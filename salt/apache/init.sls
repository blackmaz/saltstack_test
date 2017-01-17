{%- set salt_home = '/root/saltstack_test/salt' %}
{%- set salt_apachefiledir = salt_home + '/apache/files' %}
{%- set apache = salt['grains.filter_by']({
    'Debian': {
        'server': 'apache2',
        'service': 'apache2',
        'configfile': '/etc/apache2/apache2.conf',
    },
    'RedHat': {
        'server': 'httpd',
        'service': 'httpd',
        'configfile': '/etc/httpd/conf/httpd.conf',
    },
})
%}


apache:
  pkg.installed:
    - name: {{ apache.server }}
  service.running:
    - name: {{ apache.service }}
    - enable: True
