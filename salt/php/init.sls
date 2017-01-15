{% import 'common/firewall.sls' as firewall with context %}
{% set php = salt['grains.filter_by'] ({
  'Ubuntu': {
    'php': 'php',
    'fpm': 'php-fpm',
    'mysql': 'php-mysqlnd',
    'service': 'php7.0-fpm',
    'cfg': '/etc/php/7.0/fpm/pool.d/www.conf'
  },
  'CentOS': {
    'php': 'php56',
    'fpm': 'php56-php-fpm',
    'mysql': 'php56-php-mysqlnd',
    'service': 'php56-php-fpm',
    'cfg': '/opt/remi/php56/root/etc/php-fpm.d/www.conf'
  },
  'default': 'Ubuntu',
}, grain='os') %}

php:
  pkg.installed:
    - pkgs:
      - {{ php.php }}
      - {{ php.fpm }}
      - {{ php.mysql }}
  service.running:
    - name: {{ php.service }}
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

{{ php.cfg }}:
  file.comment:
    - regex: ^listen.allowed_clients = 127.0.0.1
    - char: ;

nginx_restart:
  service.running:
    - name: nginx
    - watch: 
      - file: /etc/nginx/nginx.conf

