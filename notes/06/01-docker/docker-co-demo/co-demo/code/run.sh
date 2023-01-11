#!/usr/bin/env bash
set -ex

# This is the master script for the capsule. When you click "Reproducible Run", the code in this file will execute.

mkdir -p ../results/data # make a dir for saving scraped data
mkdir -p ../results/output # make a dir for saxing output figs
python3 -u election-2020.py "$@" # running python script
Rscript election-map-2020.R "$@" # running R script for analysis 
