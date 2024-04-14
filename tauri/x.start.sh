/usr/bin/Xvfb :0 -screen 0 1920x1080x24 +extension GLX +render -noreset & 

/usr/bin/x11vnc -display :0.0 &

