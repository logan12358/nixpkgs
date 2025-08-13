{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
  pytestCheckHook,
  cadquery-ocp-proxy,
  cadquery-ocp-novtk,
  svgelements,
}:
let
  pname = "ocpsvg";
  version = "0.6.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8I2kNHzJDs01ZTlem9pXRtRquKr9aiaBuwOpwyG1QDk=";
  };
in
buildPythonPackage {
  inherit src pname version;
  pyproject = true;

  build-system = [
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook cadquery-ocp-novtk ];

  dependencies = [
    cadquery-ocp-proxy
    svgelements
  ];

  meta = {
    description = "Translator between OCP and svgelements";
    homepage = "https://github.com/3MFConsortium/lib3mf_python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tnytown ];
  };
}
