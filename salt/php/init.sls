{% import 'common/firewall.sls' as firewall with context %}
{% set php = salt['grains.filter_by'] ({
  'Ubuntu': {
    'php': 'php',
    'fpm': 'php-fpm',
    'mysql': 'php-mysqlnd',
    'service': 'php7.0-fpm',
    'cfg': '/etc/php/7.0/fpm/pool.d/www.conf',
    'repository': ''
  },
  'CentOS': {
    'php': 'php',
    'fpm': 'php-fpm',
    'mysql': 'php-mysqlnd',
    'service': 'php-fpm',
    'cfg': '/etc/php-fpm.d/www.conf',
    'repository': 'remi-php70'
  },
  'default': 'Ubuntu',
}, grain='os') %}

php:
  pkg.installed:
{% if php.repository != '' %}
    - enablerepo: {{ php.repository }}
{% endif %}
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

#/usr/share/nginx/html/info.php: #centos
#/var/www/html/info.php: #ubuntu
#  file.managed:
#    - source: salt://php/info.php
#    - require:
#      - pkg: php
#
#/etc/nginx/nginx.conf:  #centos
#/etc/nginx/sites-available/default: #ubuntu
#  file.managed:
#    - source: salt://php/nginx_default.conf
#    - require:
#      - pkg: php

{{ php.cfg }}:
  file.comment:
    - regex: ^listen.allowed_clients = 127.0.0.1
    - char: ;

#nginx_restart:
#  service.running:
#    - name: nginx
#    - watch: 
#      - file: /etc/nginx/nginx.conf

