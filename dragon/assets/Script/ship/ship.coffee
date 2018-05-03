sType = require "dragon/assets/script/ship/shipType"
cc.Class {
    extends: cc.Component

    properties: {
        speed:0.8
        type:sType.mySelf
    }

    onLoad:->
        @_upTime = 0
        @_time = 0
        @_speedType = sType.normal
        @_state = sType.normal
#        listener =
#            event: cc.EventListener.MOUSE
#            onMouseDown:@touchEnd.bind(this)
#        _canvas = cc.find("Canvas")
#        _canvas.on(cc.Node.EventType.TOUCH_END, this.touchEnd, this);
    setShipSpeed:()->
        @speed +=  -0.8
        @_time += 0.8
        @_speedType = sType.up

    setType:(@type)->

    speedUp:(dt)->
        @_upTime += dt
        if(@_upTime >= @_time)
            @_upTime = 0
            @_time = (@speed - 1) * 0.8
            @_speedType = sType.down

    speedDown:(dt)->
        @_upTime += dt
        @speed += dt
        if(@speed >= 0.5)
            @_speedType = sType.normal
            @speed = 0.8
            @_upTime = 0
            @_time = 0

    getState:->
        return @_state
    getSpeed:->
        return @speed
    getuptime:->
        return @_upTime

    update: (dt) ->
        @node.y -= @speed
        @_state = if @node.y >= 0 then sType.stop else sType.normal
        @speed = 0 if @node.y >= 0
        if( @_speedType isnt sType.normal)
            @speedUp(dt) if @_speedType is sType.up
            @speedDown(dt) if @_speedType is sType.down
        # do your update here
}
