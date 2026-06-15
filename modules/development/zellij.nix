{
  flake.modules.nixos.developmentZellij = {...}: {
  programs.zellij.settings = {
    copy_command = "xclip -selection clipboard";
  };
};
}
