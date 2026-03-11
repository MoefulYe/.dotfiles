inventory:
let
  mkCart = froms: tos: {
    inherit froms tos;
  };
  mkEdge = from: to: (mkCart [ from ] [ to ]);
  dailies = [
    "ashenye@mume"
    "ashenye@lan"
  ];
  vpses = inventory.users |> (user: builtins.elem "vps" user.tags);
  csts = inventory.users |> (user: builtins.elem "cst" user.tags);
  zjus = [ { sshConfig = ./zju.nix; } ];
in
[
  (mkEdge "ashenye@mume" "ashenye@lan")
  (mkCart dailies vpses)
  (mkCart dailies csts)
  (mkCart dailies zjus)
]
