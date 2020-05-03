#!/bin/sh

DEV='/dev/mtd2'
EEPROM_FILE="/etc/wireless/mt7612e/MT7612E_EEPROM.bin"

rm -f "$EEPROM_FILE"
dd if="$DEV" of="$EEPROM_FILE" bs=512 skip=32768 count=1 iflag=skip_bytes 2> /dev/null
