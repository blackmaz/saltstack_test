{% set salt_master_ip = salt['pillar.get']('salt_master:ip_address')  %}

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
      - file: reg_salt_master

reg_salt_master:
  file.append:
    - name: /etc/hosts
    - text: {{ salt_master_ip }}  salt

