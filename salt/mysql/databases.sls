{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set root_pwd= salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}
{%- set databases= salt['pillar.get'](company+':'+system+':software:mysql:databases',{}) %}
{%- set psvrs   = salt['pillar.get'](company+':'+system +':physical_server', {}) %}

{%- for id, database in databases.items() %}
create_{{ id }}:
  mysql_database.present:
    - name: {{ id }}
    - character_set: utf8
    - connection_user: root
    - connection_pass: {{ root_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
  mysql_user.present:
    - name: {{ database.user }}
    - host: localhost
    - password: {{ database.pwd }}
    - connection_user: root
    - connection_pass: {{ root_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
    - require:
      - mysql_database: create_{{ id }}
  mysql_grants.present:
    - grant: all privileges
    - database: {{ id }}.*
    - user: {{ database.user }}
    - host: localhost
    - connection_user: root
    - connection_pass: {{ root_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
    - require:
      - mysql_user: create_{{ id }}

grant_{{ id }}:
  mysql_user.present:
    - name: {{ database.user }}
    - host: '%'
    - password: {{ database.pwd }}
    - connection_user: root
    - connection_pass: {{ root_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
    - require:
      - mysql_user: create_{{ id }}

  mysql_grants.present:
    - grant: all privileges
    - database: {{ id }}.*
    - user: {{ database.user }}
    - host: '%'
    - connection_user: root
    - connection_pass: {{ root_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
    - require:
      - mysql_user: create_{{ id }}
{%- endfor %}

