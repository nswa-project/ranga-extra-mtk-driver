#!/bin/sh
brctl addif br-lan ra0
brctl addif br-lan rai0
logger -t "mtk_wireless" "bridge fixed"
exit 0
