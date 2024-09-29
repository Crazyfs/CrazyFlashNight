import org.flashNight.neur.Event.*;

class org.flashNight.neur.Event.EventBus {
    private var listeners:Object; // 存储事件名称和对应的监听者数组
    private var allocator:Allocator; // 用于回调函数包装对象的分配

    // 构造函数
    public function EventBus()
    {
        this.listeners = {};
        this.allocator = new Allocator(new Array(), 5); // 预分配容量为5
    }

    /**
     * 订阅事件
     * @param eventName 事件名称
     * @param callback 回调函数
     */
    public function subscribe(eventName:String, callback:Function):Void {
        if (!this.listeners[eventName]) {
            this.listeners[eventName] = [];
        }
        // 防止重复订阅相同的回调
        if (this.findCallback(eventName, callback) == -1) {
            var allocIndex:Number = this.allocator.Alloc(callback);
            this.listeners[eventName].push(allocIndex);
        }
    }

    /**
     * 查找回调函数在监听者数组中的索引
     * @param eventName 事件名称
     * @param callback 回调函数
     * @return Number 回调函数的索引，如果未找到则返回 -1
     */
    private function findCallback(eventName:String, callback:Function):Number {
        if (!this.listeners[eventName]) return -1;
        for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
            var index:Number = this.listeners[eventName][i];
            var storedCallback:Function = this.allocator.getCallback(index);
            if (storedCallback === callback) {
                return i;
            }
        }
        return -1;
    }

    /**
     * 取消订阅事件
     * @param eventName 事件名称
     * @param callback 回调函数
     */
    public function unsubscribe(eventName:String, callback:Function):Void {
        if (this.listeners[eventName]) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                var storedCallback:Function = this.allocator.getCallback(index);
                if (storedCallback === callback) {
                    this.allocator.Free(index);
                    this.listeners[eventName].splice(i, 1);
                    break;
                }
            }
            // 如果没有监听者，删除事件名称
            if (this.listeners[eventName].length == 0) {
                delete this.listeners[eventName];
            }
        }
    }

    /**
     * 发布事件
     * @param eventName 事件名称
     * @param ...args 可选参数，传递给回调函数
     */
    public function publish(eventName:String):Void {
        if (this.listeners[eventName]) {
            // 获取所有额外参数
            var args:Array = [];
            for (var i:Number = 1; i < arguments.length; i++) {
                args.push(arguments[i]);
            }

            // 复制监听者数组，防止在回调中修改原数组
            var listenersCopy:Array = this.listeners[eventName].concat();
            for (var j:Number = 0; j < listenersCopy.length; j++) {
                var index:Number = listenersCopy[j];
                var callback:Function = this.allocator.getCallback(index);
                if (callback) {
                    try {
                        callback.apply(null, args); // 传递额外参数
                    } catch (error:Error) {
                        trace("Error executing callback for event '" + eventName + "': " + error.message);
                    }
                }
            }
        }
    }

    /**
     * 释放所有资源，适用于销毁 EventBus 时调用
     */
    public function destroy():Void {
        for (var eventName in this.listeners) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                this.allocator.Free(index);
            }
            delete this.listeners[eventName];
        }
        delete this.listeners;
        this.allocator.FreeAll();
    }

    /**
     * 一次性订阅事件（仅接收一次）
     * @param eventName 事件名称
     * @param callback 回调函数
     */
    public function subscribeOnce(eventName:String, callback:Function):Void {
        var self:EventBus = this;
        var wrapper:Function = function() {
            callback.apply(null, arguments);
            self.unsubscribe(eventName, wrapper);
        };
        this.subscribe(eventName, wrapper);
    }
}
