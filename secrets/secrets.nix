let
  terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCRi3vBJxt7KZ4+Cmnm0uUTJ54ytQGW1NdV1ESohf2";
  slate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBeSGweEbpPGa7t/HiftrnDTtJLEcs14I6jlannZo+L root@slate";

  systems = [
    terra
    slate
  ];

  reilly = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy53djcTOJHEZ0EPXS2pMGrbRf45URABcm/VKSD18u8 reilly@systems";

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
  "slate/restic-backup/env.age".publicKeys = [
    slate
    reilly
  ];
  "slate/restic-backup/password.age".publicKeys = [
    slate
    reilly
  ];
  "slate/restic-backup/repo.age".publicKeys = [
    slate
    reilly
  ];
}
