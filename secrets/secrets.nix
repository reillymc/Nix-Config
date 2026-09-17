# TODO: Revisit and move to post-quantum encryption
let
  terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCRi3vBJxt7KZ4+Cmnm0uUTJ54ytQGW1NdV1ESohf2 root@terra";
  slate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBeSGweEbpPGa7t/HiftrnDTtJLEcs14I6jlannZo+L root@slate";

  mist = "age19rg9q65dgfy0xrnwg8xhl4zkam76qklu4tz40ksrz55ukmeg7gvsk3l2w7";

  systems = [
    terra
    slate
  ];

  reilly = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy53djcTOJHEZ0EPXS2pMGrbRf45URABcm/VKSD18u8 reilly@systems";
  # guest = "";

  users = [
    reilly
    # guest
  ];
in
{
  "terra/reilly/restic-backup/env.age".publicKeys = [
    reilly
  ];
  "terra/reilly/restic-backup/password.age".publicKeys = [
    reilly
  ];
  "terra/reilly/restic-backup/repo.age".publicKeys = [
    reilly
  ];
  "slate/reilly/restic-backup/env.age".publicKeys = [
    reilly
  ];
  "slate/reilly/restic-backup/password.age".publicKeys = [
    reilly
  ];
  "slate/reilly/restic-backup/repo.age".publicKeys = [
    reilly
  ];
  "guest/password.age".publicKeys = systems;
  "reilly/password.age".publicKeys = systems;

  "mist/age-identity.age".publicKeys = [
    reilly
  ]
  ++ systems;

  "mist/opencode-go-api-key.age".publicKeys = [
    mist
    reilly
  ];
}
