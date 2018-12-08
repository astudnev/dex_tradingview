
SELECT
    argument,
    value,
    tx_hash
FROM production.arguments
WHERE signature_id = 318151
LIMIT 10

---

SELECT
  max(tx_time) tx_time,

  maxIf(value, argument='destToken')='0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ? 1 : dictGetUInt64('currency_view', 'currency_id', tuple(maxIf(value, argument='destToken'))) buyCurrencyId,
  maxIf(value, argument='srcToken')='0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ? 1 : dictGetUInt64('currency_view', 'currency_id', tuple(maxIf(value, argument='srcToken'))) sellCurrencyId,

  dictGetString('currency', 'symbol', toUInt64(buyCurrencyId)) as buyCurrency,
  dictGetString('currency', 'symbol', toUInt64(sellCurrencyId)) as sellCurrency,

  sumIf(number, argument='destAmount')/dictGetUInt64('currency', 'divider', toUInt64(buyCurrencyId)) as orderAmountBuy,
  sumIf(number, argument='srcAmount')/dictGetUInt64('currency', 'divider', toUInt64(buyCurrencyId)) as orderAmountSell

FROM production.arguments
WHERE signature_id=318151 and tx_date=today()
GROUP BY tx_hash,call_path,smart_contract_id,smart_contract_address,tx_sender
LIMIT 10

---


SELECT
  max(tx_time) tx_time,

  maxIf(value, argument='destToken')='0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ? 1 : dictGetUInt64('currency_view', 'currency_id', tuple(maxIf(value, argument='destToken'))) buyCurrencyId,
  maxIf(value, argument='srcToken')='0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ? 1 : dictGetUInt64('currency_view', 'currency_id', tuple(maxIf(value, argument='srcToken'))) sellCurrencyId,

  dictGetString('currency', 'symbol', toUInt64(buyCurrencyId)) as buyCurrency,
  dictGetString('currency', 'symbol', toUInt64(sellCurrencyId)) as sellCurrency,

  sumIf(number, argument='destAmount')/dictGetUInt64('currency', 'divider', toUInt64(buyCurrencyId)) as orderAmountBuy,
  sumIf(number, argument='srcAmount')/dictGetUInt64('currency', 'divider', toUInt64(buyCurrencyId)) as orderAmountSell

FROM production.arguments
WHERE signature_id=318151 and tx_date=today()
GROUP BY tx_hash,call_path,smart_contract_id,smart_contract_address,tx_sender
HAVING buyCurrency='ETH' AND sellCurrency='DAI'

---

SELECT
  max(tx_time) tx_time,

  tx_hash,

  maxIf(value, argument='destToken')='0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ? 1 : dictGetUInt64('currency_view', 'currency_id', tuple(maxIf(value, argument='destToken'))) buyCurrencyId,
  maxIf(value, argument='srcToken')='0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ? 1 : dictGetUInt64('currency_view', 'currency_id', tuple(maxIf(value, argument='srcToken'))) sellCurrencyId,

  dictGetString('currency', 'symbol', toUInt64(buyCurrencyId)) as buyCurrency,
  dictGetString('currency', 'symbol', toUInt64(sellCurrencyId)) as sellCurrency,

  sumIf(number, argument='destAmount')/dictGetUInt64('currency', 'divider', toUInt64(buyCurrencyId)) as orderAmountBuy,
  sumIf(number, argument='srcAmount')/dictGetUInt64('currency', 'divider', toUInt64(buyCurrencyId)) as orderAmountSell,

  orderAmountBuy/orderAmountSell AS rate

FROM production.arguments
WHERE signature_id=318151 and tx_date=today()
GROUP BY tx_hash,call_path,smart_contract_id,smart_contract_address,tx_sender
HAVING buyCurrency='ETH' AND sellCurrency='DAI'
