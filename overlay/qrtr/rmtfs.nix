{ stdenv, lib, fetchFromGitHub, udev, qrtr, qmic }:

stdenv.mkDerivation {
  pname = "rmtfs";
  version = "unstable-2022-01-18";

  buildInputs = [ udev qrtr qmic ];

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "rmtfs";
    rev = "7a5ae7e0a57be3e09e0256b51b9075ee6b860322";
    hash = "sha256-iyTIPuzZofs2n0aoiA/06edDXWoZE3/NY1vsy6KuUiw=";
  };

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "Qualcomm Remote Filesystem Service";
    homepage = "https://github.com/andersson/rmtfs";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
