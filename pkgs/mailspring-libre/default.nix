{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, alsaLib
, coreutils
, db
, dpkg
, glib
, gtk3
, libkrb5
, libsecret
, nss
, openssl
, udev
, xorg
}:

stdenv.mkDerivation rec {
  pname = "mailspring";
  version = "1.8.0-libre";

  src = fetchurl {
    url = "https://github.com/notpushkin/Mailspring-Libre/releases/download/${version}/mailspring-${version}-amd64.deb";
    sha256 = "5cf5cf6cd541df6f50db3529c113ab19943ea43d17909a7997e2fb0ccfb1ca31";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    alsaLib
    db
    glib
    gtk3
    libkrb5
    libsecret
    nss
    xorg.libxkbfile
    xorg.libXScrnSaver
    xorg.libXtst
  ];

  runtimeDependencies = [
    coreutils
    openssl
    (lib.getLib udev)
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -ar ./usr/share $out

    substituteInPlace $out/share/mailspring/resources/app.asar.unpacked/mailsync \
      --replace dirname ${coreutils}/bin/dirname

    ln -s $out/share/mailspring/mailspring $out/bin/mailspring
    ln -s ${openssl.out}/lib/libcrypto.so $out/lib/libcrypto.so.1.0.0
  '';

  postFixup = /* sh */ ''
    substituteInPlace $out/share/applications/mailspring.desktop \
      --replace /usr/bin $out/bin
  '';

  meta = with lib; {
    description = "A fork of a fork – aiming at removing Mailspring's dependecy on a central server.";
    longDescription = ''
      Mailspring is an open-source mail client forked from Nylas Mail and built with Electron.
      Mailspring's sync engine runs locally, but its source is not open.
    '';
    license = licenses.unfree;
    maintainers = with maintainers; [ toschmidt popcornrules ];
    homepage = "https://getmailspring.com";
    downloadPage = "https://github.com/notpushkin/Mailspring-Libre";
    platforms = platforms.x86_64;
  };
}
