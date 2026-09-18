{
  age.secrets = {
    "healthchecks/ping-key" = {
      file = ../../secrets/slate/healthchecks/ping-key.age;
      owner = "root";
      group = "users";
      mode = "0440";
    };
    "reilly/password".file = ../../secrets/reilly/password.age;
  };
}
