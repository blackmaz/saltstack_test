{% import 'common/firewall.sls' as firewall with context %}

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

{{ firewall.firewall_open('9000', require='service: php') }}

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

/opt/remi/php56/root/etc/php-fpm.d/www.conf:
  file.comment:
    - regex: ^listen.allowed_clients = 127.0.0.1
    - char: ;

nginx_restart:
  service.running:
    - name: nginx
    - watch: 
      - file: /etc/nginx/nginx.conf

