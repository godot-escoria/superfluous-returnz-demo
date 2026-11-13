#!/usr/bin/env python3
"""Build translations/game.csv (keys = English text; en, es, fr, de, it).
fr and it come from Sosage's locale.yaml (the game's own translations), es
and de from tools/translations_es_de.py. Lists missing entries.
Usage: python3 tools/build_translations.py"""
import csv, json, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from translations_es_de import TR

# Strings written for this port (no exact match in Sosage's locale.yaml)
MANUAL_FR_IT = {
    "Hint Hotline": ("Service des indices", "Servizio di indizi"),
    "Harpagon Lonion": ("Harpagon Lonion", "Harpagon Lonion"),
    "Exit the game?\n": ("Quitter le jeu ?\n", "Uscire dal gioco?\n"),
    "ESCAPE:\n  - while playing, access the menu\n\nRIGHT CLICK/SPACE:\n  - skip a line of dialogue\n":
        ("ÉCHAP :\n  - pendant le jeu, accéder au menu\n\nCLIC DROIT/ESPACE :\n  - passer une ligne de dialogue\n",
         "ESC:\n  - mentre stai giocando, accedere al\n  menu\n\nTASTO DESTRO/SPAZIO:\n  - saltare una linea di dialogo\n"),
}

strings = json.loads(subprocess.run([sys.executable, os.path.join(ROOT, "tools/extract_strings.py")],
                                    capture_output=True, text=True, check=True).stdout)
rows, missing = [], []
for s in strings:
    en = s["en"]
    fr, it = MANUAL_FR_IT.get(en, (s["fr"], s["it"]))
    # Sosage stores object names in lowercase and capitalizes them on screen
    cap = lambda v: v[:1].upper() + v[1:] if v and en[:1].isupper() and v[:1].islower() else v
    fr, it = cap(fr), cap(it)
    es, de = TR.get(en) or TR.get(en.replace("\xa0", " "), (None, None))
    for lang, v in (("fr", fr), ("it", it), ("es", es), ("de", de)):
        if not v:
            missing.append((lang, en))
    rows.append([en, en, es or en, fr or en, de or en, it or en])

os.makedirs(os.path.join(ROOT, "translations"), exist_ok=True)
with open(os.path.join(ROOT, "translations/game.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["keys", "en", "es", "fr", "de", "it"])
    w.writerows(rows)
print("translations/game.csv: %d strings" % len(rows))
for lang, en in missing:
    print("MISSING %s: %r" % (lang, en[:80]))
