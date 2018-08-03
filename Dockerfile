FROM ubuntu
RUN apt-get -y update
RUN apt-get install vim -y
CMD touch arun
CMD echo "test" > arun
RUN apt-get install -y nginx
EXPOSE 3243
CMD service nginx restart
