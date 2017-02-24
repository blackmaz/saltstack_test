#!/usr/bin/python
import salt.client.ssh.client
import sys
import getopt

def help():
  print "python itsInit.py -p private key"
  return

ssh_key = ''

def option():
  global ssh_key
  if len(sys.argv) is 1:
    help()
    sys.exit(1)
  try:
    options, args = getopt.getopt(sys.argv[1:], "p:h", ["priv=","help"])
  except getopt.GetoptError as err:
    print str(err)
    help()
    sys.exit(1)
    
  for opt, arg in options:
    if (opt == '-p') or (opt == '--priv'):
      ssh_key = arg
    elif (opt == '-h') or (opt == '--help'):
      help()
      sys.exit(1)
    return
    
#ssh_key='/home/ubuntu/aws/test_key_pair'
#ssh_key='/home/sungsic/.ssh/id_rsa'
option()

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

ret = s.cmd(hosts,'state.apply',['salt.minion'],expr_form='list', ssh_priv=ssh_key,ssh_identities_only=True)

import salt.config
import salt.wheel
o = salt.config.master_config('/etc/salt/master')
w = salt.wheel.WheelClient(o)

m = w.cmd('key.list',['all'])
if len(m['minions_pre']) > 0:
  for host in m['minions_pre']:
    w.cmd('key.accept',[host])
