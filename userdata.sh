#! /bin/bash

#---Helper Functions---

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

#---Script Begins---

log_message "i" "Starting User_Data Script"

#We want to confirm that remi is set up properly so we don't have to deal with it as a special case in the packages loop
#Start by checking is epel-release is installed, if it is, remi is probably installed, so remove it first.
log_message "i" "Checking epel-release status to see if remi needs to be removed and reinstalled"
is_installed=$(rpm -q epel-release)
log_message "i" $is_installed
if [[ "$is_installed" == "epel-release-7-12.noarch" ]]; then
    log_message "i" "epel-release is installed, removing..."
    yum remove epel-release -y
fi

log_message "i" "Installing remi-release-7.rpm and epel-release"
if yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm epel-release -y; then
    log_message "i" "remi-release-7.rpm and epel-release installed successfully, installing yum-utils"
    if yum install yum-utils -y; then
        log_message "i" "yum-utils installed successfully, enabling remi-php73 in yum config manager"
        yum-config-manager --enable remi-php73
    else
        log_message "e" "yum-utils failed to install, yum exit code: ${?}"
    fi    
else
    log_message "e" "Remi-release-7.rpm or epel-release did not install successfully, yum exit code: ${?}"
fi

#List of other packages that we need to install:
PACKAGES=(
    #Apache
    httpd

    #PHP
    php
)

#Loop through the packages, check if they are installed, if not, install them.
for package in ${PACKAGES[@]}; do
    log_message "i" "Starting package $package"
    is_installed=$(rpm -q $package)
    if [ ! "$is_installed" == "package $package is not installed" ]; then
        log_message "i" "Package $package was already installed, skipping"
    else
        if yum install $package -y; then
            log_message "i" "Successfully installed package $package"
        else
            log_message "e" "Failed to install package $package, yum exited with code: ${?}"
        fi
    fi
done

#Make sure everything is updated
yum update -y

#Enable Apache on boot, then start httpd
systemctl enable httpd
systemctl start httpd

#Put a really basic PHP file on the web server
echo -e "<html><body><h1>Hello, World! </h1><?php echo \"Some content here\";?></body></html>" | tee /var/www/html/index.php