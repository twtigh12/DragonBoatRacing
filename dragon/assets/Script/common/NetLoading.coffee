UIControl = require "common/UIControl"

NetLoading = cc.Class
    extends: cc.Component

    properties:
        loadSpr:cc.Sprite

    onDestroy:->
        cc.log("onDestroy")
        NetLoading.isShow = false
        NetLoading.isHide = false
    onLoad:->
        @width = cc.winSize.width;
        @height = cc.winSize.height;
        this.node.on(cc.Node.EventType.TOUCH_START, this._onTouchBegan, this, true);

    _onTouchBegan:(event, captureListeners)->
        event.stopPropagation();
        return true
    update: (dt) ->
        # do your update here

NetLoading.show = (txt) ->
    promise = NetLoading.create();
    if !promise then return

    promise.then (_panel)=>
        if _panel and _panel.node then _panel.node.runAction(cc.sequence(cc.delayTime(0.25),cc.show()));

NetLoading.hide = ->
    scene = cc.director.getScene()
    if !scene then return null
    NetLoading.isHide = true
    cc.log("NetLoading.hide")
    curDialog = scene.getChildByTag(19987)
    if curDialog then curDialog.destroy()

NetLoading.isHide = false
NetLoading.isShow = false
NetLoading.create =->
    if NetLoading.isShow then return null
    NetLoading.hide();
    NetLoading.isShow = true
    scene = cc.director.getScene()
    if !scene then return null
    cc.log("NetLoading.create")
    promise = Tools.loadUI("prefabs/NetLoad")
    promise = promise.then (prefab)=>
        if !prefab then return null
        if NetLoading.isHide
            cc.log("NetLoading.isHide")
            NetLoading.isHide = false
            NetLoading.isShow = false
            return

        _panel = prefab.getComponent("NetLoading")
        _panel.node.x = cc.winSize.width * 0.5
        _panel.node.y = cc.winSize.height * 0.5
        scene.addChild(_panel.node,10000,19987)

        return _panel
    return promise

module.exports = NetLoading