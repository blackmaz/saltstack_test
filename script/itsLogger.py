#!/usr/bin/python
# -*- coding: utf-8 -*-

import logging
import logging.handlers

class itsLogger:
    # DEBUG    (D)디버깅용 로그
    # INFO     (I)도움이 되는 정보
    # WARNING  (W)주의 표시
    # ERROR    (E)에러, 프로그램 종료
    # CRITICAL (C)심각한 에러, 프로그램 비정상종료

    logger = ''
    streamHandler = ''
    formatStr = '[%(levelname)-8s] %(asctime)s > %(message)s'

    def __init__(self):
        # 로거 인스턴스를 만든다
        self.logger = logging.getLogger()
        # 포매터를 만든다
        #fomatter = logging.Formatter(self.formatStr)
        # 스트림과 파일로 로그를 출력하는 핸들러를 각각 만든다.
        #fileHandler = logging.FileHandler('./myLoggerTest.log')
        self.streamHandler = logging.StreamHandler()

        self.setFormatStr(self.formatStr)

        # 각 핸들러에 포매터를 지정한다.
        #fileHandler.setFormatter(fomatter)
        #streamHandler.setFormatter(fomatter)
        # 로거 인스턴스에 스트림 핸들러와 파일핸들러를 붙인다.
        #logger.addHandler(fileHandler)
        #logger.addHandler(streamHandler)

    def setFormatStr(self, newFormatStr):
        #self.formatStr = newFormatStr
        fomatter = logging.Formatter(newFormatStr)
        self.streamHandler.setFormatter(fomatter)
        self.logger.addHandler(self.streamHandler)

    def addFileHandler(self, logFileName):
        self.fileHandler = logging.FileHandler(logFileName)

    def addStreamHandler(self):
        self.streamHandler = logging.StreamHandler()

    def writeLog(self, logLevel, msg):
        if   logLevel.upper() == "DEBUG"    or logLevel == "D":
            self.logger.debug(msg)
        elif logLevel.upper() == "INFO"     or logLevel == "I":
            self.logger.info(msg)
        elif logLevel.upper() == "WARNING"  or logLevel == "W":
            self.logger.warning(msg)
        elif logLevel.upper() == "ERROR"    or logLevel == "E":
            self.logger.error(msg)
        elif logLevel.upper() == "CRITICAL" or logLevel == "C":
            self.logger.critical(msg)
        else:
            self.logger.warning(msg)

    def setLogLevel(self, logLevel="WARNING"):
        if   logLevel.upper() == "DEBUG"    or logLevel == "D":
            self.logger.setLevel(logging.DEBUG)
        elif logLevel.upper() == "INFO"     or logLevel == "I":
            self.logger.setLevel(logging.INFO)
        elif logLevel.upper() == "WARNING"  or logLevel == "W":
            self.logger.setLevel(logging.WARNING)
        elif logLevel.upper() == "ERROR"    or logLevel == "E":
            self.logger.setLevel(logging.ERROR)
        elif logLevel.upper() == "CRITICAL" or logLevel == "C":
            self.logger.setLevel(logging.CRITICAL)
        else:
            self.logger.setLevel(logging.WARNING)


if __name__ == "__main__":
    logger = itsLogger()
    logger.setLogLevel("DEBUG")
    logger.writeLog("DEBUG", "디버깅용 로그")
    logger.writeLog("INFO", "도움이 되는 정보")
    logger.writeLog("WARNING", "주의 표시")
    logger.writeLog("ERROR", "에러, 프로그램 종료")
    logger.writeLog("CRITICAL", "심각한 에러, 프로그램 비정상종료")
    #logger.setLogLevel()
    logger.writeLog("D", "디버깅용 로그")
    logger.writeLog("I", "도움이 되는 정보")
    logger.writeLog("W", "주의 표시")
    logger.writeLog("E", "에러, 프로그램 종료")
    logger.writeLog("C", "심각한 에러, 프로그램 비정상종료")
    logger.setFormatStr('[%(levelname)-8s]>%(message)s')
    logger.writeLog("D", "디버깅용 로그")
    logger.writeLog("I", "도움이 되는 정보")
    logger.writeLog("W", "주의 표시")
    logger.writeLog("E", "에러, 프로그램 종료")
    logger.writeLog("C", "심각한 에러, 프로그램 비정상종료")
