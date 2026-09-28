-- Retorna o valor do desconto conforme o subtotal:
-- >= 500: 10% | >= 200: 5% | abaixo disso: sem desconto
CREATE OR REPLACE FUNCTION fn_calcular_desconto(p_subtotal NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_subtotal >= 500 THEN
        RETURN ROUND(p_subtotal * 0.10, 2);
    ELSIF p_subtotal >= 200 THEN
        RETURN ROUND(p_subtotal * 0.05, 2);
    END IF;
    RETURN 0;
END;
$$;
