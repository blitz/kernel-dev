{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "kernel-dev-tools";

  src = ./tools;
  
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    for script in *; do
      install -m0555 "$script" $out/bin/
    done

    runHook preInstall
  '';
}
