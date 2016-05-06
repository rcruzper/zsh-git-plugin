# Zsh Git Commands

## Installation
Add `zgen load rcruzper/zsh-git-plugin` to your .zshrc file.

## Commands

### gcheckout
It allows to checkout a branch from a list of branches (git branch --all).
If you add arguments to the command, then it will be executed as 'git checkout -b *args' and a new branch will be created.

### gshow
It shows the list of commits and performs a git show of the selected commit.

### grebase
It performs a git rebase branch from a list of branches (git branch --all).

### grebasei
It performs an interactive rebase selecting the base commit from the rebase that will be performed. (e.g. select fourth commit if you want to rebase the first three commits)

### gdelete
It shows a list of merged branches with the actual branch and allows to select one to delete.

### gcshow
Returns the SHA-1 of a commit from a list of commits.

### gpremotes
Creates local branches of all remote branches.

## Notes
If you want to get a zsh shell fully functional see my [dotfiles](https://github.com/rcruzper/dotfiles)

## TODO
- [x] ~~Commands description~~
- [ ] Add git fetch to gcheckout
