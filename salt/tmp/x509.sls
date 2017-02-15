/etc/pki/www.key:
  x509.private_key_managed:
    - bits: 4096
    - new: True

/etc/pki/www.crt:
  x509.certificate_managed:
    - signing_policy: www
    - public_key: /etc/pki/www.key
    - CN: www.example.comA
    - days_balid: 90
    - days_remaining: 30
    - backup: True
