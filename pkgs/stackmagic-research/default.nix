{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  uv-dynamic-versioning,
  defusedxml,
  duckdb,
  httpx2,
  psycopg,
  pydantic,
  typer,
}:
buildPythonPackage {
  pname = "stackmagic-research";
  version = "0.1.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "evanaze";
    repo = "stackmagic-research";
    private = true;
    rev = "16b52c27fcca72b2e708a5ed3ce8564c875920f8";
    hash = "sha256-J5C6Z4smuJJmrkdby+XbMdEUsoMXdno3pUPUs3K50Mc=";
  };

  nativeBuildInputs = [
    hatchling
    uv-dynamic-versioning
  ];

  propagatedBuildInputs = [
    defusedxml
    duckdb
    httpx2
    psycopg
    pydantic
    typer
  ];

  dontCheck = true;
  pythonImportsCheck = ["stackmagic_prospecting"];

  meta = {
    description = "StackMagic research/prospecting Airflow DAGs";
    homepage = "https://github.com/evanaze/stackmagic-research";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
