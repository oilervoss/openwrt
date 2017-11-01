#!/bin/ash

TRANSMISSION_REMOTE='/usr/bin/transmission-remote'

# Below is a command that will generate a tracker
# list with one tracker per line
# i.e. cat /some/path/trackers.txt for a static list

LIVE_TRACKERS_LIST_CMD='curl -s --url https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt' 

TORRENTS=`$TRANSMISSION_REMOTE -l 2>/dev/null`
PARAMETER=$1

if [ $? -ne 0 ]; then
    echo -e "\n\e[0;91;1mFail on transmission. Aborting.\n\e[0m"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo -e "\n\e[31mThis script expects one parameter\e[0m"
    echo -e "\e[0;36maddtracker \t\t- list current torrents "
    echo -e "addtracker \$number\t- add trackers to torrent of number \$number"
    echo -e "addtracker \$name\t- add trackers to first torrent with part of name \$name"	
    echo -e "\n\e[0;32;1mCurrent torrents:\e[0;32m"
    echo "$TORRENTS" | sed -n 's/\(^.\{4\}\).\{64\}/\1/p'
    echo -e "\n\e[0m"
    exit 1
fi

# return number by searching  
# transmission-remote -l | grep -i "Blueray" | sed -n 's/ *\([0-9]\+\).*/\1/p'


if [ "${PARAMETER//[0-9]}" != "" ] ; then
	PARAMETER=`echo "$TORRENTS" | grep -i "$PARAMETER" | sed -n 's/\([0-9]\+\).*/\1/p'`

	if [ "${PARAMETER//[ ]}" != "" -a "${PARAMETER//[0-9 ]}" = "" ] ; then
		echo -e "\n\e[0;32;1mI found the following torrent:\e[0;32m"
		echo "$TORRENTS" | sed -n 's/\(^.\{4\}\).\{64\}/\1/p' | grep -i "$1"
	fi

fi

NUMBERCHECK=`echo "$TORRENTS" | sed -n '1d;s/\(^.\{4\}\).*/\1/;/Sum/!p'|grep "$PARAMETER"`

if [ "${PARAMETER//[0-9 ]}" != "" -o "${NUMBERCHECK//[ ]}" = "" ] ; then
	echo -e "\n\e[0;31;1mI didn't find a torrent with text/number: \e[21m$1"
        echo -e "\n\e[0;32;1mCurrent torrents:\e[0;32m"
	echo "$TORRENTS" | sed -n 's/\(^.\{4\}\).\{64\}/\1/p' 
	echo -e "\e[0m"
	exit 1
fi

echo 

$LIVE_TRACKERS_LIST_CMD | while read TRACKER
do
	if [ "$TRACKER" != "" ]; then
		echo -ne "\e[0;36;1mAdding $TRACKER\e[0;36m"
		$TRANSMISSION_REMOTE -t $TORRENTS -td $TRACKER 1>/dev/null 2>&1 
		if [ $? -eq 0 ]; then
			echo -e " -> \e[32mSuccess! "
		else
			echo -e " - \e[31m< Failed > "
		fi
	fi
done
echo -e "\e[0m"
