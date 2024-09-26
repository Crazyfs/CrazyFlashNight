﻿//加载人物相关

_root.转场景记录数据 = function()
{
	转场景记录数据第一次记录 = true;
	var i = 0;
	while (i < 4)
	{
		if (_root.操控目标表[i] != "")
		{
			var 操控对象 = _root.gameworld[_root.操控目标表[i]];
			_root.转场景数据[i][0] = 操控对象.hp;
			_root.转场景数据[i][1] = 操控对象.mp;
			_root.转场景数据[i][2] = 操控对象.攻击模式;
			_root.转场景数据[i][3] = 操控对象.长枪射击次数;
			_root.转场景数据[i][4] = 操控对象.手枪射击次数;
			_root.转场景数据[i][5] = 操控对象.手枪2射击次数;
		}
		i += 1;
	}
	佣兵同伴血量记录 = [-1, -1, -1];
	var _loc3_ = 0;
	while (_loc3_ < _root.同伴数)
	{
		if (_root.gameworld["同伴" + _loc3_].hp > 0)
		{
			佣兵同伴血量记录[_loc3_] = _root.gameworld["同伴" + _loc3_].hp;
		}
		_loc3_ += 1;
	}
	_root.写入装备缓存();
}

_root.转场景数据传递 = function()
{
	_root.加载我方人物(_root.场景进入横坐标,_root.场景进入纵坐标);
	if (_root.新出生)
	{
		_root.转场景数据 = [[0, 0, "空手", 0, 0, 0], [0, 0, "空手", 0, 0, 0], [0, 0, "空手", 0, 0, 0], [0, 0, "空手", 0, 0, 0]];
		佣兵同伴血量记录 = [-1, -1, -1];
		_root.场景转换_主角hp = _root.gameworld[_root.控制目标].hp满血值;
		_root.场景转换_主角mp = _root.gameworld[_root.控制目标].mp满血值;
		_root.场景转换_主角长枪射击次数 = 0;
		_root.场景转换_主角手枪射击次数 = 0;
		_root.场景转换_主角手枪2射击次数 = 0;
		i = 0;
		while (i < _root.同伴数)
		{
			if (_root.gameworld["同伴" + i].hp满血值 > 0)
			{
				_root.场景转换_同伴hp[i] = _root.gameworld["同伴" + i].hp满血值;
				_root.场景转换_同伴mp[i] = _root.gameworld["同伴" + i].mp满血值;
			}
			i++;
		}
		_root.新出生 = false;
		return undefined;
	}
	var i = 0;
	while (i < 4)
	{
		if (_root.操控目标表[i] != "")
		{
			var 操控对象 = _root.gameworld[_root.操控目标表[i]];
			if (_root.转场景数据[i][0] > 0)
			{
				操控对象.hp = _root.转场景数据[i][0];
			}
			if (_root.转场景数据[i][1] > 0)
			{
				操控对象.mp = _root.转场景数据[i][1];
			}
			if (转场景记录数据第一次记录)
			{
				操控对象.攻击模式切换(_root.转场景数据[i][2]);
				操控对象.攻击模式 = _root.转场景数据[i][2];
				操控对象.长枪射击次数 = _root.转场景数据[i][3];
				操控对象.手枪射击次数 = _root.转场景数据[i][4];
				操控对象.手枪2射击次数 = _root.转场景数据[i][5];
			}
		}
		i += 1;
	}
	i = 0;
	while (i < _root.同伴数)
	{
		if (_root.佣兵同伴血量记录[i] > 0)
		{
			_root.gameworld["同伴" + i].hp = _root.佣兵同伴血量记录[i];
		}
		i += 1;
	}
}

_root.转场景数据 = [[0, 0, "空手", 0, 0, 0], [0, 0, "空手", 0, 0, 0], [0, 0, "空手", 0, 0, 0], [0, 0, "空手", 0, 0, 0]];
_root.新出生 = true;
_root.转场景记录数据第一次记录 = false;

// _root.联机2015加载主角 = function(地点X, 地点Y)
// {
// 	_root.gameworld.attachMovie("主角-男",_root.控制目标,_root.gameworld.getNextHighestDepth(),{_x:地点X, _y:地点Y, 是否为敌人:false, 身高:_root.身高, 名字:_root.角色名, 等级:_root.等级, 性别:_root.性别, 用户ID:_root.accId, 是否允许掉装备:false, 是否允许发送联机数据:true});
	// _root.玩家信息界面.刷新hp显示();
	// _root.玩家信息界面.刷新mp显示();
// }

_root.加载我方人物 = function(地点X, 地点Y)
{
	if (_root.特殊操作单位)
	{
		var 当前操作单位 = _root.特殊操作单位;
	}
	else
	{
		//当前操作单位 = "主角-" + _root.性别;
		var 当前操作单位 = "主角-男";//主角模型已经统一
	}
	_root.gameworld.attachMovie(当前操作单位,_root.控制目标,_root.gameworld.getNextHighestDepth(),{_x:地点X, _y:地点Y, 是否为敌人:false, 身高:_root.身高, 名字:_root.角色名, 等级:_root.等级, 性别:_root.性别, 用户ID:_root.accId, 是否允许掉装备:false});
	_root.玩家信息界面.刷新hp显示();
	_root.玩家信息界面.刷新mp显示();
	_root.添加其他玩家();
	_root.加载佣兵(地点X,地点Y);
	_root.加载宠物(地点X,地点Y);
}

_root.加载佣兵 = function(地点X, 地点Y)
{
	_root.帧计时器.添加单次任务(function() {
		
		for(var i = 0; i < _root.佣兵个数限制; i++)
		{
			var 同伴信息 = _root.同伴数据[i];
			if (_root.佣兵是否出战信息[i] == 1 && 同伴信息[1] != undefined && 同伴信息[1] != "undefined")
			{
				/*if (同伴信息[17] == "男") 同伴信息[17] = "主角-男";
				if (同伴信息[17] == "女") 同伴信息[17] = "主角-女";
				*/
				//主角模型已经统一
				_root.gameworld.attachMovie("主角-男","同伴" + i,_root.gameworld.getNextHighestDepth(),{_x:地点X + random(10), _y:地点Y + random(10), 用户ID:同伴信息[2], 是否为敌人:false, 身高:同伴信息[3], 名字:同伴信息[1], 等级:同伴信息[0], 脸型:同伴信息[4], 发型:同伴信息[5], 头部装备:同伴信息[6], 上装装备:同伴信息[7], 手部装备:同伴信息[8], 下装装备:同伴信息[9], 脚部装备:同伴信息[10], 颈部装备:同伴信息[11], 长枪:同伴信息[12], 手枪:同伴信息[13], 手枪2:同伴信息[14], 刀:同伴信息[15], 手雷:同伴信息[16], 性别:同伴信息[17], 是否允许掉装备:false, 是否为佣兵:true, 佣兵是否出战信息id:i});
			}
		}
	}, 0);
}

_root.删除场景上佣兵 = function()
{
/*	for (var i in _root.gameworld)
	{
		if (_root.gameworld[i].是否为佣兵 === true)
		{
			_root.gameworld[i].removeMovieClip();
		}
	}*/
	var i = 0;
	while (i < _root.佣兵个数限制)
	{
		_root.gameworld["同伴" + i].removeMovieClip();
		i++;
	}
}

_root.加载敌方人物 = function(地点X, 地点Y)
{
	for(var i = 0; i < _root.敌人同伴数; i++)
	{
		var 敌人信息 = _root.敌人同伴数据[i];
		_root.gameworld.attachMovie("主角-男","敌人同伴" + i,_root.gameworld.getNextHighestDepth(),{_x:地点X + random(10), _y:地点Y + random(10), 是否为敌人:true, 身高:敌人信息[3], 名字:敌人信息[1], 等级:敌人信息[0], 脸型:敌人信息[4], 发型:敌人信息[5], 头部装备:敌人信息[6], 上装装备:敌人信息[7], 手部装备:敌人信息[8], 下装装备:敌人信息[9], 脚部装备:敌人信息[10], 颈部装备:敌人信息[11], 长枪:敌人信息[12], 手枪:敌人信息[13], 手枪2:敌人信息[14], 刀:敌人信息[15], 手雷:敌人信息[16], 性别:敌人信息[17], 是否允许掉装备:false});
	}
}


//场景转换相关

_root.返回基地 = function(){
	// if (_root.当前关卡名 == "突围")
	// {
	// 	_root.宠物信息 = _root.真实宠物信息;
	// }
	_root.新出生 = true;
	_root.玩家信息界面.刷新hp显示();
	_root.玩家信息界面.刷新mp显示();
	if (_root.关卡结束界面._visible && _root.关卡结束界面.mytext == _root.获得翻译("关卡结束！"))
	{
		_root.关卡结束界面._visible = false;
		_root.奖励物品界面.标题 = _root.获得翻译("通关奖励");
		_root.奖励物品界面.生成关卡随机奖励品();
		_root.奖励物品界面.刷新();
	}
	_root.场景进入位置名 = "出生地";
	_root.关卡类型 = "";
	if (_root.gameworld[_root.控制目标].hp > 0)
	{
		_root.淡出动画.淡出跳转帧(_root.关卡地图帧值);
		// _root.联机2015发送传言("通关");
	}
	else
	{
		_root.淡出动画.淡出跳转帧("医务室");
	}
}


//门函数

_root.场景转换函数 = new Object();

_root.场景转换函数.切换场景 = function(对应门名, 目标场景帧, 开门效果, 同时按键值){
	var 游戏世界 = _root.gameworld;
	if (!游戏世界.允许通行) return;

	var 控制对象 = 游戏世界[_root.控制目标];
	var 对应方向 = false;
	switch(同时按键值){
		case _root.上键:
			对应方向 = 控制对象.上行;
			break;
		case _root.下键:
			对应方向 = 控制对象.下行;
			break;
		case _root.左键:
			对应方向 = 控制对象.左行;
			break;
		case _root.右键:
			对应方向 = 控制对象.右行;
			break;
	}
	
	var 条件满足 = false;
	if (对应方向 && this.hitTest(控制对象.area) && 控制对象.hp > 0)
	{
		条件满足 = true;
	}
	// if (this.hitTest(控制对象.area) and _root.全鼠标控制 == true and this.hitTest(_root.鼠标) == true and 被点击 == true and 控制对象.hp > 0){
	// 	条件满足 = true;
	// }
	if (条件满足 === true)
	{
		var pt = {x:控制对象._x, y:控制对象.Z轴坐标};
		游戏世界.localToGlobal(pt);
		if (this.hitTest(pt.x, pt.y, true))
		{
			_root.场景进入位置名 = 对应门名;
			_root.转场景记录数据();
			if (开门效果 == "")
			{
				_root.淡出动画.淡出跳转帧(目标场景帧);
				this.gotoAndStop(3);
			}
			else
			{
				_root.淡出动画.跳转帧 = 目标场景帧;
				游戏世界[开门效果].play();
				this.gotoAndStop(3);
			}
		}
	}
}

_root.场景转换函数.是否从门加载角色 = function()
{
	if (this.是否从门加载主角 && _root.场景进入位置名 == this._name)
	{
		_root.gameworld鼠标横向位置 = this._x;
		_root.gameworld鼠标纵向位置 = this._y;
		_root.场景进入横坐标 = this._x;
		_root.场景进入纵坐标 = this._y;
		_root.转场景数据传递();
		_root.横版卷屏(_root.控制目标,_root.gameworld.背景长,_root.gameworld.背景高,1);
	}
}


//地图帧跳转相关
_root.防止播放跳关 = function()
{
	if (_root.关卡标志 != undefined)
	{
		_root.跳转地图(_root.关卡标志);
	}
}

_root.跳转地图 = function(跳转帧)
{
	var 游戏世界 = _root.gameworld;
	_root.常用工具函数.释放对象绘图内存(游戏世界);
	for (var i = 0; i < _root.初期关卡列表.length; i++)
	{
		if (_root.关卡标志 == _root.初期关卡列表[i])
		{
			_root.gotoAndPlay("初期关卡");
			return;
		}
	}
	for (var i = 0; i < _root.外部地图列表.length; i++)
	{
		if (_root.关卡标志 == _root.外部地图列表[i])
		{
			_root.gotoAndPlay("外部地图");
			return;
		}
	}
	_root.gotoAndPlay(跳转帧);
}

_root.加载共享场景 = function(加载场景名)
{
	var 游戏世界 = _root.attachMovie(加载场景名,"gameworld",_root.getNextHighestDepth());
	游戏世界.swapDepths(_root.gameworld层级定位器);
	// _root.淡出动画.gotoAndPlay("加载完毕");
	// _root.贴背景图();
}

