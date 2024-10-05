/**
 * Delegate 类用于将一个函数绑定到特定的作用域（对象上下文）。
 * 这对于确保在调用方法时，`this` 始终指向预期的对象非常有用。
 */
class org.flashNight.neur.Event.Delegate {
    
    /**
     * 创建一个委托函数，将指定方法绑定到给定的作用域。
     * 
     * @param scope  将作为 `this` 绑定的对象。
     * @param method 需要在该作用域内执行的函数。
     * @return 返回一个新函数，可以带参数调用，并在指定的作用域内执行。
     * 
     * 使用场景：
     * 1. 在事件处理器中防止 `this` 指向错误的对象。
     * 2. 将方法作为回调函数传递时确保作用域正确。
     * 3. 定时器或延迟执行的函数需要保持正确的上下文。
     */
    public static function create(scope:Object, method:Function):Function {
        // 如果传入的方法为空，则抛出错误
        if (method == null) {
            throw new Error("The provided method is undefined or null");
        }

        // 定义一个包装函数，将方法绑定到指定的作用域（scope）
        var wrappedFunction:Function = function() {
            // 优化参数传递，避免不必要的 apply 调用
            if (scope == null) {
                switch (arguments.length) {
                    case 0: return method(); 
                    case 1: return method(arguments[0]); 
                    case 2: return method(arguments[0], arguments[1]);
                    case 3: return method(arguments[0], arguments[1], arguments[2]);
                    case 4: return method(arguments[0], arguments[1], arguments[2], arguments[3]);
                    case 5: return method(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    default: return method.apply(null, arguments); // fallback to apply for more than 5 arguments
                }
            } else {
                switch (arguments.length) {
                    case 0: return method.call(scope);
                    case 1: return method.call(scope, arguments[0]);
                    case 2: return method.call(scope, arguments[0], arguments[1]);
                    case 3: return method.call(scope, arguments[0], arguments[1], arguments[2]);
                    case 4: return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3]);
                    case 5: return method.call(scope, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
                    default: return method.apply(scope, arguments);  // fallback for more than 5 arguments
                }
            }
        };

        // 记录原始回调函数和作用域，以便以后可以访问
        wrappedFunction._originalCallback = method;  // 保存原始回调方法
        wrappedFunction._scope = scope;              // 保存作用域

        return wrappedFunction; // 返回包装后的函数
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
