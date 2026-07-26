let
  airflowCompatOverlay = final: prev: {
    apache-airflow = let
      orig = prev.apache-airflow;
      # Fix task-sdk to skip pythonMetadataCheckPhase (derivation pname="task-sdk"
      # but upstream pyproject.toml says "apache-airflow-task-sdk")
      origTaskSdk = builtins.elemAt orig.dependencies 1;
      fixedTaskSdk = origTaskSdk.overrideAttrs {
        dontCheckPythonMetadata = true;
      };
      # Also fix airflow-core to use the fixed task-sdk
      origCore = builtins.elemAt orig.dependencies 0;
      fixedCore = origCore.overrideAttrs (oldCore: {
        propagatedBuildInputs = map (dep:
          if dep.pname or "" == "task-sdk" then fixedTaskSdk else dep
        ) (oldCore.propagatedBuildInputs or []);
      });
    in orig.overrideAttrs (old: {
      propagatedBuildInputs = [
        fixedCore
        fixedTaskSdk
        (builtins.elemAt (old.propagatedBuildInputs or []) 2) # python3
      ];
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
