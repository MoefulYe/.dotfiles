let
  mkEdge = from: to: { inherit from to; };
  mkCartesianProduct =
    froms: tos: (builtins.concatMap (from: builtins.map (to: mkEdge from to) tos) froms);
  mkCompleteGraph = nodes: mkCartesianProduct nodes nodes;
in
# 允许笔记本通过SSH访问台式机
[ (mkEdge "ashenye@lap00-xiaoxin-mei" "ashenye@desk00-u265kf-lan") ]
# 允许自己的主机访问浙江大学的两台服务器
++ (mkCartesianProduct
  [ "ashenye@desk00-u265kf-lan" "ashenye@lap00-xiaoxin-mei" ]
  [ "ubuntu@zju-zhang" "yu@zju-yu-sg" ]
)
