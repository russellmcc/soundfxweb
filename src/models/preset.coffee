define [], ->
  Backbone.Model.extend
    initialize: () ->
      @attrsMin = {}
      (@attrsMin[mk] = k) for k, mk of @minAttrs
        
    minAttrs:
      volume: 'v'
      vcoFreq: 'f'
      vcoRange: 'r'
      slfFreq: 'sf'
      slfRange: 'sr'
      noise: 'n'
      attack: 'a'
      decay: 'd'
      mixer0: 'm0'
      mixer1: 'm1'
      mixer2: 'm2'
      oneshotstate: 'o'
      
    loadFromLocalStorage: ->
      c = {}
      for k, mk of @minAttrs
        c[k] = localStorage[mk] if localStorage[mk]?
      @set c

    loadFromString: (s) ->
      c = {}
      qs = s.split '&'
      for q in qs
        qsplit = q.split '='
        k = decodeURIComponent qsplit[0]
        v = decodeURIComponent qsplit[1]
        c[@attrsMin[k]] = parseFloat v if @attrsMin[k]?
      @set c

    saveToLocalStorage: ->
      for k, v of @attributes
        localStorage[@minAttrs[k]] = v if @minAttrs[k]?

    saveToString: ->
      s = []
      e = encodeURIComponent
      for k, v of @attributes
        s.push "#{e @minAttrs[k]}=#{e v}" if @minAttrs[k]
      s.join '&'