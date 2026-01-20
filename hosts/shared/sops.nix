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
    defaultSopsFile = ../../secrets.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
