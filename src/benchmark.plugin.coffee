Table = require('cli-table')

module.exports = (BasePlugin) ->

	class BenchmarkPlugin extends BasePlugin

		name: 'benchmark'
		config:
			enabled: true

		constructor: ->
			steps = {
				general:
					time: Date.now()
			}

			# events couples to listen to
			deltas = [
				['generateBefore', 'generateAfter']
				['parseBefore', 'parseAfter']
				['populateCollectionsBefore', 'populateCollections']
				['contextualizeBefore', 'contextualizeAfter']
				['renderBefore', 'renderAfter']
				['writeBefore', 'writeAfter']
				['serverBefore', 'serverAfter']
			]

			# register the events above
			deltas.forEach (delta) =>
				before = delta[0]
				after = delta[1]
				# start timer
				@[before] = (opts) ->
					console.log before + '...'
					steps[after] = time: Date.now()
					if opts.collection?.length
						steps[after].files = opts.collection.length
				# end timer
				@[after] = ->
					steps[after].time = Date.now() - steps[after].time
					console.log '\n' + after + ' in ' + steps[after].time + 'ms (' + (Date.now() - steps.general.time) + 'ms)'
					# last event
					displayTotal() if after == 'generateAfter'

			# recap in a fancy table
			displayTotal = ->
				total = Date.now() - steps.general.time
				table = new Table {
					head: ['event', 'time (ms)', 'time percentage', 'files', 'time per file (ms)']
				}
				for stepName, step of steps
					if stepName != 'general' and stepName != 'generateAfter'
						table.push [
							stepName
							step.time
							Math.round(step.time * 100 / total) + '%'
							step.files || ''
							Math.round(step.time / step.files) || ''
						]
				table.push ['Total', total, '', '', '']
				console.log table.toString()
			super