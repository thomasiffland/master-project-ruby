FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install python3-pip python3-dev build-essential -y
RUN apt-get install imagemagick -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:dhor/myway
RUN apt-get install dcraw -y
RUN apt-get install ruby ruby-dev ruby-bundler -y
RUN apt-get install ffmpeg -y
VOLUME /tmp


ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
COPY config $APP_HOME/config
RUN bundle install

COPY . $APP_HOME

CMD ["ruby", "main.rb", "-s", "Puma"]