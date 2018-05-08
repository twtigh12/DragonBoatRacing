sType = require "ship/shipType"
DataModel = require "DataModel"
Tools = require "Tools"
UIControl = require "UIControl"
cc.Class {
    extends: cc.Component
    properties: {
        bg1:cc.Sprite
        bg2:cc.Sprite
        drum:cc.Sprite
        ship:cc.Node
        shiprobot1:cc.Node
        shiprobot2:cc.Node
        starSpr:cc.Sprite
        mapship:cc.Node
        map:cc.Node
        timeLbl:cc.Label
        speedBtn:cc.Button
    }

    onLoad:->
        @_ship = @ship.getComponent("ship")
        @_robotship1 = @shiprobot1.getComponent("shiprobot")
        @_robotship2 = @shiprobot2.getComponent("shiprobot")
        @_shipNormaly = @ship.y
        @_startSpry = @starSpr.node.y
        @_ship.setType(sType.mySelf)
        @updateData()

    showCountTime:->
        @timeLbl.string = @_timeIndex
        if(@_timeIndex is 0)
            @timeLbl.string  = "GO!"
            cb = =>
                @_robotship1.move()
                @_robotship2.move()
                @speedBtn.interactable = true
            @timeLbl.node.runAction(cc.sequence(cc.delayTime(0.5),cc.callFunc(cb,this),cc.fadeOut(0.3)))
            return
        @_timeIndex--
        @timeLbl.node.runAction(cc.sequence(cc.delayTime(1),cc.callFunc(@showCountTime,this)))


    touchEnd:(event)->
        @_ship.move()

        @_isStart = true
        height = @_ship.node.height
        if(@_ship.node.y >= height * 0.5)
            @_ship.node.y = height * 0.5
            @speed += @_shipspeed
            cc.log("@_shipspeed :" + @_shipspeed + " @speed:" + @speed)
            @speed = 40 if(@speed > 40)
        @onChangeDrum()

    onChangeDrum:->
        @_index = 0 if @_index > 1
        str = "game/drum" + @_index
        Tools.loadFrame(str,@drum)
        @_index++

    setStartSpr:->
        maxy = -cc.winSize.height * 0.5 - @starSpr.node.height
        if( @starSpr.node.y >  maxy or @_isend)
            @starSpr.node.y -= @speed
            if(@_ship.node.y >= @starSpr.node.y and @_isend and !@_isOver)
                @mapship.y = (@map.height - @mapship.height - 10)
                @_isOver = true
                @showGameOver()

    setBgPos:->
        @bg1.node.y -= @speed
        @bg2.node.y -= @speed
        if(@bg1.node.y < -568)
            @bg1.node.y = @bg2.node.y +  @bg2.node.height - 64
        if(@bg2.node.y < -568)
            @bg2.node.y = @bg1.node.y +  @bg1.node.height - 64

    setStretch:->
        if (@_isOver) then return
        @_temp += Math.abs(@_ship.getShipSpeed())
        _scale =  @map.height / 2000
        y = @_temp * _scale
        @mapship.y = y
        if(y >= @map.height - 100 and !@_isend)
            @starSpr.node.y = cc.winSize.height * 0.5 - @starSpr.node.height
            @_isend = true

    showGameOver:->
        DataModel.getModel().setIsOver(true)
        UIControl.getInstance().showPrefab("overPanel","over")

    updateData:->
        DataModel.getModel().setIsOver(false)
        @mapship.y = 0
        @_isOver = false
        @_ship.setNormal()
        @_robotship1.setNormal()
        @_robotship2.setNormal()
        @starSpr.node.y = @_startSpry
        @_isend = false
        @_index = 0
        @_temp = 0
        @speed = 0
        @_shipspeed = @_ship.node.height * 0.005
        @_isStart = false
        @_timeIndex = 3
        @speedBtn.interactable = false
        @timeLbl.node.runAction(cc.fadeIn(0.3))
        @showCountTime()


    update: (dt) ->
        if(@_isOver) then return

        if(DataModel.getModel().getShipState() isnt sType.stop and @_isStart)
            cc.log("@speed:" + @speed)
            @speed += Math.abs(@_shipspeed * 0.2)
            @speed = 6 if(@speed > 6)

        @setStartSpr()
        @setBgPos()
        if(@_ship.getState() is sType.up)
            @setStretch()

# do your update here
}
