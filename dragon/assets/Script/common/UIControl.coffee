NetLoading = require "NetLoading"
Tools = require "Tools"
DataModel = require "DataModel"
kVertexZ =
  UISpace   : 400

window.TitleType = {
  Default:0  #默认
  Challenge : 1,  #排位赛
  Leaderboard : 2, #排行榜
  Invite:3,  #邀请赛
  Backpack:4,  #书包
  Library:5,  #图书馆
  School:6,  #学校
  Store:7,  #商店
  Setting:8,  #设置
  SeasonReward:9,  #赛季奖励
  GradeList:10, #段位说明
  UserInfo:11, #玩家信息
  CompareUser:12, #比较信息
  otherUserInfo:13, #比较信息
  LastRank:14, #上届排行榜
};

Dialog = require "Dialog"
_instance = null
UIControl = cc.Class

  extends: cc.Component
  properties:
    "closeBtn": cc.Button
    "title": cc.Label
    "target":cc.Node
    "titleNode":cc.Node

  onLoad:->
    @_zorder = 0
    _instance = this
    @_panelList = [];
#    @changeTitle TitleType.Default

  changeTitle:(type)->
    cc.log("changeTitle:" + type)
    switch type
      when TitleType.Challenge then @setTitle(LANG_TEXT.TitleChallenge)
      when TitleType.Leaderboard then @setTitle(LANG_TEXT.TitleLeaderboard)
      when TitleType.Invite then @setTitle(LANG_TEXT.TitleInvite)
      when TitleType.Backpack then @setTitle(LANG_TEXT.TitleBackpack)
      when TitleType.Library then @setTitle(LANG_TEXT.TitleLibrary)
      when TitleType.School then @setTitle(LANG_TEXT.TitleSchool)
      when TitleType.Store then @setTitle(LANG_TEXT.TitleStore)
      when TitleType.Setting then @setTitle(LANG_TEXT.TitleSetting)
      when TitleType.SeasonReward then @setTitle(LANG_TEXT.seasonreward)
      when TitleType.GradeList then @setTitle(LANG_TEXT.GradeList)
      when TitleType.UserInfo then @setTitle(LANG_TEXT.UserInfo)
      when TitleType.CompareUser then @setTitle(LANG_TEXT.CompareUser)
      when TitleType.otherUserInfo then @setTitle(LANG_TEXT.otherUserInfo)
      when TitleType.LastRank then @setTitle(LANG_TEXT.LastRank)
      else @setTitle("")

  setTitle:(str)->
    cc.log("setTitle:" + str)
    @title.string = if str then str else ""

  open:(PrefabInfo,target)->
    className = PrefabInfo["PefabName"];
    promise = new Promise (resolve, reject) =>
      targetComponent = @current className
      if targetComponent
        resolve targetComponent
      else
        PrefabUrl = "prefabs/" + className
        _promise = Tools.loadUI(PrefabUrl)
        _promise.then (prefab)=>
          if(!prefab)
            Dialog.alert LANG_TEXT.trylater
          else
            top = @top();
            if !target
              target = @target
              @_panelList.push {view:prefab,className:className}
            @_zorder += kVertexZ.UISpace
            target.addChild prefab,@_zorder
          resolve prefab

    return promise

  current:(cls) ->
    if !cls
      _top = @top()
      if _top then _top["view"] else null
    result = lodash.findIndex @_panelList, {className:cls}
    return if result >= 0 then @_panelList[result]["view"] else null

  getComponentByName:(cls)->
    prefab = @current(cls)
    if(prefab)
      panel = prefab.getComponent(cls)
      return panel
    return null

  top:->
    @_panelList = @_panelList or []
    length = @_panelList.length;
    if length then @_panelList[length - 1] else null   #["view"]

  bottom:->
    if @_panelList.length then @_panelList[0] else null  #["view"]

  close:(cls)->
    promise = @closeClassbyName(cls)
    promise = promise.then ()=>
      @showPanel()

  closeAll:->
    lodash.map @_panelList , (_panel)=>
      view = _panel["view"]
      if cc.isValid view then view.destroy()
    @_panelList = []
    @goToMain()

  closeBottom:->
    index = @_panelList.length - 1
    _panel = @_panelList[index]

    if _panel && _panel["view"]
      _view = _panel["view"]
      _layer = _view.getComponent(_panel["className"])
      if _layer and _layer.closePanel?
        _layer.closePanel()
      else
        _view.destroy()
        @_panelList.splice(index, 1)
        @showBackBtn false
        @showPanel()

  showPanel:->
    if @_panelList.length <= 0 then @goToMain() else @showTop()

  showTop:->
    toppanel = @top()
    _show = true
    if toppanel and toppanel["view"]
      _view = toppanel["view"]
      _view.active = true
      _panel = _view.getComponent(toppanel["className"])
      cc.log("toppanel classname:" + toppanel["className"])
#      if(toppanel["className"] is "rankPanel")
#        @showTitle(false)
      _panel.updateData() if _panel and _panel.updateData?
    @showBackBtn(_show)

  getPanelList:->
    return @_panelList.length

  showBackBtn:(isShow)->
    @closeBtn.node.active = isShow

  showTitle:(isShow)->
    @title.node.active = isShow

  showTitleAndBack:(isShow)->
    @showBackBtn isShow
#    @showTitle isShow

  setMainPanel:(@_mainPanel)->

  goToMain:->
    DataModel.getModel().setGameMode(TitleType.Default)
    if @_panelList.length then @closeAll()
#    @changeTitle TitleType.Default
    if(@_mainPanel)
      @_mainPanel.node.active = true;
      @_mainPanel._showPanel = false
      @_mainPanel.upInfoData()
    @showTitleAndBack(false)

  showPrefab:(prefabName,mode,parent)->
    @showTitleAndBack(false)
    NetLoading.show()
    DataModel.getModel().setGameMode(mode) if mode
    promise = @open({PefabName:prefabName},parent)
    promise = promise.then (prefab)=>
      NetLoading.hide()
      panel = if prefab then prefab.getComponent(prefabName) else null
      if(!panel)
        return null
#      @changeTitle mode if mode
#      @changeTitleNodeZord(true)
      return panel
    return promise;

  closeClassbyName:(cls)->
    promise = new Promise (resolve,reject)=>
      result = lodash.findIndex @_panelList, {className:cls}
      _panel = @_panelList[result]
      if !_panel
        resolve false
      view = _panel["view"];
      if view and cc.isValid view
        view.destroy()
        @_panelList.splice result, 1;
        resolve true
    return promise

  changeTitleNodeZord:(isTop)->
    _top = @top()
    if _top
      cc.log("changeTitleNodeZord:" + _top["view"].getLocalZOrder())
      temp = if isTop then  +1 else -1
      zorder = _top["view"].getLocalZOrder() + temp
      @titleNode.setLocalZOrder(zorder)


UIControl.getInstance = ->
  if !_instance
    _instance = new UIControl;
  return _instance

module.exports = UIControl;