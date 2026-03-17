# Arun Sharma Books (PDFs)

## Required Books

Place the following PDF files in this directory:

1. **quant.pdf** - Quantitative Aptitude for CAT (12th Edition)
2. **LR.pdf** - Logical Reasoning for CAT (12th Edition)  
3. **DI.pdf** - Data Interpretation for CAT (12th Edition)
4. **varc.pdf** - Verbal Ability & Reading Comprehension for CAT (12th Edition)
5. **dilr.pdf** - Combined DILR (if you have it)

## Why PDFs are Not in Git

These PDF files are **125MB total** and are excluded from the repository via `.gitignore` to keep the repo size manageable.

## Options to Share PDFs:

### Option 1: Git LFS (Large File Storage)
If you want to track PDFs in Git:

```bash
# Install Git LFS
git lfs install

# Track PDF files
git lfs track "resources/books/*.pdf"

# Add and commit
git add .gitattributes
git add resources/books/*.pdf
git commit -m "Add Arun Sharma PDFs via Git LFS"
```

### Option 2: External Storage
- Upload PDFs to Google Drive / Dropbox
- Share link in README.md
- Contributors download separately

### Option 3: Local Only
- Keep PDFs locally
- Document in README that users need to acquire books separately
- **Most legal approach** (respects copyright)

---

## Current Status

PDFs are available locally at:
```
/home/hardiksjain/.openclaw/workspace/cat-prep-tracker-repo/resources/books/
```

But **not tracked in Git** by default.

---

## Copyright Notice

These books are copyrighted material by Arun Sharma and published by McGraw Hill Education.

**For educational use only.** If using this app publicly, users should acquire books legally.
