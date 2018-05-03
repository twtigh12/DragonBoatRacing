sType = require "dragon/assets/script/ship/shipType"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component

    properties: {
        speed:1.5
        type:sType.Robot
    }

    onLoad:->
        @_time = 0
        @_upTime = 0
        @_speedType = sType.normal
        promise = DataModel.getModel().loadrobotConfig()
        promise = promise.then (_config)=>
            @speed = _config[0].Speed
            @setShipSpeed _config[0]

    setShipSpeed:(config)->
        cc.log()
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
