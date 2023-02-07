# shellcheck shell=bash

if [[ "$ISWSL" == "2" ]]; then
  WSLHOST=$(ip route list match 0/0 | cut -d ' ' -f3)
  export WSLHOST
  export LIBGL_ALWAYS_INDIRECT=1     #GWSL
  export DISPLAY="$WSLHOST:0.0"      #GWSL
  export PULSE_SERVER="tcp:$WSLHOST" #GWSL
fi
