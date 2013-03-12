define ["jquery",
        "cs!remcoaudio",
        "cs!dialUtils",
        "cs!checkUtils",
        "cs!models/preset",
        "cs!recorder"], ($, remcoAudio, dial, check, preset, rec) -> -> $ ->

  # sensible defaults
  defaultPreset =
    volume: .2
    vcoFreq: .4
    vcoRange: .5
    slfFreq: .8
    slfRange: .7
    noise: .6
    attack: .3
    decay: .8
    oneshotstate: 1
    mixer0: 1
    mixer1: 0
    mixer2: 1

  currPreset = new preset defaultPreset
  currPreset.loadFromLocalStorage()
  do ->
    href = window.location.href
    i = href.indexOf '?'
    currPreset.loadFromString (href.slice i + 1) if i > 0
   
  audio = new webkitAudioContext
  remco = remcoAudio audio, currPreset

  currPreset.on 'change', ->
    currPreset.saveToLocalStorage()
    href = window.location.href
    i = href.indexOf '?'
    href = href[0...i] if i > 0
    href += "?#{currPreset.saveToString()}"
    ($ '#shareURL').html(href)

  # bind UI
  dialParams = [
    'volume',
    'vcoFreq',
    'vcoRange',
    'slfFreq',
    'slfRange',
    'noise',
    'attack',
    'decay',
  ]
  
  dial.modelLink "##{d}", currPreset, d for d in dialParams

  checkParams = [
    'oneshotstate',
    'mixer0',
    'mixer1',
    'mixer2'
  ]

  check.modelLink "##{c}", currPreset, c for c in checkParams
  
  $('#oneshot').click remco.triggerOneShot

  # set up the WAV recording.
  ($ '#download')[0].onclick = ->
    renderC = wavContext remco.attack.value + remco.decay.value
    o = renderC.createOscillator()
    o.type = o.SINE
    o.connect renderC.destination
    o.start 0
    # renderRemco = remcoAudio renderC
    # for k,v of remco
    #   renderRemco[k].value = v.value if v.value?
    # renderRemco.setOneShotState no
    # renderRemco.setMixerState getMixerState()
    renderC.renderWav (blob) ->
      url = (URL ? webkitURL).createObjectURL blob
      link = window.document.createElement 'a'
      link.href = url
      link.download = 'soundfx.wav'
      click = document.createEvent 'Event'
      click.initEvent 'click', true, true
      link.dispatchEvent click

  # hide for iOS until the user clicks to enable audio.
  iOSDevs = [ 'iPad'
            , 'iPod'
            , 'iPhone'
            ]
  iOS = no
  for d in iOSDevs
    (iOS = yes) if navigator.platform is d

  ($ '#touchToStart').hide() unless iOS
  if iOS
    ($ '#touchToStart')[0].onclick = ->
      tempO = audio.createOscillator()
      tempO.noteOn 0
      tempO.noteOff 0
      ($ '#touchToStart').hide()

  ($ '#loading').hide()