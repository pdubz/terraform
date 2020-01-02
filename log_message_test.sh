#!/bin/bash

#Create a function to log errors/warnings/info.
#Stores log file named LOG_FILE_NAME in LOG_DIRECTORY
LOG_DIRECTORY="/var/log/"
LOG_FILE_NAME="test.log"
LOG_FILE="${LOG_DIRECTORY}${LOG_FILE_NAME}"

log_message() {
    DATE="[$(date '+%Y-%m-%d %H:%M:%S')]"

    if [[ "$1" == "e" ]]; then
        MESSAGE="${DATE} [ERROR] ${2}"
    elif [[ "$1" == "w" ]]; then
        MESSAGE="${DATE} [WARNING] ${2}"
    else
        MESSAGE="${DATE} [INFO] ${2}"
    fi

    if [ ! -d $LOG_DIRECTORY ]; then
        echo "Log Directory ($LOG_DIRECTORY) does not exist, creating directory."
        mkdir ${LOG_DIRECTORY}
    fi

    if [ ! -f $LOG_FILE ]; then
        touch $LOG_FILE
    fi

    echo -e $MESSAGE | tee -a $LOG_FILE
}

log_message "e" "This is an error."

log_message "w" "This is a warning."

log_message "i" "This is info."