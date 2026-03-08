input: {
  hasTag = import ./hasTag.nix;
  mkHmConfigs = import ./mkHmConfigs.nix input;
  mkDarwinConfigs = import ./mkDarwinConfigs.nix input;
  mkNixosConfigs = import ./mkNixosConfigs.nix input;
  splitFullyQualifiedUsername = import ./splitFullyQualifiedUsername.nix;
}
