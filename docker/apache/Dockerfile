FROM centos:7 as builder
WORKDIR /usr/src/apache
COPY ./init_pip.sh .
RUN ./init_pip.sh
COPY ./init_yum.sh .
RUN ./init_yum.sh

FROM httpd:2.4.48
COPY --from=builder /var/www/html /var/www/html
