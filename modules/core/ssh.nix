let
  module = # aspects/core/ssh.nix - OpenSSH configuration
{...}: {
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
};
in {
  flake.modules.nixos = {
    coreSsh = module;
    core = module;
  };
}
