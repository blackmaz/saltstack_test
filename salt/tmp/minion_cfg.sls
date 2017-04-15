salt_returner:
  file.line:
    - name: /etc/salt/minion
    - content: "return: mysql, syslog"
    - mode: ensure
    - after: '#  - slack'

