base:
  '*':
    - base.repo
  'vm93':
    - mysql
    - mysql.root_user
    - mysql_user
  'vm94,vm95':
    - match: list
    - nginx
    - php
    - redis
    - redis_cli
    - mysql_cli
    - pandamall

