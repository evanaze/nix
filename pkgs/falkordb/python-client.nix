{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  python-dateutil,
  redis,
}:
buildPythonPackage rec {
  pname = "falkordb";
  version = "1.6.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "FalkorDB";
    repo = "falkordb-py";
    rev = "v${version}";
    hash = "sha256-hLhia43Wvk2Ux+zWgdPz2SSCQ5HjqZeCVu/LrK2St7E=";
  };

  build-system = [
    hatchling
  ];

  propagatedBuildInputs = [
    python-dateutil
    redis
  ];

  pythonRelaxDeps = [
    "redis"
  ];

  pythonImportsCheck = [
    "falkordb"
  ];

  meta = {
    description = "Python client for interacting with FalkorDB graph database";
    longDescription = ''
      FalkorDB is a graph database built on top of Redis. This package provides
      a Python client for interacting with FalkorDB, supporting both synchronous
      and asynchronous APIs for graph queries using the Cypher query language.
    '';
    homepage = "https://falkordb-py.readthedocs.io";
    changelog = "https://github.com/FalkorDB/falkordb-py/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.unix;
  };
}