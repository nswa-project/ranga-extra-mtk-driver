#!/bin/sh

ifconfig ra0 down
#rmmod rt2860v2_ap
insmod /lib/mtkdrv/rt2860v2_ap.ko

wrtname="radio0"
if uci get wireless.radio1 > /dev/null 2>&1; then
	wrtname="radio1"
fi

ssid=`uci get "wireless.default_${wrtname}.ssid"`
key=`uci get "wireless.default_${wrtname}.key"`
channel=`uci get "wireless.${wrtname}.channel"`
macaddr=`uci get "wireless.${wrtname}.macaddr"`
htmode=`uci get "wireless.${wrtname}.htmode"`
noscan=`uci get "wireless.${wrtname}.noscan"`
hidden=`uci get "wireless.default_${wrtname}.hidden"`
country=`uci get "wireless.${wrtname}.country"`
macfilter=`uci get "wireless.default_${wrtname}.macfilter"`
case "$macfilter" in
allow)
	ra_macfilter=1;
	;;
deny)
	ra_macfilter=2;
	;;
*)
	ra_macfilter=0;
	;;
esac
maclist=''
if [ "$ra_macfilter" != '0' ]; then
	maclist=`uci get "wireless.default_${wrtname}.maclist"`
	maclist="${maclist// /;};"
fi
auto='0'

if [ "$channel" = "" -o "$channel" = "auto" ]; then
	channel='11'
	auto='2'
fi

HT=0
HT_CE=1
[ "$htmode" = "HT40" ] && HT=1
[ "$noscan" = "1" ] && HT_CE=0

cat > /tmp/RT2860.dat <<EOF
#The word of "Default" must not be removed
Default
CountryRegion=0
CountryRegionABand=7
CountryCode=${country:-TW}
BssidNum=1
SSID1=${ssid}
WirelessMode=9
FixedTxMode=
TxRate=0
MacAddress=${macaddr}
Channel=${channel:-11}
BasicRate=15
BeaconPeriod=100
DtimPeriod=1
TxPower=100
DisableOLBC=0
BGProtection=0
TxAntenna=
RxAntenna=
TxPreamble=1
RTSThreshold=2347
FragThreshold=2346
TxBurst=1
PktAggregate=1
AutoProvisionEn=0
FreqDelta=0
TurboRate=0
WmmCapable=0
APAifsn=3;7;1;1
APCwmin=4;4;3;2
APCwmax=6;10;4;3
APTxop=0;0;94;47
APACM=0;0;0;0
BSSAifsn=3;7;2;2
BSSCwmin=4;4;3;2
BSSCwmax=10;10;4;3
BSSTxop=0;0;94;47
BSSACM=0;0;0;0
AckPolicy=0;0;0;0
APSDCapable=0
DLSCapable=0
NoForwarding=0
NoForwardingBTNBSSID=0
HideSSID=${hidden:-0}
ShortSlot=1
AutoChannelSelect=${auto:-0}
IEEE8021X=0
IEEE80211H=0
CarrierDetect=0
ITxBfEn=0
PreAntSwitch=
PhyRateLimit=0
DebugFlags=0
ETxBfEnCond=0
ITxBfTimeout=0
ETxBfTimeout=0
ETxBfNoncompress=0
ETxBfIncapable=0
FineAGC=0
StreamMode=0
StreamModeMac0=
StreamModeMac1=
StreamModeMac2=
StreamModeMac3=
CSPeriod=6
RDRegion=
StationKeepAlive=0
DfsLowerLimit=0
DfsUpperLimit=0
DfsOutdoor=0
SymRoundFromCfg=0
BusyIdleFromCfg=0
DfsRssiHighFromCfg=0
DfsRssiLowFromCfg=0
DFSParamFromConfig=0
FCCParamCh0=
FCCParamCh1=
FCCParamCh2=
FCCParamCh3=
CEParamCh0=
CEParamCh1=
CEParamCh2=
CEParamCh3=
JAPParamCh0=
JAPParamCh1=
JAPParamCh2=
JAPParamCh3=
JAPW53ParamCh0=
JAPW53ParamCh1=
JAPW53ParamCh2=
JAPW53ParamCh3=
FixDfsLimit=0
LongPulseRadarTh=0
AvgRssiReq=0
DFS_R66=0
BlockCh=
GreenAP=0
PreAuth=0
AuthMode=WPA2PSK
EncrypType=AES
WapiPsk1=0123456789
WapiPsk2=
WapiPsk3=
WapiPsk4=
WapiPsk5=
WapiPsk6=
WapiPsk7=
WapiPsk8=
WapiPskType=0
Wapiifname=
WapiAsCertPath=
WapiUserCertPath=
WapiAsIpAddr=
WapiAsPort=
RekeyMethod=DISABLE
RekeyInterval=3600
PMKCachePeriod=10
MeshAutoLink=0
MeshAuthMode=
MeshEncrypType=
MeshDefaultkey=0
MeshWEPKEY=
MeshWPAKEY=
MeshId=
WPAPSK1=${key}
HSCounter=0
HT_HTC=1
HT_RDG=1
HT_LinkAdapt=0
HT_OpMode=0
HT_MpduDensity=5
HT_EXTCHA=0
HT_BW=${HT:-0}
HT_AutoBA=1
HT_BADecline=0
HT_AMSDU=0
HT_BAWinSize=64
HT_GI=1
HT_STBC=1
HT_MCS=33
HT_TxStream=2
HT_RxStream=2
HT_PROTECT=1
HT_DisallowTKIP=1
HT_BSSCoexistence=${HT_CE:-1}
GreenAP=0
WscConfMode=0
WscConfStatus=1
WCNTest=0
AccessPolicy0=${ra_macfilter:-0}
AccessControlList0=${maclist}
AccessPolicy1=0
AccessControlList1=
AccessPolicy2=0
AccessControlList2=
AccessPolicy3=0
AccessControlList3=
AccessPolicy4=0
AccessControlList4=
AccessPolicy5=0
AccessControlList5=
AccessPolicy6=0
AccessControlList6=
AccessPolicy7=0
AccessControlList7=
WdsEnable=0
own_ip_addr=
Ethifname=
EAPifname=
PreAuthifname=
session_timeout_interval=0
idle_timeout_interval=0
WiFiTest=0
TGnWifiTest=0
ApCliEnable=0
RadioOn=1
EOF

#ifconfig ra0 down
if ifconfig ra0 up ; then
#	brctl delif br-lan ra0
	if ! brctl addif br-lan ra0 ; then
		logger -t "mtk_wireless" "Can not add wireless interface to bridge"
		brctl show | grep 'ra0' > /dev/null 2>&1 && logger -t "mtk_wireless" "ignored. need fix later!"
	fi
else
	logger -t "mtk_wireless" "Can not setup wireless interface"
fi

led=`cat /lib/mtkdrv/rt2860/led 2>/dev/null`
if [ -n "$led" ]; then
	led="/sys/class/leds/$led"
	echo netdev > "$led/trigger"
	echo 'link tx rx' > "$led/mode" || {
		echo 1 > "$led/link"
		echo 1 > "$led/tx"
		echo 1 > "$led/rx"
	}
	echo ra0 > "$led/device_name"
fi

exit 0
