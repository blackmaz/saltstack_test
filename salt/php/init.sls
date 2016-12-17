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

add_port_9000:
  module.run:
    - name: firewalld.add_port
    - zone: public
    - port: 9000/tcp
    - require:
      - service: php

reload_firewall_rule_php:
  module.run:
    - name: firewalld.reload_rules
    - require:
      - module: add_port_9000
      
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

