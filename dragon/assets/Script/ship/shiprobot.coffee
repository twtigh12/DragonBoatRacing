sType = require "dragon/assets/script/ship/shipType"
cc.Class {
    extends: cc.Component

    properties: {
        speed:1.5
        type:sType.Robot
    }

    onLoad:->
        @_time = 0
        @_speedType = sType.normal
        @setShipSpeed()

    setShipSpeed:()->
        @speed += -1
        @_speedType = sType.up
        cc.log("setShipSpeed:" + @speed)

    setType:(@type)->

    getState:->
        return @_state
    getSpeed:->
        return @speed
    getuptime:->
        return @_upTime

    update: (dt) ->
        @node.y -= @speed
        if( @_speedType isnt sType.normal)
            @setShipSpeed()

        # do your update here
}
