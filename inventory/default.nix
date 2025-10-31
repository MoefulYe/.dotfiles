{
  hosts = rec {
    # 外部的不受自己管理的主机
    external = import ./hosts/external;
    # 内部的受自己管理的nixos主机
    nixos = import ./hosts/nixos;
    # 内部的受自己管理的非nixos主机
    non-nixos = import ./hosts/non-nixos;
    all = external // nixos // non-nixos;
  };
  users = rec {
    # 外部用户，不受自己管理的用户
    external = import ./users/external;
    # 内部的使用home-manager管理的用户
    hm = import ./users/hm;
    # 内部的非home-manager管理的用户
    non-hm = import ./users/non-hm;
    all = external // hm // non-hm;
  };
}
