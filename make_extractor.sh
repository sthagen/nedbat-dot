#!/bin/bash
# From: https://community.linuxmint.com/tutorial/view/1998

payload=$1
script=$2

cat before_untar.sh > $script
printf "PAYLOAD_LINE=\`awk '/^__PAYLOAD_BELOW__/ {print NR + 1; exit 0; }' \$0\`
echo Unpacking
tail -n+\$PAYLOAD_LINE \$0 | base64 --decode | tar -xz
" >> $script
cat after_untar.sh >> $script
printf "exit 0
__PAYLOAD_BELOW__
" >> $script
base64 --break=70 $payload >> $script

chmod +x $script
