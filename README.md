# Superfluous Returnz — Godot + Escoria demo

A recreation of the prologue of **[Superfluous Returnz](https://studios.ptilouk.net/superfluous-returnz/)**, the point & click adventure by **Gee** (Ptilouk.net Studios), made with [Godot](https://godotengine.org/) 4.7 and the [Escoria](https://github.com/godot-escoria/escoria-core) adventure framework.

## Goal

Show that a complete, commercial-quality adventure can be built with Godot + Escoria, staying as close as possible to the original game: same rooms, puzzles, texts, animations and interface. The original game runs on Gee's own engine, [Sosage](https://github.com/sgiraudot/sosage); here every room, item and script was rebuilt from the original game data.

## What the demo includes

- **The prologue, playable from start to end**
  - **Bureau** (Sophie's office): the painting, the safe and its code, the USB key, the trash bin, the GNU statue, the plant, the keyhole and the secret passage.
  - **Flu-G** (Superflu's lair): the car keys, the Flumobile, the bulb, the computer, the levers, the red button and the final dialog with Superflu.
- **Sosage-style interface**
  - Click an object to open the action selector (take, look, move, inventory), with labels per object and state.
  - An inventory for combining items, and code keypads.
  - The phone, which works as the main and pause menu, with settings and save/load.
  - Hints: call for help from the phone book.
- **Dialogs** with the original layout and fonts (Space skips a line), plus the dialog choices.
- **5 languages**: English, Spanish, French, German and Italian (choose in the phone's Settings).
- **Web export** preset (`export_presets.cfg`, output in `build/web`).

## Running it

1. Open the project with **Godot 4.7**.
2. Press F5.

The game's only addons are `escoria-core` and `escoria-dialog-simple`. The game's UI lives in `game/ui/`, and its custom ESC commands in `game/commands/`.

## Project layout

| Path | Contents |
|---|---|
| `game/rooms/` | `desk.tscn` (Bureau), `flug.tscn` (Flu-G), the intro and their `.ash` scripts |
| `game/items/` | Inventory items |
| `game/characters/` | Sophie and Superflu |
| `game/ui/` | Action selector, inventory, phone menu, dialog and chooser subclasses |
| `game/commands/` | Custom ESC commands (`show_code`, `show_window`, `crouch`, `action`, `shake`…) |
| `translations/` | `game.csv` (keys are the English texts) and the compiled translations |
| `tools/` | Python helpers: Flu-G room generation, navigation meshes, translation building |

After you add or change any visible text, rebuild the translations with `python3 tools/build_translations.py` and reimport the project.

## Credits

- **Superfluous Returnz**: story, art, music and texts by **Gee** — https://studios.ptilouk.net/superfluous-returnz/ (also on Steam and itch.io). Please support the original game.
- **Sosage**, the original engine: https://github.com/sgiraudot/sosage
- **Escoria**: https://github.com/godot-escoria
- First version of this demo by Julian Murgia (StraToN); port to Godot 4.7, interface, rooms, puzzles and translations by Joaquín Becerra.

## License

The original game's assets are distributed by Gee under **CC BY-SA 4.0**; see the game's [free software page](https://studios.ptilouk.net/superfluous-returnz/floss/). This derived work keeps that license and credits the author. Sosage and the code are MIT.

## Notes

- The data pack's `LICENSE.md` (dated 2023-12-13) still says "all rights reserved", while the FLOSS page says the assets are CC BY-SA since 2023-12-25. Check the current terms before you redistribute.
