FROM node:14-buster

WORKDIR /work

RUN apt update &&\
    apt install -y bluetooth bluez libbluetooth-dev libudev-dev
COPY package*.json .
RUN npm ci

CMD [ "bash" ]
