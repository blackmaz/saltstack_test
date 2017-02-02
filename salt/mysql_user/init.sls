# 한글을 입력해도 돌아가는지 확인
{%- set db_pwd  = pillar['db_server']['root_password'] %}
{%- set db_name = pillar['application']['database_name'] %}
{%- set db_usr  = pillar['application']['db_user'] %}
{%- set db_usr_pwd = pillar['application']['db_user_password'] %}

create_{{ db_name }}:
  mysql_database.present:
    - name: {{ db_name }}
    - connection_user: root
    - connection_pass: {{ db_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
  mysql_user.present:
    - name: {{ db_usr }}
    - host: localhost
    - password: {{ db_usr_pwd }}
    - use:
      - mysql_database: {{ db_name }}
    - require:
      - mysql_database: create_{{ db_name }} 
  mysql_grants.present:
    - grant: all privileges
    - database: {{ db_name }}.*
    - user: {{ db_usr }}
    - host: localhost
    - use:
      - mysql_database: {{ db_name }}
    - require:
      - mysql_user: create_{{ db_name }}

grant_{{ db_name }}:
  mysql_user.present:
    - name: {{ db_usr }}
    - host: '%'
    - password: {{ db_usr_pwd }}
    - use:
      - mysql_database: {{ db_name }}
    - require:
      - mysql_user: create_{{ db_name }}

  mysql_grants.present:
    - grant: all privileges
    - database: {{ db_name }}.*
    - user: {{ db_usr }}
    - host: '%'
    - use:
      - mysql_database: {{ db_name }}
    - require:
      - mysql_user: create_{{ db_name }}
