{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  };
}
