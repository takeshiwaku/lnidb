links
```
https://stackoverflow.com/questions/20568836/cant-locate-dbi-pm
```
Build docker

```
docker build -t teste .
```

Executar o container
```
docker run -i -t -p 80:80  teste /bin/bash 
```

Iniciar os servicos
```
service postgresql start
service apache2 restart
service vsftpd restart  
```

Verificar se o arquivo de configuracao do apache está correto
```
apache2ctl configtest
```

Configuracao do banco postgre
Iniciar o servico
```
service postgresql start
```
Conectar com usuario postgres
```
su postgres
```
Criar usuarios 
```
createuser lnidb
createdb lnidb -O lnidb
```

Para mostrar o local do arquivo de configuracao do postgre

```
psql -t -P format=unaligned -c 'show hba_file';
```

editar o arquivo:
``` 
vi /etc/apache2/apache2.conf
```

linha 293
procurar por /var/www/html
```
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
```
cd /tmp/lnidb-master/lnidb-backend/diva
javac /tmp/lnidb-master/lnidb-backend/diva/*.java -encoding UTF-8
javac *.java 
jar cfm diva.jar manifest.txt *.class diva.png panctl.png check.png slicectl.png tool{1,2}.png view{1,2,3,4}.png colctl.png updown.png detail.png
cp diva.jar /var/www/db/lnidb-web
cp diva.jar /var/www/html
```


ir na linha 355 do arquivo lnidb.inc alterar o endereco ip p/ o servidor em questao 
```
vi /var/www/html/lnidb.inc
```

Valor original, alterar p/ o IP, que vai estar o servidor, e na realidade o melhor é colocar no servidor de DNS, que provavelmente tem ae na unicamp.
```
  $method = "http://143.106.129.42/db/getfile.php?f=";
```


Reiniciar o apache 
```
service apache2 restart
```


Para iniciar o processo em perl (processamento dos arquivos), colocar na inicializacao do servidor assim quando houver o boot nao terá que iniciar manualmente.
```
 cd /usr/local/bin
 lnidbtask.pl
```

