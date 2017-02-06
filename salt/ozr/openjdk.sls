{% set settings = salt['grains.filter_by']({
  'Debian': {
    'package': 'openjdk-8-jdk',
    'target': '/etc/alternatives/jre',
  },
  'RedHat': {
    'package': 'java-1.8.0-openjdk-devel',
    'target': '/etc/alternatives/jre',
  },
}) %}

{% if grains['os_family']=="Debian" %}

install-apt4java-module:
  cmd.run:
    - name: add-apt-repository ppa:openjdk-r/ppa;apt-get update

install_openjdk:
  pkg:
    - installed
    - name: {{ settings.package }}

{% endif %}

{% if grains['os_family']=="RedHat" %}


{% endif %}
