﻿import org.flashNight.neur.StateMachine.Status;
import org.flashNight.neur.StateMachine.Machine;
import org.flashNight.neur.StateMachine.Transitions;

class org.flashNight.neur.StateMachine.FSM_Status implements Status {
	public var name:String; // 状态名称
    public var superMachine:Machine; // 上级状态机
    public var active:Boolean; // 该状态是否激活
    public var data:Object; // 数据黑板
    public var transitions:Transitions; // 过渡线

    public function onAction():Void{
    }
    public function onEnter():Void{
    };
    public function onExit():Void{
    };

    public function FSM_Status(_onAction:Function, _onEnter:Function, _onExit:Function){
        this.active = true;
        if(_onAction) this.onAction = _onAction;
        if(_onEnter) this.onEnter = _onEnter;
        if(_onExit) this.onExit = _onExit;
        this.superMachine = null;
    }

    public function isRootMachine():Boolean{
        return !this.superMachine;
    }

    public function OnInit():Void{
        if (!isRootMachine) return;
        this.onEnter();
    }
}
