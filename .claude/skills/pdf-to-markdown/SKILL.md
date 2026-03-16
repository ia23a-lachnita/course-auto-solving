---
name: pdf-to-markdown
description: >
  Convert a PDF file into a Markdown document with extracted images.
  Use this skill whenever the user wants to convert a PDF to Markdown, extract content from a PDF, pull images or diagrams out of a PDF, or turn a PDF into readable text with embedded visuals. Triggers on phrases like "pdf to markdown", "extract pdf", "convert pdf", "pdf images", "pdf content", "parse pdf", or any request to process or read a PDF file into a structured text format. Even if the user just says "I have a PDF I want to work with in Markdown" — use this skill.
---

# PDF to Markdown Converter

This skill converts a PDF file into a Markdown document. It:

- Extracts **text** from every page, removing repetitive headers/footers
- Extracts **embedded images** (filters out logos, decorative elements, tiny icons)
- Detects and renders **vector-based diagrams/wireframes** that aren't embedded as images
- Produces a `.md` file with text and `![image](...)` references side by side

## Script location

```
C:\Users\xursc\projects\M107\uebungen_tag5\uebungen\utils\extract-pdf-images.py
```

## Usage

```bash
python "C:/Users/xursc/projects/M107/uebungen_tag5/uebungen/utils/extract-pdf-images.py" \
  "<pdf_path>" \
  --output "<output_dir>"
```

- `<pdf_path>` — path to the source PDF (required)
- `--output <output_dir>` — folder where the `.md` and images are saved (default: current directory)

## Workflow

1. **Ask for the PDF path** if the user hasn't provided one.
2. **Ask for the output directory** — suggest `./output` or the same folder as the PDF if the user doesn't have a preference.
3. **Check dependencies** — the script needs `PyMuPDF` and `Pillow`. If they're missing, install them:
   ```bash
   pip install pymupdf pillow
   ```
4. **Run the script** and show the live output to the user.
5. **Parse the JSON summary** printed at the end (last line of stdout) to report:
   - How many pages were processed
   - How many images were extracted
   - The path to the generated `.md` file
6. **Show a quick preview** — read the first ~50 lines of the generated Markdown and display them to the user so they can see what was produced.

## Output structure

```
<output_dir>/
├── <pdf-name>.md          ← the Markdown file
└── <pdf-name>_images/     ← extracted images referenced in the .md
    ├── image_1.png
    ├── image_2.jpg
    └── vector_page_3.png  ← rendered pages with vector diagrams
```

## Handling errors

- **File not found**: Confirm the path with the user and try again.
- **Import error** (fitz / PIL): Run `pip install pymupdf pillow` first.
- **No images extracted**: This is fine — the Markdown will still contain all text. Let the user know.
- **Permission error on output dir**: Suggest a different output path.

## Example interaction

User: "Can you convert my thesis.pdf to Markdown?"

1. Ask: "What's the path to `thesis.pdf`? And where should I save the output?"
2. Run the script.
3. Report: "Done! 42 pages processed, 7 images extracted. Markdown saved to `./output/thesis.md`."
4. Show the first 50 lines of the `.md` as a preview.
