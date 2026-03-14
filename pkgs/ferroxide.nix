{lib, buildGoModule, fetchFromGitHub}:

buildGoModule rec {
  pname = "ferroxide";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "ferroxide";
    rev = "v${version}";
    hash = "sha256-GShbqcsfM2Wx4Ge4pmdgAUhXIsQSxlG+WE3VKda8ZoU=";
  };

  vendorHash = "sha256-YjJdC0ZXNLAUbCoK4L2h0B4EG4y+iYKcTudJkAiOItU=";

  subPackages = ["cmd/ferroxide"];

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Third-party ProtonMail bridge with CalDAV support";
    homepage = "https://github.com/acheong08/ferroxide";
    license = licenses.mit;
    mainProgram = "ferroxide";
    platforms = platforms.linux;
  };
}
