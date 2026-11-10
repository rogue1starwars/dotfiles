# dotfiles

Minimal Neovim setup for Python / ROS 2: built-in LSP + completion, Mason for the
language servers (basedpyright, ruff, yaml-language-server), Telescope for search.

```bash
git clone https://github.com/rogue1starwars/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

- Installs Neovim stable, ripgrep and Node.js LTS to `~/.local` (no sudo).
  `~/.local/bin` must be on `PATH` (Ubuntu's default `~/.profile` adds it).
- Links `~/.config/nvim` -> `~/dotfiles/nvim` (existing config is backed up to `*.bak.<time>`).
- Plugins (vim.pack) and language servers (Mason) install on the first `nvim` start;
  restart nvim once Mason finishes. basedpyright needs `python3` with `venv`
  (`sudo apt install python3-venv` on plain Ubuntu).
- Start `nvim` from a shell with ROS sourced so basedpyright can resolve `rclpy`.
- Update: `:lua vim.pack.update()` for plugins, `:Mason` for servers, re-run `install.sh` for Neovim.
