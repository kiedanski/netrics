# FROM python:3.10 as builder 
FROM python:3.10-slim
ENV USER=netrics
ENV PATH="$PATH:/home/$USER/.local/bin"


RUN apt-get update && apt-get install -y iputils-ping git scamper dnsutils vim gcc && apt-get clean autoclean

RUN useradd -m $USER
RUN mkdir -p /home/$USER/.local/share/netrics/result/; chown -R $USER:$USER /home/$USER/.local/share/netrics/result/

USER $USER
RUN pip install --user --upgrade pip && pip install --no-cache-dir --user netrics-measurements
COPY --chown=$USER defaults.toml measurements.toml /home/$USER/.config/netrics/
WORKDIR /home/$USER

# Final image
# FROM python:3.10-slim-bullseye
# ENV USER=netrics
# ENV PATH="/opt/venv/bin:$PATH"

# RUN apk update && apk add bind-tools gcompat linux-headers


# COPY  --from=builder /opt/venv /opt/venv 
# COPY  --from=builder /usr/bin/scamper /usr/bin/scamper
# COPY  defaults.toml measurements.toml /opt/venv/netrics/


