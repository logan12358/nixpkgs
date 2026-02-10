{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
  cadquery-ocp-proxy,
  cadquery-ocp-novtk,
  numpy,
  scipy,
}:
buildPythonPackage rec {
  pname = "ocp_gordon";
  version = "0.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-POHx+1ieiRU00MH9dVOlGHMzNjCIN8S15RZNd98c9ck=";
  };

  build-system = [ setuptools-scm ];

  dependencies = [
    cadquery-ocp-proxy
    numpy
    scipy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    cadquery-ocp-novtk
  ];

  meta = {
    description = "A Python library for Gordon Surface interpolation using B-splines";
    homepage = "https://pypi.org/project/ocp-gordon/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tnytown ];
  };
}
