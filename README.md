# dotfiles

## Fresh install

```bash
curl -fsSL https://raw.githubusercontent.com/datsfain/dotfiles/main/bootstrap.sh | bash
```

## After changing KDE settings

```bash
cd ~/dotfiles
git add -A
git commit -m "Update config"
git push
```

## First time setup (existing machine)

```bash
./backup.sh
cd ~/dotfiles
stow --adopt kde
git add -A
git commit -m "Initial config"
git push
```
