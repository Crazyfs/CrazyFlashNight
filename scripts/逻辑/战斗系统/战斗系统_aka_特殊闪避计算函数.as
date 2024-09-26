//lazyMiss懒闪避：低于5%总血量不闪避，高于100%时达到最大闪避
_root.lazyMiss = function(Obj,伤害,懒闪避值){
	if(Obj.hp满血值==undefined || Obj.hp==undefined || Obj.hp<=0){
		return false;
	}
	if(伤害>Obj.hp满血值/2){
		return _root.成功率(100*懒闪避值);
	}
	if(Obj.hp<Obj.hp满血值/2){
		if(伤害>Obj.hp满血值/5){
			return _root.成功率(100*懒闪避值);
		}
		if(伤害<Obj.hp满血值*0.025){
			return false;
		}
		return _root.成功率(100*懒闪避值*伤害*5/Obj.hp满血值);
	}
	if(伤害<Obj.hp满血值*0.05){
		return false;
	}
	return _root.成功率(100*懒闪避值*伤害*2/Obj.hp满血值);
}