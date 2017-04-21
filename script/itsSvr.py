#!/usr/bin/python
# -*- coding: utf-8 -*-
import salt.client
import yaml
import sys
import getopt
import pprint
import yaml
from collections import OrderedDict

# Dictionary에 데이터를 순서에 맞게 입력해줌
# 인터넷에서 주워와서 어떻게 동작하는지는 잘 모름
def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    class OrderedLoader(Loader):
        pass
    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)
    return yaml.load(stream, OrderedLoader)


input_file=''
company_cd=''
system_cd=''

# 옵션을 주지 않고 실행했을때 도움말 표시후 중단한다.
def help():
    print "python statetest.py -i site_config_file -c company -s system"
    return

# 옵션을 파싱해서 글로벌 변수에 담는다.
def option():
    # 함수 밖에서 참조 할수있도록 글로벌로 선언해 준다.
    global input_file
    global company_cd
    global system_cd

    if(len(sys.argv) is 1) and ((company_cd == '')):
        help()
        sys.exit(1)
    try:
        options, args =  getopt.getopt(sys.argv[1:], "i:c:s:h", ["input=","company=","system=","help"])
    except getopt.GetoptError as err:
        print str(err)
        help()
        sys.exit(1)

    # 옵션에 따라서 변수에 값을 담아준다.
    for opt, arg in options:
        if (opt == '-i') or (opt == '--input'):
            input_file = arg
        elif (opt == '-c') or (opt == '--company'):
            company_cd = arg
        elif (opt == '-s') or (opt == '--system'):
            system_cd = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    # 필수 항목이 입력되었는지 검사한다.
    if (input_file == '' or company_cd == '' or system_cd == ''):
        help()
        sys.exit(1)

    return

# 로그 출력 함수
def printLog(ret):
    for server, server_ret in ret.items():
        #print server
        for command, command_ret in server_ret.items():
            #print command_ret
            prt = {}
            for key, val in command_ret.items():
                prt[val["__run_num__"]] = { "name": val.get("name","") , "comment": val.get("comment",""), "result": val.get("result","")}

            for key, val in prt.items():
                print val


option()

# 사이트 정의 파일을 읽어들인다.
print input_file
try:
    f = open(input_file, 'r')
except IOError as err:
    print str(err)
    sys.exit(1)

# 사이트 정의 파일을 순서 보장되는 딕셔너리에 담고
# 입력받은 회사코드와 시스템 코드 하위의 정보를
# 각각의 딕셔너리에 담아준다.
cfg = ordered_load(f, yaml.SafeLoader)
#cfg = yaml.load(f)

company = cfg.get(company_cd)
system = company.get(system_cd)

pSvrs = system.get('physical server')
lSvrs = system.get('logical server')
sws = system.get('software')

cmd_list = ['state.apply']
# 정의되지 않은 필라를 런타임에 전달하기 위한 문자열을 만들어 준다.
# 모든 sls는 회사코드와 시스템코드를 전달받도록 작성되어야 한다.
runtime_pillar='pillar={"company": "'+company_cd+'", "system": "'+system_cd+'"}'

local = salt.client.LocalClient()

# 정의된 소프트웨어를 한땀한땀 수행해 주는 역할을 한다.
for id, sw in sws.items():
    lSvr = sw.get('deploy server','')
    # sw에 설치 대상 서버가 정의되 않았을 때 처리
    # 다 체크해보고 정상일 경우만 실제 명령 수행하도록 변경
    if lSvr == '':
      print " error "
    host_list = []
    arg_list = [[id, runtime_pillar]]
    for pSvr in lSvrs.get(lSvr).get('physical server'):
        host_list.append(pSvrs.get(pSvr).get('hostname'))
    print "===================================================="
    print str(host_list) + str(cmd_list) + str(arg_list)
#    ret = local.cmd_iter(host_list, cmd_list, arg_list, expr_form='list',timeout=1800)
    ret = local.cmd(host_list, cmd_list, arg_list, expr_form='list',timeout=1800)
    print "===================================================="
    printLog(ret)
#    print ret
    #pprint.pprint(ret)
#    for r in ret:
#        print r[r.keys()[0]]['retcode']
#
# local.cmd_iter(hosts, cmds, [ args, 'pillar={"foo": "bar"}'], expr_form ~~)
# note : Loading companyCode, systemCode at run-time in pillar
# 'pillar={"company": "hwbc", "system": "ozr"}'
