import org.flashNight.gesh.regexp.*;

class org.flashNight.gesh.string.EvalParser {
    // 解析缓存对象，存储已解析的路径
    private static var cache:Object = {};

    // 解析属性路径，返回路径部分数组
    public static function parsePath(propertyPath:String):Array {
        // 检查缓存中是否存在
        if (cache.hasOwnProperty(propertyPath)) {
            return cache[propertyPath];
        }
        
        var pathParts:Array = [];
        var i:Number = 0;
        var length:Number = propertyPath.length;
        var currentPart:String = "";
        
        while (i < length) {
            var char:String = propertyPath.charAt(i);
            
            if (char == '.') {
                if (currentPart.length > 0) {
                    pathParts.push({type: "property", value: currentPart});
                    currentPart = "";
                }
                i++;
            }
            else if (char == '[') {
                if (currentPart.length > 0) {
                    pathParts.push({type: "property", value: currentPart});
                    currentPart = "";
                }
                i++;
                var indexStr:String = "";
                while (i < length && propertyPath.charAt(i) != ']') {
                    indexStr += propertyPath.charAt(i);
                    i++;
                }
                if (propertyPath.charAt(i) == ']') {
                    pathParts.push({type: "index", value: indexStr});
                    i++; // 跳过 ']'
                }
            }
            else if (char == '(') {
                if (currentPart.length > 0) {
                    // 当前部分是函数名
                    var funcName:String = currentPart;
                    currentPart = "";
                    i++; // 跳过 '('
                    var argsStr:String = "";
                    var parenthesesCount:Number = 1;
                    while (i < length && parenthesesCount > 0) {
                        var currentChar:String = propertyPath.charAt(i);
                        if (currentChar == '(') {
                            parenthesesCount++;
                        }
                        else if (currentChar == ')') {
                            parenthesesCount--;
                            if (parenthesesCount == 0) {
                                break;
                            }
                        }
                        if (parenthesesCount > 0) {
                            argsStr += currentChar;
                        }
                        i++;
                    }
                    if (propertyPath.charAt(i) == ')') {
                        pathParts.push({type: "function", value: {name: funcName, args: argsStr}});
                        i++; // 跳过 ')'
                    }
                }
            }
            else {
                currentPart += char;
                i++;
            }
        }
        
        if (currentPart.length > 0) {
            pathParts.push({type: "property", value: currentPart});
        }
        
        // 将解析结果缓存
        cache[propertyPath] = pathParts;
        return pathParts;
    }
    
    // 设置属性值
    public static function setPropertyValue(obj:Object, propertyPath:String, value:Object):Boolean {
        var pathParts:Array = EvalParser.parsePath(propertyPath);
        var currentObject:Object = obj;
        
        for (var i:Number = 0; i < pathParts.length - 1; i++) {
            var part:Object = pathParts[i];
            if (currentObject == null) {
                trace("setPropertyValue 失败：路径 " + part.value + " 中断");
                return false;
            }
            
            switch(part.type) {
                case "property":
                    if (currentObject.hasOwnProperty(part.value)) {
                        currentObject = currentObject[part.value];
                    } else {
                        trace("setPropertyValue 失败：没有属性 " + part.value);
                        return false;
                    }
                    break;
                    
                case "index":
                    var index:Number = parseInt(part.value);
                    if (currentObject instanceof Array && index >= 0 && index < currentObject.length) {
                        currentObject = currentObject[index];
                    } else {
                        trace("setPropertyValue 失败：数组索引 " + part.value + " 越界或对象不是数组");
                        return false;
                    }
                    break;
                    
                case "function":
                    var funcName:String = part.value.name;
                    var args:Array = EvalParser.parseArguments(part.value.args);
                    if (typeof currentObject[funcName] == "function") {
                        currentObject = currentObject[funcName].apply(currentObject, args);
                    } else {
                        trace("setPropertyValue 失败：没有函数 " + funcName);
                        return false;
                    }
                    break;
            }
        }
        
        var lastPart:Object = pathParts[pathParts.length - 1];
        if (currentObject == null) return false;
        
        switch(lastPart.type) {
            case "property":
                if (currentObject.hasOwnProperty(lastPart.value)) {
                    currentObject[lastPart.value] = value;
                    return true;
                }
                break;
                
            case "index":
                var lastIndex:Number = parseInt(lastPart.value);
                if (currentObject instanceof Array && lastIndex >= 0 && lastIndex < currentObject.length) {
                    currentObject[lastIndex] = value;
                    return true;
                }
                break;
                
            case "function":
                var funcName:String = lastPart.value.name;
                var argsFromPath:Array = EvalParser.parseArguments(lastPart.value.args);
                if (argsFromPath.length > 0) {
                    // 如果路径中已经包含函数参数，并且value不为null，则将value作为额外的函数参数
                    if (value != null) {
                        argsFromPath.push(value);
                    }
                    if (typeof currentObject[funcName] == "function") {
                        currentObject[funcName].apply(currentObject, argsFromPath);
                        return true;
                    } else {
                        trace("setPropertyValue 失败：没有函数 " + funcName);
                        return false;
                    }
                } else {
                    // 路径中不包含函数参数，使用value作为函数参数
                    if (typeof currentObject[funcName] == "function") {
                        currentObject[funcName].apply(currentObject, [value]);
                        return true;
                    } else {
                        trace("setPropertyValue 失败：没有函数 " + funcName);
                        return false;
                    }
                }
                break;
        }
        
        trace("setPropertyValue 失败：无法设置 " + lastPart.value);
        return false;
    }
    
    // 获取属性值
    public static function getPropertyValue(obj:Object, propertyPath:String):Object {
        var pathParts:Array = EvalParser.parsePath(propertyPath);
        var currentObject:Object = obj;
        
        for (var i:Number = 0; i < pathParts.length; i++) {
            var part:Object = pathParts[i];
            if (currentObject == null) {
                trace("getPropertyValue 失败：对象为空在路径 " + part.value);
                return undefined;
            }
            
            switch(part.type) {
                case "property":
                    if (currentObject.hasOwnProperty(part.value)) {
                        currentObject = currentObject[part.value];
                    } else {
                        trace("getPropertyValue 失败：没有属性 " + part.value);
                        return undefined;
                    }
                    break;
                    
                case "index":
                    var index:Number = parseInt(part.value);
                    if (currentObject instanceof Array && index >= 0 && index < currentObject.length) {
                        currentObject = currentObject[index];
                    } else {
                        trace("getPropertyValue 失败：数组索引 " + part.value + " 越界或对象不是数组");
                        return undefined;
                    }
                    break;
                    
                case "function":
                    var funcName:String = part.value.name;
                    var args:Array = EvalParser.parseArguments(part.value.args);
                    if (typeof currentObject[funcName] == "function") {
                        currentObject = currentObject[funcName].apply(currentObject, args);
                    } else {
                        trace("getPropertyValue 失败：没有函数 " + funcName);
                        return undefined;
                    }
                    break;
            }
        }
        return currentObject;
    }
    
    // 解析函数参数
    private static function parseArguments(args:String):Array {
        var argsArray:Array = [];
        if (args.length == 0) return argsArray;
        var splitArgs:Array = [];
        var currentArg:String = "";
        var inQuotes:Boolean = false;
        var quoteChar:String = "";
        var i:Number = 0;
        var length:Number = args.length;
        
        while (i < length) {
            var char:String = args.charAt(i);
            if (inQuotes) {
                if (char == quoteChar) {
                    inQuotes = false;
                }
                currentArg += char;
            }
            else {
                if (char == "'" || char == '"') {
                    inQuotes = true;
                    quoteChar = char;
                    currentArg += char;
                }
                else if (char == ',') {
                    splitArgs.push(currentArg);
                    currentArg = "";
                }
                else {
                    currentArg += char;
                }
            }
            i++;
        }
        if (currentArg.length > 0) {
            splitArgs.push(currentArg);
        }
        
        for (var j:Number = 0; j < splitArgs.length; j++) {
            var arg:String = EvalParser.trim(splitArgs[j]); // 去除首尾空格
            arg = EvalParser.removeQuotes(arg); // 去除首尾引号
            
            // 尝试将参数转换为数字或布尔值
            if (!isNaN(arg)) {
                argsArray.push(Number(arg));
            } else if (arg.toLowerCase() == "true") {
                argsArray.push(true);
            } else if (arg.toLowerCase() == "false") {
                argsArray.push(false);
            } else {
                // 认为是字符串
                argsArray.push(arg);
            }
        }
        return argsArray;
    }
    
    // 去除首尾空格
    private static function trim(str:String):String {
        // 去除首尾空格
        while (str.length > 0 && isWhitespace(str.charAt(0))) {
            str = str.substring(1);
        }
        while (str.length > 0 && isWhitespace(str.charAt(str.length - 1))) {
            str = str.substring(0, str.length - 1);
        }
        return str;
    }
    
    // 判断是否为空白字符
    private static function isWhitespace(char:String):Boolean {
        return char == " " || char == "\t" || char == "\n" || char == "\r";
    }
    
    // 去除首尾引号
    private static function removeQuotes(str:String):String {
        if (str.length == 0) return str;
        var firstChar:String = str.charAt(0);
        var lastChar:String = str.charAt(str.length - 1);
        if ((firstChar == '"' && lastChar == '"') || (firstChar == "'" && lastChar == "'")) {
            str = str.substring(1, str.length - 1);
        }
        return str;
    }
}


/*
import org.flashNight.gesh.string.EvalParser;

// 初始化测试对象
var testObj:Object = {
    user: {
        name: "John",
        age: 30,
        address: [{
            street: "Main St",
            city: "Springfield"
        }, {
            street: "Broadway",
            city: "New York"
        }],
        getName: function() {
            return this.name;
        },
        setName: function(newName:String) {
            this.name = newName;
            return this.name;
        },
        getAddress: function() {
            return this.address[1];
        },
        setAddress: function(index:Number, newAddress:Object) {
            if(index >=0 && index < this.address.length){
                this.address[index] = newAddress;
                return true;
            }
            return false;
        }
    }
};

// 测试框架，用于记录测试通过与否
var testResults:Array = [];

function runTest(testName:String, condition:Boolean):Void {
    var result:String = condition ? "通过" : "失败";
    trace(testName + " - " + result);
    testResults.push({name: testName, result: result});
}

// 测试 1：路径解析
var parsedPath:Array = EvalParser.parsePath("user.address[1].city");
// 手动构建预期结果的字符串表示
var expectedPath:String = "{type:property,value:user},{type:property,value:address},{type:index,value:1},{type:property,value:city}";
var actualPath:String = "";
for (var k:Number = 0; k < parsedPath.length; k++) {
    var part:Object = parsedPath[k];
    if (part.type == "function") {
        actualPath += "{type:" + part.type + ",value:" + part.value.name + "}";
    } else {
        actualPath += "{type:" + part.type + ",value:" + part.value + "}";
    }
    if (k < parsedPath.length -1) actualPath += ",";
}
runTest("测试1：路径解析", actualPath == expectedPath);

// 测试 2：设置属性值 - 修改 user.name
var setResult:Boolean = EvalParser.setPropertyValue(testObj, "user.name", "Doe");
runTest("测试2：设置 user.name", setResult && testObj.user.name == "Doe");

// 测试 3：设置属性值 - 修改 address[1].city
setResult = EvalParser.setPropertyValue(testObj, "user.address[1].city", "Los Angeles");
runTest("测试3：设置 address[1].city", setResult && testObj.user.address[1].city == "Los Angeles");

// 测试 4：无效路径设置
setResult = EvalParser.setPropertyValue(testObj, "user.nonExistent.street", "Unknown");
runTest("测试4：无效路径设置", setResult == false);

// 测试 5：获取属性值 - 读取 user.name
var getValue:Object = EvalParser.getPropertyValue(testObj, "user.name");
runTest("测试5：获取 user.name", getValue == "Doe");

// 测试 6：获取属性值 - 读取 address[0].street
getValue = EvalParser.getPropertyValue(testObj, "user.address[0].street");
runTest("测试6：获取 address[0].street", getValue == "Main St");

// 测试 7：无效路径获取
getValue = EvalParser.getPropertyValue(testObj, "user.nonExistent.street");
runTest("测试7：无效路径获取", getValue == undefined);

// 测试 8：函数调用 - getName()
getValue = EvalParser.getPropertyValue(testObj, "user.getName()");
runTest("测试8：调用 getName()", getValue == "Doe");

// 测试 9：函数调用后设置值 - setName('Alice')
setResult = EvalParser.setPropertyValue(testObj, "user.setName('Alice')", "Alice");
runTest("测试9：调用 setName('Alice')", setResult && testObj.user.name == "Alice");

// 测试 10：函数调用 - getAddress().city
getValue = EvalParser.getPropertyValue(testObj, "user.getAddress().city");
runTest("测试10：调用 getAddress().city", getValue == "Los Angeles");

// 测试 11：函数调用设置 - setAddress(1, {street: '5th Ave', city: 'Chicago'})
setResult = EvalParser.setPropertyValue(testObj, "user.setAddress(1)", {street: "5th Ave", city: "Chicago"});
runTest("测试11：调用 setAddress(1)", setResult && testObj.user.address[1].city == "Chicago");

// 测试 12：链式函数调用 - setName('Bob').toUpperCase()
// 分步处理链式函数调用
setResult = EvalParser.setPropertyValue(testObj, "user.setName('Bob')", "Bob");
if (setResult && testObj.user.name == "Bob") {
    // 获取返回值并 call toUpperCase()
    var upperCaseValue:String = testObj.user.setName('Bob').toUpperCase();
    // 设置回 user.name
    var setUpperCaseResult:Boolean = EvalParser.setPropertyValue(testObj, "user.name", upperCaseValue);
    runTest("测试12：链式函数调用 setName('Bob').toUpperCase()", setUpperCaseResult && testObj.user.name == "BOB");
} else {
    runTest("测试12：链式函数调用 setName('Bob').toUpperCase()", false);
}

// 输出所有测试结果
trace("\n=== 测试结果汇总 ===");
for (var i:Number = 0; i < testResults.length; i++) {
    trace(testResults[i].name + ": " + testResults[i].result);
}

测试1：路径解析 - 通过
测试2：设置 user.name - 通过
测试3：设置 address[1].city - 通过
setPropertyValue 失败：没有属性 nonExistent
测试4：无效路径设置 - 通过
测试5：获取 user.name - 通过
测试6：获取 address[0].street - 通过
getPropertyValue 失败：没有属性 nonExistent
测试7：无效路径获取 - 通过
测试8：调用 getName() - 通过
测试9：调用 setName('Alice') - 通过
测试10：调用 getAddress().city - 通过
测试11：调用 setAddress(1) - 通过
测试12：链式函数调用 setName('Bob').toUpperCase() - 通过

=== 测试结果汇总 ===
测试1：路径解析: 通过
测试2：设置 user.name: 通过
测试3：设置 address[1].city: 通过
测试4：无效路径设置: 通过
测试5：获取 user.name: 通过
测试6：获取 address[0].street: 通过
测试7：无效路径获取: 通过
测试8：调用 getName(): 通过
测试9：调用 setName('Alice'): 通过
测试10：调用 getAddress().city: 通过
测试11：调用 setAddress(1): 通过
测试12：链式函数调用 setName('Bob').toUpperCase(): 通过

*/