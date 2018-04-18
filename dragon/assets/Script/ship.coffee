sType = require "speedType"
cc.Class {
    extends: cc.Component

    properties: {
        speed:0.5
    }

    onLoad:->
        @_upTime = 0
        @_time = 0
        @_normal = sType.normal
        listener =
            event: cc.EventListener.MOUSE
            onMouseDown:@touchEnd.bind(this)
        cc.eventManager.addListener(listener,this.node)
    touchEnd:(event)->
        @speed +=  -1
        @_time += 0.5
        @_normal = sType.up

    speedUp:(dt)->
        @_upTime += dt
        if(@_upTime >= @_time)
            @_upTime = 0
            @_time = (@speed - 1) * 0.5
            @_normal = sType.down

    speedDown:(dt)->
        @_upTime += dt
        @speed += dt
        if(@speed >= 0.5)
            @_normal = sType.normal
            @speed = 0.5
            @_upTime = 0
            @_time = 0

    update: (dt) ->
        @node.y -= @speed
        cc.log("ship time:" + @_time + " @speed:" + @speed + " @_upTime:" + @_upTime)
        if( @_normal isnt sType.normal)
            @speedUp(dt) if @_normal is sType.up
            @speedDown(dt) if @_normal is sType.down
        # do your update here
}
