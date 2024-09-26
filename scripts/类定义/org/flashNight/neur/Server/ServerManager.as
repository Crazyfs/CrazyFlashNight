class org.flashNight.neur.Server.ServerManager {
    public static var instance:ServerManager;
    public var portList:Array;
    public var portIndex:Number;
    public var currentPort:Number;

    public function ServerManager() {
        portList = [];
        portIndex = 0;
        currentPort = 3000;
        extractPorts();
    }

    public static function getInstance():ServerManager {
        if (instance == null) {
            instance = new ServerManager();
        }
        return instance;
    }

    public function extractPorts():Void {
        // 如果 _root.闪客之夜 存在，则使用它，否则使用一个默认值
        var eyeOf119:String = (_root.闪客之夜 != undefined) ? _root.闪客之夜.toString() : "1192433993";
        
        for (var i:Number = 0; i <= eyeOf119.length - 4; i++) {
            portList.push(Number(eyeOf119.substring(i, i + 4)));
        }
        for (var j:Number = 0; j <= eyeOf119.length - 5; j++) {
            portList.push(Number(eyeOf119.substring(j, j + 5)));
        }
    }

    public function getAvailablePort():Void {
        if (portIndex < portList.length) {
            var port:Number = portList[portIndex];
            var lv:LoadVars = new LoadVars();
            var self = this;  // 保存对当前实例的引用，方便在回调函数中使用
            
            lv.onLoad = function(success:Boolean) {
                if (success) {
                    trace("Connected to port: " + port);
                    self.currentPort = port; // 成功连接
                } else {
                    trace("Failed to connect to port: " + port);
                    self.portIndex++;
                    self.getAvailablePort(); // 递归调用，尝试下一个端口
                }
            };

            lv.sendAndLoad("http://localhost:" + port + "/testConnection", lv, "POST");

            // 如果 _root.帧计时器 存在，则使用它，否则使用一个本地的 setTimeout 模拟
            if (_root.帧计时器 != undefined) {
                _root.帧计时器.添加单次任务(self.getAvailablePort, 5000); // 5秒超时
            } else {
                // 模拟 _root.帧计时器.添加单次任务 的行为
                setTimeout(function() { self.getAvailablePort(); }, 5000);
            }
        } else {
            trace("No available ports found.");
        }
    }

    public function sendServerMessage(message:String):Void {
        var lv:LoadVars = new LoadVars();
        
        // 如果 _root.帧计时器 存在，则使用它，否则使用默认帧数 0
        var currentFrame:String = (_root.帧计时器 != undefined) ? _root.帧计时器.当前帧数 : "0";
        message = currentFrame + " " + message;

        lv.message = message;
        var url:String = "http://localhost:" + currentPort + "/log";
        lv.sendAndLoad(url, lv, "POST");
        // trace("Message sent to port " + currentPort);
    }
}
