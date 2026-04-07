{
  services.swaync = {
    enable = true;
    # https://github.com/ErikReider/SwayNotificationCenter/blob/main/src/configSchema.json
    # see gist.github.com/JannisPetschenka/fb00eec3efea9c7fff8c38a01ce5d507
    settings = {
      # Keep notifications visible but avoid overlay-level focus behavior.
      layer = "top";
      "control-center-layer" = "top";

      # Disable keyboard-interactive features to reduce focus stealing.
      "keyboard-shortcuts" = false;
      "notification-inline-replies" = false;
      "notification-2fa-action" = false;
      "layer-shell-cover-screen" = false;
    };

  };
}
