#!/usr/bin/env bash
# Install svc: symlink the command into ~/.local/bin and the zsh completion into ~/.zfunc.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.local/bin" "$HOME/.zfunc"
chmod +x "$dir/svc"
ln -sfn "$dir/svc" "$HOME/.local/bin/svc"
ln -sfn "$dir/completions/_svc" "$HOME/.zfunc/_svc"
echo "Installed: $HOME/.local/bin/svc -> $dir/svc"
echo "Installed: $HOME/.zfunc/_svc -> $dir/completions/_svc"

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "Note: add ~/.local/bin to your PATH." ;;
esac

if [[ -f "$HOME/.zshrc" ]] && ! grep -q '\.zfunc' "$HOME/.zshrc"; then
    echo "Note: for tab completion, add this to ~/.zshrc before 'compinit':"
    echo '  fpath=("$HOME/.zfunc" $fpath)'
fi
echo "Open a new terminal (or run 'exec zsh'), then run: svc"
