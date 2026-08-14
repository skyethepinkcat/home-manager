{
  callPackage,
  writeShellApplication,
  script,
  depends ? [ ],
  bashOptions ? [
    "errexit"
    "nounset"
    "pipefail"
  ],
  ...
}:
callPackage writeShellApplication {
  name = "${script}";
  runtimeInputs = depends;
  inherit bashOptions;
  inheritPath = false;
  text = builtins.readFile ./files/scripts/${script}.sh;
}
