# FROM python:3.10 as builder 
FROM python:3.10-slim
RUN apt-get update && apt-get install -y iputils-ping git scamper dnsutils vim gcc && apt-get clean autoclean

RUN pip install --upgrade pip && pip install --no-cache-dir netrics-measurements
COPY defaults.toml measurements.toml /root/.config/netrics/
