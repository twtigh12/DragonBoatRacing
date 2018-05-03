
class Adapter
    @create: ->
        window.LANG_TEXT = require("LANGTEXT_CN");
        promise = Promise.resolve()
        promise = promise.then =>
            new Adapter

    constructor: ->
        @appInfo =
            appName:LANG_TEXT.appName

    check: (name) ->

    login: ->
        promise = new Promise (resolve, reject) =>
            @showLogin()

    showLogin:->
        promise = Tools.loadUI("prefabs/login")
        promise.then (prefab)=>
            if !prefab then return
            prefab.x = cc.winSize.width * 0.5
            prefab.y = cc.winSize.height * 0.5
            login = prefab.getComponent("login")
            cc.director.getScene().addChild(prefab)

    shareMessage: ->
        return @defaultShare()

    shareScreenshot: ->
        return @defaultShare()

    defaultShare: ->
        @resolveFalse()
    getEntryData:->

    getFriendList:->
        @resolveFalse()
    logEvent:->
        @resolveFalse()
    chooseAsync:->
        @resolveFalse()
    resolveFalse:->
        promise = new Promise (resolve, reject) =>
            resolve false
    startGame:->
        promise = Promise.resolve()
        promise.then =>
            return true

Adapter.setup = (type) ->
    getClass = (type) =>
        return require "WeiXinApp" if type is 1
        return this
    promise = getClass(type).create()
    promise = promise.then (instance) =>
        @instance = instance

module.exports = Adapter
