# AGENTS.md

Nix flake for personal dotfiles. Uses **flake-parts** + **import-tree** with the
**dendritic pattern**: every file under `modules/` is auto-imported and each file
defines flake outputs instead of being a traditional NixOS/HM module.

## Layout

```
flake.nix              # inputs, systems, install apps. Keep thin.
modules/
  homeModules/         # flake.homeModules.<name>  (home-manager)
  nixosModules/        # flake.nixosModules.<name> (NixOS)
  hosts/               # flake.{nixos,darwin}Configurations + host modules
```

- `modules/**` is loaded wholesale by `import-tree`; there is no import list to
  maintain. Add a file, get an output.
- Multi-file modules use a directory with `default.nix` (e.g. `herdr/`, `lima/`,
  `neovim/`, `pi-coding-agent/`). Nested `*.nix` are still auto-imported, so keep
  data files (`.lua`, `.toml`, `.md`) out of Nix parsing or use `_`-prefixed dirs
  (`lima/_vms/`).
- `darwinModules` are declared inline in `modules/hosts/macbook.nix`, not a
  top-level directory.

## Conventions

- File shape:
  ```nix
  {...}: {
    flake.homeModules.foo = {pkgs, ...}: { ... };
  }
  ```
- Attribute names are camelCase (`zed-editor` -> `homeModules.zed-editor`).
- Hosts wire concrete configs by listing `self.homeModules.*` / `self.nixosModules.*`.
- Adding an app/tool = new `homeModules/<name>.nix` + add to the relevant host's
  `imports`. No registry file.
- Unfree allowed; stateVersions are pinned per host.

## Hosts / targets

| target    | system          | tool            |
|-----------|-----------------|-----------------|
| `macbook` | aarch64-darwin  | darwin-rebuild  |
| `desktop` | x86_64-linux    | home-manager    |
| `vm`      | x86_64-linux    | home-manager    |
| `xps-13`  | x86_64-linux    | nixos-rebuild   |

## Validating changes (agents)

**Never** `switch`, `nixos-rebuild`, `darwin-rebuild`, or `nix run .#<host>`.
Only the owner applies changes. Agents verify by evaluating/building, not activating.

```sh
nix-instantiate --parse modules/homeModules/foo.nix   # syntax-check one file
nix flake check --no-build                            # evaluate all outputs
nix eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix eval .#homeConfigurations.vm.activationPackage.drvPath
nix build .#darwinConfigurations.macbook.system --no-link   # build, do NOT switch
```

Cross-system (linux config on darwin) builds may need a remote builder; prefer
`nix eval` when a full build is unnecessary.

The install apps (`.#macbook`, `.#desktop`, `.#vm`, `default`) and the README
bootstrap commands are **owner-only** and must not be run by agents.

## Notes

- Repo is **jj-colocated** (`jj` for VCS, git backend).
- License/author identity lives in `modules/homeModules/git.nix`.
- `result` symlink and `.jj/`, `.git/` are not source.
