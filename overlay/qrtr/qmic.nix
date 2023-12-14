{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "qmic";
  version = "unstable-2022-02-18";

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "qmic";
    rev = "4574736afce75aa5eec1e1069a19563410167c9f";
    sha256 = "sha256-0/mIg98pN66ZaVsQ6KmZINuNfiKvdEHMsqDx0iciF8w=";
  };

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "QMI IDL compiler";
    homepage = "https://github.com/andersson/qmic";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
