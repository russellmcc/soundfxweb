define [], ->
  e = {} # exports

  e.getVal = (sel) -> if ($ sel).attr 'checked' then 1 else 0
  e.setVal = (sel, v, nosync) ->
    (($ sel).attr 'checked', v > 0)
    ($ sel).trigger 'change' unless nosync
    
  # for backbone models
  e.modelLink = (sel, model, param) ->
    c = ($ sel)
    c.bind 'change', ->
      model.set param, e.getVal sel, {fromCheck: c}
    model.on "change:#{param}", (m, v, o) ->
      e.setVal sel, v if o.fromCheck isnt c
    if (model.get param)?
      e.setVal sel, (model.get param), yes
  e