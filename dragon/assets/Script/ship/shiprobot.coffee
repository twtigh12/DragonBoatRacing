sType = require "shipType"
DataModel = require "DataModel"
Tools = require "Tools"
cc.Class {
    extends: cc.Component

    properties: {
        type:sType.Robot
    }

    onLoad:->
        @_shipNormaly = @node.y
        @setNormal()

    setNormal:->
        @node.y = @_shipNormaly if @_shipNormaly

        @_interval = 0
        @_height = 0
        @_speed = 0
        @_shipSpeed = 0
        @_speedType = sType.normal
        @node.stopAllActions()

    move:->
        @randConfig()

    randConfig:->
        _rand = (Tools.rand(0,100) % 4)
        promise = DataModel.getModel().loadrobotConfig()
        promise = promise.then (_configs)=>
            _config = _configs[_rand]
            @_speed = _config.speed
            @_shipSpeed = -@_speed
            @_interval = _config.interval
            @_continuedtime = _config.Continuedtime
            @_speedType = sType.up
            @_isStart = true

    speedUp:(dt)->
        @_shipSpeed =  -@_speed
        @_continuedtime -= dt
        if (@_continuedtime <= 0)
            @node.stopAllActions()
            @node.runAction(cc.sequence(cc.delayTime(@_interval),cc.callFunc(@randConfig,this)))
            @_height = @node.height
            @_speedType = sType.down

    speedDown:(dt)->
        @_speed = (@node.height * 0.005)
        @_height -= @_speed
        if (@_height <= -5)
            @_height = 0
            @_speedType = sType.normal
            @_speed = 0
            @_isStart = false

    getSpeed:->
        return @_shipSpeed

    update: (dt) ->
        if(DataModel.getModel().isOver() or !@_isStart) then return
        _temp = @_shipSpeed
        state = DataModel.getModel().getShipState() is sType.stop
        if state
            _shipSpeed = DataModel.getModel().getShipSpeed()
            _temp =  Math.abs(Math.abs(@_shipSpeed) - Math.abs(_shipSpeed))
            _temp = -_temp if @_speedType is sType.up
        if @_speedType is sType.up or @_speedType is sType.down
            @node.y -= _temp
        if( @_speedType isnt sType.normal)
            @speedUp(dt) if @_speedType is sType.up
            @speedDown(dt) if @_speedType is sType.down
}
