FROM php:7-apache

#RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
#  php composer-setup.php && \
#  php -r "unlink('composer-setup.php');" && \
#  php composer.phar install --no-dev

# Install modules : GD mcrypt iconv
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# memcached module	
RUN apt-get install -y libmemcached-dev
RUN curl -o /root/memcached.zip https://github.com/php-memcached-dev/php-memcached/archive/php7.zip -L
RUN cd /root && unzip memcached.zip && rm memcached.zip && \
 cd php-memcached-php7 && \
 phpize && ./configure --enable-sasl && make && make install && \
 cd /root && rm -rf /root/php-memcached-* && \
 echo "extension=memcached.so" > /usr/local/etc/php/conf.d/memcached.ini  && \
 echo "memcached.use_sasl = 1" >> /usr/local/etc/php/conf.d/memcached.ini 


#RUN curl -o /root/memcached.zip https://github.com/php-memcached-dev/php-memcached/archive/2.2.0.zip -L
# cd php-memcached-2.2.0 && \

RUN pecl install redis && docker-php-ext-enable redis

RUN pecl install hprose && docker-php-ext-enable hprose

# install php pdo_mysql
RUN docker-php-ext-install pdo_mysql && \
  docker-php-ext-install bcmath

# memcached module with sasl
#RUN curl -o /root/libmemcached.tgz https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
#RUN cd /root && tar zxvf libmemcached.tgz && cd libmemcached-1.0.18 && \
# ./configure --enable-sasl && make && make install && \
# cd /root && rm -rf /root/libmemcached* 

# add http no-cache header
#COPY prepend.php /root/ 
#RUN chmod 0755 /root && echo "auto_prepend_file = /root/prepend.php" > /usr/local/etc/php/conf.d/prepend.ini

# log to stderr
RUN echo "error_log = /dev/stderr" > /usr/local/etc/php/conf.d/log.ini && \
  echo "log_errors = On" >> /usr/local/etc/php/conf.d/log.ini && \
  echo "" > /etc/apache2/conf-enabled/log.conf

# enable rewrite
#RUN mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/
#COPY rewrite.conf /etc/apache2/conf-enabled/rewrite.conf

# add check_alive.php
#echo "<?php echo 'OK'; " > /root/check_alive.php && chmod 0755 /root

# add user additional conf for apache & php
# add to CMD mkdir -p /var/www/conf/php && mkdir -p /var/www/conf/apache2 &&
# RUN echo "" >> /usr/local/php/conf.d/additional.ini
# RUN echo "" >> /etc/apache2/conf-enabled/additional.conf

# add welcome page
#COPY index.html /root/index.html

# set system timezone & php timezone
# @TODO

#EXPOSE 80 80
CMD apache2-foreground
