function mkcd {
  mkdir -p "$1" && cd "$1" || exit
}

function ns {
  nix search nixpkgs $@
}

function nd {
  nix develop ${1:=.}
}

function nsh {
  local args=()
  for arg in $@; do
  args+=("nixpkgs#$arg");
  done
  nix shell ${args[@]};
}

function nr {
  nix run nixpkgs#$@
}

function np {
  nix build --print-out-paths --no-link nixpkgs#$1
}

# nbu <format> <drivation>
# <format> ::= arx | rpm | deb | dockerimage | appimage
function nbu {
  local format="$1"
  local derivation="$2"
  if [ -z "$format" ]; then
    echo "Error: <format> is required"
    echo "Usage: nbu <format> <derivation>"
    return 1
  fi
  if [ -z "$derivation" ]; then
    echo "Error: <derivation> is required"
    echo "Usage: nbu <format> <derivation>"
    return 1
  fi
  local bundler=""
  case "$format" in
    arx) bundler="github:Nixos/bundlers#toArx";;
    rpm) bundler="github:Nixos/bundlers#toRPM";;
    deb) bundler="github:Nixos/bundlers#toDEB";;
    dockerimage) bundler="github:Nixos/bundlers#toDockerImage";;
    appimage) bundler="github:ralismark/nix-appimage";;
    *) echo "Unknown format: $format"; return 1;;
  esac
  nix bundle --bundler "$bundler" "$derivation"
}

function append_path {
  for dir in "$@"; do
    if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
      export PATH="$PATH:$dir"
    fi
  done
}

function cwt {
  mkdir -p .codex/worktrees
  git worktree add .codex/worktrees/$1 -b $1
}

function xs {
  if [[ $# -lt 1 ]]; then
    echo "Usage: pssh proxy-ip:proxy-port [ssh args...]"
    return 1
  fi
  local proxy="$1"
  shift
  ssh -o "ProxyCommand=nc -x ${proxy} %h %p" "$@"
}

function kxs {
  if [[ $# -lt 1 ]]; then
    echo "Usage: pssh proxy-ip:proxy-port [ssh args...]"
    return 1
  fi
  local proxy="$1"
  shift
  kitten ssh -o "ProxyCommand=nc -x ${proxy} %h %p" "$@"
}

function up {
  local d=""
  local limit=${1:-1}
  for ((i=0; i<limit; i++)); do
    d+="../"
  done
  cd "$d"
}

function wttr {
  curl -s "wttr.in/${CITY:-ningbo}?m2&lang=zh-cn" | bat -p
}

function pj_new {
  mkdir ~/repo/$1 && cd ~/repo/$1
}

function iv {
  fd --type=file | fzf --multi --preview 'bat --color=always --style=numbers --line-range=:100 {}' | xargs vim
}
