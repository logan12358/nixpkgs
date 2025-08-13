{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

let
  version = "2.5.0";
  soext = stdenv.hostPlatform.extensions.sharedLibrary;
  lib3mf-lib = pkgs.lib3mf;
in
buildPythonPackage {
  pname = "lib3mf";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "3MFConsortium";
    repo = "lib3mf_python";
    rev = "v${version}";
    hash = "sha256-N3eguLaUKw/uvikRFuIvEYGYAad5RZV6mV9Dvu9SfuI=";
  };

  build-system = [ setuptools ];

  postPatch = ''
    echo "include lib3mf/lib3mf${soext}" > MANIFEST.in
  '';

  pythonImportsCheck = [ "lib3mf" ];

  prePatch = ''
    rm lib3mf/lib3mf.{dll,dylib,so}
    cp -L ${lib.getLib lib3mf-lib}/lib/lib3mf${soext} lib3mf/
  '';

  meta = {
    broken = (lib.versions.majorMinor version) != (lib.versions.majorMinor lib3mf-lib.version);
    description = "Python bindings to lib3mf";
    homepage = "https://github.com/3MFConsortium/lib3mf_python";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tnytown ];
  };
}
