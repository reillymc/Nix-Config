{
  secrets,
  ...
}:
{
  age.secrets = {
    "healthchecks/ping-key" = {
      file = secrets.healthchecks.ping-key;
      owner = "root";
      group = "users";
      mode = "0440";
    };
    "reilly/password".file = secrets.users.reilly.password;
  };
}
