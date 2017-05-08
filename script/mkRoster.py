#!/usr/bin/python
# -*- coding: utf-8 -*-
import yaml
import sys
import getopt
import salt.client
import salt.config

# salt-call을 이용해서 local pillar를 조회하기 위해 설정함
__opts__ = salt.config.minion_config('/etc/salt/minion')
__opts__['file_client'] = 'local'

#site_cfg   = "/srv/pillar/site_ozr.sls"
roster_file= "/etc/salt/roster"
#company_cd = "hwbc"
#system_cd  = "ozr"

company_cd=''
system_cd=''

# 옵션을 주지 않고 실행했을때 도움말 표시후 중단한다.
def help():
    print "mkRoster.py -c company -s system"
    return

# 옵션을 파싱해서 글로벌 변수에 담는다.
def option():
    # 함수 밖에서 참조 할수있도록 글로벌로 선언해 준다.
    global company_cd
    global system_cd

    if(len(sys.argv) is 1) and ((company_cd == '')):
        help()
        sys.exit(1)
    try:
        options, args =  getopt.getopt(sys.argv[1:], "c:s:h", ["company=","system=","help"])
    except getopt.GetoptError as err:
        print str(err)
        help()
        sys.exit(1)

    # 옵션에 따라서 변수에 값을 담아준다.
    for opt, arg in options:
        if (opt == '-c') or (opt == '--company'):
            company_cd = arg
        elif (opt == '-s') or (opt == '--system'):
            system_cd = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    # 필수 항목이 입력되었는지 검사한다.
    if (company_cd == '' or system_cd == ''):
        help()
        sys.exit(1)

    return

option()

# 사이트 정의 파일을 읽어들인다.
#try:
#    f = open(site_cfg, 'r')
#except IOError as err:
#    print str(err)
#    sys.exit(1)
#
#cfg = yaml.load(f)

# salt roster 파일을 읽어들인다.
try:
    r = open(roster_file, 'r')
except IOError as err:
    print str(err)
    sys.exit(1)

roster_dic = yaml.load(r)

# roster 파일에 아무런 내용이 없을 경우에는 변수를 dic으로 초기화 해준다.
if roster_dic == None :
  roster_dic = {}

# 서버 정보를 읽어 roster 파일의 형태로 dic에 쓴다.
#company = cfg.get(company_cd)
#system  = company.get(system_cd)
#add_servers = system.get("physical server")

# pillar에 정의된 physical server 정보를 읽어 온다.
caller = salt.client.Caller(mopts=__opts__)
add_servers = caller.cmd('pillar.get',company_cd+':'+system_cd+':physical server')
if add_servers == "":
  print "Can not find physical server in pillar"
  exit()

# roster file에 등록되지 않은 server를 파일에 추가한다.
# key가 중복되는 경우에는 추가하지 않는다.(덮어쓰거나 변경하지 않음)
for svr_id, svr in add_servers.items():
  hostname = svr.get("hostname")
  if (hostname in roster_dic) == False:
    ip = svr.get("ip")
    user = svr.get("user","root")
    if user != "root":
      sudo = True
    else:
      sudo = False
    roster_dic[hostname] = {"host": ip, "user": user , "sudo": sudo}
  else:
    print "opps!! This server is already registered. (" + hostname + ")"

#print roster_dic

# roster dic을 파일에 쓴다.
with open(roster_file, 'w') as outfile:
  yaml.dump(roster_dic, outfile, default_flow_style=False)

