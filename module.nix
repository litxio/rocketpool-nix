{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.ethereum.rocketpool;
in {
  options.services.ethereum.rocketpool = {
    enable = mkEnableOption "Rocketpool node and watchtower services";

    dataDir = mkOption {
      type = types.path;
      default = "/srv/rocketpool";
      description = "Rocketpool data directory.";
    };

    user = mkOption {
      type = types.str;
      default = "rp";
      description = "User under which the services run.";
    };

    group = mkOption {
      type = types.str;
      default = "rp";
      description = "Group under which the services run.";
    };

    validatorServiceName = mkOption {
      type = types.str;
      default = "prysm-validator";
      description = "Name of the validator client service, for running systemctl commands";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
    };

    users.groups.${cfg.group} = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/data 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/data/validators 0775 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/data/rewards-trees 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/data/custom-keys 0755 ${cfg.user} ${cfg.group} - -"

      "d ${cfg.dataDir}/data/validators/prysm-non-hd 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/data/validators/prysm-non-hd/direct 0755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/data/validators/prysm-non-hd/direct/accounts 0755 ${cfg.user} ${cfg.group} - -"

      "f+ ${cfg.dataDir}/restart-vc.sh 0755 ${cfg.user} ${cfg.group} - #!/usr/bin/env bash\\n\\n"
      "w+ ${cfg.dataDir}/restart-vc.sh 0755 ${cfg.user} ${cfg.group} - sudo systemctl restart ${cfg.validatorServiceName}"
      "f+ ${cfg.dataDir}/stop-validator.sh 0755 ${cfg.user} ${cfg.group} - #!/usr/bin/env bash\\n\\n"
      "w+ ${cfg.dataDir}/stop-validator.sh 0755 ${cfg.user} ${cfg.group} - sudo systemctl stop ${cfg.validatorServiceName}"
    ];

    systemd.services.rocketpool = {
      description = "Rocketpool Node";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.rocketpool}/bin/rocketpool --settings ${cfg.dataDir}/user-settings.yml node";
        Restart = "always";
        RestartSec = "5s";
        UMask = "0002";
      };
    };

    systemd.services.rocketpool-watchtower = {
      description = "Rocketpool Watchtower";
      after = [ "network.target" "rocketpool.service" ];
      requires = [ "rocketpool.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.rocketpool}/bin/rocketpool --settings ${cfg.dataDir}/user-settings.yml watchtower";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    systemd.services."${cfg.validatorServiceName}" = {
      serviceConfig.EnvironmentFile =
        "${cfg.dataDir}/data/validators/rp-fee-recipient-env.txt";
    };

    security.sudo.extraConfig = ''
      Cmnd_Alias RP_RESTART = /usr/bin/systemctl restart ${cfg.validatorServiceName}
      Cmnd_Alias RP_STOP = /usr/bin/systemctl stop ${cfg.validatorServiceName}
      ${cfg.user} ALL=(ALL) NOPASSWD: RP_RESTART, RP_STOP
    '';

  };
}
