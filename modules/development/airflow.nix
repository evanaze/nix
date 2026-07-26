{
  flake.modules.nixos = {
    # The airflow compat overlay is applied directly by services/airflow.nix
    # where apache-airflow is actually used. This empty attr prevents the
    # import-tree from clobbering development/default.nix:
    # development = {};
  };
}