{
  age.secrets = {
    "healthchecks/ping-key" = {
      file = ../../secrets/terra/healthchecks/ping-key.age;
      owner = "root";
      group = "users";
      mode = "0440";
    };
    "guest/password".file = ../../secrets/guest/password.age;
    "reilly/password".file = ../../secrets/reilly/password.age;
  };
}
