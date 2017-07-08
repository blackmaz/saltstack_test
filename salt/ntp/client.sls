{%- import 'common/service.sls' as service with context %}

{%- set ntp = salt['grains.filter_by']({
  'Debian': {
    'server': 'ntp',
    'service': 'ntp',
    'configfile': '/etc/ntp.conf'
  },
  'RedHat': {
    'server': 'ntp',
    'service': 'ntp',
    'configfile': '/etc/ntp.conf'
  },
  'default': 'Debian',
} ) %}

{%- set ntp_servers = [
'ntp.kornet.net',
'time.bora.net',
'time.kriss.re.kr',
'time.nuri.net',
'time.nist.gov',
'time.windows.com' ] %}

ntp:
  pkg.installed:
    - name: {{ ntp.server }}
  service.running:
    - name: {{ ntp.service }}
    - enable: True
    - watch:
      - pkg: ntp

ntp_pool:
  file.comment:
    - name: {{ ntp.configfile }}
    - regex: ^pool

ntp_server:
  file.append:
    - name: {{ ntp.configfile }}
    - text:
      {%- for ntp_server in ntp_servers %}
      - "server {{ntp_server}}"
      {%- endfor %}

{{ service.service_restart(ntp.service) }}

