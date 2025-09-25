function mkcd {
  mkdir -p "$1" && cd "$1" || exit
}

function ns {
  nix search nixpkgs $@
}

function nd {
  nix develop ${1:=.} -c $SHELL
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

export PATH=$PATH:~/.local/bin