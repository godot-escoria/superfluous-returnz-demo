#!/usr/bin/env python3
"""Generate the Flu-G room (game/rooms/flug.tscn + game/rooms/flug/*.ash)
from Sosage's data/rooms/flug.yaml and data/objects/*.yaml.

Sosage places every image by its bottom-center point ("coordinates"), runs
animations at 12 fps and sorts by z: small z (1-7) is background, 50000 is
foreground; z between back_z and front_z is converted to the y Escoria uses
for depth (z_index = y), read from flug_map.png.

Run from the project root: python3 tools/gen_flug.py
"""
import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMG = os.path.join(ROOT, "game/images")
FPS = 12.0
FRONT = 4000          # Sosage z 50000 (always in front)

# Walkable outline extracted from flug_map.png (non-blue pixels)
# Interaction points (Sosage "view") outside the walkable area were moved
# to the nearest walkable point: Escoria cancels actions it can't reach.
OUTLINE = [2879, 1080, 14, 1079, 184, 952, 414, 804, 452, 808, 506, 880, 556, 972,
           830, 944, 834, 940, 839, 896, 1064, 950, 1242, 970, 1446, 956, 1706, 880,
           1738, 842, 1999, 838, 2024, 895, 2066, 952, 2130, 1006, 2259, 1010, 2309, 974,
           2530, 976, 2554, 1006, 2687, 986, 2734, 928, 2736, 923, 2722, 856, 2676, 808,
           2879, 786]


def size(rel):
    return Image.open(os.path.join(IMG, rel)).size


# ---------------------------------------------------------------- resources
ext = {}       # path -> id
subs = []      # sub_resource texts


def tex(rel):
    path = "res://game/images/" + rel
    if path not in ext:
        ext[path] = "t%d" % (len(ext) + 1)
    return 'ExtResource("%s")' % ext[path]


def vec(x, y):
    return "Vector2(%g, %g)" % (x, y)


def poly(w, h):
    return "PackedVector2Array(%g, %g, %g, %g, %g, %g, %g, %g)" % (
        -w / 2, -h, w / 2, -h, w / 2, 0, -w / 2, 0)


def anim_resource(aid, name, length, loop, tracks):
    """tracks: list of (path, times, values) with discrete updates"""
    out = ['[sub_resource type="Animation" id="%s"]' % aid,
           'resource_name = "%s"' % name, "length = %g" % max(length, 0.001)]
    if loop:
        out.append("loop_mode = 1")
    for i, (path, times, values) in enumerate(tracks):
        out += ['tracks/%d/type = "value"' % i, "tracks/%d/imported = false" % i,
                "tracks/%d/enabled = true" % i, 'tracks/%d/path = NodePath("%s")' % (i, path),
                "tracks/%d/interp = 0" % i, "tracks/%d/loop_wrap = true" % i,
                "tracks/%d/keys = {" % i,
                '"times": PackedFloat32Array(%s),' % ", ".join("%g" % t for t in times),
                '"transitions": PackedFloat32Array(%s),' % ", ".join("1" for _ in times),
                '"update": 1,', '"values": [%s]' % ", ".join(values), "}"]
    subs.append("\n".join(out))
    return aid


def library(lid, anims):
    subs.append('[sub_resource type="AnimationLibrary" id="%s"]\n_data = {\n%s\n}' % (
        lid, ",\n".join('&"%s": SubResource("%s")' % (n, a) for n, a in anims)))
    return lid


def expand_frames(frames):
    out = []
    for f in frames:
        f = str(f)
        if "x" in f:
            n, idx = f.split("x")
            out += [int(idx)] * int(n)
        else:
            out.append(int(f))
    return out


# ---------------------------------------------------------------- nodes
# Each object is a group of nodes (the Area2D and its children). Groups are
# written sorted by z: Escoria resolves clicks in _unhandled_input, which
# Godot delivers in reverse tree order, so the object drawn on top must also
# come last in the tree (hover uses z_index, clicks use tree order).
groups = []      # [z, [node texts]]


class _Nodes:
    def append(self, text):
        groups[-1][1].append(text)


nodes = _Nodes()


def esc_item(nid, x, y, z, gid, props, parent="items"):
    groups.append([z, []])
    lines = ['[node name="%s" type="Area2D" parent="%s"]' % (nid, parent),
             "process_mode = 1"]
    if z:
        lines.append("z_index = %d" % z)
    lines += ["position = %s" % vec(x, y), 'script = ExtResource("esc_item")',
              'global_id = "%s"' % gid] + props
    nodes.append("\n".join(lines))


def sprite(parent, texture, w, h, hframes=1, vframes=1, visible=True):
    lines = ['[node name="Sprite2D" type="Sprite2D" parent="%s"]' % parent]
    if not visible:
        lines.append("visible = false")
    lines += ["texture = %s" % texture, "centered = false",
              "offset = %s" % vec(-w / 2, -h)]
    if hframes > 1:
        lines.append("hframes = %d" % hframes)
    if vframes > 1:
        lines.append("vframes = %d" % vframes)
    nodes.append("\n".join(lines))


def anim_player(parent, lib):
    nodes.append('[node name="AnimationPlayer" type="AnimationPlayer" parent="%s"]\n'
                 'libraries = {\n&"": SubResource("%s")\n}' % (parent, lib))


def collision(parent, w, h):
    nodes.append('[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="%s"]\n'
                 "polygon = %s" % (parent, poly(w, h)))


def interaction(parent, x, y, view):
    nodes.append('[node name="ESCInteractionLocation" type="Marker2D" parent="%s"]\n'
                 "position = %s\nscript = ExtResource(\"interaction\")" % (
                     parent, vec(view[0] - x, view[1] - y)))


def gd_value(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, dict):
        return "{%s}" % ", ".join('"%s": %s' % (k, gd_value(val)) for k, val in v.items())
    return '"%s"' % v


# ---------------------------------------------------------------- objects
def obj(gid, tooltip, x, y, z, image, view, states=None, init=None, labels=None,
        labels_by_state=None, inventory=None, exit_dir=None, coll=None, script=True):
    """Interactive object. states: {name: dict(image=, x=, y=, frames=, loop=, hidden=)}"""
    w, h = size("objects/" + image) if image else coll
    props = ['tooltip_name = "%s"' % tooltip]
    # Escoria turns the player to interaction_angle on arrival; 0 makes Sophie
    # face left, 180 right. Sosage's "look: []" faces the object.
    if view and not exit_dir and x > view[0]:
        props.append("interaction_angle = 180")
    if script:
        props.append('esc_script = "res://game/rooms/flug/%s.ash"' % gid)
    if exit_dir:
        props.append("is_exit = true")
    props.append("combine_when_selected_action_is_in = PackedStringArray()")
    if inventory:
        t = tex("inventory/" + inventory)
        props += ["inventory_texture = %s" % t, "inventory_texture_hovered = %s" % t]
    if labels:
        props.append("metadata/verb_labels = %s" % gd_value(labels))
    if labels_by_state:
        props.append("metadata/verb_labels_by_state = %s" % gd_value(labels_by_state))
    if exit_dir:
        props.append('metadata/goto = "%s"' % exit_dir)
    esc_item(gid, x, y, z, gid, props)
    p = "items/" + gid
    if image:
        sprite(p, tex("objects/" + image), w, h)
    if states:
        anims = []
        for sname, st in states.items():
            simg = st.get("image", image)
            sw, sh = size("objects/" + simg)
            hf = st.get("hframes", 1)
            fw = sw / hf
            sx, sy = st.get("x", x), st.get("y", y)
            frames = st.get("frames", [0])
            dt = st.get("duration", 1) / FPS
            tracks = [(".:position", [0], [vec(sx, sy)]),
                      ("Sprite2D:texture", [0], [tex("objects/" + simg)]),
                      ("Sprite2D:hframes", [0], [str(hf)]),
                      ("Sprite2D:offset", [0], [vec(-fw / 2, -sh)]),
                      ("Sprite2D:frame", [i * dt for i in range(len(frames))], [str(f) for f in frames]),
                      ("Sprite2D:visible", [0], ["false" if st.get("hidden") else "true"]),
                      ("CollisionPolygon2D:polygon", [0], [poly(fw, sh)])]
            anims.append((sname, anim_resource("A_%s_%s" % (gid, sname), sname,
                                               len(frames) * dt, st.get("loop", False), tracks)))
        anim_player(p, library("L_" + gid, anims))
    collision(p, w / (states[init].get("hframes", 1) if states and init else 1), h)
    if view:
        interaction(p, x, y, view)


def scenery(gid, x, y, z, folder, states, init):
    """Non-interactive object whose image changes with its state."""
    props = ["is_interactive = false", "combine_when_selected_action_is_in = PackedStringArray()"]
    esc_item(gid, x, y, z, gid, props)
    p = "items/" + gid
    first = states[init]
    w, h = size(folder + "/" + first["image"])
    sprite(p, tex(folder + "/" + first["image"]), w, h, visible=not first.get("hidden"))
    anims = []
    for sname, st in states.items():
        sw, sh = size(folder + "/" + st.get("image", first["image"]))
        tracks = [(".:position", [0], [vec(st.get("x", x), st.get("y", y))]),
                  ("Sprite2D:texture", [0], [tex(folder + "/" + st.get("image", first["image"]))]),
                  ("Sprite2D:offset", [0], [vec(-sw / 2, -sh)]),
                  ("Sprite2D:visible", [0], ["false" if st.get("hidden") else "true"])]
        anims.append((sname, anim_resource("A_%s_%s" % (gid, sname), sname, 0, False, tracks)))
    anim_player(p, library("L_" + gid, anims))


def animation(gid, image, cols, rows, x, y, z, loop=False, frames=None, duration=1):
    """Sosage room animation: hidden until played, hidden again when it ends."""
    W, H = size("animations/" + image)
    fw, fh = W / cols, H / rows
    props = ["is_interactive = false", "combine_when_selected_action_is_in = PackedStringArray()"]
    esc_item(gid, x, y, z, gid, props)
    p = "items/" + gid
    sprite(p, tex("animations/" + image), fw, fh, cols, rows, visible=False)
    seq = expand_frames(frames) if frames else list(range(cols * rows))
    dt = duration / FPS
    length = len(seq) * dt
    times = [i * dt for i in range(len(seq))]
    vis_t, vis_v = ([0], ["true"]) if loop else ([0, length], ["true", "false"])
    play = anim_resource("A_%s_play" % gid, "play", length, loop,
                         [("Sprite2D:frame", times, [str(f) for f in seq]),
                          ("Sprite2D:visible", vis_t, vis_v)])
    stop = anim_resource("A_%s_stop" % gid, "stop", 0, False,
                         [("Sprite2D:visible", [0], ["false"])])
    anim_player(p, library("L_" + gid, [("play", play), ("stop", stop)]))


# Interactive objects (data/objects/*.yaml) --------------------------------
obj("hallway", "Hallway", 187, 840, 1, "couloir_flug.png", (250, 914), exit_dir="left")
obj("door", "Door", 321, 849, 2, "porte_flug_ouverte.png", (369, 890),
    states={"open": {"image": "porte_flug_ouverte.png"},
            "closed": {"image": "porte_flug_fermee.png", "x": 192, "y": 949}},
    init="open", labels_by_state={"open": {"move": "Close"}, "closed": {"move": "Open"}})
obj("car_keys", "Fluousmobile keys", 190, 586, 3, "clef_flumobile.png", (370, 890),
    inventory="clef_flumobile.png", labels={"combine": "Point at"})
obj("computer", "Computer", 651, 734, 4, "ecran_ordinateur_flug_erreur.png", (442, 910),
    states={"error": {"image": "ecran_ordinateur_flug_erreur.png"},
            "off": {"image": "ecran_ordinateur_flug_eteint.png"},
            "on": {"image": "ecran_ordinateur_flug_allume.png", "hframes": 2,
                   "frames": [0, 1], "duration": 7, "loop": True},
            "broken": {"image": "ecran_ordinateur_flug_casse.png"}},
    init="error", labels_by_state={"error": {"move": "Turn off"}, "off": {"move": "Turn on"},
                                   "on": {"move": "Use"}})
obj("red_button", "Red button", 620, 775, 4, "bouton_rouge.png", (442, 910), labels={"move": "Push"})
obj("socket", "Socket", 447, 542, 1, "douille.png", (359, 873), labels={"move": "Tamper"})
obj("bulb", "Light bulb", 2506, 789, 869, "ampoule.png", (2700, 976), inventory="ampoule.png",
    labels={"use": "Shatter", "combine": "Insert into"})
obj("car", "Fluousmobile", 2354, 1003, 868, "flumobile_fermee.png", (2614, 1001),
    states={"locked": {"image": "flumobile_fermee.png"}, "closed": {"image": "flumobile_fermee.png"},
            "open": {"image": "flumobile_ouverte.png"}},
    init="locked", labels={"take": "Drive"},
    labels_by_state={"locked": {"move": "Open"}, "closed": {"move": "Open"}, "open": {"move": "Close"}})
obj("suit_o_matic", "Suit-o-Matic", 1261, 938, 3, "costumomatic.png", (1059, 953), labels={"move": "Open"})
LEVERS = {"lever1": ((1617, 625), (1580, 633), "right"), "lever2": ((1635, 663), (1600, 672), "right"),
          "lever3": ((1664, 748), (1626, 757), "left"), "lever4": ((1672, 791), (1641, 798), "right")}
for gid, ((rx, ry), (lx, ly), init) in LEVERS.items():
    x, y = (rx, ry) if init == "right" else (lx, ly)
    obj(gid, "Lever", x, y, 7, "levier.png", (1715, 888),
        states={"right": {"x": rx, "y": ry}, "left": {"x": lx, "y": ly}}, init=init,
        labels_by_state={"right": {"move": "Push"}, "left": {"move": "Pull"}})
obj("notches", "Notches", 1611, 788, 6, "encoches.png", (1715, 888), labels={"move": "Pull"})
obj("poker_placed", "Poker", 1662, 695, 7, "tisonnier_pose.png", (1715, 888),
    states={"right": {"x": 1662, "y": 695}, "left": {"x": 1627, "y": 704}}, init="right",
    labels_by_state={"right": {"move": "Push"}, "left": {"move": "Pull"}})
obj("cable", "Wire", 1728, 782, FRONT, "cable.png", (1891, 942), labels={"move": "Pull"})
obj("superflu_target", "Superfluous", 1266, 875, 4, None, (978, 947), coll=(246, 394),
    labels={"move": "Talk", "take": "Push"})

# Scenery with states (flug.yaml "scenery") ---------------------------------
scenery("computer_frame", 633, 953, 3, "scenery", {"default": {"image": "ordinateur_flug.png"}}, "default")
scenery("suit_front", 1249, 948, 5, "scenery", {"default": {"image": "avant_costumomatic.png"}}, "default")
scenery("suit_lamp", 1267, 245, 6, "scenery",
        {"off": {"image": "lampe_costumomatic_eteinte.png"}, "on": {"image": "lampe_costumomatic_allumee.png"},
         "broken": {"image": "lampe_costumomatic_cassee.png"}}, "off")
scenery("suit_door", 1261, 898, 6, "scenery",
        {"closed": {"image": "porte_costumomatic_fermee.png"},
         "open": {"image": "porte_costumomatic_ouverte.png", "x": 991, "y": 896},
         "none": {"image": "porte_costumomatic_fermee.png", "hidden": True}}, "closed")

# Animations (flug.yaml "animations") ---------------------------------------
HANGING = [4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5]
HANGING_B = [13, 12, 11, 10, 9, 10, 11, 12, 13, 14, 15, 16, 17, 16, 15, 14]
animation("anim_cable", "cable.png", 5, 4, 1602, 782, FRONT)
animation("anim_boum1", "boum1.png", 4, 3, 652, 701, 5)
animation("anim_boum2", "boum1.png", 4, 3, 1269, 275, 7)
animation("anim_button", "bouton_costumomatic.png", 2, 1, 1253, 441, 6, loop=True, duration=10)
animation("anim_flash1", "eclair1.png", 6, 2, 633, 559, 2)
animation("anim_flash2", "eclair2.png", 8, 1, 468, 493, 2)
animation("anim_flash3", "eclair3.png", 1, 9, 879, 253, 2)
animation("anim_flash4", "eclair4.png", 7, 1, 1064, 462, 6)
animation("anim_flash5", "eclair5.png", 2, 2, 1098, 1018, 2,
          frames=[0, 1, 2, 3, 0, 3, 2, 1, 2, 3, 0, 1, 2, 1, 0, 3, 0, 1, 2, 3])
animation("anim_suit_door", "ouverture_porte.png", 5, 2, 1096, 929, FRONT)
animation("anim_sophie_shock", "sophie_electrisee.png", 2, 2, 1938, 1014, 950,
          frames=[0, 1, 0, 3, 0, 2, 0, 1, 0, 3, 0, 2])
animation("anim_superflu_fall1", "superflu_chute1.png", 4, 1, 1248, 914, 4)
animation("anim_superflu_fall2", "superflu_chute2.png", 6, 3, 1266, 1036, 7,
          frames=list(range(11)) + ["37x11"] + list(range(12, 18)))
animation("anim_superflu_hanging", "superflu_suspendu.png", 9, 2, 1231, 917, 4, loop=True,
          frames=HANGING * 2 + HANGING_B + HANGING * 2 + HANGING_B * 3 + HANGING + HANGING_B * 2 + HANGING)
animation("anim_superflu_stuck", "superflu_chute2.png", 6, 3, 1266, 1036, 7, loop=True, frames=[0])

# ---------------------------------------------------------------- scene
head_ext = [
    '[ext_resource type="Script" path="res://addons/escoria-core/game/core-scripts/esc_room.gd" id="room"]',
    '[ext_resource type="Script" path="res://addons/escoria-core/game/core-scripts/esc_background.gd" id="background"]',
    '[ext_resource type="Script" path="res://addons/escoria-core/game/core-scripts/esc_terrain.gd" id="terrain"]',
    '[ext_resource type="Script" path="res://addons/escoria-core/game/core-scripts/esc_item.gd" id="esc_item"]',
    '[ext_resource type="Script" path="res://addons/escoria-core/game/core-scripts/esc_interaction_location.gd" id="interaction"]',
    '[ext_resource type="Script" path="res://addons/escoria-core/game/core-scripts/esc_location.gd" id="location"]',
    '[ext_resource type="PackedScene" path="res://game/characters/sophie.tscn" id="sophie"]',
    '[ext_resource type="PackedScene" path="res://game/characters/superflu.tscn" id="superflu"]',
    '[ext_resource type="Texture2D" path="res://game/images/backgrounds/flug.png" id="bg"]',
    '[ext_resource type="Texture2D" path="res://game/images/backgrounds/flug_scale.png" id="map"]',
]
head_ext += ['[ext_resource type="Texture2D" path="%s" id="%s"]' % (p, i) for p, i in ext.items()]
nav = ('[sub_resource type="NavigationPolygon" id="nav"]\n'
       "outlines = Array[PackedVector2Array]([PackedVector2Array(%s)])\nagent_radius = 0.0"
       % ", ".join(str(v) for v in OUTLINE))
room_nodes = [
    '[node name="flug" type="Node2D"]\nscript = ExtResource("room")\nglobal_id = "room_flug"\n'
    'esc_script = "res://game/rooms/flug/flug.ash"\nplayer_scene = ExtResource("sophie")',
    '[node name="ESCBackground" type="TextureRect" parent="."]\noffset_right = 2880.0\n'
    'offset_bottom = 1080.0\nmouse_filter = 2\ntexture = ExtResource("bg")\nscript = ExtResource("background")',
    '[node name="ESCTerrain" type="Node2D" parent="."]\nscript = ExtResource("terrain")\n'
    'scales = ExtResource("map")\nscale_min = 1.0\nscale_max = 0.8\nplayer_speed_multiplier = 1.5',
    '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="ESCTerrain"]\n'
    'navigation_polygon = SubResource("nav")',
    '[node name="items" type="Node2D" parent="."]',
]
end_nodes = [
    # Sosage superflu.yaml coordinates; hidden until he falls out of the Suit-o-Matic
    '[node name="superflu" parent="." instance=ExtResource("superflu")]\nvisible = false\n'
    "position = Vector2(1249, 978)",
    # entree_porte: Sophie arrives at (260, 930)
    '[node name="entry_door" type="Marker2D" parent="."]\nposition = Vector2(260, 930)\n'
    'script = ExtResource("location")\nglobal_id = "entry_door"\nis_start_location = true',
]
nsub = len(subs) + 1
text = ['[gd_scene load_steps=%d format=3]' % (len(head_ext) + nsub + 1), ""]
ordered = [n for _, g in sorted(groups, key=lambda g: g[0]) for n in g]
text += head_ext + [""] + subs + [nav, ""] + room_nodes + ordered + end_nodes
with open(os.path.join(ROOT, "game/rooms/flug.tscn"), "w") as f:
    f.write("\n\n".join(text).replace("\n\n\n", "\n\n") + "\n")
print("flug.tscn: %d textures, %d sub-resources, %d nodes" % (len(ext), len(subs), len(ordered)))
