#sgmeeser@name的完全限定用户名拆分为用户名与主机名
{ fullyQualifiedUserName, lib }:
let
  parts =  lib.splitString "@" fullyQualifiedUserName;
  username = builtins.elemAt parts 0;
  hostname = builtins.elemAt parts 1;
in
{
  inherit username hostname;
}
