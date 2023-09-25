{
  description = "HH: a CLI Helper for creating Hetzner Cloud servers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    python-packages = ps:
      with ps; [
        requests
        python-dateutil
      ];
  in {
    devShell.x86_64-linux = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        python3
        ansible
        ansible-lint
        (pkgs.python3.withPackages python-packages)
      ];
    };
  };
}
