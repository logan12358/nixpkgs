{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  uv-build,
}:
# See the build process in https://github.com/CadQuery/ocp-build-system/blob/a6b1f3686f268ef1a42f3047ca01bc0aa9a60114/.github/workflows/build-ocp.yml#L165
buildPythonPackage rec {
  pname = "cadquery_ocp_proxy";
  version = "7.9.3.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "CadQuery";
    repo = "ocp-build-system";
    rev = "v${version}";
    hash = "sha256-DZ8K5+DVAdNwIoZWgngMcSEdlEE0r7XTW6klVnV1GXA=";
    rootDir = "cadquery_ocp_proxy";
  };

  postPatch = ''
    sed -i.bak 's/^version = .*/version = "${version}"/' pyproject.toml
    echo "# Don't edit, will be overwritten during build" > src/cadquery_ocp_proxy/_version.py
    echo "__version__ = \"${version}\"" >> src/cadquery_ocp_proxy/_version.py
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.7,<0.10.0" uv_build
  '';

  build-system = [ uv-build ];

  meta = {
    description = "Proxy package to track cadquery_ocp / cadquery_ocp_novtk version";
    homepage = "https://github.com/CadQuery/ocp-build-system/cadquery_ocp_proxy";
    license = lib.licenses.asl20;
  };
}
