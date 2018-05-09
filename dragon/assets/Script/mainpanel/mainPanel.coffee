
UIControl = require "UIControl"
DataModel = require "DataModel"
cc.Class {
    extends: cc.Component

    properties: {

    }

    onLoad:->
        window.lodash = _ #require "lodash"
        DataModel.getModel().loadrobotConfig()
    onClickExplain:()->

    onClickRank:()->

    onClickStory:()->
        promise = UIControl.getInstance().showPrefab("storyNode","boat")
        promise.then =>
            UIControl.getInstance().showTitleAndBack(true)

    onClickRice:()->

    onClickBoat:()->
        promise = UIControl.getInstance().showPrefab("boatgame","boat")
        promise.then =>
            UIControl.getInstance().showTitleAndBack(true)
    onClickDuck:()->

    onClickAnswer:()->

    update: (dt) ->
# do your update here
}
