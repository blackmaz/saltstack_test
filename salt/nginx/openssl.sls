{%- import 'common/firewall.sls' as firewall with context %}
{%- from "nginx/map.jinja" import nginx with context %}

# nginx는 openssl 사용시에 별도로 설치할 것이 없음

{{ firewall.firewall_open('443') }}

/etc/pki:
  file.directory: []

/etc/pki/www.key:
  x509.private_key_managed:
    - bits: 4096
    - backup: True
    - require:
      - file: /etc/pki

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

