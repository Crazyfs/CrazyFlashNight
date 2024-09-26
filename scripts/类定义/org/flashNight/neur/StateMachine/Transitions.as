﻿import org.flashNight.neur.StateMachine.FSM_Status;

class org.flashNight.neur.StateMachine.Transitions {
    private var status:FSM_Status;
    private var lists:Object;

    public function Transitions(_status:FSM_Status){
        this.status = _status;
        this.lists = new Object();
    }

    public function AddTransition(current:String,target:String,func:Function):Void{
        var list = this.lists[current];
        if(!list){
            list = new Array();
            this.lists[current] = list;
        }
        list.push({
            target:target,
            active:true,
            func:func
        });
    }

    public function Transit(current:String):String{
        var list = this.lists[current];
        //按顺序依次执行过渡函数
        for(var i:Number = 0; i < list.length; i++){
            var transition = list[i];
            if(!transition.active) continue;
            if(transition.func.apply(status) == true){
                return transition.target;
            }
        }
        return null;
    }
}
