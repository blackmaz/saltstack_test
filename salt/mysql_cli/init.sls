{% if salt['grains.get']('selnux:enabled') == 'True' %}
selinux_setsebool_mysql:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_can_network_connect_db
    - value: On
    - persist: TrueA
{% endif %}

/usr/share/nginx/html/mariatest.php:
  file.managed:
    - source: salt://mysql_cli/mariatest.php
    - template: jinja

