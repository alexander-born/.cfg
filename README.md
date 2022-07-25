## Installation
If you want to use neovim nightly:
```bash
sudo apt install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable
```
Install neovim and additional command line tools:
```bash
sudo apt install tmux stow neovim gnome-tweaks tree ripgrep peek xclip fd-find gnome-tweak-tool clang-format fzf npm git
```
Clone repository:
```bash
git clone git@github.com:alexander-born/.cfg.git ~/.cfg
```
Stow the wanted configurations like this:
```bash
stow nvim -d ~/.cfg -t ~
stow bash -d ~/.cfg -t ~
stow tmux -d ~/.cfg -t ~
```

## Neovim dependencies
### Python neovim library
```bash
pip install pynvim
```
### Patched fonts
Install a patched nerdfont from https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts and use it in your terminal to show symbols.

### Debug adapters
Use `:Mason` to install cpptools (C++) and debugpy (python)

## Additional steps for bash
Source all files in .bashrc with the following command:
```bash
grep -qxF 'for f in ~/.config/bash/*; do source $f; done' ~/.bashrc || echo 'for f in ~/.config/bash/*; do source $f; done' >> ~/.bashrc
```

## Addtional step for tmux
Install tmux plugin manager:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Open tmux and install plugins with `<Ctrl-a>I`.

## Add everforest colorscheme to gnome terminal
```bash
dconf load /org/gnome/terminal/legacy/profiles:/ < ~/.cfg/gnome-terminal-profiles.dconf
```
