require [], -> $ ->
  dial = (sel, c) ->
    ($ sel).dial
      flatMouse: yes
      width: 100
      displayInput: no
      angleArc:270
      angleOffset:225
      change: c

  dialLink = (sel, param, scale) ->
    scale ?= (v) -> v
    dial sel, (v) -> param.value = scale v/100
    param.value = scale ($ sel)[0].value/100
                  
  audio = new webkitAudioContext()

  # final gain stage
  amp = audio.createGain()
  amp.connect audio.destination

  dialLink '#gain', amp.gain

  # this represents the main VCO of the remco.
  # it's a square wave.
  vco = audio.createOscillator()
  vco.type = vco.SQUARE
  vco.connect amp
  vco.start 0

  dialLink '#freq', vco.frequency, (v) -> 1000 * v

  # this controls the modulation routing from the SLF to the vco.
  slf_mod = audio.createGain()
  slf_mod.connect vco.frequency

  dialLink '#slfmod', slf_mod.gain, (v) -> 100*v

  # this is the so-called "super low frequency" oscillator
  slf = audio.createOscillator()
  slf.type = slf.TRIANGLE
  slf.connect slf_mod
  slf.start 0
  
  dialLink '#slf', slf.frequency, (v) -> 100 * v

  onOffCurve = new Float32Array(3);
  onOffCurve[0] = .1
  onOffCurve[1] = 0  
  onOffCurve[2] = 0

  slf_onOff = audio.createWaveShaper()
  slf_onOff.curve = onOffCurve
  slf.connect slf_onOff
  slf_onOff.connect amp.gain
  