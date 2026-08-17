# Security

## Secret Management

This repository follows an encrypted-secrets policy. All secret material is
stored as age ciphertext
under `secrets/` using [agenix](https://github.com/ryantm/agenix). Plaintext
secret material is never stored in the repository. The recipient public keys and
the mapping of each ciphertext to its consuming host are documented in
`secrets/secrets.nix` and the per-host `secrets.nix` files.

## Key Material

The only key material present in the repository is public: the SSH host and user
public keys used as agenix recipients. Private keys never leave their hosts and
are never committed. Decrypting any secret therefore requires possession of the
corresponding private key on a configured host or user account.

## Disclosure

Security issues are handled outside the public issue tracker.

## Maintenance Model

This is a single-maintainer configuration. External pull requests are not
currently accepted.
