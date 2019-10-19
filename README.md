# network-watchdog

## Description

Basic unix shell script for monitoring network destinations and restart hardware assuming systemic degradation

## Overview

In some devices, especially low cost routers, WiFi networking performance often times degrades in proportion to system uptime. This may have multiple causes, depending on the hardware/software combination in question.

One particular setup motivated the creation of this script. In my household network I wanted to avoid spending too much money in WiFi gear, while at the same time being able to consume from community supported software. I had a WiFi coverage problem which implied that I had to set up a WiFi device as a repeater in the middle of the house.

To solve this I purchased two TP-LINK TL-WR841N devices, where one would act as the typical NAT router with DHCP and DNS server/forwarding roles, and another one being assigned the role of WiFi repeater, using the WDS method.

Initially the stock firmware was used, but as reliability and the need for further features became obvious, I flashed the devices with OpenWRT. Given the hardware limitations of these devices (4 MB of Flash and 32 MB of RAM), the sweet spot between features and stability, was using version 15.05.1.

The devices work correctly and the firmware performs quite well in this version, but I found that after a few days of operation and depending on network usage, both the router and the repeater get to a point where the network performance drops dramatically. CPU and memory is not the problem, as during degradation it is possible to patiently open an ssh session and monitor these (e.g. using "top" and "free" commands) and confirm that these are nominal.

Once degradations sets in, it is no longer possible to recover, except by forcing the device restart.

With this in mind and after exhausting the research on corrective solutions, I decided to make a rather generic watchdog script that all it does is measure the ping to a list of destinations, and if none of the destinations is reachable or the minimum ping time is above a given threshold for all destinations, it restarts the device. This allows the impact to be minimized, and the need for manual intervention.

## Usage

In a typical setup this script can be added to the crontab for periodic execution. In this case we are running it every minute:

```
root@griffinnet-zh-router:~/scripts# crontab -l
* * * * * /root/scripts/network_watchdog.sh >/dev/null 2>&1
```

## Configuration

There are three relevant variables in the script that should be configured:

```
# Round trip time threshold of the ping for considering
# networking to be degraded:

RTT_THRESHOLD=500

# List of destinations to analyze:

IP_LIST="192.168.2.1 192.168.1.30 192.168.1.23"
IP_LIST_SIZE=3
```

The *RTT_THRESHOLD* parameter defines the time in milliseconds, above which we consider the minimum ping RTT to be typical of degraded connectivity.

The *IP_LIST* parameter defines the list of IP addresses that we want to observe, to determine if the connectivity is degraded on the router side or not. The list should contain destinations that are known to be permanently connected and stable.

The *IP_LIST_SIZE* defines the size of the list, and exists due to the inability of the ash interpreter to provide the length of arrays.



