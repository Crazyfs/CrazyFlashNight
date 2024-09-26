_root.装备生命周期函数.初期特效初始化 = function(反射对象, 参数对象) 
{
   反射对象.子弹属性 = 反射对象.子弹配置.bullet_0;//通过反射对象传参通讯
   反射对象.成功率 = 参数对象.probability ? 参数对象.probability : 3;
   反射对象.xOffset = 参数对象.xOffset ? 参数对象.xOffset : 0;
   反射对象.yOffset = 参数对象.yOffset ? 参数对象.yOffset :0;

   _root.装备生命周期函数.获得身高修正比(反射对象);
   _root.装备生命周期函数.解析刀口(反射对象, 参数对象);
};

_root.装备生命周期函数.初期特效周期 = function(反射对象, 参数对象) 
{
    _root.装备生命周期函数.移除异常周期函数(反射对象);
    
    var 自机 = 反射对象.自机;
    if (_root.兵器攻击检测(自机)) 
    {
        if (_root.成功率(反射对象.成功率)) 
        {
            var 刀口 = 反射对象.获得刀口(反射对象);
            var 坐标 = {x:刀口._x,y:刀口._y};
            刀口._parent.localToGlobal(坐标);
            _root.gameworld.globalToLocal(坐标);
            
            坐标.x += (自机.方向 === "左" ? -1 : 1) * 反射对象.xOffset * 反射对象.身高修正比;
            坐标.y += 反射对象.yOffset * 反射对象.身高修正比;

            反射对象.子弹属性.shootX = 坐标.x;
            反射对象.子弹属性.shootY = 坐标.y;
            反射对象.子弹属性.shootZ = 自机.Z轴坐标;

            _root.子弹区域shoot传递(反射对象.子弹属性);
        }
    }
    //_root.服务器.发布服务器消息("初期特效周期");
};

_root.装备生命周期函数.耗蓝特效初始化 = function(反射对象, 参数对象)
{
    var 自机 = 反射对象.自机;

    反射对象.成功率 = 参数对象.probability ? 参数对象.probability : 5;
    反射对象.特效间隔 = 参数对象.interval ? 参数对象.interval : 500;
    反射对象.攻击时转向 = 参数对象.turn ? 参数对象.turn : true;
    反射对象.刀口位置 = "刀口位置" + (参数对象.position ? 参数对象.position : "3");
    反射对象.是否缓存威力 = 参数对象.cache ? 参数对象.cache : true;

    反射对象.子弹属性 = 反射对象.子弹配置.bullet_0;

    var 耗蓝量 = 参数对象.mp ? 参数对象.mp : 25;
    var 耗蓝百分比 = Number(耗蓝量.split("%")[0]);
    
    反射对象.伤害转化系数 = 参数对象.conversion ? 参数对象.conversion : 1;

    if(参数对象.cache)
    {
        反射对象.耗蓝量 = (耗蓝量.indexOf("%") === 耗蓝量.length - 1 && 耗蓝百分比 > 0) ? (自机.mp满血值 / 100 * 耗蓝百分比) : 耗蓝量;
        反射对象.子弹属性.子弹威力 = 反射对象.耗蓝量 * 反射对象.伤害转化系数;

        反射对象.设置子弹属性 = function(反射对象)
        {
            var 自机 = 反射对象.自机;
            var 刀口 = 自机.刀_引用[反射对象.刀口位置];
            var 坐标 = {x:刀口._x,y:刀口._y};
            var 子弹属性 = 反射对象.子弹属性;

            刀口._parent.localToGlobal(坐标);
            _root.gameworld.globalToLocal(坐标);
            子弹属性.shootX = 坐标.x;
            子弹属性.shootY = 坐标.y;
            子弹属性.shootZ = 自机.Z轴坐标;
        };
    }
    else
    {
        if(耗蓝量.indexOf("%") === 耗蓝量.length - 1 && 耗蓝百分比 > 0)
        {
            反射对象.耗蓝百分比 = 耗蓝百分比;
            反射对象.获得子弹威力 = function(反射对象)
            {
                反射对象.耗蓝量 = 反射对象.自机.mp满血值 / 100 * 反射对象.耗蓝百分比;
                
                return  反射对象.耗蓝量 * 反射对象.伤害转化系数;
            };
        }
        else
        {
            反射对象.耗蓝量 = 耗蓝量;
            
            反射对象.获得子弹威力 = function(反射对象)
            {
                return 反射对象.耗蓝量 * 反射对象.伤害转化系数;
            };
        }
        
        反射对象.设置子弹属性 = function(反射对象)
        {
            var 自机 = 反射对象.自机;
            var 刀口 = 自机.刀_引用[反射对象.刀口位置];
            var 坐标 = {x:刀口._x,y:刀口._y};
            var 子弹属性 = 反射对象.子弹属性;

            刀口._parent.localToGlobal(坐标);
            _root.gameworld.globalToLocal(坐标);
            子弹属性.shootX = 坐标.x;
            子弹属性.shootY = 坐标.y;
            子弹属性.shootZ = 自机.Z轴坐标;
            子弹属性.子弹威力 = 反射对象.获得子弹威力(反射对象);
        };
    }

    if(参数对象.state)
    {
        反射对象.释放特效 = function(反射对象)
        {

        };
    }
    else
    {
        反射对象.释放特效 = function(反射对象)
        {

        };
    }
};

_root.装备生命周期函数.耗蓝特效周期 = function(反射对象, 参数对象)
{
    _root.装备生命周期函数.移除异常周期函数(反射对象);

    var 自机 = 反射对象.自机;

    if(_root.兵器攻击检测(自机))
    { 
        _root.更新并执行时间间隔动作(反射对象, 反射对象.生命周期函数, 反射对象.释放特效, 反射对象.特效间隔, false, 反射对象);
    }
};

/*.

onClipEvent(enterFrame){
   冷却时间结束 = true;
   冷却时间间隔 = 0.5;
   耗蓝比例 = 1;
   自机 = _root.获得父节点(this,5);
   当前时间 = getTimer();
   if(isNaN(自机.上次释放时间) or 当前时间 - 自机.上次释放时间 > 冷却时间间隔 * 1000)
   {
      缓存时间 = 自机.上次释放时间;
      自机.上次释放时间 = 当前时间;
   }
   else
   {
      冷却时间结束 = false;
   }
   if(_root.兵器攻击检测(自机) and 冷却时间结束)
   {
      特效许可 = true;
      switch(自机.getSmallState())
      {
         case "兵器一段中":
         case "兵器五段中":
            特效许可 = true;
            break;
         default:
            特效许可 = _root.成功率(5);
      }
      if(特效许可)
      {
         自机.man.攻击时可改变移动方向(1);
         耗蓝量 = Math.floor(自机.mp满血值 / 100 * 耗蓝比例);
         if(自机.mp >= 耗蓝量)
         {
            var myPoint = {x:this._x,y:this._y};
            _parent.localToGlobal(myPoint);
            _root.gameworld.globalToLocal(myPoint);
            声音 = "";
            霰弹值 = 1;
            子弹散射度 = 0;
            发射效果 = "";
            子弹种类 = "碎石飞扬";
            子弹威力 = 耗蓝量 * 12;
            子弹速度 = 1;
            击中地图效果 = "";
            Z轴攻击范围 = 50;
            击倒率 = 1;
            击中后子弹的效果 = "";
            子弹敌我属性 = true;
            发射者名 = 自机._name;
            子弹敌我属性值 = 自机.是否为敌人 == true ? false : true;
            shootX = myPoint.x;
            Z轴坐标 = shootY = 自机._y;
            _root.子弹区域shoot(声音,霰弹值,子弹散射度,发射效果,子弹种类,子弹威力,子弹速度,Z轴攻击范围,击中地图效果,发射者名,shootX,shootY,Z轴坐标,子弹敌我属性值,击倒率,击中后子弹的效果);
         }
         else if(自机 == root.gameworld[_root.控制目标])
         {
            root.发布消息("气力不足，难以发挥装备的真正力量……");
         }
      }
   }
}

*/