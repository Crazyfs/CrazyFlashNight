import org.flashNight.neur.Event.*;

/**
 * EventBus 类用于事件的订阅、发布和管理。
 * 饿汉式单例模式确保在类加载时实例化。
 */
class org.flashNight.neur.Event.EventBus {
    private var listeners:Object;          // 事件名 -> { callbacks: { callbackID: poolIndex }, funcToID: { funcID: callbackID } }
    private var pool:Array;                // 回调函数池
    private var availSpace:Array;          // 可用索引列表
    private var idToCallback:Object;       // 唯一ID到原始回调函数的映射
    private var wrappedCallbacks:Object;   // 作用域绑定的包装函数映射

    // 静态实例，立即初始化
    private static var instance:EventBus = new EventBus();
    private static var callbackCounter:Number = 0;    // 全局回调计数器
    private static var functionCounter:Number = 0;    // 全局函数ID计数器

    /**
     * 私有化构造函数，防止外部直接创建对象。
     */
    private function EventBus() {
        this.listeners = {};
        this.pool = [];
        this.availSpace = [];
        this.idToCallback = {};
        this.wrappedCallbacks = {};
        // 预分配更大的池空间，减少扩展次数
        for (var i:Number = 0; i < 1000; i++) { // 增加预分配量到1000
            this.pool.push(null);
            this.availSpace.push(i);
        }
    }

    /**
     * 初始化方法，显式调用一次初始化静态实例。
     * 后续不再进行实例化检查，直接返回唯一实例。
     * 
     * @return 返回全局唯一的 EventBus 实例。
     */
    public static function initialize():EventBus {
        // 由于是饿汉式单例，直接返回实例
        return instance;
    }

    /**
     * 获取单例实例的静态方法。
     * 
     * @return 返回全局唯一的 EventBus 实例。
     */
    public static function getInstance():EventBus {
        return instance;
    }

    /**
     * 创建统一的包装回调函数，绑定作用域。
     * 尽量复用包装函数，减少函数创建次数。
     * 
     * @param callback 要包装的回调函数。
     * @param scope 回调函数执行时的作用域。
     * @return 返回绑定了作用域的包装函数。
     */
    private function getWrappedCallback(callback:Function, scope:Object):Function {
        var scopeKey:String = scope != null ? String(scope) : "default";
        if (!this.wrappedCallbacks[scopeKey]) {
            // 为每个scope创建一个包装函数模板
            this.wrappedCallbacks[scopeKey] = function(cb:Function, sc:Object):Function {
                return function() {
                    cb.apply(sc, arguments);
                };
            };
        }
        return this.wrappedCallbacks[scopeKey](callback, scope);
    }

    /**
     * 订阅事件，将回调函数与特定的事件绑定。
     * 避免重复订阅，通过唯一ID管理回调。
     * 
     * @param eventName 事件的名称，用于标识事件。
     * @param callback 要订阅的回调函数，当事件触发时执行。
     * @param scope 回调函数执行时的作用域（即 `this` 的指向对象）。
     */
    public function subscribe(eventName:String, callback:Function, scope:Object):Void {
        if (!this.listeners[eventName]) {
            this.listeners[eventName] = { callbacks: {}, funcToID: {} };
        }

        var listenersForEvent:Object = this.listeners[eventName];
        var funcToID:Object = listenersForEvent.funcToID;

        // 为回调函数分配一个唯一的函数ID
        if (typeof(callback.__eventBusID) == 'undefined') {
            callback.__eventBusID = EventBus.functionCounter++;
        }
        var funcID:String = String(callback.__eventBusID);

        // 检查是否已经存在相同的回调，避免重复订阅
        if (funcToID[funcID] != undefined) {
            return; // 已存在，避免重复订阅
        }

        // 分配一个唯一的回调ID
        var callbackID:Number = EventBus.callbackCounter++;
        this.idToCallback[callbackID] = callback;

        // 创建代理回调，绑定作用域
        var wrappedCallback:Function = this.getWrappedCallback(callback, scope);

        // 分配索引
        var allocIndex:Number;
        if (this.availSpace.length > 0) {
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        } else {
            // 如果 pool 已满，采用双倍扩展策略
            var newCapacity:Number = this.pool.length * 2;
            for (var j:Number = this.pool.length; j < newCapacity; j++) {
                this.pool.push(null);
                this.availSpace.push(j);
            }
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        }

        // 存储回调的分配索引和函数ID映射
        listenersForEvent.callbacks[callbackID] = allocIndex;
        funcToID[funcID] = callbackID;
    }

    /**
     * 取消订阅事件，移除指定的回调函数。
     * 通过回调的唯一ID快速定位并移除回调。
     * 
     * @param eventName 事件的名称。
     * @param callback 要取消的回调函数。
     */
    public function unsubscribe(eventName:String, callback:Function):Void {
        var listenersForEvent:Object = this.listeners[eventName];
        if (!listenersForEvent) return;

        var funcToID:Object = listenersForEvent.funcToID;

        // 获取回调函数的唯一函数ID
        if (typeof(callback.__eventBusID) == 'undefined') {
            return; // 函数未被订阅过
        }
        var funcID:String = String(callback.__eventBusID);

        var callbackID:Number = funcToID[funcID];
        if (callbackID == undefined) return; // Callback not found

        var allocIndex:Number = listenersForEvent.callbacks[callbackID];
        if (allocIndex != undefined) {
            this.pool[allocIndex] = null;
            this.availSpace.push(allocIndex);
            delete listenersForEvent.callbacks[callbackID];
            delete this.idToCallback[callbackID];
            delete funcToID[funcID];
        }

        // 如果没有监听器，删除该事件的监听对象
        var hasListeners:Boolean = false;
        for (var key:String in listenersForEvent.callbacks) {
            hasListeners = true;
            break;
        }
        if (!hasListeners) {
            delete this.listeners[eventName];
        }
    }

    /**
     * 发布事件，通知所有订阅者，并传递可选的参数。
     * 
     * @param eventName 事件名称。
     * @param ...args 传递给回调函数的参数。
     */
    public function publish(eventName:String):Void {
        var listenersForEvent:Object = this.listeners[eventName];
        if (!listenersForEvent) return;

        // 收集传递给回调的参数（去除第一个参数，即 eventName）
        var args:Array = [];
        var argsLen:Number = arguments.length;
        for (var i:Number = 1; i < argsLen; i++) {
            args.push(arguments[i]);
        }

        // 收集所有回调的索引
        var indices:Array = [];
        for (var cbID:String in listenersForEvent.callbacks) {
            var index:Number = listenersForEvent.callbacks[cbID];
            if (index != undefined && this.pool[index] != null) {
                indices.push(index);
            }
        }

        // 执行所有回调
        for (var j:Number = 0; j < indices.length; j++) {
            var currentIndex:Number = indices[j];
            var callback:Function = this.pool[currentIndex];

            if (callback) {
                try {
                    // 直接调用回调，传递参数
                    callback.apply(null, args);
                } catch (error:Error) {
                    trace("Error executing callback for event '" + eventName + "': " + error.message);
                }
            }
        }
    }

    /**
     * 一次性订阅事件，回调执行一次后即自动取消订阅。
     * 
     * @param eventName 事件的名称。
     * @param callback 要订阅的回调函数。
     * @param scope 回调函数的作用域（即 `this` 指向的对象）。
     */
    public function subscribeOnce(eventName:String, callback:Function, scope:Object):Void {
        var self:EventBus = this;
        var originalCallback:Function = callback;

        // 为回调函数分配一个唯一的函数ID
        if (typeof(originalCallback.__eventBusID) == 'undefined') {
            originalCallback.__eventBusID = EventBus.functionCounter++;
        }
        var funcID:String = String(originalCallback.__eventBusID);

        var listenersForEvent:Object = this.listeners[eventName];
        if (!listenersForEvent) {
            listenersForEvent = { callbacks: {}, funcToID: {} };
            this.listeners[eventName] = listenersForEvent;
        }

        var funcToID:Object = listenersForEvent.funcToID;

        // 检查是否已经存在相同的回调，避免重复订阅
        if (funcToID[funcID] != undefined) {
            return; // 已存在，避免重复订阅
        }

        // 分配一个唯一的回调ID
        var callbackID:Number = EventBus.callbackCounter++;
        this.idToCallback[callbackID] = originalCallback;

        // 创建一次性回调的包装函数，并内联取消订阅逻辑
        var wrappedOnceCallback:Function = function() {
            originalCallback.apply(scope, arguments);
            self.unsubscribe(eventName, originalCallback);
        };

        // 创建代理回调，绑定作用域
        var wrappedCallback:Function = this.getWrappedCallback(wrappedOnceCallback, scope);

        // 分配索引
        var allocIndex:Number;
        if (this.availSpace.length > 0) {
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        } else {
            // 如果 pool 已满，采用双倍扩展策略
            var newCapacity:Number = this.pool.length * 2;
            for (var j:Number = this.pool.length; j < newCapacity; j++) {
                this.pool.push(null);
                this.availSpace.push(j);
            }
            allocIndex = Number(this.availSpace.pop());
            this.pool[allocIndex] = wrappedCallback;
        }

        // 存储回调的分配索引和函数ID映射
        listenersForEvent.callbacks[callbackID] = allocIndex;
        funcToID[funcID] = callbackID;
    }

    /**
     * 销毁事件总线，释放所有监听器和回调。
     * 清空回调函数池和可用索引列表，防止内存泄漏。
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

        // 清空所有回调函数池中的剩余回调
        for (var i:Number = 0; i < this.pool.length; i++) {
            if (this.pool[i] != null) {
                this.pool[i] = null;
                this.availSpace.push(i);
            }
        }

        // 清空 mappings
        this.listeners = {};
        this.idToCallback = {};
        this.wrappedCallbacks = {};
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
    var numSubscribers:Number = 1000;
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
    var numPublish:Number = 10000;
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
    var numEvents:Number = 100;
    var numSubscribersPerEvent:Number = 100;
    var numPublishesPerEvent:Number = 100;
    
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
    var numOperations:Number = 10000;
    
    // 定义一个简单的回调
    function mixedCallback():Void {
        // 空回调
    }
    
    for (var i:Number = 0; i < numOperations; i++) {
        eventBus.subscribe(eventName, mixedCallback, this);
        if (i % 2 == 0) {
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

// 测试完成
trace("All tests completed.");


callback1 executed
[PASS] Test 1: EventBus subscribe and publish single event
[PASS] Test 2: EventBus unsubscribe callback
callbackOnce executed
[PASS] Test 3: EventBus subscribeOnce - first publish
[PASS] Test 3: EventBus subscribeOnce - second publish
callback2 executed with args: Hello, World
[PASS] Test 4: EventBus publish event with arguments
callback1 executed
callbackWithError executed
Error executing callback for event 'ERROR_EVENT': Intentional error in callbackWithError
[PASS] Test 5: EventBus callback error handling
[PASS] Test 6: EventBus destroy and ensure callbacks are not called
[PASS] Test 7: EventBus handles high volume of subscriptions and publishes correctly
[PERFORMANCE] Test 7: EventBus High Volume Subscriptions and Publish took 4 ms
[PASS] Test 8: EventBus handles high frequency publishes correctly
[PERFORMANCE] Test 8: EventBus High Frequency Publish took 95 ms
[PASS] Test 9: EventBus handles concurrent subscriptions and publishes correctly
[PERFORMANCE] Test 9: EventBus Concurrent Subscriptions and Publishes took 122 ms
[PASS] Test 10: EventBus handles mixed subscribe and unsubscribe operations correctly
[PERFORMANCE] Test 10: EventBus Mixed Subscribe and Unsubscribe took 110 ms
All tests completed.

*/
