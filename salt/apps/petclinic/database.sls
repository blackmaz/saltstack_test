{%- set db_name = 'petclinic' %}
{%- set root_password = '' %}

petclinic_database:
  mysql_database.present:
    - name: {{ db_name }}
    - connection_user: root
    - connection_pass: {{ root_password }}
    - connection_host: localhost
    - connection_charset: utf8
