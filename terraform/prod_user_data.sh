#!/bin/bash
sudo apt -y update
sudo apt -y install docker.io
sudo usermod -aG docker ubuntu
sleep 6m
docker run -d -p 8080:8080 dimakhomchenko/webserver:v0.1