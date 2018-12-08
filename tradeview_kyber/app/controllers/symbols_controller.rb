class SymbolsController < ApplicationController


  def index

    q = "SELECT
              if(sellCurrencyId<buyCurrencyId,concat(sellSymbol,'/',buySymbol),concat(buySymbol,'/',sellSymbol)) pairs,
              count() trades
          FROM analytics.trades
          WHERE contract_type='DEX/Kyber Network v2'
          GROUP BY pairs
          HAVING trades>100
          ORDER BY trades DESC"

   r = Clickhouse.connection.query(q).to_hashes

    pairs = r.collect do |s|
      pair = s['pairs']

      {
          symbol: pair,
          token1: {
              name: pair.split('/')[0]
          },
          token2: {
              name: pair.split('/')[1]
          },
          exchange: 'Kyber'
      }

    end

    render json: pairs
  end

end
