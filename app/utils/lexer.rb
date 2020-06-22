# syntax
# daftar {value} harga {value} {value} harga {value}
# tambah {value} jumlah {value} {value} jumlah {value}
# uang {value}

module Lexer

  # keywords
  KEYWORD_REG = "daftar"
  KEYWORD_PRICE = "harga"
  KEYWORD_ADD = "tambah"
  KEYWORD_QTY = "jumlah"
  KEYWORD_CASH = "uang"

  # kinds...
  AST_KIND_REG = "ast_kind_reg"
  AST_KIND_ADD = "ast_kind_add"
  AST_KIND_CASH = "ast_kind_cash"

  TOKEN_KIND_KEYWORD = "token_kind_keyword"
  TOKEN_KIND_VALUE = "token_kind_value"

  # struct for better typing

  Statement = Struct.new :reg_statement, :add_statement, :cash_statement, :ast_kind

  RegItem = Struct.new :name, :price

  AddItem = Struct.new :name, :qty

  Token = Struct.new :value, :kind

  LexOutput = Struct.new :token, :cursor, :bool

  ParseOutput = Struct.new :statement, :cursor, :bool

  # this is function that the tokens come from
  def lex(str)
    tokens = []
    cursor = 0
    while cursor < str.length
      lexers = ["lex_string"]
      lexers.each do |l|
        lex_output = send l, str, cursor
        cur = lex_output.cursor
        token = lex_output.token

        if lex_output.token != nil
          tokens = tokens.append token
        end

        cursor = cur
      end
    end

    # change word by known word
    new_tokens = []

    tokens.each do |token|
      if KNOWN_WORDS.has_key?(token.value)
        token.value = KNOWN_WORDS[token.value]
      end

      new_tokens = new_tokens.append token
    end

    return new_tokens
  end

  # look for match keyword
  def match_keyword(str, cur)
    keywords = [KEYWORD_REG, KEYWORD_PRICE, KEYWORD_ADD, KEYWORD_QTY, KEYWORD_CASH]
    keywords.each do |keyword|
      if keyword == str[cur...keyword.length]
        cur = cur + keyword.length
        token = Token.new keyword, TOKEN_KIND_KEYWORD

        return LexOutput.new token, cur, true
      end
    end

    return LexOutput.new nil, cur, true
  end

  def lex_string(str, cursor)
    cur = cursor
    if str[cur] == " "
      return LexOutput.new nil, cur + 1, true
    end

    value = ""
    while str[cur] != " " && cur != str.length
      value = value + str[cur]
      cur = cur + 1
    end

    lexOutput = match_keyword(value, 0)
    if lexOutput.token != nil
      return LexOutput.new lexOutput.token, cur, true
    end

    token = Token.new value, TOKEN_KIND_VALUE
    return LexOutput.new token, cur, true
  end

  # token should arrange by syntax
  def parse(str)
    tokens = lex(str)
    ast = []

    cursor = 0
    while cursor < tokens.length
      sc = parse_statement(tokens, cursor)
      cursor = sc.cursor

      if sc.bool != false
        ast = ast.append(sc.statement)
      else
        raise "invalid syntax"
      end
    end

    return ast
  end

  def parse_statement(tokens, cursor)
    cur = cursor

    if tokens[cur].value == KEYWORD_REG
      return parse_reg_statement tokens, cur
    end

    if tokens[cur].value == KEYWORD_ADD
      return parse_add_statement tokens, cur
    end

    if tokens[cur].value == KEYWORD_CASH
      return parse_cash_statement tokens, cur
    end

    return ParseOutput.new nil, cur, false
  end

  def parse_reg_statement(tokens, cursor)
    cur = cursor + 1

    reg_items = []

    price = 0

    while tokens[cur].kind != TOKEN_KIND_KEYWORD
      name = ""
      # get the name
      if tokens[cur].kind == TOKEN_KIND_VALUE
        tmp_token = tokens[cur]

        while tmp_token.kind == TOKEN_KIND_VALUE
          name = name + " " + tmp_token.value
          cur = cur + 1
          tmp_token = tokens[cur]
        end

        name = name.strip
      else
        return ParseOutput.new nil, cur, false
      end

      # next should be price
      if tokens[cur].kind == TOKEN_KIND_KEYWORD && tokens[cur].value == KEYWORD_PRICE
        cur = cur + 1
      else
        return ParseOutput.new nil, cur, false
      end

      # next should be nominal
      if tokens[cur].kind == TOKEN_KIND_VALUE
        price = tokens[cur].value
        cur = cur + 1
      else
        return ParseOutput.new nil, cur, false
      end

      reg_item = RegItem.new name, price
      reg_items = reg_items.append reg_item
    end

    reg_statement = reg_items
    statement = Statement.new
    statement.reg_statement = reg_statement
    statement.ast_kind = AST_KIND_REG

    return ParseOutput.new statement, cur, true
  end

  def parse_add_statement(tokens, cursor)
    cur = cursor + 1

    add_items = []
    qty = nil

    while tokens[cur].kind != TOKEN_KIND_KEYWORD
      name = ""

      # get name
      if tokens[cur].kind == TOKEN_KIND_VALUE
        tmp_token = tokens[cur]
        while tmp_token.kind == TOKEN_KIND_VALUE
          name = name + " " + tmp_token.value
          cur = cur + 1
          tmp_token = tokens[cur]
        end

        name = name.strip
      else
        return ParseOutput.new nil, cur, false
      end

      # next should be qty
      if tokens[cur].value == KEYWORD_QTY && tokens[cur].kind == TOKEN_KIND_KEYWORD
        cur = cur + 1
      else
        return ParseOutput.new nil, cur, false
      end

      # next should be value of qty
      if tokens[cur].kind == TOKEN_KIND_VALUE
        qty = tokens[cur].value
        cur = cur + 1
      else
        return ParseOutput.new nil, cur, false
      end

      add_item = AddItem.new name, qty
      add_items = add_items.append add_item
    end

    add_statement = add_items
    statement = Statement.new
    statement.add_statement = add_statement
    statement.ast_kind = AST_KIND_ADD

    return ParseOutput.new statement, cur, true
  end

  def parse_cash_statement(tokens, cursor)
    # just simple cash {value} syntax
    cur = cursor + 1
    cash = nil
    if tokens[cur].kind == TOKEN_KIND_VALUE
      cash = tokens[cur].value
      cur = cur + 1
    else
      return ParseOutput.new nil, cur, false
    end

    cash_statement = cash
    statement = Statement.new
    statement.cash_statement = cash_statement
    statement.ast_kind = AST_KIND_CASH

    return ParseOutput.new statement, cur, true
  end

  KNOWN_WORDS = {
    "satu" => "1",
    "dua" => "2",
    "tiga" => "3",
    "empat" => "4",
    "lima" => "5",
    "enam" => "6",
    "tujuh" => "7",
    "delapan" => "8",
    "sembilan" => "9",
    "sepuluh" => "10",
    "siji" => "1",
    "loro" => "2",
    "telu" => "3",
    "papat" => "4",
    "limo" => "5",
    "enem" => "6",
    "pitu" => "7",
    "wolu" => "8",
    "songo" => "9",
    "sepuloh" => "10",
  }
end
