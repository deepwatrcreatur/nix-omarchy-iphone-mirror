{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  mpv,
  iproute2,
  wl-clipboard,
  systemd,
  libimobiledevice,
  usbmuxd,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  # Fix pyimg4 which is currently marked broken in nixpkgs due to a loose dependency check
  customPython = python3.override {
    packageOverrides = pyFinal: pyPrev: {
      pyimg4 = pyPrev.pyimg4.overridePythonAttrs (old: {
        meta = old.meta // { broken = false; };
        dontCheckRuntimeDeps = true;
        doCheck = false;
      });
    };
    self = customPython;
  };

  pythonEnv = customPython.withPackages (ps: [
    ps.pymobiledevice3
  ]);
in
stdenv.mkDerivation rec {
  pname = "omarchy-iphone-mirror";
  version = "0.1.1-unstable-2026-09-19";

  src = fetchFromGitHub {
    owner = "DanielLemky";
    repo = "omarchy-iphone-mirror";
    rev = "cd076dc9721554f2169c1f2a5cfb818d6ca0e954";
    hash = "sha256-CcGTZasUmA7EwYwAM1/s6CnbvD/cyZspFFMd97EVL+Y=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "iphone-mirror";
      desktopName = "iPhone Mirror";
      comment = "On-demand iPhone mirroring and focused input";
      exec = "iphone-mirror";
      icon = "phone";
      terminal = false;
      categories = [
        "Utility"
        "Network"
      ];
      startupWMClass = "mpv";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/iphone-mirror $out/bin $out/lib/systemd/user

    cp -r *.py *.sh docs $out/share/iphone-mirror/
    if [ -d omarchy-plugin ]; then
      mkdir -p $out/share/omarchy/plugins/daniellemky.iphone-mirror
      cp -r omarchy-plugin/* $out/share/omarchy/plugins/daniellemky.iphone-mirror/
    fi

    # Install systemd user service
    substitute packaging/iphone-mirror.service.in $out/lib/systemd/user/iphone-mirror.service \
      --replace-fail "@PYTHON@" "${pythonEnv}/bin/python3" \
      --replace-fail "@APP_DIR@" "$out/share/iphone-mirror"

    # Wrap launcher commands
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/iphone-mirror \
      --add-flags "$out/share/iphone-mirror/mirror.py" \
      --prefix PATH : ${lib.makeBinPath [
        mpv
        iproute2
        wl-clipboard
        systemd
      ]}

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/iphone-setup-phone \
      --add-flags "$out/share/iphone-mirror/setup-phone.py" \
      --prefix PATH : ${lib.makeBinPath [
        libimobiledevice
        usbmuxd
      ]}

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/iphone-mirror-cli \
      --add-flags "$out/share/iphone-mirror/cli.py" \
      --prefix PATH : ${lib.makeBinPath [ systemd ]}

    runHook postInstall
  '';

  meta = {
    description = "On-demand iPhone mirroring and focused input for Linux over USB or Wi-Fi";
    homepage = "https://github.com/DanielLemky/omarchy-iphone-mirror";
    license = lib.licenses.mit;
    mainProgram = "iphone-mirror";
    platforms = lib.platforms.linux;
  };
}
