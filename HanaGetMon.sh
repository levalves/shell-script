#!/bin/ksh
#set -x
# ===========================================================================
# Licensed Materials - Property of Kyndryl
# "Restricted Materials of Kyndryl"
# 
# Kyndryl
# (C) Copyright Kyndryl Corp. 2021. All Rights Reserved
# ===========================================================================
# Title           : HanaGetMon.sh
# Description     : Monitor Hana DB
# Author          : levi.leopoldino.alves@kyndryl.com
# Date            : 2021-Dec-16
# Version         : 1.4
# ===========================================================================
CANDLE_HOME=/opt/IBM/ITM
USR_SAP=/usr/sap
USR_EXCLUDE="root"

ls -ltr /usr/sap/ | awk '{print $9}' | egrep -v '[A-Z]{4}' | egrep '[A-Z]' | awk '{print $1}' | grep -Ev "$USR_EXCLUDE" | egrep -v "grep" > $CANDLE_HOME/logs/SIDADM.out
  for SIDADM in `cat $CANDLE_HOME/logs/SIDADM.out`
    do
      ls -ltr $USR_SAP/$SIDADM | awk '{print $3,$9}' | grep HDB > $CANDLE_HOME/logs/USR_SN.out
      cat $CANDLE_HOME/logs/USR_SN.out | while read USR SN
        do
          SNumber=`echo $SN | rev | cut -c 1-2 | rev `
          /usr/bin/su - $USR -c "sapcontrol -nr $SNumber -function GetProcessList | grep -A 10 "description" | grep -v "description" | grep -v "running"" > "${CANDLE_HOME}/logs/GetProcessList.out"
              cat ${CANDLE_HOME}/logs/GetProcessList.out | while read li
              do
                SAP_STATE=`echo $li | cut -d"," -f4 | awk '{print $1}'`
                if [ "$SAP_STATE" == "Running" ]; then
                  SAP_WP_RC="0"
                  SAP_DESC_ERRO=$li
                  echo "$SAP_WP_RC|Instance Number: $SNumber - $SAP_DESC_ERRO"
                else
                  SAP_WP_RC="1"
                  SAP_DESC_ERRO=$li
                  echo "$SAP_WP_RC|Instance Number: $SNumber - $SAP_DESC_ERRO"
                fi
              done
         done
    done