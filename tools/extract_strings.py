#!/usr/bin/env python3
"""List every player-visible English string of the game (scripts, scenes,
UI code) and match it to Sosage's locale.yaml (en_US -> fr_FR, it_IT).
Usage: python3 tools/extract_strings.py > /tmp/strings.json"""
import glob, json, os, re, sys
import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOCALE = os.path.expanduser("~/www/jsadv/superfluous-returnz-original/extracted/data/locale.yaml")
strings = {}   # english -> first source


INTERNAL = {"Hinter", "name", "date", "saved", "day", "month", "year", "hour", "minute",
            "load", "settings", "controls", "quit", "phone", "save"}


def add(s, src):
    s = s.replace('\\"', '"')
    if s in INTERNAL:
        return
    if s.strip() and s not in strings:
        strings[s] = src


for f in glob.glob(ROOT + "/game/**/*.ash", recursive=True) + glob.glob(ROOT + "/game/**/*.esc", recursive=True):
    rel = os.path.relpath(f, ROOT)
    for line in open(f, encoding="utf-8"):
        for m in re.finditer(r'\bsay\((?:"[^"]+"|\$\w+), "((?:[^"\\]|\\.)*)"', line):
            add(m.group(1), rel)
        m = re.match(r'\s*- "((?:[^"\\]|\\.)*)"', line)
        if m:
            add(m.group(1), rel)
        for m in re.finditer(r'show_end_text\("((?:[^"\\]|\\.)*)"', line):
            add(m.group(1), rel)
for f in glob.glob(ROOT + "/game/**/*.tscn", recursive=True):
    rel = os.path.relpath(f, ROOT)
    for line in open(f, encoding="utf-8"):
        m = re.match(r'tooltip_name = "(.*)"', line)
        if m:
            add(m.group(1), rel)
        if line.startswith("metadata/verb_labels"):
            for v in re.findall(r':\s*"([^"]+)"', line):
                add(v, rel)
for f in ["game/ui/game.gd", "game/ui/phone/phone_menu.gd",
          "game/ui/inventory/inventory_ui.gd", "game/ui/inventory/inventory_ui.tscn"]:
    src = open(os.path.join(ROOT, f), encoding="utf-8").read()
    if not f.endswith("phone_menu.gd"):
        for m in re.finditer(r'tr\("((?:[^"\\]|\\.)*)"\)', src):
            add(m.group(1).replace("\\n", "\n"), f)
    if f.endswith("game.gd"):
        block = re.search(r"DEFAULT_LABELS = \{(.*?)\}", src, re.S).group(1)
        for v in re.findall(r':\s*"([^"]+)"', block):
            add(v, f)
    if f.endswith("phone_menu.gd"):
        for name in ["PHONE_BOOK", "TEXTS", "TEXT_SPEEDS"]:
            block = re.search(name + r" := ([\[\{].*?[\]\}])\n\n", src, re.S).group(1)
            if name == "TEXTS":
                vals = re.findall(r'": "((?:[^"\\]|\\.)*)"', block)
            elif name == "PHONE_BOOK":
                vals = re.findall(r'\["([^"]+)", "[\d.]+"', block)
            else:
                vals = re.findall(r'\["([a-z]+)"', block)
            for v in vals:
                add(v.replace("\\n", "\n"), f)
        # menu items, page titles, settings and save names
        for v in re.findall(r'\["[a-z_]+", "([^"]+)", "[a-z_]+"\]', src):
            add(v, f)
        for v in re.findall(r'_(?:title|show_text|confirm)\("([^"]+)"', src):
            add(v, f)
        for v in re.findall(r'\["(Full screen|Dialogue speed|Music volume|Sound effects volume|Language)"', src):
            add(v, f)
        for v in re.findall(r'return "(Office|Fluouscave)"', src):
            add(v, f)
        for v in ["yes", "no", "(Free slot)", "Language"]:
            add(v, f)

# Sosage locale: en_US -> other languages
loc = yaml.safe_load(open(LOCALE, encoding="utf-8"))["lines"]
norm = lambda s: s.replace(" ", " ").strip()
by_en = {}
for e in loc:
    if isinstance(e, dict) and e.get("en_US"):
        by_en.setdefault(norm(e["en_US"]), e)
by_en_lower = {k.lower(): v for k, v in by_en.items()}
out = []
for s, src in strings.items():
    e = by_en.get(norm(s.replace("\\n", "\n"))) or by_en_lower.get(norm(s).lower())
    out.append({"en": s, "src": src,
                "fr": e["fr_FR"].replace(" ", " ").rstrip("\n") if e else None,
                "it": e.get("it_IT", "").rstrip("\n") if e else None})
json.dump(out, sys.stdout, ensure_ascii=False, indent=1)
