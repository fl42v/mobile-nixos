# mostly copied from ../sdm845-modem.nix
{ config, lib, pkgs, options, ... }:

let
  cfg = config.mobile.quirks.qualcomm.sdm845-sensors;
  inherit (lib)
    mkIf
    mkOption
    optional
    types
  ;
in
{
  options.mobile = {
    quirks.qualcomm.sdm845-sensors.enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable this on a mainline-based SDM845 device for sensor support
      '';
    };
  };
  config = mkIf cfg.enable {

  
    nixpkgs.overlays = [
      (import ./overlay)
    ];

    # TODO: similar stuff is required for sensors, hence commenting out so far
#    environment.pathsToLink = [ "/share/uncompressed-firmware" ];
#    environment.systemPackages = [
#      (pkgs.callPackage (
#        { lib
#        , runCommand
#        , buildEnv
#        , firmwareFilesList
#        }:
#
#        runCommand "qcom-modem-uncompressed-firmware-share" {
#          firmwareFiles = buildEnv {
#            name = "qcom-modem-uncompressed-firmware";
#            paths = firmwareFilesList;
#            pathsToLink = [
#              "/lib/firmware/rmtfs"
#            ]
#              ++ optional cfg.sdm845-modem.enable "/lib/firmware/qcom/sdm845"
#              ++ optional cfg.sc7180-modem.enable "/lib/firmware/qcom/sc7180-trogdor"
#            ;
#          };
#        } ''
#          PS4=" $ "
#          (
#          set -x
#          mkdir -p $out/share/
#          ln -s $firmwareFiles/lib/firmware/ $out/share/uncompressed-firmware
#          )
#        ''
#      ) {
#        # We have to borrow the pre `apply`'d list, thus `options...definitions`.
#        # This is because the firmware is compressed in `apply` on `hardware.firmware`.
#        firmwareFilesList = lib.flatten options.hardware.firmware.definitions;
#      })
#    ];
#
    systemd.services = {
      hexagonrpcd-sdsp = {
        wantedBy =["multi-user.target"];
        serviceConfig = {
          # TODO: create users
          #user = fastrpc;
          #group = fastrpc;
          execStart = "${pkgs.hexagonrpcd}/bin/hexagonrpcd -f /dev/fastrpc-sdsp -R /run/current-system/sw/share/uncompressed-firmware/ -s";
        };
      };
    };
  };
}
