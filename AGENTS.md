# Agent Notes

Read before running Nix commands.

This file should only be updated sparingly in the case of genuine project-scoped gotchas, quirks, and general best practices as you discover them. Additions must be concise, technical English — one line per point where possible; extend existing entries rather than duplicating, and keep session-specific detail out. Only record durable repo conventions, structure, or setup — not changelog-style notes about individual changes or current implementation details; update or remove an entry when it changes instead of appending to it.

## Environment

- `/` is tmpfs (`rootfs`, `size=6124744k`, ~5.8 GiB). `/nix/store` is an overlayfs on the same tmpfs, so store paths built/downloaded consume RAM.
- RAM ~11 GiB; swap ~5.8 GiB zram (also RAM).
- Large `nix build`/`nix eval` fills tmpfs, exhausts RAM/zram, and is OOM-killed (exit `137`; empty `nix eval --raw` output). Can destabilise the session.

## Rules

1. Pre-check `df -h /` (<80%) and `free -h`. If tight, `nix store gc` first.
2. Avoid full-system build/eval unless required, memory free, one at a time:
   - `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
   - `nix build .#nixosConfigurations.<host>.config.home-manager.users.<user>.home.activationPackage` (entire HM closure)
   - `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath` (full closure eval; can OOM alone)
   - `nix flake check`
   Use `--dry-run` to preview the closure.
3. Prefer leaf evals:
   - `nix eval .#nixosConfigurations.<host>.config.home-manager.users.<user>.assertions` (look for `"assertion":false`)
   - `nix eval .#nixosConfigurations.<host>.config.home-manager.users.<user>.<option>`
   - e.g. `...users.<user>.services.restic.backups.daily.paths`
   - Standard users to check: `terra/reilly`, `terra/guest`, `slate/reilly`, `mist/dev` (0 failing assertions).
   - Flakes ignore untracked files: after adding or moving files use `path:.#...` (or stage them).
   - Options carrying removed-option shims (impermanence `home.persistence.main.{directories,files}`) error when serialised; inspect with `--apply 'xs: map (x: x.directory) xs'` or rely on assertions.
4. Real builds: `<hostname>-build [test|switch|boot] [light|dark]` (`test` default, self-escalates via sudo, theme defaults by time of day). Also `<hostname>-update`, `<hostname>-clean`; `<hostname>-theme` and theme specialisations exist only when `mynixos.theme.schedule` is set (dark = base system, light = specialisation).
5. Docs are generated from option metadata: regenerate after changing option names/descriptions/defaults with `nix build .#docs && cp -rf result/* ./docs/ && rm -f result` (use `path:.#docs` while new files are untracked). Never hand-edit `docs/`.
6. Reclaim after heavy work: `nix store gc` (safe; frees ~20 GiB via overlay/hardlinks). Re-check `df -h /`, `free -h`.
7. No concurrent heavy Nix commands.

## Module edits

- Co-locate `options` with the config they describe (repo convention; `modules/home-manager/options/` no longer exists).
- A module declaring `options` must put its config under an explicit `config = { ... }`, otherwise: "Module ... has an unsupported attribute `home'...".
- Format touched files with `nixfmt`; the repo is nixfmt-formatted, so unrelated lines should not change.

## Symptoms

- `nix eval` exit `137` / empty `--raw` output -> OOM. `nix store gc`, retry lighter.
- `/` >=95% -> store filled RAM. `nix store gc`.
- Long "copying path ... from cache.nixos.org" streaks -> materialising a large closure.
- `nix eval …config.assertions --json` fails with `attribute 'cycle' missing` on any host: upstream nixpkgs message-string artifact, not a real filesystem cycle. Check with `--apply 'filter (a: !a.assertion)'`.

## Lint

- `nix run nixpkgs#statix check` (optional single TARGET; first run may build statix from source — allow several minutes).
- `nixfmt <files>` for formatting.
