INSERT INTO clientes (nome, email) VALUES
 ('Maria Silva','maria@email.com'),
 ('João Souza','joao@email.com'),
 ('Ana Costa','ana@email.com')
ON CONFLICT DO NOTHING;

INSERT INTO produtos (nome, preco, estoque) VALUES
 ('Teclado Mecânico', 250.00, 20),
 ('Mouse Gamer', 120.00, 30),
 ('Monitor 24"', 900.00, 10),
 ('Headset', 180.00, 15);
