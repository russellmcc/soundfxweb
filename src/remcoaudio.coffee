#
# This module returns a function that creates an audio context
# for the remco soundfxmachine
#
# it requires an audio context,
# and a backbone Model representing the current preset.
#
define ["cs!pitchednoise", "cs!safaripatch", "cs!bindings"],
(createNoise, patch, bindings) -> (audio, preset) ->
  patch.context audio

  # final gain stage
  output = audio.createGain()
  output.connect audio.destination
  
  amp = audio.createGain()
  amp.connect output
  amp.gain.value = 0
  
  # this represents the main VCO of the remco.
  # it's a square wave.
  vco = audio.createOscillator()
  patch.oscillator vco
  vco.type = vco.SQUARE
  vco.frequency.value = 0
  vco.start 0
  
  # this controls the modulation routing from the SLF to the vco.
  vcomod = audio.createGain()
  vcomod.gain.value = 300
  # goddamn safari.
  vcooffset = patch.createParamModulation audio, vco.frequency, vcomod

  createWaveShaperFromCurve = (curve) ->
    n = audio.createWaveShaper()
    n.curve = new Float32Array(curve)
    n

  # when using the SLF as an audio signal it is squared up.
  slfAudio = createWaveShaperFromCurve [-1,1]

  # this is the so-called "super low frequency" oscillator
  slf = audio.createOscillator()
  patch.oscillator slf
  slf.type = slf.TRIANGLE
  slf.connect vcomod
  slf.connect slfAudio
  slf.start 0

  gateAmp = audio.createGain()
  gateAmp.gain.value = 0
  gate = createWaveShaperFromCurve [0, 1]
  gate.connect gateAmp.gain

  subgateAmp = audio.createGain()
  subgateAmp.gain.value = 0
  subgate = createWaveShaperFromCurve [0, 1]
  subgate.connect subgateAmp.gain
  
  noise = createNoise audio

  setMixerState = (m0, m1, m2) ->
    a = arguments
    m = (i) -> Math.pow(2, i) * a[i]
    state = _.foldl(m x for x in [0..2], ((a, b) -> a + b), 0)
    vco.disconnect()
    slfAudio.disconnect()
    noise.disconnect()
    gateAmp.disconnect()
    subgateAmp.disconnect()

    doGate = (g, s) ->
      s.connect gateAmp
      g.connect gate
      gateAmp.connect amp

    doSubGate = (g0, g1, s) ->
      s.connect subgateAmp
      g0.connect subgate
      doGate g1, subgateAmp
      
    switch state
      when 0 then vco.connect amp
      when 1 then slfAudio.connect amp
      when 2 then noise.connect amp
      when 3 then doGate vco, noise
      when 4 then doGate slfAudio, noise
      when 5 then doSubGate slfAudio, noise, vco
      when 6 then doGate slfAudio, vco
      # 7 is "off"

  setOneShotState = (oneShot) ->
    amp.gain.cancelScheduledValues audio.currentTime
    amp.gain.setValueAtTime 1 - oneShot, audio.currentTime

  attack = value: 1
  decay = value: 1
  
  triggerOneShot = ->
    if preset.get 'oneshotstate'
      a = attack.vaue
      d = decay.value
      amp.gain.setValueAtTime 0, audio.currentTime
      amp.gain.linearRampToValueAtTime 1, audio.currentTime + a
      amp.gain.linearRampToValueAtTime 0,
        audio.currentTime + a + d

  b = new bindings preset
  b.bindParam 'volume', output.gain
  b.bindParam 'noise', noise.frequency, bindings.logScale 50, 10000
  b.bindParam 'attack', attack, bindings.logScale .1, 3
  b.bindParam 'decay', decay, bindings.logScale .1, 3
  b.bindRange 'slfFreq', 'slfRange', slf.frequency,
    [1,10,100,5000], bindings.logScale .1, 1
  b.bindRange 'vcoFreq', 'vcoRange', vcooffset,
    [100,400,1000,5000], bindings.logScale .1, 1
  b.bindFunc ("mixer#{i}" for i in [0..2]), setMixerState
  b.bindFunc ['oneshotstate'], setOneShotState

  # return a collection of exposed parameters
  {
    triggerOneShot: triggerOneShot
    getLength: ->
      console.log attack.value + decay.value
      attack.value + decay.value
  }