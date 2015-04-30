#!/bin/bash

xvfb-run -n 99 -f /home/sahi/.Xauthority --server-args="-screen 0, 1024x768x24" /x_session.sh &
x11vnc -auth /home/sahi/.Xauthority -display :99 &

while [ 1 ]; do echo -n .; sleep 2; done
