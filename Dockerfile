#Use the official PHP 8.0 image as the base
FROM php:8.0-apache

ADD ./application /var/www/bookstack
WORKDIR /var/www/bookstack

#Install the required PHP extensions and dependencies
RUN apt-get update && apt-get install -y \
git \
libfreetype6-dev \
libjpeg62-turbo-dev \
libpng-dev \
libldap2-dev \
libtidy-dev \
libxml2-dev \
libzip-dev \
unzip \
zip \
&& docker-php-ext-configure gd --with-freetype --with-jpeg \
&& docker-php-ext-install -j$(nproc) gd \
&& docker-php-ext-install bcmath \
&& docker-php-ext-install ldap \
&& docker-php-ext-install mysqli \
&& docker-php-ext-install pdo_mysql \
&& docker-php-ext-install tidy \
&& docker-php-ext-install xml \
&& docker-php-ext-install zip 

#Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Install the PHP dependencies using Composer
RUN composer install --no-dev

#Copy the example environment file and set the permissions
RUN cp .env.example .env \
&& chown -R www-data:www-data /var/www/bookstack \
&& chmod -R 755 /var/www/bookstack/storage \
&& chmod -R 755 /var/www/bookstack/bootstrap/cache \
&& chmod -R 755 /var/www/bookstack/public/uploads 

ENV APP_URL app_url
ENV DB_HOST db_host
ENV DB_DATABASE database_database
ENV DB_USERNAME database_username
ENV DB_PASSWORD database_password

# Generate the application key
RUN php artisan key:generate --no-interaction --force

#Enable the Apache rewrite module
RUN a2enmod rewrite

#Copy the Apache configuration file
COPY ./application/bookstack.conf /etc/apache2/sites-available/bookstack.conf

#Enable the BookStack virtual host
RUN a2dissite 000-default && a2ensite bookstack

#Expose port 80
EXPOSE 80

#Start the Apache server and debug
CMD ["/bin/bash", "-c", "apache2ctl -D FOREGROUND"]