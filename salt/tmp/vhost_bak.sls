{%- set apache = salt['grains.filter_by']({
  'Ubuntu': {
    'cfg_home': '/etc/apache2'
  },
  'CentOS': {
    'cfg_home': '/etc/httpd'
  },
  'default': 'Ubuntu',
}, grain='os') %}
# 신규로 생성되는 사이트 별로 정의하는 설정, 추후에 xml로 UI에서 받아와야 함
{%- set sites = {
  '5giraffe.com'    : { 
    'listen_port': '80',  
    'use_redir': True, 
    'redirect_from': '/', 
    'redirect_to': 'https://www.ozr.kr/',
    'enable': True
  },
  '5giraffe.com'    : { 
    'listen_port': '443', 
    'use_redir': True, 
    'redirect_from': '/', 
    'redirect_to': 'https://www.ozr.kr/',
    'enable': False 
  },
  'www.5giraffe.com': { 
    'listen_port': '443', 
    'use_redir': True, 
    'redirect_from': '/', 
    'redirect_to': 'https://www.ozr.kr/',
    'enable': True 
  },
  'ozr.kr'          : { 
    'listen_port': '80',  
    'use_redir': True, 
    'redirect_from': '/', 
    'redirect_to': 'https://www.ozr.kr/',
    'enable': True 
  },
  'ozr.kr'          : { 
    'listen_port': '443', 
    'use_redir': True, 
    'redirect_from': '/', 
    'redirect_to': 'https://www.ozr.kr/',
    'enable': True 
  },
  'www.ozr.kr'      : { 
    'listen_port': '443', 
    'server_admin': 'webmaster',
    'doc_root': '/www/nest/tomcat7/webapps',
    'log_root': '/www/nest/logs/web',
    'enable': True
  }
} %}

{%- for id, site in sites.items() %}
vhost_cfg_{{ id }}:
  file.managed:
    - name: {{ apache.cfg_home }}/sites-available/{{ id }}.conf
    - source: salt://apache/conf/vhost.conf
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      server_name: {{ id }}
      site: {{ site }}

{%- if site.get('doc_root', False) != False %}
doc_root_{{ id }}:
  file.directory:
    - name: {{ site.doc_root }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
{%- endif %}

{%- if site.get('log_root', False) != False %}
log_root_{{ id }}:
  file.directory:
    - name: {{ site.log_root }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
{%- endif %}
{%- if site.get('enable') %}
site_enalbe_{{ id }}:
  file.symlink:
    - name: {{ apache.cfg_home }}/sites-enabled/{{ id }}.conf
    - target: {{ apache.cfg_home }}/sites-available/{{ id }}.conf
{%- endif %}
{%- endfor %}

