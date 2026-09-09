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
    rev = "abbfe74d47f871aa57c70fc4e9829fea84a391ab";
    hash = "sha256-NzxtKkN81MhnztH664EINnA370Ggl/4/Db87xKzVvqA=";
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
