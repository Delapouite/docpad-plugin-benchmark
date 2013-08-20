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

			# events after/before couples to listen to
			deltas = [
				'generate'
				'parse'
				'populateCollections'
				'contextualize'
				'render'
				'renderCollection'
				'write'
				'server'
			]

			# register the events above
			deltas.forEach (delta) =>
				before = delta + 'Before'
				after = delta + 'After'

				# start timer and log
				@[before] = (opts) ->
					stepName = delta + (opts.renderPass or '')
					steps[stepName] = time: Date.now()
					if opts.collection?.length
						steps[stepName].files = opts.collection.length

					console.log before + '...\n'

				# end timer and log
				@[after] = (opts) ->
					stepName = delta + (opts.renderPass or '')
					steps[stepName].time = Date.now() - steps[stepName].time

					console.log '\n' + stepName + ' in ' + steps[stepName].time + 'ms (' + (Date.now() - steps.general.time) + 'ms)'
					# last event
					displayTotal() if stepName == 'generate'

			# recap in a fancy table
			displayTotal = ->
				total = Date.now() - steps.general.time
				table = new Table {
					head: ['event', 'time (ms)', 'time percentage', 'files', 'time per file (ms)']
				}
				for stepName, step of steps
					if stepName != 'general' and stepName != 'generate'
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