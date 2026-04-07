# Ata de Reunião: Definição de POC e Arquitetura de Genies

## 📅 Resumo Executivo
* **Objetivo:** Apresentação da necessidade de uma POC para validar a aderência do produto à solução proposta.
* **Participantes Chave:** Takeshi, Flavio, Lucas Tavares e Carlos Augusto Ferreira Barbosa.

---

## 📝 Pontos Discutidos

### 1. Contextualização e Necessidade
* **Apresentação:** Takeshi e Flavio apresentaram a fundamentação para a criação de uma **Prova de Conceito (POC)**.
* **Objetivo da POC:** Demonstrar tecnicamente como o produto se alinha às necessidades do negócio.

### 2. Arquitetura dos Genies
* **Demonstração:** Lucas Tavares apresentou a estrutura dos **Genies**.
* **Interações:** Carlos Augusto Ferreira Barbosa conduziu os questionamentos técnicos durante a sessão.
* **Configuração Técnica:**
    * A solução é composta por **17 Genies** coordenados por um **Agente Supervisor**.
    * Cada Genie possui acesso a uma tabela de metadados específica para otimizar o refinamento das instruções.
    * O deploy é realizado através de um **Notebook Python**.

### 3. Integração com Microsoft Teams
A disponibilização para o usuário final seguirá o seguinte fluxo:
1.  O usuário digita a palavra **"genie"** no Teams.
2.  A mensagem aciona um fluxo no **Power Automate**.
3.  O Power Automate realiza as requisições ao Supervisor.
4.  **Autenticação:** O processo utiliza um **token de usuário sistêmico** (sem autenticação individual do usuário final nesta etapa).

---

## ✅ Próximos Passos (Action Items)
| Atividade | Responsáveis |
| :--- | :--- |
| Elaboração do desenho técnico/arquitetural | **Takeshi e Lucas** |

---
*Documento gerado para registro de alinhamento técnico.*
