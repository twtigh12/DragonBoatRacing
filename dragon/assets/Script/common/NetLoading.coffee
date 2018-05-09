UIControl = require "UIControl"
Tools = require "Tools"
NetLoading = cc.Class
    extends: cc.Component

    properties:
        loadSpr:cc.Sprite

    onDestroy:->

    onLoad:->
#        @_time = 0

    update: (dt) ->
#        @_time += dt
#        if(@_time >= 2)
#            @_time = 0
#            @node.destroy()
        # do your update here

NetLoading.show = (txt) ->
    @_promise = NetLoading.create();

NetLoading.hide = ->
    return null if(!@_promise)
    @_promise.then (prefab)=>
        prefab.destroy() if prefab
        @_promise = null

NetLoading.create =->
    return @_promise if @_promise

    NetLoading.hide();
    scene = cc.director.getScene()
    if !scene then return null
    @_promise = Tools.loadUI("prefabs/NetLoad")
    @_promise = @_promise.then (prefab)=>
        if !prefab then return null
        _panel = prefab.getComponent("NetLoading")
        prefab.x = cc.winSize.width * 0.5
        prefab.y = cc.winSize.height * 0.5
        prefab.tag = 19987
        scene.addChild(_panel.node,10000)
        prefab.setOpacity(0)
        prefab.runAction(cc.sequence(cc.delayTime(0.5),cc.fadeIn(0.2)))
        return prefab
    return @_promise

module.exports = NetLoading