{
  description = "flake templates for various languages";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    flake-parts,
  }: {
    templates = {
      base = flake-parts.templates.default;
      janet = {
        description = "janet lang template";
        path = ./janet;
      };
    };
  };
}
