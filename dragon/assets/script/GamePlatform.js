
var PlatformType = {
    None         : 0, //不使用sdk
    WeiXin       : 3, //微信SDK
    WeiXinApp    : 1, //微信小程序SDK
    QQ            : 2, //手机QQ SDK
    FaceBook     : 4  //Facebook SDK
};

var GamePlatform = {};
var  Environment_Type = {
    BENDI:0,
    NEIWANG:1, //内网测试
    WAIWANG:2, //外网测试
    PREPUBLISH:3 ,//预发布环境
    ZHENGSHI :4 //正式环境
};  //内网测试  外网测试  正式

/**
 * 获取当前对接的平台(SDK) 类型
 * @returns {PlatformType}
 */

var _currentPlatform = PlatformType.None;
var EnvironmentType  = Environment_Type.BENDI;

var _doSendScore = true;

GamePlatform.getCurrentPlatForm = function () {
  return _currentPlatform;
};

GamePlatform.needUploadScore = function () {
    return _doSendScore;
};

//是否显示全部功能
GamePlatform.getIsShowAll = function () {
    return true;
};

//中英切换
GamePlatform.isCN =function () {
    // return   _currentPlatform != PlatformType.FaceBook;
    return   false;
};

GamePlatform.getLanguage =function () {
    return GamePlatform.isCN() ? "_cn" : "_en";
};

/**
 * 获取平台名称
 * @returns {string}
 */
GamePlatform.getPlatFormName = function () {
    var type = this.getCurrentPlatForm();

    switch (type)
    {
        case PlatformType.WeiXinApp:
            return "WeiXinApp";
        case PlatformType.FaceBook:
            return "FaceBook";
        case PlatformType.WeiXin:
            return "WeiXin";
        case PlatformType.QQ:
            return "QQ";
        default:
            return "";
    }
}

/**
 * 获取SDK所需要引用进来的远程js代码文件URL
 * @returns {Array}
 */
GamePlatform.sdkCodeUrls = function () {
    var urls = [];
    var platform = this.getCurrentPlatForm();

    switch(platform)
    {
        case PlatformType.FaceBook:
            urls.push("https://connect.facebook.com/en_US/fbinstant.latest.js");
            break;
        case PlatformType.QQ:
            urls.push("https://qzonestyle.gtimg.cn/qzone/hybrid/lib/qqapi.1470836255000.js?_offline=1&max_age=36000000");
            urls.push("https://h5sdk.qq.com/h5game/js/h5jssdk-1.1.4.min.js");
            urls.push("https://midas.gtimg.cn/h5pay/js/api/midas.js");
            break;
    }
    return urls;
}

/**
 * 返回服务器地址
 * @returns {string}
 */
GamePlatform.getServer = function () {
    var platform = this.getCurrentPlatForm();
    var urlsvr = "";
    switch (EnvironmentType)
    {
        case Environment_Type.BENDI:
            // urlsvr = "http://192.168.1.21:50001";
            urlsvr = "http://192.168.55.188:10001";
            break;
        case Environment_Type.WAIWANG:
            urlsvr = "https://h5carrot.vrseastar.com";
            break;
        case Environment_Type.ZHENGSHI:
            urlsvr = "https://lb.vrseastar.com/";
            break;
        default:
            // urlsvr = "http://192.168.1.21:50001/";
            urlsvr = "http://192.168.55.188:10001";
            break;
    }

    return urlsvr;
}
/**
 * 返回登录URL地址
 * @returns {string}
 */
GamePlatform.getLoginUrl = function () {

    if(EnvironmentType == Environment_Type.WAIWANG)
        return "https://h5-game.feiyuapi.com/qq/zhtest/";//云外网
    else if(EnvironmentType == Environment_Type.PREPUBLISH)
        return "https://login.bwlbh5.qq.com/preqq/";
    else if(EnvironmentType == Environment_Type.ZHENGSHI)
        return "https://login.bwlbh5.qq.com/qq/";
    else
        return "https://h5-game.feiyuapi.com/qq/test/";

}
/**
 * 返回CDN地址
 * @returns {string}
 */
GamePlatform.getCDN = function () {

    var platform = this.getCurrentPlatForm();
    switch (platform)
    {
        case PlatformType.QQ:
            if(EnvironmentType == Environment_Type.WAIWANG)
                return "https://h5-game.feiyuapi.com/qq/zhtest/";//云外网
            else if(EnvironmentType == Environment_Type.PREPUBLISH)
                return "https://image.bwlbh5.qq.com/cdn/preqq/";
            else if(EnvironmentType == Environment_Type.ZHENGSHI)
                return "https://image.bwlbh5.qq.com/cdn/qq/";
            else
                 return "https://h5-game.feiyuapi.com/qq/";

            break;
        case PlatformType.WeiXinApp:
          
            if(EnvironmentType == Environment_Type.WAIWANG)
                return "https://h5-game.feiyuapi.com/qq/";//云外网
            else if(EnvironmentType == Environment_Type.PREPUBLISH)
                return "https://image.bwlbh5.qq.com/cdn/prewx/";
            else if(EnvironmentType == Environment_Type.ZHENGSHI)
                return "https://image.bwlbh5.qq.com/cdn/wx/";
             else
                return "https://h5-game.feiyuapi.com/qq/xcx/";
            break;
        case PlatformType.FaceBook:
            return "";
        default:
            return "";
    }

}

module.exports = GamePlatform;