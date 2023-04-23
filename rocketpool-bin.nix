{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
, lib ? pkgs.lib
, fetchurl ? pkgs.fetchurl
, glibc ? pkgs.glibc
, autoPatchelfHook ? pkgs.autoPatchelfHook
} :

let
  version = "v1.9.3";
  cliUrl = "https://github.com/rocket-pool/smartnode-install/releases/download/${version}/rocketpool-cli-linux-amd64";
  daemonUrl = "https://github.com/rocket-pool/smartnode-install/releases/download/${version}/rocketpool-daemon-linux-amd64";
in stdenv.mkDerivation rec {
  pname = "rocketpool";
  inherit version;

  src = daemon_binary;

  # outputs = [ "out" ];
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    glibc
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [
    stdenv.cc.cc.lib
  ];

  cli_binary = fetchurl {
    url = cliUrl;
    sha256 = "sha256-RFBr9KTy9Tp0Pntt4tqkyWCRVE0pBPPPmcm9gmw0LPw=";
  };

  daemon_binary = fetchurl {
    url = daemonUrl;
    sha256 = "sha256-0bOJm79suPdHaQq/voMBVO8A9erLq60XQCf/sAPLMXE=";
  };

  buildCommand = ''
    mkdir -p $out/bin

    # Install the CLI binary
    cp ${cli_binary} $out/bin/rocketpool
    chmod +x $out/bin/rocketpool

    # Install the daemon binary
    cp ${daemon_binary} $out/bin/rocketpool
    chmod +x $out/bin/rocketpool
    # Nix doesn't like suid
    #chmod u+sx,g+sx,o-rwx $out/bin/rocketpool
  '';

  meta = {
    description = "Rocketpool CLI and daemon";
    homepage = "https://github.com/rocket-pool/smartnode-install";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
