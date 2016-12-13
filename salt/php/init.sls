php:
  pkg.installed:
    - pkgs:
      - php56
      - php56-php-fpm
      - php56-php-mysqlnd

  service.running:
    - name: php56-php-fpm
    - enable: True
    - watch:
      - pkg: php

firewalld_php:
  firewalld.present:
    - name: public
    - ports:
      - 9000/tcp
    - require:
      - service: php
  service.running:
    - name: firewalld
    - watch:
      - firewalld: firewalld_php

/usr/share/nginx/html/info.php:
  file.managed:
    - source: salt://php/info.php
    - require:
      - pkg: php

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://php/nginx_default.conf
    - require:
      - pkg: php

nginx_restart:
  service.running:
    - name: nginx
    - watch: 
      - file: /etc/nginx/nginx.conf

