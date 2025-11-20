## 主机清单
### 分类
分为三类主机:
 - 完全受自己管理的且用nixos管理环境的主机
 - 完全受自己管理的但不使用nixos管理环境的主机
 - 不受自己管理的主机, 但自己有访问权限的主机
### nix主机信息的结构
```nix
nix-host = {
    hostname = "主机名"; # nix-host 是主机的唯一标识符，与主机名解耦, 当hostname不存在时候使用nix-host作为主机名
    address = "111.111.111.111"; # 主机的ip地址或域名， 可以用一个字符串或者用一个属性集表示多个地址
    # address = {
    #    ip1 = ...;
    #    ip2 = ...;
    # }
    # 只有完全受自己管理的且用nixos管理环境的主机才需要下面的nixosConfig属性
    nixosConfig = {
        main = /path/to/nixos/configuration.nix; # nixos配置文件路径
        extras = [ /path/to/extra/config1.nix /path/to/extra/config2.nix ]; # 额外的nixos配置文件路径列表
    };
    # 主机的系统架构, 默认为"x86_64-linux"
    system = "x86_64-linux"; 
    # "cat" 表示日常使用的带桌面主机
    # "dog" 表示日常使用的无头主机
    # "fox" 表示不受自己管理的主机
    # "cow" 表示无人值守的服务器主机
    # "bee" 表示集群节点主机
    # "zoo" 表示角色不明的主机
    # 如果系统是nixos管理的配置，会默认对应的role的配置
    role = "主机角色";
    description = "主机描述信息"; # 主机的描述信息可选
    priUser = "username"; # 主要用户名可选
    # 还可以添加其他自定义属性
};
```
连接主机的sshconfig配置不应该写入主机清单中，因为sshconfig是链接到一个用户的

## 用户清单
### 分类
- 受自己管理的home-manager管理环境的用户
- 受自己管理但不使用home-manager管理环境的用户
- 不受自己管理但有访问权限的用户
### home-manager用户信息的结构
```nix
hm-user@hostname = {
    username = "用户名"; # hm-user@hostname 是用户的唯一标识符，与用户名解耦, 当username不存在时候使用hm-user作为用户名
    hostname = "主机名"; # 用户所在主机的主机名
    description = "用户描述信息"; # 用户的描述信息可选
    tags = [ "tag1" "tag2" ]; # 用户标签列表可选
    ssh-conn-config = /path/to/ssh/config/file.nix; # 用户连接主机的sshconfig文件路径可选
    ssh-conn-config = {
        config1 = /path/to/ssh/config/file1.nix;
        config2 = /path/to/ssh/config/file2.nix;
        .... 
    };
    # 只有受自己管理的home-manager管理环境的用户才需要下面的homeManagerConfig属性
    hmConfig = {
        main = /path/to/home-manager/configuration.nix; # home-manager配置文件路径
        extras = [ /path/to/extra/config1.nix /path/to/extra/config2.nix ]; # 额外的home-manager配置文件路径列表
    };
    ...; # 还可以添加其他自定义属性
    ssh-pub-key =  ....
};
```
