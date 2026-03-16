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
- Writing style: concise, direct, no fluff — like an 18-year-old app dev who knows what he's doing
- Language: match the input document language (German input → German output, English input → English output)
- No intro sentences like "Sure, I'll help you..." — just do the thing
- No trailing summaries unless explicitly asked

---

## Autonomous Workflow (triggered by `.`)

### Step 1 — Find the newest task files in `inputs/`

1. Look in `inputs/` at the root of this project
2. Sort all files by modification date descending
3. Group files added at the same time (within ~5 min of each other) — those belong to one task
4. Pick the newest group as the current task
5. Check whether that task is already done:
  - Derive `task-name` from the main input file (lowercase, hyphens, no extension)
  - If a root folder like `<task-name>_YYYY-MM-DD/` already exists and contains a finished submission ZIP for that element, treat the task as already done

Fallback behavior (automatic, no questions):

- If `inputs/` is empty, or the newest grouped task is already done, check the user's Downloads folder for new task files
- In Downloads, sort by modification date descending and group related files within ~5 minutes
- Pick the newest valid task group that is not already done
- Move that group into `inputs/` (preserve filenames)
- Continue the workflow from `inputs/` as normal

If no valid task exists in both `inputs/` and Downloads: tell the user no new task files were found and stop.

### Step 2 — Extract & convert input files

Handle input files manually (no external prepare script):

- **ZIP files**: extract with Python `zipfile` into a temp subfolder inside `inputs/`
- **PDF files**: use the `/pdf-to-markdown` skill to convert PDFs → Markdown with image extraction
- **JSON files**: read directly
- **Markdown / text files**: read directly

Work out of the extracted content — no separate `.context` folder needed.

### Step 3 — Create task folder at project root

- Name format: `<task-name>_<YYYY-MM-DD>/` directly in the project root
- `task-name` = main input file name, lowercase, hyphens, no extension
- Example: `lb2-dokumentation_2026-03-16/`
- Create a `solution/` subfolder inside it

### Step 4 — Read & understand the task

- Read all converted Markdown files from the input
- Read any extracted images (diagrams, wireframes) embedded in those files
- Read any JSON data
- Understand exactly what needs to be delivered before writing a single line

### Step 5 — Solve the task

- Solve everything the task asks for
- Write code/scripts/SQL/config files directly into `<task-folder>/solution/`
- If the task explicitly requires written documentation → write it as Markdown in `<task-folder>/solution/` first
- Use wireframes/diagrams as UI reference if present

### Step 6 — Create Word document (only if the task explicitly requires a document)

Only do this if the task clearly asks for a Word document, report, or documentation file.

1. Use the `/docx` skill to convert the Markdown to `.docx`
2. **Match the input document format exactly:**
   - Font: Arial, base 11pt
   - Heading 1: bold, 16pt, color `1F3864`
   - Heading 2: bold, 13pt, color `2E75B6`
   - Tables: single border `999999`, header shading `D0E4F7`
   - If a `*_Nachname_Vorname.docx` template exists in the input, use it as format reference
3. Name: `M107_<ElementName>_Lachnit_Andre.docx`
4. Save to `<task-folder>/solution/`

### Step 7 — Package the solution

1. ZIP everything in `<task-folder>/solution/`
2. Name: `M107_<ElementName>_Lachnit_Andre.zip`
3. Save ZIP to `<task-folder>/`

### Step 8 — Tell the user what to submit

Be specific:

```
Done. Submit this:

  lb2-dokumentation_2026-03-16/M107_LB2_Lachnit_Andre.zip

Contains:
  - M107_LB2_Lachnit_Andre.docx
  - solution.sql
```

---

## File Naming Convention

| Type | Pattern |
|------|---------|
| Task folder | `<task-name>_YYYY-MM-DD/` (at project root) |
| Solution files | `<task-folder>/solution/` |
| Word doc | `M107_<Element>_Lachnit_Andre.docx` |
| ZIP submission | `M107_<Element>_Lachnit_Andre.zip` |

---

## Tools

- **PDF → Markdown**: `/pdf-to-markdown` skill
- **Word documents**: `/docx` skill (only when task requires it)
- **ZIP**: Bash `zip -r` or Python `zipfile`

---

## What NOT to do

- Don't ask "should I proceed?" — just do it
- Don't create a `workspace/` folder — work directly at project root
- Don't run `prepare-input.py` — that's from another project
- Don't create Word docs unless the task explicitly requires a document
- Don't write fluff intro paragraphs in documents
- Don't create extra files that aren't part of the solution
