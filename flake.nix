{
  description = "CLI home-manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim_config = {
      url = "github:hayesHowYaDoin/nvim_config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    home-manager,
    nixpkgs,
    nvim_config,
    ...
  } @ inputs: {
    homeManagerModules.default = import ./modules/default.nix inputs;
  };
}
