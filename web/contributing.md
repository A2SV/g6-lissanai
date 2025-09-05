# 🌟 Contributing to LissanAI – AI English Communication Coach

Thank you for contributing to LissanAI!
This document outlines the workflow and guidelines to ensure smooth collaboration.

## 1️⃣ Branching Strategy
### Main Branch

- main is the source of truth.

- Always in a working, stable state.

- No direct commits to main.

### Feature Branch Workflow

1. Create a branch from the latest main:
```bash
git checkout main
git pull origin main
git checkout -b feat/your-feature-name
```
## 2️⃣ Naming Conventions
### Branch Naming

Format: type_short-description

Types:

- feat – New feature (e.g., feat_speech-recognition)

- fix – Bug fix (e.g., fix_audio-recording-bug)

- docs – Documentation changes (e.g., docs_update-readme)

- style – Code formatting only, no logic changes (e.g., style_css-format)

- refactor – Code changes without altering behavior (e.g., refactor_backend-api-structure)

- test – Adding/fixing tests (e.g., test_add-pronunciation-tests)

### Commit Messages

Follow the Conventional Commits
 format:
```bash
<type>: <short description>
```

Examples:
```bash
feat: add Amharic-to-English email drafting

fix: resolve crash when recording long audio

docs: update setup guide with backend instructions

refactor: modularize grammar feedback service

style: apply prettier formatting to backend code

test: add unit tests for writing assistant API
```
## 3️⃣ Pull Requests (PRs)
### Creating a PR

1. Push your branch to GitHub:
```bash
git push -u origin feat/your-branch-name
```

2. Open a PR from your branch into **main**.

3. PR Template:
```bash
### Description
Explain the changes and why they are needed.

### Related Issue
Closes #<issue-number>
```
### Review Process

- Request 1–2 reviews from teammates.

- Be open to feedback.

- Approve only if the PR meets requirements and passes tests.

### Merging

- Merge only after approvals and passing CI checks.

- Delete the branch after merging.

## 4️⃣ Handling Merge Conflicts

### Steps:

1. Update local main:
```bash
git checkout main
git pull origin main
```

2. Switch to your branch:
```bash
git checkout feat/your-branch-name
git merge main
```

3. Fix conflicts in files (look for <<<<<<< HEAD markers).

4. Stage and commit:
```bash
git add .
git commit -m "chore: resolve merge conflicts with main"
git push
```

Keep commits small and focused.