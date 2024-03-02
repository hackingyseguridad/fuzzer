#!/bin/bash
# (c) hacking y seguridad .com 2024
echo
echo
curl -ks $1 $2 -L -H 'User-Agent: Mozilla/5.0' -X TRACE -I
