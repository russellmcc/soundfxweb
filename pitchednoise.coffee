define [], ->
  # workaround for a webkit bug where js audio nodes can be incorrectly
  # garbage collected - holding a global pointer fixes this.
  globalID = 0
  
  (audio) ->
    # this controls the "pitch" of the noise.
    n = audio.createScriptProcessor(1024, 0, 1)
    n._out = 0
    n._phasor = 0
    n.pitch = {value: 100}

    n.onaudioprocess = (e) ->
      # period in samples is the sample rate / pitch.
      buffer = e.outputBuffer
      period = buffer.sampleRate / n.pitch.value

      channels = for i in [0...buffer.numberOfChannels]
        buffer.getChannelData(i)
        
      for i in [0...buffer.length]
        n._phasor += 1
        if n._phasor > period
          n._out = Math.random() * 2 - 1
          n._phasor = 0
          
        for j in [0...buffer.numberOfChannels]
          channels[j][i] = n._out

    window["_pitchednoiseWorkaround#{globalID++}"] = n
    n