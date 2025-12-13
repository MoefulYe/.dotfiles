inputs:
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
in
[
  (mkCartesianProduct dailies voids)
  (mkCartesianProduct dailies zjus)
  (mkCompleteGraph dailies)
]
