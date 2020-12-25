FROM debian:buster

RUN apt update && apt install -y nginx vim wget tar
RUN apt -y install mariadb-server
RUN apt install -y php-mbstring php-zip php-gd php-xml php-pear php-gettext php-cli php-fpm php-cgi php-mysql
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-english.tar.gz
RUN tar -xzf phpMyAdmin-4.9.0.1-english.tar.gz && rm phpMyAdmin-4.9.0.1-english.tar.gz
RUN mv phpMyAdmin-4.9.0.1-english/ /var/www/html/
RUN mv /var/www/html/phpMyAdmin-4.9.0.1-english /var/www/html/phpmyadmin
COPY ./srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php
COPY ./srcs/default /etc/nginx/sites-available/default
RUN chmod 777 /var/www/html/ && chown -R www-data:www-data /var/www/html/
COPY ./srcs/querie.sql ./querie.sql
RUN service mysql start && mysql -u root < "/querie.sql"
RUN wget http://wordpress.org/latest.tar.gz
RUN tar -xzf latest.tar.gz && rm latest.tar.gz
RUN mv wordpress /var/www/html/
RUN chown -R www-data:www-data /var/www/html/wordpress && chmod -R 755 /var/www//html/wordpress
COPY ./srcs/self-signed.conf /etc/nginx/snippets/self-signed.conf
COPY ./srcs/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
RUN openssl req -subj "/C=MA/ST=KHOURIBGA/L=BJ/O=Yoki/CN=localhost" -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
RUN nginx -t 
COPY ./srcs/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 80 443

ENTRYPOINT bash script.sh && bash
