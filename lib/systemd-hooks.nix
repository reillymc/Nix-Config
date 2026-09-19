{ lib }:
{
  prefix,
  name,
  start ? false,
  failure ? true,
  success ? true,
}:
let
  unit = kind: "${prefix}-${name}-${kind}.service";
in
lib.optionalAttrs failure {
  OnFailure = [ (unit "failure") ];
}
// lib.optionalAttrs success {
  OnSuccess = [ (unit "success") ];
}
// lib.optionalAttrs start {
  After = [ (unit "start") ];
  Wants = [ (unit "start") ];
}
