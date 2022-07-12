#!/bin/ksh
#set -x
# ===========================================================================
# Licensed Materials - Property of Kyndryl
# "Restricted Materials of Kyndryl"
# 
# Kyndryl Automation
# (C) Copyright Kyndryl Corp. 2020. All Rights Reserved
# ===========================================================================
# Title           : QueueWPMonitor.sh
# Description     : Monitor Queue Work Process SAP
# Author          : levalves@br.ibm.com
# Date            : 2021-Dec-17
# Version         : 1.5
# ===========================================================================
CANDLE_HOME=/opt/IBM/ITM
SAP_USER=`ps -ef | grep -iE "ms.sap|dw.sap" | egrep -v grep | awk '{print $1}' | head -1`
OS=`uname`

     if [[ "$OS" = "Linux" ]]; then
        SAPNR=`ps -ef | grep dw.sap | egrep -v grep | head -1 | cut -d"." -f2 | awk '{print $1}' | rev | cut -c1-2 | rev`
        /usr/bin/su - $SAP_USER -c "sapcontrol -nr $SAPNR -function GetQueueStatistic" | awk '{print $1,$2}' | grep "/" > "${CANDLE_HOME}/logs/QueueWPsap.out"
        cat ${CANDLE_HOME}/logs/QueueWPsap.out | while read li
          do
            SAP_WP=`echo $li | cut -d"," -f2 | cut -d"," -f2`
            if [ "${SAP_WP}" -gt 500 ]; then        
              SAP_WP_RC="1"
              SAP_DESC_ERRO=$li
              echo "$SAP_WP_RC|$SAP_DESC_ERRO"
            else
              SAP_WP_RC="0"
              SAP_DESC_ERRO=$li
              echo "$SAP_WP_RC|$SAP_DESC_ERRO"
            fi
          done
     else
        SAPNR=`ps -ef | grep dw.sap | egrep -v grep | head -1 | cut -d"." -f2 | awk '{print $1}' | rev | cut -c1-2 | rev`
        /usr/bin/su - $SAP_USER -c "sapcontrol -nr $SAPNR -function GetQueueStatistic" | awk '{print $1,$2}' | grep "/" > "${CANDLE_HOME}/logs/QueueWPsap.out"
        cat ${CANDLE_HOME}/logs/QueueWPsap.out | while read li
          do
            SAP_WP=`echo $li | cut -d"," -f2 | cut -d"," -f2 | awk '{print $1}'`
            if [ "${SAP_WP}" -gt 500 ]; then
              SAP_WP_RC="1"
              SAP_DESC_ERRO=$li
              echo "$SAP_WP_RC|$SAP_DESC_ERRO"
            else
              SAP_WP_RC="0"
              SAP_DESC_ERRO=$li
              echo "$SAP_WP_RC|$SAP_DESC_ERRO"
            fi
          done
     fi
