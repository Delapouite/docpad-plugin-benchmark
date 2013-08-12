
module.exports = (BasePlugin) ->

    class BenchmarkPlugin extends BasePlugin

        name: 'benchmark'
        constructor: ->
            deltas = [
                ['generateBefore', 'generateAfter']
                ['parseBefore', 'parseAfter']
                ['populateCollectionsBefore', 'populateCollections']
                ['contextualizeBefore', 'contextualizeAfter']
                ['renderBefore', 'renderAfter']
                ['writeBefore', 'writeAfter']
                ['serverBefore', 'serverAfter']
            ]
            deltas.forEach (delta) =>
                before = delta[0]
                after = delta[1]
                @[before] = ->
                    console.log before + '...'
                    console.time after
                @[after] = ->
                    console.timeEnd after
            super