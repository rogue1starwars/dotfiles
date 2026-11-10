#!/usr/bin/env bash
# Install Neovim + Python LSPs into ~/.local and link configs. No sudo needed.
set -euo pipefail
DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p ~/.local/bin ~/.local/opt ~/.config

# Back up anything already at $2 (unless it's already our link), then link $1 there.
link() {
  local src=$1 dst=$2
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"; echo "backed up $dst"
  fi
  ln -s "$src" "$dst"; echo "linked $dst -> $src"
}

# 1. Neovim (latest stable release)
case "$(uname -m)" in
  x86_64) pkg=nvim-linux-x86_64 ;;
  aarch64|arm64) pkg=nvim-linux-arm64 ;;
  *) echo "unsupported arch $(uname -m)"; exit 1 ;;
esac
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/nvim.tar.gz" "https://github.com/neovim/neovim/releases/download/stable/$pkg.tar.gz"
rm -rf ~/.local/opt/$pkg
tar -xzf "$tmp/nvim.tar.gz" -C ~/.local/opt
ln -sf ~/.local/opt/$pkg/bin/nvim ~/.local/bin/nvim
echo "installed $(~/.local/bin/nvim --version | head -1)"

# 1b. ripgrep (needed by Telescope live_grep; static binary)
rgv=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/BurntSushi/ripgrep/releases/latest | sed 's#.*/tag/##')
case "$(uname -m)" in
  x86_64) rgpkg=ripgrep-$rgv-x86_64-unknown-linux-musl ;;
  *) rgpkg=ripgrep-$rgv-aarch64-unknown-linux-gnu ;;
esac
curl -fsSL -o "$tmp/rg.tar.gz" "https://github.com/BurntSushi/ripgrep/releases/download/$rgv/$rgpkg.tar.gz"
rm -rf ~/.local/opt/$rgpkg
tar -xzf "$tmp/rg.tar.gz" -C ~/.local/opt
ln -sf ~/.local/opt/$rgpkg/rg ~/.local/bin/rg
echo "installed $(~/.local/bin/rg --version | head -1)"

# 2. Language servers: installed by Mason on first nvim start (needs python3 with venv).

# 3. Configs
link "$DOT/nvim" ~/.config/nvim
# ~/.profile: only install if missing (Ubuntu's default already sources .bashrc).
if [ ! -e ~/.profile ]; then link "$DOT/profile" ~/.profile; fi

echo "done. open a new shell (or: source ~/.profile) so ~/.local/bin is on PATH."
