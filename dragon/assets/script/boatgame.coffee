sType = require "shipType"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component
    properties: {
        bg1:cc.Sprite
        bg2:cc.Sprite
        startSpr:cc.Sprite
        ship:cc.Node
        speed:1
    }

    onLoad:->
        @_upTime = 0
        @_time = 0
        @_normal = sType.normal
        @_ship = @ship.getComponent("ship")
        @_ship.setType(sType.mySelf)
#        @node.on(cc.Node.EventType.MOUSE_DOWN,@touchEnd.bind(this))
        _canvas = cc.find("Canvas")
        _canvas.on(cc.Node.EventType.TOUCH_END, this.touchEnd, this);
    touchEnd:(event)->
        @speed +=  1
        @_time += 0.8
        @_normal = sType.up
        @_ship.setShipSpeed()
        if(@_ship.getState() is sType.stop)
          @_time = @_ship.getuptime()

    speedUp:(dt)->
        @_upTime += dt
        if(@_upTime >= @_time)
            @_upTime = 0
            @_time = (@speed - 1) * 0.8
            @_normal = sType.down

    speedDown:(dt)->
        @speed -= dt
        if(@speed <= 1)
            @_normal = sType.normal
            @speed = 1
            @_upTime = 0
            @_time = 0

    update: (dt) ->
        @bg1.node.y -= @speed
        @bg2.node.y -= @speed
        if(@bg1.node.y < -568)
            @bg1.node.y = @bg2.node.y +  @bg2.node.height
        if(@bg2.node.y < -568)
            @bg2.node.y = @bg1.node.y +  @bg1.node.height
        if( @_normal isnt sType.normal)
            @speedUp(dt) if @_normal is sType.up
            @speedDown(dt) if @_normal is sType.down
        # do your update here
}
