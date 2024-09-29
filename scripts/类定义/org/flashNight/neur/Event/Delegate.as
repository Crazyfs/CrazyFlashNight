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
            // 使用 apply 将当前作用域（scope）和传递的参数一起调用方法
            return method.apply(scope, Array.prototype.slice.call(arguments));
        };

        // 记录原始回调函数和作用域，以便以后可以访问
        wrappedFunction._originalCallback = method;  // 保存原始回调方法
        wrappedFunction._scope = scope;              // 保存作用域

        return wrappedFunction; // 返回包装后的函数
    }

}


/*

// 定义一个对象作为作用域
var myObject:Object = {name: "myObject"};

// 定义一个期望在特定作用域中执行的函数
function printName():Void {
    trace("当前作用域中的 name 为: " + this.name);
}

// 使用 Delegate.create 将 `printName` 绑定到 `myObject`
var boundFunction:Function = Delegate.create(myObject, printName);

// 调用委托函数，输出 "当前作用域中的 name 为: myObject"
boundFunction();


import org.flashNight.neur.Event.Delegate;

trace("Testing Delegate functionality...");

// Test 1: 基础作用域绑定和参数传递
trace("Test 1: 基础作用域绑定和参数传递");
var scope:Object = {name: "testScope"};
function callbackBasic(arg1:String, arg2:Number):Void {
    trace("Callback in scope: " + this.name);
    trace("Arguments received: " + arg1 + ", " + arg2);
}
var delegateBasic:Function = Delegate.create(scope, callbackBasic);
delegateBasic("Hello", 42); // 预期输出：Callback in scope: testScope, Arguments received: Hello, 42

// Test 2: 无参数传递
trace("Test 2: 无参数传递");
function callbackNoArgs():Void {
    trace("Callback in scope: " + this.name + " without arguments");
}
var delegateNoArgs:Function = Delegate.create(scope, callbackNoArgs);
delegateNoArgs();  // 预期输出：Callback in scope: testScope without arguments

// Test 3: 多参数传递
trace("Test 3: 多参数传递");
function callbackMultipleArgs(arg1, arg2, arg3, arg4):Void {
    trace("Multiple arguments received: " + arg1 + ", " + arg2 + ", " + arg3 + ", " + arg4);
}
var delegateMultipleArgs:Function = Delegate.create(scope, callbackMultipleArgs);
delegateMultipleArgs("A", 1, true, [10, 20]); // 预期输出：Multiple arguments received: A, 1, true, 10,20

// Test 4: 无作用域绑定
trace("Test 4: 无作用域绑定");
function callbackNoScope():Void {
    trace("Callback with no scope, this is: " + this);
}
var delegateNoScope:Function = Delegate.create(undefined, callbackNoScope);
delegateNoScope();  // 预期输出：Callback with no scope, this is: undefined

// Test 5: 异常处理测试
trace("Test 5: 异常处理测试");
function callbackWithErrorHandling():Void {
    trace("Callback that throws error");
    throw new Error("Intentional error in callback");
}
var delegateWithErrorHandling:Function = Delegate.create(this, callbackWithErrorHandling);
try {
    delegateWithErrorHandling();
} catch (e:Error) {
    trace("Caught error: " + e.message);  // 预期输出：Caught error: Intentional error in callback
}

// Test 6: 带返回值的回调
trace("Test 6: 带返回值的回调");
function callbackWithReturn(arg1:Number):Number {
    return arg1 * 2;
}
var delegateWithReturn:Function = Delegate.create(this, callbackWithReturn);
var result:Number = delegateWithReturn(21);  // 预期返回值为 42
trace("Callback returned: " + result);  // 预期输出：Callback returned: 42

// Test 7: 空回调函数
trace("Test 7: 空回调函数");
var delegateNullCallback:Function = Delegate.create(scope, null);
try {
    delegateNullCallback();  // 预期不会有输出或可能抛出异常
} catch (e:Error) {
    trace("Caught error for null callback: " + e.message);
}

var delegateUndefinedCallback:Function = Delegate.create(scope, undefined);
try {
    delegateUndefinedCallback();  // 预期不会有输出或可能抛出异常
} catch (e:Error) {
    trace("Caught error for undefined callback: " + e.message);
}

// Test 8: 深层嵌套作用域测试
trace("Test 8: 深层嵌套作用域测试");
var outerScope:Object = {name: "OuterScope"};
var innerScope:Object = {name: "InnerScope"};

function callbackNested():Void {
    trace("Callback in scope: " + this.name);
}

var delegateOuter:Function = Delegate.create(outerScope, function() {
    trace("Inside outer scope");
    var delegateInner:Function = Delegate.create(innerScope, callbackNested);
    delegateInner();  // 预期输出：Callback in scope: InnerScope
});
delegateOuter();  // 预期输出：Inside outer scope

// Test 9: 使用 apply 传参
trace("Test 9: 使用 apply 传参");
function callbackWithApply():Void {
    trace("Arguments received via apply: " + arguments);
}
var delegateWithApply:Function = Delegate.create(this, callbackWithApply);
delegateWithApply.apply(null, ["ApplyArg1", "ApplyArg2"]);  // 预期输出：Arguments received via apply: ApplyArg1,ApplyArg2

// Test 10: 重复调用测试
trace("Test 10: 重复调用测试");
function callbackMultipleCalls():Void {
    trace("Callback executed in scope: " + this.name);
}
var delegateMultipleCalls:Function = Delegate.create(scope, callbackMultipleCalls);
delegateMultipleCalls();  // 第一次调用
delegateMultipleCalls();  // 第二次调用，预期输出应一致

// Test 11: 大数据测试
trace("Test 11: 大数据测试");
function callbackWithManyArgs():Void {
    trace("Received " + arguments.length + " arguments.");
}
var delegateWithManyArgs:Function = Delegate.create(this, callbackWithManyArgs);
var largeArgs:Array = [];
for (var i:Number = 0; i < 100; i++) {
    largeArgs.push(i);
}
delegateWithManyArgs.apply(null, largeArgs);  // 预期输出：Received 1000 arguments.

*/
