- Always check the sanity of the FSH files with the "Run the builds" section of the README.md, never run sushi or other tools like publisher.jar locally. If you want to run specific commands, change the entrypoint of the docker run command.
- The docker / Makefile publishing (publish) requires FHIR_EMAIL and FHIR_PASSWORD environment variables.
- Use Python 3 for all scripts.
- When creating new files, add them to the git index.

## Branching and versioning
- Changes to `input/fsh` are made on a feature branch. Documentation pages (input/pagecontent) and other non-FSH files may be committed directly to main.
- On a feature branch: bump only the **micro** version (e.g. 0.16.1 → 0.16.2). Update sushi-config.yaml, package.json, CHANGELOG.md, and input/pagecontent/changes.md.
- On merge to main: bump the **minor** version (e.g. 0.16.x → 0.17.0). Update sushi-config.yaml, package.json, CHANGELOG.md, and input/pagecontent/changes.md.
- CHANGELOG.md and input/pagecontent/changes.md track all micro and minor versions.

## Diagrams
- PlantUML source files go in `input/images-source/*.plantuml`. The Makefile automatically generates PNG files from these into `input/images/` during the build. Never generate PNG files manually.
- Reference generated images in pagecontent markdown wrapped in a div to prevent text wrapping around the image:
  ```html
  <div style="clear: both; margin: 1em 0;">
    <img src="filename.png" alt="Description" style="display: block; max-width: 100%; height: auto;"/>
  </div>
  ```

## Changelogs
- CHANGELOG.md and input/pagecontent/changes.md reflect **only** changes to `input/fsh` (profiles, extensions, valuesets, codesystems, examples). Documentation, scripts, build process, and other non-FSH changes do NOT belong in these files. Document those changes in the files themselves (e.g. page-level changelogs).
- Both CHANGELOG.md and input/pagecontent/changes.md must be written in **Dutch**.
