sType = require "ship/shipType"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component
    properties: {
        bg1:cc.Sprite
        bg2:cc.Sprite
        startSpr:cc.Sprite
        ship:cc.Node
        speed:6
    }

    onLoad:->
        @_upTime = 0
        @_time = 0
        @_normal = sType.normal
        @_ship = @ship.getComponent("ship")
        @_ship.setType(sType.mySelf)

        _canvas = cc.find("Canvas")
        _canvas.on(cc.Node.EventType.TOUCH_END, this.touchEnd, this);
    touchEnd:(event)->
        @_ship.move()
        if(@_ship.node.y > 0)
            height = @_ship.node.y
            @_ship.node.y = height * 0.5
            @_shipType = @_ship.getState()
            @speed -= @_ship.getShipSpeed()
            if(@speed > 40)
                @speed = 40

    update: (dt) ->
        @bg1.node.y -= @speed
        @bg2.node.y -= @speed
        if(@bg1.node.y < -568)
            @bg1.node.y = @bg2.node.y +  @bg2.node.height
        if(@bg2.node.y < -568)
            @bg2.node.y = @bg1.node.y +  @bg1.node.height
        # do your update here
}
