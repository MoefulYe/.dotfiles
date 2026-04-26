{
  pkgs,
  config,
  options,
  lib,
  specialArgs,
  ...
}:
let
  inherit (lib) types;

  fileModuleType = types.submoduleWith {
    inherit specialArgs;
    modules = lib.optionals (!config.isDocs) [
      ../../.
      "${builtins.toString config.flake.inputs.nixvim}/modules/top-level/files/submodule.nix"
      {
        _module.args = lib.pipe options._module.args [
          lib.modules.mergeAttrDefinitionsWithPrio
          (lib.flip removeAttrs [ "name" ])
          (lib.mapAttrs (_: { highestPrio, value }: lib.mkOverride highestPrio value))
        ];
      }
    ];
    description = "Nixvim configuration";
  };
in
{
  options = {
    files = lib.mkOption {
      type = types.attrsOf fileModuleType;
      description = "Extra files to add to the runtimepath";
      default = { };
      example = {
        "ftplugin/nix.lua" = {
          localOpts = {
            tabstop = 2;
            shiftwidth = 2;
            expandtab = true;
          };
        };
      };
    };

    build.extraFiles = lib.mkOption {
      type = types.package;
      description = "A derivation with all the files inside.";
      internal = true;
      readOnly = true;
    };
  };

  config =
    let
      extraFiles = lib.filter (file: file.enable) (lib.attrValues config.extraFiles);
      targets = lib.pipe extraFiles [
        (builtins.groupBy (entry: entry.target))
        (lib.mapAttrs (_: map (entry: "${entry.finalSource}")))
      ];
      prefixConflicts = lib.optionals (targets != { }) (
        let
          names = lib.attrNames targets;
          pairs = lib.zipLists names (lib.tail names);
        in
        lib.filter ({ fst, snd }: lib.hasPrefix "${fst}/" snd) pairs
      );

      concatFilesOption = attr: lib.flatten (lib.mapAttrsToList (_: builtins.getAttr attr) config.files);
    in
    {
      extraPlugins = concatFilesOption "extraPlugins";
      extraPackages = concatFilesOption "extraPackages";
      warnings = concatFilesOption "warnings";
      assertions =
        concatFilesOption "assertions"
        ++ lib.nixvim.mkAssertions "extraFiles" {
          assertion = prefixConflicts == [ ];
          message = ''
            Conflicting target prefixes:
            ${lib.concatMapStringsSep "\n" ({ fst, snd }: "  - ${fst} ↔ ${snd}") prefixConflicts}
          '';
        };

      extraFiles = lib.mkDerivedConfig options.files (
        lib.mapAttrs' (
          _: file: {
            name = file.path;
            value.source = file.plugin;
          }
        )
      );

      # nixpkgs' vim-utils now assumes plugins expose `pname`; upstream nixvim's
      # synthetic runtimepath package only sets `name`.
      build.extraFiles =
        pkgs.runCommandLocal "nvim-config"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ pkgs.jq ];
            pname = "nvim-config";
            version = "0";
            inherit targets;
            passthru.vimPlugin = true;
          }
          ''
            set -euo pipefail

            mkdir -p "$out"
            jq .targets "$NIX_ATTRS_JSON_FILE" > targets.json

            jq --raw-output 'keys[]' targets.json |
            while IFS= read -r target; do
              mapfile -t sources < <(
                jq --raw-output --arg target "$target" '.[$target][]' targets.json
              )

              if (( ''${#sources[@]} > 1 )); then
                base="''${sources[0]}"
                for src in "''${sources[@]:1}"; do
                  if [ "$src" != "$base" ] && ! diff -q "$base" "$src" >/dev/null
                  then
                    echo "error: target '$target' defined multiple times with different sources:" >&2
                    printf '  %s\n' "''${sources[@]}" >&2
                    exit 1
                  fi
                done
              fi

              dest="$out/$target"
              mkdir -p "$(dirname "$dest")"
              ln -s "''${sources[0]}" "$dest"
            done
          '';

      performance.combinePlugins.standalonePlugins = [ config.build.extraFiles ];
    };
}
