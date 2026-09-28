-- Registra uma venda completa em uma única transação:
-- valida estoque, calcula desconto (fn_calcular_desconto), grava venda e item, baixa estoque.
CREATE OR REPLACE PROCEDURE sp_realizar_venda(
    p_cliente_id  INT,
    p_produto_id  INT,
    p_quantidade  INT,
    INOUT p_venda_id INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_preco     NUMERIC(10,2);
    v_estoque   INT;
    v_subtotal  NUMERIC(10,2);
    v_desconto  NUMERIC(10,2);
BEGIN
    IF p_quantidade IS NULL OR p_quantidade <= 0 THEN
        RAISE EXCEPTION 'Quantidade inválida';
    END IF;

    SELECT preco, estoque INTO v_preco, v_estoque
    FROM produtos WHERE id = p_produto_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto não encontrado';
    END IF;
    IF v_estoque < p_quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente (disponível: %)', v_estoque;
    END IF;

    v_subtotal := v_preco * p_quantidade;
    v_desconto := fn_calcular_desconto(v_subtotal);

    INSERT INTO vendas (cliente_id, desconto, total)
    VALUES (p_cliente_id, v_desconto, v_subtotal - v_desconto)
    RETURNING id INTO p_venda_id;

    INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario)
    VALUES (p_venda_id, p_produto_id, p_quantidade, v_preco);

    UPDATE produtos SET estoque = estoque - p_quantidade WHERE id = p_produto_id;
END;
$$;
