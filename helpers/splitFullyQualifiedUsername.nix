#sgmeeser@name的完全限定用户名拆分为用户名与主机名
fqun:
let
  parts = builtins.split "@" fqun;
  username = builtins.head parts;
  hostname = builtins.elemAt parts 1;
in
{
  inherit username hostname;
}
