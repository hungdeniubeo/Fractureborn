# Contributing to Fractureborn

Thanks for taking an interest in Fractureborn.

The project is still in early development, so contributions should stay focused on the existing vertical slice rather than introducing large new systems without discussion.

## Development branch

Active gameplay development currently lives on:

```text
feat/vertical-slice
```

Use that branch as the reference for the current project structure, gameplay systems, and validation flow.

## Before making a change

For bug fixes, small polish changes, documentation, or isolated improvements, keep the change focused and describe what problem it solves.

For larger gameplay systems, map expansions, architecture changes, new races, multiplayer/co-op, or major asset replacements, open an issue first so the scope can be discussed before implementation.

## Local setup

Requirements:

- Godot 4.7.x
- Git

```bash
git clone https://github.com/hungdeniubeo/Fractureborn.git
cd Fractureborn
git switch feat/vertical-slice
```

Open `project.godot` in Godot and let the project import before running it.

## Validation

When a change affects gameplay or core systems, run the relevant checks before opening a pull request:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_logic_tests.gd
godot --headless --path . --script tests/run_playable_flow.gd
godot --headless --path . --script tests/run_playable_flow.gd -- reopen
```

For performance-sensitive work, also use the existing performance profile:

```bash
godot --path . --profiling --script tests/run_performance_profile.gd -- windowed
```

Manual playtesting is still important for combat feel, animation, visual feedback, UI layout, and controller behavior.

## Contribution guidelines

- Keep pull requests focused on one clear purpose.
- Follow the existing Godot scene and GDScript structure.
- Avoid unrelated refactors inside feature or bug-fix changes.
- Do not commit generated Godot cache/import data.
- Do not add copyrighted game assets or assets without clear usage rights.
- Keep gameplay behavior independent from placeholder sprite dimensions where possible.
- Update documentation when behavior, controls, setup, or validation steps change.
- Include reproduction steps for bug fixes when applicable.

## Assets

The project currently contains placeholder and in-progress art. Asset additions should have clear ownership or usage rights.

Existing art handoff requirements are documented in `docs/ASSET_REQUESTS.md`.

## Pull requests

A useful pull request description should include:

- What changed.
- Why the change was needed.
- How it was tested.
- Any known limitations or follow-up work.
- Screenshots or short recordings when the change is visual.

## License

The repository currently has no explicit open-source license. Opening the source publicly does not grant permission to redistribute or reuse the project's source code or assets outside the rights provided by GitHub's platform terms.
