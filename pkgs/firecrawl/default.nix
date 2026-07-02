{fetchFromGitHub}: rec {
  rev = "44a6a1665e6ecb565c16a05b25719b377c45c0c5";

  src = fetchFromGitHub {
    owner = "firecrawl";
    repo = "firecrawl";
    inherit rev;
    hash = "sha256-6ueaV67iQznFwNilJdxWso1evdYnFZ7Qljk8AyTOwEg=";
  };
}
