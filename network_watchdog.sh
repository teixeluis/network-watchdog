# !/bin/sh

# Round trip time threshold of the ping for considering
# networking to be degraded:

RTT_THRESHOLD=500

# List of destinations to analyze:

IP_LIST="192.168.2.1 192.168.1.30 192.168.1.23"
IP_LIST_SIZE=3

isDegraded () {
        ping -c 5 $1
        ping_res=$?

        # if the ping was successful, lets analyse the degradation:
        if [[ $ping_res -eq 0 ]];
        then
                min_ping=$(ping -c 5 $1| tail -1| awk '{print $4}' | cut -d '/' -f 1)

                logger "Got a minimum ping of " $min_ping " for destination " $1

                if [[ $(echo "$min_ping $RTT_THRESHOLD" | awk '{print ($1 > $2)}') -gt 0 ]];
                then
                        return 1
                fi

                return 0
        fi

    return 1
}

res=0

for ip in $IP_LIST
do
        isDegraded $ip

        res=$(($res + $?))
done

logger "Found " $res " degraded destinations."

if [[ $res -eq $IP_LIST_SIZE ]];
then
        logger "Going to reboot as networking subsystem seems to be broken."
        reboot
else
        logger "System seems to be OK"
fi
