# TODO: Revisit and move to post-quantum encryption
let
  terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCRi3vBJxt7KZ4+Cmnm0uUTJ54ytQGW1NdV1ESohf2 root@terra";
  slate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBeSGweEbpPGa7t/HiftrnDTtJLEcs14I6jlannZo+L root@slate";

  devvm = "age19rg9q65dgfy0xrnwg8xhl4zkam76qklu4tz40ksrz55ukmeg7gvsk3l2w7";

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
  "guest/password.age".publicKeys = [
    # guest
  ]
  ++ systems;
  "reilly/password.age".publicKeys = [
    reilly
  ]
  ++ systems;

  "devvm/age-identity.age".publicKeys = [
    reilly
  ]
  ++ systems;

  "devvm/opencode-go-api-key.age".publicKeys = [
    devvm
    reilly
  ];
}
