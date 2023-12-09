{ mobile-nixos
, fetchFromGitLab
, fetchpatch
, ...
}:

mobile-nixos.kernel-builder {
  version = "6.6.3";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "sdm845-6.6.3-r3";
    hash = "sha256-StE6pFwSPklhI0xjp85JSPG0yIFOZ6VU72mQoVrIFSo=";
  };

  # still necessary?
  #patches = [
  #  # ASoC: codecs: tas2559: Fix build
  #  (fetchpatch {
  #    url = "https://github.com/samueldr/linux/commit/d1b59edd94153ac153043fb038ccc4e6c1384009.patch";
  #    sha256 = "sha256-zu1m+WNHPoXv3VnbW16R9SwKQzMYnwYEUdp35kUSKoE=";
  #  })
  #];

  isModular = false;
  isCompressed = "gz";
}
