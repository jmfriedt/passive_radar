# Processing software

The dataset is huge and is stored on a separate web site at
https://www.iqengine.org under GNU Radio SigMF Repo -> Passive Radar (both channels split in
two files during post-processing although initially saved as a single interleaved file). 
This processing script for GNU/Octave assumes data have been stored as 8-bit integers.
Direct Signal Interference (DSI) removal benefit is illustrated with the figures below, 
without and with DSI removal (red ellipse) allowing for a nearby target (green
circle) to become visible, otherwise hidden in the sidelobes.

<img src="0123_2.png">
<img src="0123_dsi_2.png">

Movie of a 5.8 GB dataset processed without DSI removal (left) and with DSI removal (right)

<img src="animation.gif">

The movies were created using

```bash
for i in `seq -w 0001 0365`; do echo $i; convert +append nodsi/${i}_2.png dsi/${i}_dsi_2.png ${i}.png;done
```
followed by
```bash
convert -delay 4 -loop 0 *dsi*.png animation_dsi.gif
```
