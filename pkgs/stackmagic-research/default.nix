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
    rev = "e4554ca1ac6be290779e12749b67a518c7dffaa9";
    private = true;
    hash = lib.fakeHash;
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
