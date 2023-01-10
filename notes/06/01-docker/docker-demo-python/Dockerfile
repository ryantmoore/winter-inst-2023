FROM python:3.11

# System dependencies
#RUN apt-get update && apt-get install -y curl libz-dev

# python libraries
#RUN pip install -U bs4
COPY requirements.txt .
RUN pip install -r requirements.txt

## Copy files
RUN mkdir docker-demo
RUN mkdir docker-demo/data
ADD . docker-demo

## Set working directory
WORKDIR docker-demo