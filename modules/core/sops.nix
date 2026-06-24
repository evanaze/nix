let
  module =
    # aspects/core/sops.nix - Secrets management with sops-nix
    {
      pkgs,
      username,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        age
        sops
        ssh-to-age
      ];

      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age = {
          sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
          keyFile = "/home/${username}/.config/sops/age/keys.txt";
          generateKey = true;
        };
        secrets = {
          openrouter-api-key = {
            owner = username;
          };
          admin-pass = {};
          grafana = {};
          actual = {};
          "nut/ups-passwd" = {};
        };
      };
    };
in {
  flake.modules.nixos = {
    coreSops = module;
    core = module;
    coreRpi = module;
  };
}
