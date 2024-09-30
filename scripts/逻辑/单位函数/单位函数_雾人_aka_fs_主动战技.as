﻿_root.主动战技函数 = {空手:{},兵器:{},长枪:{}};



//空手
_root.主动战技函数.空手.旋风腿 = {
    初始化:null,
    释放许可判定:function(自机){
        return 自机.攻击模式 === "空手" && !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "旋风腿";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("旋风腿");
    }
}

//空手
_root.主动战技函数.空手.飞身踢 = {
    初始化:null,
    释放许可判定:function(自机){
        return 自机.攻击模式 === "空手" && !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "飞身踢";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("飞身踢");
    }
}


//长枪
_root.主动战技函数.长枪.发射榴弹 = {
    初始化:function(自机){
        自机.当前弹夹副武器已发射数 = 0;
        //再次读取物品属性取得传参
        var 长枪物品信息 = _root.getItemData(自机.长枪);
        var skill = 长枪物品信息.skill;
        自机.副武器子弹威力 = skill.power && skill.power > 0 ? Number(skill.power) : 2500;
        自机.副武器可发射数 = skill.bulletsize > 0 ? Number(skill.bulletsize) : 1;
        自机.副武器弹药类型 = skill.clipname ? skill.clipname : "榴弹弹药";
        自机.副武器子弹种类 = skill.bullet ? skill.bullet : "榴弹";
        自机.副武器子弹声音 = skill.sound ? skill.sound : "re_GL_under.wav";
        自机.副武器子弹霰弹值 = skill.split && skill.split > 0 ? Number(skill.split) : 1;
        自机.副武器子弹散射度 = skill.diffusion && skill.diffusion > 0 ? Number(skill.diffusion) : 0;
        自机.副武器子弹速度 = skill.velocity && skill.velocity > 0 ? Number(skill.velocity) : 25;
        自机.副武器子弹Z轴攻击范围 = skill.range && skill.range > 0 ? Number(skill.range) : 50;
        自机.副武器子弹击倒率 = skill.range && skill.range > 0 ? Number(skill.range) : 0.01;
    },
    释放许可判定:function(自机){
        if(自机.当前弹夹副武器已发射数 >= 自机.副武器可发射数) return false;
        if(自机.浮空 || 自机.倒地) return false;
        if(!(自机.状态 === "长枪行走" || 自机.状态 === "长枪站立") || 自机.换弹中) return false;
        //检测物品栏弹药
		if(自机.当前弹夹副武器已发射数 > 0){
			return true;
		}else{
        	for (var i = 0; i < _root.物品栏总数; i++)
        	{
         	   if (_root.物品栏[i][0] === 自机.副武器弹药类型)
            	{
                	if (_root.物品栏[i][1] > 1)
                	{
                    	_root.物品栏[i][1]--;
                	}
                	else
                	{
                    	_root.发布消息(自机.副武器弹药类型 + "耗尽！");
                    	_root.物品栏[i] = ["空", 0, 0];
                	}
                	_root.排列物品图标();
                	return true;
            	}
        	}
		}
        return false;
    },
    释放:function(自机){
        自机.当前弹夹副武器已发射数++;
        var myPoint = {x:自机.man.枪.枪.装扮.枪口位置._x, y:自机.man.枪.枪.装扮.枪口位置._y + 20};
        自机.man.枪.枪.装扮.localToGlobal(myPoint);
        _root.gameworld.globalToLocal(myPoint);
        var 子弹属性 = new Object();
        子弹属性.声音 = 自机.副武器子弹声音;
        子弹属性.霰弹值 = 自机.副武器子弹霰弹值;
        子弹属性.子弹散射度 = 自机.副武器子弹散射度;
        子弹属性.发射效果 = "";
        子弹属性.子弹种类 = 自机.副武器子弹种类;
        子弹属性.子弹威力 = 自机.副武器子弹威力;
        子弹属性.子弹速度 = 自机.副武器子弹速度;
        子弹属性.击中地图效果 = "";
        子弹属性.Z轴攻击范围 = 自机.副武器子弹Z轴攻击范围;
        子弹属性.击倒率 = 自机.副武器子弹击倒率;
        子弹属性.击中后子弹的效果 = "";
        子弹属性.子弹敌我属性 = !自机.是否为敌人;
        子弹属性.发射者 = 自机._name;
        子弹属性.shootX = myPoint.x;
        子弹属性.shootY = myPoint.y;
        子弹属性.shootZ = 自机.Z轴坐标;
        var 长枪物品信息 = _root.getItemData(自机.长枪);
        var skill = 长枪物品信息.skill;
        //子弹属性.子弹威力 = skill.power > 0 ? Number(skill.power) : 2500;
        _root.子弹区域shoot传递(子弹属性);
    }
}

_root.主动战技函数.长枪.旋转抡枪 = {
    初始化:null,
    释放许可判定:function(自机){
        return 自机.攻击模式 === "长枪" && (!自机.倒地 && 自机.状态 != "击倒" && 自机.状态 != "技能");
    },
    释放:function(自机){
        自机.技能名 = "抡枪";
        自机.状态改变("技能");
        自机.man.gotoAndPlay("抡枪");
    }
}



//兵器
_root.主动战技函数.兵器.滑步 = {
    初始化:null,
    释放许可判定:function(自机){
        return true;//应该是无条件吧（）
    },
    释放:function(自机){
        自机.技能名 = "战技小跳";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("战技小跳");
    }
}

_root.主动战技函数.兵器.弧光斩 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "弧光斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("弧光斩");
    }
}

_root.主动战技函数.兵器.凶斩 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "凶斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("凶斩");
    }
}

_root.主动战技函数.兵器.狼跳 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "狼跳";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("狼跳");
    }
}

_root.主动战技函数.兵器.突刺 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "突刺";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("突刺");
    }
}

_root.主动战技函数.兵器.重力操作 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "重力操作";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("重力操作");
    }
}

_root.主动战技函数.兵器.瞬步斩 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "瞬步斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("瞬步斩");
    }
}

_root.主动战技函数.兵器.漆黑凶斩 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "漆黑凶斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("漆黑凶斩");
    }
}

_root.主动战技函数.兵器.黑刀斩术 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "黑刀斩术";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("黑刀斩术");
    }
}

_root.主动战技函数.兵器.猩红居合 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "猩红凶斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("猩红凶斩");
    }
}

_root.主动战技函数.兵器.居合次元斩 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "居合次元斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("居合次元斩");
    }
}

_root.主动战技函数.兵器.天蓝斩术 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.倒地;
    },
    释放:function(自机){
        自机.技能名 = "蓝瞬步斩";
        自机.状态改变("战技");
        自机.man.gotoAndPlay("蓝瞬步斩");
    }
}

_root.主动战技函数.兵器.苍紫爆炸 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.浮空 && !自机.倒地;
    },
    释放:function(自机){
        var 当前战技 = 自机.主动战技.兵器;
        var 子弹属性 = new Object();
		子弹属性.声音 = "";
		子弹属性.霰弹值 = 1;
		子弹属性.子弹散射度 = 0;
		子弹属性.发射效果 = "";
		子弹属性.子弹种类 = "苍紫爆炸";
		子弹属性.子弹威力 = 当前战技.消耗mp * 10;
		子弹属性.子弹速度 = 0;
		子弹属性.击中地图效果 = "";
		子弹属性.Z轴攻击范围 = 150;
		子弹属性.击倒率 = 1;
		子弹属性.击中后子弹的效果 = "";
		子弹属性.水平击退速度 = 20;
		子弹属性.发射者 = 自机._name;
		子弹属性.子弹敌我属性 = !自机.是否为敌人;
        var 偏移距离 = 50;
		var 偏移x = (Math.random() - 0.5) * 2 * 偏移距离;
		var 偏移y = (Math.random() - 0.5) * 2 * 偏移距离;
		子弹属性.shootX = 自机._x + 偏移x;
        子弹属性.shootY = 自机.Z轴坐标 + 偏移y;
		子弹属性.shootZ = 子弹属性.shootY;
		_root.子弹区域shoot传递(子弹属性);
    }
}

_root.主动战技函数.兵器.黑铁剑意 = {
    初始化:null,
    释放许可判定:function(自机){
        return !自机.浮空 && !自机.倒地 && (自机.状态 === "兵器攻击" || 自机.状态 === "兵器冲击");
    },
    释放:function(自机){
        var 当前战技 = 自机.主动战技.兵器;
        var 子弹属性 = new Object();
        子弹属性.声音 = "";
		子弹属性.霰弹值 = 1;
		子弹属性.子弹散射度 = 0;
		子弹属性.发射效果 = "";
		子弹属性.子弹种类 = "剑光特效";
		子弹属性.子弹威力 = 当前战技.消耗mp * 12;
		子弹属性.子弹速度 = 0;
		子弹属性.击中地图效果 = "";
        子弹属性.Z轴攻击范围 = 100;
        子弹属性.击倒率 = 1;
		子弹属性.击中后子弹的效果 = "";
		子弹属性.水平击退速度 = 18;
        子弹属性.发射者 = 自机._name;
		子弹属性.子弹敌我属性 = !自机.是否为敌人;
        var 偏移距离 = 50;
		var 偏移x = (Math.random() - 0.5) * 2 * 偏移距离;
		// var 偏移y = (Math.random() - 0.5) * 2 * 偏移距离;
		子弹属性.shootX = 自机._x + 偏移x;
        子弹属性.shootY = 自机.Z轴坐标;
		子弹属性.shootZ = 子弹属性.shootY;
        _root.子弹区域shoot传递(子弹属性);
    }
}


//星座武器特辑
_root.主动战技函数.兵器.摩羯之力 = {
    初始化:null,
    释放许可判定:function(自机){
        return _root.控制目标 === 自机._name;
    },
    释放:function(自机){
        _root.发布消息("摩羯之力发动，敌人被引力拉扯至周围！");
        var 当前战技 = 自机.主动战技.兵器;
		var 子弹属性 = new Object();
		子弹属性.声音 = "";
		子弹属性.霰弹值 = 1;
		子弹属性.子弹散射度 = 0;
		子弹属性.发射效果 = "";
		子弹属性.子弹种类 = "摩羯之力";
		子弹属性.子弹威力 = 当前战技.消耗mp * 10;
		子弹属性.子弹速度 = 0;
		子弹属性.击中地图效果 = "";
		子弹属性.Z轴攻击范围 = 72;
		子弹属性.击倒率 = 1;
		子弹属性.击中后子弹的效果 = "";
		子弹属性.水平击退速度 = 18;
		子弹属性.发射者 = 自机._name;
        子弹属性.子弹敌我属性 = !自机.是否为敌人;
		子弹属性.shootX = 自机._x;
		子弹属性.shootY = 自机.Z轴坐标;
		子弹属性.shootZ = 子弹属性.shootY;
		_root.子弹区域shoot传递(子弹属性);
    }
}

_root.主动战技函数.兵器.金牛之力 = {
    初始化:null,
    释放许可判定:function(自机){
        return _root.控制目标 === 自机._name;
    },
    释放:function(自机){
        _root.发布消息("金牛之力发动，金币与K点爆率提升至50%，持续30秒！");
        _root.打怪掉钱机率 = 2;
        var timer = setTimeout(function (){
            _root.打怪掉钱机率 = 6;
            clearTimeout(timer);
        },30000);
        _root.发布调试消息("_root.打怪掉钱机率: " + _root.打怪掉钱机率);
        var 当前战技 = 自机.主动战技.兵器;
		var 子弹属性 = new Object();
		子弹属性.声音 = "";
		子弹属性.霰弹值 = 1;
		子弹属性.子弹散射度 = 0;
		子弹属性.发射效果 = "";
		子弹属性.子弹种类 = "金牛之力";
		子弹属性.子弹威力 = 当前战技.消耗mp * 12;
		子弹属性.子弹速度 = 0;
		子弹属性.击中地图效果 = "";
		子弹属性.Z轴攻击范围 = 72;
		子弹属性.击倒率 = 1;
		子弹属性.击中后子弹的效果 = "";
		子弹属性.水平击退速度 = 18;
		子弹属性.发射者 = 自机._name;
        子弹属性.子弹敌我属性 = !自机.是否为敌人;
		子弹属性.shootX = 自机._x;
		子弹属性.shootY = 自机.Z轴坐标;
		子弹属性.shootZ = 子弹属性.shootY;
		_root.子弹区域shoot传递(子弹属性);
    }
}

_root.主动战技函数.兵器.狮子之力 = {
    初始化:function(自机){
        if (isNaN(自机.狮王增幅次数)) 自机.狮王增幅次数 = 0;
    },
    释放许可判定:function(自机){
        return _root.控制目标 === 自机._name;
    },
    释放:function(自机){
        var 我方角色数量 = _root.帧计时器.获取友军缓存(自机, 150).length;
        if (我方角色数量 >= 10) 我方角色数量 = 10;
        if (自机.狮王增幅次数 < 1)
        {
            /*
            狮王攻击加成 = 我方角色数量 * 自机.空手攻击力 * 0.10;
            狮王防御加成 = 我方角色数量 * 自机.防御力 * 0.10;
            if(狮王攻击加成 >= 1000)
            {
            狮王攻击加成 = 1000;
            }
            if(狮王防御加成 >= 2000)
            {
            狮王防御加成 = 2000;
            }
            自机.空手攻击力 += 狮王攻击加成;
            自机.防御力 += 狮王防御加成;
            
            //换算为加算写法，但不建议在乘算倍率中使用
            狮王攻击加成 = Math.min(1000, 自机.buff.基础值.空手攻击力 * 我方角色数量 * 0.10);
            狮王防御加成 = Math.min(2000, 自机.buff.基础值.防御力 * 我方角色数量 * 0.10);
            自机.buff.赋值("空手攻击力", "加算", 狮王攻击加成, "增益");
            自机.buff.赋值("防御力", "加算", 狮王防御加成, "增益");
            */
            var 狮王攻击加成倍率 = 1 + 我方角色数量 * 0.10;
            var 攻击buff换算上限值 = 1000;
            var 攻击buff换算下限值 = -10;
            var 狮王防御加成倍率 = 1 + 我方角色数量 * 0.10;
            var 防御buff换算上限值 = 2000;
            var 防御buff换算下限值 = -10;
            
            自机.buff.赋值("空手攻击力","倍率",狮王攻击加成倍率,"增益",攻击buff换算上限值,攻击buff换算下限值);
            自机.buff.赋值("防御力","倍率",狮王防御加成倍率,"增益",防御buff换算上限值,防御buff换算下限值);
            
            自机.狮王增幅次数 = 1;
            _root.发布消息("狮王之力发动！目前力量提升至" + 自机.空手攻击力 + "点！");
            _root.发布消息("狮王之力发动！目前防御提升至" + 自机.防御力 + "点！");
        }
        var 当前战技 = 自机.主动战技.兵器;
		var 子弹属性 = new Object();
		子弹属性.声音 = "";
		子弹属性.霰弹值 = 1;
		子弹属性.子弹散射度 = 0;
		子弹属性.发射效果 = "";
		子弹属性.子弹种类 = "狮子之力";
		子弹属性.子弹威力 = 当前战技.消耗mp * (10 + 我方角色数量);
		子弹属性.子弹速度 = 0;
		子弹属性.击中地图效果 = "";
		子弹属性.Z轴攻击范围 = 72;
		子弹属性.击倒率 = 1;
		子弹属性.击中后子弹的效果 = "";
		子弹属性.水平击退速度 = 18;
		子弹属性.发射者 = 自机._name;
        子弹属性.子弹敌我属性 = !自机.是否为敌人;
		子弹属性.shootX = 自机._x;
		子弹属性.shootY = 自机.Z轴坐标;
		子弹属性.shootZ = 子弹属性.shootY;
		_root.子弹区域shoot传递(子弹属性);
    }
}