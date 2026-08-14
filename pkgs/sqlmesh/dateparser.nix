{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  python-dateutil,
  pytz,
  regex,
  tzlocal,
  hijridate,
  convertdate,
  fasttext,
  numpy,
  langdetect,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "dateparser";
  version = "1.2.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "scrapinghub";
    repo = "dateparser";
    tag = "v${version}";
    hash = "sha256-O0FsLWbH0kGjwGCTklBMVVqosxXlXRyS9aAcggtBLsA=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    python-dateutil
    pytz
    regex
    tzlocal
  ];

  optional-dependencies = {
    calendars = [
      hijridate
      convertdate
    ];
    fasttext = [
      fasttext
      numpy
    ];
    langdetect = [
      langdetect
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  doCheck = false;

  pythonImportsCheck = [
    "dateparser"
  ];

  meta = {
    description = "Date parsing library designed to parse dates from HTML pages";
    homepage = "https://github.com/scrapinghub/dateparser";
    changelog = "https://github.com/scrapinghub/dateparser/blob/v${version}/HISTORY.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
}
