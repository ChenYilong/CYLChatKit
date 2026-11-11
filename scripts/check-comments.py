#!/usr/bin/env python3
"""Public API comment format check (AGENTS.md, "Code comments"; .agents/skills/cylchatkit-comments/SKILL.md).

In the public headers of core (ChatKit/**/*.h, vendored code excluded):
- no whole-line `///` or `//!` comments and no stacked `//` comments directly above a declaration: a doc comment is a
  `/*! ... */` block, which Xcode Quick Help, DocC, and Swift's generated interface show to callers;
- no `/** ... */` doc blocks (one style only).
- single-line doc comments use the same block: no `/*! text */` on one line, no trailing `/**< */`, `/*!< */`, `///<`,
  or `//` after a declaration (one comment format per public file, for multi-line and single-line comments alike).
The file header block at the top of a file and commented-out code are not doc comments and are ignored.
With --report it also prints how many declarations have no doc comment (a TODO in docs/api-comments.md, not a failure).
"""
import os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(os.path.join(ROOT, 'ChatKit'))
files = [f for f in subprocess.check_output(['git', 'ls-files', '.']).decode().split('\n')
         if f.endswith('.h') and 'Vendor/' not in f and '.framework' not in f]
DECL = re.compile(r'^\s*(-\s*\(|\+\s*\(|@property|@interface|@protocol\s+\w+\s*(<|$)|typedef\b|FOUNDATION_EXTERN|FOUNDATION_EXPORT|UIKIT_EXTERN)')
fail, undocumented = [], 0
for f in files:
    L = open(f, encoding='utf-8', errors='replace').read().split('\n')
    head = 0
    while head < len(L) and (L[head].strip() == '' or L[head].lstrip().startswith('//')):
        head += 1
    prev = ''
    for i in range(head, len(L)):
        s = L[i].strip()
        if re.match(r'^///(?!<)|^//!', s):
            fail.append('%s:%d: use a /*! ... */ block, not %s' % (f, i + 1, s[:3]))
        if re.match(r'^/\*!.*\*/$', s) and not s.startswith('/*!\n'):
            fail.append('%s:%d: write a single-line doc comment as a /*! ... */ block on its own lines' % (f, i + 1))
        if re.search(r'\S\s*(/\*[*!]<|///<)', L[i]):
            fail.append('%s:%d: move the trailing comment into a /*! ... */ block above the declaration' % (f, i + 1))
        if re.search(r'[;,]\s*//(?!/)', L[i]) and not s.startswith('//') and 'http' not in L[i]:
            fail.append('%s:%d: move the trailing // comment into a /*! ... */ block above the declaration' % (f, i + 1))
        if re.match(r'^/\*\*(?![*<])', s):
            fail.append('%s:%d: use /*! instead of /**' % (f, i + 1))
        if re.match(r'^//(?![/!<])', s) and i + 1 < len(L) and DECL.match(L[i + 1]) and not re.search(r'[;{}]\s*$|^//\s*(-|\+|@)', s):
            fail.append('%s:%d: a // comment above a declaration is not documentation; use /*! ... */' % (f, i + 1))
        if DECL.match(L[i]) and not re.match(r'^\s*(@interface\s+\w+\s*\(|@protocol\s+\w+\s*;)', L[i]):
            if not (prev.endswith('*/') or prev.startswith('@optional') or prev.startswith('@required') or prev.startswith('#pragma')):
                undocumented += 1
        if s:
            prev = s
if fail:
    print('\n'.join(fail)); print('%d comment violation(s)' % len(fail)); sys.exit(1)
print('public API comment format passed')
if '--report' in sys.argv:
    print('declarations without a doc comment (TODO, docs/api-comments.md): %d' % undocumented)
