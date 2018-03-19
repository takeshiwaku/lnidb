FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y gcc           
RUN apt-get install -y make          
RUN apt-get install -y php           
RUN apt-get install -y php-pgsql    
RUN apt-get install -y vsftpd       
RUN apt-get install -y postgresql   
RUN apt-get install -y postgresql-server-dev-9.5
RUN apt-get install -y perl
RUN apt-get install -y libdbi-perl
RUN apt-get install -y zip unzip
RUN apt-get install -y vim
RUN apt-get install -y apache2
RUN apt-get install -y apache2-dev
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y libapache2-mod-php
RUN apt-get install -y openssh-server

RUN apt-get install -y sysv-rc-conf 

# Comandos que colocam na inicializacao dos servicos
#RUN chkconfig --levels 345 postgresql on
#RUN chkconfig --levels 345 httpd on
#RUN chkconfig --levels 345 vsftpd on
#RUN chkconfig --levels 345 iptables on
#COPY vsftpd.conf /etc/vsftpd.conf

# Copia do repositorio p/ a pasta /tmp
copy lnidb-master.zip /tmp
RUN unzip /tmp/lnidb-master.zip  -d /tmp

# Verificar a necessidade de copia desta configuracao.
# COPY apache_lnidb.conf /etc/httpd/conf.d

# modulo de envio de arquivo p/ apache
COPY mod_xsendfile.c /tmp 
RUN apxs -cia /tmp/mod_xsendfile.c

# inclusao no arquivo de configuracao do apache para nao apresentar erro colocar o nome correto
RUN echo "ServerName 172.17.0.2 " >> /etc/apache2/apache2.conf

# Reinicializacao do servico do apache.
RUN service apache2 restart

# Configuracao do postgre autorizando o usuario lnidb p/ acessar o postgre
RUN cp /etc/postgresql/9.5/main/pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf.old
RUN echo "local	all	    lnidb		              trust" > /etc/postgresql/9.5/main/pg_hba.conf 
RUN cat  /etc/postgresql/9.5/main/pg_hba.conf.old >> /etc/postgresql/9.5/main/pg_hba.conf

# Criacao de usuario lnidb
RUN useradd lnidb -c LNIDB -m
RUN echo "lnidb:lnidb" | chpasswd

# Criacao de pastas do usuario lnidb 
RUN chmod 0755 /home/lnidb
RUN mkdir -m 0777 /home/lnidb/importacao
RUN mkdir -m 0777 /home/lnidb/anexos
RUN mkdir -m 0755 /home/lnidb2
RUN mkdir -m 0755 /home/lnidb2/dicom
RUN mkdir -m 0755 /home/lnidb2/attach
RUN mkdir -m 0755 /home/lnidb2/basket
RUN chown -R lnidb:lnidb /home/lnidb2
RUN chown -R lnidb:lnidb /home/lnidb

# Criacao do usuario anexo
RUN useradd anexo -c "anexos LNIDB" -M -s "/sbin/nologin" -d "/home/lnidb/anexos" 
RUN echo "anexo:anexo" | chpasswd

# Verificar a necessidade do arquivo ftp.modules.
#RUN cp /tmp/lnidb-master/lnidb-backend/ftp.modules /etc/sysconfig/modules
#RUN chmod 0755 /etc/sysconfig/modules/ftp.modules

###### copia de arquivo de teste.....
#RUN mkdir -m 0777 /home/lnidb/importacao/ARQUIVO
#COPY x20171101_151328IM_0001256DTIhighiso20SENSEANGELICAOLIVETTOALMEIDAs501a1005.bvec  /home/lnidb/importacao/ARQUIVO
#COPY x20171101_151328IM_0001256DTIhighiso20SENSEANGELICAOLIVETTOALMEIDAs501a1005.bval /home/lnidb/importacao/ARQUIVO
#COPY IM_0003 /home/lnidb/importacao/ARQUIVO
#COPY IM_0001 /home/lnidb/importacao/ARQUIVO
#COPY 20171101_151328IM_0001256DTIhighiso20SENSEANGELICAOLIVETTOALMEIDAs501a1005.nii /home/lnidb/importacao/ARQUIVO

#######################
#RUN mkdir -m 0777 /home/lnidb/importacao/AR_PQ
#COPY PQ.zip /home/lnidb/importacao/AR_PQ
#RUN unzip /home/lnidb/importacao/AR_PQ/PQ.zip /home/lnidb/importacao/
###################################

#RUN mkdir -m 0777 /home/lnidb/importacao/0001
#COPY IM_0011 /home/lnidb/importacao/0001
#COPY IM_0009 /home/lnidb/importacao/0001
#COPY IM_0007 /home/lnidb/importacao/0001

# Instalar utilitários binários:
RUN cp /tmp/lnidb-master/lnidb-backend/binutils/* /usr/local/bin
RUN cp /tmp/lnidb-master/lnidb-backend/lnidbtask.pl /usr/local/bin

# Inclusao na inicializacao, no ubuntu verificar se é o mesmo uso.
#RUN cp /tmp/lnidb-master/lnidb-backend/lnidbtask.sh /etc/rc.d/init.d/lnidbtask
#RUN chkconfig --add lnidbtask
#RUN chkconfig --levels 345 lnidbtask on


# Copia dos arquivos do sistema para a pasta /var/www/html 
RUN mkdir -p /var/www/db/lnidb-web
RUN cp /tmp/lnidb-master/lnidb-web/*.* /var/www/db/lnidb-web
RUN cp /tmp/lnidb-master/lnidb-web/*.* /var/www/html
RUN chmod 777 -R /var/www/db/*

# Insalacao do pacote DBI do perl 
RUN perl -MCPAN -e 'install DBI'
RUN perl -MCPAN -e 'install DBD::Pg'

# Compilacao do applet que apresenta a imagem no browser.
RUN javac /tmp/lnidb-master/lnidb-backend/diva/*.java -encoding UTF-8

