# Security

## Secret Management

Secret ciphertext and recipient keys live in a separate private repository,
`reillymc/Nix-Secrets`, encrypted with
[agenix](https://github.com/ryantm/agenix). Plaintext secret material is never
committed. This repository contains no secret material and no key material; see
the Nix-Secrets README for recipients and the edit/rotation workflow.

## Disclosure

Security issues are handled outside the public issue tracker.

## Maintenance Model

This is a single-maintainer configuration. External pull requests are not
currently accepted.
