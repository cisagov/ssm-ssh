{
    description = "Tool to simplify secure shell connections over AWS Systems Manager (SSM).";

    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
      flake-utils.url = "github:numtide/flake-utils";
    };
    outputs = { self, nixpkgs, flake-utils }:
      flake-utils.lib.eachDefaultSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
          awssh = pkgs.python310Packages.buildPythonPackage rec {
            pname = "awssh";
            version = "1.1.0";
            doCheck = false;
            propagatedBuildInputs = with pkgs.python310Packages; [
              boto3
              docopt
              schema
              setuptools
              wheel
            ];
            src = pkgs.fetchFromGitHub {
              owner = "cisagov";
              repo = "awssh";
              rev = "v1.1.0";
              sha256 = "sha256-4b2VBFUQye4wTvuagPwEImLwkUO4Dk5hvOYW+eg8OGA=";
             };
            };
          in {
          packages.default = pkgs.python310Packages.buildPythonPackage rec {
            pname = "awssh";
            version = "1.1.0";
            src = ./.;
            propagatedBuildInputs = with pkgs.python310Packages; [
              boto3
              docopt
              schema
              setuptools
              wheel
        ];
      };
    });
}
