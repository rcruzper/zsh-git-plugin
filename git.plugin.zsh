# gcheckout - checkout local|remote branch
function gcheckout() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# gshow - commit browser
function gshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                  (grep -o '[a-f0-9]\{7\}' | head -1 |
                  xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                  {}
FZF-EOF"
}

# gcshow - get git commit sha
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

# fstash - easier way to deal with stashes
# # type fstash to get a list of your stashes
# # enter shows you the contents of the stash
# # ctrl-d shows a diff of the stash against your current HEAD
# # ctrl-b checks the stash out as a branch, for easier merging
function gstash() {
    local out q k sha
    while out=$(
        git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
        fzf --ansi --no-sort --query="$q" --print-query \
            --expect=ctrl-d,ctrl-b);
    do
        mapfile -t out <<< "$out"
        q="${out[0]}"
        k="${out[1]}"
        sha="${out[-1]}"
        sha="${sha%% *}"
        [[ -z "$sha" ]] && continue
        if [[ "$k" == 'ctrl-d' ]]; then
            git diff $sha
        elif [[ "$k" == 'ctrl-b' ]]; then
            git stash branch "stash-$sha" $sha
            break;
        else
            git stash show -p $sha
        fi
    done
}

