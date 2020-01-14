Role Name
=========

The role is the script of backup database PostgreSQL.

Feature:

- Backup of postgresql role
- Backup only selected databases
- Rotation of backup
- List of exclude databases
- Logs
- Prometheus metrics

### Run

Specify a settings file to run the script.

```bash
./pg_backup.sh config.example
```

The description of config can be found in [config](files/config).

Paths:

- /opt/pg_backup/bin - script
- /opt/pg_backup/conf - config folder
- /var/log/pg_backup - logs folder


### Testing

```bash
cd tests
./setup.sh
vagrant up
```

To apply ansible changes

```bash
vagrant provision
```

Example Playbook
----------------

    - hosts: servers
      vars:
        pg_backup_config_file: config.test
        pg_backup_config: |
          DIR_TO_BACKUP=/backup
          DB_URL=postgresql:///postgres
          EXCLUDE="template1"
          ONLY_INCLUDE=""
        pg_backup_user: postgres
        pg_backup_group: postgres
      roles:
        - postgresql-backup

License
-------

MIT

Author Information
------------------

Alexey Matveev
