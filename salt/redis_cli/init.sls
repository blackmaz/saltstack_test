{% set redis = salt['grains.filter_by'] ({
  'Ubuntu': {
    'client': 'php-redis',
    'repository': ''
  },
  'CentOS': {
    'client': 'php-pecl-redis',
    'repository': 'remi-php70'
  },
  'default': 'Ubuntu',
}, grain='os') %}

redis_cli:
  pkg.installed:
{% if redis.repository != '' %}
    - enablerepo: {{ redis.repository }}
{% endif %}
    - name: {{ redis.client }}

#php_fpm:
#  service.running:
#    - name: php56-php-fpm
#    - watch: 
#      - pkg: redis_cli

#nginx_service:
#  service.running:
#    - name: nginx
#    - watch:
#      - pkg: redis_cli

{% if salt['grains.get']('selinux:enabled') == True %}
selinux_redis_port:
  cmd.run:
    - name: semanage port -m -t http_port_t -p tcp 6379
    - require:
      - pkg: redis_cli
{% endif %}

#/usr/share/nginx/html/redistest.php:
#  file.managed:
#    - source: salt://redis_cli/redistest.php
#    - required:
#      - pkg: redis_cli
  
