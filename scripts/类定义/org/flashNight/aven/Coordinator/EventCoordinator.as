/*
### EventCoordinator 类的 README 文档

这东西的路径：org.flashNight.aven.Coordinator.EventCoordinator

#### 概述
`EventCoordinator` 类是一个为 ActionScript 2 项目设计的高级事件管理系统。它允许开发者为任何 `MovieClip` 对象或其他事件支持的对象添加、移除、启用或禁用事件监听器。该类通过使用唯一标识符和集中式的事件管理机制，有效避免了事件处理器间的冲突和重复，同时提供了自动清理功能，以防止内存泄漏。

#### 功能
- **添加事件监听器** (`addEventListener`): 为目标对象添加一个事件监听器，并返回一个唯一标识符，用于后续操作。
- **移除事件监听器** (`removeEventListener`): 根据唯一标识符移除已添加的事件监听器。
- **清除所有事件监听器** (`clearEventListeners`): 移除目标对象上的所有事件监听器，通常用于对象销毁前的清理。
- **启用/禁用事件监听器** (`enableEventListeners`): 允许暂时禁用或重新启用目标对象上的所有事件监听器，便于管理复杂的交互逻辑。
- **自动清理** (`setupAutomaticCleanup`): 确保当对象被卸载时自动移除其上的所有事件监听器，避免内存泄漏。

#### 使用方法
```actionscript
var myMovieClip:MovieClip = _root.createEmptyMovieClip("myClip", _root.getNextHighestDepth());
var clickHandlerId = EventCoordinator.addEventListener(myMovieClip, "onPress", function() {
    trace("Clip pressed!");
});

// 根据需要移除监听器
EventCoordinator.removeEventListener(myMovieClip, "onPress", clickHandlerId);

// 清除对象上的所有事件监听器
EventCoordinator.clearEventListeners(myMovieClip);

// 禁用所有监听器
EventCoordinator.enableEventListeners(myMovieClip, false);

// 启用所有监听器
EventCoordinator.enableEventListeners(myMovieClip, true);
```

#### 性能注意事项
尽管 `EventCoordinator` 提供了方便的事件管理功能，但它的实现可能会在处理大量事件或频繁触发事件时影响性能。特别是在每次事件触发时，都需要遍历和执行多个事件处理器，这可能在性能敏感的场景中成为瓶颈。因此，不建议在复杂的负载情况下使用此系统。后续版本将探索性能优化的可能性，以改善这一点。

#### 未来计划
- **性能优化**：根据实际使用情况和反馈，我们计划进一步优化事件处理机制，减少性能开销。
- **更灵活的配置选项**：考虑增加更多的配置选项，以适应更多样化的使用需求。

*/


class org.flashNight.aven.Coordinator.EventCoordinator {
    private static var eventHandlers:Object = {};
    private static var nextID:Number = 0;

    // 添加事件监听器
    public static function addEventListener(target:Object, eventName:String, handler:Function):String {
        if (target == null || eventName == null || handler == null) {
            trace("Error: Invalid arguments in addEventListener.");
            return null;
        }
        var targetKey:String = getTargetKey(target);
        if (!eventHandlers[targetKey]) {
            eventHandlers[targetKey] = {};
            if (eventName != "onUnload") {
                setupAutomaticCleanup(target);  // 设置自动清理，除非事件名为 onUnload
            }
        }
        if (!eventHandlers[targetKey][eventName]) {
            eventHandlers[targetKey][eventName] = [];
        }

        var handlerID:String = "HID" + (nextID++);
        var handlerObj:Object = {id: handlerID, func: handler};
        eventHandlers[targetKey][eventName].push(handlerObj);

        var originalHandler:Function = target[eventName];
        target[eventName] = function() {
            var handlers:Array = eventHandlers[getTargetKey(this)][eventName];
            for (var i = 0; i < handlers.length; i++) {
                handlers[i].func.apply(this);
            }
            if (originalHandler) originalHandler.apply(this);
        };
        
        return handlerID;
    }

    // 移除特定的事件监听器
    public static function removeEventListener(target:Object, eventName:String, handlerID:String):Void {
        if (target == null || eventName == null || handlerID == null) {
            trace("Error: Invalid arguments in removeEventListener.");
            return;
        }
        var targetKey:String = getTargetKey(target);
        if (eventHandlers[targetKey] && eventHandlers[targetKey][eventName]) {
            var handlers:Array = eventHandlers[targetKey][eventName];
            for (var i:Number = 0; i < handlers.length; i++) {
                if (handlers[i].id === handlerID) {
                    handlers.splice(i, 1);
                    trace("Handler removed: " + handlerID);
                    break;
                }
            }
            if (handlers.length == 0) {
                delete eventHandlers[targetKey][eventName];
                target[eventName] = null;
                trace("All handlers for " + eventName + " removed.");
            }
        }
    }

    // 清除对象上的所有事件监听器
    public static function clearEventListeners(target:Object):Void {
        var targetKey:String = getTargetKey(target);
        if (eventHandlers[targetKey]) {
            for (var eventName:String in eventHandlers[targetKey]) {
                target[eventName] = null;
            }
            delete eventHandlers[targetKey];
        }
    }

    // 启用或禁用对象上的所有事件监听器
    public static function enableEventListeners(target:Object, enable:Boolean):Void {
        var targetKey:String = getTargetKey(target);
        if (eventHandlers[targetKey]) {
            for (var eventName:String in eventHandlers[targetKey]) {
                if (enable) {
                    // 恢复原始事件处理器
                    restoreEventHandlers(target, eventName);
                } else {
                    // 临时移除事件处理器
                    target[eventName] = function() {};
                }
            }
        }
    }

    // 内部帮助方法：恢复对象上的事件处理函数
    private static function restoreEventHandlers(target:Object, eventName:String):Void {
        var targetKey:String = getTargetKey(target);
        var originalHandler:Function = target[eventName];
        var handlers:Array = eventHandlers[targetKey][eventName];
        target[eventName] = function() {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i].func.apply(this);
            }
            if (originalHandler) originalHandler.apply(this);
        };
    }

    // 设置自动清理
    private static function setupAutomaticCleanup(target:Object):Void {
        var originalUnload:Function = target.onUnload;
        target.onUnload = function() {
            clearEventListeners(this);
            if (originalUnload) {
                originalUnload.apply(this);
            }
        };
    }

    // 生成目标对象的唯一键
    private static function getTargetKey(target:Object):String {
        if (!target._uniqueID) {
            target._uniqueID = "UID" + (nextID++);
        }
        return target._uniqueID;
    }

    // 添加 onUnload 回调
    public static function addUnloadCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onUnload", handler);
    }

    // 添加 onLoad 回调
    public static function addLoadCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onLoad", handler);
    }

    // 添加 onEnterFrame 回调
    public static function addEnterFrameCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onEnterFrame", handler);
    }

    // 添加 onPress 回调
    public static function addPressCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onPress", handler);
    }

    // 添加 onRelease 回调
    public static function addReleaseCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onRelease", handler);
    }

    // 添加 onRollOver 回调
    public static function addRollOverCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onRollOver", handler);
    }

    // 添加 onRollOut 回调
    public static function addRollOutCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onRollOut", handler);
    }

    // 添加 onMouseMove 回调
    public static function addMouseMoveCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onMouseMove", handler);
    }

    // 添加 onMouseDown 回调
    public static function addMouseDownCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onMouseDown", handler);
    }

    // 添加 onMouseUp 回调
    public static function addMouseUpCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onMouseUp", handler);
    }

    // 添加 onKeyDown 回调
    public static function addKeyDownCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onKeyDown", handler);
    }

    // 添加 onKeyUp 回调
    public static function addKeyUpCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onKeyUp", handler);
    }

    // 添加 onDragOut 回调
    public static function addDragOutCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onDragOut", handler);
    }

    // 添加 onDragOver 回调
    public static function addDragOverCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onDragOver", handler);
    }

    // 添加 onData 回调 (用于动态加载的影片剪辑)
    public static function addDataCallback(target:Object, handler:Function):String {
        return addEventListener(target, "onData", handler);
    }
}
