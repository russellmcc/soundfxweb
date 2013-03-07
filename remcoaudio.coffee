#
# This module returns a function that creates an audio context
# for the remco soundfxmachine
#
define ["cs!pitchednoise"], (createNoise) -> ->
  audio = new webkitAudioContext()

  # final gain stage
  amp = audio.createGain()
  amp.connect audio.destination

  # this represents the main VCO of the remco.
  # it's a square wave.
  vco = audio.createOscillator()
  vco.type = vco.SQUARE
  vco.start 0

  # this controls the modulation routing from the SLF to the vco.
  vcomod = audio.createGain()
  vcomod.connect vco.frequency

  createWaveShaperFromCurve = (curve) ->
    n = audio.createWaveShaper()
    n.curve = new Float32Array(curve)
    n

  # when using the SLF as an audio signal it is squared up.
  slfAudio = createWaveShaperFromCurve [-1,1]

  # this is the so-called "super low frequency" oscillator
  slf = audio.createOscillator()
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

  setMixerState = (state) ->
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
      when 3 then doGate noise, vco
      when 4 then doGate noise, slfAudio
      when 5 then doSubGate slfAudio, noise, vco
      when 6 then doGate slfAudio, vco
      # 7 is "off"
      

  # return a collection of exposed parameters
  {
    amp: amp.gain
    vco: vco.frequency
    slf: slf.frequency
    vcomod: vcomod.gain
    noise: noise.frequency
    setMixerState: setMixerState
  }
