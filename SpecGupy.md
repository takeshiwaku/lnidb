Perfeito! Adicionei a nova regra de negócio para a criação do arquivo **CSV** (otimizado para o **Amazon QuickSight**) e a lógica matemática e de engenharia para o **cálculo de SLA (Service Level Agreement)** do ciclo de vida das vagas, utilizando os campos createdAt e updatedAt.

Aqui está a sua **Specification-Driven Development (SDD)** atualizada e refinada em Markdown:

---

# Engenharia de Dados: Spec de Integração (Gupy para AWS S3)

Esta especificação define os requisitos de arquitetura, design técnico, regras de negócio e implementação para o componente de ingestão de dados da **Gupy API** para a camada Raw/Bronze do Data Lake na **AWS S3**. O componente será implementado em Python e executado como uma função **AWS Lambda**, possuindo acoplamento fraco com o ambiente AWS para permitir testes locais independentes. A saída final será gerada em formato **CSV** estruturado para consumo direto no **Amazon QuickSight**.

---

## 1. Objetivo do Programa

Análise, extração e transformação periódica de dados consolidados (vagas, candidaturas e candidatos) do ecossistema Gupy por meio de sua API oficial ([https://developers.gupy.io/reference/introduction](https://developers.gupy.io/reference/introduction)), realizando o achatamento dos payloads, o cálculo de SLA de fechamento de vagas e a carga dos dados em formato **CSV** em um bucket da **Amazon Web Services (AWS S3)** para visualização no **Amazon QuickSight**.

---

## 2. Arquitetura e Fluxo de Dados

O componente operará sob o modelo de execução Serverless da AWS (Lambda), utilizando o padrão de arquitetura de pipelines de dados em memória (*In-Memory*) para otimização de custo e performance.

```
[ Gupy API v1 ] ➔ [ Achatamento & Cálculo de SLA ] ➔ [ Conversão para CSV ] ➔ [ Upload S3 ] ➔ [ Amazon QuickSight ]

```

### Detalhes das Etapas:

1. **Extração (API Client):** Autenticação via token estático (Bearer Token) no header HTTP, efetuando requisições paginadas para os endpoints da API da Gupy.
2. **Transformação & Cálculo de Métricas:**
* Achatamento (*flattening*) de dicionários JSON aninhados para o formato de tabela plana.
* Aplicação da regra de negócio para o cálculo de SLA de tempo de fechamento/ciclo da vaga.
* Injeção de metadados operacionais (extracted_at no formato ISO 8601 UTC).


3. **Conversão para CSV (In-Memory):** Consolidação dos registros normalizados em um buffer de texto (io.StringIO) configurado em conformidade com os requisitos do QuickSight.
4. **Carga (S3 Ingestion):** Streaming do buffer de texto convertido em bytes diretamente para o S3 utilizando a biblioteca boto3.

---

## 3. Regra de Negócio: Cálculo de SLA da Vaga

Para medir a eficiência do processo de recrutamento nos dashboards do QuickSight, o script deve calcular o tempo total de ciclo (SLA) de cada vaga extraída do endpoint /v1/jobs.

### 3.1. Variáveis Utilizadas

* $T_{\text{inicio}}$ = Valor do campo createdAt (Data de abertura da vaga na Gupy).
* $T_{\text{fim}}$ = Valor do campo updatedAt (Data da última atualização/encerramento da vaga).

### 3.2. Fórmula do SLA

O cálculo do SLA deve rastrear a diferença em dias (com precisão de casas decimais para representar horas/minutos fracionados):

$$\text{SLA\_Dias} = \frac{T_{\text{fim}} - T_{\text{inicio}}}{\text{86400 segundos}}$$

### 3.3. Requisitos de Implementação do SLA

* As strings de data fornecidas pela Gupy em formato ISO 8601 (ex: 2026-05-22T14:00:00.000Z) devem ser convertidas para objetos datetime nativos do Python em formato UTC.
* Se a vaga ainda estiver aberta (e o updatedAt não representar um encerramento real), o cálculo deve utilizar a data e hora do momento da extração ($T_{\text{atual}}$) para calcular o SLA parcial (Dias em aberto).
* O resultado deve ser gravado na coluna nova chamada sla_total_days formatado como um número de ponto flutuante (*float*).

---

## 4. Requisitos Técnicos e Especificações do QuickSight

### 4.1. Padrões de Autenticação da API Gupy

* Authorization: Bearer <GUPY_TOKEN>
* Accept: application/json

### 4.2. Formatação do CSV para o Amazon QuickSight

Para evitar erros de *parsing* e quebra de colunas no QuickSight, as seguintes diretrizes são obrigatórias:

* **Encoding:** UTF-8.
* **Delimitador:** Vírgula (,).
* **Tratamento de Quebras de Linha e Aspas:** Textos longos contendo quebras de linha (\n) ou vírgulas (como descrições de cargos) devem ser obrigatoriamente envelopados com aspas duplas. Quaisquer aspas duplas originais do texto devem ser escapadas como ("").
* **Campos de Data:** Devem manter o padrão ISO 8601 (YYYY-MM-DD HH:MM:SS) para reconhecimento automático de séries temporais no QuickSight.

### 4.3. Tecnologias Obrigatórias

* **Runtime:** Python 3.11 ou 3.12.
* **Bibliotecas Nativas:** csv, io, logging, datetime.
* **SDK AWS:** boto3 e botocore.
* **Ambiente de Teste:** python-dotenv.

---

## 5. Design para Execução Dupla (Local vs AWS Lambda)

O script utiliza o bloco condicional if **name** == "**main**": para permitir que o desenvolvedor execute e valide todo o pipeline localmente sem precisar realizar o deploy ou invocar o Console AWS.

### 5.1. Estrutura Base do Código (lambda_function.py)

```python
import os
import io
import csv
import json
import logging
from datetime import datetime, timezone
import boto3
from botocore.exceptions import ClientError

# Configuração de logging adaptável
logger = logging.getLogger()
logger.setLevel(logging.INFO)

class GupyS3CsvIngestor:
    def __init__(self):
        self.gupy_token = os.environ.get("GUPY_TOKEN")
        self.bucket_name = os.environ.get("AWS_S3_BUCKET")
        self.s3_client = boto3.client("s3")
        
    def parse_gupy_date(self, date_str):
        """Converte a string de data da Gupy para datetime UTC tratando o sufixo Z"""
        if not date_str:
            return None
        return datetime.fromisoformat(date_str.replace("Z", "+00:00"))

    def calculate_sla(self, created_at_str, updated_at_str):
        """Calcula o SLA em dias (float) baseado em createdAt e updatedAt"""
        t_inicio = self.parse_gupy_date(created_at_str)
        t_fim = self.parse_gupy_date(updated_at_str)
        
        if not t_inicio:
            return 0.0
            
        if not t_fim:
            t_fim = datetime.now(timezone.utc)
            
        delta = t_fim - t_inicio
        return round(delta.total_seconds() / 86400.0, 4)

    def flatten_and_enrich(self, record):
        """Achata a estrutura do JSON e aplica regras de negócio (SLA)"""
        flat_dict = {}
        for key, value in record.items():
            if isinstance(value, dict):
                for sub_key, sub_value in value.items():
                    flat_dict[f"{key}_{sub_key}"] = sub_value
            elif isinstance(value, list):
                flat_dict[key] = json.dumps(value, ensure_ascii=False)
            else:
                flat_dict[key] = value
                
        # Aplicação da regra de SLA
        flat_dict["sla_total_days"] = self.calculate_sla(
            record.get("createdAt"), 
            record.get("updatedAt")
        )
        flat_dict["extracted_at"] = datetime.now(timezone.utc).isoformat()
        return flat_dict

    def convert_to_csv_buffer(self, flat_data):
        if not flat_data:
            return None
            
        csv_buffer = io.StringIO()
        headers = flat_data[0].keys()
        
        # Configuração estrita de aspas para proteção do Amazon QuickSight
        writer = csv.DictWriter(csv_buffer, fieldnames=headers, delimiter=',', quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        writer.writerows(flat_data)
        
        byte_buffer = io.BytesIO(csv_buffer.getvalue().encode('utf-8'))
        csv_buffer.close()
        return byte_buffer

    def upload_to_s3(self, byte_buffer, endpoint_type):
        now = datetime.now(timezone.utc)
        key = f"raw/gupy/{endpoint_type}/year={now.year}/month={now.strftime('%m')}/day={now.strftime('%d')}/{endpoint_type}_{now.strftime('%H%M%S')}.csv"
        
        try:
            self.s3_client.upload_fileobj(byte_buffer, self.bucket_name, key)
            logger.info(f"Upload concluído: s3://{self.bucket_name}/{key}")
            return True
        except ClientError as e:
            logger.error(f"Falha de gravação no S3: {e}")
            raise e

def lambda_handler(event, context):
    """Ponto de entrada oficial na AWS Lambda"""
    logger.info(f"Execução iniciada via Lambda. Evento: {json.dumps(event)}")
    ingestor = GupyS3CsvIngestor()
    
    for data_type in ["jobs"]:
        # Exemplo simulado de dados da API da Gupy para visualização estrutural
        mock_gupy_api_response = [
            {
                "id": 9991, 
                "title": "Engenheiro de Dados Pleno", 
                "createdAt": "2026-05-10T10:00:00.000Z", 
                "updatedAt": "2026-05-22T11:00:00.000Z", # 12 dias e 1 hora de SLA
                "status": "closed"
            }
        ]
        
        flat_data = [ingestor.flatten_and_enrich(item) for item in mock_gupy_api_response]
        byte_buffer = ingestor.convert_to_csv_buffer(flat_data)
        if byte_buffer:
            ingestor.upload_to_s3(byte_buffer, data_type)
            
    return {"statusCode": 200, "body": "Pipeline executado e dados salvos em CSV."}

if __name__ == "__main__":
    """Ponto de entrada para Execução de Teste Local"""
    print("\n" + "="*40)
    print("   EXECUÇÃO LOCAL DE TESTE (SEM CONSOLE)   ")
    print("="*40)
    
    try:
        from dotenv import load_dotenv
        load_dotenv()
    except ImportError:
        print("Dica: Instale 'python-dotenv' para carregar arquivos .env locais.")

    # Redireciona logs para o console local (sys.stdout)
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    
    # Execução direta do handler simulando comportamento da nuvem
    resposta = lambda_handler(event={"is_local_test": True}, context=None)
    print(f"\nResultado do Teste Local: {resposta}")

```

### 5.2. Instruções de Execução Local

1. Crie um arquivo .env na raiz do projeto contendo as chaves temporárias da AWS (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY), o nome do bucket de destino e o token da Gupy.
2. Execute o comando diretamente no seu terminal:
```bash
python lambda_function.py


```



```

---

## 6. Estrutura de Particionamento no S3

Para garantir a performance do QuickSight (evitando varreduras completas desnecessárias por meio de filtros de partição), os arquivos CSV serão salvos utilizando a convenção Hive:

s3://[NOME_DO_BUCKET]/raw/gupy/[TIPO_DE_DADO]/year=YYYY/month=MM/day=DD/[TIPO_DE_DADO]_[TIMESTAMP].csv

---

## 7. Critérios de Aceite para Validação (Definição de Pronto)

1. **Validação do SLA:** O arquivo CSV gerado deve conter a coluna sla_total_days preenchida com o cálculo preciso em dias (ex: 12.0416).
2. **Compatibilidade QuickSight:** O arquivo CSV deve abrir corretamente em qualquer software de planilhas e no QuickSight sem deslocamento de colunas provocado por quebras de linha de campos de texto.
3. **Isolamento de Infraestrutura:** O comando python lambda_function.py roda com sucesso localmente, lê do arquivo .env e faz o upload real ou mockado para o S3 sem depender de gatilhos internos da AWS Cloud.

```