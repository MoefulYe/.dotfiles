{
  inputs,
  isLinux,
  isDarwin,
  ...
}:
{
  imports =
    if isLinux then
      [
        inputs.nur.modules.nixos.default
      ]
    else if isDarwin then
      [
        inputs.nur.modules.darwin.default
      ]
    else
      throw "nur.nix: Unsupported OS";
}
