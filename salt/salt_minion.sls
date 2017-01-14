{% set salt_master_ip = salt['pillar.get']('salt_master:ip_address')  %}

reg_salt_master:
  host.present:
    - name: salt
    - ip: {{ salt_master_ip }}

install_curl:
  pkg.install:
    - name: curl
    - require:
      - file: reg_salt_master

install_pyyaml:
  pip.removed:
    - name: PyYAML
    - require:
      - file: reg_salt_master
      
salt_minion:
  cmd.run:
    - name: |
        curl -L https://bootstrap.saltstack.com -o install_salt.sh
        sh install_salt.sh -P
    - unless: test -x /usr/bin/salt-minion
    - require:
      - pkg: install_curl
      