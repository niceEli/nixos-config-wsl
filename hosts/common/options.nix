{ lib, ... }:
{
  options.niceeli.gpgKey = lib.mkOption {
    type = lib.types.str;
    description = "GPG key ID used as the default gpg key and for git commit signing";
  };
}
