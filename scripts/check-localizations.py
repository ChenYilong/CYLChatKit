#!/usr/bin/env python3
"""Check localization tables (docs/localization.md).

For every `<lang>.lproj/<Table>.strings` under ChatKit/ and ChatKit-OC/Example/:
- the file must parse as a strings file (`"key" = "value";` entries and comments), and
- every language of the same table in the same folder must have the same key set.

It also checks the layer-macro acceptance criterion (AGENTS.md, "Internationalization and localization"): core
(ChatKit/, vendored code excluded) and the example (ChatKit-OC/Example/) each define at least one localization macro,
the two layers use different macro names, each macro names a bundle of its own layer, and no macro reads a bundle that
belongs to the other layer.

Vendor and legacy tables (LEGACY below) differ by language on purpose (plural variants, per-language emoji
names), so their key differences are reported as warnings only. Every other table must match exactly.

Usage: scripts/check-localizations.py [root]   Exits 1 when a check fails.
"""
import collections
import os
import re
import sys

ENTRY = re.compile(r'\s*"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;', re.S)
COMMENT = re.compile(r'\s*(/\*.*?\*/|//[^\n]*)', re.S)


# (folder, table) pairs whose key sets differ by design. Keep this list short; never add a project-owned table.
LEGACY = {
    ('ChatKit/Class/Resources/DateTools.bundle', 'DateTools.strings'),
    ('ChatKit/Class/Resources/CYLPBLocalizations.bundle', 'Localizable.strings'),
    ('ChatKit/Class/Resources', 'EmojiLocalizable.strings'),
}


def parse(path):
    data = open(path, 'rb').read()
    for encoding in ('utf-8-sig', 'utf-16'):
        try:
            text = data.decode(encoding)
            break
        except UnicodeDecodeError:
            continue
    else:
        raise ValueError('unknown encoding')
    keys, pos = [], 0
    while pos < len(text):
        m = COMMENT.match(text, pos) or ENTRY.match(text, pos)
        if m:
            if m.re is ENTRY:
                keys.append(m.group(1))
            pos = m.end()
        elif text[pos:].strip() == '':
            break
        else:
            line = text.count('\n', 0, pos) + 1
            raise ValueError('syntax error near line %d' % line)
    return keys


LOCALIZATION_API = re.compile(r'NSLocalizedString\w*|localizedStringForKey:')
MACRO = re.compile(r'^[ \t]*#[ \t]*define[ \t]+(\w+)(?:\([^)]*\))?((?:[^\n]*\\\n)*[^\n]*)', re.M)
STRING_LITERAL = re.compile(r'@"((?:[^"\\]|\\.)*)"')


def bundle_names(root, base):
    names = set()
    for dirpath, dirnames, _ in os.walk(os.path.join(root, base)):
        dirnames[:] = [d for d in dirnames if d != 'Pods']
        for d in dirnames:
            if d.endswith('.bundle'):
                names.add(d[:-len('.bundle')])
    return names


def layer_macros(root, base, skip):
    """Returns {macro name: [string literals in its body]} for localization macros defined in headers under base."""
    macros = {}
    for dirpath, dirnames, filenames in os.walk(os.path.join(root, base)):
        dirnames[:] = [d for d in dirnames if d != 'Pods' and not d.endswith('.bundle')]
        if any(part in dirpath.replace(os.sep, '/').split('/') for part in skip):
            continue
        for name in filenames:
            if not name.endswith('.h'):
                continue
            text = open(os.path.join(dirpath, name), encoding='utf-8', errors='replace').read()
            for m in MACRO.finditer(text):
                body = m.group(2)
                if LOCALIZATION_API.search(body):
                    macros[m.group(1)] = STRING_LITERAL.findall(body)
    return macros


def check_macros(root):
    """The two-macro acceptance criterion. Returns the number of failures."""
    core_bundles = bundle_names(root, 'ChatKit')
    example_bundles = bundle_names(root, os.path.join('ChatKit-OC', 'Example'))
    core = layer_macros(root, 'ChatKit', {'Vendor'})
    example = layer_macros(root, os.path.join('ChatKit-OC', 'Example'), set())
    failures = 0
    for layer, macros, own, other in (('core', core, core_bundles, example_bundles),
                                      ('example', example, example_bundles, core_bundles)):
        if not macros:
            print('error: no localization macro found in the %s layer' % layer)
            failures += 1
        for name, literals in sorted(macros.items()):
            mine = sorted(set(literals) & own)
            foreign = sorted(set(literals) & other)
            if not mine:
                print('error: %s macro %s does not name a bundle of the %s layer' % (layer, name, layer))
                failures += 1
            if foreign:
                print('error: %s macro %s reads a bundle of the other layer: %s' % (layer, name, ', '.join(foreign)))
                failures += 1
            print('%s macro: %s -> bundle %s' % (layer, name, ', '.join(mine) or '?'))
    shared = sorted(set(core) & set(example))
    if shared:
        print('error: core and example use the same macro name: %s' % ', '.join(shared))
        failures += 1
    if core and example and not shared:
        print('%d different localization macros (core: %d, example: %d)' % (len(core) + len(example), len(core), len(example)))
    return failures


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..')
    tables = collections.defaultdict(dict)  # (folder, table) -> {lang: keys}
    failures = 0
    for base in ('ChatKit', os.path.join('ChatKit-OC', 'Example')):
        for dirpath, dirnames, filenames in os.walk(os.path.join(root, base)):
            dirnames[:] = [d for d in dirnames if d != 'Pods']
            if not dirpath.endswith('.lproj'):
                continue
            for name in filenames:
                if not name.endswith('.strings'):
                    continue
                path = os.path.join(dirpath, name)
                rel = os.path.relpath(path, root)
                try:
                    keys = parse(path)
                except ValueError as error:
                    print('error: %s: %s' % (rel, error))
                    failures += 1
                    continue
                dupes = sorted(k for k, n in collections.Counter(keys).items() if n > 1)
                if dupes:
                    print('warning: %s: duplicate keys %s' % (rel, ', '.join(dupes)))
                folder = os.path.relpath(os.path.dirname(dirpath), root)
                tables[(folder, name)][os.path.basename(dirpath)[:-len('.lproj')]] = set(keys)
    for (folder, table), langs in sorted(tables.items()):
        if len(langs) < 2:
            continue
        union = set().union(*langs.values())
        legacy = (folder.replace(os.sep, '/'), table) in LEGACY
        for lang, keys in sorted(langs.items()):
            missing = sorted(union - keys)
            if missing:
                print('%s: %s/%s.lproj/%s is missing %d key(s): %s' % (
                    'warning' if legacy else 'error', folder, lang, table, len(missing),
                    ', '.join(missing[:10]) + (' ...' if len(missing) > 10 else '')))
                failures += 0 if legacy else 1
    failures += check_macros(root)
    checked = sum(len(langs) for langs in tables.values())
    print('%d table file(s) in %d table(s) checked, %d failure(s)' % (checked, len(tables), failures))
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
