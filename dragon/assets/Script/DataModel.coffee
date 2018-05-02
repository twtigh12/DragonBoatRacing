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

  _ship:null

DataModel.getModel = ->
  if !@_instance
    @_instance = new DataModel;
    @_instance.initData()
  return @_instance

module.exports = DataModel;