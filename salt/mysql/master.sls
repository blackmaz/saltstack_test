{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set cfg = {
      'root_pwd'    : salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','')
    , 'repl_user'   : salt['pillar.get'](company+':'+system+':software:mysql:replication:id','')
    , 'repl_pass'   : salt['pillar.get'](company+':'+system+':software:mysql:replication:pw','')
    , 'service_port':  salt['pillar.get'](company+':'+system+':software:mysql:service_port','3306')
}
%}

mysql_master_config:
  file.managed:
    - name: {{ mysql.cfg_svr }} 
    - source: salt://mysql/conf/server.master.cnf.{{ grains['os'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
      company: {{company}}
      system: {{system}}
      service_port: {{cfg.service_port}}
      
create_replication_user:
  mysql_query.run:
    - database: mysql
    - query: "GRANT REPLICATION SLAVE ON *.* TO '{{ cfg.repl_user }}'@'%' IDENTIFIED BY '{{ cfg.repl_pass }}';"
    - connection_user: root
    - connection_pass: {{ cfg.root_pwd }}

grant_replication_client:
  mysql_query.run:
    - database: mysql
    - query: "GRANT REPLICATION CLIENT ON *.* TO '{{ cfg.repl_user }}'@'%';"
    - connection_user: root
    - connection_pass: {{ cfg.root_pwd }}

service_restart:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - file: mysql_master_config

