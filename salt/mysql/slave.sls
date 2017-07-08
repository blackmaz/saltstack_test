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

# From repl.sql
# Master Node IP Setup
{%- for psvr in lsvrs.get(cfg.dsvr).get('physical_server',[]) %}
{%-   if "mysql_master" in psvrs.get(psvr).get('role',[]) %}
{%-     do cfg.update({'mst_ip' : psvrs.get(psvr).get(cfg.iptype)}) %}
{%-   endif %}
{%- endfor %}


# From server.slave.cnf.Ubuntu
# Bind IP Setup
{%- if cfg.iptype %}
{%-   for psvr, info in psvrs.items() %}
{%-     if salt['grains.get']('host') == info.hostname %}
{%-       do cfg.update({'bind_ip': info.get(cfg.iptype,None) }) %}
{%-     endif %}
{%-   endfor %}
{%- endif %}

#  unique server id 만들기
{%- set tmp = 2 %}
{%- for psvr, info in psvrs.items() %}
{%-   if salt['grains.get']('host') == info.hostname %}
{%-     do cfg.update({'svr_id': tmp }) %}
{%-   else %}
{%-     set tmp = tmp + 1 %}
{%-   endif %}
{%- endfor %}

# From server.slave.cnf.CentOS
# same ubuntu

mysql_slave_config:
  file.managed:
    - name: {{ mysql.cfg_svr }}
    - source: salt://mysql/conf/server.slave.cnf.{{ grains['os'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
      cfg: {{ cfg }}

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
      cfg: {{ cfg }}

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


