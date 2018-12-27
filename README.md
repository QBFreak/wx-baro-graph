# Barometric Pressure Graphing

This is a collection of scripts I use to generate a graph of the barometric pressure over the last 24 hours. I have it set to generate a new image every hour.

## Shell scripts

The shell scripts are included for reference only. Basically they set up my perl environment just like I would have in `.bashrc`, and then call the matching perl script. These are what my hourly cron jobs run.

## Perl scripts

These do the heavy lifting. `getall.pl` downloads the current weather data, as needed, and `graph.pl` generates the actual graph image.
