{
  pkgs,
  username,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      zsh-fast-syntax-highlighting
      zsh-powerlevel10k
    ];
  };

  home-manager.users.${username} = {
    home.file.".p10k.zsh".source = ./p10k.zsh;

    programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        history.size = 10000;
        initExtra = ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

          function epush() {
              branch=$(git rev-parse --abbrev-ref HEAD)
              ticket=$(echo $branch | cut -d / -f2 -)
              git add .
              git commit -m "$ticket $*"
              git pull
              git push
          }
        '';

        shellAliases = {
          gconflicts = "git diff --name-only --diff-filter=U --relative";
          gsminit = "git submodule update --init --recursive";
          gsmupd = "git submodule update --remote --recursive";
          update = "pushd $HOME/.config/nix && nix flake update && popd";
          dka = "docker container kill $(docker ps -q)}";
          findpi = "arp -na | grep -i 2c:cf:67";
          sshpi = "ssh evanaze@hs.local";
          ll = "ls -al";
        };
      };
    };
  };
}
