import salt.client.ssh.client

#ssh_key='/home/ubuntu/aws/test_key_pair'
ssh_key='/home/sungsic/.ssh/id_rsa'

s = salt.client.ssh.client.SSHClient()
r = s.cmd('*','test.ping',ssh_priv=ssh_key,ssh_identities_only=True)
hosts = []
for host in r.keys():
  if r[host]['retcode'] == 10:
    ret = s.cmd(host, 'sudo cat /etc/*release|grep DISTRIB_ID',raw_shell=True,ssh_priv=ssh_key,ssh_identities_only=True)
    if ret[host]['stdout'] == 'DISTRIB_ID=Ubuntu\n':
      hosts.append(host)

ret = s.cmd(hosts,'sudo apt-get -y install python',expr_form='list',  raw_shell=True,ssh_priv=ssh_key,ssh_identities_only=True)

hosts = []
r = s.cmd('*','test.ping',ssh_priv=ssh_key,ssh_identities_only=True)
for host in r.keys():
  if r[host]['retcode'] == 0:
    hosts.append(host)

ret = s.cmd(hosts,'state.apply',['salt_minion'],expr_form='list', ssh_priv=ssh_key,ssh_identities_only=True)

import salt.config
import salt.wheel
o = salt.config.master_config('/etc/salt/master')
w = salt.wheel.WheelClient(o)

m = w.cmd('key.list',['all'])
if len(m['minions_pre']) > 0:
  for host in m['minions_pre']:
    w.cmd('key.accept',[host])
