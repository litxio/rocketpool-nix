{ pkgs ? import <nixpkgs> {}
, fetchFromGitHub ? pkgs.fetchFromGitHub
, buildGoApplication ? pkgs.buildGoApplication
, lib ? pkgs.lib
} :

buildGoApplication rec {
  pname = "rocketpool-smartnode";
  version = "v1.9.3";

  modules = ./gomod2nix.toml;

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "${version}";
    sha256 = "14601jlnshhwlhdqs2rsq50j68gnsjqx9ks4yp32nipip0vvh6wv";
    # date = "2023-04-21T00:59:21-04:00";
  };

  # buildPhase = ''
  #   cd $src/rocketpool
  #   ./build.sh
  #   cd $src/rocketpool-cli
  #   ./build.sh
  # '';

  # installPhase = ''
  #   mkdir -p $out/bin

  #   cp $src/rocketpool/rocketpool-daemon-linux-amd64 $out/bin/rocketpool
  #   cp $src/rocketpool-cli/rocketpool-cli-linux-amd64 $out/bin/rocketpool-cli
  # '';

  meta = {
    description = "Rocketpool Smartnode and CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
  };
}
