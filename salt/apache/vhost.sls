{%- from 'apache/map.jinja' import apache with context %}

{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set vhosts = salt['pillar.get'](company+':'+system+':software:apache:vhosts',{}) %}

{%- set selinux_enabled = salt['grains.get']('selinux:enabled') %}

{%- for id, vhost in vhosts.items() %}
vhost_cfg_{{ id }}:
  file.managed:
    - name: {{ apache.siteavailable }}/{{ id }}.conf
    - source: salt://apache/conf/_vhost.conf
    - user: root
    - group: root
    - mode: 640
    - template: jinja
{% for key, value in salt['pillar.get'](company+':'+system+':physical_server',{}).items() %}
{% if salt['grains.get']('host') == value.get('hostname') %}
      listen_ip: {{ value.get('ip') }}
{% endif %}
{% endfor %}
      server_name: {{ id }}
      vhost: {{ vhost }}

{%- for port, cfg in vhost.get('ports').items() %}
{%- if cfg.get('doc_root', False) != False %}
doc_root_{{ id }}_{{ port }}:
  file.directory:
    - name: {{ cfg.doc_root }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - file: vhost_cfg_{{ id }}

{%- if selinux_enabled %}
selinux_httpd_sys_content_{{ id }}_{{ port }}:
  cmd.run:
    - name: chcon -R -t httpd_sys_content_t {{ cfg.doc_root }}
    - require: 
      - file: vhost_cfg_{{ id }}
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
    - require:
      - file: vhost_cfg_{{ id }}
{%- if selinux_enabled %}
selinux_httpd_log_{{ id }}_{{ port }}:
  cmd.run:
    - name: chcon -R -t httpd_log_t {{ cfg.log_root }}
    - require:
      - file: vhost_cfg_{{ id }}
{%- endif %}
{%- endif %}
{%- endfor %}
{%- if vhost.get('enable',False) %}
site_enalbe_{{ id }}:
  file.symlink:
    - name: {{ apache.siteenabled }}/{{ id }}.conf
    - target: {{ apache.siteavailable }}/{{ id }}.conf
    - require:
      - file: vhost_cfg_{{ id }}
{%- else %}
site_disalbe_{{ id }}:
  module.run:
    - name: file.remove
    - path: {{ apache.siteenabled }}/{{ id }}.conf
    - onlyif: test -f {{ apache.siteenabled }}/{{ id }}.conf
{%- endif %}
{%- endfor %}

