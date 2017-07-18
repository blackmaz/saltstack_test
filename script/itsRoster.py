#!/usr/bin/python
# -*- coding: utf-8 -*-
import yaml
import sys
import getopt

from itsSitePillar import physicalServer

roster_file= "/etc/salt/roster"
company_cd=''
system_cd=''
cmd_type='add'

#yaml 파일을 읽어서 Dic 형태로 보관하고 있으면서, 항목을 추가하거나 업데이트 한다.
class yamlFile:
    yamlFileDic = ''
    yamlFileNm = ''
    chgHost = []
    addHost = []
    delHost = []
    extHost = []
    uchgHost = []
    chgFile = False

    # 생성자
    def __init__(self, filename):
        self.yamlFileDic = self.readFile(filename)
        self.yamlFileNm = filename

    # yaml 파일을 읽어서 Dic에 저장한다. 
    def readFile(self, fileName):
        try:
            yamlFileDic = yaml.load(open(fileName, 'r'))
            if yamlFileDic == None:
                yamlFileDic = {}
        except:
            yamlFileDic = {}
        self.chgFile = False
        return yamlFileDic

    # 저장된 Dic을 yaml 파일로 출력한다. 
    def writeFile(self):
        if self.chgFile:
            with open(self.yamlFileNm, 'w') as outfile:
                yaml.dump(self.yamlFileDic, outfile, default_flow_style=False)
            self.chgFile = False

    # 저장된 Dic을 출력한다. 
    def printFile(self):
        print self.yamlFileDic

    # 저장된 Dic에 Dic을 추가한다. 이때 키가 중복되는 것은 건너뛴다. 
    def addDic(self, key, val):
        if key not in self.yamlFileDic:
            self.yamlFileDic[key] = val
            self.chgFile = True
            return True
        else:
            return False

    # 저장된 Dic에 Dic을 찾아서 업데이트 한다. 키가 없는 것은 건너뛴다. 
    def chgDic(self, key, val):
        if key in self.yamlFileDic:
            self.yamlFileDic[key] = val
            self.chgFile = True
            return True
        else:
            return False

    # 저장된 Dic에 Dic을 찾아서 삭제한다.
    def delDic(self, key):
        if key in self.yamlFileDic:
            del self.yamlFileDic[key]
            self.chgFile = True
            return True
        else:
            return False

    # 동일한 key에 대해서 value를 비교해서 동일한지 여부를 리턴함
    def cmpDic(self, key, val):
        if key in self.yamlFileDic:
            if self.yamlFileDic[key] == val:
                return "exist"
            else:
                return "change"
        else:
            return "add"

    # Roster 파일에 특정 오퍼레이션을 한다 (add or change)
    # add : 새로운 host정보만 추가함
    # change : 새로운 host정보를 추가하고 변경된 정보는 update함
    def opFile(self, dicData, op="add"):
        for key, val in dicData.items():
            e = self.cmpDic(key, val)
            if e == "exist":
               self.extHost.append(key)
            elif e == "change":
               if op == "change":
                   self.chgDic(key, val)
                   self.chgHost.append(key)
               else:
                   self.uchgHost.append(key)
            elif e == "add":
               self.addDic(key, val)
               self.addHost.append(key)
            else:
               print "error"
          
        print "added Host : " + ",".join(self.addHost)
        print "changed Host : " + ",".join(self.chgHost)
        print "unchanged Host : " + ",".join(self.uchgHost)
        print "exist Host : " + ",".join(self.extHost)


def itsMkRoster(company_cd, system_cd, cmd_type="add"):
    # pillar에 정의된 physical server 정보를 읽어 온다.
    p = physicalServer(company_cd, system_cd)

    # physical server 정보를 roster 형태로 변환한다. 
    r = p.listRoster()

    # roster 파일을 읽어서 pillar에서 생성한 정보를 추가한다. 
    y = yamlFile(roster_file)
    y.opFile(r, cmd_type)
    y.writeFile()
    #y.opFile('del', roster_file, r)

# 옵션을 주지 않고 실행했을때 도움말 표시후 중단한다.
def help():
    print "mkRoster.py -c company -s system [-t add|change]"
    return

# 옵션을 파싱해서 글로벌 변수에 담는다.
def option():
    # 함수 밖에서 참조 할수있도록 글로벌로 선언해 준다.
    global company_cd
    global system_cd
    global cmd_type

    if(len(sys.argv) is 1) and ((company_cd == '')):
        help()
        sys.exit(1)
    try:
        options, args =  getopt.getopt(sys.argv[1:], "c:s:t:h", ["company=","system=","cmd-type=","help"])
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
        elif (opt == '-t') or (opt == '--cmd-type'):
            cmd_type = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    # 필수 항목이 입력되었는지 검사한다.
    if (company_cd == '' or system_cd == ''):
        help()
        sys.exit(1)

    return

if __name__ == "__main__":
    option()
    itsMkRoster(company_cd, system_cd, cmd_type)


