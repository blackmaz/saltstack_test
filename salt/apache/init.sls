{% import 'common/firewall.sls' as firewall with context %}
{%- set salt_home = '/root/saltstack_test/salt' %}
{%- set salt_apachefiledir = salt_home + '/apache/files' %}
{%- set apache = salt['grains.filter_by']({
    'Debian': {
        'server': 'apache2',
        'service': 'apache2',
        'configdir': '/etc/apache2',
        'configfile': 'apache2.conf',
        'configsitefile': '000-default.conf',
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

{% if grains['os_family']=="Debian" %}

install-proxy-module:
  cmd.run:
    - name: a2enmod proxy;a2enmod proxy_http;

{{ apache.configdir }}/{{ apache.configfile }}:
  file.managed:
    - source: salt://apache/conf/_{{ apache.configfile }}
    - user: root
    - group: root
    - mode: '640'
    - template: jinja
    - defaults:
      listen_port: 80

{{ apache.configdir }}/sites-available/{{ apache.configsitefile }}:
  file.managed:
    - source: salt://apache/conf/_{{ apache.configsitefile }}
    - user: root
    - group: root
    - mode: '640'
    - template: jinja

{% endif %}

{% if grains['os_family']=="RedHat" %}

{{ apache.configdir }}/{{ apache.configfile }}:
  file.append:
    - source: salt://apache/conf/_{{ apache.configfile }}
    - template: jinja

{% endif %}

{{ firewall.firewall_open('80', require='service: apache') }}
