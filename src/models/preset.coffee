define [], ->
  Backbone.Model.extend
    initialize:
      @attrsMin = {}
      ([mk] = k) for k, mk in @minAttrs
        
    minAttrs:
      volume: 'v'
      vcoFreq: 'f'
      vcoRange: 'r'
      slfFreq: 'sf'
      slfRange: 'sr'
      noise: 'n'
      attack: 'a'
      decay: 'd'

    loadFromLocalStorage: ->
      c = {}
      for k, mk in @minAttrs
        c[k] = localStorage[mk] if localStorage[mk]?
      @set c
    loadFromString: (s) ->
      console.log s
      c = {}
      qs = s.split '&'
      for q in qs
        qsplit = q.split '='
        k = decodeURIComponent qsplit[0]
        v = decodeURIComponent qsplit[1]
        c[@attrsMin[k]] = parseFloat v if @attrsMin[k]?
      @set c

    saveToLocalStorage: ->
      for k, v in @attributes
        localStorage[@minAttrs[k]] = v if @minAttrs[k]?

    saveToString: ->
      s = []
      e = encodeURIComponent
      for k, v in @attributes
        s.push "#{e @minAttrs[k]} = {e v}" if @minAttrs[k]
      s.join '&'