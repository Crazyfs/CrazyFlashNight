_root.弹壳系统 = {};

// 物理运动函数
_root.弹壳系统.弹壳物理运动 = function(弹壳) {   
    if (弹壳._y - 弹壳.Z轴坐标 < -5) {
        弹壳.垂直速度 += 4;
        弹壳._x += 弹壳.水平速度;
        弹壳._y += 弹壳.垂直速度;
        弹壳._rotation += 弹壳.旋转速度;
    } else {
        弹壳.垂直速度 = 弹壳.垂直速度 / -2 - _root.随机整数(0, 5);
        弹壳._xscale = Math.max(Math.sin(弹壳._rotation * Math.PI / 180), 0.5) * 弹壳._xscale; // 设置最小缩放值为50%
        if (弹壳.垂直速度 < -10) {
            弹壳.水平速度 += _root.随机浮点偏移(4);
            弹壳.旋转速度 = 弹壳.旋转速度 * 1.5 + _root.随机浮点(0, 25);
            弹壳._x += 弹壳.水平速度;
            弹壳._y = 弹壳.Z轴坐标 - 6;
            弹壳._rotation += 弹壳.旋转速度;
        } else {
            _root.add2map3(弹壳, 2);
            _root.帧计时器.移除任务(弹壳.任务ID);
            _root.帧计时器.添加或更新任务(弹壳, "回收", function(弹壳) {
                弹壳._visible = false;
                _root.gameworld.可用弹壳池[弹壳.弹壳种类].push(弹壳);
                --_root.弹壳系统.当前弹壳总数;
            }, 1, 弹壳);
        }
    }
};

// 物理模拟函数
_root.弹壳系统.弹壳物理模拟 = function(弹壳) {
    弹壳.水平速度 = _root.随机浮点偏移(4);
    弹壳.垂直速度 = _root.随机浮点(-8, -20);
    弹壳.旋转速度 = _root.随机浮点(-10, 10); 
    弹壳.Z轴坐标 = 弹壳._y + 100;
    弹壳.swapDepths(弹壳.Z轴坐标);
    弹壳.任务ID = _root.帧计时器.添加生命周期任务(弹壳, "运动", this.弹壳物理运动, 33, 弹壳); // 2帧1动让视觉更柔和
};

// 获取或创建原型弹壳（懒加载）
_root.弹壳系统.获取或创建原型弹壳 = function(弹壳种类) {
    if (this.弹壳映射表[弹壳种类].原型) {
        return this.弹壳映射表[弹壳种类].原型;
    }
    var 游戏世界 = _root.gameworld;
    var 世界效果 = 游戏世界.效果;
    var 原型弹壳 = 世界效果.attachMovie(弹壳种类, "prototype_" + 弹壳种类, 世界效果.getNextHighestDepth());
    原型弹壳._visible = false; // 原型不可见
    this.弹壳映射表[弹壳种类].原型 = 原型弹壳;
    return 原型弹壳;
};

// 创建弹壳（使用原型模式和懒加载）
_root.弹壳系统.创建弹壳 = function(弹壳种类, myX, myY) {
    var 原型弹壳 = this.获取或创建原型弹壳(弹壳种类);
    var 游戏世界 = _root.gameworld;
    var 世界效果 = 游戏世界.效果;
    var 效果深度 = 世界效果.getNextHighestDepth();
    var 创建的弹壳 = 原型弹壳.duplicateMovieClip(弹壳种类 + " " + 效果深度, 效果深度);
    创建的弹壳._x = myX;
    创建的弹壳._y = myY;
    创建的弹壳._visible = true;
    this.弹壳物理模拟(创建的弹壳);
    return 创建的弹壳;
};

// 发射弹壳
_root.弹壳系统.发射弹壳 = function(子弹类型, myX, myY, xscale, 必然触发) {
    if (this.当前弹壳总数 <= this.弹壳总数上限 || _root.成功率(this.弹壳总数上限) || 必然触发) {
        var 弹壳信息 = this.弹壳映射表[子弹类型];
        var 弹壳种类 = 弹壳信息.弹壳;
        var 游戏世界 = _root.gameworld;
        if (!弹壳种类) return;
        if (!游戏世界.可用弹壳池) this.初始化弹壳池();
        var 弹壳池 = 游戏世界.可用弹壳池[弹壳种类];
        var scale = xscale / 100;
        var ascale = Math.abs(scale);
        myX -= scale * 弹壳信息.myX;
        myY += ascale * 弹壳信息.myY;
        if (弹壳池.length > 0) {
            var 弹壳 = 弹壳池.pop();
            弹壳._x = myX;
            弹壳._y = myY;
            弹壳._visible = true;
            this.弹壳物理模拟(弹壳);
        } else {
            var 弹壳 = this.创建弹壳(弹壳种类, myX, myY);
        }
        弹壳._xscale = xscale;
        弹壳._yscale = ascale * 100;
        ++this.当前弹壳总数;
    }
};

// 初始化弹壳池
_root.弹壳系统.初始化弹壳池 = function() {
    var 游戏世界 = _root.gameworld;
    游戏世界.可用弹壳池 = {};
    this.当前弹壳总数 = 0;
    for (var 类型 in this.弹壳映射表) {
        游戏世界.可用弹壳池[this.弹壳映射表[类型].弹壳] = [];
    }
};
