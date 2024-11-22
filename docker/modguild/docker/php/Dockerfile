FROM wordpress:fpm
        ENV PHP_OPCACHE_MEMORY_CONSUMPTION="512"
        RUN docker-php-ext-install calendar
        RUN docker-php-ext-configure calendar
        RUN docker-php-ext-install opcache
        RUN docker-php-ext-configure opcache
