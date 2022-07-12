#!/bin/sh
set -x
# ===========================================================================
# Licensed Materials - Property of Kyndryl
# "Restricted Materials of Kyndryl"
# 
# Kyndryl
# (C) Copyright Kyndryl Corp. 2021. All Rights Reserved
# ===========================================================================
# Script          : AutoPrereqZbxOra.sh
# Description     : Script pre-req
# Author          : levi.leopoldino.alves@kyndryl.com
# Date            : 2021-Dec-17
# Version         : 1.0
# ===========================================================================
NULL="YOU HAVE NEW MAIL"
CANDLEHOME=/opt/IBM/ITM
ORAUSER=`ps -ef|grep -i ora_smon | grep -v grep | awk '{print $1}'`
PATH=$PATH:/usr/local/bin
ORATAB=/etc/oratab
ZBXUSER=zabbix
ZBXTMP=/var/opt/zabbix/tmp
ZBXSQL=$CANDLEHOME/config/zbxgrant.sql

function FuncGeraEnv {
  cp $ORATAB $CANDLEHOME/logs/oratab.auto
  cat /etc/oratab | grep -v "^#" |grep -v "ASM" | grep -v "^$" |awk -F: '{print $1,$2}' > $CANDLEHOME/logs/oratab.auto
  mkdir -p ${ZBXTMP} && chown ${ZBXUSER}:${ZBXUSER} ${ZBXTMP}
}

function FuncGetSids {
  if [ ! -f $ORATAB ] ; then
    echo "$0: $ORATAB is misssing"
    exit 1
  else
    echo "${ORATAB} is OK"
  fi

  cat ${CANDLEHOME}/logs/oratab.auto | while read SID HOME
  do
    echo "Setando ORACLE_SID=${SID}"
    export ORACLE_SID=${SID}
    echo "Criando Usuuario e senha..."
    /usr/bin/su - ${ORAUSER} -c "sqlplus /nolog @${ZBXSQL} kynoramon ${ZBXTMP}" | grep -v "${NULL}"
  done
}
FuncGeraEnv
FuncGetSids
