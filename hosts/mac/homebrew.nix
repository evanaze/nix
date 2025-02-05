{...}: {
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    brews = [
      "direnv"
      "yt-dlp"
    ];
    casks = [
      "bitwarden"
      "brave-browser"
      "cursor"
      "docker"
      "duplicati"
      "iterm2"
      "keyboardcleantool"
      "nordvpn"
      "proton-mail"
      "proton-mail-bridge"
      "proton-pass"
      "raindropio"
      "spotify"
      "tailscale"
      "visual-studio-code"
      "vlc"
      "zoom"
    ];
  };
}
