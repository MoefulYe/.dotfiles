self-used nix configuration
## thanks
nixvim https://github.com/dc-tec/nixvim
wen https://github.com/wenjinnn/.dotfiles
##
zju-connect
nftables improve
 - [ ] alloc user for mihomo
 - [ ] ...

那么你的方案总结下来就是这个仓库本身不存放密钥根（agekey，sshkey，硬盘锁），密钥根仍然每个主机分开保存，外围的敏感信息采用sops脱敏后直接在仓库内进行管理，密钥对应的公钥明文保存在仓库，同时提供系列的部署脚本统一生成密钥简化部署步骤
