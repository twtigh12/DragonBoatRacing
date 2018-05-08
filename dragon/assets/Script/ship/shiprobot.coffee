sType = require "dragon/assets/script/ship/shipType"
DataModel = require "DataModel"
Tools = require "Tools"
cc.Class {
    extends: cc.Component

    properties: {
        speed:1.5
        type:sType.Robot
    }

    onLoad:->
        @_time = 0
        @_upTime = 0
        @_interval = 0
        @_speed = 0
        @_shipSpeed = 0
        @_speedType = sType.normal
        @_height = @node.height
        @randConfig()

    randConfig:->
        _rand = (Tools.rand(0,100) % 4)
        promise = DataModel.getModel().loadrobotConfig()
        promise = promise.then (_configs)=>
            _config = _configs[_rand]
            @_height = @node.height
            @_time = _config.interval
            @move()

    move:()->
        @_speedType = sType.up
        @_height = @node.height

    speedUp:(dt)->
        @_speed = -(@node.height * 0.01)
        @_height += @_speed
        if (@_height <= 5)
            @_height =  @node.height
            @node.stopAllActions()
            @node.runAction(cc.sequence(cc.delayTime(@_time),cc.callFunc(@randConfig,this)))
            @_speedType = sType.down
            @_speed = -@speed

    speedDown:(dt)->
        @_speed = (@node.height * 0.005)
        @_height -= @_speed
        if (@_height <= -5)
            @_height = 0
            @_speedType = sType.normal
            @_speed = @speed

    setType:(@type)->

    getState:->
        return @_state
    getSpeed:->
        return @speed
    getuptime:->
        return @_upTime

    update: (dt) ->
        _temp = 0
        if DataModel.getModel().getShipState() is sType.stop
            @_shipSpeed = DataModel.getModel().getShipSpeed()
            _temp =  Math.abs(Math.abs(@_speed) - Math.abs(@_shipSpeed))
        @_speed += if @_speedType is sType.up then -_temp else _temp

        @node.y -= @_speed if @_speedType is sType.up or @_speedType is sType.down
        if( @_speedType isnt sType.normal)
            @speedUp(dt) if @_speedType is sType.up
#            @speedDown(dt) if @_speedType is sType.down

}
