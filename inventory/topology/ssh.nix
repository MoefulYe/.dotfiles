{ lib, ... }:
let
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
    "ubuntu@zju-zhang"
    "yu@zju-yu-sg"
    "zhao@zju-zhao"
  ];
  voids = [
    "ashenye@lap00-xiaoxin-mei"
    "root@rutr00-k2p-zhuque"
    "ashenye@rutr01-j4105-qingloong"
  ];
  dailies = [
    "ashenye@desk00-u265kf-lan"
    "ashenye@lap01-macm4-mume"
  ];
  vpses = [
    "ashenye@vps00-foxhk-citrus"
    "ashenye@vps01-hawk-lemon"
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
