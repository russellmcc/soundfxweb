define [], ->
  # web audio bug...
  globalID = 0
  context: (a) ->
    patches =
      createGain: 'createGainNode'
      createScriptProcessor: 'createJavaScriptNode'
    for k,v of patches
      a[k] ?= a[v]
  oscillator: (o) ->
    o.start ?= o.noteOn

  # yikes! this is required because of safari's bad behavior
  # when connecting streams to parameters.
  #
  # a: audiocontext
  # p: parameter to modulate
  # m: modulation source
  # returns: parameter that represents the "baseline"
  createParamModulation: (a, p, m) ->
    # chrome doesn't need a separate node for offsetting.'
    if /Chrome/.test navigator.userAgent
      m.connect p
      return p
      
    n = a.createScriptProcessor 1024,1,1
    n.offset = value: 0
    n.onaudioprocess = (e) ->
      # period in samples is the sample rate / frequency.
      outBuffer = e.outputBuffer
      inBuffer = e.inputBuffer
      
      outChannels = for i in [0...outBuffer.numberOfChannels]
        outBuffer.getChannelData(i)
      inChannels = for i in [0...inBuffer.numberOfChannels]
        inBuffer.getChannelData(i)
      for i in [0...outBuffer.length]
        for j in [0...outBuffer.numberOfChannels]
          outChannels[j][i] = n.offset.value + inChannels[j][i]
    window["_safariPatchOffset#{globalID++}"] = n
    m.connect n
    n.connect p
    n.offset