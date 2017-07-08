{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set m       = salt['pillar.get'](company+':'+system +':software:mysql', {}) %}
{%- set lsvrs   = salt['pillar.get'](company+':'+system +':logical_server', {}) %}
{%- set psvrs   = salt['pillar.get'](company+':'+system +':physical_server', {}) %}

{%- set cfg = salt['grains.filter_by'] ({
    'Debian': {
          'root_pwd'    : m.get('root').get('pwd')
        , 'rid'         : m.get('replication').get('id')
        , 'rpw'         : m.get('replication').get('pw')
        , 'port'        : m.get('service_port','3306')
        , 'iptype'      : m.get('service_ip'  ,'ip')
        , 'dsvr'        : m.get('deploy_server'  ,'')
        , 'data_dir'    : m.get('data_dir' ,'/var/lib/mysql')
        , 'mst_ip'      : ''
        , 'bind_ip'     : ''
        , 'svr_id'      : ''
        , 'log_dir'     : m.get('log_dir'  ,'/var/log/mysql')
    },
    'RedHat': {
          'root_pwd'    : m.get('root').get('pwd')
        , 'rid'         : m.get('replication').get('id')
        , 'rpw'         : m.get('replication').get('pw')
        , 'port'        : m.get('service_port','3306')
        , 'iptype'      : m.get('service_ip'  ,'ip')
        , 'dsvr'        : m.get('deploy_server'  ,'')
        , 'data_dir'    : m.get('data_dir' ,'/var/lib/mysql')
        , 'mst_ip'      : ''
        , 'bind_ip'     : ''
        , 'svr_id'      : ''
        , 'log_dir'     : m.get('log_dir'  ,'/var/log/mariadb')
    }
}) %}

# From server.slave.cnf.Ubuntu
# Bind IP Setup
{%- if cfg.iptype %}
{%-   for psvr, info in psvrs.items() %}
{%-     if salt['grains.get']('host') == info.hostname %}
{%-       do cfg.update({'bind_ip': info.get(cfg.iptype,None) }) %}
{%-     endif %}
{%-   endfor %}
{%- endif %}

mysql_master_config:
  file.managed:
    - name: {{ mysql.cfg_svr }} 
    - source: salt://mysql/conf/server.master.cnf.{{ grains['os'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
      cfg: {{ cfg }}
      
create_replication_user:
  mysql_query.run:
    - database: mysql
    - query: "GRANT REPLICATION SLAVE ON *.* TO '{{ cfg.rid }}'@'%' IDENTIFIED BY '{{ cfg.rpw }}';"
    - connection_user: root
    - connection_pass: {{ cfg.root_pwd }}

grant_replication_client:
  mysql_query.run:
    - database: mysql
    - query: "GRANT REPLICATION CLIENT ON *.* TO '{{ cfg.rid }}'@'%';"
    - connection_user: root
    - connection_pass: {{ cfg.root_pwd }}

service_restart:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - file: mysql_master_config

