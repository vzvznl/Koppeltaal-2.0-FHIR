# Contributing to Koppeltaal 2.0 FHIR

Thank you for your interest in contributing to the Koppeltaal 2.0 FHIR Implementation Guide!

## Prerequisites

Before you start contributing, make sure you have:

- **Git** installed on your computer
- **Docker** installed (recommended for building and testing)
- **VSCode** (recommended) or another code editor
- A **GitHub account**
- Access to this repository

## Development Workflow

We use a feature branch workflow with pull requests for all contributions. This guide will walk you through each step.

### 1. Get the Latest Code

Before creating a new feature branch, make sure you have the latest code from the `main` branch.

**Using the command line:**

```bash
# Make sure you're on the main branch
git checkout main

# Get the latest changes from GitHub
git pull origin main
```

**Using VSCode:**

1. Click on the branch name in the bottom-left corner (should show `main`)
2. If not on `main`, select `main` from the dropdown
3. Click the refresh/sync icon in the bottom-left corner to pull latest changes

### 2. Create a Feature Branch

Create a new branch for your work. Use descriptive names that explain what you're working on.

**Using the command line:**

```bash
# Create and switch to a new branch
git checkout -b feature/your-feature-name
```

**Using VSCode:**

1. Click on the branch name in the bottom-left corner (should show `main`)
2. Select `+ Create new branch...`
3. Enter your branch name (e.g., `feature/add-new-profile`)
4. Press Enter

**Branch naming conventions:**
- `feature/` for new features (e.g., `feature/add-practitioner-role`)
- `fix/` for bug fixes (e.g., `fix/patient-identifier-cardinality`)
- `docs/` for documentation updates (e.g., `docs/update-readme`)

### 3. Make Your Changes

Now you can make your changes to the FHIR Implementation Guide.

**Common files to edit:**

- **FHIR Profiles and Extensions**: `input/fsh/` directory
  - Edit existing `.fsh` files or create new ones
  - These define your FHIR profiles, extensions, value sets, and code systems

- **Documentation**: `input/pagecontent/` directory
  - Markdown files (`.md`) for human-readable documentation

**VSCode Tips:**

- Use the **Explorer** panel (left sidebar) to navigate files
- The **Source Control** panel (Git icon in left sidebar) shows your changes
- Files with changes will have an **M** (modified) or **U** (untracked) indicator

**Important:** Don't update the version in `sushi-config.yaml` or `CHANGELOG.md` on feature branches - maintainers will handle this when merging to `main`.

### 4. Test Your Changes

Always validate your changes before pushing to ensure your FSH files compile correctly.

#### First Time: Build the Docker Image

If you haven't built the Docker image yet, you need to do this once:

**Using the command line:**

```bash
# Navigate to the project directory
cd /path/to/Koppeltaal-2.0-FHIR

# Build the Docker image (this takes a few minutes)
docker build . -t koppeltaal-builder
```

**Using VSCode:**

1. Open the **Terminal** in VSCode (Terminal → New Terminal)
2. Run the command above in the terminal

#### Run the Build to Validate Your Changes

**Using the command line:**

```bash
# Build and validate your FHIR resources
docker run -v ${PWD}:/src koppeltaal-builder
```

**Using VSCode:**

1. Open the **Terminal** in VSCode (Terminal → New Terminal)
2. Run the Docker command above
3. Wait for the build to complete (usually 1-2 minutes)
4. Check the output for errors

**What to look for:**

- ✅ **Success**: Look for "Successfully created" messages at the end
- ❌ **Errors**: SUSHI will show errors in red - fix these before committing
- ⚠️ **Warnings**: Yellow warnings are okay but review them

**Note**: You don't need any credentials for testing. These are only required for publishing to Simplifier.net, which is handled by maintainers.

### 5. Commit Your Changes

Once your changes are tested and working, commit them to your feature branch.

**Using the command line:**

```bash
# See what files you changed
git status

# Add your changed files
git add input/fsh/MyNewProfile.fsh
git add input/pagecontent/my-documentation.md

# Or add all changed files at once
git add .

# Commit with a descriptive message
git commit -m "Add new Patient profile with custom extensions"
```

**Using VSCode:**

1. Click on the **Source Control** icon in the left sidebar (looks like a branch)
2. Review your **Changes** - you'll see all modified files listed
3. **Stage your changes:**
   - Hover over each file and click the **+** icon to stage individual files
   - Or click the **+** icon next to "Changes" to stage all files
4. Type a **commit message** in the text box at the top (e.g., "Add new Patient profile with custom extensions")
5. Click the **✓ Commit** button (or press Cmd+Enter / Ctrl+Enter)

**Writing good commit messages:**

- Keep the first line under 50 characters
- Use the imperative mood ("Add feature" not "Added feature")
- Be specific about what changed
- Examples:
  - ✅ "Add Patient profile with Dutch address requirements"
  - ✅ "Fix cardinality constraint on Practitioner.identifier"
  - ❌ "Update files"
  - ❌ "WIP"

### 6. Push Your Changes to GitHub

After committing, push your feature branch to GitHub so others can see it.

**Using the command line:**

```bash
# Push your branch to GitHub
git push origin feature/your-feature-name

# First time pushing a new branch, Git might ask you to set upstream:
git push --set-upstream origin feature/your-feature-name
```

**Using VSCode:**

1. After committing, look at the bottom-left corner
2. Click the **cloud/sync icon** (↑) next to your branch name
3. If this is your first push, VSCode will ask to "publish branch" - click **OK**
4. VSCode will push your changes to GitHub

### 7. Create a Pull Request

Now that your changes are pushed to GitHub, create a Pull Request (PR) to merge your changes into the `main` branch.

**Using GitHub (Web Interface):**

1. **Go to the repository** on GitHub
2. You'll usually see a yellow banner saying "Your recently pushed branches" with a **Compare & pull request** button - click it
3. If you don't see the banner:
   - Click the **Pull requests** tab
   - Click the green **New pull request** button
   - Select your feature branch from the "compare" dropdown
4. **Fill in the PR form:**
   - **Title**: Short description of your changes (e.g., "Add Patient profile with Dutch address requirements")
   - **Description**: Explain:
     - What you changed and why
     - Any relevant context
     - How to test the changes (if applicable)
     - Reference any related issues (e.g., "Fixes #123")
5. Click **Create pull request**

**Using VSCode with GitHub Pull Requests Extension:**

1. Install the **GitHub Pull Requests and Issues** extension (if not already installed)
2. Click the **GitHub** icon in the left sidebar
3. Click **Create Pull Request**
4. Fill in the title and description
5. Click **Create**

**What happens next:**

- Automated tests will run on your PR
- Team members will review your changes
- You may receive feedback or change requests

### 8. Address Review Feedback

If reviewers request changes:

**Making updates:**

1. Make the requested changes in your feature branch (same as step 3)
2. Test your changes again (step 4)
3. Commit the changes (step 5)
4. Push to GitHub (step 6)
5. The pull request will **automatically update** with your new commits

**Using VSCode:**

1. Make your changes in the editor
2. Go to **Source Control** panel
3. Stage, commit, and push (same process as before)
4. Go to GitHub to see your PR updated

**Responding to comments:**

- You can reply to review comments on GitHub
- Mark conversations as resolved when you've addressed them
- Ask questions if you're unsure about feedback

### 9. Merge and Cleanup

Once your pull request is approved:

1. **A maintainer will merge** your PR into `main`
2. **Delete your feature branch** (to keep the repository clean):

**Using the command line:**

```bash
# Switch back to main
git checkout main

# Update your local main with the merged changes
git pull origin main

# Delete your local feature branch
git branch -d feature/your-feature-name

# Delete the remote branch on GitHub (if not already deleted)
git push origin --delete feature/your-feature-name
```

**Using VSCode:**

1. GitHub usually prompts you to delete the branch after merging - click **Delete branch**
2. In VSCode, click on the branch name in bottom-left
3. Select `main` to switch back
4. Click the refresh icon to pull latest changes
5. To delete the local branch:
   - Open **Command Palette** (Cmd+Shift+P / Ctrl+Shift+P)
   - Type "Git: Delete Branch"
   - Select your feature branch from the list

**Using GitHub (Web Interface):**

1. After the PR is merged, GitHub shows a **Delete branch** button
2. Click it to remove the remote branch

**Congratulations!** Your contribution is now part of the project! 🎉

---

## VSCode Quick Reference Guide

This section provides a quick reference for common git operations in VSCode.

### Setting Up VSCode

**Recommended Extensions:**

1. **GitHub Pull Requests and Issues** - Create and manage PRs directly in VSCode
2. **GitLens** - Enhanced git visualization and history
3. **FSH Language Support** - Syntax highlighting for FHIR Shorthand files

**Install extensions:**
- Click the Extensions icon in the left sidebar (looks like building blocks)
- Search for the extension name
- Click **Install**

### Common VSCode Git Operations

| Action | How to do it in VSCode |
|--------|------------------------|
| **See current branch** | Look at bottom-left corner of window |
| **Switch branches** | Click branch name → select branch from list |
| **Create new branch** | Click branch name → "+ Create new branch..." |
| **See changed files** | Click Source Control icon (left sidebar) |
| **Stage files** | Hover over file → click **+** icon |
| **Unstage files** | Hover over staged file → click **−** icon |
| **Commit changes** | Type message in text box → Click ✓ or Cmd+Enter |
| **Push to GitHub** | Click cloud/sync icon (↑) in bottom-left |
| **Pull from GitHub** | Click refresh icon in bottom-left |
| **View file changes** | Click on file in Source Control panel |
| **Discard changes** | Right-click file → "Discard Changes" |

### VSCode Terminal Commands

You can also use git commands in VSCode's integrated terminal:

1. Open terminal: **Terminal → New Terminal** (or Ctrl+\`)
2. Run any git or docker commands
3. The terminal starts in your project directory

### Viewing Build Output in VSCode

When running the Docker build command in VSCode terminal:

1. The output appears directly in the terminal
2. Scroll up to see SUSHI errors/warnings
3. Look for colored output:
   - 🔴 Red = Errors (must fix)
   - 🟡 Yellow = Warnings (review)
   - 🟢 Green = Success messages

---

## Guidelines

### Version Updates

**For Contributors:** Do NOT update version numbers or CHANGELOG.md on feature branches.

**For Maintainers:** When updating the version in `sushi-config.yaml` on `main` branch, also update:
- `CHANGELOG.md` with changes to `./input/fsh` only (not build process or scripts)
- `package.json` with the same version number

### File Operations

When working with git:

- ✅ Use `git rm` instead of plain `rm` when deleting files
- ✅ Use `git mv` instead of plain `mv` when moving files
- ✅ Always add new files to git (except generated files)
- ❌ Do not add generated files to git (files in `output/`, `fsh-generated/`, etc.)

### Code Quality

- Follow existing code patterns and structure in `.fsh` files
- Test your changes thoroughly before submitting a PR
- Keep commits focused and atomic (one logical change per commit)
- Write clear, descriptive commit messages
- Don't commit commented-out code - remove it or explain why it's there

## Build Process

This project uses a dual-build approach:
1. **Full Documentation Package** - For GitHub Pages and human-readable documentation
2. **Minimal Server Package** - For HAPI FHIR servers (solves database constraints)

See [BUILD.md](BUILD.md) for detailed technical information about the build system.

## Getting Help

- 📖 **Build documentation**: Check [README.md](README.md) for build and deployment documentation
- 🐛 **Issues**: Review existing [issues](../../issues) to see if your question has been answered
- 💬 **Questions**: Ask questions in your pull request or open a new issue
- 📚 **FHIR IG Publisher docs**: See [HL7 FHIR IG Publisher documentation](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation)

## Troubleshooting

### Common Issues

**Problem:** Docker build fails with "permission denied"

**Solution:**
- Make sure Docker Desktop is running
- On Linux, you may need to use `sudo docker ...`

**Problem:** SUSHI shows errors about unknown resources

**Solution:**
- Make sure dependencies are installed (Docker handles this automatically)
- Check that you're referencing the correct resource names

**Problem:** Git says "Your branch is behind 'origin/main'"

**Solution:**
```bash
# Pull the latest changes
git pull origin main
```

**Problem:** Can't push to GitHub

**Solution:**
- Make sure you've committed your changes first
- Check that you have write access to the repository
- In VSCode, you may need to sign in to GitHub (click account icon in bottom-left)

**Problem:** Build succeeds but I see warnings

**Solution:**
- Warnings are usually okay, but review them
- Common warnings about slice max values are expected
- Fix any warnings that seem relevant to your changes

---

## Questions?

If you have questions or need help:
- 💬 Ask in your pull request
- 🐛 [Open an issue](../../issues/new)
- 📧 Contact the maintainers

Thank you for contributing to Koppeltaal 2.0 FHIR! 🙏
