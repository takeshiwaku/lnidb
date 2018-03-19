links
```shell
https://stackoverflow.com/questions/20568836/cant-locate-dbi-pm
```
Build docker

```shell
docker build -t teste .
```

Executar o container
```shell
docker run -i -t -p 80:80  teste /bin/bash 
```

Iniciar os servicos
```shell
service postgresql start
service apache2 restart
service vsftpd restart  
```

#Verificar se o arquivo de configuracao do apache está correto
```shell
apache2ctl configtest
```

#Configuracao do banco postgre
Iniciar o servico
```shell
service postgresql start
```
#Conectar com usuario postgres
```shell
su postgres
```
Criar usuarios 
```shell
createuser lnidb
createdb lnidb -O lnidb
```

Criar o banco de dados atraves do comando (utilizando o o usuario "postgres")
```shell
psql lnidb lnidb -f /tmp/lnidb-master/lnidb-backend/lnidb.sql
```


Para mostrar o local do arquivo de configuracao do postgre

```shell
psql -t -P format=unaligned -c 'show hba_file';
```

editar o arquivo:
```shell
vi /etc/apache2/apache2.conf
```

linha 293
procurar por /var/www/html
```xml
<Directory /var/www/>
        Options Indexes FollowSymLinks
	XSendFile on
	XSendFilePath /home/lnidb2/basket
	XSendFilePath /home/lnidb2/attach
	XSendFilePath /home/lnidb2/dicom
        AllowOverride None
        Require all granted
</Directory>
```  
  


Compilar o programa em java 
```shell
cd /tmp/lnidb-master/lnidb-backend/diva
javac /tmp/lnidb-master/lnidb-backend/diva/*.java -encoding UTF-8
javac *.java 
jar cfm diva.jar manifest.txt *.class diva.png panctl.png check.png slicectl.png tool{1,2}.png view{1,2,3,4}.png colctl.png updown.png detail.png
cp diva.jar /var/www/db/lnidb-web
cp diva.jar /var/www/html
```


ir na linha 355 do arquivo lnidb.inc alterar o endereco ip p/ o servidor em questao 
```shell
vi /var/www/html/lnidb.inc
```

Valor original, alterar p/ o IP, que vai estar o servidor, e na realidade o melhor é colocar no servidor de DNS, que provavelmente tem ae na unicamp.
```
  $method = "http://143.106.129.42/db/getfile.php?f=";
```


Reiniciar o apache 
```shell
service apache2 restart
```


Para iniciar o processo em perl (processamento dos arquivos), colocar na inicializacao do servidor assim quando houver o boot nao terá que iniciar manualmente.
```shell
 cd /usr/local/bin
 lnidbtask.pl
```

