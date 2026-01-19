{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    shattered-pixel-dungeon
    steam
    zeroad
  ];
}
