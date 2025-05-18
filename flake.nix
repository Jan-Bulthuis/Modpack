{
  description = "A cool minecraft modpack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-modpack.url = "github:Jan-Bulthuis/nix-modpack";
    nix-modpack.inputs.nixpkgs.follows = "nixpkgs";
    nix-minecraft.url = "github:Jan-Bulthuis/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      eachSystem =
        fn: lib.genAttrs lib.systems.flakeExposed (system: fn (import inputs.nixpkgs { inherit system; }));
    in
    {
      packages = eachSystem (pkgs: {
        server = inputs.nix-modpack.packages.${pkgs.system}.mkModpackServer {
          packUrl = "https://raw.githubusercontent.com/Jan-Bulthuis/Modpack/refs/heads/master/pack.toml";
          server = inputs.nix-minecraft.legacyPackages.${pkgs.system}.neoForgeServers.neoforge-21_1_172;
        };

        testServer = inputs.nix-modpack.packages.${pkgs.system}.mkModpackServer {
          packUrl = "http://localhost:8080/pack.toml";
          server = inputs.nix-minecraft.legacyPackages.${pkgs.system}.neoForgeServers.neoforge-21_1_172;
        };

        client = inputs.nix-modpack.packages.${pkgs.system}.mkModpackClient {
          packUrl = "https://raw.githubusercontent.com/Jan-Bulthuis/Modpack/refs/heads/master/pack.toml";
          gameVersion = "1.21.1";
          loaderUid = "net.neoforged";
          loaderVersion = "21.1.172";
        };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ packwiz ];
        };
      });
    };
}
