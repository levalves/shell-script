#!/bin/ksh
#set -x
# ===========================================================================
# Licensed Materials - Property of Kyndryl
# "Restricted Materials of Kyndryl"
# 
# Kyndryl
# (C) Copyright Kyndryl Corp. 2021. All Rights Reserved
# ===========================================================================
# Title           : J2EEGetProcListMon.sh
# Description     : Monitor Java J2EE ABAP SAP
# Author          : levi.leopoldino.alves@kyndryl.com
# Date            : 2021-Oct-08
# Version         : 1.1
# ===========================================================================
CANDLE_HOME=/opt/IBM/ITM
NULL="YOU HAVE NEW MAIL"
USR_EXCLUDE="root"

OS=`uname`
     if [[ "$OS" = "Linux" ]]; then
        ls -ltr /usr/sap/ | awk '{print $3" "$9}' | egrep -v '[A-Z]{4}' | egrep '[A-Z]' | awk '{print $1}' | grep -Ev "$USR_EXCLUDE" | egrep -v "grep" | grep -v "$NULL" > $CANDLE_HOME/logs/SIDADM.out
        for SIDADM in `cat $CANDLE_HOME/logs/SIDADM.out`
          do
            /usr/bin/su - $SIDADM -c "startsap check" | grep "not running" | sort | uniq > $CANDLE_HOME/logs/notrun.out
            NOTRUN=`/usr/bin/su - $SIDADM -c "startsap check" | grep "not running" | sort | uniq | egrep "not running" | tail -c 13`
            if [ "$NOTRUN" == "not running " ]; then
              SAP_WP_RC="1"
              SAP_DESC_ERRO=`cat $CANDLE_HOME/logs/notrun.out`
              echo "$SAP_WP_RC|$SAP_DESC_ERRO"
            fi
              /usr/bin/su - $SIDADM -c "startsap check" | grep "Checking" | grep "Instance J" | awk '{print $5}' | egrep '[0-9]' | tail -c 3 | grep -v "$NULL" > $CANDLE_HOME/logs/SAPNR.out
              for SAPNR in `cat $CANDLE_HOME/logs/SAPNR.out`
                do
                  /usr/bin/su - $SIDADM -c "sapcontrol -nr $SAPNR -function J2EEGetProcessList | egrep -v debugproxy | grep "J2EE_" | cut -d"," -f1-2,4-5,7-8" | grep -v "$NULL" > "${CANDLE_HOME}/logs/J2EEGetProcessList.out"
                  cat ${CANDLE_HOME}/logs/J2EEGetProcessList.out | while read li
                    do
                        SAP_STATE=`echo $li | cut -d"," -f6 | awk '{print $1}'`
                        if [ "$SAP_STATE" == "Running" ]; then
                          SAP_WP_RC="0"
                          SAP_DESC_ERRO=$li
                          echo "$SAP_WP_RC|Instance Number:$SAPNR - $SAP_DESC_ERRO"
                        else
                          SAP_WP_RC="1"
                          SAP_DESC_ERRO=$li
                        echo "$SAP_WP_RC|Instance Number:$SAPNR - $SAP_DESC_ERRO"
                        fi
                      done
                 done
             done
     else
        ls -ltr /usr/sap/ | awk '{print $3" "$9}' | egrep -v '[A-Z]{4}' | egrep '[A-Z]' | awk '{print $1}' | grep -Ev "$USR_EXCLUDE" | egrep -v "grep" | grep -v "$NULL" > $CANDLE_HOME/logs/SIDADM.out
        for SIDADM in `cat $CANDLE_HOME/logs/SIDADM.out`
          do
            /usr/bin/su - $SIDADM -c "startsap check" | grep "not running" | sort | uniq | grep -v "$NULL" > $CANDLE_HOME/logs/notrun.out
            NOTRUN=`/usr/bin/su - $SIDADM -c "startsap check" | grep "not running" | sort | uniq | egrep "not running" | tail -c 13`
            if [ "$NOTRUN" == "not running " ]; then
              SAP_WP_RC="1"
              SAP_DESC_ERRO=`cat $CANDLE_HOME/logs/notrun.out`
              echo "$SAP_WP_RC|$SAP_DESC_ERRO"
            fi
              /usr/bin/su - $SIDADM -c "startsap check" | grep "Checking" | grep "Instance J" | awk '{print $5}' | egrep '[0-9]' | tail -c 3 | grep -v "$NULL" > $CANDLE_HOME/logs/SAPNR.out
              for SAPNR in `cat $CANDLE_HOME/logs/SAPNR.out`
                do
                  /usr/bin/su - $SIDADM -c "sapcontrol -nr $SAPNR -function J2EEGetProcessList | egrep -v debugproxy | grep "J2EE_" | cut -d"," -f1-2,4-5,7-8" | grep -v "$NULL" > "${CANDLE_HOME}/logs/J2EEGetProcessList.out"
                  cat ${CANDLE_HOME}/logs/J2EEGetProcessList.out | while read li
                    do
                      SAP_STATE=`echo $li | cut -d"," -f6 | awk '{print $1}'`
                        if [ "$SAP_STATE" == "Running" ]; then
                          SAP_WP_RC="0"
                          SAP_DESC_ERRO=$li
                          echo "$SAP_WP_RC|Instance Number:$SAPNR - $SAP_DESC_ERRO"
                        else
                          SAP_WP_RC="1"
                          SAP_DESC_ERRO=$li
                        echo "$SAP_WP_RC|Instance Number:$SAPNR - $SAP_DESC_ERRO"
                        fi
                      done
                 done
             done
     fi