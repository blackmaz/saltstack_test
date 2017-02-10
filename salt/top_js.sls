base:
  '*':
    - base.repo
  'minion1':
    - match: list
    - mysql
    - ozr.mysql_db_import

