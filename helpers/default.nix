input: {
  hasTag = import ./hasTag.nix;
  mkHmConfigs = import ./mkHmConfigs.nix;
  mkDarwinConfigs = import ./mkDarwinConfigs.nix input;
  mkNixosConfigs = import ./mkNixosConfigs.nix input;
  splitFullyQualifiedUsername = import ./splitFullyQualifiedUsername.nix;
}
