_DialogZOrder = 10004
UIControl = require "dragon/assets/script/common/UIControl"
DialogType = require "dragon/assets/script/common/DialogType"


Dialog = cc.Class {
    extends: cc.Component

    properties: {
        okBtn:cc.Button
        okBtnTitle:cc.Label
        cancelBtn:cc.Button
        cancelBtnTitle:cc.Label
        hintLbl:cc.Label
        verticalSpr:cc.Sprite
    }

    onLoad:->
        @_lbl = @hintLbl.getComponent(cc.Label)
        @_okTitle = @okBtnTitle.getComponent(cc.Label)
        @_cancelTitle = @cancelBtnTitle.getComponent(cc.Label)

    onDestroy:->
        if @closed then @onRemove()

    onRemove:->
        lodash.pull @_Dialog_List ,this

    initUI:->
        btnCount = 1;
        switch @type
            when DialogType.OKCancel then  btnCount = 2
            when DialogType.YesNo then btnCount = 2
            when DialogType.Retry then @changeBtnTitle(LANG_TEXT.Btn_Retry)



        @verticalSpr.node.active = btnCount > 1
        @cancelBtn.node.active = false
        @okBtn.node.x = 0
        if btnCount is 1 then @okBtn.node.width = @node.width

    changeBtnTitle:(oktitle,cancelTitle)->
        @_okTitle.string = oktitle ? "ok"
        @_cancelTitle.string = cancelTitle ? "cancel"

    setData:(@_text,@type,@buttons,@callback)->
        @initUI()
        @showStr(@_text)

    onClickBtn:(sender,index)->
        @callback && @callback(parseInt(index))
        @.node.destroy()

    showStr:(str)->
        @_lbl.string = if str then str else ""

    setCountDown:(cd)->
        @_retryCountDown = cd;
        @_update = cd > 0

    close:->
        @closed = true
        @node.destroy()

    update: (dt) ->
        if(@_update)
            @_retryCountDown -= dt;
            m = @_text;
            if(parseInt(this.retryCountDown)>0)
                 m = @_text + "请" + parseInt(@_retryCountDown) + " 秒后点再试"
            else
                @_update = false
            this.label.setString(m);

        # do your update here
}

Dialog._currentScene = null;
Dialog._Dialog_List = [];


Dialog.showConfirm = (text,callback,type)->
    promise = Dialog.create()
    promise.then (dialog)=>
        type = DialogType.YesNo if !type
        dialog.setData(text,type,null,callback)
        return dialog
    return promise

Dialog.showCustom = (text,buttons,callback)->
    promise = Dialog.create()
    promise.then (dialog)=>
        cc.log(dialog)
        type = DialogType.YesNo if !type
        dialog.setData(text,type,buttons,callback)
        return dialog
    return promise

Dialog.Retry = (text,callback,cd)->
    promise = Dialog.create()
    promise.then (dialog)=>
        type = DialogType.Retry if !type
        dialog.setData(text,type,null,callback)
        if cd then dialog.setCountDown(cd)
        return dialog
    return promise

Dialog.alert = (text, callback)->
    type = DialogType.Alert if !type
    Dialog.showConfirm(text,callback,type)

Dialog.removeAllDialog = ->
    lodash.map  @_Dialog_List, (dialog)=>
        dialog.close()
    @_Dialog_List.length = 0

Dialog._getCurrentScene = ->
    cc.director.getScene()

Dialog.changeScene = (scene)->
    lodash.map  @_Dialog_List, (dialog)=>
        dialog.removeFromParent()
        scene.addChild(dialog,_DialogZOrder)
    @_currentScene = scene

Dialog.create =->
    scene = @_getCurrentScene()
    return null if !scene

    curDialog = scene.getChildByTag(19875)
    if curDialog then curDialog.destroy()

    promise = UIControl.getInstance().open({PefabName:"DialogNode"},scene)
    promise = promise.then (prefab)=>
        return null if !prefab
        dialog = prefab.getComponent("Dialog")
        dialog.node.x = cc.winSize.width * 0.5
        dialog.node.y = cc.winSize.height * 0.5
        dialog.node.tag = 19875
        return dialog

    return promise

module.exports = Dialog;