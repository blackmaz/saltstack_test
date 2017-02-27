{%- set root_pwd = salt['pillar.get']('software:mysql:root_pwd') %}
{%- set databases = salt['pillar.get']('software:mysql:databases',{}) %}

{%- for id, database in databases.items() %}
create_{{ id }}:
  mysql_database.present:
    - name: {{ id }}
    - connection_user: root
    - connection_pass: {{ root_pwd }}
    - connection_host: localhost
    - connection_charset: utf8
  mysql_user.present:
    - name: {{ database.user }}
    - host: localhost
    - password: {{ database.pwd }}
    - use:
      - mysql_database: {{ id }}
    - require:
      - mysql_database: create_{{ id }} 
  mysql_grants.present:
    - grant: all privileges
    - database: {{ id }}.*
    - user: {{ database.user }}
    - host: localhost
    - use:
      - mysql_database: {{ id }}
    - require:
      - mysql_user: create_{{ id }}

grant_{{ id }}:
  mysql_user.present:
    - name: {{ database.user }}
    - host: '%'
    - password: {{ database.pwd }}
    - use:
      - mysql_database: {{ id }}
    - require:
      - mysql_user: create_{{ id }}

  mysql_grants.present:
    - grant: all privileges
    - database: {{ id }}.*
    - user: {{ database.user }}
    - host: '%'
    - use:
      - mysql_database: {{ id }}
    - require:
      - mysql_user: create_{{ id }}
{%- if database.get('import',False) %}
dmpfile_dn_{{ id }}:
  file.managed:
    - name: /tmp/dbdump_{{id}}.sql
    - source: {{ database.data }} 
    - user: root
    - group: root
    - mode: 644

dmpfile_imp_{{ id }}:
  cmd.run:
    - name: mysql -u root -p'{{ root_pwd|replace("'", "'\"'\"'") }}' < /tmp/dbdump_{{id}}.sql
    - require:
      - file: dmpfile_dn_{{ id }}
{%- endif %}
{%- endfor %}

