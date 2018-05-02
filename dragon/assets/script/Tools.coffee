Tools = {
  _spritrFrames :[]
  _prefabs:[]
  arc4random:->
     parseInt(Math.random() * 100000000);

  getStringTime:(time)->
    t = parseInt(time / 3600)
    if(t < 10)
      t = "0" + t
    m = parseInt((time % 3600) / 60)
    if(m < 10)
      m = "0" + m
    s = parseInt(time % 60)
    if(s < 10)
      s = "0" + s

    str = t + ":" + m + ":" + s

    return str

  changeNum:(lable,fromNum,toNum,callback)->
    dt = 0.1
    isup = fromNum <= toNum
    upNum = setInterval ()->
      if isup
        fromNum = Math.ceil(fromNum + ((toNum - fromNum) * dt))
      else
        fromNum = Math.floor(fromNum + ((toNum - fromNum) * dt))
      if isup and fromNum >= toNum or !isup and fromNum <= toNum
        fromNum = toNum
        clearInterval(upNum)
        callback && callback()
      lable.string = fromNum
    ,20

  getEnIndex:(index)->
    switch index
      when 0 then "Zero"
      when 1 then "First"
      when 2 then "Second"
      when 3 then "Third"
      when 4 then "Fourth"
      when 5 then "Fifth"
      when 6 then "Sixth"
      when 7 then "Seventh"
      when 8 then "Eighth"
      when 9 then "Ninth"
      when 10 then "Tenth"
      when 11 then "Eleventh"
      when 12 then "Twelfth"
      when 13 then "Thirteenth"
      when 14 then "Fourteenth"
      when 15 then "Fifteenth"
      when 16 then "Sixteenth"


  translate : () ->
    args = arguments
    args[0].replace /{(\d+)}/g, (match, number) ->
      return args[number] if args[number]?
      return match

  loadRemoteHeadImage : (imageUrl,sprite,size) ->
    return if !imageUrl or !sprite
    size = {width: 64, height: 64} if !size
    cc.loader.load {url: imageUrl, type: 'png'}, (err, texture) =>
      sprite.getComponent(cc.Sprite).spriteFrame = new cc.SpriteFrame texture
      sprite.setScale  size.width / sprite.width ,size.height / sprite.height

  loadImage:(atlas,sprStr)->
    promise = new Promise (resolve, reject) ->
      isfind = false
      lodash.find Tools._spritrFrames,(sprframe)=>
        if(sprframe.name is sprStr)
          isfind = true
          resolve sprframe.frame
      if(!isfind)
        cc.loader.loadRes atlas, cc.SpriteAtlas, (err, atlas)=>
          if err
            cc.log "载入图集失败:#{err}"
            resolve null
          else
            frame = atlas.getSpriteFrame(sprStr)
            Tools._spritrFrames.push({frame:frame,name:sprStr})
            resolve frame

    return promise

  loadUI:(prefabUrl,data) ->
    promise = Tools.loadPrefabs prefabUrl
    promise = promise.then (loadedResource)=>
      if !loadedResource then return null
      view   = cc.instantiate loadedResource
      return view
    return promise

  loadPrefabs:(prefabUrl)->
    promise = new Promise (resolve, reject) ->
      isfind = false
      lodash.find Tools._prefabs,(prefabs)=>
        if(prefabs.Url is prefabUrl)
          isfind = true
          resolve prefabs.prefab
      if(!isfind)
        cc.loader.loadRes prefabUrl , cc.Prefab , (errorMessage,loadedResource) =>
          if errorMessage
            cc.log "载入预制资源失败:#{errorMessage}"
            resolve null
          else
            Tools._spritrFrames.push({Url:prefabUrl,prefab:loadedResource})
            resolve loadedResource
    return promise


  jsonParse: (jsonUrl) ->
    promise = new Promise (resolve, reject) ->
      cc.loader.load cc.url.raw(jsonUrl), (err,res)->
        if err
          return  cc.log "json解析出错 ：#{jsonUrl}"
        resolve res

  getlvName:(lv)->
    switch lv
      when 0 then "kindergarten"
      when 1 then "Grade 1"
      when 2 then "Grade 2"
      when 3 then "Grade 3"
      when 4 then "Grade 4"
      when 5 then "Grade 5"
      when 6 then "Grade 6"
      when 7 then "JGrade 7"
      when 8 then "Grade 8"
      when 9 then "Grade 9"
      when 10 then "Grade 10"
      when 11 then "Grade 11"
      when 12 then "Grade 12"
      when 13 then "Grade 13"
      when 14 then "Grade 14"
      when 15 then "Grade 15"
      when 16 then "Grade 16"

  cutString:(str, len)->
      reg = /[\u4e00-\u9fa5]/g #/[\u4e00-\u9fa5]/g;    #专业匹配中文  "^.+?[^\u4e00-\u9fa5A-Za-z]+.+?$"
      slice = str.substring(0, len);
      chineseCharNum = (~~(slice.match(reg) && slice.match(reg).length));
      realen = slice.length*2 - chineseCharNum;
      return str.substr(0, realen) +  if realen < str.length then "..." else ""

  rand:(n,m)->
    m = m ? 0
    n = n ? 0
    parseInt(Math.random()*(m-n+1)+n,10);
    return Math.floor(Math.random()*(m-n+1)+n);

  setRankLbl:(lbl)->
    _data = DataModel.getModel()
    promise = _data.getRandRank()
    if !promise
      if lbl then lbl.string = _data.getRank()
    else
      promise.then (rank)=>
        if lbl then lbl.string = rank ? 9999

  getPropImgByID:(propID)->
    str = "icon_" + propID
    promise = @loadImage("sheep/Item/Item.plist",str)
    return promise


}

module.exports = Tools;