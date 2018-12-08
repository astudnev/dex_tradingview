class BarsController < ApplicationController

  def index

    time_from = params[:from].to_i
    time_to = params[:to].to_i

    fsym = params[:fsym]
    tsym = params[:tsym]

    aggregate = case params[:aggregate]
                when 'day'
                  then 'toUInt32(toStartOfDay(tx_time))'
                when 'hour'
                  then 'toUInt32(toStartOfHour(tx_time))'
                when 'minute'
                  then 'toUInt32(toStartOfMinute(tx_time))'
                end



    q = "SELECT * FROM
        (

        SELECT
            #{aggregate} time,

            argMin(amountBuy/amountSell, tx_time) open,
            argMax(amountBuy/amountSell, tx_time) close,


            sum(amountSell) volumefrom,
            sum(amountBuy) volumeto,

            min(amountBuy/amountSell) low,
            max(amountBuy/amountSell) high

        FROM analytics.trades
        WHERE contract_type='DEX/Kyber Network v2'
        AND sellSymbol='#{fsym}' AND buySymbol='#{tsym}'
        AND tx_time BETWEEN '#{convert_time time_from}' AND '#{convert_time time_to}'
        GROUP BY time

        UNION ALL

        SELECT
            #{aggregate} time,

            argMin(amountSell/amountBuy, tx_time) open,
            argMax(amountSell/amountBuy, tx_time) close,


            sum(amountBuy) volumefrom,
            sum(amountSell) volumeto,

            min(amountSell/amountBuy) low,
            max(amountSell/amountBuy) high


        FROM analytics.trades
        WHERE contract_type='DEX/Kyber Network v2'
        AND sellSymbol='#{tsym}' AND buySymbol='#{fsym}'
        AND tx_time BETWEEN '#{convert_time time_from}' AND '#{convert_time time_to}'
        GROUP BY time

        )

        ORDER BY time"

    data = Clickhouse.connection.query(q).to_hashes

    bars =
        {"Response" => "Success",
         "Type" => 100,
         "Aggregated"=> false,
         "Data": data,
         "TimeTo" => time_to,
         "TimeFrom" => time_from,
         "FirstValueInArray" => true,
          "ConversionType" => {
              "type" => "force_direct",
              "conversionSymbol" => ""},
         "RateLimit" => {},
         "HasWarning" => false}

    render json: bars
  end

  private

  def convert_time t
    Time.at(t).utc.strftime('%Y-%m-%d %H:%M:%S')
  end

end
