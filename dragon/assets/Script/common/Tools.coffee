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


}

module.exports = Tools;