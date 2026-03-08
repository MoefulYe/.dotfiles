{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  mkEdge = from: to: {
    type = "edge";
    inherit from to;
  };
  mkCartesianProduct = froms: tos: {
    type = "cert-prod";
    inherit froms tos;
  };
  mkCompleteGraph = nodes: {
    type = "complete-graph";
    inherit nodes;
  };
  mkEgo = nodes: {
    type = "ego";
    inherit nodes;
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
