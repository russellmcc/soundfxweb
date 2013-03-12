define [], -> (length)->
  # iOS safari patch.
  offlineContext = webkitOfflineAudioContext ? webkitAudioContext
  ret = new offlineContext 1, length * 44100, 44100
  ret.renderWav = (comp) ->
    @oncomplete = (e) ->
      samples = e.renderedBuffer.getChannelData(0)
      # based on code from https://github.com/mattdiamond/Recorderjs
      # see COPYING for details
      data = new Int16Array samples.length
      console.log samples
      for i in [0...samples.length]
        s = samples[i]
        data[i] = if s < 0 then s * 0x8000 else s * 0x7FFF
      console.log data
      bb = new Blob [
        'RIFF'
        # length of file after this point
        new Uint32Array [32 + samples.length]
        'WAVE'
        'fmt '
        # length of fmt chunk
        new Uint32Array [16]
        # sample format (1= raw PCM)
        new Uint16Array [1]
        # number of channels
        new Uint16Array [2]
        # sample rate
        new Uint32Array [@sampleRate]
        # byte rate
        new Uint32Array [@sampleRate * 2]
        # bytes per frame
        new Uint16Array [2]
        # bits per sample
        new Uint16Array [16]
        'data'
        # length
        new Uint32Array [samples.length * 2]
        # data
        data
        ]
      comp bb

    @startRendering()
  ret
        