{%- if salt['grains.get']('selinux:enabled') == True -%}
selinux_setsebool_mysql:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_can_network_connect_db
    - value: On
    - persist: True
{%- endif -%}

