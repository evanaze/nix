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
      sshKeyPaths = ["/home/${username}/.ssh/id_ed25519"];
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = true;
    };
    secrets = {
      ts-server-key = {};
    };
  };
}
