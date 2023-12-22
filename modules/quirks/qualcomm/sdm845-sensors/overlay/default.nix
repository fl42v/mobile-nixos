self: super:
  {
    libqmi = super.libqmi.overrideAttrs (_: {
      version = "1.34.0";
      src = super.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "mobile-broadband";
        repo = "libqmi";
        rev = "1.34.0";
        hash = "sha256-l9ev9ZOWicVNZ/Wj//KNd3NHcefIrLVriqJhEpwWvtQ=";
      };

      patches = []; # even more outdated libqmi in pinned nixpkgs?

    });

    libssc = (super.callPackage ./libssc.nix {}).override { libqmi = self.libqmi; };

    hexagonrpcd = (super.callPackage ./hexagonrpcd.nix {});


    iio-sensor-proxy = super.iio-sensor-proxy.overrideAttrs (attrs: {
      # https://gitlab.com/dylanvanassche/pmaports/-/tree/qcom-sdm845-sensors/temp/iio-sensor-proxy
      src = super.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "hadess";
        repo = "iio-sensor-proxy";
        rev = "48cb957c41b8d51d882219866e1366c45e21c352";
        hash = "sha256-1faWUqkQIrngAehg8uRVyiE4PmIYHp9KNVd0tonemZQ=";
      };

      buildInputs = attrs.buildInputs ++ [
        self.libssc
        super.pkgs.protobufc
      ];

      mesonFlags = attrs.mesonFlags ++ [
        (super.lib.mesonBool "ssc-support" true)
      ];

      patches = [
        # https://gitlab.com/postmarketOS/pmaports/-/tree/0a25713ceb04e2b19ca5add7b5a32da5ac83adb4/temp/iio-sensor-proxy
        # TODO: possibly fetch them from gitlab instead of copying
        # TODO: remove as soon as upstreamed
        ./iio-patches/0001-iio-sensor-proxy-depend-on-libssc.patch
        ./iio-patches/0002-proximity-support-SSC-proximity-sensor.patch
        ./iio-patches/0003-light-support-SSC-light-sensor.patch
        ./iio-patches/0004-accelerometer-support-SSC-accelerometer-sensor.patch
        ./iio-patches/0005-compass-support-SSC-compass-sensor.patch
        ./iio-patches/0006-accelerometer-apply-accel-attributes.patch
        ./iio-patches/0007-data-add-libssc-udev-rules.patch
      ];
    });
  }
