# Sistema de Vendas

## Identificação
- **Aluno(a):** Guilherme Henrique Macedo Estrela
- **Disciplina:** Projeto de Banco de Dados
- **Professor(a):** Anderson Soares

## Sobre o projeto
Aplicação web para controle de vendas de uma loja: cadastro de produtos e clientes, registro de vendas com baixa automática de estoque, cálculo de desconto por faixa de valor e relatório consolidado de vendas. O banco de dados concentra regras de negócio (desconto, validação de estoque e gravação da venda) e a consolidação dos dados para consulta.

## Tecnologias utilizadas
- Python 3 / Flask
- PostgreSQL 11 ou superior
- HTML/CSS (templates Jinja2)
- psycopg2

## Banco de dados
- **SGBD:** PostgreSQL
- **Principais tabelas:** `clientes`, `produtos`, `vendas`, `itens_venda`
- **View:** `vw_relatorio_vendas` — junta vendas, clientes, itens e produtos. Usada na tela *Relatório de vendas* e no *Dashboard*.
- **Function:** `fn_calcular_desconto(subtotal)` — retorna o desconto (5% a partir de R$ 200; 10% a partir de R$ 500). Usada na tela *Nova venda* (botão "Calcular desconto") e dentro da procedure.
- **Procedure:** `sp_realizar_venda(cliente, produto, quantidade, INOUT venda_id)` — valida estoque, calcula desconto, grava venda e item e baixa o estoque em uma única transação. Chamada pelo botão "Confirmar venda" da tela *Nova venda*.

## Como executar
1. Crie o banco: `createdb -U postgres loja`
2. Na raiz do projeto, crie os objetos e dados: `psql -U postgres -d loja -f database/setup.sql`
3. Instale as dependências: `pip install -r src/requirements.txt`
4. (Opcional) Defina `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`. Padrão: localhost / 5432 / loja / postgres / postgres.
5. Execute: `cd src && python app.py` e acesse http://127.0.0.1:5000
