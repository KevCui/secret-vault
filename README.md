# Secret Vault

> Vault, organize and protect secrets with password.

## Dependency

- [openssl](https://linux.die.net/man/1/openssl)

## How to use

```
Usage:
  ./vault.sh [-s <string>|-k <key>]

Options:
  -s <encrypted_string>    optional, decrypt secret
  -k <key>                 optional, decrypt secret paired with key
  -h | --help              display this help message
```

### Example

#### Add secret

- Add secret string `ZYTYYE5FOAGW5ML7LRWUL4WTZLNJAMZS`:

```bash
~$ ./vault.sh
Enter key name: totp secret
Enter secret string: ZYTYYE5FOAGW5ML7LRWUL4WTZLNJAMZS
enter aes-128-cbc encryption password:
Verifying - enter aes-128-cbc encryption password:
[INFO] Saving secret in ./secret.vault
```

#### Show saved secrets

```bash
~$ cat ./secret.vault
#<key>: <encrypted_secret>
totp_secret: U2FsdGVkX1/XTyK0mRuUz8GJiuZFxasmaKjcAC/TSfeXNUXedfd+8xA3k189acAsmNxmfak0DMMDhbrjyGSw1w==
```

#### Reveal secret using key

```bash
~$ ./vault.sh -k totp_secret
enter aes-128-cbc decryption password:
ZYTYYE5FOAGW5ML7LRWUL4WTZLNJAMZS
```

#### Reveal secret with encrypted string

```bash
~$ ./vault.sh -s U2FsdGVkX1/XTyK0mRuUz8GJiuZFxasmaKjcAC/TSfeXNUXedfd+8xA3k189acAsmNxmfak0DMMDhbrjyGSw1w==
enter aes-128-cbc decryption password:
ZYTYYE5FOAGW5ML7LRWUL4WTZLNJAMZS
```
