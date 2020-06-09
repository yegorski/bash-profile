# For troubleshooting whether `./bash_profile` or `.bashrc` is being sourced by iTerm:
# https://superuser.com/questions/320065/bashrc-not-sourced-in-iterm-mac-os-x/320068
export BASH_CONF="~/.bash_profile"

export HISTSIZE=10000000
export HISTFILESIZE=10000000

# Paths
## Brew
export PATH="/usr/local/sbin:$PATH"

## Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

## Pyenv-virtualenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Git completion and adding branch to the command prompt
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi

# Git
alias gitvaccuum="git branch --merged | grep -Ev '(^\*|master)' | xargs git branch -d"
alias gb="git branch"
alias gc="git checkout"
alias gcm="git checkout master; git fetch; git pull"
alias gd="git diff"
alias gdc="git diff --cached"
alias gf="git fetch"
alias gl="git log"
alias glt="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gm="git merge"
alias gpo="git push origin"
alias grh="git reset --hard"
alias grhom="git reset --hard origin/master"
alias grm="git rebase master"
alias gs="git status"
alias gsl="git stash list"
alias gsp="git stash pop"
alias gss="git stash save"

# Navigation
alias e="exit"
alias h="history"
alias ll="ls -larth"

# Terraform
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfm="terraform fmt -diff -check"
alias tfw="terraform fmt -write"
alias twl="terraform workspace list"
alias tws="terraform workspace select"

# Functions
## Docker
docker-clear-logs() {
    local image="${1}"
    echo "" > $(docker inspect --format='{{.LogPath}}' $image)
}
docker-exec() {
    docker exec -it $1 /bin/bash
}
docker-get-image-id() {
    docker ps | xargs echo | cut -d " " -f 9
}
docker-run() {
    declare image="${1}" command="${2}"
    docker run -v $(pwd):/root_dir -w /root_dir -it --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --user root \
        ${image} ${command}
}
docker-run-with-port() {
    declare image="${1}" command="${2}" port="${3}"
    docker run -v $(pwd):/root_dir -w /root_dir -it --rm \
        -p ${port} \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ${image} ${command}
}

## Finder
check-size() {
    for dir in $(ls -larth . | awk -F ' ' '{ print $9 }'); do du -sh $dir; done
}
deletedirs() {
    local dirname="${1}"
    find . -name $dirname -type d -exec rm -r "{}" \;
}
deletefiles() {
    local files="${1}"
    find . -name $files -exec rm -r "{}" \;
}
findcontent() {
    local content="${1}"
    find . -type f -exec grep $content '{}' \; -print
}
finddirs() {
    local dirname="${1}"
    find . -name $dirname -type d;
}
findfiles() {
    find . -name "$1";
}
findfilecontent() {
    local file="${1}"
    local content="${2}"
    grep -rnw $file -e $content
}
replace-in-file() {
    local search=$1
    local replace=$2
    local file=$3
    sed -i "s/${search}/${replace}/g" ${file}
}

## Git
add-force-push() {  # adds all updated files and force-pushes with the same commit message
    git add .; git commit --amend; git push origin $(git rev-parse --abbrev-ref HEAD) --force
}
git-up() {  ## sets local branch to track upstream
    local branch="${1}"
    git branch --set-upstream-to=origin/$branch $branch
}

## Network
curl-with-cors() {  # sets a request with cross-origin request headers
    declare origin="${1}" url="{2:-http://localhost}"
    curl -i -X OPTIONS -H "Origin: ${origin}" \
        -H 'Access-Control-Request-Method: POST' \
        -H 'Access-Control-Request-Headers: Content-Type, Authorization' \
        "${url}"
}
flushdns() {
    dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
}
ssh-sudo () {  # SSH to the serve as root
    declare server="${1}"
    ssh -i ~/.ssh/id_rsa.tech-ops -t ec2-user@$server "sudo su -"
}
whosonport() {
    local port="${1}"
    sudo lsof -i tcp:$port
}

## Python
conda-create-env-and-source() {
    conda env create -f environment.yml
    source activate $(awk '$1 ~ /^name:/ {print $2}' environment.yml)
}
workon() {
    local python_env="${1}"
    source ~/envs/$python_env/bin/activate
}

## Utilities
custom-log() {
    log show --predicate "logType == default AND process like 'SophosAntiVirus'"
}
watch() {
    local cmd="${1}"
    while :; do clear; $cmd; sleep 1; done
}
