define [], ->
  e = {} # exports
  maxDial = 100

  e.getVal = (sel) ->
    v = ($ sel)?[0]?.value
    if v? then v/maxDial else 0

  dial = (sel, c) ->
    ($ sel).dial
      flatMouse: yes
      width: 100
      height: 100
      displayInput: no
      angleArc:270
      angleOffset:225
      fgColor: "#000"
      noScroll: yes
      max: maxDial
      change: (v) ->
        c v/maxDial
        yes
    ($ sel)[0].sync = ->
      c e.getVal sel

  e.setVal = (sel, v, nosync) ->
    (($ sel).val v * maxDial).trigger 'change'
    ($ sel)[0].sync() unless nosync
    
  # for backbone models
  e.modelLink = (sel, model, param) ->
    d = dial sel, (v) ->
      model.set param, v, {fromDial: d}
    model.on "change:#{param}", (m, v, o) ->
      e.setVal sel, v if o.fromDial isnt d
    if (model.get param)?
      e.setVal sel, model.get param, yes
  e