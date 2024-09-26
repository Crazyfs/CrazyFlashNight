﻿_root.LoadPCTasks = function()
{
	var _loc2_ = SharedObject.getLocal("crazyflasher7_saves");
	_root.tasks_to_do = _loc2_.data.tasks_to_do;
	_root.tasks_finished = _loc2_.data.tasks_finished;
	_root.task_chains_progress = _loc2_.data.task_chains_progress;
	_root.task_history = _loc2_.data.task_history;
	UpdateTaskProgress();
	//检查并删除undefined任务
	for (var index in tasks_to_do){
		if(_root.getTaskData(tasks_to_do[index].id).title == undefined){
			_root.DeleteTask(index);
		}
	}
}

_root.SavePCTasks = function()
{
	var _loc2_ = SharedObject.getLocal("crazyflasher7_saves");
	_loc2_.data.tasks_to_do = _root.tasks_to_do;
	_loc2_.data.tasks_finished = _root.tasks_finished;
	_loc2_.data.task_chains_progress = _root.task_chains_progress;
	_loc2_.data.task_history = _root.task_history;
	_loc2_.flush();
	UpdateTaskProgress();
}

_root.NPCTaskCheck = function(npcname)
{
	for (var index in tasks_to_do)
	{
		var _loc4_ = _root.getTaskData(tasks_to_do[index].id).finish_npc;
		if (_loc4_ == npcname && taskFinished(index))
		{
			return {result:"完成任务", id:index};
		}
	}
	for (var i = 0; i < _root.tasks_of_npc[npcname].length; i++)
	{
		if (taskAvailable(_root.tasks_of_npc[npcname][i]))
		{
			for (var j = 0; j < tasks_to_do.length; j++)
			{
				if (tasks_to_do[j].id == _root.tasks_of_npc[npcname][i])
				{
					return {result:"路过"};
				}
			}
			return {result:"接受任务", id:_root.tasks_of_npc[npcname][i]};
		}
	}
	return {result:"路过"};
}

_root.GetTask = function(id)
{
	var i = 0;
	while (i < tasks_to_do.length)
	{
		if (tasks_to_do[i].id == id)
		{
			_root.发布消息("无法重复接受任务！");
			return false;
		}
		i += 1;
	}
	AddTask(id);
	_root.SetDialogue(_root.getTaskText(_root.getTaskData(id).get_conversation));
	_root.任务栏界面.排列任务图标();
	_root.弹出公告界面.弹出新任务(id);
}

_root.taskFinished = function(index)
{
	var requirements = tasks_to_do[index].requirements;
	if (requirements.stages.length != 0)
	{
		_root.任务完成提示._visible = 0;
		return false;
	}
	for (var _loc4_ in requirements.items)
	{
		if (!_root.物品栏是否有(requirements.items[_loc4_].name, requirements.items[_loc4_].count))
		{
			_root.任务完成提示._visible = 0;
			return false;
		}
	}
	_root.任务完成提示._visible = 1;
	return true;
}

_root.taskAvailable = function(index)
{
	if (tasks_finished[String(index)] > 0 && tasks_finished[String(index)] != undefined)
	{
		return false;
	}
	var i = 0;
	while (i < tasks_to_do.length)
	{
		if (tasks_to_do[i].id == index)
		{
			return false;
		}
		i += 1;
	}
	var _loc4_ = 0;
	var _loc5_ = _root.getTaskData(index).get_requirements;
	while (_loc4_ < _loc5_.length)
	{
		if (_loc5_[_loc4_].__proto__ == Number.prototype)
		{
			if (tasks_finished[String(_loc5_[_loc4_])] < 1 || tasks_finished[String(_loc5_[_loc4_])] == undefined)
			{
				return false;
			}
		}
		else
		{
			var _loc6_ = _loc5_[_loc4_].split("#");
			if (!_root.物品栏是否有(_loc6_[0], Number(_loc6_[1])))
			{
				return false;
			}
		}
		_loc4_ += 1;
	}
	return true;
}

_root.FinishTask = function(index)
{
	var TaskData = _root.getTaskData(tasks_to_do[index].id);
	var rewards = TaskData.rewards;
	var 奖励格数 = 0;
	for(var i = 0; i < rewards.length; i++)
	{
		rewards[i] = rewards[i].split("#");
		var item = _root.getItemData(rewards[i][0]);
		if (!item.use || item.use != "货币")
		{
			if (item.type == "消耗品" || item.type == "防具" || item.type == "武器")
			{
				奖励格数 += 1;
			}
			else
			{
				if (Number(rewards[i][1]))
				{
					奖励格数 += Number(rewards[i][1]);
				}
				else
				{
					奖励格数 += 1;
				}
			}
		}
	}
	if (_root.物品栏有空位数() < 奖励格数)
	{
		_root.发布消息("背包无法装下奖励，无法交付任务！请清理背包后重试！");
		return false;
	}
	_root.任务奖励提示界面.奖励品 = [];
	for(var i = 0; i < rewards.length; i++)
	{
		var showNum = Number(rewards[i][1]);
		switch (rewards[i][0])
		{
			case "金币" :
				var goldNum = Number(rewards[i][1]);
				if (_root.isChallengeMode() == true)
				{
					goldNum = Math.floor(goldNum * 0.5);
				}
				_root.金钱 += goldNum;
				if (_root.isEasyMode() == true)
				{
					_root.虚拟币 += Math.floor(goldNum * 0.5);
					_root.任务奖励提示界面.奖励品.push(["K点", Math.floor(goldNum * 0.5)]);
				}
				showNum = goldNum;
				break;
			case "K点" :
				var kdotNum = Number(rewards[i][1]);
				if (_root.isChallengeMode() == true)
				{
					kdotNum = Math.floor(kdotNum * 0.1);
				}
				_root.虚拟币 += kdotNum;
				showNum = kdotNum;
				break;
			case "经验值" :
				_root.经验值 += Number(rewards[i][1]);
				_root.主角是否升级(_root.等级,_root.经验值);
				break;
			case "技能点" :
				_root.技能点数 += Number(rewards[i][1]);
				break;
			default :
				_root.物品栏添加(rewards[i][0],Number(rewards[i][1]),0);
		}
		_root.任务奖励提示界面.奖励品.push([rewards[i][0], showNum]);
	}
	_root.任务奖励提示界面.刷新();
	//消耗任务物品
	var needItems = tasks_to_do[index].requirements;
	for (var needi in needItems.items)
	{
		needItem = needItems.items[needi].name;
		needItemCount = needItems.items[needi].count;
		_root.物品栏删除指定物品(needItem,needItemCount);
	}
	_root.SetDialogue(_root.getTaskText(TaskData.finish_conversation));
	UpdateTaskProgress(tasks_to_do[index].id);
	tasks_to_do.splice(index,1);
	var _loc7_ = -1;
	var _loc8_ = 0;
	while (_loc8_ < task_in_chains_by_sequence[TaskData.chain[0]].length)
	{
		if (task_chains[TaskData.chain[0]][String(task_in_chains_by_sequence[TaskData.chain[0]][_loc8_])] == TaskData.id)
		{
			_loc7_ = _loc8_;
			break;
		}
		_loc8_ += 1;
	}
	var _loc9_ = task_in_chains_by_sequence[TaskData.chain[0]][_loc8_ + 1] != undefined && _loc7_ != -1;
	var _loc10_ = taskAvailable(task_chains[TaskData.chain[0]][String(task_in_chains_by_sequence[TaskData.chain[0]][_loc8_ + 1])]);
	if (_loc9_ && _loc10_)
	{
		_root.GetTask(task_chains[TaskData.chain[0]][String(task_in_chains_by_sequence[TaskData.chain[0]][_loc8_ + 1])]);
	}
	return true;
}

_root.FinishStage = function(name, difficulty)
{
	switch (difficulty)
	{
		case "地狱" :
			FinishStage(name,"修罗");
			break;
		case "修罗" :
			FinishStage(name,"冒险");
			break;
		case "冒险" :
			FinishStage(name,"简单");
			break;
		case "简单" :
			break;
	}
	for (var i in tasks_to_do)
	{
		var _loc4_ = tasks_to_do[i].requirements.stages;
		var j = 0;
		var len = _loc4_.length;
		while (j < len)
		{
			if (_loc4_[j].name == name && _loc4_[j].difficulty == difficulty)
			{
				tasks_to_do[i].requirements.stages.splice(j,1);
				len -= 1;
			}
			j += 1;
		}
	}
	UpdateTaskProgress();
}

_root.AddTask = function(id)
{
	for (var i = 0; i < tasks_to_do.length; i++)
	{
		if (tasks_to_do[i].id == id)
		{
			_root.发布消息("无法重复接受任务！");
			return false;
		}
	}
	var _loc3_ = _root.getTaskData(id).finish_requirements;
	var _loc4_ = {};
	var _loc5_ = [];
	var _loc6_ = [];
	var _loc7_ = {};
	var _loc8_ = 0;
	for (_loc8_ in _loc3_)
	{
		var _loc9_ = _loc3_[_loc8_].split("#");
		if (isNaN(Number(_loc9_[1])))
		{
			_loc7_ = {};
			_loc7_.name = _loc9_[0];
			_loc7_.difficulty = _loc9_[1];
			_loc6_.push(_loc7_);
		}
		else
		{
			_loc7_ = {};
			_loc7_.name = _loc9_[0];
			_loc7_.count = _loc9_[1];
			_loc5_.push(_loc7_);
		}
	}
	_loc4_.items = _loc5_;
	_loc4_.stages = _loc6_;
	var _loc10_ = {};
	_loc10_.id = id;
	_loc10_.requirements = _loc4_;
	tasks_to_do.push(_loc10_);
}

_root.DeleteTask = function(index)
{
	if (_root.getTaskData(tasks_to_do[index].id).chain[0] == "主线")
	{
		_root.发布消息("无法删除主线任务！");
		return false;
	}
	tasks_to_do.splice(index,1);
	_root.发布消息("删除任务成功！");
	return true;
}

_root.UpdateTaskProgress = function(id)
{
	if (id != undefined)
	{
		if (tasks_finished[String(id)] == undefined)
		{
			tasks_finished[String(id)] = 0;
		}
		var _loc3_ = _root.getTaskData(id).chain;
		if (task_chains_progress[_loc3_[0]] < Number(_loc3_[1]) || task_chains_progress[_loc3_[0]] == undefined)
		{
			task_chains_progress[_loc3_[0]] = Number(_loc3_[1]);
		}
		tasks_finished[String(id)] += 1;
		task_history.push(id);
	}
	if (task_chains_progress.主线 == undefined)
	{
		task_chains_progress.主线 = 0;
	}
	_root.主线任务进度 = task_chains_progress.主线;
	if (_root.主线任务进度 > 13)
	{
		_root.后勤战备箱按钮._visible = true;
	}
	_root.任务栏界面.排列任务图标();
}

_root.计算难度等级 = function(等级描述)
{
	if (等级描述 === "简单") return 1;
	if (等级描述 === "冒险") return 1.5;
	if (等级描述 === "修罗") return 2;
	if (等级描述 === "地狱") return 2.5;
	return 1;
}

_root.点击npc后检测任务 = function(npc名字)
{
	var ret = NPCTaskCheck(npc名字);
	switch (ret.result)
	{
		case "完成任务" :
			FinishTask(ret.id);
			break;
		case "接受任务" :
			GetTask(ret.id);
			break;
		case "路过" :
			break;
	}
	return ret.result;
}

_root.是否达成任务检测 = function()
{
	for (var i in tasks_to_do)
	{
		if (taskFinished(i))
		{
			return true;
		}
	}
	return false;
}

_root.完成任务提示检测 = function()
{
	是否达成任务检测();
}

_root.打印任务进度 = function(页数)
{
	if (_root.任务栏界面.mc事件日志.mytext._x != undefined)
	{
		_root.任务栏界面.mc事件日志.mytext.text = "";
		_root.任务栏界面.新任务text.text = "";
		var _loc3_ = (页数 - 1) * 事件日志每页条数;
		while (_loc3_ < task_history.length && _loc3_ < 页数 * 事件日志每页条数)
		{
			_root.任务栏界面.mc事件日志.mytext.text = _root.任务栏界面.mc事件日志.mytext.text + "\r" + _root.getTaskText(_root.getTaskData(task_history[_loc3_]).title) + _root.获得翻译(" 完成");
			_loc3_ += 1;
		}
	}
}

_root.tasks_to_do = [];
_root.tasks_finished = {};
_root.task_chains_progress = {};
_root.task_history = [];
_root.可同时接的任务数 = 10;
_root.事件日志每页条数 = 10;
_root.主线任务进度 = 0;