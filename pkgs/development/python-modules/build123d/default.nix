{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  pytestCheckHook,
  setuptools-scm,
  anytree,
  ezdxf,
  ipython,
  numpy,
  cadquery-ocp-novtk,
  ocpsvg,
  ocp-gordon,
  lib3mf,
  requests,
  sympy,
  scipy,
  scikit-learn,
  svgpathtools,
  trianglesolver,
  webcolors,
}:
buildPythonPackage {
  pname = "build123d";
  version = "0.10.0-unstable-2026-06-12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gumyr";
    repo = "build123d";
    rev = "98f0e6f457905cddd3d42fc25a89376506ab311e";
    hash = "sha256-EOWuTpo4nlm5Zd0c1G/g33R94UOK4TZXm1lSUpgy2Gw=";
  };

  env.SETUPTOOLS_SCM_PRETEND_VERSION = "0.10.0";

  patches = [
    ./test_large_step_file.patch
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    anytree
    ezdxf
    ipython
    numpy
    cadquery-ocp-novtk
    ocpsvg
    ocp-gordon
    lib3mf
    requests
    scipy
    scikit-learn
    sympy
    svgpathtools
    trianglesolver
    webcolors
  ];

  pythonRelaxDeps = [
    "ipython"
    "webcolors"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    cp ${fetchurl {
      url = "https://github.com/tpaviot/pythonocc-demos/blob/8158b217efc313889162e7c4dfefba87078d1270/assets/models/as1-oc-214.stp";
      hash = "sha256-A4vmWcVLFsnz2o17Lae2Pj/Yh506vlt4JhCDNqfAuuk=";
    }} ./as1-oc-214.stp
  '';

  meta = {
    description = "python CAD programming library";
    homepage = "https://github.com/gumyr/build123d";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tnytown ];
  };
}
