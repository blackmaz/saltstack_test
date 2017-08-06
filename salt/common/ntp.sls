{%- set company = salt['pillar.get']('company','de2o') %}
{%- set system = salt['pillar.get']('system','test') %}
{%- import 'common/service.sls' as service with context %}

{%- set cfg = salt['grains.filter_by']({
  'Debian': {
    'ntp' : {
      'server': 'ntp',
      'service': 'ntp',
      'configfile': '/etc/ntp.conf'
    },
    'tz': {
      'localtime': '/etc/localtime',
      'zoneinfo': '/usr/share/zoneinfo'
    }
  },
  'RedHat': {
    'ntp' : {
      'server': 'ntp',
      'service': 'ntpd',
      'configfile': '/etc/ntp.conf'
    },
    'tz': {
      'localtime': '/etc/localtime',
      'zoneinfo': '/usr/share/zoneinfo'
    }
  },
  'default': 'Debian',
} ) %}

{%- set continent = 'Asia' %}
{%- set city = 'Seoul' %}


{%- set ntp_servers = [
'ntp.kornet.net',
'time.bora.net',
'time.kriss.re.kr',
'time.nuri.net',
'time.nist.gov',
'time.windows.com' ] %}

time_zone:
  file.symlink:
    - name: {{ cfg.tz.localtime }}
    - target: {{ cfg.tz.zoneinfo }}/{{ continent }}/{{ city }}

ntp:
  pkg.installed:
    - name: {{ cfg.ntp.server }}
  service.running:
    - name: {{ cfg.ntp.service }}
    - enable: True
    - watch:
      - pkg: ntp

ntp_server:
  file.comment:
    - name: {{ cfg.ntp.configfile }}
    - regex: ^pool
    - require:
      - service: ntp
  file.append:
    - name: {{ cfg.ntp.configfile }}
    - text:
      {%- for ntp_server in ntp_servers %}
      - "server {{ntp_server}}"
      {%- endfor %}
    - require:
      - file: ntp_pool

{{ service.service_restart(cfg.ntp.service) }}

