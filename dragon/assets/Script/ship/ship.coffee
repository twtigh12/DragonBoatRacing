sType = require "shipType"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component

    properties: {
        type:sType.mySelf
    }

    onLoad:->
        @_normaly = @node.y
        @setNormal()

    setNormal:->
        @_isStart = false
        @_dt = 0
        @_speed = 0
        @node.y = @_normaly if @_normaly
        @_movey = 0
        @_speedType = sType.normal
        @_height = @node.height
        @node.stopAllActions()

    move:()->
        @_isStart = true
        @_speedType = sType.up
        @setShipState(sType.up)
        @_height = @node.height

    setType:(@type)->

    speedUp:(dt)->
        @_dt = 0
        @setShipState(sType.up)
        @_speed = -(@node.height * 0.01)
        @_height += @_speed
        @_movey += @_speed
        if (@_height <= 5)
            @_height =  @node.height
            @_speedType = sType.down
            @_speed = 0
            DataModel.getModel().setShipState(sType.down)
        DataModel.getModel().setShipSpeed(@_speed)

    speedDown:(dt)->
        @_dt = 0
        @setShipState(sType.down)
        @_speed = (@node.height * 0.005)
        @_height -= @_speed
        if (@_height <= -5 or  @node.y < @_normaly)
            @node.y = @_normaly
            @_height = 0
            @_speedType = sType.normal
            @_speed = 0
            @_isStart = false
            DataModel.getModel().setShipState(sType.normal)
        DataModel.getModel().setShipSpeed(@_speed)

    setShipState:(type)->
        state = type
        state = sType.stop if @node.y >= @node.height * 0.5
        DataModel.getModel().setShipState(state)

    getShipSpeed:->
        return @_speed

    getMoveDistances:->
        return @_movey

    getState:->
        return @_speedType

    update: (dt) ->
        if(!@_isStart) then return
        if (@node.y < @node.height * 0.5 and @_speedType is sType.up) or @_speedType is sType.down
            @node.y -= @_speed

        if( @_speedType isnt sType.normal)
            @_dt += dt
            @speedUp(dt) if @_speedType is sType.up and @_dt > 0.1
            @speedDown(dt) if @_speedType is sType.down  and @_dt > 0.1
        # do your update here
}
