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
in
[
  (mkCartesianProduct [ "ashenye@desk00-u265kf-lan" "ashenye@lap01-macm4-mume" ] [ "ashenye@lap00-xiaoxin-mei" "root@rutr00-k2p-zhuque"  ])
  (mkCartesianProduct [ "ashenye@desk00-u265kf-lan" "ashenye@lap01-macm4-mume" ] [ "ubuntu@zju-zhang" "yu@zju-yu-sg" ])
  (mkCompleteGraph [ "ashenye@lap01-macm4-mume" "ashenye@desk00-u265kf-lan" ])
]
