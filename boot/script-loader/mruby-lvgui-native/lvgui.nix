{ stdenv
, pkgs
, lib
, fetchFromGitHub
, pkg-config
, freetype
, SDL2
, libdrm
, withSimulator ? false
}:

let
  inherit (lib) optional optionals;
  simulatorDeps = [
    SDL2
  ];

  # Minified libinput, both for size and cross-compilation.
  libinput = (pkgs.libinput.override({
    # libwacom doesn't cross-compile at the moment
    libwacom = null;

    documentationSupport = false;
    doxygen = null;
    graphviz = null;

    eventGUISupport = false;
    cairo = null;
    glib = null;
    gtk3 = null;

    testsSupport = false;
    check = null;
    valgrind = null;
    python3 = null;
  })).overrideAttrs(old: {
    buildInputs = with pkgs; [
      libevdev     
      mtdev        
    ];
    nativeBuildInputs = old.nativeBuildInputs ++ [
      pkgs.buildPackages.udev
    ];
    mesonFlags = old.mesonFlags ++ [
      "-Dlibwacom=false"
    ];
  });

  # Allow libevdev to cross-compile.
  libevdev = (pkgs.libevdev.override({
    python3 = null;
  })).overrideAttrs({nativeBuildsInputs ? [], ...}: {
    nativeBuildInputs = nativeBuildsInputs ++ [
      pkgs.buildPackages.python3
    ];
  });
  libxkbcommon = pkgs.callPackage (
    { stdenv
    , libxkbcommon
    , meson
    , ninja
    , pkg-config
    , bison
    }:

    libxkbcommon.overrideAttrs({...}: {
      nativeBuildInputs = [ meson ninja pkg-config bison ];
      buildInputs = [ ];

      mesonFlags = [
        "-Denable-wayland=false"
        "-Denable-x11=false"
        "-Denable-docs=false"
        "-Denable-xkbregistry=false"

        # This is because we're forcing uses of this build
        # to define config and locale root; for stage-1 use.
        # In stage-2, use the regular xkbcommon lib.
        "-Dxkb-config-root=/NEEDS/OVERRIDE/etc/X11/xkb"
        "-Dx-locale-root=/NEEDS/OVERRIDE/share/X11/locale"
      ];

      outputs = [ "out" "dev" ];

      # Ensures we don't get any stray dependencies.
      allowedReferences = [
        "out"
        "dev"
        stdenv.cc.libc_lib
      ];
    })

  ) {};

in
  stdenv.mkDerivation {
    pname = "lvgui";
    version = "2024-03-09";

    src = fetchFromGitHub {
      repo = "lvgui";
      owner = "mobile-nixos";
      rev = "7e77f26e92c7dcebd582f9fd41b3647292b739a1";
      hash = "sha256-0Fb3Wisw9hKXwFUACsFqvuiiO7i79/RxsT10kRGpdRw=";
    };

    # Document `LVGL_ENV_SIMULATOR` in the built headers.
    # This allows the mrbgem to know about it.
    # (In reality this should be part of a ./configure step or something similar.)
    postPatch = ''
      sed -i"" '/^#define LV_CONF_H/a #define LVGL_ENV_SIMULATOR ${if withSimulator then "1" else "0"}' lv_conf.h
    '';

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      freetype
      libevdev
      libdrm
      libinput
      libxkbcommon
    ]
    ++ optionals withSimulator simulatorDeps
    ;

    makeFlags = [
      "PREFIX=${placeholder "out"}"
    ]
    ++ optional withSimulator "LVGL_ENV_SIMULATOR=1"
    ++ optional (!withSimulator) "LVGL_ENV_SIMULATOR=0"
    ;

    enableParallelBuilding = true;
  }
