﻿_root.cheatCode = function(作弊码){
	
	
   if(作弊码 == "hardmode")
   {
      _root.difficultyMode = 0;
      _root.最上层发布文字提示("更改为困难模式！");
      _root.修改工具按钮._visible = true;
   }
   else if(作弊码 == "easymode")
   {
      _root.difficultyMode = 1;
      _root.最上层发布文字提示("更改为简单模式！");
      _root.修改工具按钮._visible = true;
   }
   else if(作弊码 == "challengemode")
   {
      _root.difficultyMode = 2;
      _root.最上层发布文字提示("更改为挑战模式！");
      _root.修改工具按钮._visible = false;
   }
   if(作弊码 == "easteregg")
   {
      _root.easterEgg = 1;
      _root.最上层发布文字提示("彩蛋内容开启！");
   }
   else if(作弊码 == "eastereggoff")
   {
      _root.easterEgg = 0;
      _root.最上层发布文字提示("彩蛋内容关闭！");
   }
   if(作弊码 == "test" and !_root.调试模式)
   {
      _root.调试模式 = true;
      _root.最上层发布文字提示("调试模式开启！");
   }
   else if(作弊码 == "test" and _root.调试模式)
   {
      _root.调试模式 = false;
      _root.最上层发布文字提示("调试模式关闭！");
   }
   if(作弊码 == "add1")
   {
  		add1僵尸兵种 = "敌人-光头军人僵尸1";
  		add1僵尸等级 = 1;
   		add1僵尸名字 = "僵尸";
  	 	add1僵尸是否为敌人 = true;
   		add1僵尸身高 = 175;
  	 	add1僵尸长枪 = "";
   		add1僵尸手枪 = "";
   		add1僵尸手枪2 = "";
  	 	add1僵尸刀 = "";
   		add1僵尸手雷 = "";
   		add1僵尸僵尸型敌人newname = this._name + 兵种;
   		_root.gameworld.attachMovie(add1僵尸兵种,add1僵尸僵尸型敌人newname,_parent.getNextHighestDepth(),{_x: _root.gameworld[_root.控制目标]._x ,_y:_root.gameworld[_root.控制目标]._y,等级:this.add1僵尸等级,名字:this.add1僵尸名字,是否为敌人:this.add1僵尸是否为敌人,身高:this.add1僵尸身高,长枪:this.add1僵尸长枪,手枪:this.add1僵尸手枪,手枪2:this.add1僵尸手枪2,刀:this.add1僵尸刀,手雷:this.add1僵尸手雷,产生源:this._name});

      _root.最上层发布文字提示("添加一个僵尸！");
   }
	if(作弊码.indexOf("#code:")>-1){
		执行代码  = 作弊码.split("#code:")[1];
		_root.发布消息("执行代码："+执行代码);
		eval(执行代码);
		_root.发布消息("执行失败！因为as2不支持eval()直接解析，等fs处理吧");
	}else if(作弊码.indexOf("#_root.")>-1){
		执行代码  = 作弊码.split("#_root.")[1].split("=");
		变量名  = 执行代码[0].split(" ").join("");
		变量值  = 执行代码[1];
		if(变量值.indexOf(";")>-1){
			变量值初始值 = 变量值.split(";");
			变量值=变量值初始值[0];
			参数类型 = 变量值初始值[1];
			if(参数类型.indexOf("int")>-1  or 参数类型.indexOf("数")>-1  or 参数类型.indexOf("float")>-1  or 参数类型.indexOf("number")>-1  or 参数类型.indexOf("Number")>-1 ){
				变量值 = Number(变量值);
				_root.发布消息("传入数字型");
			}else if(参数类型.indexOf("bool")>-1  or 参数类型.indexOf("布尔")>-1 ){
				if(变量值=="false" or 变量值=="0" or !变量值){
					变量值 = false;
				}else{
					变量值 = true;
				}
				_root.发布消息("传入布尔型："+变量值);
			}
		}
		_root.发布消息("变更变量：_root."+变量名);
		_root[变量名] = 变量值;
		_root.发布消息("值已变更为:"+变量值);
	}else if(作弊码.indexOf("#func:_root.")>-1){
		执行代码  = 作弊码.split("#func:_root.")[1].split("(");
		执行函数  = 执行代码[0].split(" ").join("");
		执行参数初始值  = 执行代码[1].split(")");
		执行参数  = 执行参数初始值[0];
		参数类型  = 执行参数初始值[1];
		_root.发布消息("执行函数：_root."+执行函数+"("+执行参数+")");
		执行参数数组 = 执行参数.split(",");
		for(i=0;i<执行参数数组.length;i++){
			if(执行参数数组.length==1){
				前缀="";
			}else{
				前缀=i+1;
				前缀=前缀+":"
			}
			if(参数类型.indexOf(前缀+"int")>-1  or 参数类型.indexOf(前缀+"数")>-1  or 参数类型.indexOf(前缀+"float")>-1  or 参数类型.indexOf(前缀+"num")>-1  or 参数类型.indexOf(前缀+"Num")>-1 ){
				执行参数数组[i] = Number(执行参数数组[i]);
				_root.发布消息("传入数字型:"+执行参数数组[i]);
			}else if(参数类型.indexOf(前缀+"变量")>-1 or 参数类型.indexOf(前缀+"var")>-1){
				if(作弊码.indexOf("_root.")>-1){
					执行参数数组[i] = 执行参数数组[i].split("_root.")[1].split(" ").join("");
				}else{
					执行参数数组[i] = 执行参数数组[i].split(" ").join("");
				}
				_root.发布消息("传入root变量:_root."+执行参数数组[i]);
				执行参数数组[i] = _root[执行参数数组[i]];
			}else if(参数类型.indexOf(前缀+"bool")>-1  or 参数类型.indexOf(前缀+"布尔")>-1 ){
					if(执行参数数组[i]=="false" or 执行参数数组[i]=="0" or !执行参数数组[i]){
						执行参数数组[i] = false;
					}else{
						执行参数数组[i] = true;
					}
					_root.发布消息("传入布尔型："+执行参数数组[i]);
			}
		}
		
		//_root[执行函数](执行参数);
		_root[执行函数].apply(this, 执行参数数组);
		_root.发布消息("执行完毕！");
	}else if(作弊码.indexOf("#change:")>-1){
		执行代码  = 作弊码.split("#change:")[1];
		_root.特殊操作单位 = 执行代码;
		if(_root.特殊操作单位=="false" or _root.特殊操作单位=="0"){
			_root.特殊操作单位="";
		}
		_root.加载我方人物(_root.gameworld.出生地._x,_root.gameworld.出生地._y);
		if(_root.特殊操作单位){
			_root.最上层发布文字提示("当前操作目标变更为："+_root.特殊操作单位+"-切换场景生效");
		}else{
			_root.最上层发布文字提示("当前操作目标恢复！"+"-切换场景生效");
		}
	}else if(作弊码.indexOf("#level:")>-1){
		执行代码  = 作弊码.split("#level:")[1].split(" ").join("");
		
		_root.等级 = Number(执行代码);
		_root.经验值 = _root.根据等级得升级所需经验(_root.等级-1);
		_root.升级需要经验值 = _root.根据等级得升级所需经验(_root.等级);
		_root.玩家信息界面.刷新经验值显示();
		_root.最上层发布文字提示("当前等级变更为："+_root.等级+",经验值变更为："+_root.经验值+"-切换场景生效");
		
	}else if(作弊码.substring(0,2)==".."){
		执行代码  = 作弊码.split("..")[1].split(" ").join("");
		if(!isNaN(Number(执行代码))){
			_root.等级 = Number(执行代码);
			_root.经验值 = _root.根据等级得升级所需经验(_root.等级-1);
			_root.升级需要经验值 = _root.根据等级得升级所需经验(_root.等级);
			_root.玩家信息界面.刷新经验值显示();
			_root.最上层发布文字提示("当前等级变更为："+_root.等级+",经验值变更为："+_root.经验值+"-切换场景生效");
		}
		
	}
	//_root.发布消息(作弊码.substring(0,2));
}

/*
作弊码（部分）语法示例：
调试模式开启/关闭：test
简单模式：easymode
困难模式：hardmode
挑战模式：challengemode
添加一个僵尸（角斗场无人时可用，其中为数字1）：add1
变更等级(和对应经验)：#level:15

_root.变量值变更（字符串型）：#_root.abc=AAA
_root.变量值变更（非字符串型）：#_root.abc=123;int

_root.函数执行(单字符串型传值)：#func:_root.测试作弊码(ABC)
_root.函数执行(单非字符串型传值)：#func:_root.测试作弊码(123);int
_root.函数执行(单参数，传_root.变量)：#func:_root.测试作弊码(_root.abc);var

_root.函数执行(多参数均为字符串型)：#func:_root.测试作弊码2(AB,AC)
_root.函数执行(多参数，指定参数数据类型)：#func:_root.测试作弊码3(123,AC,_root.abc);1:数字,3:变量

变更当前操作单位（未进行操作代码适配的单位无法移动）：#change:主角-尾上世莉架

*/
_root.测试作弊码 = function(a){
	_root.发布消息(a+1);
}
_root.测试作弊码2 = function(a,b){
	_root.发布消息(a+b);
}
_root.测试作弊码3 = function(a,b,c){
	_root.发布消息(a+b+c);
}