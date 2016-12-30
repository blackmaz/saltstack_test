abcd:
  cmd.run:
    - name: ls -al
    - require:
      - cmd: cdef

bcdef:
  cmd.run:
    - name: ps 
    - require:
      - cmd: abcd

cdef:
  cmd.run:
    - name: ping -c 3 192.168.10.80



