{
  users,
  hosts,
  specialArgs,
  home-manager,
  nixpkgs,
  paths,
  ...
}:
users
|> builtins.mapAttrs (
  fullyQualifiedUserName:
  {
    mainModule,
    extraModules ? [ ],
    userInfo ? { },
  }:
  let
    lib = nixpkgs.lib;
    splitFullyQualifiedUsername = import ./splitFullyQualifiedUsername.nix;
    inherit (splitFullyQualifiedUsername { inherit lib fullyQualifiedUserName; }) username hostname;
    # 查询是否inventory中有对应的主机信息
    hostInfo = hosts."${hostname}".hostInfo or { };
  in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages."${hostInfo.system or "x86_64-linux"}";
    extraSpecialArgs = specialArgs // {
      inherit
        fullyQualifiedUserName
        username
        hostname
        ;
      # 主机信息的来源优先级: userInfo中定义的hostInfo字段 > inventory中的主机信息 > 自动生成的主机信息
      hostInfo = {
        inherit hostname;
      } // hostInfo // (userInfo.hostInfo or {});
      userInfo = {
        inherit username;
      } // userInfo;
    };
    modules = [
      {
        imports = extraModules ++ [ 
          "${paths.hmRoles}/${userInfo.role}"
          mainModule 
        ];
        home.username = username;
      }
    ];
  }
)
