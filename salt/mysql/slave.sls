{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set cfg = {
      'root_pwd'    : salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','')
    , 'rid'         : salt['pillar.get'](company+':'+system+':software:mysql:replication:id','')
    , 'rpw'         : salt['pillar.get'](company+':'+system+':software:mysql:replication:pw','')
    , 'port'        : salt['pillar.get'](company+':'+system+':software:mysql:service_port','3306')
}
%}

mysql_slave_config:
  file.managed:
    - name: {{ mysql.cfg_svr }}
    - source: salt://mysql/conf/server.slave.cnf.{{ grains['os'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
      company: {{company}}
      system: {{system}}
      service_port: {{cfg.port}}

service_restart:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - file: mysql_slave_config

mysql_repl_sql:
  file.managed:
    - name: /tmp/repl.sql
    - source: salt://mysql/conf/repl.sql
    - user: root
    - group: root
    - mode: 644
    - template: jinja

mysql_do_repl:
  cmd.run:
    - name: mysql -uroot -p{{cfg.root_pwd}} < /tmp/repl.sql
    - require:
      - file: mysql_repl_sql

tmp_file_Delete:
  file.absent:
    - name: /tmp/repl.sql
    - require:
      - cmd: mysql_do_repl


