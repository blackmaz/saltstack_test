ssh_public_key_exchange:
  file.append:
    - name: /home/sungsic/.ssh/authorized_keys
    - source: salt://test1/home/sungsic/.ssh/id_rsa.pub
