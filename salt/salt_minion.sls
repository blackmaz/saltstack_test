{% set salt_master_ip = '192.168.10.81' %}

salt_minion:
  cmd.run:
    - name: |
        curl -L https://bootstrap.saltstack.com -o install_salt.sh
        sudo sh install_salt.sh -P
    - unless: test -x /usr/bin/salt-minion

reg_salt_master:
  file.append:
    - name: /etc/hosts
    - text: {{ salt_master_ip }}  salt
    - require:
      - cmd: salt_minion

salt_minion_restart:
  service.running:
    - name: salt-minion
    - watch:
      - file: reg_salt_master
