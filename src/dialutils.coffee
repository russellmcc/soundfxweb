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
        e.globalChangeHook?(sel, v/maxDial)
        yes
    ($ sel)[0].sync = ->
      c e.getVal sel
      e.globalChangeHook?(sel, e.getVal sel)

  e.setVal = (sel, v) ->
    (($ sel).val v * maxDial).trigger 'change'
    ($ sel)[0].sync()
    
    
  e.funcLink = (sel, f, scale) ->
    scale ?= (v) -> v
    dial sel, (v) -> f scale v
    f scale e.getVal sel

  e.paramLink = (sel, p, scale) ->
    e.funcLink sel,
      ((v) -> p.value = v), scale

  e.rangeLink = (valSel, rangeSel, param, ranges, vScale) ->
    vScale ?= (v) -> v
    calc = (r) -> (v) ->
      # range value
      rV = if r then v else (e.getVal rangeSel)
      # "value" value
      vV = if r then (e.getVal valSel) else v
      range = Math.floor rV * (ranges.length - .001)
      ranges[range] * vScale vV
    e.paramLink valSel, param, calc no
    e.paramLink rangeSel, param, calc yes

  e.logScale = (min, max, base) ->
    base ?= 2
    l = (x) -> (Math.log x)/(Math.log base)
    logmin = l min
    logmax = l max
    (v) ->
      Math.pow(base, v * (logmax - logmin) + logmin)
      
  e