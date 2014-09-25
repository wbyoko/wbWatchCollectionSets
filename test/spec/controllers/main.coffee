'use strict'

describe 'Decorator: $rootScope: wbWatchCollectionSets', ->

  beforeEach module 'wbWatchCollectionSetsApp'

  $rootScope = null
  $log = null
  watchFn = null

  flatten = (arr) ->
    arr.reduce ((xs, el) ->
      if Array.isArray el
        xs.concat flatten el
      else
        xs.concat [el]), []

  beforeEach inject (_$rootScope_, _$log_) ->
    $rootScope = _$rootScope_
    $log = _$log_
    watchFn = -> return #noop

  afterEach ->
    do watchFn
    do $log.reset

  describe 'active', ->

    it 'should iterate over an array', ->
      $rootScope.items = [
        'igor'
        'misko'
      ]

      watchFn = $rootScope.wbWatchCollectionSets 'item in items', (newCollection, oldCollection, scope, sets) ->
        sets.active (index, item, isEnter) ->
          itemState = isEnter and "enter" or "update"
          $log.log "#{index}:#{item}:#{itemState}"

      do $rootScope.$digest
      expect(flatten($log.log.logs)).toEqual(["0:igor:enter", "1:misko:enter"])

      do $log.reset
      $rootScope.items.push 'william'
      do $rootScope.$digest
      expect(flatten($log.log.logs)).toEqual(["0:igor:update", "1:misko:update", "2:william:enter"])

      do $log.reset
      do $rootScope.items.shift
      do $rootScope.items.shift
      do $rootScope.$digest
      expect(flatten($log.log.logs)).toEqual(["0:william:enter"])

  describe 'exit', ->

    it 'should iterate over an array', ->
      $rootScope.items = [
        'igor'
        'misko'
      ]

      watchFn = $rootScope.wbWatchCollectionSets 'item in items', (newCollection, oldCollection, scope, sets) ->
        sets.exit (index, item) ->
          $log.log "#{index}:#{item}"

      do $rootScope.$digest
      expect(flatten($log.log.logs)).toEqual([])

      do $log.reset
      $rootScope.items.unshift 'william'
      do $rootScope.$digest
      expect(flatten($log.log.logs)).toEqual([])
      
      do $log.reset
      do $rootScope.items.pop
      do $rootScope.items.pop
      do $rootScope.$digest
      expect(flatten($log.log.logs)).toEqual(["1:igor", "2:misko"])
