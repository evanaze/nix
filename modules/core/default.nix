{
  flake.modules.nixos.core = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      busybox
      cachix
      cron
      devenv
      dig
      expect
      git
      htop
      lsof
      meslo-lgs-nf
      nmap
      nixos-anywhere
      tree
      unzip
      wget
    ];
  };
}
