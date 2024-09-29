import org.flashNight.neur.Event.*;

class org.flashNight.neur.Event.EventBus {
    private var listeners:Object;
    private var allocator:Allocator;

    public function EventBus() {
        this.listeners = {};
        this.allocator = new Allocator(new Array(), 5);
    }

    public function subscribe(eventName:String, callback:Function, scope:Object):Void {
        if (!this.listeners[eventName]) {
            this.listeners[eventName] = [];
        }
        if (this.findCallback(eventName, callback) == -1) {
            var wrappedCallback:Function = Delegate.create(scope, callback); // 使用 Delegate.create
            var allocIndex:Number = this.allocator.Alloc(wrappedCallback);
            this.listeners[eventName].push(allocIndex);
        }
    }

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
            if (this.listeners[eventName].length == 0) {
                delete this.listeners[eventName];
            }
        }
    }

    public function publish(eventName:String):Void {
        if (this.listeners[eventName]) {
            var args:Array = [];
            for (var i:Number = 1; i < arguments.length; i++) {
                args.push(arguments[i]); // 收集参数
            }

            var listenersCopy:Array = this.listeners[eventName].concat();
            for (var j:Number = 0; j < listenersCopy.length; j++) {
                var index:Number = listenersCopy[j];
                var callback:Function = this.allocator.getCallback(index);
                if (callback) {
                    try {
                        callback.apply(null, args); // 确保参数传递
                    } catch (error:Error) {
                        trace("Error executing callback for event '" + eventName + "': " + error.message);
                    }
                }
            }
        }
    }

    public function subscribeOnce(eventName:String, callback:Function, scope:Object):Void {
        var self:EventBus = this;
        var wrappedCallback:Function = Delegate.create(scope, callback);
        var wrapper:Function = function() {
            wrappedCallback.apply(null, arguments); // 调用原始回调
            self.unsubscribe(eventName, wrapper); // 触发后取消订阅
        };
        this.subscribe(eventName, wrapper, scope);
        trace("Subscribed once for event " + eventName);
    }

    public function destroy():Void {
        for (var eventName in this.listeners) {
            for (var i:Number = 0; i < this.listeners[eventName].length; i++) {
                var index:Number = this.listeners[eventName][i];
                this.allocator.Free(index);
            }
            delete this.listeners[eventName];
        }
        this.allocator.FreeAll();
    }
}
