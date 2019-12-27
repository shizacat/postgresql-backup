Описание роли
=============

Установка скрипта бэкапа для базы данных PostgreSQL.

Возможности:

- Бэкап ролей
- Бэкап только указанных баз
- Список исключений
- Логи
- Метрики для прометеуса


Тестирование

```bash
cd tests
./setup.sh
vagrant up
```

Для применения измений в ansible
```bash
vagrant provision
```

Пример Playbook
---------------

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

Лицензия
--------

MIT

Информация об авторе
--------------------

Alexey Matveev