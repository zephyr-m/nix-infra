{
  description = "Local Docker platform with Traefik, wildcard domains, and observability";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bash
              coreutils
              curl
              docker
              docker-compose
              git
              gnugrep
              gnused
              jq
              just
              mkcert
              openssl
              yq-go
            ];

            shellHook = ''
              export INFRA_ROOT="$PWD"
              echo "infra shell: use 'just bootstrap', 'just up', 'just ps'"
            '';
          };
        });
    };
}
