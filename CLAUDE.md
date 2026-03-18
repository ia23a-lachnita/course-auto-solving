# CLAUDE.md — M107 Workspace

## Trigger: `.`

When the user sends just `.`, run the full autonomous workflow below without asking for confirmation.

## Trigger: `init name`

When the user sends `init name`, do this immediately:

1. Ask for first and last name in one message (example: `Andre Lachnit`)
2. Wait for user input
3. Parse the input as:
  - First name = first token
  - Last name = second token
4. Update this `CLAUDE.md` file automatically so from now on all naming uses that entered name
5. Confirm shortly that the name profile is saved and active

When updating `CLAUDE.md`, replace all hardcoded identity/name patterns:

- `Name in all documents: **...**`
- `M107_<ElementName>_<LastName>_<FirstName>.docx`
- `M107_<ElementName>_<LastName>_<FirstName>.zip`
- Submission example filenames
- File Naming Convention table entries

Do not ask for extra confirmation. Apply the update directly.

---

## Identity & Style

- Name in all documents: **Andre Lachnit**
- Writing style: concise, direct, no fluff, like an 18-year-old app dev who knows what he's doing
- Readability target: write so a typical 18-year-old apprentice understands it immediately, use simple words, short sentences, and avoid unnecessary jargon
- Language: match the input document language (German input → German output, English input → English output)
- In German text, always use proper umlauts (ä, ö, ü, Ä, Ö, Ü). Do not use the sharp s character (ß); always write `ss` instead.
- Never wait for user feedback to fix language issues: proactively fix umlauts/style automatically before presenting final output
- Never use em dashes (—) in generated text; use commas, colons, or normal hyphens instead.
- If screenshots are embedded into Word, always keep the original width/height ratio and only scale the full image so it fits on the page.
- If answers are meant to be submitted, the final answer file must be Word (`.docx`), not Markdown (`.md`). Markdown may be used only as an internal draft before conversion.
- No intro sentences like "Sure, I'll help you...", just do the thing
- No trailing summaries unless explicitly asked

---

## Root Map

Keep project root clean and use these fixed locations:

- `inputs/`: newest task input drops only
- `tasks/active/`: task folders currently in progress
- `tasks/done/`: completed task folders with final ZIP
- `exercises/`: training and module exercise projects
- `references/`: templates, guides, and reference material
- `scratch/`: temporary extracts and one-off helper files
- `utils/`: shared workflow utilities

Do not create task folders directly at project root.

---

## Autonomous Workflow (triggered by `.`)

### Step 1 — Find the newest task files

Check sources in this order — stop at the first that yields a new, not-yet-done task:

**Source A — `inputs/` folder**
1. List all files in `inputs/`, sort by modification date descending
2. Group files added within ~5 min of each other (same task)
3. Pick the newest group; skip if already done (see below)

**Source B — SharePoint (via `mcp__bzz-sharepoint__list_folder`)**

**Auto-discover mode (no task name given):**
1. List the M107 base folder:
   `list_folder("/sites/UBSLernende2324-23_Appi-A/Freigegebene Dokumente/23_Appi-A/M107")`
2. Collect all Tag folders whose date is today or earlier. Parse the date from each folder name, sort newest-first.
3. For each Tag folder, list its direct contents (depth=1). Identify task items — each item is either:
   - A **single file** (PDF, DOCX, ZIP) directly in the Tag folder → that file alone is one task
   - A **subfolder** (any subfolder except `Abgaben` and system folders) → that subfolder and all its contents is one task
   - Ignore the `Abgaben` folder entirely (that is for submissions, not task input)
4. For each task item:
   a. Derive `task-name` from the file or folder name (lowercase, hyphens, no extension)
   b. If `tasks/done/<task-name>_*/` exists with a ZIP → done, skip
   c. If `tasks/active/<task-name>_*/` exists → in progress, mark as undone (no re-download)
   d. Otherwise → undone; download the file or all files inside the subfolder into `inputs/<task-name>/`
5. Collect **all** undone task items across all Tag folders and also from the `LBs` folder (same logic applies there).
6. If everything is done → tell the user and stop.
7. If exactly one undone task is found: show that task and ask first, `Ist das die richtige Aufgabe? (ja/nein)`. Only continue after `ja`.
8. If multiple undone tasks found: list them all with their source (Tag folder / LBs), then ask which one to work on (or "all" to chain). Do not auto-pick.

**Named mode (user specifies task name or date):**
1. List the M107 base folder to find the Tag folder matching the given name or date
2. List that Tag folder to find the task file
3. Apply the done-check: if already in `tasks/done/`, tell the user and ask if they want to redo it
4. Download into `inputs/` and proceed

**Source C — Downloads folder**
- Sort by modification date descending, group related files within ~5 minutes
- Pick the newest valid group not already done
- Move into `inputs/` (preserve filenames)

**Already-done check:**
- Derive `task-name` from the main input file (lowercase, hyphens, no extension)
- If a folder in `tasks/active/` or `tasks/done/` like `<task-name>_YYYY-MM-DD/` already exists and contains a finished submission ZIP, treat the task as already done

If no valid new task exists in any source: tell the user and stop.

### Step 2 — Extract & convert input files

Handle input files manually (no external prepare script):

- **ZIP files**: extract with Python `zipfile` into a temp subfolder inside `inputs/`
- **PDF files**:
  - To **read/understand** the task content: use the `/pdf-to-markdown` skill (PDF → Markdown with image extraction)
  - To **convert a PDF to a submittable Word document**: use `mcp__acrobat-converter__convert_pdf_to_word` — this uses Adobe Acrobat Pro locally and produces native-quality DOCX output
- **JSON files**: read directly
- **Markdown / text files**: read directly

Work out of the extracted content — no separate `.context` folder needed.

### Step 3 — Create task folder under tasks/active

- Name format: `tasks/active/<task-name>_<YYYY-MM-DD>/`
- `task-name` = main input file name, lowercase, hyphens, no extension
- Example: `tasks/active/lb2-dokumentation_2026-03-16/`
- Create a `solution/` subfolder inside it

### Step 4 — Read & understand the task

- Read all converted Markdown files from the input
- Read any extracted images (diagrams, wireframes) embedded in those files
- Read any JSON data
- Check related previous tasks in `tasks/done/` (and matching items in `tasks/active/`) to see whether this task is a continuation
- Reuse already answered parts when the new task explicitly builds on earlier work; avoid rewriting completed content from scratch
- Understand exactly what needs to be delivered before writing a single line

### Step 5 — Solve the task

- Solve everything the task asks for
- Write code/scripts/SQL/config files directly into `<task-folder>/solution/`
- If written answers are required for submission, draft in Markdown if helpful, then convert to Word and submit the `.docx` version
- Use wireframes/diagrams as UI reference if present
- Never change the assignment format or structure, keep all sections/checklist points/questions from the assignment, do not drop anything

### Step 5.2 — Re-read assignment and define deliverables

Before packaging, read the assignment again and build an explicit deliverables contract:

1. List every required output artifact from the assignment (documents, code files, screenshots, logs, etc.)
2. Mark each item as `required` and map it to the concrete file path in `solution/`
3. Mark any files that are helper-only and not required for submission
4. Do not continue until all required items exist and are complete

### Step 5.3 — User-action dependency handling

If any required action cannot be executed by the agent alone (wallet interaction, login, MFA, CAPTCHA, GUI steps, screenshots, manual confirmations):

1. Inform the user immediately, do not delay
2. Provide exact step-by-step actions the user must perform
3. Explain what result/proof is needed from each action
4. Continue automatically as soon as user confirms the action is done

### Step 5.4 — Screenshot support workflow

When screenshots are required by the assignment:

1. List all required screenshots explicitly
2. For each screenshot, provide:
  - where to navigate
  - what action to run
  - what must be visible in the captured image
3. Tell the user where to save screenshot files in `solution/`
4. Validate screenshot files exist before packaging

### Step 5.6 — Mandatory subagent quality review loop

After creating the solution, run a subagent review loop with the full assignment text and the produced solution.

1. Ask the subagent to review completeness, correctness, formatting compliance, and submission readiness
2. If result is not rated perfect, fix issues and run the review again
3. Repeat until the subagent rates the solution as perfect and no hard external blocker is identified
4. If blocked, report exactly what is missing and what the user must do

### Step 5.5 — Mandatory final check before Word conversion

Before starting Step 6, run a full final check across all deliverable content (code, Markdown draft, filenames, and submission text).

Required checks:

- Language/style compliance:
  - In German text, use proper umlauts (`ä, ö, ü, Ä, Ö, Ü`)
  - Never use `ß`, always use `ss`
  - Text must sound natural and simple for an 18-year-old apprentice, avoid over-complex wording
  - No em dash (`—`), use comma/colon/normal hyphen
  - Mandatory hard gate command: `pwsh -File ./utils/check-german-style.ps1 -Path <task-folder>/solution`
  - If this command exits with non-zero code, STOP packaging and fix all reported lines first
- Content completeness:
  - All required task questions/sections are fully answered
  - No TODO placeholders remain
- Technical correctness:
  - Required scripts/tests run successfully (if applicable)
  - Referenced files actually exist in `<task-folder>/solution/`
- Naming compliance:
  - Word and ZIP names strictly match the naming convention

If any check fails, fix everything first. Only then continue to Step 6 (Word conversion).

### Step 6 — Create Word document for submitted answers/documents

Do this whenever answers, a report, or documentation are part of the submission.

1. Always use the `/docx` skill.
2. If the task input contains any `.docx` file: **do not create a new document from scratch**.
3. Instead, copy the existing input `.docx` into `<task-folder>/solution/` and edit that copy in place.
4. Keep layout 1:1 (same styles, spacing, tables, line boxes, headers, colors, and page setup).
5. Fill existing placeholders/answer lines/tables so text visually fits, no clipping/overflow.
6. If screenshots are embedded, preserve original aspect ratio and only scale uniformly so the full image fits on the page.
7. Only if there is no input `.docx` at all, create a new `.docx` with `/docx` skill.
8. Name: `M107_<ElementName>_Lachnit_Andre.docx`
9. Save to `<task-folder>/solution/`

### Step 7 — Package the solution

1. ZIP everything in `<task-folder>/solution/`
2. Name: `M107_<ElementName>_Lachnit_Andre.zip`
3. Save ZIP to `<task-folder>/`
4. Present a review block before upload:
  - full ZIP file list
  - one-line purpose for each file and why it is included
  - explicit mapping against the deliverables contract from Step 5.2
5. Wait for explicit user command `upload`
6. Do not upload anything before `upload`
7. Move finished task folder from `tasks/active/` to `tasks/done/` only after successful upload

### Step 8 — Upload to SharePoint and report

Only run this step after the user explicitly sends `upload`.

1. **Find the correct submission folder on SharePoint** using `mcp__bzz-sharepoint__list_folder`:
   - For LB tasks: `/sites/UBSLernende2324-23_Appi-A/Freigegebene Dokumente/23_Appi-A/M107/LBs/Element <N>/AbgabenElement<N> - Teil <X>/Andre`
   - For daily tasks: `/sites/UBSLernende2324-23_Appi-A/Freigegebene Dokumente/23_Appi-A/M107/Tag <N> - <DD.MM.YYYY>/Abgaben/Andre`
   - Always call `list_folder` first to confirm the exact path — never guess
2. **Upload** the ZIP with `mcp__bzz-sharepoint__upload_file`
3. Report what was uploaded:

```
Done. Uploaded:

  LBs/Element 3/AbgabenElement3 - Teil A/Andre/M107_E3_TeilA_Lachnit_Andre.zip

Local copy:
  tasks/done/m107-e3-teila-verschluesselung_2026-03-17/M107_E3_TeilA_Lachnit_Andre.zip

Contains:
  - M107_E3_TeilA_Lachnit_Andre.docx
  - blockchain_encrypt.py
  - test_blockchain.py
```

---

## File Naming Convention

| Type | Pattern |
|------|---------|
| Task folder (active) | `tasks/active/<task-name>_YYYY-MM-DD/` |
| Task folder (done) | `tasks/done/<task-name>_YYYY-MM-DD/` |
| Solution files | `<task-folder>/solution/` |
| Word doc | `M107_<Element>_Lachnit_Andre.docx` |
| ZIP submission | `M107_<Element>_Lachnit_Andre.zip` |

---

## Tools

- **PDF → Markdown** (read/understand): `/pdf-to-markdown` skill
- **PDF → Word** (convert for submission): `mcp__acrobat-converter__convert_pdf_to_word` — uses Adobe Acrobat Pro locally, native quality
  - Single file: `convert_pdf_to_word(pdf_path, output_path)`
  - Whole folder: `convert_folder_to_word(folder_path, output_folder)`
- **Word documents** (create/edit): `/docx` skill (only when task requires it)
- **ZIP**: Bash `zip -r` or Python `zipfile`
- **SharePoint**: `mcp__bzz-sharepoint__list_folder`, `mcp__bzz-sharepoint__download_file`, `mcp__bzz-sharepoint__upload_file`
  - Base site: `/sites/UBSLernende2324-23_Appi-A/Freigegebene Dokumente/23_Appi-A/M107`
  - Always `list_folder` before upload to confirm the path exists
  - Only upload to paths containing `/Andre/`

---

## What NOT to do

- Don't ask "should I proceed?" — just do it
- Don't create a `workspace/` folder — work directly at project root
- Don't run `prepare-input.py` — that's from another project
- Don't submit answer documents as Markdown files when they must be handed in, submit Word (`.docx`) instead
- Don't write fluff intro paragraphs in documents
- Don't create extra files that aren't part of the solution
