#!/bin/ksh
#set -x
# ===========================================================================
# Licensed Materials - Property of IBM
# "Restricted Materials of IBM"
# 
# IBM ITM 
# (C) Copyright IBM Corp. 2020. All Rights Reserved
# ===========================================================================
# Title           : R3transdMonDB2_auto.ksh
# Description     : Collect information about hung state SAP / DB2 / ORACLE
# Author          : levalves@br.ibm.com
# Date            : 2021-Sep-03
# Version         : 1.1
# ===========================================================================
CANDLE_HOME=/opt/IBM/ITM
SAP_USER=`ps -ef | grep -i ms.sap | egrep -v grep | awk '{print $1}' | head -1`
DB2_SID=`ps -ef | grep db2logmgr | egrep -v grep | awk '{print $13}' | cut -d")" -f1 | cut -d"(" -f2 | head -1`
ORA_SID=`ps -ef | grep ora_pmon | egrep -v grep | awk '{print $8}' | cut -d"_" -f3 | head -1` 
ORACLE=`ps -ef | grep ora_pmon | egrep -v grep | awk '{print $8}' | cut -d"_" -f1-2 | head -1` 
DB2=`ps -ef| grep db2logmgr | grep -v grep | awk '{print $10}' | cut -d"(" -f2 | cut -d"." -f1 | head -1`
SAP_HOME=/home/$SAP_USER

if [[ "$OS" = "Linux" ]]; then
 STAT_SAP_WP=`ps -ef | grep dw.sap | egrep -v grep | wc -l`
  if [ "${STAT_SAP_WP}" -eq 0 ]; then
    SAP_STAT_RC="1"
    SAP_DESC_ERRO="Instance-Down"
    echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
  else
     if [[ -n $ORACLE ]]; then
        DB_SID=$ORA_SID
        /usr/bin/su - $SAP_USER -c "R3trans -d" > "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out"
        R3TRANS_RC=`cat "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out" | grep "R3trans finished" | grep "0000" | wc -l | awk '{print $1}'`
           if [ "$R3TRANS_RC" == 1 ] ; then
              SAP_STAT_RC="0"
	      SAP_DESC_ERRO=`cat "${SAP_HOME}/trans.log" | cut -d"]" -f2 | egrep "DB instance" | cut -d" " -f1-9` #Oracle
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           else
              SAP_STAT_RC="1"
              SAP_DESC_ERRO="R3trans -d: 2EETW169 no connect possible: DBMS = DB $DB_SID Instance-Down"
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           fi
     else
        [[ -n $DB2 ]]
        /usr/bin/su - $SAP_USER -c "R3trans -d" > "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out"
        R3TRANS_RC=`cat "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out" | grep "R3trans finished" | grep "0000" | wc -l | awk '{print $1}'`
           if [ "$R3TRANS_RC" == 1 ] ; then
              SAP_STAT_RC="0"
              SAP_DESC_ERRO="R3trans -d: SAP database is available $DB_SID Instance-Up"
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           else
              SAP_STAT_RC="1"
              SAP_DESC_ERRO="R3trans -d: 2EETW169 no connect possible: DBMS = DB $DB_SID Instance-Down"
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           fi
     fi
  fi
else
  ORA_SID=`ps -ef | grep ora_pmon | egrep -v grep | awk '{print $9}' | cut -d"_" -f3 | head -1` 
  ORACLE=`ps -ef | grep ora_pmon | egrep -v grep | awk '{print $9}' | cut -d"_" -f1-2 | head -1` 
  STAT_SAP_WP=`ps -ef | grep dw.sap | egrep -v grep | wc -l`
  if [ "${STAT_SAP_WP}" -eq 0 ]; then
    SAP_STAT_RC="1"
    SAP_DESC_ERRO="Instance-Down"
    echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
  else
     if [[ -n $ORACLE ]]; then
        DB_SID=$ORA_SID
        /usr/bin/su - $SAP_USER -c "R3trans -d" > "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out"
        R3TRANS_RC=`cat "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out" | grep "R3trans finished" | grep "0000" | wc -l | awk '{print $1}'`
           if [ "$R3TRANS_RC" == 1 ] ; then
              SAP_STAT_RC="0"
	      SAP_DESC_ERRO=`cat "${SAP_HOME}/trans.log" | cut -d"]" -f2 | egrep "DB instance" | cut -d" " -f1-9` #Oracle
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           else
              SAP_STAT_RC="1"
              SAP_DESC_ERRO="R3trans -d: 2EETW169 no connect possible: DBMS = DB $DB_SID Instance-Down"
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           fi
     else
        [[ -n $DB2 ]]
        /usr/bin/su - $SAP_USER -c "R3trans -d" > "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out"
        R3TRANS_RC=`cat "${CANDLE_HOME}/logs/rtransd_${DB_SID}.out" | grep "R3trans finished" | grep "0000" | wc -l | awk '{print $1}'`
           if [ "$R3TRANS_RC" == 1 ] ; then
              SAP_STAT_RC="0"
              SAP_DESC_ERRO="R3trans -d: SAP database is available $DB_SID Instance-Up"
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           else
              SAP_STAT_RC="1"
              SAP_DESC_ERRO="R3trans -d: 2EETW169 no connect possible: DBMS = DB $DB_SID Instance-Down"
              echo "$SAP_STAT_RC|$SAP_DESC_ERRO"
           fi
     fi
  fi
fi
