#!/usr/bin/env python3
"""Check localization tables (docs/localization.md).

For every `<lang>.lproj/<Table>.strings` under ChatKit/ and ChatKit-OC/Example/:
- the file must parse as a strings file (`"key" = "value";` entries and comments), and
- every language of the same table in the same folder must have the same key set, and every key must have the same
  format specifiers (`%@`, `%1$@`, `%d`, ...) in every language.

It also checks the layer-macro acceptance criterion (AGENTS.md, "Internationalization and localization"): core
(ChatKit/, vendored code excluded) and the example (ChatKit-OC/Example/) each define at least one localization macro,
the two layers use different macro names, each macro names a bundle of its own layer, and no macro reads a bundle that
belongs to the other layer.

It also checks that every key passed to a layer's macro as a string literal exists in that layer's table (a typo would
silently show the raw key).

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


SPECIFIER = re.compile(r'%(?:\d+\$)?[-+ 0#]*\d*(?:\.\d+)?(?:hh|h|ll|l|q|L|z|t|j)?[@diouxXeEfFgGaAcCsSp]')


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
    keys, pairs, pos = [], {}, 0
    while pos < len(text):
        m = COMMENT.match(text, pos) or ENTRY.match(text, pos)
        if m:
            if m.re is ENTRY:
                keys.append(m.group(1))
                pairs[m.group(1)] = m.group(2)
            pos = m.end()
        elif text[pos:].strip() == '':
            break
        else:
            line = text.count('\n', 0, pos) + 1
            raise ValueError('syntax error near line %d' % line)
    return keys, pairs


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


def macro_call_keys(text, macro):
    """Yields the string literal of the first argument of each `macro(...)` call in text, found with a small parser."""
    for m in re.finditer(r'\b%s\(' % re.escape(macro), text):
        depth, i, first, in_string = 1, m.end(), [], False
        while i < len(text) and depth > 0:
            c = text[i]
            if in_string:
                if c == '\\':
                    first.append(text[i:i + 2]); i += 2; continue
                if c == '"':
                    in_string = False
            elif c == '"':
                in_string = True
            elif c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    break
            elif c == ',' and depth == 1:
                break
            first.append(c)
            i += 1
        argument = ''.join(first)
        for literal in STRING_LITERAL.findall(argument):
            yield literal


def check_used_keys(root, base, macros, skip, tables):
    """Every literal key passed to a macro of this layer must exist in the table that the macro reads."""
    failures = 0
    defined = {}
    for (folder, table), langs in tables.items():
        if folder.replace(os.sep, '/').startswith(base.replace(os.sep, '/')):
            defined.setdefault(table, set()).update(*(keys for keys, _ in langs.values()))
    for name, literals in macros.items():
        table = next((l + '.strings' for l in literals if (l + '.strings') in defined), None)
        if not table:
            continue
        missing = {}
        for dirpath, dirnames, filenames in os.walk(os.path.join(root, base)):
            dirnames[:] = [d for d in dirnames if d != 'Pods' and not d.endswith('.bundle')]
            if any(part in dirpath.replace(os.sep, '/').split('/') for part in skip):
                continue
            for filename in filenames:
                if not filename.endswith(('.m', '.mm', '.h')):
                    continue
                path = os.path.join(dirpath, filename)
                text = open(path, encoding='utf-8', errors='replace').read()
                for key in macro_call_keys(text, name):
                    if key not in defined[table]:
                        missing.setdefault(key, set()).add(os.path.relpath(path, root))
        for key, paths in sorted(missing.items()):
            print('error: %s(@"%s") is not a key of %s (%s)' % (name, key, table, ', '.join(sorted(paths))))
            failures += 1
    return failures


def check_macros(root, tables):
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
    failures += check_used_keys(root, 'ChatKit', core, {'Vendor'}, tables)
    failures += check_used_keys(root, os.path.join('ChatKit-OC', 'Example'), example, set(), tables)
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
                    keys, pairs = parse(path)
                except ValueError as error:
                    print('error: %s: %s' % (rel, error))
                    failures += 1
                    continue
                dupes = sorted(k for k, n in collections.Counter(keys).items() if n > 1)
                if dupes:
                    print('warning: %s: duplicate keys %s' % (rel, ', '.join(dupes)))
                folder = os.path.relpath(os.path.dirname(dirpath), root)
                tables[(folder, name)][os.path.basename(dirpath)[:-len('.lproj')]] = (set(keys), pairs)
    for (folder, table), langs in sorted(tables.items()):
        if len(langs) < 2:
            continue
        union = set().union(*(keys for keys, _ in langs.values()))
        legacy = (folder.replace(os.sep, '/'), table) in LEGACY
        # Format specifiers: every language of a key must use the same ones, in any order.
        if not legacy:
            for key in sorted(union):
                found = {lang: sorted(SPECIFIER.findall(pairs[key])) for lang, (_, pairs) in langs.items() if key in pairs}
                if len({tuple(v) for v in found.values()}) > 1:
                    print('error: %s/%s: key "%s" has different format specifiers: %s' % (
                        folder, table, key, '; '.join('%s: %s' % (l, ' '.join(v) or '-') for l, v in sorted(found.items()))))
                    failures += 1
        for lang, (keys, _) in sorted(langs.items()):
            missing = sorted(union - keys)
            if missing:
                print('%s: %s/%s.lproj/%s is missing %d key(s): %s' % (
                    'warning' if legacy else 'error', folder, lang, table, len(missing),
                    ', '.join(missing[:10]) + (' ...' if len(missing) > 10 else '')))
                failures += 0 if legacy else 1
    failures += check_macros(root, tables)
    checked = sum(len(langs) for langs in tables.values())
    print('%d table file(s) in %d table(s) checked, %d failure(s)' % (checked, len(tables), failures))
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
