# course-auto-solving

Minimal setup for the autonomous M107 solving workflow.

## Included
- `CLAUDE.md` with the `.` trigger workflow
- `.claude/` agent skills and local settings
- `inputs/utils/prepare-input.py` helper utility
- `.claude/skills/pdf-to-markdown/scripts/extract-pdf-images.py` PDF-to-Markdown extractor

## Excluded by design
Task-specific files and generated artifacts are ignored (`inputs` drops, extracted outputs, zips, images, docs, caches, etc.).

## Usage
1. Drop new task files into `inputs/` (local, ignored by git).
2. Open the workspace in VS Code with Copilot agent mode.
3. Send `.` to run the autonomous workflow from `CLAUDE.md`.

## Local Workspace Layout
- `tasks/active/`: task folders currently being solved
- `tasks/done/`: completed task folders with final ZIP submissions
- `exercises/`: practice and module exercise projects
- `references/`: templates, guides, and reference material
- `scratch/`: temporary extraction files and one-off helper scripts
