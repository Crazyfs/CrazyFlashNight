class org.flashNight.neur.Event.Delegate {
    // 缓存对象，用于存储已创建的委托函数
    private static var cache:Object = {};
    
    // 唯一标识符计数器，用于为每个方法和作用域分配唯一的ID
    private static var uidCounter:Number = 0;

    /**
     * 创建一个委托函数，将指定方法绑定到给定的作用域。
     * 利用缓存机制优化委托函数的创建，避免重复创建相同的委托函数。
     * 
     * 该方法通过为每个方法和作用域分配唯一的标识符，并将包装后的委托函数存储在缓存中，
     * 从而确保在多次绑定相同方法和作用域时，可以复用已存在的委托函数，提升性能。
     * 
     * 这种实现方式在事件处理和回调机制中尤为重要，因为它能够显著减少内存占用和提高执行效率，
     * 尤其在需要频繁绑定和解绑事件处理函数的场景下，表现出色。
     * 
     * @param scope  将作为 `this` 绑定的对象。如果为 `null`，则方法将在全局作用域中执行。
     * @param method 需要在该作用域内执行的函数。必须为有效的函数引用，不能为 `null` 或 `undefined`。
     * @return 返回一个新函数，可以带参数调用，并在指定的作用域内执行。若相同的 `scope` 和 `method` 已存在，
     *         则返回缓存中的委托函数，避免重复创建。
     */
    public static function create(scope:Object, method:Function):Function {
        // 如果传入的方法为空，则抛出错误，确保后续操作的合法性
        if (method == null) {
            throw new Error("The provided method is undefined or null");
        }

        var cacheKey:Number;        // 用于在缓存中查找或存储委托函数的唯一键
        var loccache = cache;       // 本地引用缓存对象，提升访问速度

        // 为方法分配唯一标识符，确保每个方法都有一个独特的ID
        if (method.__delegateUID == undefined) {
            // 方法尚未分配 UID，直接分配并创建包装函数
            method.__delegateUID = uidCounter++;
            
            if (scope == null) {
                // 当 scope 为 null 时，仅使用方法的 UID 作为缓存键
                cacheKey = method.__delegateUID;
                
                /**
                 * 定义包装函数，该函数在调用时会执行原始方法。
                 * 根据传入参数的数量，选择最优的调用方式以提升性能。
                 * 对于参数数量超过5个的情况，使用 apply 方法进行调用。
                 */
                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method();
                    else if (len == 1) return method(arguments[0]);
                    else if (len == 2) return method(arguments[0], arguments[1]);
                    else if (len == 3) return method(arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method(arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(null, arguments);  // 参数超过5个时，使用 apply 调用
                };
            } else {
                // 确保 scope 对象有唯一的 UID，以区分不同的作用域
                if (scope.__scopeUID == undefined) {
                    scope.__scopeUID = uidCounter++;
                }
                // 使用 scope 的 UID 和方法的 UID 组合生成缓存键，确保每个作用域-方法组合唯一
                cacheKey = (scope.__scopeUID << 16) | method.__delegateUID;
                
                /**
                 * 定义包装函数，该函数在调用时会以指定的作用域执行原始方法。
                 * 根据传入参数的数量，选择最优的调用方式以提升性能。
                 * 对于参数数量超过5个的情况，使用 apply 方法进行调用。
                 */
                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method.call(scope);
                    else if (len == 1) return method.call(scope, arguments[0]);
                    else if (len == 2) return method.call(scope, arguments[0], arguments[1]);
                    else if (len == 3) return method.call(scope, arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(scope, arguments);  // 参数超过5个时，使用 apply 调用
                };
            }

            // 将包装函数存入缓存，以便后续复用
            loccache[cacheKey] = wrappedFunction;
            
            // 返回包装后的函数，供调用者使用
            return wrappedFunction;
        } else {
            // 方法已经有 UID，尝试从缓存中获取包装函数
            if (scope == null) {
                cacheKey = method.__delegateUID;

                // 从缓存中查找是否已存在对应的包装函数
                var cachedFunction:Function = loccache[cacheKey];
                if (cachedFunction != undefined) {
                    // 如果缓存中存在，直接返回该包装函数，避免重复创建
                    return cachedFunction;
                }

                /**
                 * 如果缓存中不存在，则创建新的包装函数。
                 * 根据参数数量选择最优调用方式，提升性能。
                 */
                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method();
                    else if (len == 1) return method(arguments[0]);
                    else if (len == 2) return method(arguments[0], arguments[1]);
                    else if (len == 3) return method(arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method(arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(null, arguments);  // 参数超过5个时，使用 apply 调用
                };

            } else {
                // 确保 scope 对象有唯一的 UID，以区分不同的作用域
                if (scope.__scopeUID == undefined) {
                    scope.__scopeUID = uidCounter++;
                }
                // 使用 scope 的 UID 和方法的 UID 组合生成缓存键，确保每个作用域-方法组合唯一
                cacheKey = (scope.__scopeUID << 16) | method.__delegateUID;

                // 从缓存中查找是否已存在对应的包装函数
                var cachedFunction:Function = loccache[cacheKey];
                if (cachedFunction != undefined) {
                    // 如果缓存中存在，直接返回该包装函数，避免重复创建
                    return cachedFunction;
                }

                /**
                 * 如果缓存中不存在，则创建新的包装函数。
                 * 根据参数数量选择最优调用方式，提升性能。
                 */
                var wrappedFunction:Function = function() {
                    var len = arguments.length;
                    if (len == 0) return method.call(scope);
                    else if (len == 1) return method.call(scope, arguments[0]);
                    else if (len == 2) return method.call(scope, arguments[0], arguments[1]);
                    else if (len == 3) return method.call(scope, arguments[0], arguments[1], arguments[2]);
                    else if (len == 4) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3]);
                    else if (len == 5) return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    else return method.apply(scope, arguments);  // 参数超过5个时，使用 apply 调用
                };
            }

            // 将新创建的包装函数存入缓存，以便后续复用
            loccache[cacheKey] = wrappedFunction;
            
            // 返回包装后的函数，供调用者使用
            return wrappedFunction;
        }
    }
    
    /**
     * 清理缓存中的所有委托函数。
     * 需要在适当的时候调用，以防止内存泄漏。
     * 
     * 由于缓存中存储了所有创建过的委托函数，这些函数会持续占用内存空间。
     * 在不再需要这些委托函数时，应调用此方法清空缓存，以释放内存资源。
     * 特别是在大型应用程序或长时间运行的程序中，定期清理缓存有助于维持内存使用的稳定性。
     */
    public static function clearCache():Void {
        // 遍历缓存对象中的所有键，并逐一删除对应的委托函数
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
