-- Consolida vendas, clientes, itens e produtos para o relatório e o dashboard
CREATE OR REPLACE VIEW vw_relatorio_vendas AS
SELECT
    v.id                                AS venda_id,
    v.data_venda,
    c.nome                              AS cliente,
    p.nome                              AS produto,
    i.quantidade,
    i.preco_unitario,
    (i.quantidade * i.preco_unitario)   AS subtotal,
    v.desconto,
    v.total
FROM vendas v
JOIN clientes    c ON c.id = v.cliente_id
JOIN itens_venda i ON i.venda_id = v.id
JOIN produtos    p ON p.id = i.produto_id;
