{
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      FastConnectable = true;
      MultiProfile = "multiple";
    };
  };

  services.pipewire.wireplumber.extraConfig."10-xm5-bluetooth" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.auto-connect" = [
        "a2dp_sink"
        "hfp_hf"
      ];
      "bluez5.a2dp.ldac.quality" = "auto";
    };
  };
}
