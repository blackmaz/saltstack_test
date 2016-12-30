include:
  - abc

ffab:
  cmd.run:
    - name: ls -l
    - require:
      - cmd: abcd
