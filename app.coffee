define ["jquery",
        "cs!remcoaudio",
        "cs!dialUtils"], ($, remcoAudio, dial) -> -> $ ->

  getCheckVal = (sel) -> if ($ sel).attr('checked') then 1 else 0
  getMixerState = ->
    m = (i) -> Math.pow(2, i) * getCheckVal "#mixer#{i}"
    (m 0) + (m 1) + (m 2)

  getOneShotState = -> getCheckVal '#oneshotstate'

  remco = remcoAudio()

  dial.paramLink '#volume', remco.volume
  dial.rangeLink '#vcoFreq',
    '#vcoRange',
    remco.vco,
    [100, 400, 1000, 5000],
    dial.logScale .1, 1
  dial.rangeLink '#slfFreq',
    '#slfRange',
    remco.slf,
    [1,10,100,5000],
    dial.logScale .1, 1
  dial.paramLink '#noise', remco.noise, (dial.logScale 50, 10000)
  dial.paramLink '#attack', remco.attack, (dial.logScale .1, 3)
  dial.paramLink '#decay', remco.decay, (dial.logScale .1, 3)

  syncMixer = -> remco.setMixerState getMixerState()
  $('.mixer').bind 'change', syncMixer
  $('.mixer').bind 'click', (e) -> $(e).trigger 'change'
  syncMixer()

  syncOneShot = -> remco.setOneShotState getOneShotState()
  $('#oneshotstate').bind 'change', syncOneShot
  $('#oneshotstate').bind 'click', syncOneShot
  syncOneShot()
  $('#oneshot').click remco.triggerOneShot

  # preset logic
  dialParams =
    volume: 'v'
    vcoFreq: 'f'
    vcoRange: 'r'
    slfFreq: 'sf'
    slfRange: 'sr'
    noise: 'n'
    attack: 'a'
    decay: 'd'
             
  selectParams =
    oneshotstate: 'o'
    mixer0: 'm0'
    mixer1: 'm1'
    mixer2: 'm2'

  applyPreset = (p) ->
    for d,k of dialParams
      dial.setVal "##{d}", p[k]
    for s,k of selectParams
      ($ "##{s}").attr('checked', p[k] > 0).trigger 'change'

  createPreset = () ->
    p = {}
    for d,k of dialParams
      p[k] = dial.getVal "##{d}"
    for s,k of selectParams
      p[k] = getCheckVal "##{s}"
    p

  getPresetFromURL = ->
    href = window.location.href
    qs = (href.slice (href.indexOf '?') + 1).split '&'
    p = {}
    for q in qs
      qsplit = q.split '='
      p[decodeURIComponent qsplit[0]] = parseFloat decodeURIComponent qsplit[1]
    p
    
  getURLFromPreset = (p) ->
    href = window.location.href
    i = href.indexOf '?'
    href = href[0...i] if i?
    href += '?'
    for k,v of p
      href += encodeURIComponent k
      href += '='
      href += encodeURIComponent v
      href += '&'
    href[0...href.length - 1]

  # update the share url and localStorage whenever anything changes
  savePreset = (p) ->
    ($ '#shareURL').html(getURLFromPreset p)
    (localStorage[k] = v) for k,v of p
        
  dial.globalChangeHook = (sel, v) ->
    p = createPreset()
    p[dialParams[sel[1...sel.length]]] = v
    savePreset p
  ($ '.switch').bind 'change', -> savePreset createPreset()
    
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

  preset = {}

  # update with localstorage and the url Preset
  urlPreset = getPresetFromURL()
  
  updateForKey = (dk, k) ->
    preset[k] = defaultPreset[dk]
    preset[k] = localStorage[k] if localStorage?[k]?
    preset[k] = urlPreset[k] if urlPreset[k]?
    
  updateForKey d,k for d,k of dialParams
  updateForKey s,k for s,k of selectParams

  applyPreset preset

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
      tempO = remco.audio.createOscillator()
      tempO.noteOn 0
      tempO.noteOff 0
      ($ '#touchToStart').hide()

  ($ '#loading').hide()