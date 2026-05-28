Aqui está uma proposta de **Especificação Técnica de Integração (Integration Spec)** estruturada para o seu cenário. Ela define o fluxo de dados, a arquitetura da solução e inclui um protótipo funcional em Python para ilustrar a lógica de extração, cruzamento e scoring.

---

# Especificação Técnica: Integração e Scoring Gupy $\rightarrow$ IA

## 1. Visão Geral e Objetivo

Esta integração visa automatizar a coleta de vagas ativas (publicadas) na plataforma **Gupy**, extrair seus requisitos, buscar a base de candidatos disponíveis e, por fim, calcular um **Score de Aderência** (compatibilidade) entre o perfil do candidato e as exigências da vaga utilizando Python.

---

## 2. Arquitetura do Fluxo de Dados

O processo segue o modelo de pipeline abaixo:

1. **Extração de Vagas:** Consome a API da Gupy filtrando por `status=published`.
2. **Extração de Requisitos:** Consolida a descrição e os campos de qualificações de cada vaga.
3. **Extração de Candidatos:** Busca os candidatos cadastrados no banco de talentos/vaga.
4. **Processamento & Scoring:** Executa um motor de correspondência (Match Engine) em Python para gerar a nota de aderência.
5. **Carga/Saída:** Consolida os resultados em um report ou payload de saída.

---

## 3. Mapeamento de APIs (Gupy)

> ⚠️ **Nota de Integração:** Os endpoints abaixo baseiam-se no padrão REST de API pública/parceiros da Gupy. Substitua os placeholders (`{{token}}`, `{{base_url}}`) pelas credenciais oficiais do seu ambiente empresarial.

### 3.1. Listar Vagas Abertas

* **Endpoint:** `GET https://api.gupy.io/v1/jobs`
* **Headers:** `Authorization: Bearer {{token}}`
* **Query Params:** `status=published`
* **Dados Relevantes de Retorno:** `id`, `title`, `description`, `requirements`

### 3.2. Listar Candidatos por Vaga (ou Base Geral)

* **Endpoint:** `GET https://api.gupy.io/v1/jobs/{jobId}/candidates` ou `GET https://api.gupy.io/v1/candidates`
* **Headers:** `Authorization: Bearer {{token}}`
* **Dados Relevantes de Retorno:** `id`, `name`, `skills`, `resumeText` (experiência/currículo)

---

## 4. Estrutura do Script Python (Implementação)

Abaixo está o código em Python que simula a integração com as APIs da Gupy e realiza o cálculo de score.

Para o cálculo de aderência de forma escalável e inteligente, o exemplo utiliza técnicas de Processamento de Linguagem Natural (NLP) via **TF-IDF e Similaridade de Cosseno**. Se preferir, esse motor pode ser facilmente substituído por chamadas a uma API de LLM (como OpenAI ou Azure OpenAI) para análise semântica mais profunda.

### Pré-requisitos

```bash
pip install requests sklearn

```

### Código Fonte

```python
import requests
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Configurações de API (Substituir pelos dados reais)
GUPY_API_URL = "https://api.gupy.io/v1"
GUPY_TOKEN = "SEU_TOKEN_AQUI"
HEADERS = {
    "Authorization": f"Bearer {GUPY_TOKEN}",
    "Content-Type": "application/json"
}

def fetch_published_jobs():
    """Busca todas as vagas com status 'published' na Gupy."""
    url = f"{GUPY_API_URL}/jobs"
    params = {"status": "published"}
    
    try:
        # Mocking para demonstração caso a API não esteja conectada
        # response = requests.get(url, headers=HEADERS, params=params)
        # return response.json().get('data', [])
        
        # MOCK DATA para validação local do fluxo
        return [
            {
                "id": 101,
                "title": "Desenvolvedor Java Sênior",
                "requirements": "Experiência sólida com Java, Spring Boot, Microserviços, Cloud Architecture (AWS ou Azure) e bancos de dados SQL."
            },
            {
                "id": 102,
                "title": "Cientista de Dados Pleno",
                "requirements": "Domínio de Python, Pandas, bibliotecas de Machine Learning (Scikit-Learn), SQL avançado e criação de pipelines de dados."
            }
        ]
    except Exception as e:
        print(f"Erro ao buscar vagas: {e}")
        return []

def fetch_candidates_for_job(job_id):
    """Busca candidatos associados ou mapeados para a base."""
    url = f"{GUPY_API_URL}/jobs/{job_id}/candidates"
    
    try:
        # response = requests.get(url, headers=HEADERS)
        # return response.json().get('data', [])
        
        # MOCK DATA representando currículos/skills extraídos dos candidatos
        return [
            {
                "candidate_id": 5001,
                "name": "Carlos Silva",
                "resume_summary": "Desenvolvedor focado em ecossistema Java. Tenho 6 anos de experiência com Spring Boot, arquitetura baseada em microserviços e deploy em container Docker na AWS."
            },
            {
                "candidate_id": 5002,
                "name": "Ana Souza",
                "resume_summary": "Engenheira de Dados com forte background em Python, SQL Server e criação de dashboards em PowerBI. Conhecimento básico de modelos preditivos."
            },
            {
                "candidate_id": 5003,
                "name": "Rodrigo Lima",
                "resume_summary": "Profissional de TI com experiência em suporte técnico, redes de computadores e automação de scripts simples com Python."
            }
        ]
    except Exception as e:
        print(f"Erro ao buscar candidatos para a vaga {job_id}: {e}")
        return []

def calculate_adherence_score(requirements, candidate_resume):
    """
    Calcula o score de aderência usando TF-IDF e Similaridade de Cosseno.
    Retorna um valor percentual de 0 a 100.
    """
    documents = [requirements, candidate_resume]
    
    # Vetorização do texto tirando stop-words em português
    vectorizer = TfidfVectorizer(stop_words='portuguese')
    try:
        tfidf_matrix = vectorizer.fit_transform(documents)
        # Calcula a similaridade entre o vetor da vaga (0) e do candidato (1)
        similarity = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:2])
        
        # Converte para escala 0-100% e arredonda
        score = round(similarity[0][0] * 100, 2)
        return score
    except ValueError:
        # Tratamento caso os textos sejam vazios ou sem palavras interpretáveis
        return 0.0

def main():
    print("Iniciando Pipeline de Integração Gupy & Scoring...")
    
    # 1. Buscar vagas publicadas
    jobs = fetch_published_jobs()
    print(f"Total de vagas ativas encontradas: {len(jobs)}\n")
    
    results_pipeline = []

    # 2. Iterar sobre cada vaga
    for job in jobs:
        print(f"--- Processando Vaga: {job['title']} (ID: {job['id']}) ---")
        requirements = job['requirements']
        
        # 3. Buscar candidatos para a vaga específica
        candidates = fetch_candidates_for_job(job['id'])
        
        # 4. Calcular o score para cada candidato
        for candidate in candidates:
            resume = candidate['resume_summary']
            score = calculate_adherence_score(requirements, resume)
            
            match_data = {
                "job_id": job['id'],
                "job_title": job['title'],
                "candidate_id": candidate['candidate_id'],
                "candidate_name": candidate['name'],
                "score_adherence": f"{score}%"
            }
            results_pipeline.append(match_data)
            
            print(f"   > Candidato: {candidate['name']} | Score: {score}%")
        print("\n")
        
    # Aqui os dados estruturados em 'results_pipeline' poderiam ser enviados para um banco ou webhook externo.
    print("Processamento finalizado com sucesso.")

if __name__ == "__main__":
    main()

```

---

## 5. Regras de Negócio e Tratamento de Exceções

* **Paginação da API:** A API da Gupy utiliza paginação para retornar candidatos. O script produtivo deve tratar os parâmetros `page` e `limit` em loops `while` até que todos os registros sejam consumidos.
* **Sanitização de Texto:** Antes de rodar o `TfidfVectorizer`, recomenda-se limpar caracteres especiais, remover tags HTML que possam vir da descrição da vaga e colocar todo o texto em *lowercase*.
* **Gargalo de Chamadas (Rate Limiting):** Caso a base de candidatos seja massiva, adicione delays (`time.sleep`) entre as requisições para evitar bloqueios (`HTTP 429 Too Many Requests`) por parte dos servidores da Gupy.
* **Evolução do Motor de Match:** A similaridade de cosseno analisa a frequência de palavras/termos comuns. Se precisar capturar sinônimos ou conceitos abstratos (ex: entender que "AWS" se relaciona fortemente com "Cloud Architecture" mesmo sem repetir as palavras), a recomendação é evoluir o método `calculate_adherence_score` utilizando embeddings ou LLMs.