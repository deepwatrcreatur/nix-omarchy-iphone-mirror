{
  lib,
  stdenv,
  fetchurl,
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
  customPython = python3.override {
    packageOverrides = pyFinal: pyPrev: {
      pyimg4 = pyPrev.pyimg4.overridePythonAttrs (old: {
        meta = old.meta // { broken = false; };
        dontCheckRuntimeDeps = true;
        doCheck = false;
      });

      parameter-decorators = pyPrev.buildPythonPackage rec {
        pname = "parameter_decorators";
        version = "0.0.2";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/de/7b/1fa9000dbe427745af3eda3f1690d86e2161b6cfcd56b16cd76008a8f2c5/parameter_decorators-0.0.2-py2.py3-none-any.whl";
          hash = "sha256-j4koA1b36pg3Jb9HU0wiFx+9EKE9mBWfRPPFW6iuc+c=";
        };
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };

      pmd-net-proto = pyPrev.buildPythonPackage rec {
        pname = "pmd_net_proto";
        version = "0.0.3";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/16/b1/f76c04c704fd78e219095fed9a69a4e356f43c103855badc6524de181511/pmd_net_proto-0.0.3-py3-none-any.whl";
          hash = "sha256-joQzWL2F9DvKc1iotmFUGPTmWpTuTKz+7U146RkJqYw=";
        };
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };

      pmd-net-addr = pyPrev.buildPythonPackage rec {
        pname = "pmd_net_addr";
        version = "0.0.3";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/e1/c8/57f5c7cb292839d182519c944fd4660ae39c5a4266691f2ef73080ea0af7/pmd_net_addr-0.0.3-py3-none-any.whl";
          hash = "sha256-fTay7PUQBGNUUczqKj6pep/VZOaPAzl+ljXEP/bqQXs=";
        };
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };

      pmd-pytcp = pyPrev.buildPythonPackage rec {
        pname = "pmd_pytcp";
        version = "0.3.7";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/de/0a/0cf601c19e2cafadb68b36533c1ffa54ab1132f4fc40833f0b63ea0be0ad/pmd_pytcp-0.3.7-py3-none-any.whl";
          hash = "sha256-Xqdw5hHgXvjP6Im5aBbn4fTUn16rKWk9Pi9TxZEo3wE=";
        };
        propagatedBuildInputs = [
          pyFinal.pmd-net-proto
          pyFinal.pmd-net-addr
        ];
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };

      developer-disk-image = pyPrev.buildPythonPackage rec {
        pname = "developer_disk_image";
        version = "0.3.0";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/c9/47/8322b1356a4e3e455a743308d1d43d117b1e82e8311639e710171e950b8f/developer_disk_image-0.3.0-py3-none-any.whl";
          hash = "sha256-VFHrKAvPUYj0BhBwgbBctHGPZF9d2cZO6UL1d6QxCPk=";
        };
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };

      typer-injector = pyPrev.buildPythonPackage rec {
        pname = "typer_injector";
        version = "0.3.0";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/f1/97/6217b630fc5ec896dc7226a36aafa26e87ae6c106043ec505490e52459fb/typer_injector-0.3.0-py3-none-any.whl";
          hash = "sha256-AupQMp9eQRWSxbjvg4f/oEO1iXfwQx7ESfex9BcX+Q8=";
        };
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };

      pymobiledevice3 = pyPrev.buildPythonPackage rec {
        pname = "pymobiledevice3";
        version = "11.13.1";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/65/0e/bcbfd741ee7c83ec587a0cbc4002bec8ebe9e6f598e2fb46065e0340e25f/pymobiledevice3-11.13.1-py3-none-any.whl";
          hash = "sha256-SbMrcQGd3IZ2qK5b0bZ3xueu+L+c8BnyPvZyYXtJ1tk=";
        };
        propagatedBuildInputs = pyPrev.pymobiledevice3.propagatedBuildInputs ++ (with pyFinal; [
          developer-disk-image
          parameter-decorators
          pmd-pytcp
          pmd-net-proto
          pmd-net-addr
          typer-injector
          questionary
          ifaddr
        ]);
        catchConflicts = false;
        doCheck = false;
        dontCheckRuntimeDeps = true;
      };
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
