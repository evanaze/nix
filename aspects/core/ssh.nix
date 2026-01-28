# aspects/core/ssh.nix - OpenSSH configuration
{...}: {
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
}
