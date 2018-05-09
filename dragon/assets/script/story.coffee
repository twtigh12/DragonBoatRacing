cc.Class {
    extends: cc.Component

    properties:{}

    onLoad:->
        @_action = @node.getComponent(cc.Animation)
        @_action.play("story")
    update: (dt) ->
        # do your update here
}
