kVertexZ =
  UISpace   : 400
DataModel = require "dragon/assets/script/DataModel"
Tools = require "common/Tools"

window.TitleType = {
  Default:-1  #默认
  Challenge : 0,  #排位赛
  Leaderboard : 1, #排行榜
  Invite:2,  #邀请赛
  Backpack:3,  #书包
  Library:4,  #图书馆
  School:5,  #学校
  Store:6,  #商店
  Setting:7,  #设置
  SeasonReward:8,  #赛季奖励
};

_instance = null
UIControl = cc.Class

    extends: cc.Component
    properties:
      "closeBtn": cc.Button
      "title": cc.Label
      "target":cc.Node

    onLoad:->
      @_zorder = 0
      _instance = this
      @_panelList = [];

    changeTitle:(type)->
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
        else @setTitle("")

    setTitle:(str)->
      @title.string =  str ? "" if @title

    open:(PrefabInfo,target)->
#      NetLoading.show()
      className = PrefabInfo["PefabName"];
      promise = new Promise (resolve, reject) =>
#        NetLoading.hide()
        targetComponent = @current className
        if targetComponent
          resolve targetComponent
        else
          PrefabUrl = "prefabs/" + className
          _promise = Tools.loadUI(PrefabUrl)
          _promise.then (prefab)=>
            if(!prefab)
              Dialog.showCustom(LANG_TEXT.trylater)
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

    top:->
      @_panelList = @_panelList or []
      length = @_panelList.length;
      if length then @_panelList[length - 1] else null   #["view"]

    bottom:->
      if @_panelList.length then @_panelList[0] else null  #["view"]

    close:(cls)->

      result = lodash.findIndex @_panelList, {className:cls}
      _panel = @_panelList[result]
      if !_panel
        return
      view = _panel["view"];
      if view and cc.isValid view
        view.destroy()
        @_panelList.splice result, 1;
        @showPanel()

    closeAll:->
      lodash.map @_panelList , (_panel)=>
        view = _panel["view"]
        if cc.isValid view then view.destroy()
      @_panelList = []
      @goToMain()

    closeBottom:->
      @showBackBtn false
      _panel = @_panelList.pop()

      if _panel && _panel["view"]
        _view = _panel["view"]
        _layer = _view.getComponent(_panel["className"])
        if _layer and _layer.closePanel?
          _layer.closePanel()
        else
          _view.destroy()
          @showPanel()

    showPanel:->
      if @_panelList.length <= 0 then @goToMain() else @showTop()

    showTop:->
      toppanel = @top()
      if toppanel and toppanel["view"]
        _view = toppanel["view"]
        _view.active = true
        _panel = _view.getComponent(toppanel["className"])
        if _panel and _panel.updateData then _panel.updateData()
      @showBackBtn true

    getPanelList:->
      return @_panelList.length

    showBackBtn:(isShow)->
      @closeBtn.node.active = isShow

    showTitle:(isShow)->
      @title.node.active = isShow if @title

    showTitleAndBack:(isShow)->
      @showBackBtn isShow
      @showTitle isShow

    setMainPanel:(@_mainPanel)->

    goToMain:->
      DataModel.getModel().setGameMode(TitleType.Default)
      if @_panelList.length then @closeAll()
      @_mainPanel and @_mainPanel.node.active = true;
      @_mainPanel._showPanel = false
      @showTitleAndBack(false)

    showPrefab:(prefabName,mode)->
      @showTitleAndBack(false)
      DataModel.getModel().setGameMode(mode)
      promise = @open({PefabName:prefabName})
      promise = promise.then (prefab)=>
        panel = if prefab then prefab.getComponent(prefabName) else null
        if(!panel)
          return null
        return panel
      return promise;

UIControl.getInstance = ->
    if !_instance
      _instance = new UIControl;
    return _instance

module.exports = UIControl;