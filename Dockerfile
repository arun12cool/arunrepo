FROM ubuntu
RUN apt-get -y update
RUN apt-get install vim
CMD touch arun
CMD echo "test" > arun
RUN apt-get install -y nginx
RUN service nginx start
EXPOSE 3243
CMD service nginx start
