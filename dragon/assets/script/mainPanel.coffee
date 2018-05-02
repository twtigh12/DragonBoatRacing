UIControl = require "UIControl"
cc.Class {
    extends: cc.Component

    properties: {

    }

    onLoad:->
       window.lodash = require "lodash"

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
