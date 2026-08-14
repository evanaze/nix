{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,
  setuptools-scm,

  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hyperscript";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vchan";
    repo = "hyperscript";
    tag = "v${version}";
    hash = "sha256-mbq7E6FVNx4X37uUXiCD+jUlYZj/ql2KD7L10lUKuV0=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "hyperscript"
  ];

  meta = {
    description = "Python library for creating HTML with the hyperscript scripting language";
    homepage = "https://github.com/vchan/hyperscript";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
}
