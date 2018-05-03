
UIControl = require "UIControl"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component

    properties: {

    }

    onLoad:->
        window.lodash = require "lodash"
        DataModel.getModel().loadrobotConfig()

    onClickExplain:()->

    onClickRank:()->

    onClickStory:()->

    onClickRice:()->

    onClickBoat:()->
        UIControl.getInstance().showPrefab("boatgame","boat")
    onClickDuck:()->

    onClickAnswer:()->

    update: (dt) ->
# do your update here
}
