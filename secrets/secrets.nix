let
  terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCRi3vBJxt7KZ4+Cmnm0uUTJ54ytQGW1NdV1ESohf2";
  reilly = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy53djcTOJHEZ0EPXS2pMGrbRf45URABcm/VKSD18u8";

  systems = [ terra ];
  users = [ reilly ];
in
{
  "terra/restic-backup/env.age".publicKeys = [
    terra
    reilly
  ];
  "terra/restic-backup/password.age".publicKeys = [
    terra
    reilly
  ];
  "terra/restic-backup/repo.age".publicKeys = [
    terra
    reilly
  ];
}
