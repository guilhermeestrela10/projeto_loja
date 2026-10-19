# Integração com Supabase e Redis

## O que mudou
- **Supabase** passa a ser o banco principal (PostgreSQL na nuvem). Tabelas, view,
  function e procedure foram criadas lá rodando o mesmo `database/setup.sql`.
- **CRUD de produtos e clientes** usa o `supabase-py` (`insert`, `select`, `update`, `delete` + `eq`).
- **fn_calcular_desconto** é chamada por `supabase.rpc(...)`.
- **sp_realizar_venda** continua no banco (transação única) e é chamada com `psycopg2`
  na string de conexão do Supabase, pois possui parâmetro INOUT.
- **Redis Cloud** guarda em cache as listas de produtos, clientes e o relatório de vendas
  (`SETEX`, `GET`, `DEL`, `TTL`). Cada tela mostra se os dados vieram do **Supabase** ou do **Redis**.

## Telas
- Produtos e clientes: cadastrar, listar, **editar** e **excluir** (CRUD completo no Supabase).
- Todas as listagens mostram a origem dos dados (Supabase ou Redis), o tempo restante do cache
  e um botão **Limpar cache** (comando `DEL`).
- Dashboard e relatório continuam usando a view `vw_relatorio_vendas`.

## Fluxo do cache
1. 1ª listagem: Python → Supabase → Redis → tela
2. Próximas (cache válido): Python → Redis → tela
3. Cadastro/edição/exclusão/venda: a chave é apagada (`DEL`) e a próxima listagem busca no Supabase.

Chaves: `produtos:lista`, `clientes:lista`, `relatorio:vendas` (TTL de 60 s).

## Como executar
1. No Supabase: SQL Editor → cole e rode `database/setup.sql`.
2. Copie `.env.example` para `.env` e preencha as credenciais.
3. `pip install -r src/requirements.txt`
4. `cd src && python app.py` → http://127.0.0.1:5000

## Atenção
- Use a chave `service_role` só no servidor e nunca suba o `.env` ao GitHub.
- Se o Redis cair, o sistema continua funcionando direto pelo Supabase.
