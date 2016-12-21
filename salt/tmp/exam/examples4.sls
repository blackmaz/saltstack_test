Clone the Saltstack bootstrap script repo:
  pkg.installed:
    - name: git
  git.latest:
    - name: https://github.com/saltstack/salt-bootstrap
    - rev: develop
    - target: /tmp/work/salt
