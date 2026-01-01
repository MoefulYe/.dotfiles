{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./fine-tuning.nix    
    ./networking.nix 
  ];
}
