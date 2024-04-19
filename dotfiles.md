## DOTFILES

`dotfiles` is a submodule managed by `chezmoi.io`

To update and reflect the last changes in `dotfiles` repository use: 

```bash
git submodule update --init --force --remote
```

_Don't know yet I need to force the update._


# Update submodules
git submodule update --remote --merge

# Fetch the latest changes from the submodule’s origin and rebase them
git submodule update --remote --rebase