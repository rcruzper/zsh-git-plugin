# gcheckout - checkout local|remote branch
function gcheckout() {
    if [[ -n $1 ]] then
        git checkout -b "$@"
    else
        local branches branch
        branches=$(git branch --all | grep -v HEAD) &&
        branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    fi
}

# gshow - commit browser
function gshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --select-1 --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                  (grep -o '[a-f0-9]\{7\}' | head -1 |
                  xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                  {}
FZF-EOF"
}

# gfix - git commit -a --fixup
function gfix() {
    local commits commitId
    commits=$(git log --oneline --decorate)
    while read -r commit; do
        if [[ $commit != *fixup\!* ]]; then
            commitId=$(echo $commit | awk '{print $1;}')
            git commit -a --fixup $commitId
            break
        fi
    done <<< "$commits"
}

# grauto - git rebase -i --autosquash 
function grauto() {
    local commits
    commits=$(git log --oneline --decorate)
    local counter=0
    while read -r commit; do
        if [[ $commit == *fixup\!* ]]; then
            counter=$((counter+1))
        else
            GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~$((counter+1))
            break
        fi
    done <<< "$commits"
}

# gcshow - get git commit SHA-1
function gcshow() {
    local commits commit
    commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
    commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
    echo -n $(echo "$commit" | sed "s/ .*//")
}

# gcheckout - checkout local|remote branch
function grebase() {
    local branches branch
    branches=$(git branch -r | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git fetch $(echo "$branch" | sed "s/.* //" | cut -d "/" -f 1) $(echo "$branch" | sed "s/.* //" | cut -d "/" -f 2-15) &&
    git rebase FETCH_HEAD
}

# grebase - interactive rebase
alias grebasei='git rebase -i `gcshow`'

# gdelete - branch -d of merged branches
function gdelete() {
    local branches branch
    branches=$(git branch --merge) &&
        branch=$(echo "$branches" | fzf-tmux -d 15 +s +m) &&
        git branch -d $(echo "$branch" | sed "s/.* //")
}

# gpremotes - creates local branches of all remote branches
function gpremotes(){
    for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v $(git rev-parse --abbrev-ref HEAD) `; do
        git branch --track ${branch#remotes/origin/} $branch
    done
}