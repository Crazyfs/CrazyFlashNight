﻿import org.flashNight.neur.Controller.PIDController;
import org.flashNight.neur.ScheduleTimer.CerberusScheduler;
import org.flashNight.naki.DataStructures.*;
import org.flashNight.sara.*;
import org.flashNight.neur.Server.*; 
import org.flashNight.neur.Event.EventBus;
_root.帧计时器 = _root.createEmptyMovieClip("帧计时器", _root.getNextHighestDepth());


_root.帧计时器.初始化任务栈 = function()
 {  
    //this.任务栈 = []; 
	//this.待移除任务表 = []; 
	//this.待添加任务表 = [];
    //this.待移除移除任务id表 = {};
    this.任务哈希表 = {}; // 频繁更新的任务利用键值对单独维护
    this.当前帧数 = 0; 
    this.任务ID计数器 = 0;
    this.目标缓存 = {};
    this.目标缓存["undefined"] = { 数据: [], 最后更新帧数: 0 };
    this.目标缓存["true"] = { 数据: [], 最后更新帧数: 0 };
    this.目标缓存["false"] = { 数据: [], 最后更新帧数: 0 };
    this.帧率 = 30;//当前项目为30帧/s
    this.毫秒每帧 = this.帧率 / 1000;//用于乘法优化性能
    this.每帧毫秒 = 1000 / this.帧率;
    this.帧开始时间 = 0;
    this.测量间隔帧数 = this.帧率;
    this.帧率数据队列 = [];
    this.队列最大长度 = 24;
    this.总帧率 = 0;  // 存储所有帧率之和
    this.最小帧率 = 30;  // 初始化为一个合理的默认最大值
    this.最大帧率 = 0;  // 初始化为0
    this.最小差异 = 5;//最大最小帧率差的最小值
    this.异常间隔帧数 = this.帧率 * 5;
    this.实际帧率 = 0;
    this.性能等级 = 0;
    this.预设画质 = _quality;
    this.更新天气间隔 = 5 * this.帧率;
    this.天气待更新时间 = this.更新天气间隔;
    this.光照等级数据 = [];//存储短期内的天气情况
    this.当前小时 = null;

    this.是否死亡特效 = true;

    this.kp = 0.2;
    this.ki = 0.5;
    this.kd = -30;
    this.integralMax = 3; // 设定积分限幅
    this.derivativeFilter = 0.2; // 平滑误差
    this.目标帧率 = 26;
    this.PID = new org.flashNight.neur.Controller.PIDController(this.kp, this.ki, this.kd, this.integralMax, this.derivativeFilter);

    this.ScheduleTimer = new CerberusScheduler();

    this.singleWheelSize = 150;
    this.multiLevelSecondsSize = 60;
    this.multiLevelMinutesSize = 60;
    this.precisionThreshold = 0.1;
    this.ScheduleTimer.initialize(this.singleWheelSize,
                                  this.multiLevelSecondsSize, 
                                  this.multiLevelMinutesSize, 
                                  this.帧率, 
                                  this.precisionThreshold);

    this.zeroFrameTasks = {}; // Use an object or array to store tasks
    this.eventBus = new EventBus();

};

_root.帧计时器.初始化任务栈();
_root.帧计时器.更新帧率数据 = function(当前帧率) 
{
    var 被移除的数据 = null;
    if (this.帧率数据队列.length >= this.队列最大长度) 
    {
        被移除的数据 = this.帧率数据队列.shift();  // 移除最旧的数据
        this.总帧率 -= 被移除的数据.帧率;
        this.帧率数据队列.push({帧率: 当前帧率});
    }
    else
    {
        this.总帧率 = 当前帧率 * this.队列最大长度;
        while (this.帧率数据队列.length < this.队列最大长度) 
        {
            this.帧率数据队列.push({帧率: 当前帧率});// 处理帧率数据未满的情况
        }
    }

    this.总帧率 += 当前帧率;// 添加新帧率数据
    if (当前帧率 > this.最大帧率) this.最大帧率 = 当前帧率;// 更新最小和最大帧率
    if (当前帧率 < this.最小帧率) this.最小帧率 = 当前帧率;

    // 检查移除的数据是否影响最小或最大值
    if (被移除的数据) 
    {
        if (被移除的数据.帧率 === this.最小帧率 or 被移除的数据.帧率 === this.最大帧率) 
        {
            // 重新评估最小或最大帧率
            this.最小帧率 = this.帧率数据队列[0].帧率;
            this.最大帧率 = this.帧率数据队列[0].帧率;
            for (var i = 1; i < this.队列最大长度; ++i) 
            {
                var 帧率 = this.帧率数据队列[i].帧率;
                if (帧率 < this.最小帧率) this.最小帧率 = 帧率;
                if (帧率 > this.最大帧率) this.最大帧率 = 帧率;
            }
        }
    }

    this.平均帧率 = this.总帧率 / this.队列最大长度;// 更新平均帧率
    if (this.最大帧率 - this.最小帧率 < this.最小差异) 
    {
        var 差额 = (this.最小差异 - (this.最大帧率 - this.最小帧率)) / 2;
        this.最小帧率 -= 差额;
        this.最大帧率 += 差额;
        this.帧率差 = this.最小差异;
    }
    else
    {
        this.帧率差 = this.最大帧率 - this.最小帧率;
    }

    var 光照起点小时 = Math.floor(_root.天气系统.当前时间);
    if(this.当前小时 !== 光照起点小时)
    {
        this.光照等级数据 = [];// 添加绘制光照等级的逻辑
        this.当前小时 = 光照起点小时;
        for (var i = 0; i < this.队列最大长度; ++i) 
        {
            this.光照等级数据.push(_root.天气系统.昼夜光照[(光照起点小时 + i) % 24]);// 推入未来队列最大长度的光照等级
        }
    }
};

_root.帧计时器.绘制帧率曲线 = function() 
{
    var 画布 = _root.玩家信息界面.性能帧率显示器.画布;
    var 高度 = 14;  // 曲线图的高度
    var 宽度 = 72;  // 曲线图的宽度
    var 步进长度 = 宽度 / this.队列最大长度;

    画布._x = 2;  // 设置画布位置
    画布._y = 2;
    画布.clear();//重置绘图区

    // 开始绘制光照等级曲线
    var 线条颜色 = 0x333333; // 灰色线条表示光照等级
    //画布.lineStyle(0.5, 线条颜色, 100);
    画布.beginFill(线条颜色, 100); // 开始填充区域
    var 光照步进高度 = 高度 / 9;
    var x0 = 0;
    var y0 = 高度 - (this.光照等级数据[0] * 光照步进高度);

    画布.moveTo(x0, 高度); // 移动到起点底部
    画布.lineTo(x0, y0); // 移动到起点

    for (var i = 1; i < this.队列最大长度; ++i) 
    {
        var x1 = x0 + 步进长度;
        var y1 = 高度 - (this.光照等级数据[i] * 光照步进高度);

        画布.curveTo((x0 + x1) / 2, (y0 + y1) / 2, x1, y1); // 绘制二次贝塞尔曲线
       
        x0 = x1; // 更新起点
        y0 = y1;
    }

    画布.lineTo(x0, 高度); // 从最后一个点连接到底部
    画布.endFill(); // 完成填充区域

    var 线条颜色;
    switch(this.性能等级)
    {
        case 0: 线条颜色 = 0x00FF00;break;
        case 1: 线条颜色 = 0x00CCFF;break;
        case 2: 线条颜色 = 0xFFFF00;break;
        default: 线条颜色 = 0xFF0000;
    }
    画布.lineStyle(1.5, 线条颜色, 100);  // 设置线条样式（绿色）


    // 绘制帧率曲线
    var 帧率步进高度 = 高度 / this.帧率差;
    var x0 = 0;
    var y0 = 高度 - ((this.帧率数据队列[0].帧率 - this.最小帧率) * 帧率步进高度);
    
    画布.moveTo(x0, y0);

    for (var i = 1; i < this.队列最大长度; i++) 
    {
        var x1 = x0 + 步进长度;
        var y1 = 高度 - ((this.帧率数据队列[i].帧率 - this.最小帧率) * 帧率步进高度);

        画布.curveTo((x0 + x1) / 2, (y0 + y1) / 2, x1, y1);// 绘制二次贝塞尔曲线
 
        x0 = x1;// 更新起点
        y0 = y1;
    }
};

_root.帧计时器.性能评估优化 = function()
{
    if (--this.测量间隔帧数 === 0) 
    {
        var 当前时间 = getTimer();  // 获取当前时间
        this.实际帧率 = Math.ceil(this.帧率 * (1 + this.性能等级) * 10000 / (当前时间 - this.帧开始时间)) / 10;  // 计算实际帧率
        //_root.服务器.发布服务器消息("当前实际帧率: " + this.实际帧率 + " FPS");

        
        //原pi控制器
        /*
        var 当前性能 = this.性能等级;
        if (this.实际帧率 >= 24 + 当前性能 * 2.5) 
        {
            当前性能 = 0;
        } 
        else if (this.实际帧率 >= 18 + 当前性能 * 5) 
        {
            当前性能 = 1;
        }
        else if (this.实际帧率 >= 10 + 当前性能 * 5) 
        {
            当前性能 = 2;
        }  
        else 
        {
            当前性能 = 3;
        }
        */
        // PID 控制器接管性能等级调整
        var 目标帧率 = this.帧率 - this.性能等级 * 2;
        var pidOutput = this.PID.update(this.目标帧率, this.实际帧率, this.帧率 * (1 + this.性能等级)); // 调用PID控制器更新

        var 当前性能 = Math.round(pidOutput); // PID输出的结果作为性能等级
        //_root.服务器.发布服务器消息(目标帧率 + " 当前帧率: " + this.实际帧率 + " pidOutput: " + pidOutput + " 当前性能: " + 当前性能);
        当前性能 = Math.max(0, Math.min(当前性能, 3)); // 限制性能等级在 0-3 之间

        // 引入一个确认步骤，避免过于频繁的性能调整
        if (this.性能等级 !== 当前性能) 
        {
            if (this.等待确认) 
            {
                this.执行性能调整(当前性能);// 如果已经在等待确认，执行调整
                this.性能等级 = 当前性能;
                this.等待确认 = false;
                _root.发布消息("性能等级: [" + this.性能等级  + " : " + this.实际帧率 + " FPS] " + _quality);
            } 
            else 
            {
                this.等待确认 = true;// 如果不在等待确认，开始确认
            }
        } else 
        {
            this.等待确认 = false;// 如果性能等级没有变化或调整后稳定，重置确认标志
        }

        this.帧开始时间 = 当前时间;
        this.测量间隔帧数 = this.帧率 * (1 + this.性能等级);
        this.更新帧率数据(this.实际帧率);
        this.绘制帧率曲线();//游戏UI更新
    }
};

_root.帧计时器.执行性能调整 = function(新性能等级) 
{
    switch (新性能等级) 
    {
        case 0:
            _root.效果上限 = 20;
            _root.画面效果上限 = 20;
            _root.面积系数 = 300000;
            _root.同屏打击数字特效上限 = 25;
            this.是否死亡特效 = true;
            _quality = this.预设画质;
            _root.天气系统.光照等级更新阈值 = 0.1;
            _root.弹壳系统.弹壳总数上限 = 25;
            _root.发射效果上限 = 15;
            _root.显示列表.继续播放(_root.显示列表.预设任务ID);
            _root.UI系统.经济面板动效 = true;
            break;
        case 1:
            _root.效果上限 = 15;
            _root.画面效果上限 = 15;
            _root.面积系数 = 450000; 
            _root.同屏打击数字特效上限 = 18;
            this.是否死亡特效 = true;
            _quality = this.预设画质 === 'LOW' ? this.预设画质 : 'MEDIUM';
            _root.天气系统.光照等级更新阈值 = 0.2;
            _root.弹壳系统.弹壳总数上限 = 18;
            _root.发射效果上限 = 10;
            _root.显示列表.继续播放(_root.显示列表.预设任务ID);
            _root.UI系统.经济面板动效 = true;
            break;
        case 2:
            _root.效果上限 = 10;
            _root.画面效果上限 = 10;
            _root.面积系数 = 600000; //刷佣兵数量砍半
            _root.同屏打击数字特效上限 = 12;
            this.是否死亡特效 = false;
            _root.天气系统.光照等级更新阈值 = 0.5;
            _quality = 'LOW';
            _root.弹壳系统.弹壳总数上限 = 12;
            _root.发射效果上限 = 5;
            _root.显示列表.暂停播放(_root.显示列表.预设任务ID);
            _root.UI系统.经济面板动效 = false;
            break;
        default:
            _root.效果上限 = 0;  // 禁用效果
            _root.画面效果上限 = 5;  // 最低上限
            _root.面积系数 = 3000000;  //刷佣兵为原先十分之一
            _root.同屏打击数字特效上限 = 10;
            this.是否死亡特效 = false;
            _root.天气系统.光照等级更新阈值 = 1;
            _quality = 'LOW';
            _root.弹壳系统.弹壳总数上限 = 10;
            _root.发射效果上限 = 0;
            _root.显示列表.暂停播放(_root.显示列表.预设任务ID);
            _root.UI系统.经济面板动效 = false;
    }
};

_root.帧计时器.执行性能调整(0);

_root.帧计时器.定期异常检查 = function()
{
    if (--this.异常间隔帧数 === 0) 
    {
        var 游戏世界 = _root.gameworld;

        for (var 待选目标 in 游戏世界) 
        {
            var 目标 = 游戏世界[待选目标];
            if(目标.hp > 0)
            {
                目标.异常指标 = 0;
            }
            else if(目标.hp <= 0 and 目标.hp !== undefinded)
            {
                if(++目标.异常指标 > 2)
                {
                    if(++目标.移除指标 > 2)
                    {
                        目标.removeMovieClip();
                        _root.发布消息("remove " + 目标);
                    }
                    else if(目标.异常指标 === 3)
                    {
                        目标.死亡检测();
                        _root.发布消息("kill " + 目标);
                    }
                }
            }

        }   
        _root.服务器.发布服务器消息("正在检查异常");
        this.异常间隔帧数 = this.帧率 * 5;
    }
};

_root.帧计时器.定期更新天气 = function()
{
    var 游戏世界 = _root.gameworld;
    if (--this.天气待更新时间 === 0 or !游戏世界.已更新天气) 
    {
        _root.天气系统.设置当前天气();
        if(!游戏世界.已更新天气)
        {                                                                                                                                                                                                                                                                                                                                                                                           
            游戏世界.已更新天气 = true;//保证换场景可切换

            // 游戏世界.onUnload = function()
            // {
            //     _root.常用工具函数.释放对象绘图内存(游戏世界);
            //     //_root.服务器.发布服务器消息("游戏世界卸载");	
            // };

        }
        
        this.天气待更新时间 = this.更新天气间隔 * (1 + this.性能等级);

    }
    //_root.服务器.发布服务器消息("正在更新天气" + _root.格式化对象为字符串(_root.天气系统.环境设置));
};

_root.帧计时器.键盘输入控制目标 = function()
{
    var 控制对象 = _root.gameworld[_root.控制目标];
    if(!控制对象) return;
    if(_root.暂停){
        控制对象.左行 = false;
        控制对象.右行 = false;
        控制对象.上行 = false;
        控制对象.下行 = false;
        控制对象.动作A = false;
        控制对象.动作B = false;
        控制对象.动作C = false;
        控制对象.强制奔跑 = false;
    }else{
        控制对象.左行 = Key.isDown(控制对象.左键);
        控制对象.右行 = Key.isDown(控制对象.右键);
        控制对象.上行 = Key.isDown(控制对象.上键);
        控制对象.下行 = Key.isDown(控制对象.下键);
        控制对象.动作A = Key.isDown(控制对象.A键);
        控制对象.动作B = Key.isDown(控制对象.B键);
        控制对象.动作C = Key.isDown(控制对象.C键);
        控制对象.强制奔跑 = !控制对象.动作A && !控制对象.动作B && !控制对象.动作C && Key.isDown(_root.奔跑键);
    }
}

_root.帧计时器.eventBus.subscribe("frameUpdate", function(当前帧数) {
    this.性能评估优化();
    this.定期更新天气();
    this.键盘输入控制目标();
}, _root.帧计时器);

_root.帧计时器.eventBus.subscribe("frameUpdate", function(当前帧数) {
    _root.显示列表.播放列表();
}, _root.帧计时器);

_root.帧计时器.eventBus.subscribe("frameUpdate", function(当前帧数) {
    _root.UI系统.虚拟币刷新();
    _root.UI系统.金钱刷新();
}, _root.帧计时器);

_root.帧计时器.eventBus.subscribe("frameUpdate", function(当前帧数) {
    var tasks = this.ScheduleTimer.tick();

    if (tasks != null) {
        var node = tasks.getFirst();
        while (node != null) {
            var nextNode = node.next;
            var taskID = node.taskID;
            var 任务 = this.任务哈希表[taskID];
            if (任务) {
                任务.动作();
                // 处理任务重复逻辑
                if (任务.重复次数 === 1) {
                    delete this.任务哈希表[taskID];
                } else if (任务.重复次数 === true || 任务.重复次数 > 1) {
                    if (任务.重复次数 !== true) {
                        任务.重复次数 -= 1;
                    }
                    任务.待执行帧数 = 任务.间隔帧数;
                    任务.node = this.ScheduleTimer.evaluateAndInsertTask(taskID, 任务.待执行帧数);
                } else {
                    delete this.任务哈希表[taskID];
                }
            }
            node = nextNode;
        }
    }

    // 处理零帧任务
    for (var taskID in this.zeroFrameTasks) {
        var 任务 = this.zeroFrameTasks[taskID];
        任务.动作();
        if (任务.重复次数 !== true) {
            任务.重复次数 -= 1;
            if (任务.重复次数 <= 0) {
                delete this.zeroFrameTasks[taskID];
            }
        }
    }
}, _root.帧计时器);

_root.帧计时器.onEnterFrame = function() {
    this.当前帧数 += 1;

    // 发布帧更新事件，传递当前帧数
    this.eventBus.publish("frameUpdate", this.当前帧数);
};


_root.帧计时器.移除任务 = function(任务ID)
{
    var 任务 = this.任务哈希表[任务ID];
    
    if (任务) 
    {
        var 节点 = 任务.节点;
        this.ScheduleTimer.removeTaskByNode(节点);
        delete this.任务哈希表[任务ID];  // Remove from hash table
    } else if (this.zeroFrameTasks[任务ID]) {
        delete this.zeroFrameTasks[任务ID]; // Remove from zero-frame tasks
    }
};



// 添加任务函数
_root.帧计时器.添加任务 = function(动作, 间隔时间, 重复次数) {
    var 任务ID = ++this.任务ID计数器;
    var 间隔帧数 = Math.ceil(间隔时间 * this.毫秒每帧);
    var 参数数组 = arguments.length > 3 ? Array.prototype.slice.call(arguments, 3) : [];

    var 任务 = {
        id: 任务ID,
        动作: function() { 动作.apply(任务, 参数数组); },
        间隔帧数: 间隔帧数,
        重复次数: 重复次数 === undefined || 重复次数 === null ? 1 : 重复次数,
        参数数组: 参数数组
    };

    if (间隔帧数 <= 0) {
        this.zeroFrameTasks[任务ID] = 任务;
    } else {
        任务.待执行帧数 = 间隔帧数;
        任务.节点 = this.ScheduleTimer.evaluateAndInsertTask(任务ID, 间隔帧数);
        this.任务哈希表[任务ID] = 任务;
    }

    return 任务ID;
};


_root.帧计时器.添加单次任务 = function(动作, 间隔时间)
{
    // 检查间隔时间是否小于或等于0
    if (间隔时间 <= 0) {
        // 立即执行任务动作
        动作.apply(null, arguments.length > 2 ? Array.prototype.slice.call(arguments, 2) : []);
        // 返回特殊值，表示任务已立即执行（例如，返回null或0）
        return null; 
    } else {
        // 正常添加任务，重复次数为1
        var 完整参数 = [动作, 间隔时间, 1].concat(arguments.length > 2 ? Array.prototype.slice.call(arguments, 2) : []);
        return this.添加任务.apply(this, 完整参数); // 返回任务ID
    }
};


_root.帧计时器.添加循环任务 = function(动作, 间隔时间)
 {
    var 完整参数 = [动作, 间隔时间, true].concat(arguments.length > 2 ? Array.prototype.slice.call(arguments, 2) : []);// 使用_apply_调用添加任务，确保_this_指向帧计时器对象

    return this.添加任务.apply(this, 完整参数); // 返回任务ID
};

_root.帧计时器.添加或更新任务 = function(对象, 标签名, 动作, 间隔时间) 
{
    if (!对象.任务标识) 对象.任务标识 = {};
    if (!对象.任务标识[标签名]) 
    {
        对象.任务标识[标签名] = ++this.任务ID计数器;
    }

    var 任务ID = 对象.任务标识[标签名];
    var 间隔帧数 = Math.ceil(间隔时间 * this.毫秒每帧);
    var 参数数组 = arguments.length > 4 ? Array.prototype.slice.call(arguments, 4) : [];
    var 动作封装 = function() { 动作.apply(对象, 参数数组); };  // Ensure correct context and parameter passing

    // Retrieve the task from either 任务哈希表 or zeroFrameTasks
    var 任务 = this.任务哈希表[任务ID] || this.zeroFrameTasks[任务ID];
    if (任务) 
    {
        任务.动作 = 动作封装;
        任务.间隔帧数 = 间隔帧数;
        任务.参数数组 = 参数数组;

        if (间隔帧数 === 0) {
            // Move task to zeroFrameTasks if necessary
            if (this.任务哈希表[任务ID]) {
                this.ScheduleTimer.removeTaskByNode(任务.节点);
                delete 任务.节点; // Remove node reference
                delete this.任务哈希表[任务ID];
                this.zeroFrameTasks[任务ID] = 任务;
            }
            // No need to reschedule zero-frame tasks
        } else {
            if (this.zeroFrameTasks[任务ID]) {
                // Move task from zeroFrameTasks to 任务哈希表
                delete this.zeroFrameTasks[任务ID];
                任务.待执行帧数 = 间隔帧数;
                任务.节点 = this.ScheduleTimer.evaluateAndInsertTask(任务ID, 间隔帧数);
                this.任务哈希表[任务ID] = 任务;
            } else {
                // Reschedule the task in ScheduleTimer
                任务.待执行帧数 = 间隔帧数;
                this.ScheduleTimer.rescheduleTaskByNode(任务.节点, 间隔帧数);
            }
        }
    } 
    else 
    {
        // Task does not exist, create a new one
        任务 = {
            id: 任务ID,
            动作: 动作封装,
            间隔帧数: 间隔帧数,
            重复次数: 1,
            参数数组: 参数数组
        };

        if (间隔帧数 === 0) {
            this.zeroFrameTasks[任务ID] = 任务;
        } else {
            任务.待执行帧数 = 间隔帧数;
            任务.节点 = this.ScheduleTimer.evaluateAndInsertTask(任务ID, 间隔帧数);
            this.任务哈希表[任务ID] = 任务;
        }
    }

    return 任务ID;
};


_root.帧计时器.添加生命周期任务 = function(对象, 标签名, 动作, 间隔时间) {
    if (!对象.任务标识) 对象.任务标识 = {};
    if (!对象.任务标识[标签名]) 
    {
        对象.任务标识[标签名] = ++this.任务ID计数器;
    }

    var 任务ID = 对象.任务标识[标签名];
    var 间隔帧数 = Math.ceil(间隔时间 * this.毫秒每帧);
    var 参数数组 = arguments.length > 4 ? Array.prototype.slice.call(arguments, 4) : [];
    var 动作封装 = function() { 动作.apply(对象, 参数数组); };

    // Create or update the task
    var 任务 = this.任务哈希表[任务ID] || this.zeroFrameTasks[任务ID];
    if (任务) {
        任务.动作 = 动作封装;
        任务.间隔帧数 = 间隔帧数;
        任务.参数数组 = 参数数组;
        任务.重复次数 = true; // Set to infinite repetition

        if (间隔帧数 === 0) {
            if (this.任务哈希表[任务ID]) {
                this.ScheduleTimer.removeTaskByNode(任务.节点);
                delete 任务.节点;
                delete this.任务哈希表[任务ID];
                this.zeroFrameTasks[任务ID] = 任务;
            }
        } else {
            if (this.zeroFrameTasks[任务ID]) {
                delete this.zeroFrameTasks[任务ID];
                任务.待执行帧数 = 间隔帧数;
                任务.节点 = this.ScheduleTimer.evaluateAndInsertTask(任务ID, 间隔帧数);
                this.任务哈希表[任务ID] = 任务;
            } else {
                任务.待执行帧数 = 间隔帧数;
                this.ScheduleTimer.rescheduleTaskByNode(任务.节点, 间隔帧数);
            }
        }
    } else {
        // Create a new task
        任务 = {
            id: 任务ID,
            动作: 动作封装,
            间隔帧数: 间隔帧数,
            重复次数: true, // Infinite repetition
            参数数组: 参数数组
        };

        if (间隔帧数 === 0) {
            this.zeroFrameTasks[任务ID] = 任务;
        } else {
            任务.待执行帧数 = 间隔帧数;
            任务.节点 = this.ScheduleTimer.evaluateAndInsertTask(任务ID, 间隔帧数);
            this.任务哈希表[任务ID] = 任务;
        }
    }

    // Set unload callback to remove the task when the object is destroyed
    _root.常用工具函数.设置卸载回调(对象, function() {
        _root.帧计时器.移除任务(任务ID);
        delete this.任务标识[标签名];
    });

    return 任务ID;
};



_root.帧计时器.定位任务 = function(任务ID)
{  
    return this.任务哈希表[任务ID] || this.zeroFrameTasks[任务ID] || null;
};


_root.帧计时器.延迟执行任务 = function(任务ID, 延迟时间) 
{  
    var 任务 = this.任务哈希表[任务ID] || this.zeroFrameTasks[任务ID];

    if (任务) 
    {  
        var 延迟帧数;
        if (isNaN(延迟时间))
        {
            任务.待执行帧数 = 延迟时间 === true ? Infinity : 任务.间隔帧数;
        }
        else
        {
            延迟帧数 = Math.ceil(延迟时间 * this.毫秒每帧);
            任务.待执行帧数 += 延迟帧数;
        }

        if (任务.待执行帧数 <= 0) {
            // Should be a zero-frame task
            if (this.任务哈希表[任务ID]) {
                // Move to zeroFrameTasks
                this.ScheduleTimer.removeTaskByNode(任务.节点);
                delete 任务.节点;
                delete this.任务哈希表[任务ID];
                this.zeroFrameTasks[任务ID] = 任务;
            }
            // Else, already in zeroFrameTasks
        } else {
            // Should be in ScheduleTimer
            if (this.zeroFrameTasks[任务ID]) {
                // Move to 任务哈希表 and schedule
                delete this.zeroFrameTasks[任务ID];
                任务.节点 = this.ScheduleTimer.evaluateAndInsertTask(任务ID, 任务.待执行帧数);
                this.任务哈希表[任务ID] = 任务;
            } else {
                // Reschedule in ScheduleTimer
                this.ScheduleTimer.rescheduleTaskByNode(任务.节点, 任务.待执行帧数);
            }
        }

        return true; // Delay set successfully
    }  
    return false; // Task not found, delay set failed
};


_root.帧计时器.确保目标缓存存在 = function(自机状态, 请求类型) 
{
    var 自机状态键 = 自机状态.toString();
    if (!this.目标缓存[自机状态键]) 
    {
        this.目标缓存[自机状态键] = {};
        this.目标缓存[自机状态键][请求类型] = { 数据: [], 最后更新帧数: 0 };
    }
    else if (!this.目标缓存[自机状态键][请求类型]) 
    {
        this.目标缓存[自机状态键][请求类型] = { 数据: [], 最后更新帧数: 0 };
    }
};

_root.帧计时器.更新目标缓存 = function(自机:Object, 更新间隔:Number, 请求类型:String, 自机状态键:String)
{
    更新间隔 = isNaN(更新间隔) ? 1 : 更新间隔;
    if (!this.目标缓存[自机状态键]) 
    {
        this.目标缓存[自机状态键] = {};
        this.目标缓存[自机状态键][请求类型] = { 数据: [], 最后更新帧数: 0 };
    }
    else if (!this.目标缓存[自机状态键][请求类型]) 
    {
        this.目标缓存[自机状态键][请求类型] = { 数据: [], 最后更新帧数: 0 };
    }

    var 目标缓存对象 = this.目标缓存[自机状态键][请求类型];
    目标缓存对象.数据.length = 0;//刷新缓存
    var 游戏世界 = _root.gameworld;
    var 条件判断函数:Function;

    switch (请求类型)
    {
        case "敌人":条件判断函数 = function(目标:Object):Boolean {
            return 自机.是否为敌人 != 目标.是否为敌人;
        };break;
        case "友军":
        default:条件判断函数 = function(目标:Object):Boolean {
            return 自机.是否为敌人 == 目标.是否为敌人;
        };
    }
    
    目标缓存对象.数据.length = 0;
    for (var 待选目标 in 游戏世界) 
    {
        var 目标 = 游戏世界[待选目标];
        if(目标.hp > 0)
        {
            //if (目标.是否为敌人 === undefinded) 目标.是否为敌人 = true;
            if (条件判断函数(目标)) 目标缓存对象.数据.push(目标);
        }
        //_root.服务器.发布服务器消息(目标 + " ," + 目标.命中率 + " ," + 目标.躲闪率);
    }
    目标缓存对象.最后更新帧数 = this.当前帧数;
};

_root.帧计时器.获取目标缓存 = function(自机:Object, 更新间隔:Number, 请求类型:String) 
{
    var 自机状态键 = 自机.是否为敌人.toString();
    var 目标缓存对象 = this.目标缓存[自机状态键][请求类型];

    if (isNaN(目标缓存对象.最后更新帧数) or this.当前帧数 - 目标缓存对象.最后更新帧数 > 更新间隔) 
    {
        this.更新目标缓存(自机, 更新间隔, 请求类型, 自机状态键);
    }

    return 目标缓存对象.数据;
};

_root.帧计时器.获取敌人缓存 = function(自机:Object, 更新间隔:Number) 
{
    var 自机状态键 = 自机.是否为敌人.toString();
    var 目标缓存对象 = this.目标缓存[自机状态键]["敌人"];

    if (isNaN(目标缓存对象.最后更新帧数) or this.当前帧数 - 目标缓存对象.最后更新帧数 > 更新间隔) 
    {
        this.更新目标缓存(自机, 更新间隔, "敌人", 自机状态键);
    }

    return 目标缓存对象.数据;
};

_root.帧计时器.获取友军缓存 = function(自机:Object, 更新间隔:Number) 
{
    var 自机状态键 = 自机.是否为敌人.toString();
    var 目标缓存对象 = this.目标缓存[自机状态键]["友军"];

    if (isNaN(目标缓存对象.最后更新帧数) or this.当前帧数 - 目标缓存对象.最后更新帧数 > 更新间隔) 
    {
        this.更新目标缓存(自机, 更新间隔, "友军", 自机状态键);
    }

    return 目标缓存对象.数据;
};

_root.帧计时器.添加主动战技cd = function(动作, 间隔时间)
 {
    return _root.帧计时器.添加单次任务(动作, 间隔时间); // 返回任务ID
};