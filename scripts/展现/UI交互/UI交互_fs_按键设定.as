
//_root.互动键 = 69;//e键
//_root.武器技能键 = 70;//f键
//_root.飞行键 = 18;//Alt键
//_root.武器变形键 = 81;//q键盘
//_root.奔跑键 = 16;//shift键盘

_root.刷新键值设定 = function()
{
    var 键值设定 = _root.键值设定;
	if(_root.键值设定.length < 30){
		var 新增按键 = [[_root.获得翻译("互动键"), "互动键", 69], [_root.获得翻译("武器技能键"), "武器技能键", 70], [_root.获得翻译("飞行键"), "飞行键", 18],  [_root.获得翻译("武器变形键"), "武器变形键", 81], [_root.获得翻译("奔跑键"), "奔跑键", 16]];

		_root.键值设定 = _root.键值设定.concat(新增按键);
	}
    for (var i = 0; i < 键值设定.length; i++)
	{
		_root[键值设定[i][1]] = 键值设定[i][2];
	}
	var 操控目标按键设定表 = _root.按键设定表[0];
	操控目标按键设定表[0] = _root.上键;
	操控目标按键设定表[1] = _root.下键;
	操控目标按键设定表[2] = _root.左键;
	操控目标按键设定表[3] = _root.右键;
};

_root.keyshow = function(keycode)
{
    var x键名 = "";
	if (keycode == 65)
	{
		x键名 = "A";//J键
	}
	else if (keycode == 66)
	{
		x键名 = "B";//K键
	}
	else if (keycode == 67)
	{
		x键名 = "C";
	}
	else if (keycode == 68)
	{
		x键名 = "D";
	}
	else if (keycode == 69)
	{
		x键名 = "E";
	}
	else if (keycode == 70)
	{
		x键名 = "F";
	}
	else if (keycode == 71)
	{
		x键名 = "G";
	}
	else if (keycode == 72)
	{
		x键名 = "H";
	}
	else if (keycode == 73)
	{
		x键名 = "I";
	}
	else if (keycode == 74)
	{
		x键名 = "J";
	}
	else if (keycode == 75)
	{
		x键名 = "K";
	}
	else if (keycode == 76)
	{
		x键名 = "L";
	}
	else if (keycode == 77)
	{
		x键名 = "M";
	}
	else if (keycode == 78)
	{
		x键名 = "N";
	}
	else if (keycode == 79)
	{
		x键名 = "O";
	}
	else if (keycode == 80)
	{
		x键名 = "P";
	}
	else if (keycode == 81)
	{
		x键名 = "Q";
	}
	else if (keycode == 82)
	{
		x键名 = "R";
	}
	else if (keycode == 83)
	{
		x键名 = "S";
	}
	else if (keycode == 84)
	{
		x键名 = "T";
	}
	else if (keycode == 85)
	{
		x键名 = "U";
	}
	else if (keycode == 86)
	{
		x键名 = "V";
	}
	else if (keycode == 87)
	{
		x键名 = "W";
	}
	else if (keycode == 88)
	{
		x键名 = "X";
	}
	else if (keycode == 89)
	{
		x键名 = "Y";
	}
	else if (keycode == 90)
	{
		x键名 = "Z";
	}
	else if (keycode == 48)
	{
		x键名 = "0";
	}
	else if (keycode == 49)
	{
		x键名 = "1";//键1，切换空手
	}
	else if (keycode == 50)
	{
		x键名 = "2";//键2，切换冷兵
	}
	else if (keycode == 51)
	{
		x键名 = "3";//键3，切换手枪
	}
	else if (keycode == 52)
	{
		x键名 = "4";//键4，切换长枪
	}
	else if (keycode == 53)
	{
		x键名 = "5";
	}
	else if (keycode == 54)
	{
		x键名 = "6";
	}
	else if (keycode == 55)
	{
		x键名 = "7";
	}
	else if (keycode == 56)
	{
		x键名 = "8";
	}
	else if (keycode == 57)
	{
		x键名 = "9";
	}
	else if (keycode == 96)
	{
		x键名 = "Num0";
	}
	else if (keycode == 97)
	{
		x键名 = "Num1";
	}
	else if (keycode == 98)
	{
		x键名 = "Num2";
	}
	else if (keycode == 99)
	{
		x键名 = "Num3";
	}
	else if (keycode == 100)
	{
		x键名 = "Num4";
	}
	else if (keycode == 101)
	{
		x键名 = "Num5";
	}
	else if (keycode == 102)
	{
		x键名 = "Num6";
	}
	else if (keycode == 103)
	{
		x键名 = "Num7";
	}
	else if (keycode == 104)
	{
		x键名 = "Num8";
	}
	else if (keycode == 105)
	{
		x键名 = "Num9";
	}
	else if (keycode == 106)
	{
		x键名 = "*";
	}
	else if (keycode == 107)
	{
		x键名 = "+";
	}
	else if (keycode == 108)
	{
		x键名 = "Enter";
	}
	else if (keycode == 109)
	{
		x键名 = "_";
	}
	else if (keycode == 110)
	{
		x键名 = ".";
	}
	else if (keycode == 111)
	{
		x键名 = "/";
	}
	else if (keycode == 144)
	{
		x键名 = "Num Lock";
	}
	else if (keycode == 112)
	{
		x键名 = "F1";
	}
	else if (keycode == 113)
	{
		x键名 = "F2";
	}
	else if (keycode == 114)
	{
		x键名 = "F3";
	}
	else if (keycode == 115)
	{
		x键名 = "F4";
	}
	else if (keycode == 116)
	{
		x键名 = "F5";
	}
	else if (keycode == 117)
	{
		x键名 = "F6";
	}
	else if (keycode == 118)
	{
		x键名 = "F7";
	}
	else if (keycode == 119)
	{
		x键名 = "F8";
	}
	else if (keycode == 120)
	{
		x键名 = "F9";
	}
	else if (keycode == 121)
	{
		x键名 = "F10";
	}
	else if (keycode == 122)
	{
		x键名 = "F11";
	}
	else if (keycode == 123)
	{
		x键名 = "F12";
	}
	else if (keycode == 8)
	{
		x键名 = "Backspace";
	}
	else if (keycode == 9)
	{
		x键名 = "Tab";
	}
	else if (keycode == 13)
	{
		x键名 = "Enter";
	}
	else if (keycode == 16)
	{
		x键名 = "Shift";
	}
	else if (keycode == 17)
	{
		x键名 = "Control";
	}
	else if (keycode == 12)
	{
		x键名 = "Clear";
	}
	else if (keycode == 18)
	{
		x键名 = "Alt";
	}
	else if (keycode == 20)
	{
		x键名 = "Caps Lock";
	}
	else if (keycode == 27)
	{
		x键名 = "Esc";
	}
	else if (keycode == 32)
	{
		x键名 = "Spacebar";
	}
	else if (keycode == 33)
	{
		x键名 = "Page Up";
	}
	else if (keycode == 34)
	{
		x键名 = "Page Down";
	}
	else if (keycode == 35)
	{
		x键名 = "End";
	}
	else if (keycode == 36)
	{
		x键名 = "Home";
	}
	else if (keycode == 37)
	{
		x键名 = "左方向键";
	}
	else if (keycode == 38)
	{
		x键名 = "上方向键";
	}
	else if (keycode == 39)
	{
		x键名 = "右方向键";
	}
	else if (keycode == 40)
	{
		x键名 = "下方向键";
	}
	else if (keycode == 45)
	{
		x键名 = "Insert";
	}
	else if (keycode == 46)
	{
		x键名 = "Delete";
	}
	else if (keycode == 47)
	{
		x键名 = "Help";
	}
	else if (keycode == 144)
	{
		x键名 = "Num Lock";
	}
	else if (keycode == 186)
	{
		x键名 = ";:";
	}
	else if (keycode == 187)
	{
		x键名 = "=+";
	}
	else if (keycode == 189)
	{
		x键名 = "-_";
	}
	else if (keycode == 191)
	{
		x键名 = "/?";
	}
	else if (keycode == 192)
	{
		x键名 = "`~";
	}
	else if (keycode == 219)
	{
		x键名 = "[{";
	}
	else if (keycode == 220)
	{
		x键名 = "\\|";
	}
	else if (keycode == 221)
	{
		x键名 = "]}";
	}
	else if (keycode == 222)
	{
		x键名 = "‘”";
	}
	return x键名;
};

_root.键值设定 = [[_root.获得翻译("上键"), "上键", 87], [_root.获得翻译("下键"), "下键", 83], [_root.获得翻译("左键"), "左键", 65], [_root.获得翻译("右键"), "右键", 68], [_root.获得翻译("功能键A"), "A键", 74], [_root.获得翻译("功能键B"), "B键", 75], [_root.获得翻译("功能键C"), "C键", 82], [_root.获得翻译("攻击模式-空手"), "键1", 49], [_root.获得翻译("攻击模式-兵器"), "键2", 50], [_root.获得翻译("攻击模式-手枪"), "键3", 51], [_root.获得翻译("攻击模式-长枪"), "键4", 52], [_root.获得翻译("攻击模式-手雷"), "键5", 53], [_root.获得翻译("快捷物品栏1"), "快捷物品栏键1", 55], [_root.获得翻译("快捷物品栏2"), "快捷物品栏键2", 56], [_root.获得翻译("快捷物品栏3"), "快捷物品栏键3", 57], [_root.获得翻译("快捷物品栏4"), "快捷物品栏键4", 48], [_root.获得翻译("快捷技能栏1"), "快捷技能栏键1", 32], [_root.获得翻译("快捷技能栏2"), "快捷技能栏键2", 85], [_root.获得翻译("快捷技能栏3"), "快捷技能栏键3", 73], [_root.获得翻译("快捷技能栏4"), "快捷技能栏键4", 79], [_root.获得翻译("快捷技能栏5"), "快捷技能栏键5", 80], [_root.获得翻译("快捷技能栏6"), "快捷技能栏键6", 76], [_root.获得翻译("快捷技能栏7"), "快捷技能栏键7", 72], [_root.获得翻译("快捷技能栏8"), "快捷技能栏键8", 71], [_root.获得翻译("快捷技能栏9"), "快捷技能栏键9", 67], [_root.获得翻译("快捷技能栏10"), "快捷技能栏键10", 66], [_root.获得翻译("快捷技能栏11"), "快捷技能栏键11", 78], [_root.获得翻译("快捷技能栏12"), "快捷技能栏键12", 77],  [_root.获得翻译("切换武器键"), "切换武器键", 47], [_root.获得翻译("互动键"), "互动键", 69], [_root.获得翻译("武器技能键"), "武器技能键", 70], [_root.获得翻译("飞行键"), "飞行键", 18],  [_root.获得翻译("武器变形键"), "武器变形键", 81], [_root.获得翻译("奔跑键"), "奔跑键", 16]];
_root.刷新键值设定();