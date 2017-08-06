{%- import 'common/firewall.sls' as firewall with context %}

{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- from 'mysql/map.jinja' import mysql with context %}

{%- set m       = salt['pillar.get'](company+':'+system +':software:mysql', {}) %}
{%- set lsvrs   = salt['pillar.get'](company+':'+system +':logical_server', {}) %}
{%- set psvrs   = salt['pillar.get'](company+':'+system +':physical_server', {}) %}

{%- set cfg = salt['grains.filter_by'] ({
    'Debian': {
          'root_pwd'    : m.get('root').get('pwd')
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

# From my.cnf.CentOS
# Bind IP Setup
#{%- if cfg.iptype %}
#{%-   for psvr, info in psvrs.items() %}
#{%-     if salt['grains.get']('host') == info.hostname %}
#{%-       do cfg.update({'bind_ip': info.get(cfg.iptype,None) }) %}
#{%-     endif %}
#{%-   endfor %}
#{%- endif %}

{%- do cfg.update({'bind_ip': salt['network.ip_addrs']()[0]}) %}

# From my.cnf.Ubuntu
# same CentOS


{%- if grains['os_family'] == 'Debian' %}
mysql-debconf:
  debconf.set:
    - name: {{ mysql.server }}
    - data:
        'mysql-server/root_password': {'type': 'string', 'value':'{{ cfg.root_pwd }}'}
        'mysql-server/root_password_again': {'type':'string', 'value':'{{ cfg.root_pwd }}'}
{%- endif %}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}

mysql_cfg:
  file.managed:
    - name: {{ mysql.cfg }}
    - source: salt://mysql/conf/my.cnf.{{ grains['os'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
      cfg: {{cfg}}

mysql_service:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: mysql
      - file: mysql_cfg

{{ firewall.firewall_open(cfg.port, require='service: mysql_service') }}


