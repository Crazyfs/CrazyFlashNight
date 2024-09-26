import org.flashNight.naki.DataStructures.*;

class org.flashNight.naki.DataStructures.Task {
    public var id:Number;                  // 任务 ID
    public var action:Function;            // 任务执行的动作
    public var intervalFrames:Number;      // 执行间隔帧数
    public var remainingRepeats:Number;    // 剩余重复次数
    public var params:Array;               // 动作参数
    public var waitFrames:Number;          // 等待执行的帧数
    public var node:TaskIDNode;                // 任务在调度器中的节点引用

    // 构造函数
    function Task(id:Number, action:Function, intervalFrames:Number, repeats:Number, params:Array) {
        this.id = id;
        this.action = action;
        this.intervalFrames = intervalFrames;
        this.remainingRepeats = (repeats == undefined || repeats == null) ? 1 : repeats;
        this.params = params;
        this.waitFrames = intervalFrames; // 初始等待帧数
        this.node = null; // 初始化节点引用
    }

    // 执行任务动作
    public function execute() {
        if (this.action) {
            this.action.apply(this, this.params); // 绑定对象到任务自身
        }
    }

    // 更新任务状态
    public function update() {
        if (this.remainingRepeats > 0 || this.remainingRepeats === true) {
            this.execute();
            this.waitFrames = this.intervalFrames; // 重置等待帧数

            if (this.remainingRepeats !== true) {
                this.remainingRepeats -= 1; // 减少剩余重复次数
            }
        }
    }

    // 检查任务是否完成
    public function isComplete():Boolean {
        return this.remainingRepeats <= 0 && this.remainingRepeats !== true;
    }
}
