{%- from 'apache/map.jinja' import apache with context %}
{%- set os = grains['os'] %}

{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set modjk = salt['pillar.get'](company+':'+system+':software:apache:modjk',{}) %}

{%- if grains['os_family']=='Debian' %}
install_mod_jk:
  pkg.installed:
    - name: libapache2-mod-jk
{%- set req = "pkg: install_mod_jk" %}
{%- elif grains['os_family']=='RedHat' %}
install_pre_req:
  pkg.installed:
    - pkgs:
      - wget
      - httpd-devel
      - libtool

download_mod_jk:
  file.directory:
    - name: {{ apache.modjksrc.working_dir }}
    - user: root
    - group: root
  archive.extracted:
    - name: {{ apache.modjksrc.working_dir }}
    - source: {{ apache.modjksrc.dn_url }}
    - skip_verify: True
    - require:
      - file: download_mod_jk

install_mod_jk:
  cmd.run:
    - name: |
        ./configure {{ apache.modjksrc.cfg_args }}
        make
        libtool {{ apache.modjksrc.libtool_args }}
        make install
    - cwd: {{ apache.modjksrc.working_dir }}/{{ apache.modjksrc.name }}/native
    - unless: test -f /usr/lib64/httpd/modules/mod_jk.so
    - require:
      - archive: download_mod_jk
      - pkg: install_pre_req
{%- set req = "cmd: install_mod_jk" %}
{%- endif %}

mod_jk_conf:
  file.managed:
    - name: {{ apache.modjk.conf_dir }}/{{ apache.modjk.conf_file }}
    - source: salt://apache/conf/_httpd-jk.conf.{{ os }}
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      worker_file: {{ apache.modjk.worker_dir }}/{{ apache.modjk.worker_file }}
    - require:
      - {{ req }}

mod_jk_worker:
  file.managed:
    - name: {{ apache.modjk.worker_dir }}/{{ apache.modjk.worker_file }}
    - source: salt://apache/conf/_workers.properties
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      site: {{ modjk }}
    - require:
      - file: mod_jk_conf
