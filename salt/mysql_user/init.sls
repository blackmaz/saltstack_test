pandamall_database:
  mysql_database.present:
    - name: {{ pillar['application']['database_name'] }}
    - connection_user: root
    - connection_pass: {{pillar['db_server']['root_password']}}
    - connection_host: localhost
    - connection_charset: utf8
  mysql_user.present:
    - name: {{ pillar['application']['db_user'] }}
    - host: localhost
    - password: {{ pillar['application']['db_user_password'] }}
    - use:
      - mysql_database: {{ pillar['application']['database_name'] }}
    - require:
      - mysql_database: pandamall_database
  mysql_grants.present:
    - grant: all privileges
    - database: {{ pillar['application']['database_name'] }}.*
    - user: {{ pillar['application']['db_user'] }}
    - host: localhost
    - use:
      - mysql_database: {{ pillar['application']['database_name'] }}
    - require:
      - mysql_user: pandamall_database

{% for client_ip in salt['pillar.get']('db_server:client_ip', {}) %} 
pandamall_grant_{{client_ip}}:
  mysql_user.present:
    - name: {{ pillar['application']['db_user'] }}
    - host: {{client_ip}}
    - password: {{ pillar['application']['db_user_password'] }}
    - use:
      - mysql_database: {{ pillar['application']['database_name'] }}
    - require:
      - mysql_user: pandamall_database

  mysql_grants.present:
    - grant: all privileges
    - database: {{ pillar['application']['database_name'] }}.*
    - user:  {{ pillar['application']['db_user'] }}
    - host: {{client_ip}}
    - use:
      - mysql_database: {{ pillar['application']['database_name'] }}
    - require:
      - mysql_user: pandamall_database
{% endfor %}
