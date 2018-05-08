UIControl = require "UIControl"
cc.Class {
    extends: cc.Component

    properties:
        bgspr:cc.Node

    onLoad:->

    onClickContinue:->
        UIControl.getInstance().closeBottom()
    onClickShare:->

    update: (dt) ->
        # do your update here
}
