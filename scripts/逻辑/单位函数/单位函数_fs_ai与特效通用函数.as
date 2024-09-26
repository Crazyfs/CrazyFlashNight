_root.获得随机坐标偏离 = function(自机:Object, 坐标偏移范围:Number)
{
	var xOffset = (_root.basic_random() - 0.5) * 2 * 坐标偏移范围;
	var yOffset = (_root.basic_random() - 0.5) * 2 * 坐标偏移范围;
	return {x:自机._x + xOffset, y:自机._y + yOffset};
};


_root.寻找攻击目标基础函数 = function(自机:Object) 
{
   	if (自机.攻击目标 == "无" or _root.gameworld[自机.攻击目标].hp <= 0) 
	{
        var 最近的距离:Number = Infinity;
        var 最近的敌人名:String = undefined;

        var 敌人列表 = _root.帧计时器.获取敌人缓存(自机, 30); // 从缓存中获取当前自机应该攻击的目标类型的列表，1s刷新一次缓存

        for (var i = 0; i < 敌人列表.length; i++) 
		{
            var 待检测目标 = 敌人列表[i];
            var d = Math.abs(待检测目标._x - 自机._x);
            if (d < 最近的距离) 
			{
                最近的距离 = d;
                最近的敌人名 = 待检测目标._name;
            }
        }

        自机.攻击目标 = 最近的敌人名 ? 最近的敌人名 : "无";
    }
};
