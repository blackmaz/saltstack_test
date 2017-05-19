#!/usr/bin/python
# -*- coding: utf-8 -*-
import yaml
import sys
import getopt

from itsSitePillar import physicalServer

roster_file= "/etc/salt/roster"
company_cd=''
system_cd=''

#yaml 파일을 읽어서 Dic 형태로 보관하고 있으면서, 항목을 추가하거나 업데이트 한다.
class yamlFile:
    yamlFileDic = ''
    chgFile = False

    # yaml 파일을 읽어서 Dic에 저장한다. 
    def readFile(self, fileName):
        try:
            self.yamlFileDic = yaml.load(open(fileName, 'r'))
            if self.yamlFileDic == None:
                self.yamlFileDic = {}
        except:
            self.yamlFileDic = {}
        self.chgFile = False

    # 저장된 Dic을 출력한다. 
    def printFile(self):
        print self.yamlFileDic

    # 저장된 Dic에 Dic을 추가한다. 이때 키가 중복되는 것은 건너뛴다. 
    def addDic(self, addDicData):
        for key, val in addDicData.items():
            if key not in self.yamlFileDic:
                self.yamlFileDic[key] = val
                self.chgFile = True
        return True

    # 저장된 Dic에 Dic을 찾아서 업데이트 한다. 키가 없는 것은 건너뛴다. 
    def updateDic(self):
        return False

    # 저장된 Dic에 Dic을 찾아서 삭제한다.
    def deleteDic(self):
        return False

    # 저장된 Dic을 파일로 출력한다. 
    def writeFile(self, fileName):
        if self.chgFile:
            with open(fileName, 'w') as outfile:
                yaml.dump(self.yamlFileDic, outfile, default_flow_style=False)
            self.chgFile = False

    # 특정 파일에 오퍼레이션을 한다
    def opFile(self, op, fileName, dicData):
        if op == 'add':
            self.readFile(fileName)        
            self.addDic(dicData)
            self.writeFile(roster_file)
            return True
        else:
            return False

def itsMkRoster(company_cd, system_cd):
    # pillar에 정의된 physical server 정보를 읽어 온다.
    p = physicalServer(company_cd, system_cd)

    # physical server 정보를 roster 형태로 변환한다. 
    r = p.listRoster()

    # roster 파일을 읽어서 pillar에서 생성한 정보를 추가한다. 
    y = yamlFile()
    y.opFile('add', roster_file, r)

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

if __name__ == "__main__":
    option()
    itsMkRoster(company_cd, system_cd)


