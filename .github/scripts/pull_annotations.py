#!/usr/bin/env python3
"""Pull new Hypothesis annotations for our IG and open GitHub Issues."""

import json
import os
import sys
import textwrap
from pathlib import Path

import requests

H_TOKEN = os.environ["HYPOTHESIS_TOKEN"]
H_GROUP = os.environ["HYPOTHESIS_GROUP"]
IG_DOMAIN = os.environ["IG_DOMAIN"]  # e.g. "vzvznl.github.io/Koppeltaal-2.0-FHIR"
GH_TOKEN = os.environ["GITHUB_TOKEN"]
GH_REPO = os.environ["GITHUB_REPOSITORY"]  # "owner/repo"

STATE_PATH = Path(".feedback/processed.json")
H_API = "https://hypothes.is/api"


def load_state() -> set[str]:
    if STATE_PATH.exists():
        return set(json.loads(STATE_PATH.read_text()))
    return set()


def save_state(ids: set[str]) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(sorted(ids), indent=2) + "\n")


def fetch_annotations() -> list[dict]:
    """Pull all annotations in our group under the IG URL prefix."""
    headers = {"Authorization": f"Bearer {H_TOKEN}"}
    params = {
        "group": H_GROUP,
        "wildcard_uri": f"https://{IG_DOMAIN}/*",
        "limit": 200,
        "sort": "created",
        "order": "asc",
    }
    out: list[dict] = []
    while True:
        r = requests.get(f"{H_API}/search", params=params, headers=headers, timeout=30)
        r.raise_for_status()
        rows = r.json().get("rows", [])
        if not rows:
            break
        out.extend(rows)
        if len(rows) < params["limit"]:
            break
        # cursor pagination
        params["search_after"] = rows[-1]["created"]
    return out


def extract_quote(ann: dict) -> str:
    """Get the text that was highlighted, if any."""
    for target in ann.get("target", []) or []:
        for sel in target.get("selector", []) or []:
            if sel.get("type") == "TextQuoteSelector":
                return sel.get("exact", "") or ""
    return ""


def short_user(ann: dict) -> str:
    # "acct:alice@hypothes.is" -> "alice"
    u = ann.get("user", "")
    return u.replace("acct:", "").split("@", 1)[0] or "anonymous"


def build_issue(ann: dict) -> tuple[str, str]:
    quote = extract_quote(ann).strip()
    comment = (ann.get("text") or "").strip()
    page = ann.get("uri", "")
    incontext = (ann.get("links") or {}).get("incontext") or ""
    tags = ann.get("tags") or []
    user = short_user(ann)

    # Title: prefer first line of comment, else quoted text, else fallback
    title_source = comment.splitlines()[0] if comment else quote
    if not title_source:
        title_source = "Annotation (highlight only)"
    title = f"[feedback] {textwrap.shorten(title_source, width=80, placeholder='…')}"

    body = textwrap.dedent(f"""\
        **Page:** {page}

        **Reviewer:** {user} (via Hypothesis)

        **Highlighted text:**
        > {quote or '_(no quote — page-level note)_'}

        **Comment:**
        {comment or '_(no comment text — highlight only)_'}

        **Tags:** {', '.join(tags) if tags else '_(none)_'}

        ---
        Imported from Hypothesis annotation `{ann['id']}`.
        [Open in context]({incontext})
        """)
    return title, body


def create_issue(title: str, body: str) -> str:
    r = requests.post(
        f"https://api.github.com/repos/{GH_REPO}/issues",
        headers={
            "Authorization": f"Bearer {GH_TOKEN}",
            "Accept": "application/vnd.github+json",
        },
        json={"title": title, "body": body, "labels": ["feedback", "hypothesis"]},
        timeout=30,
    )
    r.raise_for_status()
    return r.json()["html_url"]


def main() -> int:
    processed = load_state()
    annotations = fetch_annotations()
    print(f"fetched {len(annotations)} annotations from group {H_GROUP}")
    created = 0
    for ann in annotations:
        if ann["id"] in processed:
            continue
        # Skip replies — treat them as context on the parent, not new issues.
        if ann.get("references"):
            processed.add(ann["id"])  # still mark as seen
            continue
        title, body = build_issue(ann)
        url = create_issue(title, body)
        print(f"  created issue: {url}")
        processed.add(ann["id"])
        created += 1
    save_state(processed)
    print(f"done. {created} new issue(s) created.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
