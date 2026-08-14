{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,
  setuptools-scm,

  # dependencies
  python-dateutil,

  # tests
  pytestCheckHook,
  duckdb,
  numpy,
  pandas,
}:

buildPythonPackage rec {
  pname = "sqlglot";
  version = "30.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tobymao";
    repo = "sqlglot";
    tag = "v${version}";
    hash = "sha256-N5eUcaJHRINbOyF23f3wfGTcSzpJ7/gcMtFFbhPRkcE=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    python-dateutil
  ];

  nativeCheckInputs = [
    pytestCheckHook
    duckdb
    numpy
    pandas
  ];

  meta = {
    description = "An effortless SQL transpiler/compiler that aims to be a generic SQL AST representation";
    homepage = "https://github.com/tobymao/sqlglot";
    changelog = "https://github.com/tobymao/sqlglot/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
}
