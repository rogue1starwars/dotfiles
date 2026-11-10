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

# 1b'. fd (directory search for Telescope; respects .gitignore)
fdv=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/sharkdp/fd/releases/latest | sed 's#.*/tag/##')
case "$(uname -m)" in
  x86_64) fdpkg=fd-$fdv-x86_64-unknown-linux-musl ;;
  *) fdpkg=fd-$fdv-aarch64-unknown-linux-gnu ;;
esac
curl -fsSL -o "$tmp/fd.tar.gz" "https://github.com/sharkdp/fd/releases/download/$fdv/$fdpkg.tar.gz"
rm -rf ~/.local/opt/$fdpkg
tar -xzf "$tmp/fd.tar.gz" -C ~/.local/opt
ln -sf ~/.local/opt/$fdpkg/fd ~/.local/bin/fd
echo "installed $(~/.local/bin/fd --version)"

# 1c. Node.js LTS (Mason needs npm for yaml-language-server)
case "$(uname -m)" in x86_64) narch=x64 ;; *) narch=arm64 ;; esac
nodev=$(curl -fsSL https://nodejs.org/dist/index.json | python3 -c 'import json,sys; print(next(r["version"] for r in json.load(sys.stdin) if r["lts"]))')
nodepkg=node-$nodev-linux-$narch
curl -fsSL -o "$tmp/node.tar.gz" "https://nodejs.org/dist/$nodev/$nodepkg.tar.gz"
rm -rf ~/.local/opt/node-*-linux-$narch
tar -xzf "$tmp/node.tar.gz" -C ~/.local/opt
for b in node npm npx; do ln -sf ~/.local/opt/$nodepkg/bin/$b ~/.local/bin/$b; done
echo "installed node $(~/.local/bin/node --version)"

# 2. Language servers: installed by Mason on first nvim start
#    (basedpyright needs python3 with venv; yaml-language-server needs the npm above).

# 3. Configs
link "$DOT/nvim" ~/.config/nvim

echo "done. open a new shell (or: source ~/.profile) so ~/.local/bin is on PATH."
