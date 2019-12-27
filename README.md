Role Name
=========

The role is the script of backup database PostgreSQL.

Feature:

- Backup of postgresql role
- Backup only selected databases
- The list of exclude databases
- Logs
- The metrics for Prometheus


Testing

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
