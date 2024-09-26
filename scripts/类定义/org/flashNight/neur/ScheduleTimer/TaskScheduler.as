import org.flashNight.naki.DataStructures.*;
import org.flashNight.neur.ScheduleTimer.*;

class org.flashNight.neur.ScheduleTimer.TaskScheduler {
    public var tasks:Object;          // 存储任务的哈希表
    public var zeroFrameTasks:Object; // 存储零帧任务的哈希表
    public var taskIDCounter:Number;  // 任务 ID 计数器
    public var scheduleTimer:CerberusScheduler; // 调度器定时器

    private static var singleWheelSize:Number = 150;
    private static var multiLevelSecondsSize = 60;
    private static var multiLevelMinutesSize = 60;
    private static var precisionThreshold = 0.1;
    private static var frameRate = 30;

    // 构造函数
    public function TaskScheduler() {
        this.tasks = {};
        this.zeroFrameTasks = {};
        this.taskIDCounter = 0;
        this.singleWheelSize = 150;
        this.multiLevelSecondsSize = 60;
        this.multiLevelMinutesSize = 60;
        this.precisionThreshold = 0.1;
        this.frameRate = 30;
        this.millisecondsPerFrame = 1000 / this.frameRate;
        this.scheduleTimer = new CerberusScheduler(); // 确保初始化定时器
        this.scheduleTimer.initialize(this.singleWheelSize,
                                      this.multiLevelSecondsSize, 
                                      this.multiLevelMinutesSize, 
                                      this.frameRate, 
                                      this.precisionThreshold);
    }

    // 添加任务
    public function addTask(action:Function, intervalTime:Number, repeats:Number, ...params):Number {
        var taskID:Number = ++this.taskIDCounter;
        var intervalFrames:Number = Math.ceil(intervalTime * this.millisecondsPerFrame);
        
        var task:Task = {
            id: taskID,
            action: action,
            intervalFrames: intervalFrames,
            remainingRepeats: (repeats === undefined || repeats === null) ? 1 : repeats,
            params: params, // 存储额外参数
            execute: function() {
                // 执行任务时应用参数
                this.action.apply(null, this.params);
            },
            isComplete: function() {
                return this.remainingRepeats <= 0;
            }
        };
        
        if (intervalFrames <= 0) {
            this.zeroFrameTasks[taskID] = task;
        } else {
            task.node = this.scheduleTimer.evaluateAndInsertTask(taskID, intervalFrames);
            this.tasks[taskID] = task;
        }

        return taskID;
    }

    // 更新任务状态
    public function updateTasks():Void {
        // 处理定时任务
        var scheduledTasks = this.scheduleTimer.tick();

        if (scheduledTasks != null) {
            var node:TaskIDNode = scheduledTasks.getFirst();
            while (node != null) {
                var taskID = node.taskID;
                var task:Task = this.tasks[taskID];
                
                if (task) {
                    task.execute(); // 执行任务
                    this.handleTaskCompletion(task);
                }

                node = node.next;
            }
        }

        // 处理零帧任务
        for (var id in this.zeroFrameTasks) {
            var zeroFrameTask:Task = this.zeroFrameTasks[id];
            zeroFrameTask.execute();
            this.handleTaskCompletion(zeroFrameTask);
        }
    }

    // 处理任务完成逻辑
    private function handleTaskCompletion(task:Object):Void {
        task.remainingRepeats--;
        if (task.isComplete()) {
            delete this.tasks[task.id];
        } else {
            task.node = this.scheduleTimer.evaluateAndInsertTask(task.id, task.intervalFrames);
        }
    }

    // 移除任务
    public function removeTask(taskID:Number):Void {
        if (this.tasks[taskID]) {
            var task:Object = this.tasks[taskID];
            this.scheduleTimer.removeTaskByNode(task.node);
            delete this.tasks[taskID];
        } else if (this.zeroFrameTasks[taskID]) {
            delete this.zeroFrameTasks[taskID];
        }
    }

    // 添加单次任务
    public function addSingleTask(action:Function, intervalTime:Number):Number {
        if (intervalTime <= 0) {
            action.apply(null);
            return null; // 任务已立即执行
        }
        return this.addTask(action, intervalTime, 1);
    }

    // 添加循环任务
    public function addLoopTask(action:Function, intervalTime:Number):Number {
        return this.addTask(action, intervalTime, true);
    }

    // 添加或更新任务
    public function addOrUpdateTask(obj:Object, tagName:String, action:Function, intervalTime:Number):Number {
        if (!obj.taskIdentifiers) obj.taskIdentifiers = {};
        if (!obj.taskIdentifiers[tagName]) {
            obj.taskIdentifiers[tagName] = ++this.taskIDCounter;
        }

        var taskID:Number = obj.taskIdentifiers[tagName];
        return this.addTask(action, intervalTime, this.tasks[taskID] ? this.tasks[taskID].remainingRepeats : 1);
    }
}
