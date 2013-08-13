Table = require('cli-table')

module.exports = (BasePlugin) ->

    class BenchmarkPlugin extends BasePlugin

        name: 'benchmark'
        constructor: ->
            timers = {
                general: Date.now()
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
                @[before] = ->
                    console.log before + '...'
                    timers[after] = Date.now()
                # end timer
                @[after] = ->
                    timers[after] = Date.now() - timers[after]
                    console.log '\n' + after + ' in ' + timers[after] + 'ms (' + (Date.now() - timers.general) + 'ms)'
                    # last event
                    displayTotal() if after == 'generateAfter'

            # recap in a fancy table
            displayTotal = ->
                total = Date.now() - timers.general
                table = new Table {
                    head: ['event', 'time in ms', 'percentage']
                }
                for timer, ms of timers
                    if timer != 'general' and timer != 'generateAfter'
                        table.push [timer,  ms, Math.round(ms * 100 / total) + '%']
                table.push ['Total', total, '']
                console.log table.toString()
            super