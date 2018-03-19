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
