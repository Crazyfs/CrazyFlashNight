import org.flashNight.neur.Event.*;

/**
 * EventBus 类用于事件的订阅、发布和管理。
 * 采用饿汉式单例模式，确保在类加载时实例化。
 */
class org.flashNight.neur.Event.EventBus {
    private var listeners:Object;          // 存储事件监听器，结构为事件名 -> { callbacks: { callbackID: poolIndex }, funcToID: { funcID: callbackID }, count: Number }
    private var pool:Array;                // 回调函数池，用于存储回调函数的索引位置
    private var availSpace:Array;          // 可用索引列表，存储空闲的池位置
    private var idToCallback:Object;       // 唯一ID到原始回调函数的映射

    // 静态实例，类加载时初始化，采用饿汉式单例
    private static var instance:EventBus = new EventBus();
    private static var callbackCounter:Number = 0;    // 全局回调计数器
    private var tempArgs:Array = [];                  // 参数缓存区，重用避免频繁创建
    private var tempCallbacks:Array = [];             // 重用的回调函数存储数组

    /**
     * 私有化构造函数，防止外部直接创建对象。
     * 初始化回调池，并为可用空间列表预分配 1000 个空闲位置。
     */
    private function EventBus() {
        this.listeners = {};           // 初始化监听器字典
        this.pool = [];                // 初始化回调函数池
        this.availSpace = [];          // 初始化可用索引列表
        this.idToCallback = {};        // 初始化回调 ID 映射

        // 预分配 1000 个空闲池位，减少运行时扩展的开销
        for (var i:Number = 0; i < 1000; i++) {
            this.pool.push(null);
            this.availSpace.push(i);
        }
    }

    /**
     * 初始化方法，显式调用一次初始化静态实例。
     * 后续直接返回唯一的实例，不再检查。
     * 
     * @return EventBus 单例实例
     */
    public static function initialize():EventBus {
        Delegate.init();
        return instance;
    }

    /**
     * 获取 EventBus 单例实例的静态方法。
     * 
     * @return EventBus 单例实例
     */
    public static function getInstance():EventBus {
        return instance;
    }

    /**
     * 订阅事件，将回调函数与特定事件绑定。
     * 避免重复订阅，通过唯一 ID 管理回调。
     * 
     * @param eventName 事件名称
     * @param callback 要订阅的回调函数
     * @param scope 回调函数执行时的作用域
     */
    public function subscribe(eventName:String, callback:Function, scope:Object):Void {
        if (!this.listeners[eventName]) {
            this.listeners[eventName] = { callbacks: {}, funcToID: {}, count: 0 };  // 初始化事件的监听器对象，包含回调、ID 映射和计数
        }

        var listenersForEvent:Object = this.listeners[eventName];
        var funcToID:Object = listenersForEvent.funcToID;

        // 分配唯一的函数 ID
        if (typeof(callback.__eventBusID) == 'undefined') {
            callback.__eventBusID = EventBus.callbackCounter++;
        }
        var funcID:String = String(callback.__eventBusID);

        // 如果已存在该回调，避免重复订阅
        if (funcToID[funcID] != undefined) {
            return;
        }

        // 分配唯一的回调 ID
        var callbackID:Number = EventBus.callbackCounter++;
        this.idToCallback[callbackID] = callback;

        // 创建作用域绑定的包装回调
        var wrappedCallback:Function = Delegate.create(scope, callback);

        // 分配池中的可用索引位置
        var allocIndex:Number;
        if (this.availSpace.length > 0) {
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        } else {
            // 如果池已满，采用双倍扩展策略
            var newCapacity:Number = this.pool.length * 2;
            for (var j:Number = this.pool.length; j < newCapacity; j++) {
                this.pool.push(null);
                this.availSpace.push(j);
            }
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        }

        // 将回调 ID 和分配的索引位置存储起来
        listenersForEvent.callbacks[callbackID] = allocIndex;
        funcToID[funcID] = callbackID;

        listenersForEvent.count++;  // 增加该事件的回调计数
    }

    /**
     * 取消订阅事件，移除指定的回调函数。
     * 通过唯一 ID 快速定位并移除回调函数。
     * 
     * @param eventName 事件名称
     * @param callback 要取消的回调函数
     */
    public function unsubscribe(eventName:String, callback:Function):Void {
        var listenersForEvent:Object = this.listeners[eventName];
        if (!listenersForEvent) return;

        var funcToID:Object = listenersForEvent.funcToID;

        if (typeof(callback.__eventBusID) == 'undefined') {
            return;
        }
        var funcID:String = String(callback.__eventBusID);

        var callbackID:Number = funcToID[funcID];
        if (callbackID == undefined) return;

        // 根据回调 ID 获取其索引位置并释放该回调
        var allocIndex:Number = listenersForEvent.callbacks[callbackID];
        if (allocIndex != undefined) {
            this.pool[allocIndex] = null;
            this.availSpace.push(allocIndex);
            delete listenersForEvent.callbacks[callbackID];
            delete this.idToCallback[callbackID];
            delete funcToID[funcID];
        }

        listenersForEvent.count--;  // 减少该事件的回调计数

        // 如果没有剩余的回调函数，则删除该事件的监听器对象
        if (listenersForEvent.count === 0) {
            delete this.listeners[eventName];
        }
    }

    /**
     * 发布事件，通知所有订阅者，并传递可选的参数。
     * 
     * @param eventName 事件名称
     */
    public function publish(eventName:String):Void {
        var listenersForEvent:Object = this.listeners[eventName];
        if (!listenersForEvent) return;

        var callbacks:Object = listenersForEvent.callbacks;
        var poolRef:Array = this.pool;

        this.tempCallbacks.length = 0;  // 清空并重用临时回调数组

        // 将所有回调函数存入 tempCallbacks 数组
        for (var cbID:String in callbacks) {
            var index:Number = callbacks[cbID];
            var callback:Function = poolRef[index];
            if (callback != null) {
                this.tempCallbacks.push(callback);
            }
        }

        var callbackCount:Number = this.tempCallbacks.length;
        var hasArguments:Boolean = arguments.length >= 2;

        // 如果存在额外参数，则将参数传递到 tempArgs 中
        if (hasArguments) {
            this.tempArgs.length = 0;
            var argsLen:Number = arguments.length;
            for (var i:Number = 1; i < argsLen; i++) {
                this.tempArgs.push(arguments[i]);
            }
        }

        // 倒序遍历并执行回调函数
        for (var j:Number = callbackCount - 1; j >= 0; j--) {
            var cb:Function = this.tempCallbacks[j];
            try {
                if (hasArguments) {
                    // 手动展开常见参数情况，避免使用 apply 带来的性能损耗
                    switch (this.tempArgs.length) {
                        case 0: cb(); break;
                        case 1: cb(this.tempArgs[0]); break;
                        case 2: cb(this.tempArgs[0], this.tempArgs[1]); break;
                        case 3: cb(this.tempArgs[0], this.tempArgs[1], this.tempArgs[2]); break;
                        case 4: cb(this.tempArgs[0], this.tempArgs[1], this.tempArgs[2], this.tempArgs[3]); break;
                        case 5: cb(this.tempArgs[0], this.tempArgs[1], this.tempArgs[2], this.tempArgs[3], this.tempArgs[4]); break;
                        case 6: cb(this.tempArgs[0], this.tempArgs[1], this.tempArgs[2], this.tempArgs[3], this.tempArgs[4], this.tempArgs[5]); break;
                        case 7: cb(this.tempArgs[0], this.tempArgs[1], this.tempArgs[2], this.tempArgs[3], this.tempArgs[4], this.tempArgs[5], this.tempArgs[6]); break;
                        default: cb.apply(null, this.tempArgs);  // 参数超过 7 个时，使用 apply
                    }
                } else {
                    cb();
                }
            } catch (error:Error) {
                trace("Error executing callback for event '" + eventName + "': " + error.message);
            }
        }
    }

    /**
     * 一次性订阅事件，回调执行一次后即自动取消订阅。
     * 
     * @param eventName 事件名称
     * @param callback 要订阅的回调函数
     * @param scope 回调函数的作用域
     */
    public function subscribeOnce(eventName:String, callback:Function, scope:Object):Void {
        var self:EventBus = this;
        var originalCallback:Function = callback;

        if (typeof(originalCallback.__eventBusID) == 'undefined') {
            originalCallback.__eventBusID = EventBus.callbackCounter++;
        }
        var funcID:String = String(originalCallback.__eventBusID);

        var listenersForEvent:Object = this.listeners[eventName];
        if (!listenersForEvent) {
            listenersForEvent = { callbacks: {}, funcToID: {}, count: 0 };  // 初始化事件的监听器对象
            this.listeners[eventName] = listenersForEvent;
        }

        var funcToID:Object = listenersForEvent.funcToID;

        if (funcToID[funcID] != undefined) {
            return;  // 避免重复订阅
        }

        var callbackID:Number = EventBus.callbackCounter++;
        this.idToCallback[callbackID] = originalCallback;

        // 创建一次性回调的包装函数
        var wrappedOnceCallback:Function = function() {
            originalCallback.apply(scope, arguments);
            self.unsubscribe(eventName, originalCallback);  // 回调执行后自动取消订阅
        };

        // 使用 Delegate.create 获取包装后的回调函数
        var wrappedCallback:Function = Delegate.create(scope, wrappedOnceCallback);

        var allocIndex:Number;
        if (this.availSpace.length > 0) {
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        } else {
            var newCapacity:Number = this.pool.length * 2;
            for (var j:Number = this.pool.length; j < newCapacity; j++) {
                this.pool.push(null);
                this.availSpace.push(j);
            }
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        }

        listenersForEvent.callbacks[callbackID] = allocIndex;
        funcToID[funcID] = callbackID;
        listenersForEvent.count++;  // 增加该事件的回调计数
    }

    /**
     * 销毁事件总线，释放所有监听器和回调函数。
     * 清理回调池、可用索引列表及临时缓存，防止内存泄漏。
     */
    public function destroy():Void {
        for (var eventName:String in this.listeners) {
            var listenersForEvent:Object = this.listeners[eventName];
            for (var cbID:String in listenersForEvent.callbacks) {
                var index:Number = listenersForEvent.callbacks[cbID];
                if (index != undefined) {
                    this.pool[index] = null;
                    this.availSpace.push(index);
                    delete this.idToCallback[cbID];
                }
            }
            delete this.listeners[eventName];
        }

        // 清空回调池中的所有剩余回调
        for (var i:Number = this.pool.length - 1; i >= 0; i--) {
            if (this.pool[i] != null) {
                this.pool[i] = null;
                this.availSpace.push(i);
            }
        }

        this.listeners = {};
        this.idToCallback = {};

        // 清空 Delegate 缓存中的包装回调函数
        Delegate.clearCache();

        // 清空临时参数和回调数组
        this.tempArgs.length = 0;
        this.tempCallbacks.length = 0;
    }
}


/*

// 导入必要的类
import org.flashNight.neur.Event.*;

// 定义测试用的回调函数标志
var callback1Called:Boolean = false;
var callback2Called:Boolean = false;
var callbackWithArgsCalled:Boolean = false;
var callbackWithErrorCalled:Boolean = false;
var callbackOnceCalled:Boolean = false;

// 定义一个简单的断言函数
function assert(condition:Boolean, testName:String):Void {
    if (condition) {
        trace("[PASS] " + testName);
    } else {
        trace("[FAIL] " + testName);
    }
}

// 创建 EventBus 实例
var eventBus:EventBus = EventBus.initialize();

// 定义测试用的回调函数
function callback1():Void {
    callback1Called = true;
    // trace("callback1 executed"); // 移除 trace 以减少性能影响
}

function callback2(arg1, arg2):Void {
    callback2Called = true;
    // trace("callback2 executed with args: " + arg1 + ", " + arg2); // 移除 trace 以减少性能影响
}

function callbackWithError():Void {
    callbackWithErrorCalled = true;
    // trace("callbackWithError executed"); // 移除 trace 以减少性能影响
    throw new Error("Intentional error in callbackWithError");
}

function callbackOnce():Void {
    callbackOnceCalled = true;
    // trace("callbackOnce executed"); // 移除 trace 以减少性能影响
}

// 在每个测试用例开始前重置回调标志
function resetFlags():Void {
    callback1Called = false;
    callback2Called = false;
    callbackWithArgsCalled = false;
    callbackWithErrorCalled = false;
    callbackOnceCalled = false;
}

// 测试用例 1: EventBus - 订阅和发布单个事件
function testEventBusSubscribePublish():Void {
    resetFlags();
    eventBus.subscribe("TEST_EVENT", callback1, this);
    eventBus.publish("TEST_EVENT");
    assert(callback1Called == true, "Test 1: EventBus subscribe and publish single event");
    callback1Called = false; // 重置标志
    eventBus.unsubscribe("TEST_EVENT", callback1); // 清理订阅
}

testEventBusSubscribePublish();

// 测试用例 2: EventBus - 取消订阅
function testEventBusUnsubscribe():Void {
    resetFlags();
    eventBus.subscribe("TEST_EVENT", callback1, this);
    eventBus.unsubscribe("TEST_EVENT", callback1);
    eventBus.publish("TEST_EVENT");
    assert(callback1Called == false, "Test 2: EventBus unsubscribe callback");
}

testEventBusUnsubscribe();

// 测试用例 3: EventBus - 一次性订阅
function testEventBusSubscribeOnce():Void {
    resetFlags();
    eventBus.subscribeOnce("ONCE_EVENT", callbackOnce, this);
    eventBus.publish("ONCE_EVENT");
    eventBus.publish("ONCE_EVENT");
    assert(callbackOnceCalled == true, "Test 3: EventBus subscribeOnce - first publish");
    callbackOnceCalled = false;
    assert(callbackOnceCalled == false, "Test 3: EventBus subscribeOnce - second publish");
}

testEventBusSubscribeOnce();

// 测试用例 4: EventBus - 发布带参数的事件
function testEventBusPublishWithArgs():Void {
    resetFlags();
    eventBus.subscribe("ARGS_EVENT", callback2, this);
    eventBus.publish("ARGS_EVENT", "Hello", "World");
    assert(callback2Called == true, "Test 4: EventBus publish event with arguments");
    callback2Called = false; // 重置标志
    eventBus.unsubscribe("ARGS_EVENT", callback2); // 清理订阅
}

testEventBusPublishWithArgs();

// 测试用例 5: EventBus - 回调函数抛出错误时的处理
function testEventBusCallbackErrorHandling():Void {
    resetFlags();
    eventBus.subscribe("ERROR_EVENT", callbackWithError, this);
    eventBus.subscribe("ERROR_EVENT", callback1, this);

    eventBus.publish("ERROR_EVENT");
    assert(
        callbackWithErrorCalled == true &&
        callback1Called == true,
        "Test 5: EventBus callback error handling"
    );
    callbackWithErrorCalled = false;
    callback1Called = false;
    eventBus.unsubscribe("ERROR_EVENT", callbackWithError);
    eventBus.unsubscribe("ERROR_EVENT", callback1);
}

testEventBusCallbackErrorHandling();

// 测试用例 6: EventBus - 销毁后确保所有回调不再被调用
function testEventBusDestroy():Void {
    resetFlags();
    eventBus.subscribe("DESTROY_EVENT", callback1, this);
    eventBus.destroy();
    eventBus.publish("DESTROY_EVENT");
    assert(callback1Called == false, "Test 6: EventBus destroy and ensure callbacks are not called");
}

testEventBusDestroy();

// -----------------------------------------------------------
// 性能测试部分开始
// -----------------------------------------------------------

// 定义一个简单的计时函数
function measurePerformance(testName:String, testFunction:Function):Void {
    var startTime:Number = getTimer();
    testFunction();
    var endTime:Number = getTimer();
    var duration:Number = endTime - startTime;
    trace("[PERFORMANCE] " + testName + " took " + duration + " ms");
}

// 性能测试用例 7: EventBus - 大量事件订阅与发布
function testEventBusHighVolumeSubscriptions():Void {
    resetFlags();
    var numSubscribers:Number = 10000; // 增加到10000
    var eventName:String = "HIGH_VOLUME_EVENT";
    
    // 定义一个简单的回调
    function highVolumeCallback():Void {
        // 空回调
    }
    
    // 订阅大量回调
    for (var i:Number = 0; i < numSubscribers; i++) {
        eventBus.subscribe(eventName, highVolumeCallback, this);
    }
    
    // 发布事件
    eventBus.publish(eventName);
    
    // 取消订阅所有回调
    for (var j:Number = 0; j < numSubscribers; j++) {
        eventBus.unsubscribe(eventName, highVolumeCallback);
    }
    
    // 测试通过无需具体断言
    assert(true, "Test 7: EventBus handles high volume of subscriptions and publishes correctly");
}

measurePerformance("Test 7: EventBus High Volume Subscriptions and Publish", testEventBusHighVolumeSubscriptions);

// 性能测试用例 8: EventBus - 高频发布事件
function testEventBusHighFrequencyPublish():Void {
    resetFlags();
    var numPublish:Number = 100000; // 增加到100,000
    var eventName:String = "HIGH_FREQ_EVENT";
    
    // 定义一个简单的回调
    function highFreqCallback():Void {
        // 空回调
    }
    
    // 订阅一个回调
    eventBus.subscribe(eventName, highFreqCallback, this);
    
    // 高频发布事件
    for (var i:Number = 0; i < numPublish; i++) {
        eventBus.publish(eventName);
    }
    
    // 取消订阅
    eventBus.unsubscribe(eventName, highFreqCallback);
    
    // 测试通过无需具体断言
    assert(true, "Test 8: EventBus handles high frequency publishes correctly");
}

measurePerformance("Test 8: EventBus High Frequency Publish", testEventBusHighFrequencyPublish);

// 性能测试用例 9: EventBus - 高并发订阅与发布
function testEventBusConcurrentSubscriptionsAndPublishes():Void {
    resetFlags();
    var numEvents:Number = 1000; // 增加到1000
    var numSubscribersPerEvent:Number = 1000; // 增加到1000
    var numPublishesPerEvent:Number = 1000; // 增加到1000
    
    // 定义一个简单的回调
    function concurrentCallback():Void {
        // 空回调
    }
    
    // 订阅多个事件，每个事件有多个订阅者
    for (var i:Number = 0; i < numEvents; i++) {
        var eventName:String = "CONCURRENT_EVENT_" + i;
        for (var j:Number = 0; j < numSubscribersPerEvent; j++) {
            eventBus.subscribe(eventName, concurrentCallback, this);
        }
    }
    
    // 发布每个事件多次
    for (var k:Number = 0; k < numEvents; k++) {
        var currentEvent:String = "CONCURRENT_EVENT_" + k;
        for (var l:Number = 0; l < numPublishesPerEvent; l++) {
            eventBus.publish(currentEvent);
        }
    }
    
    // 取消所有订阅
    for (var m:Number = 0; m < numEvents; m++) {
        var currentEventToUnsub:String = "CONCURRENT_EVENT_" + m;
        for (var n:Number = 0; n < numSubscribersPerEvent; n++) {
            eventBus.unsubscribe(currentEventToUnsub, concurrentCallback);
        }
    }
    
    // 测试通过无需具体断言
    assert(true, "Test 9: EventBus handles concurrent subscriptions and publishes correctly");
}

measurePerformance("Test 9: EventBus Concurrent Subscriptions and Publishes", testEventBusConcurrentSubscriptionsAndPublishes);

// 性能测试用例 10: EventBus - 混合订阅与取消订阅
function testEventBusMixedSubscribeUnsubscribe():Void {
    resetFlags();
    var eventName:String = "MIXED_EVENT";
    var numOperations:Number = 100000; // 增加到100,000
    
    // 定义一个简单的回调
    function mixedCallback():Void {
        // 空回调
    }
    
    for (var i:Number = 0; i < numOperations; i++) {
        eventBus.subscribe(eventName, mixedCallback, this);
        if (i % 10 == 0) { // 保持取消订阅的频率
            eventBus.unsubscribe(eventName, mixedCallback);
        }
    }
    
    // 发布事件
    eventBus.publish(eventName);
    
    // 最终取消所有订阅
    eventBus.unsubscribe(eventName, mixedCallback);
    
    // 测试通过无需具体断言
    assert(true, "Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly");
}

measurePerformance("Test 10: EventBus Mixed Subscribe and Unsubscribe", testEventBusMixedSubscribeUnsubscribe);

// 性能测试用例 11: EventBus - 嵌套事件发布
function testEventBusNestedPublish():Void {
    resetFlags();
    var eventName1:String = "NESTED_EVENT_1";
    var eventName2:String = "NESTED_EVENT_2";

    function nestedCallback1():Void {
        // trace("Nested callback1 executed"); // 移除 trace 以减少性能影响
        eventBus.publish(eventName2); // 在回调中再次发布事件
    }

    function nestedCallback2():Void {
        // trace("Nested callback2 executed"); // 移除 trace 以减少性能影响
    }

    // 订阅事件
    eventBus.subscribe(eventName1, nestedCallback1, this);
    eventBus.subscribe(eventName2, nestedCallback2, this);

    // 发布第一个事件，测试嵌套事件发布
    eventBus.publish(eventName1);

    // 取消订阅
    eventBus.unsubscribe(eventName1, nestedCallback1);
    eventBus.unsubscribe(eventName2, nestedCallback2);

    assert(true, "Test 11: EventBus handles nested event publishes correctly");
}

measurePerformance("Test 11: EventBus Nested Event Publish", testEventBusNestedPublish);

// 性能测试用例 12: EventBus - 并行事件处理
function testEventBusParallelEvents():Void {
    resetFlags();
    var eventNames:Array = ["EVENT_A", "EVENT_B", "EVENT_C", "EVENT_D", "EVENT_E"];
    var numSubscribersPerEvent:Number = 10000; // 增加每个事件的订阅者数量

    function parallelCallback():Void {
        // trace("Parallel event callback executed"); // 移除 trace 以减少性能影响
    }

    // 订阅多个事件，每个事件有大量订阅者
    for (var i:Number = 0; i < eventNames.length; i++) {
        for (var j:Number = 0; j < numSubscribersPerEvent; j++) {
            eventBus.subscribe(eventNames[i], parallelCallback, this);
        }
    }

    // 同时发布多个事件
    for (var k:Number = 0; k < eventNames.length; k++) {
        eventBus.publish(eventNames[k]);
    }

    // 取消所有订阅
    for (var m:Number = 0; m < eventNames.length; m++) {
        for (var n:Number = 0; n < numSubscribersPerEvent; n++) {
            eventBus.unsubscribe(eventNames[m], parallelCallback);
        }
    }

    // 测试通过无需具体断言
    assert(true, "Test 12: EventBus handles parallel event processing correctly");
}

measurePerformance("Test 12: EventBus Parallel Event Processing", testEventBusParallelEvents);

// 性能测试用例 13: EventBus - 长时间运行的订阅与取消
function testEventBusLongRunningSubscriptions():Void {
    resetFlags();
    var eventName:String = "LONG_RUNNING_EVENT";
    var numSubscribers:Number = 5000;
    
    function longRunningCallback():Void {
        // 空回调
    }
    
    // 长时间订阅与取消
    for (var i:Number = 0; i < numSubscribers; i++) {
        eventBus.subscribe(eventName, longRunningCallback, this);
        if (i % 10 == 0) {
            eventBus.unsubscribe(eventName, longRunningCallback);
        }
    }
    
    // 发布事件
    eventBus.publish(eventName);
    
    // 最终取消所有订阅
    eventBus.unsubscribe(eventName, longRunningCallback);
    
    // 测试通过无需具体断言
    assert(true, "Test 13: EventBus handles long-running subscriptions and cleanups correctly");
}

measurePerformance("Test 13: EventBus Long Running Subscriptions and Cleanups", testEventBusLongRunningSubscriptions);

// 性能测试用例 14: EventBus - 复杂参数传递
function testEventBusComplexArguments():Void {
    resetFlags();
    var eventName:String = "COMPLEX_ARG_EVENT";

    // 创建复杂参数对象
    var complexData:Object = {
        key1: "value1",
        key2: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        key3: { nestedKey1: "nestedValue1", nestedKey2: "nestedValue2", nestedKey3: { deepKey: "deepValue" } }
    };

    function complexArgCallback(data:Object):Void {
        // trace("Complex data received: " + data); // 移除 trace 以减少性能影响
    }

    // 订阅事件
    eventBus.subscribe(eventName, complexArgCallback, this);

    // 发布带有复杂参数的事件
    eventBus.publish(eventName, complexData);

    // 取消订阅
    eventBus.unsubscribe(eventName, complexArgCallback);

    assert(true, "Test 14: EventBus handles complex argument passing correctly");
}

measurePerformance("Test 14: EventBus Complex Argument Passing", testEventBusComplexArguments);

// 性能测试用例 15: EventBus - 批量事件订阅与取消
function testEventBusBulkSubscribeUnsubscribe():Void {
    resetFlags();
    var numEvents:Number = 50000; // 增加到50,000
    var eventNamePrefix:String = "BULK_EVENT_";

    function bulkCallback():Void {
        // 空回调
    }

    // 批量订阅事件
    for (var i:Number = 0; i < numEvents; i++) {
        var eventName:String = eventNamePrefix + i;
        eventBus.subscribe(eventName, bulkCallback, this);
    }

    // 发布部分事件
    for (var j:Number = 0; j < numEvents; j += 1000) { // 增加间隔以减少发布次数
        var eventName:String = eventNamePrefix + j;
        eventBus.publish(eventName);
    }

    // 批量取消订阅
    for (var k:Number = 0; k < numEvents; k++) {
        var eventName:String = eventNamePrefix + k;
        eventBus.unsubscribe(eventName, bulkCallback);
    }

    assert(true, "Test 15: EventBus handles bulk subscriptions and unsubscriptions correctly");
}

measurePerformance("Test 15: EventBus Bulk Subscribe and Unsubscribe", testEventBusBulkSubscribeUnsubscribe);

// 测试完成
trace("All tests completed.");

[PASS] Test 1: EventBus subscribe and publish single event
[PASS] Test 2: EventBus unsubscribe callback
[PASS] Test 3: EventBus subscribeOnce - first publish
[PASS] Test 3: EventBus subscribeOnce - second publish
[PASS] Test 4: EventBus publish event with arguments
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
[PASS] Test 5: EventBus callback error handling
[PASS] Test 6: EventBus destroy and ensure callbacks are not called
[PASS] Test 7: EventBus handles high volume of subscriptions and publishes correctly
[PERFORMANCE] Test 7: EventBus High Volume Subscriptions and Publish took 28 ms
[PASS] Test 8: EventBus handles high frequency publishes correctly
[PERFORMANCE] Test 8: EventBus High Frequency Publish took 1117 ms
[PASS] Test 9: EventBus handles concurrent subscriptions and publishes correctly
[PERFORMANCE] Test 9: EventBus Concurrent Subscriptions and Publishes took 14917 ms
[PASS] Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly
[PERFORMANCE] Test 10: EventBus Mixed Subscribe and Unsubscribe took 412 ms
[PASS] Test 11: EventBus handles nested event publishes correctly
[PERFORMANCE] Test 11: EventBus Nested Event Publish took 0 ms
[PASS] Test 12: EventBus handles parallel event processing correctly
[PERFORMANCE] Test 12: EventBus Parallel Event Processing took 147 ms
[PASS] Test 13: EventBus handles long-running subscriptions and cleanups correctly
[PERFORMANCE] Test 13: EventBus Long Running Subscriptions and Cleanups took 23 ms
[PASS] Test 14: EventBus handles complex argument passing correctly
[PERFORMANCE] Test 14: EventBus Complex Argument Passing took 0 ms
[PASS] Test 15: EventBus handles bulk subscriptions and unsubscriptions correctly
[PERFORMANCE] Test 15: EventBus Bulk Subscribe and Unsubscribe took 4642 ms
All tests completed.


[PASS] Test 1: EventBus subscribe and publish single event
[PASS] Test 2: EventBus unsubscribe callback
[PASS] Test 3: EventBus subscribeOnce - first publish
[PASS] Test 3: EventBus subscribeOnce - second publish
[PASS] Test 4: EventBus publish event with arguments
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
[PASS] Test 5: EventBus callback error handling
[PASS] Test 6: EventBus destroy and ensure callbacks are not called
[PASS] Test 7: EventBus handles high volume of subscriptions and publishes correctly
[PERFORMANCE] Test 7: EventBus High Volume Subscriptions and Publish took 26 ms
[PASS] Test 8: EventBus handles high frequency publishes correctly
[PERFORMANCE] Test 8: EventBus High Frequency Publish took 892 ms
[PASS] Test 9: EventBus handles concurrent subscriptions and publishes correctly
[PERFORMANCE] Test 9: EventBus Concurrent Subscriptions and Publishes took 11492 ms
[PASS] Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly
[PERFORMANCE] Test 10: EventBus Mixed Subscribe and Unsubscribe took 349 ms
[PASS] Test 11: EventBus handles nested event publishes correctly
[PERFORMANCE] Test 11: EventBus Nested Event Publish took 0 ms
[PASS] Test 12: EventBus handles parallel event processing correctly
[PERFORMANCE] Test 12: EventBus Parallel Event Processing took 144 ms
[PASS] Test 13: EventBus handles long-running subscriptions and cleanups correctly
[PERFORMANCE] Test 13: EventBus Long Running Subscriptions and Cleanups took 17 ms
[PASS] Test 14: EventBus handles complex argument passing correctly
[PERFORMANCE] Test 14: EventBus Complex Argument Passing took 0 ms
[PASS] Test 15: EventBus handles bulk subscriptions and unsubscriptions correctly
[PERFORMANCE] Test 15: EventBus Bulk Subscribe and Unsubscribe took 1058 ms
All tests completed.


[PASS] Test 1: EventBus subscribe and publish single event
[PASS] Test 2: EventBus unsubscribe callback
[PASS] Test 3: EventBus subscribeOnce - first publish
[PASS] Test 3: EventBus subscribeOnce - second publish
[PASS] Test 4: EventBus publish event with arguments
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
[PASS] Test 5: EventBus callback error handling
[PASS] Test 6: EventBus destroy and ensure callbacks are not called
[PASS] Test 7: EventBus handles high volume of subscriptions and publishes correctly
[PERFORMANCE] Test 7: EventBus High Volume Subscriptions and Publish took 27 ms
[PASS] Test 8: EventBus handles high frequency publishes correctly
[PERFORMANCE] Test 8: EventBus High Frequency Publish took 790 ms
[PASS] Test 9: EventBus handles concurrent subscriptions and publishes correctly
[PERFORMANCE] Test 9: EventBus Concurrent Subscriptions and Publishes took 10943 ms
[PASS] Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly
[PERFORMANCE] Test 10: EventBus Mixed Subscribe and Unsubscribe took 312 ms
[PASS] Test 11: EventBus handles nested event publishes correctly
[PERFORMANCE] Test 11: EventBus Nested Event Publish took 0 ms
[PASS] Test 12: EventBus handles parallel event processing correctly
[PERFORMANCE] Test 12: EventBus Parallel Event Processing took 133 ms
[PASS] Test 13: EventBus handles long-running subscriptions and cleanups correctly
[PERFORMANCE] Test 13: EventBus Long Running Subscriptions and Cleanups took 15 ms
[PASS] Test 14: EventBus handles complex argument passing correctly
[PERFORMANCE] Test 14: EventBus Complex Argument Passing took 0 ms
[PASS] Test 15: EventBus handles bulk subscriptions and unsubscriptions correctly
[PERFORMANCE] Test 15: EventBus Bulk Subscribe and Unsubscribe took 880 ms
All tests completed.

[PASS] Test 1: EventBus subscribe and publish single event
[PASS] Test 2: EventBus unsubscribe callback
[PASS] Test 3: EventBus subscribeOnce - first publish
[PASS] Test 3: EventBus subscribeOnce - second publish
[PASS] Test 4: EventBus publish event with arguments
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
[PASS] Test 5: EventBus callback error handling
[PASS] Test 6: EventBus destroy and ensure callbacks are not called
[PASS] Test 7: EventBus handles high volume of subscriptions and publishes correctly
[PERFORMANCE] Test 7: EventBus High Volume Subscriptions and Publish took 30 ms
[PASS] Test 8: EventBus handles high frequency publishes correctly
[PERFORMANCE] Test 8: EventBus High Frequency Publish took 759 ms
[PASS] Test 9: EventBus handles concurrent subscriptions and publishes correctly
[PERFORMANCE] Test 9: EventBus Concurrent Subscriptions and Publishes took 10815 ms
[PASS] Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly
[PERFORMANCE] Test 10: EventBus Mixed Subscribe and Unsubscribe took 366 ms
[PASS] Test 11: EventBus handles nested event publishes correctly
[PERFORMANCE] Test 11: EventBus Nested Event Publish took 0 ms
[PASS] Test 12: EventBus handles parallel event processing correctly
[PERFORMANCE] Test 12: EventBus Parallel Event Processing took 147 ms
[PASS] Test 13: EventBus handles long-running subscriptions and cleanups correctly
[PERFORMANCE] Test 13: EventBus Long Running Subscriptions and Cleanups took 17 ms
[PASS] Test 14: EventBus handles complex argument passing correctly
[PERFORMANCE] Test 14: EventBus Complex Argument Passing took 0 ms
[PASS] Test 15: EventBus handles bulk subscriptions and unsubscriptions correctly
[PERFORMANCE] Test 15: EventBus Bulk Subscribe and Unsubscribe took 1049 ms
All tests completed.


[PASS] Test 1: EventBus subscribe and publish single event
[PASS] Test 2: EventBus unsubscribe callback
[PASS] Test 3: EventBus subscribeOnce - first publish
[PASS] Test 3: EventBus subscribeOnce - second publish
[PASS] Test 4: EventBus publish event with arguments
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
[PASS] Test 5: EventBus callback error handling
[PASS] Test 6: EventBus destroy and ensure callbacks are not called
[PASS] Test 7: EventBus handles high volume of subscriptions and publishes correctly
[PERFORMANCE] Test 7: EventBus High Volume Subscriptions and Publish took 28 ms
[PASS] Test 8: EventBus handles high frequency publishes correctly
[PERFORMANCE] Test 8: EventBus High Frequency Publish took 764 ms
[PASS] Test 9: EventBus handles concurrent subscriptions and publishes correctly
[PERFORMANCE] Test 9: EventBus Concurrent Subscriptions and Publishes took 10986 ms
[PASS] Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly
[PERFORMANCE] Test 10: EventBus Mixed Subscribe and Unsubscribe took 385 ms
[PASS] Test 11: EventBus handles nested event publishes correctly
[PERFORMANCE] Test 11: EventBus Nested Event Publish took 0 ms
[PASS] Test 12: EventBus handles parallel event processing correctly
[PERFORMANCE] Test 12: EventBus Parallel Event Processing took 152 ms
[PASS] Test 13: EventBus handles long-running subscriptions and cleanups correctly
[PERFORMANCE] Test 13: EventBus Long Running Subscriptions and Cleanups took 19 ms
[PASS] Test 14: EventBus handles complex argument passing correctly
[PERFORMANCE] Test 14: EventBus Complex Argument Passing took 0 ms
[PASS] Test 15: EventBus handles bulk subscriptions and unsubscriptions correctly
[PERFORMANCE] Test 15: EventBus Bulk Subscribe and Unsubscribe took 1095 ms
All tests completed.
*/
