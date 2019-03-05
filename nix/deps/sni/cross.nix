{ crossenv }:

crossenv.make_derivation rec {
  name    = "sni";
  builder = ./builder.sh;

  CC = "${crossenv.host}-gcc";
  AR = "${crossenv.host}-ar";

  src = crossenv.nixpkgs.fetchFromGitHub {
    owner = "urbit";
    repo = "sniproxy";
    rev = "173beb88ee62bddd13874ca04ab338cdec704928";
    sha256 = "1ib6p7vhpvbg6d5a2aimppsb09kjg4px4vlw5h3ys9zf9c1if5z4";
  };
}


