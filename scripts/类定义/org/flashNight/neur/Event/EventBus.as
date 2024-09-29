import org.flashNight.neur.Event.*;


class org.flashNight.neur.Event.EventBus {
    private var listeners:Object; // 存储事件名称和对应的监听者数组
    private var allocator:Allocator; // 用于回调函数包装对象的分配

    // 构造函数
    public function EventBus()
    {
        this.listeners = {};
        this.allocator = new Allocator(new Array());
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
        if (this.listeners[eventName].indexOf(callback) == -1) {
            var allocIndex:Number = this.allocator.Alloc(callback);
            this.listeners[eventName].push(allocIndex);
        }
    }

    /**
     * 取消订阅事件
     * @param eventName 事件名称
     * @param callback 回调函数
     */
    public function unsubscribe(eventName:String, callback:Function):Void {
        if (this.listeners[eventName]) {
            var allocIndex:Number = -1;
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                if (this.allocator.pool[index] === callback) {
                    allocIndex = index;
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
     * @param args 可选参数，传递给回调函数
     */
    public function publish(eventName:String, ...args):Void {
        if (this.listeners[eventName]) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                var callback:Function = this.allocator.pool[index];
                if (callback) {
                    try {
                        callback.apply(null, args);
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
}
