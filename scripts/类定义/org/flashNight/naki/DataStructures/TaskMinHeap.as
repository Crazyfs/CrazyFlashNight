/*
# TaskMinHeap 类

## 简介

`TaskMinHeap` 是一个最小堆实现，用于管理基于任务优先级的调度。该类允许你插入、查找、更新和删除任务，并且能够高效地获取优先级最低的任务。通过维护一个堆结构，`TaskMinHeap` 保证了在 `O(log n)` 时间复杂度内完成插入和删除操作，是实现任务调度、优先队列等场景的理想选择。

## 特性

- **插入任务**：可以根据任务 ID 和优先级插入新任务。
- **删除任务**：根据任务 ID 从堆中移除特定任务。
- **更新优先级**：动态调整任务的优先级，并维护堆的性质。
- **获取最小任务**：快速获取并移除优先级最低的任务。
- **查看堆顶任务**：无需移除即可查看优先级最低的任务。
- **任务查找**：可以根据任务 ID 快速查找到对应的任务节点。

## 使用方法

### 1. 创建实例

首先，导入 `TaskMinHeap` 类并创建一个实例。

```actionscript
import org.flashNight.naki.DataStructures.TaskMinHeap;

var taskHeap:TaskMinHeap = new TaskMinHeap();
```

### 2. 插入任务

使用 `insert` 方法插入一个新任务，需要指定任务 ID 和优先级。

```actionscript
taskHeap.insert("task1", 10);
taskHeap.insert("task2", 5);
```

### 3. 获取并执行优先级最低的任务

使用 `extractMin` 方法获取并移除优先级最低的任务。

```actionscript
var minTask:HeapNode = taskHeap.extractMin();
trace("Executing task: " + minTask.taskID + " with priority: " + minTask.priority);
```

### 4. 更新任务的优先级

使用 `update` 方法更新某个任务的优先级。

```actionscript
taskHeap.update("task1", 3);
```

### 5. 删除特定任务

使用 `remove` 方法根据任务 ID 删除任务。

```actionscript
taskHeap.remove("task2");
```

### 6. 查看堆顶任务

使用 `peekMin` 方法查看当前堆顶任务（优先级最低），但不移除它。

```actionscript
var topTask:HeapNode = taskHeap.peekMin();
trace("Top task: " + topTask.taskID + " with priority: " + topTask.priority);
```

### 7. 查找任务

使用 `find` 方法根据任务 ID 查找任务节点。

```actionscript
var task:HeapNode = taskHeap.find("task1");
if (task != null) {
    trace("Found task: " + task.taskID + " with priority: " + task.priority);
} else {
    trace("Task not found.");
}
```

## 代码结构

- `heap:Array`：存储堆中节点的数组。
- `taskMap:Object`：用于快速查找任务的映射。
- `insert(taskID:String, priority:Number):Void`：插入新任务。
- `remove(taskID:String):Void`：根据任务 ID 移除特定任务。
- `update(taskID:String, newPriority:Number):Void`：更新任务的优先级。
- `extractMin():HeapNode`：获取并移除优先级最低的任务。
- `peekMin():HeapNode`：查看优先级最低的任务，但不移除它。
- `find(taskID:String):HeapNode`：根据任务 ID 查找任务节点。
- `bubbleUp(index:Number):Void`：上浮操作，维护堆的性质。
- `bubbleDown(index:Number):Void`：下沉操作，维护堆的性质。
- `swap(index1:Number, index2:Number):Void`：交换堆中两个节点的位置。
- `rebalance(node:HeapNode):Void`：重新平衡堆。
- `findIndexByTaskID(taskID:String):Number`：查找任务在堆中的索引。

## 注意事项

1. **`trace` 调试**：在代码中，所有的 `trace` 语句默认是被注释掉的。可以在需要调试时解除注释以查看详细的运行时信息。
2. **索引更新**：堆的上浮和下沉操作会自动维护节点的索引，确保堆的性质不被破坏。
3. **优先级更新**：在使用 `update` 方法更新任务优先级时，堆会自动重新平衡，以确保最小堆的结构。

## 扩展

此类可以作为基础数据结构，扩展用于实现更多复杂的任务调度系统，如带有定时器的优先队列或多任务系统中的任务管理模块。

*/

import org.flashNight.naki.DataStructures.*;

class org.flashNight.naki.DataStructures.TaskMinHeap {
    private var heap:Array;       // 用于存储堆中节点的数组
    private var taskMap:Object;   // 用于快速查找任务的映射

    // 构造函数，初始化堆和任务映射
    public function TaskMinHeap() {
        this.heap = [];
        this.taskMap = {};
    }

    // 插入新任务到堆中
    public function insert(taskID:String, priority:Number):Void {
        var node:HeapNode = new HeapNode(taskID, priority);
        this.heap.push(node);  // 将新节点添加到堆末尾
        this.taskMap[taskID] = node;  // 将任务映射到新节点
        this.bubbleUp(this.heap.length - 1);  // 维护堆的性质
    }

    // 根据 taskID 查找任务
    public function find(taskID:String):HeapNode {
        return this.taskMap[taskID];
    }

    // 查看堆顶任务
    public function peekMin():HeapNode {
        if (this.heap.length == 0) {
            return null;
        }
        return this.heap[0];
    }

    // 根据 taskID 移除特定任务
    public function remove(taskID:String):Void {
        var node:HeapNode = this.taskMap[taskID];
        if (node == null) {
            // trace("Task not found: " + taskID);
            return;  // 如果任务不存在，直接返回
        }

        var index:Number = this.findIndexByTaskID(taskID);  // 查找任务在堆中的索引
        if (index == -1) {
            // trace("Node not found in heap for taskID: " + taskID);
            return;  // 如果找不到节点，直接返回
        }
        
        // trace("Removing task: " + taskID + " at index: " + index);

        // 如果要删除的节点正好是最后一个节点
        if (index == this.heap.length - 1) {
            // trace("Task is the last node in the heap, removing directly.");
            this.heap.pop();  // 直接移除最后一个节点
        } else {
            var lastNode:HeapNode = HeapNode(this.heap.pop());  // 弹出最后一个节点
            // trace("Replacing node at index: " + index + " with last node: " + lastNode.taskID);
            this.heap[index] = lastNode;  // 用最后一个节点替换要删除的节点位置
            this.taskMap[lastNode.taskID] = lastNode;
            
            // trace("Last node priority: " + lastNode.priority + ", removed node priority: " + node.priority);

            // 如果最后一个节点的优先级比要删除的节点低，进行上浮；否则，下沉
            if (lastNode.priority < node.priority) {
                // trace("Last node has lower priority, bubbling up.");
                this.bubbleUp(index);
            } else {
                // trace("Last node has higher or equal priority, bubbling down.");
                this.bubbleDown(index);
            }
        }
        
        delete this.taskMap[taskID];  // 删除 taskMap 中的对应项
        // trace("Task removed: " + taskID);
    }

    // 更新任务的优先级
    public function update(taskID:String, newPriority:Number):Void {
        var node:HeapNode = this.taskMap[taskID];
        if (node == null) {
            // trace("Task not found for update: " + taskID);
            return;
        }

        // trace("Found task for update: " + taskID + " with current priority: " + node.priority);
        var oldPriority:Number = node.priority;
        node.priority = newPriority;

        // 调用重新平衡方法来调整堆
        this.rebalance(node);

        // trace("Updated task: " + taskID + " to new priority: " + newPriority);
    }

    // 当任务被取出执行
    public function extractMin():HeapNode {
        if (this.heap.length == 0) {
            return null;
        }
        var minNode:HeapNode = this.heap[0];
        var lastNode:HeapNode = HeapNode(this.heap.pop());
        // trace("Executing task: " + minNode.taskID + " at priority: " + minNode.priority);
        if (this.heap.length > 0) {
            this.heap[0] = lastNode;
            this.bubbleDown(0);
        }
        delete this.taskMap[minNode.taskID];
        // trace("Heap after extraction: " + this.heap);
        return minNode;
    }

    // 上浮操作，维护堆的性质
    private function bubbleUp(index:Number):Void {
        var node:HeapNode = this.heap[index];
        while (index > 0) {
            var parentIndex:Number = (index - 1) >> 1;  // 使用位运算符计算父节点索引
            var parentNode:HeapNode = this.heap[parentIndex];
            if (node.priority >= parentNode.priority) {
                break;  // 如果当前节点的优先级不小于父节点，退出循环
            }
            this.heap[index] = parentNode;  // 上浮当前节点
            index = parentIndex;
        }
        this.heap[index] = node;  // 将节点放在最终确定的位置
    }

    // 下沉操作，维护堆的性质
    private function bubbleDown(index:Number):Void {
        var length:Number = this.heap.length;
        var node:HeapNode = this.heap[index];

        while (true) {
            var left:Number = (index << 1) + 1;  // 计算左子节点索引
            var right:Number = left + 1;  // 计算右子节点索引
            var smallest:Number = index;

            // 合并左、右子节点的优先级比较操作
            if (left < length && this.heap[left].priority < node.priority) {
                smallest = left;
            }
            if (right < length && this.heap[right].priority < this.heap[smallest].priority) {
                smallest = right;
            }

            if (smallest == index) {
                break;  // 如果当前节点已经是最小，退出循环
            }

            this.heap[index] = this.heap[smallest];  // 下沉节点
            index = smallest;
        }
        this.heap[index] = node;  // 将节点放在最终确定的位置
    }

    // 交换两个节点
    private function swap(index1:Number, index2:Number):Void {
        var temp:HeapNode = this.heap[index1];
        this.heap[index1] = this.heap[index2];
        this.heap[index2] = temp;

        // 更新索引信息（如果需要）
        this.heap[index1].index = index1;
        this.heap[index2].index = index2;
    }

    // 重新平衡堆
    private function rebalance(node:HeapNode):Void {
        var index:Number = this.heap.indexOf(node);
        if (index == -1) {
            // trace("Node not found in heap for rebalancing: " + node.taskID);
            return;
        }
        
        var parentIndex:Number = (index - 1) >> 1;  // 位运算符计算父节点索引
        var left:Number = (index << 1) + 1;  // 位运算符计算左子节点索引
        var right:Number = left + 1;  // 右子节点索引

        var smallest:Number = index;
        
        if (left < this.heap.length && this.heap[left].priority < this.heap[smallest].priority) {
            smallest = left;
        }
        if (right < this.heap.length && this.heap[right].priority < this.heap[smallest].priority) {
            smallest = right;
        }
        
        if (smallest != index) {
            this.swap(index, smallest);
            this.bubbleDown(smallest);
        } else if (parentIndex >= 0 && this.heap[parentIndex].priority > this.heap[index].priority) {
            this.bubbleUp(index);
        }
    }

    // 查找任务在堆中的索引
    private function findIndexByTaskID(taskID:String):Number {
        for (var i:Number = 0; i < this.heap.length; i++) {
            if (this.heap[i].taskID == taskID) {
                return i;
            }
        }
        return -1; // 如果未找到，返回-1
    }
}
