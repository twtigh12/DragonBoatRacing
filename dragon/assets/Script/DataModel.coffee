Tools = require("Tools");

DataModel  = cc.Class
  initData:->
    cc.log("initData")
  onDestroy:->
    cc.log("onDestroy")

  setShip:(@_ship)->
  getShip:->
    return @_ship

  setGameMode:(@_mode)->
  getGameMode:->
    return @_mode
  
  setShipSpeed:(@_shipSpeed)->

  getShipSpeed:->
    return @_shipSpeed ? 0

  loadrobotConfig:->
    promise = Promise.resolve()
    if(@_robotConfig)
      promise = promise.then ()=>
        return @_robotConfig
    else
      promise = Tools.jsonParse("resources/config/robotShip.json")
      promise = promise.then (configs)=>
        @_robotConfig = configs
        cc.log("robotConfig:" + JSON.stringify(configs))

  _ship:null

DataModel.getModel = ->
  if !@_instance
    @_instance = new DataModel;
    @_instance.initData()
  return @_instance

module.exports = DataModel;