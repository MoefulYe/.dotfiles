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
  zjus = [
    "ubuntu@zju-zhang"
    "yu@zju-yu-sg"
  ];
  voids = [
    "ashenye@lap00-xiaoxin-mei"
    "root@rutr00-k2p-zhuque"
  ];
  dailies = [
    "ashenye@desk00-u265kf-lan"
    "ashenye@lap01-macm4-mume"
  ];
  deployeeSshConfig =
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
    |> (import ../../infra/remote-builder/mkDeployeeSshConfig.nix);
  deployee = {
    sshConfig = deployeeSshConfig;
  };
in
[
  (mkCartesianProduct dailies voids)
  (mkCartesianProduct dailies zjus)
  (mkCompleteGraph dailies)
  (mkCartesianProduct dailies [ deployee ])
]
