{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,

  mkPythonMetaPackage,
  python,
  pythonImportsCheckHook,
  toPythonModule,

  cmake,
  ninja,

  pybind11,
  vtk,
  vtkSupport ? true,
}:

let
  pythonBuildEnv = python.withPackages (
    ps: with ps; [
      click
      lief
      path
      libclang
      toml
      pandas
      joblib
      tqdm
      jinja2
      toposort
      logzero
      pyparsing
      pybind11
      schema
    ]
  );

  ocp-sources = callPackage ./ocp-sources.nix { inherit pythonBuildEnv vtkSupport; };
  inherit (ocp-sources) version;
in
toPythonModule (
  stdenv.mkDerivation (finalAttrs: {
    pname = if vtkSupport then "cadquery-ocp" else "cadquery-ocp-novtk";
    inherit version;
    src = ocp-sources;

    nativeBuildInputs =
      ocp-sources.nativeBuildInputs
      ++ lib.optional (stdenv.buildPlatform == stdenv.hostPlatform) pythonImportsCheckHook;
    inherit (ocp-sources) buildInputs;

    propagatedBuildInputs = [
      (mkPythonMetaPackage {
        inherit (finalAttrs) pname version meta;
        dependencies = lib.optional vtkSupport vtk;
      })
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-Wno-deprecated-declarations";
    };

    cmakeFlags = [ (lib.cmakeFeature "Python_ROOT_DIR" "${pythonBuildEnv}") ];

    separateDebugInfo = true;

    installPhase =
      let
        destDir = "$out/${python.sitePackages}";
      in
      ''
        runHook preInstall

        mkdir -p ${destDir}
        cp ./*.so ${destDir}

        runHook postInstall
      '';

    pythonImportsCheck = [
      "OCP"
      "OCP.gp"
    ];

    meta = {
      description = "Python wrapper for OCCT generated using pywrap";
      homepage = "https://github.com/CadQuery/OCP";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ tnytown ];
    };
  })
)
