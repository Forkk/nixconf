{ stdenv, fetchFromGitHub, git, dmenu, cmake }:

stdenv.mkDerivation rec {
  name = "j4-dmenu-desktop-${version}";
  version = "2.14";

  src = fetchFromGitHub {
    owner = "enkore";
    repo = "j4-dmenu-desktop";
    rev = "r2.14";
    sha256 = "14srrkz4qx8qplgrrjv38ri4pnkxaxaq6jy89j13xhna492bq128";
  };

  buildInputs = [ git dmenu cmake ];

  meta = with stdenv.lib; {
      description = "A replacement for i3-dmenu-desktop, a dmenu wrapper that uses .desktop files";
      homepage = https://github.com/enkore/j4-dmenu-desktop/;
      # maintainers = with maintainers; [ Forkk ];
      platforms = platforms.all;
  };
}
