class HomeController < ApplicationController
  include Lexer

  def index
  end

  def commands
    statements = parse(params[:commands])

    @items = []
    @cash = 0
    @return = 0
    statements.each do |statement|
      case statement.ast_kind

      when AST_KIND_REG
        arr = statement.reg_statement.map.with_index do |st, index|
          { name: st.name, price: st.price }
        end

        Product.create(arr)
      when AST_KIND_ADD
        @items = @items.push statement.add_statement
      when AST_KIND_CASH
        @cash = statement.cash_statement
      end
    end

    if @items != []
      @return = make_return(@items, @cash)
    end

    render :json => {
      :return => @return,
    }
  end

  private

  def make_return(items, cash)
    products = []
    items[0].each do |item|
      p = Product.where("name = ?", item.name)
      obj = { name: item.name, qty: item.qty, price: p[0].price }
      products.push obj
    end

    total = 0
    products.each do |p|
      total = total + p[:qty].to_i * p[:price].to_i
    end

    return total - cash.to_i
  end
end
