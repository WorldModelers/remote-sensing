# Portable Remote Sensing Applications

## Global Crop Mask

<img align="right" src="imgs/global_mask.png">

There are 20 publically available global crop masks at various resolutions and time scales.

Task: stitch these crop masks into a normalized, unified non-temporal global mask.

<br>


## Vegetation Index (VI)

<img align="right" src="imgs/vi_mask.png">

Mask VI indices (temporal stack) with unified crop mask from above => only crop pixels remain.

<br>
<br>
<br>
<br>

## Convert VI to Time Series

<img align="right" src="imgs/spatial_avgs.png">

Aggregate VI values over crop pixels per admin area. Convert these spatial average values into time series.

<br>
<br>
<br>
<br>


## Machine Learning

<img align="right" src="imgs/predict.png">

Correlate observed yield values (from LSMS, ministry, or simulations) with VI and climate time series. This can be done with regression or deep learning or any of your favorite ML tools.