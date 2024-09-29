import org.flashNight.neur.ScheduleTimer.*;
import org.flashNight.naki.DataStructures.*;

class org.flashNight.neur.ScheduleTimer.TaskManager {
    private var tasks:Object;                // 任务哈希表，存储所有任务
    private var zeroFrameTasks:Object;       // 零帧任务哈希表，存储需要立即执行的任务
    private var taskIDCounter:Number;        // 任务 ID 计数器
    private var framesPerMillisecond:Number; // 每毫秒的帧数
    private var scheduler:CerberusScheduler; // 调度器实例，地狱三头犬调度器

    // 构造函数，允许通过外部传入帧率配置和调度器实例
    public function TaskManager(frameRate:Number, scheduler:CerberusScheduler) {
        this.tasks = {};
        this.zeroFrameTasks = {};
        this.taskIDCounter = 0;
        this.framesPerMillisecond = frameRate / 1000;  // 帧率转化为每毫秒的帧数
        this.scheduler = scheduler; // 引入地狱三头犬调度器实例
    }

    // 创建任务，使用时间间隔（秒）并转换为帧
    public function createTask(action:Function, intervalTime:Number, repeats:Number, params:Array):String {
        var taskID:String = String(++this.taskIDCounter);  // 确保任务ID为String类型
        var intervalFrames:Number = Math.ceil(intervalTime * this.framesPerMillisecond * 1000);

        var task:Task = new Task(taskID, action, intervalFrames, repeats, params); // 创建任务

        // 区分零帧任务和延迟任务
        if (intervalFrames <= 0) {
            this.zeroFrameTasks[taskID] = task;
        } else {
            task.node = this.scheduler.evaluateAndInsertTask(taskID, intervalFrames); // 插入任务
            this.tasks[taskID] = task;
        }

        trace("Task " + taskID + " created. Interval frames: " + intervalFrames + ", repeats: " + repeats);
        return taskID;
    }

    // 更新任务，支持更新动作、间隔时间和参数
    public function updateTask(taskID:String, action:Function, intervalTime:Number, params:Array):Void {
        var task:Task = this.getTask(taskID);
        if (task) {
            task.action = action;
            task.intervalFrames = Math.ceil(intervalTime * this.framesPerMillisecond * 1000);
            task.params = params;

            trace("Task " + taskID + " updated. New interval frames: " + task.intervalFrames);

            // 更新调度或零帧任务状态
            if (task.intervalFrames <= 0) {
                this.moveTaskToZeroFrame(taskID, task);
            } else {
                this.moveTaskToScheduler(taskID, task);
            }
        } else {
            trace("Update failed: Task " + taskID + " not found.");
        }
    }

    // 删除任务，通过任务ID
    public function removeTask(taskID:String):Void {
        var task:Task = this.getTask(taskID);
        if (task) {
            if (task.node != null) {
                this.scheduler.removeTaskByNode(task.node); // 从调度器中移除任务
                trace("Task " + taskID + " removed from scheduler.");
            }
            task.destroy(); // 清理任务
            delete this.tasks[taskID]; // 从任务表中移除
            delete this.zeroFrameTasks[taskID]; // 从零帧任务表中移除（如果存在）
            trace("Task " + taskID + " destroyed and removed from TaskManager.");
        } else {
            trace("Remove failed: Task " + taskID + " not found.");
        }
    }

    // 获取任务，通过任务ID
    public function getTask(taskID:String):Task {
        return this.tasks[taskID] || this.zeroFrameTasks[taskID];
    }

    // 处理并执行所有到期任务
    public function processTasks():Void {
        // 处理零帧任务
        this.processZeroFrameTasks();

        // 调用调度器的 tick 方法获取到期任务
        var expiredTasks:TaskIDLinkedList = this.scheduler.tick();
        if (expiredTasks != null) {
            this.processScheduledTasks(expiredTasks);
        }
    }

    // 执行任务，并处理错误
    private function executeTask(task:Task):Void {
        try {
            task.update(); // 调用 update() 方法，执行任务并更新状态
        } catch (error:Error) {
            trace("任务执行失败，ID：" + task.id + "，错误信息：" + error.message);
        }
    }

    // 延迟任务执行
    public function delayTask(taskID:String, delayTime:Number):Boolean {
        var task:Task = this.getTask(taskID);
        if (task && task.intervalFrames > 0) { // 仅支持延迟调度任务
            var delayFrames:Number = Math.ceil(delayTime * this.framesPerMillisecond * 1000);
            task.waitFrames += delayFrames;
            this.scheduler.rescheduleTaskByNode(task.node, task.waitFrames);
            trace("Task " + taskID + " delayed by " + delayFrames + " frames.");
            return true;
        }
        trace("Delay failed: Task " + taskID + " not found or is a zero-frame task.");
        return false;
    }

    // 处理零帧任务
    private function processZeroFrameTasks():Void {
        for (var taskID in this.zeroFrameTasks) {
            var task:Task = this.zeroFrameTasks[taskID];
            this.executeTask(task);

            // 确保零帧任务在执行后被移除
            if (task.isComplete()) {
                delete this.zeroFrameTasks[taskID];
                trace("Zero-frame Task " + taskID + " executed and removed.");
            } else {
                // 如果任务是无限循环（repeats=0），需要重新加入零帧任务队列
                trace("Zero-frame Task " + taskID + " executed and remains for further execution.");
            }
        }
    }

    // 处理调度到期的任务
    private function processScheduledTasks(expiredTasks:TaskIDLinkedList):Void {
        var node:TaskIDNode = expiredTasks.getFirst();
        while (node != null) {
            var taskID:String = node.taskID;
            var task:Task = this.tasks[taskID];
            if (task) {
                this.executeTask(task);

                // 检查是否需要重复执行或删除
                if (task.isComplete()) {
                    this.removeTask(taskID);
                    trace("Scheduled Task " + taskID + " executed and removed.");
                } else {
                    task.node = this.scheduler.evaluateAndInsertTask(taskID, task.intervalFrames);
                    trace("Scheduled Task " + taskID + " rescheduled.");
                }
            }
            node = node.next;
        }
    }

    // 将任务移至零帧任务队列
    private function moveTaskToZeroFrame(taskID:String, task:Task):Void {
        if (this.tasks[taskID]) {
            this.scheduler.removeTaskByNode(task.node);
            delete this.tasks[taskID];
            this.zeroFrameTasks[taskID] = task;
            trace("Task " + taskID + " moved to zero-frame tasks.");
        }
    }

    // 将任务移至调度器
    private function moveTaskToScheduler(taskID:String, task:Task):Void {
        if (this.zeroFrameTasks[taskID]) {
            delete this.zeroFrameTasks[taskID];
            task.node = this.scheduler.evaluateAndInsertTask(taskID, task.intervalFrames);
            this.tasks[taskID] = task;
            trace("Task " + taskID + " moved to scheduler.");
        } else {
            this.scheduler.rescheduleTaskByNode(task.node, task.intervalFrames);
            trace("Task " + taskID + " rescheduled in scheduler.");
        }
    }
}
