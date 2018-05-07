sType = require "ship/shipType"
DataModel = require "DataModel"
Tools = require "Tools"
cc.Class {
    extends: cc.Component
    properties: {
        bg1:cc.Sprite
        bg2:cc.Sprite
        startSpr:cc.Sprite
        drum:cc.Sprite
        ship:cc.Node
        starSpr:cc.Sprite
        mapship:cc.Sprite
        map:cc.Node
        speed:6
    }

    onLoad:->
        @_upTime = 0
        @_time = 0
        @_index = 0
        @_temp = 0
        @_normal = sType.normal
        @_ship = @ship.getComponent("ship")
        @_ship.setType(sType.mySelf)
        @_isStart = true
        @_shipspeed = @_ship.node.height * 0.005
#        _canvas = cc.find("Canvas")
#        _canvas.on(cc.Node.EventType.TOUCH_END, this.touchEnd, this);

    touchEnd:(event)->
        @_ship.move()
        height = @_ship.node.height
        if(@_ship.node.y >= height * 0.5)
            @_ship.node.y = height * 0.5
            @speed += @_shipspeed
            @speed = 40 if(@speed > 40)
        @onChangeDrum()

    onChangeDrum:->
        @_index = 0 if @_index > 1
        str = "game/drum" + @_index
        Tools.loadFrame(str,@drum)
        @_index++

    setStartSpr:->
        if( @starSpr.node.y > -cc.winSize.height * 0.5 - @starSpr.node.height )
            @starSpr.node.y -= @speed

    setBgPos:->
        @bg1.node.y -= @speed
        @bg2.node.y -= @speed
        if(@bg1.node.y < -568)
            @bg1.node.y = @bg2.node.y +  @bg2.node.height - 64
        if(@bg2.node.y < -568)
            @bg2.node.y = @bg1.node.y +  @bg1.node.height - 64

    setStretch:->
        @_temp += Math.abs(@_ship.getShipSpeed())
        _scale =  @map.height / 6000
        _temp = @_temp / 6000
        y = @_temp * _scale
        @mapship.node.y = y
        if(y >= @map.height - 100)
            @starSpr.node.y = cc.winSize.height + 100

    update: (dt) ->
        if(DataModel.getModel().getShipState() isnt sType.stop)
            @speed -= @_shipspeed * 0.2
            @speed = 6 if(@speed < 6)

        @setStartSpr()
        @setBgPos()
        if(@_ship.getState() is sType.up)
            @setStretch()

# do your update here
}
