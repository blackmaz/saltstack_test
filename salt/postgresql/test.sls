#postgres:
#  user.present:
#    - password: q1w2e3r4
#    - hash_password: True

db_init:
  postgres_initdb.present:
    - name: /var/lib/pgsql/data
    - auth: password
    - user: pgadmin
    - password: pgadmin123
    - encoding: UTF8
    - locale: None
    - runas: postgres
