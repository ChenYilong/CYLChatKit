#!/usr/bin/env python3
"""Naming checks of AGENTS.md ("Objective-C and API rules"), copied from the CYLTabBarController rule.

- Core (ChatKit/) and the demo (ChatKit-OC/Example) contain no LCCK, lcck_, LCChatKit, AGEmoji, JZ, or Mp3Recorder token
  (resource names of core, such as the table LCChatKitString, are allowed).
- Every class, protocol, and enum declared in core starts with CYL; in the demo with CYLDemo (AppDelegate is the one
  system-named class). Vendored C libraries (lame.framework) and Pods are not scanned.
Exit code 1 lists every violation. Existing leftovers that are only recorded (docs/naming.md) are in ALLOWED_*.
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FORBIDDEN = re.compile(r'LCCK|lcck_|LCChatKit(?!String)|\bAGEmoji|\bJZ[A-Z]|\bMp3Recorder')
ALLOWED_LINES = re.compile(r'^\s*// Credit:|lcck_conversation_placeholder_avat|lcckkit : sdfsdf')
SCAN_EXT = ('.h', '.m', '.mm', '.swift', '.pch', '.xib', '.strings', '.sh', '.py', '.yml', '.podspec', 'Podfile')
ALLOWED_PREFIX = {'core': ('CYL',), 'demo': ('CYLDemo',)}
SYSTEM_CLASSES = {'AppDelegate'}
# Vendored classes that still carry a foreign prefix; each one is a TODO in docs/naming.md.
ALLOWED_CLASSES = {'DTDateComponent'}
fail = []


def walk(sub):
    for dp, dn, fn in os.walk(os.path.join(ROOT, sub)):
        dn[:] = [d for d in dn if d not in ('Pods', '.git', 'lame.framework') and not d.endswith('.xcodeproj')]
        for f in fn:
            yield os.path.join(dp, f)


for sub in ('ChatKit', 'ChatKit-OC/Example', 'scripts', '.github'):
    for p in walk(sub):
        if p.endswith('check-naming.py') or not p.endswith(SCAN_EXT):
            continue
        rel = os.path.relpath(p, ROOT)
        for i, line in enumerate(open(p, encoding='utf-8', errors='replace'), 1):
            if FORBIDDEN.search(line) and not ALLOWED_LINES.search(line):
                fail.append('%s:%d: forbidden legacy name: %s' % (rel, i, line.strip()[:100]))

for layer, sub, skip in (('core', 'ChatKit', ('Vendor',)), ('demo', 'ChatKit-OC/Example', ())):
    for p in walk(sub):
        rel = os.path.relpath(p, ROOT)
        if not p.endswith(('.h', '.m')) or any(s in rel.split(os.sep) for s in skip):
            continue
        text = re.sub(r'/\*.*?\*/|//[^\n]*', '', open(p, encoding='utf-8', errors='replace').read(), flags=re.S)
        for kind, rx in (('class', r'@interface\s+(\w+)\s*:\s*\w+'),
                         ('protocol', r'@protocol\s+(\w+)\s*(?:<[^>]*>)?\s*\n'),
                         ('enum', r'typedef\s+NS_(?:ENUM|OPTIONS)\s*\(\s*\w+\s*,\s*(\w+)')):
            for m in re.finditer(rx, text):
                n = m.group(1)
                if n in SYSTEM_CLASSES or n in ALLOWED_CLASSES:
                    continue
                if not n.startswith(ALLOWED_PREFIX[layer]):
                    fail.append('%s: %s %s must start with %s' % (rel, kind, n, ALLOWED_PREFIX[layer][0]))

if fail:
    print('\n'.join(sorted(set(fail))))
    print('%d naming violation(s)' % len(set(fail)))
    sys.exit(1)
print('naming checks passed')
