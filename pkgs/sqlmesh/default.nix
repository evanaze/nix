{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,
  setuptools-scm,

  # dependencies
  click,
  croniter,
  duckdb,
  dateparser,
  humanize,
  hyperscript,
  importlib-metadata,
  ipywidgets,
  jinja2,
  json-stream,
  packaging,
  pandas,
  pydantic,
  python-dotenv,
  requests,
  rich,
  ruamel-yaml,
  sqlglot,
  tenacity,
  time-machine,
}:

buildPythonPackage (finalAttrs: {
  pname = "sqlmesh";
  version = "0.236.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SQLMesh";
    repo = "sqlmesh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bhlyhCXU01RpOfGoJRQcGQ8NAVsW51mVec8C8YcpqCI=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    croniter
    duckdb
    dateparser
    humanize
    hyperscript
    importlib-metadata
    ipywidgets
    jinja2
    json-stream
    packaging
    pandas
    pydantic
    python-dotenv
    requests
    rich
    ruamel-yaml
    sqlglot
    tenacity
    time-machine
  ];

  # tests require a running duckdb instance and other infrastructure
  doCheck = false;

  pythonImportsCheck = [
    "sqlmesh"
  ];

  meta = {
    description = "Next-generation data transformation framework";
    longDescription = ''
      SQLMesh is a data transformation framework that enables data engineers and
      analysts to efficiently run and manage data transformations with SQL and Python.
      It provides a unified platform for managing data pipelines, version control,
      and data quality checks.
    '';
    homepage = "https://sqlmesh.com";
    changelog = "https://github.com/SQLMesh/sqlmesh/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
    mainProgram = "sqlmesh";
  };
})
