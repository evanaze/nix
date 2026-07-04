{
  flake.modules.nixos.core = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      busybox
      cachix
      cron
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
