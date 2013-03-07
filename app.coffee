require ["cs!remcoaudio"], (remcoAudio) -> $ ->
  maxDial = 10000
  
  dial = (sel, c) ->
    ($ sel).dial
      flatMouse: yes
      width: 100
      displayInput: no
      angleArc:270
      angleOffset:225
      max: maxDial
      change: c

  getDialVal = (sel) ->
    v = ($ sel)?[0]?.value
    if v? then v/maxDial else 0

  dialFuncLink = (sel, f, scale) ->
    scale ?= (v) -> v
    dial sel, (v) -> f scale (v/maxDial)
    f scale getDialVal sel

  dialParamLink = (sel, p, scale) ->
    dialFuncLink sel,
      ((v) -> p.value = v), scale

  dialRangeLink = (valSel, rangeSel, param, ranges, vScale) ->
    vScale ?= (v) -> v
    calc = (r) -> (v) ->
      # range value
      rV = if r then v else (getDialVal rangeSel)
      # "value" value
      vV = if r then (getDialVal valSel) else v
      range = Math.floor rV * (ranges.length - .001)
      ranges[range] * vScale vV
    dialParamLink valSel, param, calc no
    dialParamLink rangeSel, param, calc yes

  logScale = (min, max, base) ->
    base ?= 2
    l = (x) -> (Math.log x)/(Math.log base)
    logmin = l min
    logmax = l max
    (v) ->
      Math.pow(base, v * (logmax - logmin) + logmin)

  getMixerState = ->
    m = (i) -> Math.pow(2, i) * ~~(($ "#mixer#{i}")[0].value)
    (m 0) + (m 1) + (m 2)

  remco = remcoAudio()

  dialParamLink '#gain', remco.amp
  dialRangeLink '#vcoFreq',
    '#vcoRange',
    remco.vco,
    [100, 400, 1000, 5000],
    logScale .1, 1
  dialParamLink '#slfmod', remco.vcomod, (v) -> 50 + 980 * v

  dialRangeLink '#slfFreq',
    '#slfRange',
    remco.slf,
    [1,10,100,5000],
    logScale .1, 1

  dialParamLink '#noise', remco.noise, (logScale 50, 10000)

  remco.setMixerState getMixerState()

  $(".mixerswitch").change -> remco.setMixerState getMixerState()
    