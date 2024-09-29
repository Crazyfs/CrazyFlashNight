import org.flashNight.naki.DataStructures.*;

class org.flashNight.naki.DataStructures.Task {
    public var id:String;                  // 任务 ID，字符串类型
    public var action:Function;            // 任务执行的动作
    public var intervalFrames:Number;      // 执行间隔帧数
    public var remainingRepeats:Number;    // 剩余重复次数，0表示无限循环
    public var params:Array;               // 动作参数
    public var waitFrames:Number;          // 等待执行的帧数
    public var node:TaskIDNode;            // 任务在调度器中的节点引用
    public var isInfinite:Boolean;         // 是否为无限循环任务

    // 构造函数
    public function Task(id:String, action:Function, intervalFrames:Number, repeats:Number, params:Array) {
        this.id = id; // 使用字符串类型的任务ID
        this.action = action;
        this.intervalFrames = intervalFrames;
        // repeats=0 表示无限循环
        if (repeats === 0){
            this.remainingRepeats = 0;
            this.isInfinite = true;
        } else {
            this.remainingRepeats = (repeats === undefined || repeats === null || isNaN(repeats)) ? 1 : repeats;
            this.isInfinite = false;
        }
        this.params = params;
        this.waitFrames = intervalFrames; // 初始等待帧数
        this.node = null; // 初始化节点引用
    }

    // 执行任务动作并更新状态
    public function update():Void {
        if (this.isInfinite || this.remainingRepeats > 0) { // 0 表示无限循环
            this.execute();
            trace("Task " + this.id + " executed. Remaining repeats: " + this.remainingRepeats);
            if (!this.isInfinite && this.remainingRepeats > 0) {
                this.remainingRepeats -= 1; // 减少剩余重复次数
            }
        }
    }

    // 执行任务动作
    public function execute():Void {
        if (this.action) {
            this.action.apply(null, this.params); // 不绑定对象，直接调用
        }
    }

    // 检查任务是否完成
    public function isComplete():Boolean {
        return (!this.isInfinite && this.remainingRepeats <= 0);
    }

    // 清理引用，避免内存泄漏
    public function destroy():Void {
        this.action = null;
        this.params = null;
        this.node = null;
    }
}
