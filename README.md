# dotfiles

Minimal Neovim setup for Python / ROS 2: built-in LSP with basedpyright + ruff, no plugins.

```bash
git clone https://github.com/rogue1starwars/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

- Installs Neovim stable to `~/.local/opt`, basedpyright + ruff with `uv tool` (no sudo).
- Links `~/.config/nvim` -> `~/dotfiles/nvim` (existing config is backed up to `*.bak.<time>`).
- Installs `profile` as `~/.profile` only if none exists (fixes `.bashrc` not loading over SSH).
- Start `nvim` from a shell with ROS sourced so basedpyright can resolve `rclpy`.
- Update servers: `uv tool upgrade --all`. Update Neovim: re-run `install.sh`.
