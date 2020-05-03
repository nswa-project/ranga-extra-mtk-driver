#!/bin/bash

[ -z "$1" ] && exit 0
echo -n "$1" > "$2"
