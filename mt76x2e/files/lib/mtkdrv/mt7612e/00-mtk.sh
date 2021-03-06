#!/bin/sh

IFNAME='rai0'
DRIVER='mt76x2e'

ifconfig "$IFNAME" down
rmmod "$DRIVER"

wrtname="radio0"

ssid=`uci get "wireless.default_${wrtname}.ssid"`
key=`uci get "wireless.default_${wrtname}.key"`
channel=`uci get "wireless.${wrtname}.channel"`
macaddr=`uci get "wireless.${wrtname}.macaddr"`
htmode=`uci get "wireless.${wrtname}.htmode"`
noscan=`uci get "wireless.${wrtname}.noscan"`
hidden=`uci get "wireless.default_${wrtname}.hidden"`
country=`uci get "wireless.${wrtname}.country"`
auto='0'

#-s 32772 -n 6

if [ "$channel" = "" -o "$channel" = "auto" ]; then
	channel='157'
	auto='2'
fi

cat > /tmp/mt7612e.dat <<EOF
#The word of "Default" must not be removed
Default
MacAddress=${macaddr}
IcapMode=0
WebInit=1
CountryRegion=5
CountryRegionABand=7
CountryCode=${country:-TW}
BssidNum=1
SSID1=${ssid}
WirelessMode=14
TxRate=0
Channel=${channel}
BasicRate=15
BeaconPeriod=100
DtimPeriod=1
TxPower=100
LinkTestSupport=0
ThermalRecal=0
SKUenable=0
PERCENTAGEenable=0
BFBACKOFFenable=0
CalCacheApply=0
DisableOLBC=0
BGProtection=0
TxAntenna=
RxAntenna=
TxPreamble=1
RTSThreshold=2347
FragThreshold=2346
TxBurst=1
PktAggregate=1
TurboRate=0
WmmCapable=1
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
SecurityMode=0
VLANEnable=0
VLANName=
VLANID=0
VLANPriority=0
WscConfMode=0
WscConfStatus=2
WscAKMP=1
WscConfigured=0
WscModeOption=0
WscActionIndex=9
WscPinCode=
WscRegResult=1
WscUseUPnP=1
WscUseUFD=0
WscSSID=RalinkInitialAP
WscKeyMGMT=WPA-EAP
WscConfigMethod=138
WscAuthType=1
WscEncrypType=1
WscNewKey=scaptest
IEEE8021X=0
IEEE80211H=1
CSPeriod=6
PreAuth=0
AuthMode=WPA2PSK
EncrypType=AES
WPAPSK1=${key}
RekeyInterval=3600
RekeyMethod=DISABLE
PMKCachePeriod=10
WPAPSK1=12345678
DefaultKeyID=1
Key1Type=0
Key1Str1=
Key2Type=0
Key2Str1=
Key3Type=0
Key3Str1=
Key4Type=0
Key4Str1=
HSCounter=0
HT_HTC=1
HT_RDG=1
HT_LinkAdapt=0
HT_OpMode=0
HT_MpduDensity=5
HT_EXTCHA=1
HT_BW=1
HT_AutoBA=1
HT_BADecline=0
HT_AMSDU=0
HT_BAWinSize=64
HT_GI=1
HT_STBC=1
HT_MCS=33
HT_PROTECT=1
HT_MIMOPS=3
HT_40MHZ_INTOLERANT=0
HT_TxStream=2
HT_RxStream=2
HT_DisallowTKIP=1
HT_BSSCoexistence=0
VHT_STBC=1
VHT_SGI=1
VHT_LDPC=1
G_BAND_256QAM=1
NintendoCapable=0
AccessPolicy0=0
AccessControlList0=
AccessPolicy1=0
AccessControlList1=
AccessPolicy2=0
AccessControlList2=
AccessPolicy3=0
AccessControlList3=
WdsEnable=0
WdsEncrypType=NONE
WdsList=
WdsKey=
WirelessEvent=0
MACRepeaterOuiMode=2
RADIUS_Server=0
RADIUS_Port=1812
RADIUS_Key=
RADIUS_Acct_Server=
RADIUS_Acct_Port=1813
RADIUS_Acct_Key=
session_timeout_interval=0
idle_timeout_interval=0
staWirelessMode=8
StreamMode=0
PreAntSwitch=1
E2pAccessMode=2
PMFMFPC=0
PMFMFPR=0
PMFSHA256=0
DfsEnable=0
DfsZeroWait=0
DfsZeroWaitCacTime=255
HS_enabled=1
HS_internet=1
HS_hessid=bssid
HS_roaming_consortium_oi=50-6F-9A
HS_operating_class=115
HS_proxy_arp=0
HS_dgaf_disabled=0
HS_l2_filter=0
EDCCAEnable=1
RRMEnable=1
RegulatoryClass=12
FtSupport=1
own_ip_addr=192.168.1.10
EAPifname=br0
PreAuthifname=br0
AutoProvisionEn=
RADIUS_Key1=ralink
MUTxRxEnable=0
FixedTxMode=HT
HT_LDPC=0
VHT_BW=1
VHT_BW_SIGNAL=0
EOF

insmod "/lib/mtkdrv/${DRIVER}.ko"

if ifconfig "$IFNAME" up ; then
	if ! brctl addif br-lan "$IFNAME" ; then
		logger -t "mtk_wireless-mt7612e" "Can not add wireless interface to bridge"
		ifconfig "$IFNAME" down
	fi
else
	logger -t "mtk_wireless-mt7612e" "Can not setup wireless interface"
fi

exit 0
