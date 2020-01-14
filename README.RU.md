Описание роли
=============

Установка скрипта бэкапа для базы данных PostgreSQL.

Возможности:

- Бэкап ролей
- Бэкап только указанных баз
- Ротация бэкапов
- Список исключений
- Логи. Ротация логов.
- Метрики для прометеуса


### Запуск

Для запуска скрипта ему нужно указать файл с настройками

```bash
./pg_backup.sh config.example
```

Описание параметров настройки можно посмотеть в [config](files/config).

Пути:

- /opt/pg_backup/bin - скрипт
- /opt/pg_backup/conf - папка с конфигом
- /var/log/pg_backup - папка с логами


### Тестирование

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
          DIR_TO_BACKUP=/backup/store
          DIR_WORK=/backup/work
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
