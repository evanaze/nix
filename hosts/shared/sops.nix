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
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  };
}
