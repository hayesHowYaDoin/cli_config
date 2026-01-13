inputs: {pkgs, ...}: {
  imports = [
    ./git.nix
    ./nvim.nix
    ./zsh.nix
    inputs.nvim-config.homeManagerModules.default
  ];

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
    fastmod
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
    xclip
    yazi
    zip
    zoxide
  ];
}
