###################################
# openjdk installig sls
###################################
{% set openjdk = salt['grains.filter_by']({
  'Debian': {
    'package': 'openjdk-8-jdk',
    'target': '/etc/alternatives/jre',
  },
  'RedHat': {
    'package': 'java-1.8.0-openjdk-devel',
    'target': '/etc/alternatives/jre',
  },
}) %}

# Debian계열의 경우
{% if grains['os_family']=="Debian" %}

# jdk8의 경우 별도 Repository에 있음,추가 필요
install-apt4java-module:
  cmd.run:
    - name: add-apt-repository -y ppa:openjdk-r/ppa;apt-get -y update

install_openjdk:
  pkg:
    - installed
    - name: {{ openjdk.package }}

{% endif %}
# Redhat계열(CentOS,Fedora)의 경우
{% if grains['os_family']=="RedHat" %}

install_openjdk:
  pkg:
    - installed
    - name: {{ openjdk.package }}

{% endif %}
