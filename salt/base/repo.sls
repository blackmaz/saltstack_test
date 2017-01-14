install_epel:
  pkg.installed:
    - name: epel-release

install_remi_repo:
  cmd.run:
    - name: rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    - require:
      - pkg: install_epel


