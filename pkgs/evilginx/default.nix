# evilginx: standalone man-in-the-middle attack framework used for phishing
# credentials and session cookies. For authorized red-team / pentest engagements.
# Not in nixpkgs, so packaged here as pkgs.local-pkgs.evilginx.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "evilginx";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "kgretzky";
    repo = "evilginx2";
    tag = "v${version}";
    hash = "sha256-/UQgoT/AO3TpkV5VF5ybVdVSJHLwX2d9k5w579sWEUE=";
  };

  # Upstream commits a vendor/ dir, so deps come from source.
  vendorHash = null;

  # Binary lives at the module root (package main).
  subPackages = ["."];

  ldflags = ["-s" "-w"];

  # evilginx reads its phishlets/ and redirectors/ from a config dir at runtime
  # (-p / -t flags). Ship the bundled ones under share/ so they can be pointed at.
  postInstall = ''
    mv $out/bin/evilginx2 $out/bin/evilginx 2>/dev/null || true
    mkdir -p $out/share/evilginx
    cp -r phishlets redirectors $out/share/evilginx/
  '';

  meta = with lib; {
    description = "Standalone MITM attack framework for phishing login credentials and session cookies (2FA bypass)";
    homepage = "https://github.com/kgretzky/evilginx2";
    license = licenses.bsd3;
    mainProgram = "evilginx";
    platforms = platforms.linux;
  };
}
