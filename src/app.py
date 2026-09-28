import os
import psycopg2
import psycopg2.extras
from flask import Flask, render_template, request, redirect, url_for, flash

app = Flask(__name__)
app.secret_key = "troque-esta-chave"


def conectar():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "loja"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "nova_senha"),
    )


def consultar(sql, params=None):
    con = conectar()
    try:
        with con, con.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            return cur.fetchall()
    finally:
        con.close()


def executar(sql, params=None):
    con = conectar()
    try:
        with con, con.cursor() as cur:
            cur.execute(sql, params)
    finally:
        con.close()


@app.route("/")
def dashboard():
    # Usa a VIEW para consolidar os indicadores
    resumo = consultar(
        "SELECT COUNT(DISTINCT venda_id) AS vendas, COALESCE(SUM(quantidade),0) AS itens, "
        "COALESCE(SUM(subtotal - desconto),0) AS faturamento FROM vw_relatorio_vendas"
    )[0]
    top = consultar(
        "SELECT produto, SUM(quantidade) AS qtd FROM vw_relatorio_vendas "
        "GROUP BY produto ORDER BY qtd DESC LIMIT 5"
    )
    return render_template("dashboard.html", resumo=resumo, top=top)


@app.route("/produtos", methods=["GET", "POST"])
def produtos():
    if request.method == "POST":
        executar(
            "INSERT INTO produtos (nome, preco, estoque) VALUES (%s,%s,%s)",
            (request.form["nome"], request.form["preco"], request.form["estoque"]),
        )
        flash("Produto cadastrado.")
        return redirect(url_for("produtos"))
    return render_template("produtos.html", produtos=consultar("SELECT * FROM produtos ORDER BY id"))


@app.route("/clientes", methods=["GET", "POST"])
def clientes():
    if request.method == "POST":
        try:
            executar("INSERT INTO clientes (nome, email) VALUES (%s,%s)",
                     (request.form["nome"], request.form["email"]))
            flash("Cliente cadastrado.")
        except psycopg2.Error:
            flash("Erro: e-mail já cadastrado.")
        return redirect(url_for("clientes"))
    return render_template("clientes.html", clientes=consultar("SELECT * FROM clientes ORDER BY id"))


@app.route("/nova-venda", methods=["GET", "POST"])
def nova_venda():
    preview = None
    if request.method == "POST":
        cliente = request.form["cliente_id"]
        produto = request.form["produto_id"]
        qtd = int(request.form["quantidade"])
        if request.form["acao"] == "calcular":
            # Usa a FUNCTION para mostrar o desconto antes de confirmar
            r = consultar(
                "SELECT preco * %s AS subtotal, fn_calcular_desconto(preco * %s) AS desconto "
                "FROM produtos WHERE id = %s", (qtd, qtd, produto))[0]
            preview = {"subtotal": r["subtotal"], "desconto": r["desconto"],
                       "total": r["subtotal"] - r["desconto"]}
        else:
            con = conectar()
            try:
                # Usa a PROCEDURE para registrar a venda
                with con, con.cursor() as cur:
                    cur.execute("CALL sp_realizar_venda(%s, %s, %s, NULL)", (cliente, produto, qtd))
                    venda_id = cur.fetchone()[0]
                flash(f"Venda #{venda_id} registrada com sucesso.")
                return redirect(url_for("relatorio"))
            except psycopg2.Error as e:
                flash("Erro: " + (e.diag.message_primary or "falha ao registrar venda"))
            finally:
                con.close()
    return render_template("nova_venda.html", preview=preview,
                           clientes=consultar("SELECT id, nome FROM clientes ORDER BY nome"),
                           produtos=consultar("SELECT id, nome, preco, estoque FROM produtos ORDER BY nome"))


@app.route("/relatorio")
def relatorio():
    # Usa a VIEW para listar as vendas
    linhas = consultar("SELECT * FROM vw_relatorio_vendas ORDER BY data_venda DESC, venda_id DESC")
    return render_template("relatorio.html", linhas=linhas)


if __name__ == "__main__":
    app.run(debug=True)
