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
    'ports': {
      '80': {  
        'use_redir': True, 
        'redirect_from': '/', 
        'redirect_to': 'https://www.ozr.kr/'
      },
      '443': {
        'use_redir': True, 
        'redirect_from': '/', 
        'redirect_to': 'https://www.ozr.kr/'
      },
    },
    'enable': True 
  },
  'www.5giraffe.com': { 
    'ports': {
      '443': {
        'use_redir': True, 
        'redirect_from': '/', 
        'redirect_to': 'https://www.ozr.kr/'
      },
    },
    'enable': True 
  },
  'ozr.kr'          : { 
    'ports': {
      '80': {
        'use_redir': True, 
        'redirect_from': '/', 
        'redirect_to': 'https://www.ozr.kr/'
      },
      '443': {
        'use_redir': True, 
        'redirect_from': '/', 
        'redirect_to': 'https://www.ozr.kr/'
      },
    },
    'enable': True 
  },
  'www.ozr.kr'      : { 
    'ports': {
      '443': { 
        'server_admin': 'webmaster',
        'doc_root': '/www/nest/tomcat7/webapps',
        'log_root': '/www/nest/logs/web',
        'use_ssl': True
      },
    },
    'enable': True
  }
} %}
{%- set selinux_enabled = salt['grains.get']('selinux:enabled') %}

{%- for id, site in sites.items() %}
vhost_cfg_{{ id }}:
  file.managed:
    - name: {{ apache.cfg_home }}/sites-available/{{ id }}.conf
    - source: salt://apache/conf/_vhost.conf
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      server_name: {{ id }}
      site: {{ site }}

{%- for port, cfg in site.get('ports').items() %}
{%- if cfg.get('doc_root', False) != False %}
doc_root_{{ id }}_{{ port }}:
  file.directory:
    - name: {{ cfg.doc_root }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{%- if selinux_enabled %}
selinux_httpd_sys_content_{{ id }}_{{ port }}:
  cmd.run:
    - name: chcon -R -t httpd_sys_content_t {{ cfg.doc_root }}
{%- endif %}

{%- endif %}

{%- if cfg.get('log_root', False) != False %}
log_root_{{ id }}_{{ port }}:
  file.directory:
    - name: {{ cfg.log_root }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{%- if selinux_enabled %}
selinux_httpd_log_{{ id }}_{{ port }}:
  cmd.run:
    - name: chcon -R -t httpd_log_t {{ cfg.log_root }}
{%- endif %}
{%- endif %}
{%- endfor %}
{%- if site.get('enable',False) %}
site_enalbe_{{ id }}:
  file.symlink:
    - name: {{ apache.cfg_home }}/sites-enabled/{{ id }}.conf
    - target: {{ apache.cfg_home }}/sites-available/{{ id }}.conf
{%- endif %}
{%- endfor %}

