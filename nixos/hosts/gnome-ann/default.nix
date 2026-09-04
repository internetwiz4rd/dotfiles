{
  inputs,
  ...
}:
{
  specialArgs = {
    inherit
      inputs
      ;
  };
  modules = [
    ./configuration.nix
  ];
}
