{
  stdenvNoCC,
  makeWrapper,
  flakeSelf,
}:

stdenvNoCC.mkDerivation {
  name = "kernel-dev-tools";

  src = ./tools;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    for script in *; do
      install -m0555 "$script" $out/bin/
    done

    wrapProgram $out/bin/enter-kernel-dev \
      --set FLAKE_DIR "${flakeSelf}"

    runHook preInstall
  '';
}
