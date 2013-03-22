define ["jquery",
        "cs!remcoaudio",
        "cs!dialUtils",
        "cs!checkUtils",
        "cs!models/preset"], ($, remcoAudio, dial, check, preset) -> -> $ ->

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
  currPreset.updateFromLocalStorage()
  do ->
    href = window.location.href
    qs = (href.slice (href.indexOf '?') + 1)
    currPreset.updateFromString qs
   
  audio = new webkitAudioContext
  remco = remcoAudio audio, currPreset

  currPreset.on 'change', ->
    currPreset.saveToLocalStorage()
    href = window.location.href
    i = href.indexOf '?'
    href = href[0...i] if i?
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