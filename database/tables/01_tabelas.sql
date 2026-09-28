CREATE TABLE IF NOT EXISTS clientes (
    id      SERIAL PRIMARY KEY,
    nome    VARCHAR(100) NOT NULL,
    email   VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS produtos (
    id       SERIAL PRIMARY KEY,
    nome     VARCHAR(100) NOT NULL,
    preco    NUMERIC(10,2) NOT NULL CHECK (preco >= 0),
    estoque  INT NOT NULL DEFAULT 0 CHECK (estoque >= 0)
);

CREATE TABLE IF NOT EXISTS vendas (
    id          SERIAL PRIMARY KEY,
    cliente_id  INT NOT NULL REFERENCES clientes(id),
    data_venda  TIMESTAMP NOT NULL DEFAULT NOW(),
    desconto    NUMERIC(10,2) NOT NULL DEFAULT 0,
    total       NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS itens_venda (
    id              SERIAL PRIMARY KEY,
    venda_id        INT NOT NULL REFERENCES vendas(id),
    produto_id      INT NOT NULL REFERENCES produtos(id),
    quantidade      INT NOT NULL CHECK (quantidade > 0),
    preco_unitario  NUMERIC(10,2) NOT NULL
);
