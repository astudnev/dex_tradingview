var rp = require('request-promise').defaults({json: true})

const api_root = 'https://min-api.cryptocompare.com'
const history = {}

export default {
	history: history,

    getBars: function(symbolInfo, resolution, from, to, first, limit) {
		var split_symbol = symbolInfo.name.split(/[:/]/)
			const aggregation = resolution === '1D' ? 'day' : (resolution == '1' ? 'minute' : 'hour')
			const qs = {
					e: split_symbol[0],
					fsym: split_symbol[1],
					tsym: split_symbol[2],
					to:  to ? to : '',
					from: from ? from : '',
					limit: limit ? limit : 2000,
                	aggregate: aggregation
					// aggregate: 1//resolution 
				}
			// console.log({qs})

        return rp({
                url: 'http://localhost:3001/bars',
                qs,
            })
            .then(data => {
                console.log({data})
				if (data.Response && data.Response === 'Error') {
					console.log('CryptoCompare API error:',data.Message)
					return []
				}
				if (data.Data.length) {
					console.log(`Actually returned: ${new Date(data.TimeFrom * 1000).toISOString()} - ${new Date(data.TimeTo * 1000).toISOString()}`)
					var bars = data.Data.map(el => {
						return {
							time: el.time * 1000, //TradingView requires bar time in ms
							low: el.low,
							high: el.high,
							open: el.open,
							close: el.close,
							volume: el.volumefrom 
						}
					})
						if (first) {
							var lastBar = bars[bars.length - 1]
							history[symbolInfo.name] = {lastBar: lastBar}
						}
					return bars
				} else {
					return []
				}
			})
}
}
