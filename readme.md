# gswarm-GAX

These scripts make it possible to compute the average of the AOD1B over the solution periods of the [Swarm gravity field models](https://www.researchgate.net/project/Multi-approach-gravity-field-models-from-Swarm-GPS-data), which happen to be complete calendar months.

Before that, there is the need to download the AOD1B data with `AOD1B/download.sh`. Notice that the AOD1B data is very large, 7.2Gb per year uncompressed.

The script `aod-mean.awk` is where all the work takes place. All input arguments are assumed to be AOD1B files to be averaged. Optionally, the environment variable `lmax` can be exported before running the `awk` script to define the maximum degree to consider (defaults to 40).

The script `aod-mean-monthly.sh` wraps around `aod-mean.awk` to pick the AOD1B files relevant to a particular calendar month defined by the input arguments:

```
./aod-mean-monthly.sh <4-digit year> <2-digit month>
```

As a result, `GA[ABCD]_<start_date>_<stop_date>.gfc` are produced. The header information is retrieved from the AOD1B files and left unchanged.
