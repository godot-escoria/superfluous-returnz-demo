#!/usr/bin/env python3
"""Build an Escoria terrain scale map from a Sosage ground map.

Sosage reads depth from the red channel and paints non-walkable areas pure
blue. Escoria reads the HSV value (max of R, G, B), so blue counts as white
(far away) and characters shrink when they touch it. Output: grayscale from
the red channel, blue areas filled with the median gray of their row (the
depth gradient is vertical); rows without walkable pixels are interpolated.
Usage: python3 tools/make_scale_map.py in_map.png out_scale.png"""
import sys
import numpy as np
from PIL import Image

m = np.array(Image.open(sys.argv[1]).convert("RGB")).astype(float)
blue = (m[:, :, 2] > 200) & (m[:, :, 0] < 60) & (m[:, :, 1] < 60)
red = m[:, :, 0]
rows = np.full(red.shape[0], np.nan)
for y in range(red.shape[0]):
    walk = ~blue[y]
    if walk.any():
        rows[y] = np.median(red[y][walk])
known = np.where(~np.isnan(rows))[0]
rows = np.interp(np.arange(len(rows)), known, rows[known])
out = np.where(blue, rows[:, None], red)
Image.fromarray(out.clip(0, 255).astype(np.uint8), "L").save(sys.argv[2])
print(sys.argv[2], "blue pixels filled:", int(blue.sum()))
