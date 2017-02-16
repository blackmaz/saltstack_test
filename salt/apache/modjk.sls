{%- set modjk = salt['grains.filter_by']({
  'Ubuntu': {
    'worker_dir'  : '/etc/libapache2-mod-jk' ,
    'worker_file' : 'workers.properties'
  },
  'CentOS': {
    'worker_dir'  : '/etc/libapache2-mod-jk' ,
    'worker_file' : 'workers.properties'
  },
  'default': 'Ubuntu',
}, grain='os') %}
{%- set os = grains['os'] %}

{%- set workers = {
  'worker' : {
    'worker1' : {'port': '8009', 'host': 'localhost' },
    'worker2' : {'port': '9009', 'host': 'localhost' }
  },
  'lb' : {
    'loadbalancer' : {'balance_workers' : [ 'worker1', 'worker2' ] }
  },
  'list' : [ 'worker1', 'worker2']
} %}

{%- if os == 'Ubuntu' %}
install_mod_jk:
  pkg.installed:
    - name: libapache2-mod-jk

modjk_cfg:
  file.managed:
    - name: {{ modjk.worker_dir }}/{{ modjk.worker_file }}
    - source: salt://apache/conf/_workers.properties.{{ os }}
    - user: root
    - group: root
    - mode: 640
    - template: jinja
      site: {{ workers }}
{%- endif %}

