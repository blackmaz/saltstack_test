{%- set mod_jk = salt['grains.filter_by']({
  'Ubuntu': {
    'worker_dir'  : '/etc/libapache2-mod-jk',
    'worker_file' : 'workers.properties',
    'conf_dir'    : '/etc/apache2/mods-available',
    'conf_file'   : 'jk.conf'

  },
  'CentOS': {
    'worker_dir'  : '/etc/httpd/conf' ,
    'worker_file' : 'workers.properties',
    'conf_dir'    : '/etc/httpd/conf.d',
    'conf_file'   : 'mod_jk.conf'
  },
  'default': 'Ubuntu',
}, grain='os') %}
{%- set os = grains['os'] %}
{%- set workers = salt['pillar.get']('workers', {}) %}
{%- set mod_jk_src = {
    'name'         : 'tomcat-connectors-1.2.42-src',
    'dn_url'       : 'http://mirror.navercorp.com/apache/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz',
    'working_dir'  : '/tmp/mod_jk',
    'cfg_args'     : '--with-apxs=/usr/bin/apxs --enable-api-compatibility',
    'libtool_args' : '--finish /usr/lib64/httpd/modules'
} %}

{%- if os == 'Ubuntu' %}
install_mod_jk:
  pkg.installed:
    - name: libapache2-mod-jk
{%- elif os == 'CentOS' %}
install_pre_req:
  pkg.installed:
    - pkgs:
      - wget
      - httpd-devel
      - libtool

download_mod_jk:
  file.directory:
    - name: {{ mod_jk_src.working_dir }}
    - user: root
    - group: root
  archive.extracted:
    - name: {{ mod_jk_src.working_dir }}
    - source: {{ mod_jk_src.dn_url }}
    - skip_verify: True
    - require:
      - file: download_mod_jk

install_mod_jk:
  cmd.run:
    - name: |
        cd {{ mod_jk_src.working_dir }}/{{ mod_jk_src.name }}/native
        ./configure {{ mod_jk_src.cfg_args }}
        make
        libtool {{ mod_jk_src.libtool_args }}
        make install
    - cwd: {{ mod_jk_src.working_dir }}/{{ mod_jk_src.name }}/native
    - unless: test -f /usr/lib64/httpd/modules/mod_jk.so
    - require:
      - archive: download_mod_jk
      - pkg: install_pre_req
{%- endif %}

mod_jk_conf:
  file.managed:
    - name: {{ mod_jk.conf_dir }}/{{ mod_jk.conf_file }}
    - source: salt://apache/conf/_httpd-jk.conf.{{ os }}
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      worker_file: {{ mod_jk.worker_dir }}/{{ mod_jk.worker_file }}

mod_jk_worker:
  file.managed:
    - name: {{ mod_jk.worker_dir }}/{{ mod_jk.worker_file }}
    - source: salt://apache/conf/_workers.properties
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      site: {{ workers }}

