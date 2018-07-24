FROM ubuntu
RUN apt-get -y update
CMD touch arun
RUN apt-get install -y nginx
EXPOSE 3243
CMD service nginx start
