class org.flashNight.neur.Event.Delegate {
    // 缓存对象，用于存储已创建的委托函数
    private static var cache:Object = {};
    
    // 唯一标识符计数器
    private static var uidCounter:Number = 0;

    /**
     * 创建一个委托函数，将指定方法绑定到给定的作用域。
     * 利用缓存机制优化委托函数的创建，避免重复创建相同的委托函数。
     * 
     * @param scope  将作为 `this` 绑定的对象。
     * @param method 需要在该作用域内执行的函数。
     * @return 返回一个新函数，可以带参数调用，并在指定的作用域内执行。
     */
    public static function create(scope:Object, method:Function):Function {
        // 如果传入的方法为空，则抛出错误
        if (method == null) {
            throw new Error("The provided method is undefined or null");
        }

        var cacheKey:Number;
        var loccache = cache;

        // 为方法分配唯一标识符
        if (method.__delegateUID == undefined) {
            // 方法尚未分配 UID，直接分配并创建包装函数
            method.__delegateUID = uidCounter++;
            
            if (scope == null) {
                // 当 scope 为 null 时，仅使用方法的 UID 作为缓存键
                cacheKey = method.__delegateUID;
                
                // 定义包装函数
                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method();
                    else if (len == 1) return method(arguments[0]);
                    else if (len == 2) return method(arguments[0], arguments[1]);
                    else if (len == 3) return method(arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method(arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(null, arguments);  // 参数超过 5 个时，使用 apply
                };
            } else {
                // 确保 scope 对象有唯一的 UID
                if (scope.__scopeUID == undefined) {
                    scope.__scopeUID = uidCounter++;
                }
                // 使用 scope 的 UID 和方法的 UID 组合生成缓存键
                cacheKey = (scope.__scopeUID << 16) | method.__delegateUID;
                
                // 定义包装函数
                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method.call(scope);
                    else if (len == 1) return method.call(scope, arguments[0]);
                    else if (len == 2) return method.call(scope, arguments[0], arguments[1]);
                    else if (len == 3) return method.call(scope, arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(scope, arguments);  // 参数超过 5 个时，使用 apply
                };
            }

            // 将包装函数存入缓存
            loccache[cacheKey] = wrappedFunction;
            
            return wrappedFunction; // 返回包装后的函数
        } else {
            // 方法已经有 UID，尝试从缓存中获取包装函数
            if (scope == null) {
                cacheKey = method.__delegateUID;

                var cachedFunction:Function = loccache[cacheKey];
                if (cachedFunction != undefined) {
                    return cachedFunction;
                }

                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method();
                    else if (len == 1) return method(arguments[0]);
                    else if (len == 2) return method(arguments[0], arguments[1]);
                    else if (len == 3) return method(arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method(arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(null, arguments);  // 参数超过 5 个时，使用 apply
                };

            } else {
                if (scope.__scopeUID == undefined) {
                    scope.__scopeUID = uidCounter++;
                }
                cacheKey = (scope.__scopeUID << 16) | method.__delegateUID;

                var cachedFunction:Function = loccache[cacheKey];
                if (cachedFunction != undefined) {
                    return cachedFunction;
                }

                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method.call(scope);
                    else if (len == 1) return method.call(scope, arguments[0]);
                    else if (len == 2) return method.call(scope, arguments[0], arguments[1]);
                    else if (len == 3) return method.call(scope, arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(scope, arguments);  // 参数超过 5 个时，使用 apply
                };
            }

            // 将包装函数存入缓存
            loccache[cacheKey] = wrappedFunction;
            
            return wrappedFunction; // 返回包装后的函数
        }
    }
    
    /**
     * 清理缓存中的所有委托函数。
     * 需要在适当的时候调用，以防止内存泄漏。
     */
    public static function clearCache():Void {
        for (var key:String in cache) {
            delete cache[key];
        }
    }
}


/*

// 假设该代码在 _root 上下文执行

// 定义一个简单的类用于测试 scope 绑定
var TestClass = function(name) {
    this.name = name;
};

TestClass.prototype.sayHello = function(greeting) {
    return greeting + ", my name is " + this.name;
};

// 定义不同的函数用于测试
function globalTestFunction() {
    return "Global function called!";
}

// 实例化一个对象用于绑定 scope
var testInstance = new TestClass("Alice");

// 测试用例 1：没有参数的函数绑定到全局作用域
var globalDelegate = org.flashNight.neur.Event.Delegate.create(null, globalTestFunction);
trace(globalDelegate()); // 输出: Global function called!

// 测试用例 2：带参数的函数绑定到指定对象作用域
var helloDelegate = org.flashNight.neur.Event.Delegate.create(testInstance, testInstance.sayHello);
trace(helloDelegate("Hello")); // 输出: Hello, my name is Alice

// 测试用例 3：改变作用域后执行相同的方法
var anotherInstance = new TestClass("Bob");
var anotherHelloDelegate = org.flashNight.neur.Event.Delegate.create(anotherInstance, testInstance.sayHello);
trace(anotherHelloDelegate("Hi")); // 输出: Hi, my name is Bob

// 测试用例 4：测试超过5个参数的调用
function testMultipleArguments(arg1, arg2, arg3, arg4, arg5, arg6) {
    return [arg1, arg2, arg3, arg4, arg5, arg6].join(", ");
}

var multiArgDelegate = org.flashNight.neur.Event.Delegate.create(null, testMultipleArguments);
trace(multiArgDelegate(1, 2, 3, 4, 5, 6)); // 输出: 1, 2, 3, 4, 5, 6

// 测试用例 5：测试 null method 抛出错误
try {
    var nullDelegate = org.flashNight.neur.Event.Delegate.create(null, null);
    trace(nullDelegate());
} catch (e:Error) {
    trace("Error caught: " + e.message); // 输出: Error caught: The provided method is undefined or null
}


*/
