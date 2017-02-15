{%- import 'common/firewall.sls' as firewall with context %}

{%- if grains['os']=="Ubuntu" %}
mod_ssl:
  cmd.run:
    - name: a2enmod ssl

m2crypto:
  pkg.installed:
    - name: m2crypto
    - require: 
      - cmd: mod_ssl
{%- set req = "pkg: m2crypto" %}
{%- else %}
mod_ssl:
  pkg.installed:
    - name: mod_ssl

python-pip:
  pkg.installed:
    - pkgs:
      - python2-pip
      - gcc
      - python-devel
      - openssl-devel
    - require:
      - pkg: mod_ssl

m2crypto:
  pip.installed:
    - name: m2crypto
    - require:
      - pkg: python-pip
{%- set req = "pip: m2crypto" %}
{%- endif %}

{{ firewall.firewall_open('443', require=req) }}

/etc/pki:
  file.directory: []

/etc/pki/www.key:
  x509.private_key_managed:
    - bits: 4096
    - backup: True
    - require:
      - {{ req }}

/etc/pki/www.crt:
  x509.certificate_managed:
    - signing_private_key: /etc/pki/www.key
    - CN: ca.example.com
    - C: KR
    - ST: Seoul
    - L: Jung-gu
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - require:
      - x509: /etc/pki/www.key
