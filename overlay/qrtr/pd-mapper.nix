{ stdenv, lib, fetchFromGitHub, qrtr, xz }:

stdenv.mkDerivation {
  pname = "pd-mapper";
  version = "unstable-2022-02-08";

  buildInputs = [ qrtr xz ];

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "pd-mapper";
    rev = "10997ba7c43a3787a40b6b1b161408033e716374";
    hash = "sha256-qGrYNoPCxtdpTdbkSmB39+6/pSXml96Aul8b9opF9Lc=";
  };

  patches = [
    ./pd-mapper-firmware-path.diff
  ];

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "Qualcomm PD mapper";
    homepage = "https://github.com/andersson/pd-mapper";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
