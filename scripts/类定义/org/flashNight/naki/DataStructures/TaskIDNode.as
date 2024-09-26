﻿import org.flashNight.naki.DataStructures.*;

class org.flashNight.naki.DataStructures.TaskIDNode extends TaskNode {
    public var prev:TaskIDNode = null;
    public var next:TaskIDNode = null;
    public var slotIndex:Number = -1;
    public var list:TaskIDLinkedList = null;  // Reference to the parent linked list

    public function TaskIDNode(taskID:String) {
        super(taskID);
    }

    public function reset(newTaskID:String):Void {
        if (newTaskID != null) {
            this.taskID = newTaskID;  // Reset task ID if provided
        }
        this.prev = null;
        this.next = null;
        this.slotIndex = -1;
        this.list = null;  // Clear reference to the list
    }

    public function equals(other:TaskIDNode):Boolean {
        return this.taskID == other.taskID;
    }

    public function toString():String {
        var taskIDStr:String = this.taskID != null ? this.taskID : "null";
        var prevTaskIDStr:String = this.prev != null ? this.prev.taskID : "PPPnull";
        var nextTaskIDStr:String = this.next != null ? this.next.taskID : "NNNnull";
        var listStr:String = this.list != null ? "ListRef" : "NoListRef";
        
        return "TaskIDNode [taskID=" + taskIDStr + ", prev=" + prevTaskIDStr + ", next=" + nextTaskIDStr + ", list=" + listStr + "]";
    }
}
