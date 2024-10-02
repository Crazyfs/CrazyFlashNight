import org.flashNight.naki.DataStructures.TaskIDNode;

class org.flashNight.naki.DataStructures.Task {
    public var id:String;
    public var action:Function;
    public var intervalFrames:Number;
    public var repeats:Number;            // 初始重复次数
    public var remainingRepeats:Number;   // 剩余重复次数
    public var params:Array;
    public var node:TaskIDNode;
    public var isInfinite:Boolean;

    public function Task() {
        // 空构造函数，方便对象池的复用
    }

    // 初始化方法，用于对象池复用
    public function initialize(id:String, action:Function, intervalFrames:Number, repeats:Number, params:Array):Void {
        this.id = id;
        this.action = action;
        this.intervalFrames = intervalFrames;
        this.repeats = repeats; // 保存初始重复次数

        if (repeats === 0) {
            this.remainingRepeats = 0;
            this.isInfinite = true;
        } else {
            this.remainingRepeats = (repeats === undefined || repeats === null || isNaN(repeats)) ? 1 : repeats;
            this.isInfinite = false;
        }
        this.params = (params != null && params instanceof Array) ? params : [];
        this.node = null;
    }

    // 执行任务动作并更新状态
    public function update():Void {
        if (this.isInfinite || this.remainingRepeats > 0) {
            this.execute();

            if (!this.isInfinite && this.remainingRepeats > 0) {
                this.remainingRepeats -= 1; // 减少剩余重复次数
            }

            trace("Task " + this.id + " executed. Remaining repeats: " + (this.isInfinite ? "Infinite" : this.remainingRepeats));

            // 如果任务需要重复执行，设置下一次执行的等待帧数
            // 由 Scheduler 重新调度任务
        }
    }

    // 执行任务动作
    public function execute():Void {
        if (this.action) {
            try {
                this.action.apply(this, this.params); // 确保 this 指向 Task 实例
            } catch (error:Error) {
                trace("Task " + this.id + " execution failed: " + error.message);
                throw error; // 将异常抛出，交由 TaskManager 处理
            }
        }
    }

    // 检查任务是否完成
    public function isComplete():Boolean {
        return (!this.isInfinite && this.remainingRepeats <= 0);
    }

    // 清理引用，避免内存泄漏
    public function reset():Void {
        this.id = null;
        this.action = null;
        this.intervalFrames = 0;
        this.repeats = 0;
        this.remainingRepeats = 0;
        this.params = null;
        this.node = null;
        this.isInfinite = false;
    }

}
