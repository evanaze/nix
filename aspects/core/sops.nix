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
      ts-server-key = {};
      admin-pass = {};
      syncthing-earth-key-pem = {};
      syncthing-earth-cert-pem = {};
      syncthing-mars-key-pem = {};
      syncthing-mars-cert-pem = {};
      syncthing-jupiter-key-pem = {};
      syncthing-jupiter-cert-pem = {};
    };
  };
}
