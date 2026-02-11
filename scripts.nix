{
  callPackage,
  writeShellApplication,
  script,
  depends ? [],
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
  bashOptions = bashOptions;

  text = builtins.readFile ./files/scripts/${script}.sh;
}
