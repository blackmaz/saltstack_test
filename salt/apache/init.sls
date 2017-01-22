{% import 'common/firewall.sls' as firewall with context %}
{%- set salt_home = '/root/saltstack_test/salt' %}
{%- set salt_apachefiledir = salt_home + '/apache/files' %}
{%- set apache = salt['grains.filter_by']({
    'Debian': {
        'server': 'apache2',
        'service': 'apache2',
        'configdir': '/etc/apache2',
        'configfile': 'apache2.conf',
    },
    'RedHat': {
        'server': 'httpd',
        'service': 'httpd',
        'configdir': '/etc/httpd/conf',
        'configfile': 'httpd.conf',
    },
})
%}

apache:
  pkg.installed:
    - name: {{ apache.server }}
  service.running:
    - name: {{ apache.service }}
    - enable: True
    - watch:
      - pkg: apache

{{ apache.configdir }}/{{ apache.configfile }}:
  file.managed:
    - source: salt://apache/conf/{{ apache.configfile }}
    - user: root
    - group: root
    - mode: '640'
    - template: jinja
    - defaults:
      listen_port: 80

{{ firewall.firewall_open('80', require='service: apache') }}
