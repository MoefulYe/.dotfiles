{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  mkCartesianProduct = froms: tos: {
    type = "cert-prod";
    inherit froms tos;
  };
  zjus = [
    "ubuntu@zhang.zju"
    "yu@yu-sg.zju"
    "zzm@zzm.zju"
  ];
  voids = [
    "root@zhuque"
    "ashenye@qingloong"
  ];
  dailies = [
    "ashenye@lan"
    "ashenye@mume"
  ];
  vpses = [
    "ashenye@citrus"
    "ashenye@lemon"
    "ashenye@yuzu"
  ];
  deployeeSshConfig =
    (
      (
        [
          "lan"
          "mei"
          "mume"
        ]
        |> (lib.map (name: {
          hostname = name;
          domain = "${name}.void";
          port = 2222;
        }))
      )
      ++ [
        {
          hostname = "citrus";
          domain = "45.192.104.103";
          port = 2222;
        }
        {
          hostname = "lemon";
          domain = "198.252.98.154";
          port = 2222;
        }
      ]
    )
    |> (import ../../infra/remote-deploy/mkDeployeeSshConfig.nix);
  deployee = {
    sshConfig = deployeeSshConfig;
  };
in
[
  (mkCartesianProduct dailies voids)
  (mkCartesianProduct dailies zjus)
  (mkCartesianProduct dailies vpses)
  (mkCompleteGraph dailies)
  (mkCartesianProduct dailies [ deployee ])
  (mkEgo dailies)
]
