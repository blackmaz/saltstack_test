base:
  '*':
    - base.repo
  'vm83,vm93':
    - match: list
    - mysql
    - mysql_user
  'vm84,vm94':
    - match: list
    - nginx
    - php
    - redis
    - redis_cli
    - mysql_cli
    - pandamall

