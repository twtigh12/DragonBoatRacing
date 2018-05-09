var GamePlatform = require("GamePlatform");
var NetLoading = require("NetLoading");
var Dialog = require("Dialog");
var DialogType = require("DialogType");
window.LANG_TEXT = require("LANGTEXT_CN");

var UserDataInterFace = {
    autoFlush: true
    , _myDatas: {}
    , loaded: false
    , saveKey : "playerdata"
    , noticeVer : 0 //公告版本号
    , saving : false
    , noticeList : []
    , faultRetryTimes: 0
    , noticeHandler : null //公告改变处理器 , {onChange:function ,onRemove:function}
    , api:
        {
            save :      "updateuser"
            ,load :      "login"
            ,ranked:     "top"
            ,heartbeat : "heartbeat"  //心跳地址
            ,matchbegin : "matchbegin" //邀请
            ,matchquery : "matchquery" //查询是否匹配到（匹配到玩家）
            ,matchend : "matchend"  //离开房间
            ,answerbegin: "answerbegin" //开始答题
            ,answer:      "answer" //答题
            ,answerquery: "answerquery" //查询对方答题状态
            ,answerend  : "answerend" //退出答题
            ,answertimeout  : "answertimeout" //退出答题
            ,answerfinish  : "answerfinish" //答题结算
            ,getconfig  : "getconfig" //获取配置文件
            ,seasonreward  : "seasonreward" //赛季结算
            ,getrankdata  : "getrankdata" //排行榜

        }
    , apiInit : false
    , changedDatas: null
    , enableConvert: true
    , delaySaveTimer : -1 //帧内延迟存储，避免一帧内重复调用数据存储。
    , retrySaveTimer : -1       //失败重试定时器
    , SvrTimeDiff : 0 //服务器和本地时差
    , regList :{}
    , _lastPost: 0 //最后收到服务器响应时间
    ,_apiRoot : ""
    ,_syncDmTime:0
    ,reset:function () {
        this.loaded = false;
        this._myDatas = {};
        this._lastPost = 0;
        this.changedDatas = null;
        this.noticeList = [];
        this.SvrTimeDiff = 0;

        var server = GamePlatform.getServer();
        if(server != this._apiRoot) {
            this.apiInit = false;
            for (var k in this.api) {
                var s = this.api[k];
                s = s.replace(this._apiRoot, "");
                this.api[k] = cc.path.join(server, s);
            }

            this._apiRoot = server;

            this.faultRetryTimes = 0;

            this.apiInit = true;
        }
    }
    ,update:function (dt) //心跳/公告过期时间刷新
    {
        if(!this.loaded)
            return;
        var model = DataModel.getModel();
        var now = this.getCurSystemTime();

        do {
            var flag = false;
            for (var i in this.noticeList) {
                var n = this.noticeList[i];
                if (now > n.expiredtime) { //过期
                    if(this.noticeHandler && this.noticeHandler.onRemove)
                    {
                        this.noticeHandler.onRemove(n.id);
                    }
                    this.noticeList.splice(i, 1);
                    flag = true;
                    break;
                }
            }
        }while(flag);


        var now = this.getCurSystemTime();
        var diff = now - this._lastPost;
        if(diff > 60)//60sec
        {
            this._postData(this.api.heartbeat,null
                ,function (data) {
                    if(data && data.havenewseason)
                    {
                        DataModel.getModel().setNewSeason(data.havenewseason)
                    }
                }
            );
            this._lastPost = now;
        }
    }

    ,sendHeart:function () {
        var self = this;
        var timer = setInterval(function () {
            self.update()
        },1000);
    }


    , _postData:function (url,datas,responseCallback) {

        url.indexOf("?")== -1 ? url += "?uid=" + encodeURIComponent(cc.playerInfo.id) : url += "&uid=" + encodeURIComponent(cc.playerInfo.id);
        url += "&openid=" + encodeURIComponent(cc.playerInfo.openid);
        var errMsg = "";
        var request = cc.loader.getXMLHttpRequest();

        request.timeout = 5000;

        var dataForPost      = {};

        dataForPost.token    = cc.playerInfo.token;//
        dataForPost.ntfv     = this.noticeVer;

        console.log("apptype:" + dataForPost.apptype + "  dataForPost.platid:"+ dataForPost.platid  + "   cc.playerInfo.id:" + cc.playerInfo.id + " cc.playerInfo.openid:" + cc.playerInfo.openid);
        console.log(" url:"+ url + " datas:"+JSON.stringify(datas));
        if(datas)
        {
            for (var k in datas) {
                dataForPost[k] = datas[k];
            }
        }
        var self = this;

        request.onreadystatechange = function()
        {
            if (request.readyState == 4)
            {
                var data = null;
                if(request.status == 200)
                {
                    var response = request.responseText;
                    try
                    {
                        data = JSON.parse(response);
                    }
                    catch (e)
                    {
                        errMsg =  e.message;
                    }
                }
                else
                {
                    // errMsg = String.format(LANG_TEXT.NetWork_Hint,request.status);
                    console.log(errMsg);
                }

                //if(parseInt(Math.random() *1000) % 5 ===0)
                //    data.code = 2;

                if (data)
                {
                    switch(data.code)
                    {
                        case 2: //需要重新登录
                            self.loaded = false;
                            Dialog.alert(LANG_TEXT.NetWork_Hint1,function () {
                                location.reload();
                            });
                            return;
                        case 3://封号
                            self.loaded = false;
                            Dialog.alert(decodeURIComponent(data.msg) || LANG_TEXT.NetWork_Hint2,null);
                            return;
                        case 4://维护
                        {
                            self.faultRetryTimes += 1; //如果是走的 navigator.reload(),重启游戏这个状态会丢失
                            var msg = decodeURIComponent(data.msg) || LANG_TEXT.NetWork_Hint3;
                            var cd = self.faultRetryTimes >= 10 ? 6:0;

                            Dialog.Retry(msg, function () {
                                location.reload();
                            },cd);

                            return;
                        }
                    }

                //     var notice = data.ntf || data.msg.ntf;
                //     if (notice)
                //     {
                //         var v1 = self.noticeVer;
                //         self.noticeVer = notice.ntfv;
                //         if (self.noticeVer != v1)
                //         {
                //             self.noticeList = notice.notice;
                //             if (self.noticeHandler && self.noticeHandler.onChange)
                //             {
                //                 self.noticeHandler.onChange();
                //             }
                //         }
                //         delete data.msg.ntf;
                //     }
                }

                self.faultRetryTimes = 0;
                if(responseCallback)
                {
                    responseCallback(data,errMsg);
                }

                if(!errMsg) //更新最后访问时间
                {
                    self._lastPost = self.getCurSystemTime();
                }
            }
            else if(request.readyState === 0)
            {
                // console.log(LANG_TEXT.NetWork_Hint4);
                if(responseCallback)
                {
                    responseCallback(null,LANG_TEXT.NetWork_Hint4);//request abort
                }
            }
        };

        request.onerror = function ()
        {
            console.log("request canceled");
            if(responseCallback) responseCallback(null,LANG_TEXT.NetWork_Hint5);
        }

        request.open("POST",url, true);
        request.setRequestHeader("Content-Type","application/x-www-form-urlencoded;");
        request.send("data=" + encodeURIComponent(JSON.stringify(dataForPost)));
    }

    , _post: function (api, data, option, callback) {
        if (!callback) {
            callback = option;
            option = {};
        }
        option.block = (option.block !== undefined ? option.block : true);
        option.retry = (option.retry !== undefined ? option.retry : "default"); // default/block/none

        if (option.block) {
            NetLoading.show();
        }
        var self = this;
        this._postData(api, data, function (response, err) {
            if (option.block) {
                NetLoading.hide();
            }

            if (response && response.code === 0) {
                callback(response.msg);
                return;
            }

            var retry = function (message, callback) {
                Dialog.showConfirm(message, function (id) {
                    callback(id === 1);
                }, DialogType.RetryCancel);
            };
            if (option.retry === "block") {
                retry = function (message, callback) {
                    Dialog.Retry(message, function () {
                        callback(true);
                    });
                };
            }
            if (option.retry === "none") {
                retry = function (message, callback) {
                    callback(false);
                };
            }
            retry(err || !response ||response.msg || LANG_TEXT.NetWork_Hint8, function (tryAgain) {
                if (tryAgain) {
                    self._post(api, data, option, callback);
                } else {
                    callback(null);
                }
            });
        });
    }
    , setContextID:function (contextID) {
        cc.playerInfo.context = contextID;
        //this.setValue("context",contextID); todo
    }

    /**
     * 从服务器获取配置和用户存档
     * @param callback
     */
    , loadFromServer: function (callback) {
        if(this.loaded) {
            callback && callback(null);
            return;
        }

        if(!this.apiInit) {
            var server = GamePlatform.getServer();
            for (var k in this.api) {
                this.api[k] = cc.path.join(server, this.api[k]);
            }

            this._apiRoot = server;
            this.apiInit = true;
        }

        var self  = this;
        var isUseLocalData = false;
        var key = this.saveKey;

        function  readLocalData() {
            cc.sys.localStorage.getItem(key);
            if(localData)
            {
                try
                {
                    var obj = JSON.parse(localData);
                    return obj;
                }
                catch (e)
                {
                    //self._myDatas = {};
                    cc.log("local data err0r");
                    return null;
                }
            }
            else {
                cc.log("local data is empty");
            }

            return null;
        }

        var apptype = GamePlatform.getCurrentPlatForm();

        var localData = null;//readLocalData();
        var getUrl = this.api.load;// + uriId;
        var now = parseInt((new Date()).getTime() / 1000); //TODO 时间同步
        var  userData = {};
        userData.name = cc.playerInfo.name;
        userData.photo = cc.playerInfo.photo;
        userData.time      = now;
        userData.id       = cc.playerInfo.id;
        userData.apptype  = apptype;
        userData.platid   = window.isOnIOS ? 0 : 1;
        userData.cliver   = cc.game.versionInt || 1;
        userData.cliverstr   = cc.game.version || "1.0.0.0";
        userData.hardware = cc.playerInfo.hardware || "unknown";
        userData.telecomoper = cc.playerInfo.telecomoper || "unknown";
        userData.network = cc.playerInfo.network || "unknown";
        userData.channel = cc.playerInfo.channel || 0;//"unknown";
        userData.shareuid = cc.playerInfo.shareuid || "";//"unknown";

        // if(UseSDK){
        //     SDKInterface.logEvent&&SDKInterface.logEvent('logining');
        // }
        this._postData(getUrl,userData,function(data, err)
        {
            var errMsg = err;
            if(data)
            {
                var serverData = null;

                if (data.code === 0)
                {
                    // if(UseSDK) {
                    //     SDKInterface.logEvent && SDKInterface.logEvent('loginsucc');
                    // }
                    serverData = data.msg;// JSON.parse(result.msg)
                    cc.playerInfo.id = serverData.uid;
                    //var isNewUser = serverData.ext.newuser;
                    self.setTimeDiff(serverData.time)

                    var config = userData.config;

                    var datam = DataModel.getModel();
                    datam.newuser =  serverData.ext.newuser;
                    datam.issuccessbargain = serverData.issuccessbargain;
                    datam.newyearbegin = serverData.newyearbegin;
                    datam.newyearend = serverData.newyearend;
                    datam.nyfightbegin = serverData.nyfightbegin;
                    datam.nyfightend = serverData.nyfightend;
                    datam.sex = serverData.sex;	//性别
                    datam.address = serverData.address;// 地址(省市区)
                    datam.choicesex = serverData.choicesex;//性别 1 男 ;2 女 ; 0 全部
                    datam.province = serverData.province;//省
                    datam.city = serverData.city;//市
                    datam.district = serverData.district;//区

                    delete  serverData.config;
                    delete  serverData.ext;
                    self.dataConvertForLoad(serverData);
                }
                else
                {
                    errMsg = data.msg;
                    cc.log("not have current player data or server error.");
                }

            }

            if(!errMsg) {

                cc.log("login myDatas:"+JSON.stringify(serverData));
                for(var k in serverData) {
                    self._myDatas[k] = serverData[k];
                }
                var data = DataModel.getModel();
                data.loadData(serverData); //载入

                self.changedDatas = {};
                self.loaded = true;
            }

            callback && callback(errMsg);
        })


        cc.log("load server data send request...");

        /* facebook 存储
                    FBInstant.player.getDataAsync([key])
                        .then(function (data) {

                            if (data && data[key]) {
                                self._myDatas = data[key];
                                cc.log("load server data is success!");
                            }
                            else {
                                cc.log("server data is empty, to use local data");
                                readLocalData();
                            }

                            self.loaded = true;
                            callback && callback();
                        });
                        */

    }

    , matchbegin:function (roomid,owneruid,lv,callback) {
        var data = {roomid:roomid,owneruid:owneruid,lv:lv};
        this._post(this.api.matchbegin,data,{block:true},function (response) {
            cc.log("matchbegin:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    , matchquery:function (callback) {
        this._post(this.api.matchquery,null,{block:false},function (response) {
            cc.log("matchquery:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    ,matchend:function (callback) {
        this._post(this.api.matchend,null,{block:true},function (response) {
            cc.log("matchend:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    ,answerbegin:function (callback) {
        this._post(this.api.answerbegin,null,{block:true},function (response) {
            cc.log("answerbegin:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    ,answer:function (roomid,index,id,types,answer,time,callback) {
        var data = {roomid:roomid,index:index,id:id,subtype:types,answer:answer,answerstarttime:time};
        this._post(this.api.answer,data,{block:true},function (response) {
            cc.log("answer:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    ,answerquery:function (callback) {
        this._post(this.api.answerquery,null,{block:false},function (response) {
            cc.log("answerquery:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    ,answerend:function (roomid) {
        var data = {roomid:roomid};
        var promise = new Promise(function(resolve, reject) {
            UserDataInterFace._post(UserDataInterFace.api.answerend, data, {block: true}, function (response) {
                cc.log("answerend:" + JSON.stringify(response));
                resolve(response);
            })
        });
        return promise;
    }

    ,answertimeout:function () {
        var promise = new Promise(function(resolve, reject) {
            UserDataInterFace._post(UserDataInterFace.api.answertimeout,null,{block:false},function (response) {
                cc.log("answertimeout:" +JSON.stringify(response));
                resolve(response);
            })
        });
        return promise;
    }

    ,answerfinish:function (callback) {
        this._post(this.api.answerfinish,null,{block:true},function (response) {
            cc.log("answerfinish:" +JSON.stringify(response));
            callback && callback(response);
        })
    }

    ,getconfig:function (configname) {
        var data = {configname:configname}
        var promise = new Promise(function(resolve, reject) {
            UserDataInterFace._post(UserDataInterFace.api.getconfig, data, {block: false}, function (response) {
                // cc.log("getconfig:" + JSON.stringify(response));
                resolve(response)
            })
        });
        return promise;
    }

    ,seasonreward:function () {
        var promise = new Promise(function(resolve, reject){
            UserDataInterFace._post(UserDataInterFace.api.seasonreward,null,{block:true},function (response) {
                cc.log("seasonreward:" +JSON.stringify(response));
                resolve(response)
            })
        });
        return promise
    }

    ,getrankdata:function (page,rankVersion) {
        var data = {page:page,rankVersion:rankVersion};
        var promise = new Promise(function(resolve, reject) {
            UserDataInterFace._post(UserDataInterFace.api.getrankdata, data, {block: true}, function (response) {
                cc.log("getrankdata:" + JSON.stringify(response));
                resolve(response);
            })
        });
        return promise
    }


    /**
     * 数组序列变为 key value
     * @param data
     * @param name
     * @private
     */
    ,_convertToKV:function (data,name) {
        var newName = this._getNewName(name);
        var arr = data[newName];

        if(arr)
        {
            var kv,k;
            for(var i in arr)
            {
                kv = arr[i];
                // k = String.formatC(name, kv[0]);
                data[k] = kv[1];
            }

            delete  data[newName];
        }
    }


    /**
     * 独项的值转为数字序列（数字用%d）
     * @param data
     * @param name
     */
    , _convertToArray: function (data,name) {
        var reg = this.regList[name];
        if(!reg)
        {
            reg = new RegExp(name.replace("%d","(\\d+)"),'ig');
            this.regList[name] = reg;
        }
        var r  = [];
        var ks = [];
        var m;
        for(var k in data) {
            m = reg.exec(k);
            if(m)
            {
                r.push(
                    [
                        parseInt(m[1]),
                        data[k]
                    ]);

                ks.push(k);
            }
        }

        for(var k in ks) {
            delete  data[ks[k]];
        }

        if(r.length)
        {
            var newKey = this._getNewName(name);
            data[newKey] = r;
        }
    }
    , _getNewName:function(name) {
        return name.replace("%d","");
    }
    , dataConvertForPost:function (datas) {
        if(!this.enableConvert)
            return;
        //UserDeFine.t_LD_H = "TEQlZEg=";     //LD%dH
        //UserDeFine.t_LD_T = "TEQlZFQ=";     //LD%dT
        //var t_nCHPlayedState  = "Q0hQbGF5ZWRTdGF0ZSVk";//CHPlayedState%d
        //var t_nCHPlayDay  = "Q0hQbGF5RGF5JWQ=";//CHPlayDay%d
        // this._convertToArray(datas,subgkkk(UserDeFine.t_LD_H));
        // this._convertToArray(datas,subgkkk(UserDeFine.t_LD_T));
        // this._convertToArray(datas,subgkkk(t_nCHPlayedState));
        // this._convertToArray(datas,subgkkk(t_nCHPlayDay));
    }
    , dataConvertForLoad:function (datas) {

        if(!this.enableConvert)
            return;
        //UserDeFine.t_LD_H = "TEQlZEg=";     //LD%dH
        //UserDeFine.t_LD_T = "TEQlZFQ=";     //LD%dT
        //var t_nCHPlayedState  = "Q0hQbGF5ZWRTdGF0ZSVk";//CHPlayedState%d
        //var t_nCHPlayDay  = "Q0hQbGF5RGF5JWQ=";//CHPlayDay%d
        // this._convertToKV(datas,subgkkk(UserDeFine.t_LD_H));
        // this._convertToKV(datas,subgkkk(UserDeFine.t_LD_T));
        // this._convertToKV(datas,subgkkk(t_nCHPlayedState));
        // this._convertToKV(datas,subgkkk(t_nCHPlayDay));
    }

    , _readLocalDataItem : function (key) {

        var val;
        if(UseSDK && typeof(SDKInterface.getLocalStorage) == "function")
        {
            val = SDKInterface.getLocalStorage(key);
        }
        else {
            val = cc.sys.localStorage.getItem(key);
        }

        return val;
    }
    , _writeLocalDataItem:function (key,val) {
        if(UseSDK && typeof(SDKInterface.setLocalStorage) == "function")
        {
            SDKInterface.setLocalStorage(key,val);
        }
        else
        {
            cc.sys.localStorage.setItem(key,val);
        }
    }

    ,setTimeDiff:function (svrTime) {
        if(undefined == svrTime)
            return
        var localTime = parseInt((new Date()).getTime() / 1000);
        this.SvrTimeDiff = localTime - svrTime; //时间差
    }
    /**
     * 获取服务器时间
     * @returns {Date}
     */
    ,getSvrDate:function()
    {
        var date = new Date();
        var t = date.getTime() - this.SvrTimeDiff * 1000;
        date.setTime(t);
        return date;
    },

    getCurSystemTime:function(){
        return parseInt(this.getSvrDate().getTime() / 1000)
    },


    INTFORKEY: function (_key, _v) {

        if(_v === undefined)
            _v = 0;
        var value = this._myDatas[_key];
        return value !== undefined && !isNaN(value) ? parseInt(value) : _v;
    },

    INTFORDKEY: function (_key) {
        return this.INTFORKEY(_key,0);
    },

    setValue:function(key,v)
    {
        var old =  this._myDatas[key];

        if(old !== v)
        {
            this._myDatas[key] = v;
            if(this.loaded) this.changedDatas[key] = v;
        }
    },

    INTTOKEY: function (_v, _key) {
        if (isNaN(_v))
            throw new Error();

        this.setValue(_key,parseInt(_v));
    },

    BOOLFORKEY: function (_key, _v) {
        if (isNaN(_v))
            throw new Error("");
        var value = this._myDatas[_key];
        var ret = undefined != value ? value : _v;
        return ret;
    },
    BOOLFORDKEY: function (_key) {
        return this.BOOLFORKEY(_key,false);
    },
    BOOLTOKEY: function (_v, _key)
    {
        _v = _v ? true : false;
        this.setValue(_key,_v);
    },

    DOUBLEFORDKEY: function (_key) {
        var value = this._myDatas[_key];
        var s = value ? parseFloat(value) : 0;
        if (isNaN(s))
            s = 0;
        return s;
    },

    DOUBLETOKEY: function (_v, _key) {
        if (isNaN(_v))
            throw new Error("");
        _v = parseFloat(_v);
        this.setValue(_key,_v);
    },

    FLOATFORKEY: function (_key) {
        var value = this._myDatas[_key];
        return value ? parseFloat(value) : 0;
    },

    FLOATTOKEY: function (_v, _key) {
        this.DOUBLETOKEY(_v,_key);
    },

    STRINGFORDKEY: function (_key) {
        var value = this._myDatas[_key];
        return value ? value : "";
    },

    STRINGTOKEY: function (_v, _key) {
        if(_v !== undefined) {
            this.setValue(_key,"" + _v);
        }
        else {
            cc.log(_key + " is undefined");
        }
    },
    ISVALIDKEY:function (key) {
        return this._myDatas[key] !== undefined;
    }
}

var INTFORKEY = function(_key , _v)
{
    return UserDataInterFace.INTFORKEY(_key,_v);
};

var INTFORDKEY = function (_key) {
    return UserDataInterFace.INTFORDKEY(_key);
};

var INTTOKEY = function (_v , _key) {
    return UserDataInterFace.INTTOKEY(_v,_key);
}

var BOOLFORKEY = function (_key, _v) {
    return UserDataInterFace.BOOLFORKEY(_key,_v);
};

var BOOLFORDKEY = function (_key) {
    return UserDataInterFace.BOOLFORDKEY(_key);
};

var BOOLTOKEY = function (_v,_key) {
    return UserDataInterFace.BOOLTOKEY(_v,_key);
};

var DOUBLEFORDKEY = function (_key) {
    return UserDataInterFace.DOUBLEFORDKEY(_key);
};

var DOUBLETOKEY = function ( _v,_key) {
    return UserDataInterFace.DOUBLETOKEY(_v, _key);
};

var FLOATFORKEY = function (_key) {
    return UserDataInterFace.FLOATFORKEY(_key);
};

var FLOATTOKEY = function (_v,_key) {
    return UserDataInterFace.FLOATTOKEY(_v,_key);
}

var STRINGFORDKEY = function (_key) {
    return UserDataInterFace.STRINGFORDKEY(_key);
};

var STRINGTOKEY = function (_v,_key) {
    return UserDataInterFace.STRINGTOKEY(_v,_key);
};

/*-------------------------------本地存储 ------------------------------------*/
var _LocalData = null;
var _GETVALUE_LOC = function (key,def) {
    if (def === undefined)
        def = "";

    if (_LocalData === null)
    {
        var strData = UserDataInterFace._readLocalDataItem("LocalData");
        if(strData)
        {
            try
            {
                _LocalData = JSON.parse(strData);
            }
            catch (e)
            {
                _LocalData = {};
            }

        }
        else
        {
            _LocalData = {};
        }
    }

    var val = _LocalData[key];
    return val === undefined ? def : val;
}


var Flush_LOC = function () {
    if(_LocalData)
    {
        try {
            UserDataInterFace._writeLocalDataItem("LocalData",JSON.stringify(_LocalData));
        }
        catch (e)
        {

        }
    }
}
var _SETVALUE_LOC = function (key,val) {
    if(_LocalData === null)
    {
        _GETVALUE_LOC("","");
    }
    _LocalData[key] = val;
}

var INTFORKEY_LOC = function (_key, _v) {

    if(_v === undefined)
        _v = 0;
    var value = _GETVALUE_LOC(_key, _v);
    return value !== undefined && !isNaN(value)? parseInt(value) : _v;
};

var INTFORDKEY_LOC = function (_key) {
    return INTFORKEY_LOC(_key,0);
};

var INTTOKEY_LOC = function (_v, _key) {
    if (isNaN(_v))
        throw new Error();
    _SETVALUE_LOC(_key,_v);
};

var BOOLFORKEY_LOC = function (_key, _v) {
    if (isNaN(_v))
        throw new Error("");
    var value =  _GETVALUE_LOC(_key,_v);
    var ret = undefined != value ? value : _v;
    return ret;
};
var BOOLFORDKEY_LOC = function (_key) {
    return BOOLFORKEY_LOC(_key,false);
};
var BOOLTOKEY_LOC = function (_v, _key)
{
    _v = _v ? true : false;
    _SETVALUE_LOC(_key,_v);
};

var DOUBLEFORDKEY_LOC = function (_key) {
    var value = _GETVALUE_LOC(_key,0);
    var s = value ? parseFloat(value) : 0;
    if (isNaN(s))
        s = 0;
    return s;
};

var DOUBLETOKEY_LOC = function (_v, _key) {
    if (isNaN(_v))
        throw new Error("");
    _SETVALUE_LOC(_key,_v);
};

var FLOATFORKEY_LOC = function (_key) {
    var value = _GETVALUE_LOC(_key,0)
    return value ? parseFloat(value) : 0;
};

var FLOATTOKEY_LOC = function (_v, _key) {
    DOUBLETOKEY_LOC(_v,_key);
};

var STRINGFORDKEY_LOC = function (_key) {
    return _GETVALUE_LOC(_key,"");
};

var STRINGTOKEY_LOC = function (_v, _key) {
    if(_v !== undefined) {
        _SETVALUE_LOC(_key, _v);
    }
    else {
        cc.log(_key + " is undefined");
    }
};

/*----------------------------------------------------------------------------*/

var ISVALIDKEY = function (_key) {
    return UserDataInterFace.ISVALIDKEY(_key);
};


var _base64Dict = {};
var subgkkk = function(s)
{
    var spStr =  _base64Dict[s];
    if(spStr === undefined)
    {
        spStr   =  Base64Decode(s);
        spStr = spStr.toLowerCase();
        _base64Dict[s] = spStr;
    }

    return spStr;
}

module.exports = UserDataInterFace;