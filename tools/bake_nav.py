#!/usr/bin/env python3
"""Bake a room's navigation polygon from its outline (agent radius 0) and
write vertices/polygons back into the .tscn.
Usage: python3 tools/bake_nav.py game/rooms/flug.tscn"""
import os, re, subprocess, sys
GODOT = os.path.expanduser("~/apps/godot/Godot_v4.7.2-stable_linux.x86_64")
scene = sys.argv[1]
out = subprocess.run([GODOT, "--headless", "--path", ".", "-s", "res://tools/bake_nav.gd", "--",
                      "res://" + scene], capture_output=True, text=True, timeout=180).stdout
lines = out.splitlines()
verts = next(l[6:] for l in lines if l.startswith("VERTS "))
polys = [l[5:] for l in lines if l.startswith("POLY ")]
s = open(scene).read()
i = s.index('[sub_resource type="NavigationPolygon"')
j = s.find("\n\n", i)
blk = s[i:j]
blk = re.sub(r"\nvertices = PackedVector2Array\([^)]*\)", "", blk)
blk = re.sub(r"\npolygons = Array\[PackedInt32Array\]\(\[.*?\]\)", "", blk, flags=re.S)
head, rest = blk.split("\n", 1)
blk = "%s\nvertices = PackedVector2Array(%s)\npolygons = Array[PackedInt32Array]([%s])\n%s" % (
    head, verts.replace(",", ", "),
    ", ".join("PackedInt32Array(%s)" % p.replace(",", ", ") for p in polys), rest)
open(scene, "w").write(s[:i] + blk + s[j:])
print("%s: %d vertices, %d polygons" % (scene, verts.count(",") // 2 + 1, len(polys)))
