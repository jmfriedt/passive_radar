# Processing software

The dataset is huge and cannot be stored online. This processing script for GNU/Octave assumes data
have been stored as complex floating point numbers (see read_complex_binary.m in the GNU Radio repository
for an example on how to read the file content). Direct Signal Interference (DSI) removal benefit is illustrated 
with the figures below, without and with DSI removal (red ellipse) allowing for a nearby target (green
circle) to become visible, otherwise hidden in the sidelobes.

<img src="0123_2.png">
<img src="0123_dsi_2.png">

Movie of a 5.8 GB dataset processed without DSI removal (left) and with DSI removal (right)

<img src="animation.gif">
