import org.flashNight.neur.Event.*;

/**
 * EventBus 类用于事件的订阅、发布和管理。
 * 它利用 Allocator 进行回调的内存管理，确保高效处理。
 */
class org.flashNight.neur.Event.EventBus {
    private var listeners:Object;   // 事件名 -> 回调函数的索引数组
    private var allocator:Allocator; // 分配器，用于管理回调函数

    /**
     * 构造函数，初始化事件总线和分配器。
     */
    public function EventBus() {
        this.listeners = {};   // 初始化空的事件监听器映射
        this.allocator = new Allocator(new Array(), 5);  // 初始化分配器，预分配 5 个空间
    }

    /**
     * 订阅事件。
     * 
     * @param eventName 事件的名称。
     * @param callback 要订阅的回调函数。
     * @param scope 回调执行时的作用域（`this` 指向的对象）。
     */
    public function subscribe(eventName:String, callback:Function, scope:Object):Void {
        if (!this.listeners[eventName]) {
            this.listeners[eventName] = [];
        }

        // 如果没有重复订阅，则添加
        if (this.findCallback(eventName, callback) == -1) {
            var wrappedCallback:Function = Delegate.create(scope, callback);  // 创建代理回调，绑定作用域
            var allocIndex:Number = this.allocator.Alloc(wrappedCallback);    // 分配回调并获取索引
            this.listeners[eventName].push(allocIndex);                       // 存储分配的索引
        }
    }

    /**
     * 查找指定事件名下的回调函数。
     * 
     * @param eventName 事件名称。
     * @param callback 回调函数。
     * @return 回调函数的索引，如果不存在则返回 -1。
     */
    private function findCallback(eventName:String, callback:Function):Number {
        if (!this.listeners[eventName]) return -1;

        for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
            var index:Number = this.listeners[eventName][i];
            var storedCallback:Function = this.allocator.getCallback(index);

            if (storedCallback._originalCallback === callback) {
                return i;
            }
        }
        return -1;
    }



    /**
     * 取消订阅事件。
     * 
     * @param eventName 事件名称。
     * @param callback 要取消的回调函数。
     */
    public function unsubscribe(eventName:String, callback:Function):Void {
        if (this.listeners[eventName]) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                var storedCallback:Function = this.allocator.getCallback(index);

                if (storedCallback._originalCallback === callback) {
                    this.allocator.Free(index);
                    this.listeners[eventName].splice(i, 1);
                    break;
                }
            }

            if (this.listeners[eventName].length == 0) {
                delete this.listeners[eventName];
            }
        }
    }


    /**
     * 发布事件，并向订阅者传递可选参数。
     * 
     * @param eventName 事件名称。
     * @param ...args 传递给回调的参数。
     */
    public function publish(eventName:String):Void {
        if (this.listeners[eventName]) {
            // 收集传递的参数
            var args:Array = [];
            for (var i:Number = 1; i < arguments.length; i++) {
                args.push(arguments[i]);
            }

            // 创建监听器的副本，避免在回调过程中修改原数组
            var listenersCopy:Array = this.listeners[eventName].concat();

            // 遍历回调并执行
            for (var j:Number = 0; j < listenersCopy.length; j++) {
                var index:Number = listenersCopy[j];
                var callback:Function = this.allocator.getCallback(index);

                if (callback) {
                    try {
                        callback.apply(null, args);  // 执行回调，并传递参数
                    } catch (error:Error) {
                        trace("Error executing callback for event '" + eventName + "': " + error.message);
                    }
                }
            }
        }
    }

    /**
     * 一次性订阅事件。
     * 
     * @param eventName 事件名称。
     * @param callback 要订阅的回调函数。
     * @param scope 回调执行时的作用域。
     */
    public function subscribeOnce(eventName:String, callback:Function, scope:Object):Void {
        var self:EventBus = this;
        var wrappedCallback:Function = Delegate.create(scope, callback);
        var wrapper:Function = function() {
            wrappedCallback.apply(null, arguments);
            self.unsubscribe(eventName, wrapper); // 使用 wrapper 而非 callback
        };
        wrapper._originalCallback = callback;
        this.subscribe(eventName, wrapper, scope);
    }




    /**
     * 销毁事件总线，释放所有监听器和回调。
     */
    public function destroy():Void {
        for (var eventName in this.listeners) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                this.allocator.Free(index);  // 释放所有回调
            }
            delete this.listeners[eventName];  // 删除事件名
        }

        this.allocator.FreeAll();  // 释放所有分配器资源
    }
}
