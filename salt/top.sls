base:
  '*':
    - common.repo
  'vm03.chossvm':
    - mysql
    - mysql_user
  'vm04.chossvm,vm05.chossvm':
    - match: list
    - nginx
    - php
    - redis
    - redis_cli
    - mysql_cli
    - pandamall

