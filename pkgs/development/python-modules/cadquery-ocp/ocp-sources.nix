{
  lib,
  gcc14Stdenv,
  writers,
  fetchFromGitHub,

  llvmPackages,
  cmake,
  ninja,

  apple-sdk,
  fmt,
  fontconfig,
  freetype,
  libglvnd,
  libx11,
  nlohmann_json,
  opencascade-occt,
  pybind11,
  rapidjson,
  utf8cpp,
  vtk,
  vtkSupport ? true,
  xorgproto,

  pythonBuildEnv,
}:
let
  version = "7.9.3.1.1";

  opencascade-occt' = opencascade-occt.override {
    withVtk = vtkSupport;
  };

  stdenv = gcc14Stdenv;
in
stdenv.mkDerivation {
  pname = "ocp-sources";
  inherit version;

  src = fetchFromGitHub {
    owner = "CadQuery";
    repo = "OCP";
    rev = version;
    hash = "sha256-TKvJ03WHVuUAMTHLr2KWjKU1rBoSOfpAIxjjpYKN2nQ=";
    name = "ocp";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    fmt
    fontconfig
    freetype
    libglvnd
    libx11
    nlohmann_json
    opencascade-occt'
    pybind11
    rapidjson
    utf8cpp
    xorgproto

    llvmPackages.openmp
    llvmPackages.llvm
    llvmPackages.libclang
  ] ++ lib.optional vtkSupport vtk;

  patches = [
    # Use CXX_IMPLICIT_INCLUDE_DIRECTORIES for header discovery on Darwin
    ./cmake-implicit-includes-darwin.patch

    # Don't hard-code OSX prefix and includes
    ./ocp-toml-osx.patch
  ]
    # Patch vtk out of OCP (see https://github.com/CadQuery/ocp-build-system/blob/a6b1f3686f268ef1a42f3047ca01bc0aa9a60114/.github/actions/build-ocp/action.yml#L144)
    ++ lib.optional (!vtkSupport) ./ocp-novtk.patch;

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DN_PROC=$NIX_BUILD_CORES"
    )
  '';

  cmakeFlags = [
    (lib.cmakeFeature "Python_ROOT_DIR" "${pythonBuildEnv}")
    (lib.cmakeFeature "CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES" "${lib.getDev stdenv.cc.cc}/include/c++/*;${lib.getDev stdenv.cc.cc}/include/c++/*/${stdenv.targetPlatform.config};${lib.getDev stdenv.cc.libc}/include")
  ];
  dontUseCmakeBuildDir = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r OCP/* $out

    runHook postInstall
  '';
}
