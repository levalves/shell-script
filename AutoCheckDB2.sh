#!/bin/sh
#set -x
# ===========================================================================
# Licensed Materials - Property of Kyndryl
# "Restricted Materials of Kyndryl"
# 
# Kyndryl ITM 
# (C) Copyright Kyndryl Corp. 2020. All Rights Reserved
# ===========================================================================
# Title           : AutoCheckDB2.sh
# Description     : Collect information about DB2
# Author          : levalves@br.ibm.com
# Date            : 2022-Jul-07
# Version         : 1.1
# ===========================================================================
CANDLEHOME=`find / -name kuddb2 | cut -d"/" -f1-4 | grep -v APM`
LOGS=$CANDLEHOME/logs
ps -ef| grep db2sysc | grep -v grep | awk '{print $1}' | sort > $LOGS/DB2User.log
DB2User=`paste -s -d "|" $LOGS/DB2User.log`
OS=`uname`

levinux() {
  echo "-------------------------------------------------------------------------------"
  echo "                    _                 _"
  echo "                   | |     _____   __(_)_ __  _   ___  __"
  echo "                   | |    / _ \ \ / /| | '_ \| | | \ \/ /"
  echo "                   | |___|  __/\ V / | | | | | |_| |>  <"
  echo "                   |_____|\___| \_/  |_|_| |_|\__,_/_/\_\\"
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo ""
  sleep 5
}

CheckCandleHome() {
  DB2UsrGroup=`cat /etc/passwd|grep -E "$DB2User" | awk -F: '{print $4}' | uniq`
  DB2Group=`cat /etc/group | grep "$DB2UsrGroup" | awk -F: '{print $1}'`
  #DB2Group=`cat /etc/group | grep -E "$DB2User" | grep -v grep | cut -d":" -f1 | tail -1`
  chown -R root:$DB2Group $CANDLEHOME
  echo "Executando comando..."
  echo "chmod -R root:$DB2Group $CANDLEHOME"
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo ""
  chmod -R 775 $CANDLEHOME
  echo "Executando comando..."
  echo "chmod -R 775 $CANDLEHOME"
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo ""

}

CheckITM() {
  ProcessITM=`ps -ef|grep -i kuddb2 | grep -v grep | awk '{print $8}' | cut -d"/" -f8 | head -1`
  if [ $ProcessITM = kuddb2 ]; then
     echo "Processos ITM kuddb2 ----> RUNNING"
     echo ""
     ps -ef|grep -i kuddb2 | grep -v grep
     echo ""
     echo "-------------------------------------------------------------------------------"
     echo ""
     cp $CANDLEHOME/config/kcirunas.cfg $CANDLEHOME/config/kcirunas.cfg.bkp
     cp $CANDLEHOME/config/kcirunas.cfg $LOGS/kcirunas.cfg.bkp
     cat $LOGS/kcirunas.cfg.bkp | sed '/\/agent/d' > $LOGS/kcirunas.cfg
  else
    echo "Processos ITM kuddb2 ----> NOT RUNNING"
  fi
}

CheckDb2Up() {
  ProcessDB21=`ps -ef | grep db2wdog | egrep -v grep | awk '{print $8}' | head -1`
  ProcessDB22=`ps -ef | grep db2wdog | egrep -v grep | awk '{print $9}' | head -1`
  if [ $ProcessDB21 = db2wdog -o $ProcessDB22 = db2wdog ]; then
    if [[ "$OS" = "Linux" ]]; then
      ps -ef | grep db2wdog | egrep -v grep | awk '{print $10}'  | cut -d"[" -f2  | cut -d"]" -f1 | sort > $LOGS/DB2Instance.log
    else
      ps -ef | grep db2wdog | egrep -v grep | awk '{print $11}'  | cut -d"[" -f2  | cut -d"]" -f1 | sort > $LOGS/DB2Instance.log
    fi
    echo "Processos DB2 ----> RUNNING"
    echo ""
    ps -ef | grep db2wdog | egrep -v grep
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo ""
    CheckCandleHome
  else
    echo "Processos DB2 ----> NOT RUNNING"
  fi
}

GeraCfg() {
  echo "Gerando arquivo .cfg ----> $CANDLEHOME/config/kcirunas.cfg"
  paste $LOGS/DB2Instance.log $LOGS/DB2User.log > $LOGS/UserInstance.log
  echo "  <productCode>ud</productCode>" >> $LOGS/kcirunas.cfg
  cat $LOGS/UserInstance.log | while read name user
    do
      echo "  <instance>" >> $LOGS/kcirunas.cfg
      echo "    <name>$name</name>" >> $LOGS/kcirunas.cfg
      echo "    <user>$user</user>">> $LOGS/kcirunas.cfg 
      echo "  </instance>" >> $LOGS/kcirunas.cfg
   done
  echo "" >> $LOGS/kcirunas.cfg
  echo " </agent>" >> $LOGS/kcirunas.cfg
  cp $LOGS/kcirunas.cfg $CANDLEHOME/config/
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo ""
    echo "Executando comando..."
    echo "$CANDLEHOME/bin/AutoRunAgents.sh -h $CANDLEHOME"
    $CANDLEHOME/bin/AutoRunAgents.sh -h $CANDLEHOME
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo ""
}

Stop () {
  echo "Parando Agent ITM DB2, aguarde..."
  echo ""
  cat $LOGS/UserInstance.log | while read user instance
    do
      /usr/bin/su - root -c "/bin/ksh -c '/opt/IBM/ITM/bin/itmcmd agent -o $instance -f stop ud'"
    done
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo ""
} 

Start () {
  echo "Iniciando Agent ITM DB2, aguarde..."
  echo ""
  cat $LOGS/UserInstance.log | while read user instance
    do
      /usr/bin/su - $user -c "/bin/ksh -c '/opt/IBM/ITM/bin/itmcmd agent -o $instance -f start ud'"
    done
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo ""
} 

Status () {
  echo "Status Instancia DB2"
  $CANDLEHOME/bin/cinfo -r
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo ""
}

#### MAIN ####
levinux
CheckITM
CheckDb2Up
GeraCfg
Stop
Start
Status
