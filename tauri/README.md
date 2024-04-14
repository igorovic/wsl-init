# Experiment in progress


start xvfb in container

```bash
# diplay :0 screen 0 for tauri app to be able to start
Xvfb :0 -screen 0 1920x1080x24 +extension GLX +render -noreset
```

serve with xvnc

```bash
x11vnc -display :0.0
```

```bash
docker run -it --name tauri-dev -p 5900:5900 \
-e DISPLAY=:0 \
--privileged \
dyve/tauri:v0
```