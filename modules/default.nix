{pkgs, ...}: {
  imports = [./git.nix ./nvim.nix ./zsh.nix];

  home.packages = with pkgs; [
    bat
    caligula
    chafa
    claude-code
    coreutils
    devenv
    direnv
    dust
    eza
    fd
    fzf
    htop
    impala
    lazygit
    nitch
    nvtopPackages.full
    oh-my-posh
    presenterm
    ripgrep
    tldr
    tmux
    typst
    usbutils
    yazi
    zip
    zoxide
  ];
}
