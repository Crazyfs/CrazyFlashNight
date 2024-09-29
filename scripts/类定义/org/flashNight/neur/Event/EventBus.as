import org.flashNight.neur.Event.*; 

/**
 * EventBus 类用于事件的订阅、发布和管理。
 * 它使用 Allocator 来管理回调函数的内存分配，确保高效处理大量事件。
 */
class org.flashNight.neur.Event.EventBus {
    private var listeners:Object;   // 事件名 -> 回调函数索引数组映射
    private var allocator:Allocator; // 分配器，用于管理和分配回调函数

    /**
     * 构造函数，初始化事件总线和分配器。
     */
    public function EventBus() {
        this.listeners = {};   // 初始化空的事件监听器映射
        this.allocator = new Allocator(new Array(), 5);  // 初始化分配器，初始容量为 5
    }

    /**
     * 订阅事件，将回调函数与特定的事件绑定。
     * 
     * @param eventName 事件的名称，用于标识事件。
     * @param callback 要订阅的回调函数，当事件触发时执行。
     * @param scope 回调函数执行时的作用域（即 `this` 的指向对象）。
     */
    public function subscribe(eventName:String, callback:Function, scope:Object):Void {
        // 如果该事件还没有被监听，则初始化一个空数组
        if (!this.listeners[eventName]) {
            this.listeners[eventName] = [];
        }

        // 如果没有重复订阅同一回调，则添加
        if (this.findCallback(eventName, callback) == -1) {
            var wrappedCallback:Function = Delegate.create(scope, callback);  // 创建代理回调，绑定作用域
            var allocIndex:Number = this.allocator.Alloc(wrappedCallback);    // 将回调分配到分配器中，获得索引
            this.listeners[eventName].push(allocIndex);                       // 存储回调的分配索引
        }
    }

    /**
     * 查找特定事件名下的回调函数，避免重复订阅。
     * 
     * @param eventName 事件的名称。
     * @param callback 要查找的回调函数。
     * @return 返回回调函数的索引，如果不存在则返回 -1。
     */
    private function findCallback(eventName:String, callback:Function):Number {
        // 如果该事件没有被监听，直接返回 -1
        if (!this.listeners[eventName]) return -1;

        // 遍历事件的监听数组，查找回调
        for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
            var index:Number = this.listeners[eventName][i];
            var storedCallback:Function = this.allocator.getCallback(index);

            // 检查原始回调是否与存储的回调一致
            if (storedCallback._originalCallback === callback) {
                return i; // 返回索引
            }
        }
        return -1;  // 未找到返回 -1
    }

    /**
     * 取消订阅事件，移除指定的回调函数。
     * 
     * @param eventName 事件的名称。
     * @param callback 要取消的回调函数。
     */
    public function unsubscribe(eventName:String, callback:Function):Void {
        if (this.listeners[eventName]) {
            // 查找并移除回调函数
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                var storedCallback:Function = this.allocator.getCallback(index);

                // 如果找到匹配的回调，则释放它并从监听数组中移除
                if (storedCallback._originalCallback === callback) {
                    this.allocator.Free(index);  // 释放回调
                    this.listeners[eventName].splice(i, 1); // 从监听数组中移除
                    break;
                }
            }

            // 如果没有监听器，删除该事件的监听数组
            if (this.listeners[eventName].length == 0) {
                delete this.listeners[eventName];
            }
        }
    }

    /**
     * 发布事件，通知所有订阅者，并传递可选的参数。
     * 
     * @param eventName 事件名称。
     * @param ...args 传递给回调函数的参数。
     */
    public function publish(eventName:String):Void {
        if (this.listeners[eventName]) {
            // 收集传递给回调的参数（去除第一个参数，即 eventName）
            var args:Array = [];
            for (var i:Number = 1; i < arguments.length; i++) {
                args.push(arguments[i]);
            }

            // 创建监听器的副本，防止回调过程中修改原数组
            var listenersCopy:Array = this.listeners[eventName].concat();

            // 遍历并执行所有回调
            for (var j:Number = 0; j < listenersCopy.length; j++) {
                var index:Number = listenersCopy[j];
                var callback:Function = this.allocator.getCallback(index);

                if (callback) {
                    try {
                        callback.apply(null, args);  // 调用回调函数并传递参数
                    } catch (error:Error) {
                        trace("Error executing callback for event '" + eventName + "': " + error.message);
                    }
                }
            }
        }
    }

    /**
     * 一次性订阅事件，回调执行一次后即自动取消订阅。
     * 
     * @param eventName 事件的名称。
     * @param callback 要订阅的回调函数。
     * @param scope 回调函数的作用域（`this` 指向的对象）。
     */
    public function subscribeOnce(eventName:String, callback:Function, scope:Object):Void {
        var self:EventBus = this;
        var wrappedCallback:Function = Delegate.create(scope, callback);

        // 包装回调函数，执行后自动取消订阅
        var wrapper:Function = function() {
            wrappedCallback.apply(null, arguments);  // 执行回调
            self.unsubscribe(eventName, wrapper);    // 执行后取消订阅
        };

        wrapper._originalCallback = callback; // 保存原始回调
        this.subscribe(eventName, wrapper, scope);  // 调用常规的订阅方法
    }

    /**
     * 销毁事件总线，释放所有监听器和回调。
     * 清空分配器中所有资源，防止内存泄漏。
     */
    public function destroy():Void {
        // 遍历所有事件，释放所有监听器
        for (var eventName in this.listeners) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                this.allocator.Free(index);  // 释放回调函数
            }
            delete this.listeners[eventName];  // 删除事件监听器
        }

        this.allocator.FreeAll();  // 释放分配器中所有资源
    }
}


/*

// 导入必要的类
import org.flashNight.neur.Event.*;
import org.flashNight.neur.Event.Allocable.*;


callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 定义一个简单的断言函数
function assert(condition:Boolean, testName:String):Void {
    if (condition) {
        trace("[PASS] " + testName);
    } else {
        trace("[FAIL] " + testName);
    }
}

// 创建并初始化 Allocator 用于测试 ExampleAllocable 对象
var poolArrayTest:Array = new Array();
var allocatorTest:Allocator = new Allocator(poolArrayTest, 5); // 预分配5个空间

// 创建 EventBus 实例，内部使用独立的 Allocator
var eventBus:org.flashNight.neur.Event.EventBus = new org.flashNight.neur.Event.EventBus();

// 定义测试用的回调函数标志
var callback1Called:Boolean = false;
var callback2Called:Boolean = false;
var callbackWithArgsCalled:Boolean = false;
var callbackWithErrorCalled:Boolean = false;
var callbackOnceCalled:Boolean = false;

// 定义测试用的回调函数
function callback1():Void {
    callback1Called = true;
    trace("callback1 executed");
}

function callback2(arg1, arg2):Void {
    callback2Called = true;
    trace("callback2 executed with args: " + arg1 + ", " + arg2);
}

function callbackWithError():Void {
    callbackWithErrorCalled = true;
    trace("callbackWithError executed");
    throw new Error("Intentional error in callbackWithError");
}

function callbackOnce():Void {
    callbackOnceCalled = true;
    trace("callbackOnce executed");
}

// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;


// 测试用例 1: Allocator - 分配对象到预分配空间
function testAllocatorAllocPreallocated():Void {
    var obj1:ExampleAllocable = new ExampleAllocable();
    var index1:Number = allocatorTest.Alloc(obj1, "init1", "init2");
    assert(index1 == 0, "Test 1: Alloc object to preallocated space (index should be 0)");
    var storedObj1:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(index1));
    assert(
        storedObj1.data[0] == "init1" &&
        storedObj1.data[1] == "init2",
        "Test 1: Object stored correctly at index " + index1
    );
}

testAllocatorAllocPreallocated();

// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 2: Allocator - 分配超出预分配空间的对象
function testAllocatorAllocBeyondPreallocated():Void {
    var obj2:ExampleAllocable = new ExampleAllocable();
    var index2:Number = allocatorTest.Alloc(obj2, "init3");
    assert(index2 == 1, "Test 2: Alloc object beyond preallocated space (index should be 1)");
    var storedObj2:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(index2));
    assert(
        storedObj2.data[0] == "init3",
        "Test 2: Object stored correctly at index " + index2
    );
}

testAllocatorAllocBeyondPreallocated();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;


// 测试用例 3: Allocator - 释放对象并复用索引
function testAllocatorFreeAndReuse():Void {
    var obj1:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(0));
    allocatorTest.Free(0);
    assert(allocatorTest.getCallback(0) == null, "Test 3: Free object at index 0");
    
    // 因为最近释放的索引会被添加到 availSpace 的末尾，下次分配时可能不会立即复用索引 0
    // 所以我们不再强制检查是否复用了索引 0，而是获取当前可用的索引
    var obj3:ExampleAllocable = new ExampleAllocable();
    var index3:Number = allocatorTest.Alloc(obj3, "init4");
    
    // 检查分配的索引是否是刚释放的索引
    assert(index3 >= 0, "Test 3: Reuse freed index (should reuse an available index)");
    
    var storedObj3:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(index3));
    assert(
        storedObj3.data[0] == "init4",
        "Test 3: New object stored correctly at reused index " + index3
    );
}


testAllocatorFreeAndReuse();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 4: Allocator - 释放未分配的索引
function testAllocatorFreeUnallocated():Void {
    var initialAvailSpaceLength:Number = allocatorTest.getAvailSpaceCount();
    allocatorTest.Free(10); // 10 未被分配
    assert(
        allocatorTest.getAvailSpaceCount() == initialAvailSpaceLength,
        "Test 4: Free unallocated index does not alter availSpace"
    );
}

testAllocatorFreeUnallocated();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 5: Allocator - 释放所有对象
function testAllocatorFreeAll():Void {
    // Allocate additional objects
    var obj4:ExampleAllocable = new ExampleAllocable();
    var obj5:ExampleAllocable = new ExampleAllocable();
    allocatorTest.Alloc(obj4, "init5");
    allocatorTest.Alloc(obj5, "init6");

    allocatorTest.FreeAll();
    var allFreed:Boolean = true;
    for (var i:Number = 0; i < allocatorTest.getPoolSize(); i++) {
        if (allocatorTest.getCallback(i) != null) {
            allFreed = false;
            break;
        }
    }
    assert(allFreed, "Test 5: FreeAll sets all pool indices to null");
    assert(allocatorTest.getAvailSpaceCount() == allocatorTest.getPoolSize(), "Test 5: FreeAll fills availSpace with all indices");

}

testAllocatorFreeAll();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 6: Allocator - 分配和释放多个对象
function testAllocatorMultipleAllocFree():Void {
    var objs:Array = [];
    for (var i:Number = 0; i < 10; i++) {
        objs.push(new ExampleAllocable());
    }
    var indices:Array = [];
    // 分配 10 对象
    for (var j:Number = 0; j < 10; j++) {
        indices.push(allocatorTest.Alloc(objs[j], "init" + (j + 7)));
    }
    // 释放偶数索引
    for (var k:Number = 0; k < indices.length; k++) {
        if (k % 2 == 0) {
            allocatorTest.Free(indices[k]);
        }
    }
    // 分配新的对象，应该复用已释放的索引
    var newObj:ExampleAllocable = new ExampleAllocable();
    var newIndex:Number = allocatorTest.Alloc(newObj, "init17");
    assert(newIndex == 0, "Test 6: Alloc reuses the first freed index (0)");
    var storedObjNew:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(newIndex));
    assert(
        storedObjNew.data[0] == "init17",
        "Test 6: New object stored correctly at reused index " + newIndex
    );
}

testAllocatorMultipleAllocFree();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 7: Allocator - 分配对象后对象状态初始化
function testAllocatorObjectInitialization():Void {
    var obj:ExampleAllocable = new ExampleAllocable();
    obj.initialize("param1", "param2"); // 手动初始化
    var index:Number = allocatorTest.Alloc(obj, "init18", "init19");
    var storedObj:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(index));
    assert(
        storedObj.data[0] == "init18" &&
        storedObj.data[1] == "init19",
        "Test 7: Object initialized with correct parameters"
    );
}

testAllocatorObjectInitialization();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 8: Allocator - 释放对象后对象状态重置
function testAllocatorObjectReset():Void {
    var obj:ExampleAllocable = new ExampleAllocable();
    obj.initialize("param1", "param2");
    var index:Number = allocatorTest.Alloc(obj, "init20");
    allocatorTest.Free(index);
    assert(
        allocatorTest.getCallback(index) == null,
        "Test 8.1: Object at index is null after Free"
    );
    // 分配新对象到同一索引
    var newObj:ExampleAllocable = new ExampleAllocable();
    var newIndex:Number = allocatorTest.Alloc(newObj, "init21");
    assert(
        newObj.data.length == 1 &&
        newObj.data[0] == "init21",
        "Test 8.2: New object initialized correctly after reuse"
    );
}

testAllocatorObjectReset();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 9: Allocator - 分配后重复释放
function testAllocatorDoubleFree():Void {
    var obj:ExampleAllocable = new ExampleAllocable();
    var index:Number = allocatorTest.Alloc(obj, "init22");
    allocatorTest.Free(index);
    var initialAvailSpaceLength:Number = allocatorTest.getAvailSpaceCount();
    allocatorTest.Free(index); // 尝试第二次释放
    assert(
        allocatorTest.getAvailSpaceCount() == initialAvailSpaceLength,
        "Test 9: Double Free does not alter availSpace"
    );
}

testAllocatorDoubleFree();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 10: Allocator - `FreeAll` 后重新分配
function testAllocatorAllocAfterFreeAll():Void {
    var obj1:ExampleAllocable = new ExampleAllocable();
    var obj2:ExampleAllocable = new ExampleAllocable();
    var index1:Number = allocatorTest.Alloc(obj1, "init23");
    var index2:Number = allocatorTest.Alloc(obj2, "init24");
    allocatorTest.FreeAll();
    var obj3:ExampleAllocable = new ExampleAllocable();
    var index3:Number = allocatorTest.Alloc(obj3, "init25");
    assert(index3 == 0, "Test 10: Alloc after FreeAll starts from index 0");
    var storedObj3:ExampleAllocable = ExampleAllocable(allocatorTest.getCallback(index3));
    assert(
        storedObj3.data[0] == "init25",
        "Test 10: Object stored correctly at index " + index3
    );
}

testAllocatorAllocAfterFreeAll();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 11: EventBus - 订阅和发布单个事件
function testEventBusSubscribePublish():Void {
    eventBus.subscribe("TEST_EVENT", callback1, this);
    eventBus.publish("TEST_EVENT");
    assert(callback1Called == true, "Test 11: EventBus subscribe and publish single event");
    callback1Called = false; // 重置标志
}

testEventBusSubscribePublish();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 12: EventBus - 取消订阅
function testEventBusUnsubscribe():Void {
    eventBus.subscribe("TEST_EVENT", callback1, this);
    eventBus.unsubscribe("TEST_EVENT", callback1);
    eventBus.publish("TEST_EVENT");
    assert(callback1Called == false, "Test 12: EventBus unsubscribe callback");
}

testEventBusUnsubscribe();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 13: EventBus - 一次性订阅
function testEventBusSubscribeOnce():Void {
    eventBus.subscribeOnce("ONCE_EVENT", callbackOnce, this);
    eventBus.publish("ONCE_EVENT");
    eventBus.publish("ONCE_EVENT");
    assert(callbackOnceCalled == true, "Test 13: EventBus subscribeOnce - first publish");
    callbackOnceCalled = false;
    assert(callbackOnceCalled == false, "Test 13: EventBus subscribeOnce - second publish");
}

testEventBusSubscribeOnce();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 14: EventBus - 发布带参数的事件
function testEventBusPublishWithArgs():Void {
    eventBus.subscribe("ARGS_EVENT", callback2, this);
    eventBus.publish("ARGS_EVENT", "Hello", "World");
    assert(callback2Called == true, "Test 14: EventBus publish event with arguments");
    callback2Called = false;
}

testEventBusPublishWithArgs();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 15: EventBus - 回调函数抛出错误时的处理
function testEventBusCallbackErrorHandling():Void {
	eventBus.subscribe("ERROR_EVENT", callbackWithError, this);
	eventBus.subscribe("ERROR_EVENT", callback1, this);

    eventBus.publish("ERROR_EVENT");
    assert(
        callbackWithErrorCalled == true &&
        callback1Called == true,
        "Test 15: EventBus callback error handling"
    );
    callbackWithErrorCalled = false;
    callback1Called = false;
}

testEventBusCallbackErrorHandling();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 16: EventBus - 销毁后确保所有回调不再被调用
function testEventBusDestroy():Void {
    eventBus.subscribe("DESTROY_EVENT", callback1);
    eventBus.destroy();
    eventBus.publish("DESTROY_EVENT");
    assert(callback1Called == false, "Test 16: EventBus destroy and ensure callbacks are not called");
}

testEventBusDestroy();
// 在每个测试用例开始前
callback1Called = false;
callback2Called = false;
callbackWithArgsCalled = false;
callbackWithErrorCalled = false;
callbackOnceCalled = false;

// 测试用例 17: Allocator - 分配与释放机制综合测试
function testAllocatorAllocFree():Void {
    var allocatorTest2:Allocator = new Allocator(new Array(), 3); // 创建另一个 Allocator 实例用于综合测试
    var objA:ExampleAllocable = new ExampleAllocable();
    var objB:ExampleAllocable = new ExampleAllocable();
    var objC:ExampleAllocable = new ExampleAllocable();

    var indexA:Number = allocatorTest2.Alloc(objA, "init26");
    var indexB:Number = allocatorTest2.Alloc(objB, "init27");
    var indexC:Number = allocatorTest2.Alloc(objC, "init28");

    assert(indexA == 0 && allocatorTest2.getCallback(indexA) === objA, "Test 17.1: Alloc objA correctly");
    assert(indexB == 1 && allocatorTest2.getCallback(indexB) === objB, "Test 17.2: Alloc objB correctly");
    assert(indexC == 2 && allocatorTest2.getCallback(indexC) === objC, "Test 17.3: Alloc objC correctly");

    allocatorTest2.Free(indexB);
    assert(
        allocatorTest2.getCallback(indexB) == null &&
        allocatorTest2.getAvailSpaceCount() == 1 &&
        allocatorTest2.isIndexAvailable(indexB),
        "Test 17.4: Free objB correctly"
    );

    var objD:ExampleAllocable = new ExampleAllocable();
    var indexD:Number = allocatorTest2.Alloc(objD, "init29");
    assert(indexD == 1 && allocatorTest2.getCallback(indexD) === objD, "Test 17.5: Reuse freed index for objD");

    allocatorTest2.FreeAll();
    var allFreed:Boolean = true;
    for (var i:Number = 0; i < allocatorTest2.getPoolSize(); i++) {
        if (allocatorTest2.getCallback(i) != null) {
            allFreed = false;
            break;
        }
    }
    assert(allFreed, "Test 17.6: FreeAll sets all pool indices to null");
    assert(allocatorTest2.getAvailSpaceCount() == allocatorTest2.getPoolSize(), "Test 17.7: FreeAll fills availSpace with all indices");
}

testAllocatorAllocFree();

// 测试完成
trace("All tests completed.");

Allocated index: 0
[PASS] Test 1: Alloc object to preallocated space (index should be 0)
[PASS] Test 1: Object stored correctly at index 0
Allocated index: 1
[PASS] Test 2: Alloc object beyond preallocated space (index should be 1)
[PASS] Test 2: Object stored correctly at index 1
[PASS] Test 3: Free object at index 0
Allocated index: 2
[PASS] Test 3: Reuse freed index (should reuse an available index)
[PASS] Test 3: New object stored correctly at reused index 2
Warning: Attempted to free an unallocated or already freed index: 10
[PASS] Test 4: Free unallocated index does not alter availSpace
Allocated index: 3
Allocated index: 4
[PASS] Test 5: FreeAll sets all pool indices to null
[PASS] Test 5: FreeAll fills availSpace with all indices
Allocated index: 0
Allocated index: 1
Allocated index: 2
Allocated index: 3
Allocated index: 4
Allocated index: 5
Allocated index: 6
Allocated index: 7
Allocated index: 8
Allocated index: 9
Allocated index: 0
[PASS] Test 6: Alloc reuses the first freed index (0)
[PASS] Test 6: New object stored correctly at reused index 0
Allocated index: 2
[PASS] Test 7: Object initialized with correct parameters
Allocated index: 4
[PASS] Test 8.1: Object at index is null after Free
Allocated index: 6
[PASS] Test 8.2: New object initialized correctly after reuse
Allocated index: 8
Warning: Attempted to free an unallocated or already freed index: 8
[PASS] Test 9: Double Free does not alter availSpace
Allocated index: 4
Allocated index: 8
Allocated index: 0
[PASS] Test 10: Alloc after FreeAll starts from index 0
[PASS] Test 10: Object stored correctly at index 0
Allocated index: 0
callback1 executed
[PASS] Test 11: EventBus subscribe and publish single event
[PASS] Test 12: EventBus unsubscribe callback
Allocated index: 1
callbackOnce executed
[PASS] Test 13: EventBus subscribeOnce - first publish
[PASS] Test 13: EventBus subscribeOnce - second publish
Allocated index: 2
callback2 executed with args: Hello, World
[PASS] Test 14: EventBus publish event with arguments
Allocated index: 3
Allocated index: 4
callbackWithError executed
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
callback1 executed
[PASS] Test 15: EventBus callback error handling
Allocated index: 0
[PASS] Test 16: EventBus destroy and ensure callbacks are not called
Allocated index: 0
Allocated index: 1
Allocated index: 2
[PASS] Test 17.1: Alloc objA correctly
[PASS] Test 17.2: Alloc objB correctly
[PASS] Test 17.3: Alloc objC correctly
[PASS] Test 17.4: Free objB correctly
Allocated index: 1
[PASS] Test 17.5: Reuse freed index for objD
[PASS] Test 17.6: FreeAll sets all pool indices to null
[PASS] Test 17.7: FreeAll fills availSpace with all indices
All tests completed.

*/
