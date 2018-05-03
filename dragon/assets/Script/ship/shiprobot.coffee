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
        @_speedType = sType.normal
        @randConfig()

    randConfig:->
        _rand = (Tools.rand(0,100) % 4)
        promise = DataModel.getModel().loadrobotConfig()
        promise = promise.then (_config)=>
            @speed = _config[_rand].Speed
            @setShipSpeed _config[_rand]
            @_interval = _config[_rand].interval

    setShipSpeed:(config)->
        @speed += -config.speedup
        @_time += config.Continuedtime
        @_speedType = sType.up
        cc.log("setShipSpeed:" + @speed)

    speedUp:(dt)->
        @_upTime += dt
        cc.log("@_upTime:" + @_upTime + " @_time:" + @_time)
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

    setType:(@type)->

    getState:->
        return @_state
    getSpeed:->
        return @speed
    getuptime:->
        return @_upTime

    update: (dt) ->
        @node.y -= @speed
        cc.log("@speed:" + @speed + " @_speedType:" + @_speedType)
        @speedUp(dt) if @_speedType is sType.up
        @speedDown(dt) if @_speedType is sType.down

# do your update here
}
