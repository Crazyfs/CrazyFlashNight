_root.单元体计数 = 0;

_root.创建单元体 = function(子弹:MovieClip, 子弹种类:String) {
    _root.单元体计数++;
    return 子弹.attachMovie("单元体-" + 子弹种类, "单元体-" + _root.单元体计数++, 子弹.getNextHighestDepth());
}

_root.回收单元体 = function(单元体:MovieClip) {
    单元体.removeMovieClip();
}

_root.子弹衰竭计数 = function(子弹:MovieClip) {
    return (子弹.霰弹值 + 子弹.子弹散射度) / 25;// 让衰减在前期更为剧烈  
}

_root.嵌套子弹属性初始化 = function(子弹元件:MovieClip,子弹种类:String){
	var 子弹属性 = {
		声音:"",
		霰弹值:子弹元件.霰弹值,
		子弹散射度:1,
		发射效果:"",
		子弹种类:子弹种类 == undefined ? "普通子弹" : 子弹种类,
		子弹威力:子弹元件.子弹威力,
		子弹速度:10,
		Z轴攻击范围:10,
		击中地图效果:"火花",
		发射者:子弹元件.发射者名,
		shootX:子弹元件._x,
		shootY:子弹元件._y,
		shootZ:子弹元件.Z轴坐标,
		子弹敌我属性:子弹元件.子弹敌我属性值,
		击倒率:10,
		击中后子弹的效果:"",
		水平击退速度:NaN,
		垂直击退速度:NaN,
		命中率:NaN,
		固伤:NaN,
		百分比伤害:NaN,
		血量上限击溃:NaN,
		防御粉碎:NaN,
		区域定位area:子弹元件.子弹区域area
	}
	return 子弹属性;
}

