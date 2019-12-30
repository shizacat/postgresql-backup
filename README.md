Role Name
=========

The role is the script of backup database PostgreSQL.

Feature:

- Backup of postgresql role
- Backup only selected databases
- The list of exclude databases
- Logs
- The metrics for Prometheus

### Run

For the script run, him need to specify file with settings.

```bash
./pg_backup.sh config.example
```

The description of config can be found in 
[config](files/config).

Paths:

- /opt/pg_backup/bin - script
- /opt/pg_backup/conf - folder with config
- /var/log/pg_backup - folder with logs


### Testing

```bash
cd tests
./setup.sh
vagrant up
```

During development, so that apply the changes.

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
