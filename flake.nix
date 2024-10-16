{
  description = "Flake for nix darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
      plugin-vim-kitty = {
      url = "github:knubie/vim-kitty-navigator/20abf8613aa228a5def1ae02cd9da0f2d210352a";
      flake = false;
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    plugin-statuscolumn-nvim = {
      url = "github:JuanBaut/statuscolumn.nvim";
      flake = false;
    };
    plugin-tint-nvim = {
      url = "github:levouh/tint.nvim";
      flake = false;
    };
    plugin-cyberpunk-nvim = {
      url = "github:samueljoli/cyberpunk.nvim";
      flake = false;
    };
    plugin-grug-nvim = {
      url = "github:MagicDuck/grug-far.nvim";
      flake = false;
    };
    plugin-gruvbox-nvim = {
      url = "github:ellisonleao/gruvbox.nvim";
      flake = false;
    };
    plugin-yazi-nvim = {
      url = "github:mikavilpas/yazi.nvim";
      flake = false;
    };
    plugin-heirline-components = {
      url = "github:Zeioth/heirline-components.nvim/f849bbfe05f0d523449eb8d0713dffd4c3d7c295";
      flake = false;
    };
    plugin-lazydev-nvim = {
      url = "github:folke/lazydev.nvim";
      flake = false;
    };
    plugin-luvit-meta = {
      url = "github:Bilal2453/luvit-meta";
      flake = false;
    };
    plugin-dir-telescope = {
      url = "github:princejoogie/dir-telescope.nvim";
      flake = false;
    };
    baouncer = {
      url = "github:lalilul3lo/baouncer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      userName = "sjoli";
      system = "aarch64-darwin";

      # scripts
      rebuild = pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./scripts/rebuild.sh);
      bootstrapScript = builtins.replaceStrings ["@username@"] [userName] (builtins.readFile ./scripts/bootstrap.sh);
      bootstrap = pkgs.writeShellScriptBin "bootstrap" bootstrapScript;

      pkgs = import inputs.nixpkgs { inherit system; };
      machines = import ./machines {
        inherit inputs;
        inherit userName;
      };
    in
    machines.forEach (machine: {
      darwinConfigurations.${machine.name} = machine.darwinConfiguration inputs;
      homeConfigurations.${userName} = machine.homeConfiguration inputs;
    }) // {
      # expose rebuild script in this environment
      devShells.${system}.default = pkgs.mkShell { packages = with pkgs; [rebuild]; };

      # enables running bootstrap script from nix
      packages.${system} = {
        inherit bootstrap;
      };
      apps.${system} = {
        default = {
          type = "app";
          program = "${inputs.self.packages.${system}.bootstrap}/bin/bootstrap";
        };
      };
    };
}
