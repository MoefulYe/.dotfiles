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
  (mkEdge "ashenye@desk00-u265kf-lan" "ashenye@lap00-xiaoxin-mei")
  (mkCartesianProduct [ "ashenye@desk00-u265kf-lan" ] [ "ubuntu@zju-zhang" "yu@zju-yu-sg" ])
]
