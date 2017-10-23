#!/bin/ash

TRANSMISSION_REMOTE='/usr/bin/transmission-remote'

# Below is a command that will generate a tracker
# list with one tracker per line
# i.e. cat /some/path/trackers.txt for a static list

LIVE_TRACKERS_LIST_CMD='curl -s --url https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt' 


if [ $# -eq 0 ]; then
    echo "This script expects one parameter - the tracker id"
    echo "Use $TRANSMISSION_REMOTE -l to find it"
    $TRANSMISSION_REMOTE -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p'
    exit 1
fi

# return number by searching  
# transmission-remote -l | grep -i "Girls" | sed -n 's/ *\([0-9]\+\).*/\1/p'

INDEX=$1

if [ "${INDEX//[0-9]}" != "" ] ; then
	TORRENT=`$TRANSMISSION_REMOTE -l|grep -i $1`
	INDEX=`echo $TORRENT | sed -n 's/\([0-9]\+\).*/\1/p'`

	if [ "$INDEX" != "" ] ; then
		echo "I found the following torrent:"
		$TRANSMISSION_REMOTE -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p' | grep -i $1
	fi

fi

if [ "${INDEX//[0-9]}" != "" -o "$INDEX" = "" ] ; then
	echo "I didn't find a torrent with the text: $1"
	$TRANSMISSION_REMOTE -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p' 
	exit 1
fi

echo 

$LIVE_TRACKERS_LIST_CMD | while read TRACKER
do
	if [ "$TRACKER" != "" ]; then
		echo -n "Adding $TRACKER"
		$TRANSMISSION_REMOTE -t $INDEX -td $TRACKER 1>/dev/null 2>&1 
		if [ $? -eq 0 ]; then
			echo " --> Success! "
		else
			echo "  < Failed > "
		fi
	fi
done
