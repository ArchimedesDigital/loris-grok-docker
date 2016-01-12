FROM ubuntu:14.04

MAINTAINER BDLSS, Bodleian Libraries, Oxford University <calvin.butcher@bodleian.ox.ac.uk>

ENV HOME /root

# Update packages and install tools 
RUN apt-get update -y && apt-get install -y wget git unzip cmake make

# Install pip and python libs
RUN apt-get install -y python-dev python-setuptools python-pip
RUN pip install --upgrade pip		
RUN pip2.7 install Werkzeug
RUN pip2.7 install configobj


# ******************************************************************************************
# ******************************************************************************************
# ******************************************************************************************
# Forked from https://github.com/loris-imageserver/loris-docker/blob/development/Dockerfile
# Originally worked with Kakadu (install below); forked and changed to work with OPENJPEG
# CTB 12.1.16
# ******************************************************************************************
# ******************************************************************************************
# ******************************************************************************************

# Install kakadu
# WORKDIR /usr/local/lib
# RUN wget --no-check-certificate https://github.com/loris-imageserver/loris/raw/development/lib/Linux/x86_64/libkdu_v74R.so \
#	&& chmod 755 libkdu_v74R.so
#
# WORKDIR /usr/local/bin
# RUN wget --no-check-certificate https://github.com/loris-imageserver/loris/raw/development/bin/Linux/x86_64/kdu_expand \
#	&& chmod 755 kdu_expand
#

# Install OPENJPEG
WORKDIR /tmp
RUN wget http://downloads.sourceforge.net/project/openjpeg.mirror/2.0.1/openjpeg-2.0.1.tar.gz 
RUN tar xzvf openjpeg-2.0.1.tar.gz
RUN cd openjpeg-2.0.1/
RUN cmake .
RUN make
RUN sudo make install

# shortlinks for other libraries
RUN ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/ \
	&& ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/ \
	&& ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/ \
	&& ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/ \
	&& ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/ \

RUN echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig

# Install Pillow
RUN apt-get install -y libjpeg8 libjpeg8-dev libfreetype6 libfreetype6-dev zlib1g-dev liblcms2-2 liblcms2-dev liblcms2-utils libtiff5-dev
RUN pip2.7 install Pillow

# Install loris
WORKDIR /opt

# Get loris and unzip. 
# TODO: Move to specific tag later
RUN wget --no-check-certificate https://github.com/loris-imageserver/loris/archive/development.zip \
	&& unzip development.zip \
	&& mv loris-development/ loris/ \
	&& rm development.zip

RUN useradd -d /var/www/loris -s /sbin/false loris

WORKDIR /opt/loris

# Create image directory
RUN mkdir /usr/local/share/images

# Load example images
RUN cp -R tests/img/* /usr/local/share/images/

RUN ./setup.py install 
COPY loris2.conf etc/loris2.conf
COPY webapp.py loris/webapp.py

WORKDIR /opt/loris/loris

EXPOSE 5004
CMD ["python", "webapp.py"]
