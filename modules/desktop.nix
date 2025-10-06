{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "";
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}