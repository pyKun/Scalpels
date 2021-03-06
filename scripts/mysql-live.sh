#!/bin/bash
# Author: Kun Huang <academicgareth@gmail.com>
#
# Basic Usage: TODO
#
# TODO announce the advantage and disadvantages
#

log_file_var=general_log_file
log_switch_var=general_log
log_file=/tmp/mysqllive.log
old_log_file=`mysql -e "SELECT @@$log_file_var" | grep -v $log_file_var | grep -v '\-\-\-\-\-'`
old_log_switch=`mysql -e "SELECT @@$log_switch_var" | grep -v $log_switch_var | grep -v '\-\-\-\-\-'`

reset () {
    echo -------------------------------------
    echo reset $log_file_var to $old_log_file
    echo reset $log_switch_var to $old_log_switch
    mysql -e "SET GLOBAL $log_switch_var = $old_log_switch;"
    mysql -e "SET GLOBAL $log_file_var = '$old_log_file';"

    echo remove $log_file
    echo -------------------------------------
    sudo rm $log_file
}

trap "reset" SIGINT SIGTERM

echo -------------------------------------
echo reserve $log_file_var: $log_file
echo reserve $log_switch_var: ON
echo -------------------------------------

mysql -e "SET GLOBAL $log_file_var = '$log_file';"
mysql -e "SET GLOBAL $log_switch_var = ON;"

sleep 1
sudo chmod +r $log_file

# TODO use awk /reg/ statement instead
tailf $log_file | awk '{
if ( $1 + 0 != $1 )
    # TODO cat this line on its above line
    print $0;
else if ( $1 + 0 == $1 && $2 == "Query" && $3 == "SELECT" && $4 == "1" )
    ;
else if ( $1 + 0 == $1 && $2 == "Query" && $3 == "COMMIT" )
    ;
else if ( $1 + 0 == $1 && $2 == "Query" && $3 == "ROLLBACK" )
    ;
else
    # TODO flag to control empty line
    { $1=$2=""; print $0; print ""}
}
'
