_root.使用药剂 = function(物品名)
{
	var 控制对象 = _root.gameworld[_root.控制目标];
	if (控制对象.hp <= 0) return;
	
	var 炼金等级 = 0;
	if (_root.主角被动技能.炼金 && _root.主角被动技能.炼金.启用)
	{
		炼金等级 = _root.主角被动技能.炼金.等级;
	}

	var tmp_药剂属性 = _root.根据物品名查找全部属性(物品名);
	if (tmp_药剂属性[7] == 0)
	{
		var hp增加值 = tmp_药剂属性[10] + Math.min(Math.floor(tmp_药剂属性[10] * 炼金等级 * 0.05), 500);
		if (hp增加值 + 控制对象.hp <= Math.ceil(控制对象.hp满血值 * (1 + 炼金等级 * 0.03)))
		{
			控制对象.hp += hp增加值;
		}
		else if (控制对象.hp < Math.ceil(控制对象.hp满血值 * (1 + 炼金等级 * 0.03)))
		{
			控制对象.hp = Math.ceil(控制对象.hp满血值 * (1 + 炼金等级 * 0.03));
		}
		_root.玩家信息界面.刷新hp显示();
		var mp增加值 = tmp_药剂属性[11] + Math.min(Math.ceil(tmp_药剂属性[11] * 炼金等级 * 0.1), 1000);
		if (mp增加值 + 控制对象.mp <= 控制对象.mp满血值)
		{
			控制对象.mp += mp增加值;
		}
		else
		{
			控制对象.mp = 控制对象.mp满血值;
		}
		_root.玩家信息界面.刷新mp显示();
		_root.效果("药剂动画",控制对象._x,控制对象._y,100);
	}
	else if (tmp_药剂属性[7] == 1)
	{
		_root.佣兵集体加血(tmp_药剂属性[10] + Math.min(Math.floor(tmp_药剂属性[10] * 炼金等级 * 0.05), 500));
	}
	else if (tmp_药剂属性[7] == "淬毒")
	{
		var 淬毒量 = _root.getItemData(物品名).data.poison;
		if (淬毒量)
		{
			控制对象.淬毒 = 淬毒量 + Math.min(Math.floor(淬毒量 * 炼金等级 * 0.07), 2000);
		}
		_root.效果("淬毒动画",控制对象._x,控制对象._y,100);
	}
	else if (tmp_药剂属性[7] == "净化")
	{
		var 净化量 = Number(_root.getItemData(物品名).data.clean) + Math.min(Math.floor(5 * 炼金等级), 50);
		if (净化量)
		{
			if (_root.地形伤害系数)
			{
				_root.地形伤害系数 = 0.09 + (_root.地形伤害系数 - 0.09) * 20 / 净化量;
			}
			控制对象.麻痹值 = -10 * 净化量;
		}
		_root.效果("净化动画",控制对象._x,控制对象._y,100);
	}
}
