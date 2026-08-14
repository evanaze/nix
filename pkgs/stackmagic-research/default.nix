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
    rev = "86054c6892698cba7e9ff8db10bdf5e0f79d0bce";
    private = true;
    hash = "sha256-HutfzrEK4yr6PZhD42EHxGvQHFk290DqRF+ziYKAIx8=";
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
