FROM rocker/r-ver:4.2.0

# System dependencies
RUN apt-get update && apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev libfontconfig1-dev

# R packages
RUN install2.r dplyr tidyr ggplot2 sf remotes
RUN Rscript -e 'remotes::install_github("wmurphyrd/fiftystater")'

## Copy files
RUN mkdir docker-demo
COPY data docker-demo/data
COPY code docker-demo/code
RUN mkdir docker-demo/output
#ADD . docker-demo

## Set working directory
WORKDIR docker-demo