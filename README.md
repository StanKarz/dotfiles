# Dotfiles

My personal dotfiles for macOS, managed as symlinks from `~/dotfiles` into `$HOME`.

## What's in here

| File              | Symlinked to                | Purpose                                        |
| ----------------- | --------------------------- | ---------------------------------------------- |
| `.zshrc`        | `~/.zshrc`                | Zsh config: Oh My Zsh, plugins, history, tools |
| `.gitconfig`    | `~/.gitconfig`            | Git user, aliases, credential helper           |
| `.tmux.conf`    | `~/.tmux.conf`            | tmux key bindings, plugins, status bar         |
| `.vimrc`        | `~/.vimrc`                | Vim: syntax, indentation, search, clipboard    |
| `starship.toml` | `~/.config/starship.toml` | Starship prompt theming                        |
| `install.sh`    | —                          | Symlink installer (see below)                  |

## Quick start (new machine)

```bash
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install all required tools
brew install git zsh tmux starship zoxide broot fzf nvm uv eza
$(brew --prefix)/opt/fzf/install   # sets up fzf keybindings (interactive — answer y to all three prompts)

# 3. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 4. Install Oh My Zsh custom plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 5. Install Tmux Plugin Manager (TPM)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 6. Clone this repo and run installer
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh

# 7. Open a new shell, then start tmux and install plugins
tmux
# Inside tmux, press: Ctrl+B then I (capital i) to install plugins
```

You'll also want a **Nerd Font** for the starship prompt icons to render correctly. Install one with:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Then set it as your terminal font in Ghostty (`~/.config/ghostty/config`):

```
font-family = JetBrainsMono Nerd Font
```

## What `install.sh` does

The script is safe to re-run. It:

1. Verifies `~/dotfiles` exists, exits early if not.
2. Creates `~/.config/` if missing (where `starship.toml` lives).
3. For each target file (`.zshrc`, `.gitconfig`, etc.), if a **real file** exists there (not already a symlink), it's moved aside to `<file>.backup.<timestamp>` so nothing is silently overwritten.
4. Creates symlinks pointing each target to the corresponding file in `~/dotfiles`.

This means any edits made in `~/dotfiles/.zshrc` are immediately reflected in `~/.zshrc`, and you can keep the dotfiles repo under version control as the single source of truth.

## Git credentials & multiple GitHub accounts

`.gitconfig` uses macOS's keychain for credentials:

```gitconfig
[credential]
    helper = osxkeychain
```

For a single account, that's all you need — the first time you push, macOS prompts for your credentials and stores them in the Keychain.

### Multiple GitHub accounts (recommended approach: SSH)

The HTTPS + osxkeychain combo gets awkward with multiple accounts because credentials are keyed by hostname (both accounts look like `github.com`). The clean solution is **SSH keys with host aliases**.

**1. Generate a key per account:**

```bash
ssh-keygen -t ed25519 -C "you@personal.com" -f ~/.ssh/id_ed25519_personal
ssh-keygen -t ed25519 -C "you@work.com"     -f ~/.ssh/id_ed25519_work
```

**2. Add each public key to the corresponding GitHub account** (Settings → SSH and GPG keys):

```bash
pbcopy < ~/.ssh/id_ed25519_personal.pub  # then paste into personal account
pbcopy < ~/.ssh/id_ed25519_work.pub      # then paste into work account
```

**3. Configure `~/.ssh/config`:**

```ssh-config
# Personal
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

**4. Clone using the alias instead of `github.com`:**

```bash
git clone git@github.com-personal:StanKarz/some-repo.git
git clone git@github.com-work:my-org/work-repo.git
```

**5. Set the right identity per repo** (since `.gitconfig` has one global `user.email`):

```bash
cd ~/path/to/work-repo
git config user.email "you@work.com"
git config user.name "Stan (Work)"
```

Or use conditional includes in `~/.gitconfig` to auto-switch based on directory — see `git config --help` under `includeIf`.

## Useful Git commands

### Custom aliases (defined in `.gitconfig`)

| Alias                  | Expands to                                 | What it does                                     |
| ---------------------- | ------------------------------------------ | ------------------------------------------------ |
| `git graph`          | `log --all --graph --decorate --oneline` | Pretty branch graph of all branches              |
| `git last`           | `log -1 HEAD --stat`                     | Show last commit with files changed              |
| `git unstage <file>` | `reset HEAD -- <file>`                   | Move a file from staging back to working dir     |
| `git amend`          | `commit --amend --no-edit`               | Add staged changes to the last commit (keep msg) |
| `git undo`           | `reset --soft HEAD~1`                    | Undo the last commit but keep the changes staged |

`git undo` is the safe "oh wait, I committed too early" — your changes stay in the index, just rewind the commit. `git amend` is great for "I committed and then noticed a typo in one file" — `git add` the fix, then `git amend`.

### Oh My Zsh `git` plugin aliases

The `git` plugin (already enabled in `.zshrc`) ships ~150 aliases. Most-used ones:

| Alias     | Command                                  |
| --------- | ---------------------------------------- |
| `gst`   | `git status`                           |
| `ga`    | `git add`                              |
| `gaa`   | `git add --all`                        |
| `gc`    | `git commit -v`                        |
| `gcmsg` | `git commit -m`                        |
| `gco`   | `git checkout`                         |
| `gcb`   | `git checkout -b`                      |
| `gp`    | `git push`                             |
| `gl`    | `git pull`                             |
| `gd`    | `git diff`                             |
| `gds`   | `git diff --staged`                    |
| `gb`    | `git branch`                           |
| `glog`  | `git log --oneline --decorate --graph` |
| `gsta`  | `git stash push`                       |
| `gstp`  | `git stash pop`                        |

Full reference: [https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)

### Other useful workflows

| Command                             | What it does                                                  |
| ----------------------------------- | ------------------------------------------------------------- |
| `lt`                              | `eza -T --icons` — directory tree view with file icons     |
| `ciaclean`                        | Delete all local branches already merged into `origin/main` |
| `git config user.email "x@y.com"` | Set per-repo email (override global)                          |

### Other useful keystrokes:

| Keys              | Action                                                                       |
| ----------------- | ---------------------------------------------------------------------------- |
| `Ctrl+R`        | fzf fuzzy history search (start typing, see matches, Enter to run)           |
| `Ctrl+T`        | fzf file picker — drops a fuzzy-matched filename into the current command   |
| `Alt+C`         | fzf directory picker —`cd`s into a fuzzy-matched directory                |
| `Ctrl+W`        | Delete previous word (great for "I accidentally accepted a long suggestion") |
| `Ctrl+U`        | Wipe the entire current line silently                                        |
| `Ctrl+C`        | Cancel the current line, new prompt                                          |
| `Ctrl+_`        | Undo                                                                         |
| `Up` / `Down` | Cycle through full history (replaces whole line)                             |
| `Shift+Tab`     | Cycle backwards through completion menu                                      |

## tmux quick reference

Default prefix is `Ctrl+B`. After pressing prefix, release before pressing the next key.

| Keybind                         | Action                                |
| ------------------------------- | ------------------------------------- |
| `prefix + \|`                  | Split pane vertically (left/right)   |
| `prefix + -`                  | Split pane horizontally (top/bottom)  |
| `Ctrl+Shift+arrow`            | Move between panes (no prefix needed) |
| `prefix + c`                  | New window                            |
| `prefix + ,`                  | Rename current window                 |
| `prefix + n` / `prefix + p` | Next / previous window                |
| `prefix + 1`, `2`, …       | Jump to window N                      |
| `prefix + x`                  | Kill current pane                     |
| `prefix + d`                  | Detach session (leaves it running)    |
| `prefix + I`                  | Install TPM plugins                   |
| `prefix + Ctrl-s`             | Save session (tmux-resurrect)         |
| `prefix + Ctrl-r`             | Restore session (tmux-resurrect)      |

From outside tmux:

| Command                       | Action                         |
| ----------------------------- | ------------------------------ |
| `tmux`                      | Start a new unnamed session    |
| `tmux new -s work`          | Start a named session          |
| `tmux ls`                   | List all sessions              |
| `tmux attach -t work`       | Attach to session "work"       |
| `tmux kill-session -t work` | Delete session "work"          |
| `tmux kill-server`          | Nuke everything (all sessions) |

### Copy/paste inside tmux

`set -g mouse on` is enabled, which means click-drag selects in tmux's buffer — `Cmd+C` won't work the way you expect. Two ways to copy:

- **Plain drag** → tmux-yank + OSC 52 (`set -g set-clipboard on`) auto-copy the selection to the macOS clipboard. Then `Cmd+V` to paste anywhere.
- **Shift+drag** → bypasses tmux entirely; you get a normal Ghostty terminal selection. `Cmd+C` to copy. (Shift is hardcoded in Ghostty as the bypass modifier.)

For keyboard-only copy, use copy mode: `prefix + [` to enter, navigate with arrow/vim keys, `Space` to start selection, `Enter` to copy.

## Troubleshooting

**`git config --get credential.helper` returns the wrong value**

Check where the setting is coming from:

```bash
git config --list --show-origin | grep credential
```

If the override is in `~/.gitconfig`, verify the symlink AND the file content at the other end:

```bash
ls -la ~/.gitconfig                   # confirm symlink target
grep -A1 credential ~/.gitconfig      # confirm file content matches what you expect
```

A common gotcha: editing the new dotfile but forgetting to actually replace the file in `~/dotfiles/`. The symlink is fine; it's the source file that's stale.

**Tab completion doesn't accept the grey suggestion**

It's not supposed to. Tab does filesystem/command completion; the grey text is autosuggestions. Use Right arrow for the suggestion, Tab for completion. See the Shell shortcuts table above.

**Another useful reference guide for shell tricks & tips**: https://blog.hofstede.it/shell-tricks-that-actually-make-life-easier-and-save-your-sanity/

## Updating

```bash
cd ~/dotfiles
git pull
# Re-run the installer if file paths/symlinks changed:
./install.sh
# Reload zsh:
source ~/.zshrc
# Reload tmux config (from inside tmux):
tmux source-file ~/.tmux.conf
```
