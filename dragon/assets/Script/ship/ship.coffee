sType = require "dragon/assets/script/ship/shipType"
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
        @_speed = 0
        @node.y = @_normaly if @_normaly

        @_speedType = sType.normal
        @_height = @node.height
        @node.stopAllActions()

    move:()->
        @_isStart = true
        @_speedType = sType.up
        @_height = @node.height

    setType:(@type)->

    speedUp:(dt)->
        @_speed = -(@node.height * 0.01)
        @_height += @_speed
        if (@_height <= 5)
            @_height =  @node.height
            @_speedType = sType.down
            @_speed = 0
            DataModel.getModel().setShipState(sType.down)
        DataModel.getModel().setShipSpeed(@_speed)

    speedDown:(dt)->
        @_speed = (@node.height * 0.005)
        @_height -= @_speed
        if (@_height <= -5)
            @_height = 0
            @_speedType = sType.normal
            @_speed = 0
            DataModel.getModel().setShipState(sType.normal)
        DataModel.getModel().setShipSpeed(@_speed)

    getShipSpeed:->
        return @_speed

    getState:->
        return @_speedType

    update: (dt) ->
        if(!@_isStart) then return

        @node.y -= @_speed  if (@node.y < @node.height * 0.5 and @_speedType is sType.up) or @_speedType is sType.down
        if @node.y >= @node.height * 0.5
            DataModel.getModel().setShipState(sType.stop)

        if( @_speedType isnt sType.normal)
            @speedUp(dt) if @_speedType is sType.up
            @speedDown(dt) if @_speedType is sType.down
        # do your update here
}
