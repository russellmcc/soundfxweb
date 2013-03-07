define ["cs!pitchednoise"], (createNoise) -> $ ->
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

  audio = new webkitAudioContext()

  # final gain stage
  amp = audio.createGain()
  amp.connect audio.destination

  dialParamLink '#gain', amp.gain

  # this represents the main VCO of the remco.
  # it's a square wave.
  vco = audio.createOscillator()
  vco.type = vco.SQUARE
  vco.connect amp
  vco.start 0

  dialRangeLink '#vcoFreq',
    '#vcoRange',
    vco.frequency,
    [100, 400, 1000, 5000],
    logScale .1, 1

  # this controls the modulation routing from the SLF to the vco.
  slf_mod = audio.createGain()
  slf_mod.connect vco.frequency

  dialParamLink '#slfmod', slf_mod.gain, (v) -> 50 + 980 * v

  # this is the so-called "super low frequency" oscillator
  slf = audio.createOscillator()
  slf.type = slf.TRIANGLE
  slf.connect slf_mod
  slf.start 0

  dialRangeLink '#slfFreq',
    '#slfRange',
    slf.frequency,
    [1,10,100,5000],
    logScale .1, 1

  noise = createNoise audio
  noise.connect amp

  dialParamLink '#noise', noise.pitch, (logScale 50, 10000)
  