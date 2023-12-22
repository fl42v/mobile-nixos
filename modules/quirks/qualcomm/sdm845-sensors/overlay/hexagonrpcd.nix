{ lib
, stdenv
, fetchFromGitLab 
, meson
, ninja
, pkg-config
, cmake
, glib
, mesonEmulatorHook
, libgudev
, libqmi
, protobufc
}:

stdenv.mkDerivation rec {
  pname = "hexagonrpcd";
  version = "git";

  outputs = [ "out" ];

  src = fetchFromGitLab {
    owner = "flamingradian";
    repo = "sensh";
    rev = "c82b2da4eba13009652984749660e79c410ec99c";
    hash = "sha256-q9ABATf+24lrOq/g04FDUd33+uvoA+vt+woXCQcstfs=";
  };
  sourceRoot = "${src.name}/fastrpc";

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
  ];

  buildInputs = [ glib ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://codeberg.org/DylanVanAssche/libssc";
    description = "Library to expose Qualcomm Sensor Core sensors";
    platform = "aarch64-linux";
    license = licenses.gpl3Plus;
  };
}
