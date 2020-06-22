require "test_helper"

class LexTest < ActiveSupport::TestCase
  include Lexer

  @@source = "daftar nasi goreng harga 10000 es teh harga 2000 tambah nasi goreng jumlah 1 es teh jumlah 2 uang 50000"

  test "produce tokens" do
    tokens = lex(@@source)
    assert tokens != nil
    # daftar
    assert tokens[0].value == "daftar"
    assert tokens[0].kind == TOKEN_KIND_KEYWORD

    ## 1000
    assert tokens[4].value == "10000"

    # nasi goreng
    assert tokens[1].value == "nasi"
    assert tokens[1].kind == TOKEN_KIND_VALUE
    # jumlah
    assert tokens[12].value == "jumlah"
    assert tokens[12].kind == TOKEN_KIND_KEYWORD
    # last
    assert tokens[-1].value == "50000"
    assert tokens[-1].kind == TOKEN_KIND_VALUE
  end

  test "produce statement" do
    statements = parse(@@source)
    # actually just 3 statements
    assert_equal 3, statements.length
    # statement 1
    assert_equal AST_KIND_REG, statements[0].ast_kind
    assert_equal "nasi goreng", statements[0]["reg_statement"][0]["name"]
    assert_equal "10000", statements[0]["reg_statement"][0]["price"]
    assert_equal "es teh", statements[0]["reg_statement"][1]["name"]
    assert_equal "2000", statements[0]["reg_statement"][1]["price"]
    # statement 2
    assert_equal AST_KIND_ADD, statements[1].ast_kind
    assert_equal "nasi goreng", statements[1]["add_statement"][0]["name"]
    assert_equal "1", statements[1]["add_statement"][0]["qty"]
    assert_equal "es teh", statements[1]["add_statement"][1]["name"]
    assert_equal "2", statements[1]["add_statement"][1]["qty"]
    # statement 3
    assert_equal AST_KIND_CASH, statements[2].ast_kind
    assert_equal "50000", statements[2]["cash_statement"]
  end

  test "throw invalid syntax" do
    # s1 = ""
    s2 = "tambah es susu"
    s3 = "es susu"
    s4 = "tambah es susu harga 12000"
    s5 = "tambah tambah"
    s6 = "daftar harga"
    s7 = "uang jumlah"

    # assert_raise "invalid syntax" do parse s1 end
    assert_raise "invalid syntax" do parse s2 end
    assert_raise "invalid syntax" do parse s3 end
    assert_raise "invalid syntax" do parse s4 end
    assert_raise "invalid syntax" do parse s5 end
    assert_raise "invalid syntax" do parse s6 end
    assert_raise "invalid syntax" do parse s7 end
  end

  test "change by known words" do
    source = "tambah tahu jumlah tiga tambah tempe jumlah loro"
    tokens = lex(source)

    assert_equal "3", tokens[3].value
    assert_equal "2", tokens[-1].value
  end
end
