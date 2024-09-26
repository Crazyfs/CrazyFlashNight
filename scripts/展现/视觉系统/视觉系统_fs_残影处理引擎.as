import flash.display.BitmapData;
_root.残影系统 = {};
_root.残影系统.初始化 = function() {
    this.残影数量 = 5;
    this.残影变动间隔帧数 = 1;
    this.残影存在时间 = _root.帧计时器.每帧毫秒 * this.残影数量 * this.残影变动间隔帧数;
    this.残影变动时间 = this.残影存在时间 / this.残影数量;
    this.残影刷新时间 = this.残影变动时间 / this.残影数量;
    this.残影透明度衰减 = 100 / this.残影数量;
};

_root.残影系统.初始化();

_root.残影系统.绘制元件 = function(影片剪辑, 参数) {
    this.绘制到画布(影片剪辑, _root.色彩引擎.初级调整颜色(影片剪辑, 参数));
};

_root.残影系统.绘制线条 = function(点集, 颜色, 线条宽度) {
    var 画布 = this.获得当前画布(); // 自动获取画布
    if (点集 == undefined || 点集.length < 2) return; // 校验点集

    颜色 = 颜色 == undefined ? 0xFF0000 : 颜色; // 默认红色
    线条宽度 = 线条宽度 == undefined ? 1 : 线条宽度; // 默认宽度为1

    画布.lineStyle(线条宽度, 颜色, 100); // 设置线条样式
    画布.moveTo(点集[0].x, 点集[0].y);
    for (var i = 1; i < 点集.length; i++) {
        画布.lineTo(点集[i].x, 点集[i].y);
    }
};

_root.残影系统.绘制闭合线条 = function(点集, 颜色, 线条宽度) {
    var 画布 = this.获得当前画布(); // 自动获取画布
    if (点集 == undefined || 点集.length < 3) return; // 校验点集，闭合线条至少需要3个点

    颜色 = 颜色 == undefined ? 0xFF0000 : 颜色; // 默认红色
    线条宽度 = 线条宽度 == undefined ? 1 : 线条宽度; // 默认宽度为1

    画布.lineStyle(线条宽度, 颜色, 100); // 设置线条样式
    画布.moveTo(点集[0].x, 点集[0].y);
    for (var i = 1; i < 点集.length; i++) {
        画布.lineTo(点集[i].x, 点集[i].y);
    }
    画布.lineTo(点集[0].x, 点集[0].y); // 回到起点闭合形状
};


_root.残影系统.绘制形状 = function(点集, 填充颜色, 线条颜色, 线条宽度, 填充透明度, 线条透明度) {
    var 画布 = this.获得当前画布(); // 自动获取画布
    if (点集 == undefined || 点集.length < 3) return; // 校验点集，至少需要3个点来形成一个闭合形状
    
    填充透明度 = 填充透明度 == undefined ? 100 : 填充透明度;// 处理默认透明度

    // 设置线条样式，包括颜色、透明度和宽度
    if (线条颜色 != undefined) {
        线条宽度 = 线条宽度 == undefined ? 1 : 线条宽度;
        线条透明度 = 线条透明度 == undefined ? 100 : 线条透明度;
        画布.lineStyle(线条宽度, 线条颜色, 线条透明度);
    } else {
        画布.lineStyle(); // 不绘制线条
    }

    // 设置填充颜色和透明度
    if (填充颜色 != undefined) {
        画布.beginFill(填充颜色, 填充透明度);
    } else {
        画布.beginFill(填充颜色, 100); // 默认不透明
    }

    // 绘制形状
    画布.moveTo(点集[0].x, 点集[0].y);
    for (var i = 1; i < 点集.length; i++) {
        画布.lineTo(点集[i].x, 点集[i].y);
    }
    画布.lineTo(点集[0].x, 点集[0].y); // 闭合形状
    画布.endFill(); // 结束填充
};



_root.残影系统.绘制到画布 = function(影片剪辑, 调整颜色) {
    if (!影片剪辑)
        return;
    var 画布 = this.获得当前画布();
    if (!调整颜色)
        调整颜色 = _root.色彩引擎.空调整颜色; // 如果未提供颜色调整，则使用默认的

    /*
    var pos = {x: 0, y: 0};
    var ascale = Math.abs(影片剪辑._xscale) / 100;
    var matrix;
    影片剪辑.localToGlobal(pos);
    画布.globalToLocal(pos);

    if (影片剪辑._xscale < 0) {
        matrix = new flash.geom.Matrix(-ascale, 0, 0, ascale, pos.x, pos.y);
    } else {
        matrix = new flash.geom.Matrix(ascale, 0, 0, ascale, pos.x, pos.y);
    }

    画布.bitmapData.draw(影片剪辑, matrix, 调整颜色, "normal", undefined, true); // 在当前画布上绘制影片剪辑
    */
    var mc = 影片剪辑;
    var totalMatrix = new flash.geom.Matrix();
    var 游戏世界 = _root.gameworld;
    // 遍历从影片剪辑到根的所有父级元件，累积变换
    while (mc != undefined && mc != 游戏世界) {
        var mtx = mc.transform.matrix;
        totalMatrix.concat(mtx);
        mc = mc._parent;
    }

    // 应用画布的逆变换，将全局坐标转换回画布的局部坐标
    var canvasInvertedMatrix = 画布.transform.matrix.clone();
    canvasInvertedMatrix.invert();
    totalMatrix.concat(canvasInvertedMatrix);
    画布.bitmapData.draw(影片剪辑, totalMatrix, 调整颜色, "normal", undefined, true);
};


_root.残影系统.获得当前画布 = function() {
    if (!this.当前画布) {
        var 残影系统挂载层 = _root.gameworld.deadbody;

        if (残影系统挂载层.残影画布池.length > 0) {
            this.当前画布 = 残影系统挂载层.残影画布池.pop();
        } else {
            this.当前画布 = this.创建画布(残影系统挂载层);
        }
        var 画布 = this.当前画布;
        画布._visible = true;
        画布._alpha = 100;
        画布.循环任务ID = _root.帧计时器.添加任务(this.画布循环任务, this.残影刷新时间, this.残影数量, 画布, 残影系统挂载层);
        画布.循环次数 = this.残影数量;
        画布.当前循环次数 = 1;
        画布.onUnload = function() {
            _root.帧计时器.移除任务(画布.循环任务ID);
            _root.残影系统.当前画布 = null; //防止过图后残影系统无法正常工作
            //_root.服务器.发布服务器消息("画布卸载" + 画布.循环任务ID);
        };
    }

    return this.当前画布;
};

_root.残影系统.画布循环任务 = function(画布, 残影系统挂载层) {
    if (画布.当前循环次数 >= 画布.循环次数) {
        画布._visible = false;
        画布.bitmapData.fillRect(画布.bitmapData.rectangle, 0x00000000);
        画布.clear();
        残影系统挂载层.残影画布池.push(画布);
        //_root.服务器.发布服务器消息("画布回收" + 画布.循环任务ID);
    } else {
        画布._alpha -= _root.残影系统.残影透明度衰减;
        if (画布.当前循环次数 === 1 && _root.残影系统.当前画布 === 画布) {
            _root.残影系统.当前画布 = null;
        }
        画布.当前循环次数++;
        //_root.服务器.发布服务器消息(_root.帧计时器.当前帧数 + "画布透明度" + 画布._alpha);
    }
};

_root.残影系统.创建画布 = function(残影系统挂载层) {
    if (!残影系统挂载层.残影系统存在) {
        残影系统挂载层.残影系统存在 = true;
        残影系统挂载层.残影画布数量 = 0;
        残影系统挂载层.残影画布池 = [];
    }
    var 画布 = 残影系统挂载层.createEmptyMovieClip("画布" + ++残影系统挂载层.残影画布数量, 残影系统挂载层.getNextHighestDepth());
    var bitmapData:BitmapData = new BitmapData(残影系统挂载层._width, 残影系统挂载层._height, true, 0x00000000); // 设置为透明背景
    画布.attachBitmap(bitmapData, 0, "auto", true);
    画布.bitmapData = bitmapData;
    return 画布;
};
