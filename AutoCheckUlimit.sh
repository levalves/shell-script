#!/bin/ksh
#set -x
# ===========================================================================
# Licensed Materials - Property of IBM
# "Restricted Materials of IBM"
# 
# IBM ITM 
# (C) Copyright IBM Corp. 2020. All Rights Reserved
# ===========================================================================
# Title           : QueueWPMonitor.sh
# Description     : Monitor Queue Work Process SAP
# Author          : levalves@br.ibm.com
# Date            : 2021-Sep-03
# Version         : 1.0
# ===========================================================================
CANDLE_HOME=/opt/IBM/ITM
ULIMIT=`ulimit -a | grep "max user processes" | awk '{print $5}'`
OS=`uname`
THRESHOLD="127000"

if [[ "$OS" = Linux ]]; then
    if [ "${ULIMIT}" -gt "${THRESHOLD}" ]; then        
        ULIMIT_RC="1"
    	ULIMIT_ERRO="ulimit - max user processes ${THRESHOLD} != ${ULIMIT}"
        echo "$ULIMIT_RC|$ULIMIT_ERRO"
    else
        ULIMIT_RC="0"
        ULIMIT_ERRO="ulimit - max user processes OK"
        echo "$ULIMIT_RC|$ULIMIT_ERRO"
    fi
else #UNIX/AIX
    if [ "${ULIMIT}" -gt "${THRESHOLD}" ]; then
        ULIMIT_RC="1"
        ULIMIT_ERRO="ulimit - max user processes ${THRESHOLD} != ${ULIMIT}"
        echo "$ULIMIT_RC|$ULIMIT_ERRO"
    else
        ULIMIT_RC="0"
        ULIMIT_ERRO="ulimit - max user processes OK"
        echo "$ULIMIT_RC|$ULIMIT_ERRO"
    fi
fi