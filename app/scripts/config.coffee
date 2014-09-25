'use strict'

###*
 # @ngdoc function
 # @name wbWatchCollectionSetsApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the wbWatchCollectionSetsApp
###
angular.module('wbWatchCollectionSetsApp')
  .config ($provide) ->
      
    $provide.decorator '$rootScope', ($delegate) ->

      $delegate.wbWatchCollectionSets = (watchExp, listener) ->

        match = watchExp.match /^\s*([\s\S]+?)\s+in\s+([\s\S]+?)\s*$/

        unless match
          throw Error "Expected expression in form of '_item_ in _collection_' but got '#{watchExp}'."

        rhs = match[2]

        lastItemMap = {}

        class UpdateSet
          constructor: (@activeSet, @exitSet) ->

          active: (listener) ->
            for key, item of @activeSet
              listener item.index, item.item, item.isEnter

          exit: (listener) ->
            for key, item of @exitSet
              listener item.index, item.item

        $delegate.$watchCollection rhs, (newCollection, oldCollection, scope) ->
          nextItemMap = {}
          exitItemMap = []

          for item, index in newCollection
            key = "#{index}#{item}"

            if lastItemMap.hasOwnProperty key
              #update
              delete lastItemMap[key]
              nextItemMap[key] =
                index: index
                item: item
                isEnter: false
            else if nextItemMap.hasOwnProperty key
              #duplicate
             throw ngRepeatMinErr "Duplicates in a repeater are not allowed"
            else
              #enter
              nextItemMap[key] =
                index: index
                item: item
                isEnter: true

          for key, item of lastItemMap
            #exit
            delete item.isEnter
            exitItemMap[key] = item

          sets = new UpdateSet(nextItemMap, exitItemMap)
          listener newCollection, oldCollection, scope, sets
          lastItemMap = nextItemMap

      $delegate
