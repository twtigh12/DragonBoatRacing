sType = require "dragon/assets/script/ship/shipType"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component

    properties: {
        speed:2
        type:sType.mySelf
    }

    onLoad:->
        @_upTime = 0
        @_time = 0
        @_speed = 0
        @_speedType = sType.normal
        @_state = sType.normal
        @_height = @node.height

    move:()->
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
    getSpeed:->
        return @speed
    getuptime:->
        return @_upTime

    update: (dt) ->
        @node.y -= @_speed  if (@node.y < @node.height * 0.5 and @_speedType is sType.up) or @_speedType is sType.down
        DataModel.getModel().setShipState(sType.stop) if @node.y >= @node.height * 0.5
        if( @_speedType isnt sType.normal)
            @speedUp(dt) if @_speedType is sType.up
            @speedDown(dt) if @_speedType is sType.down
        # do your update here
}
