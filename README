This is a mono-repo containing two applications:

- export_backup
- make_backup

## How to run tests

Pre-requisite:

- [install bash_unit](https://github.com/bash-unit/bash_unit?tab=readme-ov-file#how-to-install-bash_unit).

```
#> bash_unit */tests/test*
```

## Export Backup

`export_backup` deals with two things:

- Exporting Paas generated database backup to external storage
- Backing up S3 to external storage.

## Make Backup

`make_backup` deals with generating database backup on demand. If one need to perform an operation that has the potential to destroy data, one can use this application. It will pg_dump our databases and store it, ciphered, on a private S3 bucket.
