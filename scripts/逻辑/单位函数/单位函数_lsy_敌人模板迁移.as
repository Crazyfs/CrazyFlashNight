﻿//容纳敌人函数的对象
_root.敌人函数 = new Object();


//以下14个是原版敌人的必要函数

_root.敌人函数.根据等级初始数值 = function(等级值)
{
	hp满血值 = _root.根据等级计算值(hp_min, hp_max, 等级值) * _root.难度等级;
	空手攻击力 = _root.根据等级计算值(空手攻击力_min, 空手攻击力_max, 等级值) * _root.难度等级;
	行走X速度 = _root.根据等级计算值(速度_min, 速度_max, 等级值) / 10;
	行走Y速度 = 行走X速度 / 2;
	跑X速度 = 行走X速度 * 奔跑速度倍率;
	跑Y速度 = 行走Y速度 * 奔跑速度倍率;
	被击硬直度 = _root.根据等级计算值(被击硬直度_min, 被击硬直度_max, 等级值);
	起跳速度 = -10;
	基本防御力 = _root.根据等级计算值(基本防御力_min, 基本防御力_max, 等级值);
	防御力 = 基本防御力 + 装备防御力;
	躲闪率 = _root.根据等级计算值(躲闪率_min, 躲闪率_max, 等级值, true); //允许小数躲闪率
	hp = !isNaN(hp) ? hp : hp满血值;
};

_root.敌人函数.行走 = function()
{
	if (this.右行 == 1 || this.左行 == 1 || this.上行 == 1 || this.下行 == 1)
	{
		if (状态 != 攻击模式 + "跑")
		{
			if (this.右行 == 1)
			{
				方向改变("右");
				状态改变(攻击模式 + "行走");
				移动("右",行走X速度);
			}
			else if (this.左行 == 1)
			{
				方向改变("左");
				状态改变(攻击模式 + "行走");
				移动("左",行走X速度);
			}
			if (this.下行 == 1)
			{
				状态改变(攻击模式 + "行走");
				移动("下",行走Y速度);
			}
			else if (this.上行 == 1)
			{
				状态改变(攻击模式 + "行走");
				移动("上",行走Y速度);
			}
		}
		else
		{
			if (this.右行 == 1)
			{
				方向改变("右");
				状态改变(攻击模式 + "跑");
				移动("右",跑X速度);
			}
			else if (this.左行 == 1)
			{
				方向改变("左");
				状态改变(攻击模式 + "跑");
				移动("左",跑X速度);
			}
			if (this.下行 == 1)
			{
				状态改变(攻击模式 + "跑");
				移动("下",跑Y速度);
			}
			else if (this.上行 == 1)
			{
				状态改变(攻击模式 + "跑");
				移动("上",跑Y速度);
			}
		}
	}
	else
	{
		状态改变(攻击模式 + "站立");
	}
};

_root.敌人函数.移动 = function(移动方向, 速度)
{
	var point = {x:this._x, y:this.Z轴坐标};
	var 游戏世界 = _root.gameworld;
	var 游戏世界地图 = 游戏世界.地图;
	游戏世界.localToGlobal(point);
	var xx = point.x;
	var yy = point.y;
	if (移动方向 === "右" && this._x + 速度 < _root.Xmax && (this._x + 速度 > _root.Xmin || 速度 > 0) && !游戏世界地图.hitTest(xx + 速度, yy, true))
	{
		this._x += 速度;
	}
	else if (移动方向 === "左" && this._x - 速度 > _root.Xmin && (this._x - 速度 < _root.Xmax || 速度 > 0) && !游戏世界地图.hitTest(xx - 速度, yy, true))
	{
		this._x -= 速度;
	}
	if (移动方向 === "下" && this._y + 速度 < _root.Ymax && !游戏世界地图.hitTest(xx, yy + 速度, true))
	{
		Z轴坐标 += 速度;
		this._y = Z轴坐标;
		this.swapDepths(this._y);
	}
	else if (移动方向 === "上" && this._y - 速度 > _root.Ymin && !游戏世界地图.hitTest(xx, yy - 速度, true))
	{
		Z轴坐标 -= 速度;
		this._y = Z轴坐标;
		this.swapDepths(this._y);
	}
};

_root.敌人函数.被击移动 = function(移动方向, 速度, 摩擦力)
{
	if(免疫击退) return;
	移动钝感硬直(_root.钝感硬直时间);
	减速度 = 摩擦力;
	speed = 速度;
	this.onEnterFrame = function()
	{
		if (!硬直中)
		{
			speed -= 减速度;
			this.移动(移动方向,speed);
			if (speed <= 0)
			{
				delete this.onEnterFrame;
			}
		}
	};
};

_root.敌人函数.强制移动 = _root.主角函数.强制移动;


_root.敌人函数.方向改变 = function(新方向)
{
	if(锁定方向) return;
	if (新方向 === "右")
	{
		方向 = "右";
		this._xscale = myxscale;
		新版人物文字信息._xscale = 100;
	}
	else if (新方向 === "左")
	{
		方向 = "左";
		this._xscale = -myxscale;
		新版人物文字信息._xscale = -100;
	}
};

_root.敌人函数.状态改变 = function(新状态名)
{
	状态 = 新状态名;
	this.gotoAndStop(新状态名);
};

_root.敌人函数.动画完毕 = function()
{
	if(hp <= 0){
		//防止没有倒地动画的敌人在击倒动画被扣至0血导致不死
		状态改变("血腥死");
	}else{
		状态改变(攻击模式 + "站立");
	}
};

_root.敌人函数.硬直 = function(目标, 时间) 
{
    目标.stop();

    _root.帧计时器.添加或更新任务(目标, "硬直", function() {
        目标.play();
    }, 时间); 
};


_root.敌人函数.移动钝感硬直 = function(时间) 
{
    var 自机:Object = this;  // 在外部保存对当前对象的引用

    this.硬直中 = true;  
    _root.帧计时器.添加或更新任务(this, "移动钝感硬直", function() {
        自机.硬直中 = false;  
    }, 时间);
};

_root.敌人函数.随机掉钱 = function()
{
	if (!this.不掉钱 && random(_root.打怪掉钱机率) === 0)
	{
		var 金币时间倍率 = _root.天气系统.金币时间倍率;
		//_root.发布消息("金币时间倍率" + 金币时间倍率);
		var 昼夜爆金币 = this.hp满血值 * 金币时间倍率 / 5;
		
		_root.创建可拾取物("金钱",random(昼夜爆金币),this._x,this._y,true);
	}
};

_root.敌人函数.计算经验值 = function()
{
	this.随机掉钱();

	var 经验时间倍率 = _root.天气系统.经验时间倍率;
	
	//_root.发布消息("经验时间倍率" + 经验时间倍率);
	_root.经验值计算(最小经验值 * 经验时间倍率,最大经验值 * 经验时间倍率,等级,_root.最大等级);
	_root.主角是否升级(_root.等级,_root.经验值);
	this.已加经验值 = true;
};

_root.敌人函数.攻击呐喊 = function()
{
	if (性别 === "女"){
		_root.播放音效(女_攻击呐喊_库[random(女_攻击呐喊_库.length)]);
	}else{
		_root.播放音效(男_攻击呐喊_库[random(男_攻击呐喊_库.length)]);
	}
};

_root.敌人函数.中招呐喊 = function()
{
	if (性别 === "女"){
		_root.播放音效(女_中招呐喊_库[random(女_中招呐喊_库.length)]);
	}else{
		_root.播放音效(男_中招呐喊_库[random(男_中招呐喊_库.length)]);
	}
};

_root.敌人函数.击倒呐喊 = function()
{
	if (性别 === "女"){
		_root.播放音效(女_击倒呐喊_库[random(女_击倒呐喊_库.length)]);
	}else{
		_root.播放音效(男_击倒呐喊_库[random(男_击倒呐喊_库.length)]);
	}
};


//以下是新增或新整合的函数

_root.敌人函数.死亡检测 = function()
{
	if (hp <= 0 && !已加经验值)
	{
		this.man.stop();
		_root.帧计时器.注销目标缓存(this);
		if (是否为敌人)
		{
			_root.敌人死亡计数 += 1;
			_root.gameworld[产生源].僵尸型敌人场上实际人数--;
			_root.gameworld[产生源].僵尸型敌人总个数--;
			this.计算经验值();
		}
		this.人物文字信息._visible = false;
		this.新版人物文字信息._visible = false;
		_root.add2map(this,2);
		this.removeMovieClip();
	}
};


_root.初始化敌人模板 = function()
{
	//以下14个是原版敌人的必要函数
	this.根据等级初始数值 = this.根据等级初始数值 ? this.根据等级初始数值 : _root.敌人函数.根据等级初始数值;
	this.行走 = this.行走 ? this.行走 : _root.敌人函数.行走;
	this.移动 = this.移动 ? this.移动 : _root.敌人函数.移动;
	this.被击移动 = this.被击移动 ? this.被击移动 : _root.敌人函数.被击移动;
	this.方向改变 = this.方向改变 ? this.方向改变 : _root.敌人函数.方向改变;
	this.状态改变 = this.状态改变 ? this.状态改变 : _root.敌人函数.状态改变;
	this.动画完毕 = this.动画完毕 ? this.动画完毕 : _root.敌人函数.动画完毕;
	this.硬直 = this.硬直 ? this.硬直 : _root.敌人函数.硬直;
	this.移动钝感硬直 = this.移动钝感硬直 ? this.移动钝感硬直 : _root.敌人函数.移动钝感硬直;
	this.随机掉钱 = this.随机掉钱 ? this.随机掉钱 : _root.敌人函数.随机掉钱;
	this.计算经验值 = this.计算经验值 ? this.计算经验值 : _root.敌人函数.计算经验值;
	this.攻击呐喊 = this.攻击呐喊 ? this.攻击呐喊 : _root.敌人函数.攻击呐喊;
	this.中招呐喊 = this.中招呐喊 ? this.中招呐喊 : _root.敌人函数.中招呐喊;
	this.击倒呐喊 = this.击倒呐喊 ? this.击倒呐喊 : _root.敌人函数.击倒呐喊;
	
	//以下是新增或新整合的函数
	this.死亡检测 = _root.敌人函数.死亡检测;
	this.强制移动 = _root.敌人函数.强制移动;

	
	//以下15个是必须外部定义的参数，为了保险在这里检测一遍
	最小经验值 = !isNaN(最小经验值) ? 最小经验值 : 100;
	最大经验值 = !isNaN(最大经验值) ? 最大经验值 : 100;
	hp_min = !isNaN(hp_min) ? hp_min : 100;
	hp_max = !isNaN(hp_max) ? hp_max : 100;
	速度_min = !isNaN(速度_min) ? 速度_min : 30;
	速度_max = !isNaN(速度_max) ? 速度_max : 30;
	空手攻击力_min = !isNaN(空手攻击力_min) ? 空手攻击力_min : 10;
	空手攻击力_max = !isNaN(空手攻击力_max) ? 空手攻击力_max : 10;
	被击硬直度_min = !isNaN(被击硬直度_min) ? 被击硬直度_min : 1000;
	被击硬直度_max = !isNaN(被击硬直度_max) ? 被击硬直度_max : 1000;
	躲闪率_min = !isNaN(躲闪率_min) ? 躲闪率_min : 10;
	躲闪率_max = !isNaN(躲闪率_max) ? 躲闪率_max : 2;
	基本防御力_min = !isNaN(基本防御力_min) ? 基本防御力_min : 1;
	基本防御力_max = !isNaN(基本防御力_max) ? 基本防御力_max : 1;
	装备防御力 = !isNaN(装备防御力) ? 装备防御力 : 0;
	
	//以下是可以自定义的原版参数
	性别 = 性别 ? 性别 : "男";
	称号 = 称号 ? 称号 : "";
	身高 = !isNaN(身高) ? 身高 : 175;
	方向 = 方向 ? 方向 : "右";
	攻击模式 = 攻击模式 ? 攻击模式 : "空手";
	状态 = 登场动画 ? "登场" : 攻击模式 + "站立";
	击中效果 = 击中效果 ? 击中效果 : "飙血";
	刚体 = 刚体 ? true : false;
	无敌 = 无敌 === true ? true : false;
	
	//以下是可自定义的原版ai相关参数，在ai改革后可能被废弃
	x轴攻击范围 = x轴攻击范围 ? x轴攻击范围 : 100;
	y轴攻击范围 = y轴攻击范围 ? y轴攻击范围 : 10;
	x轴保持距离 = !isNaN(x轴保持距离) ? x轴保持距离 : 50;
	停止机率 = !isNaN(停止机率) ? 停止机率 : 50;
	随机移动机率 = !isNaN(随机移动机率) ? 随机移动机率 : 50;
	攻击欲望 = !isNaN(攻击欲望) ? 攻击欲望 : 5;
	
	//以下是可以自定义的新增参数
	重量 = !isNaN(重量) ? 重量 : 60;
	韧性系数 = !isNaN(韧性系数) ? 韧性系数 : 1;
	命中率 = !isNaN(命中率) ? 命中率 : 10;
	免疫击退 = 免疫击退 ? true : false;
	锁定方向 = 锁定方向 ? true : false;
	奔跑速度倍率 = !isNaN(奔跑速度倍率) ? 奔跑速度倍率 : 2;
	
	//以下是自动初始化的必要参数
	攻击目标 = "无";
	攻击模式 = "空手";
	格斗架势 = false;
	浮空 = false;
	倒地 = false;
	硬直中 = false;
	已加经验值 = false;
	
	//转换身高，调整层级
	身高转换值 = _root.身高百分比转换(this.身高);
	this._xscale = 身高转换值;
	this._yscale = 身高转换值;
	myxscale = this._xscale;
	Z轴坐标 = this._y;
	this.swapDepths(this._y + random(10));
	
	//应用新版人物文字信息
	if(this.人物文字信息){
		this.人物文字信息.unloadMovie();
		this.attachMovie("新版人物文字信息","新版人物文字信息",this.getNextHighestDepth());
		this.新版人物文字信息._x = 人物文字信息._x;
		this.新版人物文字信息._y = 人物文字信息._y;
	}
	
	//初始化完毕
	_root.帧计时器.注册目标缓存(this);
	根据等级初始数值(等级);
	方向改变(方向);
	gotoAndStop(状态);
}


_root.初始化可操控敌人模板 = function()
{
	this.循环切换攻击模式 = _root.主角函数.循环切换攻击模式;
	this.随机切换攻击模式 = _root.主角函数.随机切换攻击模式;
	this.单发枪计时 = _root.主角函数.单发枪计时;
	//this.单发枪可以射击 = _root.主角函数.单发枪可以射击;
	this.单发枪计时_2 = _root.主角函数.单发枪计时_2;
	//this.单发枪可以射击_2 = _root.主角函数.单发枪可以射击_2;
	this.攻击呐喊 = _root.主角函数.攻击呐喊;
	this.中招呐喊 = _root.主角函数.中招呐喊;
	this.击倒呐喊 = _root.主角函数.击倒呐喊;

	//

	this.计算经验值 = _root.主角函数.计算经验值;
	this.播放二级动画 = _root.主角函数.播放二级动画;

	//

	this.动画完毕 = _root.主角函数.动画完毕;

	//

	this.硬直 = _root.主角函数.硬直;

	this.移动钝感硬直 = _root.主角函数.移动钝感硬直;


	//
	this.攻击模式切换 = this.攻击模式切换 ? this.攻击模式切换 : _root.主角函数.攻击模式切换;
	this.按键控制攻击模式 = _root.主角函数.按键控制攻击模式;
	this.根据模式重新读取武器加成 = _root.主角函数.根据模式重新读取武器加成;
	// this.跳 = _root.主角函数.跳;


	//
	this.冲击 = _root.主角函数.冲击;
	this.攻击 = this.攻击 ? this.攻击 : _root.主角函数.攻击;
	this.方向改变 = _root.主角函数.方向改变;
	this.移动 = _root.主角函数.移动;
	// this.跳跃上下移动 = _root.主角函数.跳跃上下移动;
	this.被击移动 = _root.主角函数.被击移动;
	this.拾取 = _root.主角函数.拾取;
	this.非主角外观刷新 = _root.主角函数.非主角外观刷新;
	this.状态改变 = this.状态改变 ? this.状态改变 : _root.主角函数.状态改变;
	// this.UpdateBigState = _root.主角函数.UpdateBigState;
	// this.UpdateState = _root.主角函数.UpdateState;
	// this.UpdateSmallState = _root.主角函数.UpdateSmallState;
	// this.UpdateBigSmallState = _root.主角函数.UpdateBigSmallState;
	// this.getBigState = _root.主角函数.getBigState;
	// this.getState = _root.主角函数.getState;
	// this.getSmallState = _root.主角函数.getSmallState;
	// this.getAllState = _root.主角函数.getAllState;
	// this.getPastBigStates = _root.主角函数.getPastBigStates;
	// this.getPastStates = _root.主角函数.getPastStates;
	// this.getPastSmallStates = _root.主角函数.getPastSmallStates;
	this.人物暂停 = _root.主角函数.人物暂停;
	this.获取键值 = _root.主角函数.获取键值;
	this.根据等级初始数值 = _root.主角函数.根据等级初始数值;
	this.行走 = this.行走 ? this.行走 : _root.主角函数.行走;
	this.初始化可用技能 = _root.主角函数.初始化可用技能;
	// this.存储当前飞行状态 = _root.主角函数.存储当前飞行状态;
	// this.读取当前飞行状态 = _root.主角函数.读取当前飞行状态;
	this.按键检测 = _root.主角函数.按键检测;

	this.死亡检测 = _root.主角函数.死亡检测;

	// this.刀口位置生成子弹 = _root.主角函数.刀口位置生成子弹;
	this.长枪射击 = _root.主角函数.长枪射击;
	this.手枪射击 = _root.主角函数.手枪射击;
	this.手枪2射击 = _root.主角函数.手枪2射击;
	this.刷新枪口位置 = _root.主角函数.刷新枪口位置;
	
	最小经验值 = !isNaN(最小经验值) ? 最小经验值 : 16;
	最大经验值 = !isNaN(最大经验值) ? 最大经验值 : 134;
	hp_min = !isNaN(hp_min) ? hp_min : 200;
	hp_max = !isNaN(hp_max) ? hp_max : 1000;
	mp_min = !isNaN(mp_min) ? mp_min : 100;
	mp_max = !isNaN(mp_max) ? mp_max : 600;
	速度_min = !isNaN(速度_min) ? 速度_min : 40;
	速度_max = !isNaN(速度_max) ? 速度_max : 60;
	空手攻击力_min = !isNaN(空手攻击力_min) ? 空手攻击力_min : 10;
	空手攻击力_max = !isNaN(空手攻击力_max) ? 空手攻击力_max : 150;
	被击硬直度_min = !isNaN(被击硬直度_min) ? 被击硬直度_min : 1000;
	被击硬直度_max = !isNaN(被击硬直度_max) ? 被击硬直度_max : 200;
	躲闪率_min = !isNaN(躲闪率_min) ? 躲闪率_min : 10;
	躲闪率_max = !isNaN(躲闪率_max) ? 躲闪率_max : 2;
	基本防御力_min = !isNaN(基本防御力_min) ? 基本防御力_min : 10;
	基本防御力_max = !isNaN(基本防御力_max) ? 基本防御力_max : 400;

	//新加属性
	重量 = !isNaN(重量) ? 重量 : 60;
	韧性系数 = !isNaN(韧性系数) ? 韧性系数 : 1;
	命中率 = !isNaN(命中率) ? 命中率 : 10;
	// 血包数量 = 3;
	// 血包使用间隔 = 8 * _root.帧计时器.帧率;
	// 血包恢复比例 = 33;
	// 上次使用血包时间 = _root.帧计时器.当前帧数;

	不掉钱 = 不掉钱 ? true : false;
	// 不掉装备 = 不掉装备 ? true : false;


	操控编号 = _root.获取操控编号(this._name);
	if (操控编号 != -1) 获取键值();
	
	if (!this.装备防御力) this.装备防御力 = 0;
	if (this.hp满血值装备加层 == undefined)
	{
		this.hp满血值装备加层 = 0;
	}
	if (mp满血值装备加层 == undefined)
	{
		mp满血值装备加层 = 0;
	}
	
	攻击目标 = "无";
	x轴攻击范围 = 100;
	y轴攻击范围 = 20;
	x轴保持距离 = 50;
	
	攻击模式 = 攻击模式 ? 攻击模式 : "空手";
	状态 = 登场动画 ? "登场" : 攻击模式 + "站立";
	方向 = 方向 ? 方向 : "右";
	击中效果 = 击中效果 ? 击中效果 : "飙血";
	格斗架势 = false;
	Z轴坐标 = this._y;
	浮空 = false;
	倒地 = false;
	硬直中 = false;
	强制换弹夹 = false;
	if (!长枪射击次数) 长枪射击次数 = new Object();
	if (!手枪射击次数) 手枪射击次数 = new Object();
	if (!手枪2射击次数) 手枪2射击次数 = new Object();
	手雷射击次数 = 0;
	循环切换攻击模式计数 = 1;
	// 单发枪射击速度 = 1000;
	// 单发枪射击速度_2 = 1000;
	// 单发枪计时_时间结束 = true;
	// 单发枪计时_时间结束_2 = true;
	射击许可 = true;
	射击许可2 = true;
	// bigState = [];
	// state = [];
	// smallState = [];
	// allStage = [bigState, state, smallState];//暂时取消
	// useBigState = ["技能中", "技能结束", "普攻中", "普攻结束"];
	// useSmallStateSkill = ["闪现中", "闪现结束", "六连中", "六连结束", "踩人中", "踩人结束", "技能结束"];
	// useSmallStateWeapon = ["兵器一段前", "兵器一段中", "兵器二段中", "兵器三段中", "兵器四段中", "兵器五段中", "兵器五段结束", "兵器普攻结束", "长枪攻击前", "长枪攻击中", "长枪攻击结束"];
	// useStateWeapon = ["空手", "兵器", "手枪", "手枪2", "双枪", "长枪", "手雷"];
	// useStateWeaponAction = ["站立", "行走", "攻击", "跑", "冲击", "跳", "拾取", "躲闪"];
	// useStateOtherType = ["技能", "挂机", "被击", "击倒", "被投", "血腥死"];


	_root.刷新人物装扮(this._name);

	身高转换值 = _root.身高百分比转换(this.身高);
	this._xscale = 身高转换值;
	this._yscale = 身高转换值;
	myxscale = this._xscale;
	this.swapDepths(this._y + random(10) - 5);

	if (_root.控制目标 != this._name)
	{
		初始化可用技能();
	}else{
		被动技能 = _root.主角被动技能;
	}
	buff = new 主角模板数值buff(this);
	
	//应用新版人物文字信息
	this.attachMovie("新版人物文字信息","新版人物文字信息",this.getNextHighestDepth());
	this.新版人物文字信息._x = 人物文字信息._x;
	this.新版人物文字信息._y = 人物文字信息._y;
	this.人物文字信息.unloadMovie();
	
	//初始化完毕
	根据等级初始数值(等级);
	方向改变(方向);
	gotoAndStop(状态);
};

//#change:主角-牛仔



//容纳敌人二级函数的对象，包括了原版的二级函数，以及新写或基于原版修改的二级函数
_root.敌人二级函数 = new Object();

//最广泛的二级函数
_root.敌人二级函数.攻击时移动 = function(速度)
{
	var 移动方向 = _parent.方向;
	if (速度 < 0)
	{
		速度 = -速度;
		移动方向 = 移动方向 === "右" ? "左" : "右";
	}
	_parent.移动(移动方向,速度);
};

//首次实装于武装JK
_root.敌人二级函数.攻击时四向移动 = function(上, 下, 左, 右)
{
	if (上 != 0)
	{
		_parent.移动("上",上);
	}
	else if (下 != 0)
	{
		_parent.移动("下",下);
	}
	if (左 != 0)
	{
		_parent.方向改变("左");
		_parent.移动("左",左);
	}
	else if (右 != 0)
	{
		_parent.方向改变("右");
		_parent.移动("右",右);
	}
}

//由李小龙的瞬移改写，增加了最小与最大移动距离参数
_root.敌人二级函数.X轴追踪移动 = function(保持距离, 最小移动距离, 最大移动距离)
{
	if (!_parent.攻击目标 || _parent.攻击目标 === "无"){
		return;
	}
	var 方向 = _parent.方向;
	var distance = _root.gameworld[_parent.攻击目标]._x - _parent._x;
	if (方向 === "左"){
		distance = -distance;
	}
	distance -= 保持距离;
	if (!isNaN(最小移动距离) && distance < 最小移动距离){
		distance = 最小移动距离;
	}
	if (最大移动距离 > 0 && distance > 最大移动距离){
		distance = 最大移动距离;
	}
	_parent.移动(_parent.方向, distance);
};

//首次实装于独狼
_root.敌人二级函数.Z轴追踪移动 = function(最大移动距离){
	if (!_parent.攻击目标 || _parent.攻击目标 === "无"){
		return;
	}
	var distance = _root.gameworld[_parent.攻击目标].Z轴坐标 - _parent.Z轴坐标;
	var 方向 = "下";
	if (distance < 0){
		distance = -distance;
		方向 = "上";
	}
	if (最大移动距离 > 0 && distance > 最大移动距离){
		distance = 最大移动距离;
	}
	_parent.移动(方向,distance);
};

//根据攻击目标的位置计算移动角度，可限制角度的最大值。首次实装于方舟爪豪
//大于最大角度则返回最大角度，攻击目标在身后则返回角度限制下的随机值
_root.敌人二级函数.计算攻击角度 = function(最大角度)
{
	if (!最大角度 || 最大角度 <= 0)
	{
		return 0;
	}
	var 水平距离 = _root.gameworld[_parent.攻击目标]._x - _parent._x;
	水平距离 = _parent.方向 === "左" ? -水平距离 : 水平距离;
	if (水平距离 <= 0)
	{
		return 2 * Math.random() * 最大角度 - 最大角度;
	}
	var 垂直距离 = _root.gameworld[_parent.攻击目标].Z轴坐标 - _parent.Z轴坐标;
	var 角度 = Math.atan(垂直距离 / 水平距离) / Math.PI * 180;
	角度 = Math.min(角度, 最大角度);
	角度 = Math.max(角度, -最大角度);
	return 角度;
}

//以固定角度移动，可能需要同时限制转向。首次实装于方舟爪豪
_root.敌人二级函数.固定角度移动 = function(速度, 角度)
{
	if (!攻击时移动) 攻击时移动 = _root.敌人二级函数.攻击时移动;
	攻击时移动(速度 * Math.cos(角度 * Math.PI / 180));
	var 垂直速度 = 速度 * Math.sin(角度 * Math.PI / 180);
	var 垂直方向 = "上";
	if (垂直速度 < 0)
	{
		垂直速度 = -垂直速度;
		垂直方向 = "下";
	}
	_parent.移动(垂直方向,垂直速度);
}

