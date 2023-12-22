{ config, lib, pkgs, ... }:

{
  imports = [
    ./sound.nix
  ];

  mobile.hardware = {
    soc = "qualcomm-sdm845";
  };

  mobile.boot.stage-1 = {
    compression = "xz";
    kernel.package = (pkgs.callPackage ./kernel { });
  };

  hardware.enableRedistributableFirmware = true;

  # Note: on devices it's highly likely no firmware is required during stage-1.
  # DRM *should* work fine without firmware.
  # Modems and such will pick them back up in stage-2.
  # Even though, we're eagerly adding firmware files that fit.
  # This is a workaround for non-modular kernels wanting to load the adsp firmware during stage-1.
  mobile.boot.stage-1.firmware = [
    (pkgs.runCommand "initrd-firmware" {} ''
      # for op6 pmos folks only copy the gpu-related stuff
      # https://gitlab.com/dylanvanassche/pmaports/-/blob/qcom-sdm845-sensors/device/community/firmware-oneplus-sdm845/APKBUILD
      # https://gitlab.com/dylanvanassche/pmaports/-/blob/qcom-sdm845-sensors/device/community/firmware-oneplus-sdm845/30-gpu-firmware.files
      # since i'm trying to make exactly op6 a bit more usable, i'll comment unnecessary stuff out for now (and make an overlay/override later)
      #cp -vrf ${config.mobile.device.firmware} $out
      #chmod -R +w $out
      ## Big file, fills and breaks stage-1
      #rm -v $out/lib/firmware/qcom/sdm845/*/modem.mbn

      # Copy extra a630 firmware from linux-firmware
      mkdir -p $out/lib/firmware/qcom/sdm845/oneplus6
      cp -vf ${pkgs.linux-firmware}/lib/firmware/qcom/{a630_sqe.fw,a630_gmu.bin} $out/lib/firmware/qcom
      # some device-specific crap.
      # TODO: check if it's used (somehow :D)
      cp -vrf ${config.mobile.device.firmware}/lib/firmware/qcom/sdm845/oneplus6/a630_zap.mbn $out/lib/firmware/qcom/sdm845/oneplus6/a630_zap.mbn
    '')
  ];


  mobile.system.type = "android";
  mobile.system.android = {
    # Assumed all SDM845 devices use A/B
    ab_partitions = lib.mkDefault true;
    # Assumed all SDM845 devices can boot with the same options.
    bootimg.flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      # https://gitlab.com/dylanvanassche/pmaports/-/blob/qcom-sdm845-sensors/device/community/device-oneplus-enchilada/deviceinfo#L28
      # the following github issue (which # i kinda like) says it's not used, but still
      # https://github.com/NixOS/mobile-nixos/issues/666
      offset_second = "0x00f00000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
    appendDTB = lib.mkDefault [
      "dtbs/qcom/sdm845-${config.mobile.device.name}.dtb"
    ];
  };

  # TODO: check if role switching was mainlined (or at least downstreamed).
  # I remember it being done for 845-s
  mobile.usb.mode = "gadgetfs";
  # The identifiers used here serve as a compatible well-known identifier.
  mobile.usb.idVendor = lib.mkDefault "18D1"; # Google
  mobile.usb.idProduct = lib.mkDefault "D001"; # "Nexus 4"

  mobile.usb.gadgetfs.functions = {
    adb = "ffs.adb";
    mass_storage = "mass_storage.0";
    rndis = "rndis.usb0";
  };

  mobile.quirks.qualcomm.sdm845-modem.enable = true;
  mobile.quirks.qualcomm.sdm845-sensors.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT}=="1", SUBSYSTEMS=="input", ATTRS{name}=="pmi8998_haptics", TAG+="uaccess", ENV{FEEDBACKD_TYPE}="vibra"
  '';
}
