let
  # Mark task-sdk as dontCheckPythonMetadata to avoid pname mismatch
  # (derivation pname="task-sdk" but upstream pyproject.toml says "apache-airflow-task-sdk")
  fixTaskSdk = drv:
    if drv.pname or "" == "task-sdk"
    then drv.overrideAttrs { dontCheckPythonMetadata = true; }
    else drv;

  # Recursively fix task-sdk references in dependency trees (airflowCore also depends on it)
  fixDeps = deps: map (dep:
    if dep.pname or "" == "apache-airflow-core" then
      dep.overrideAttrs (old: {
        propagatedBuildInputs = fixDeps (old.propagatedBuildInputs or []);
      })
    else
      fixTaskSdk dep
  ) deps;

  airflowCompatOverlay = final: prev: {
    apache-airflow = prev.apache-airflow.overrideAttrs (old: {
      propagatedBuildInputs = fixDeps (old.propagatedBuildInputs or []);
    });

    pythonPackagesExtensions =
      (prev.pythonPackagesExtensions or [])
      ++ [
        (_pyFinal: pyPrev: {
          wirerope = pyPrev.wirerope.overridePythonAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''

                python - <<'PY'
                from pathlib import Path

                path = Path("setup.py")
                text = path.read_text()

                if "from pkg_resources import get_distribution" not in text:
                    raise SystemExit("wirerope patch target import not found")

                if '    get_distribution("setuptools>=39.2.0")' not in text:
                    raise SystemExit("wirerope patch target version check not found")

                text = text.replace("from pkg_resources import get_distribution\n", "", 1)
                text = text.replace('    get_distribution("setuptools>=39.2.0")', "    pass", 1)

                path.write_text(text)
                PY
              '';
          });
        })
      ];
  };

  module = {pkgs, ...}: {
    nixpkgs.overlays = [airflowCompatOverlay];

    environment.systemPackages = [pkgs.apache-airflow];
  };
in {
  flake.modules.nixos = {
    developmentAirflow = module;
    development = module;
  };
}
