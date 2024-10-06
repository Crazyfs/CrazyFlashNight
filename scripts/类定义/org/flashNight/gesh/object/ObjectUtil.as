// 文件路径: org/flashNight/gesh/object/ObjectUtil.as

import org.flashNight.gesh.string.StringUtils;
import org.flashNight.naki.Sort.InsertionSort;
import JSON;

class org.flashNight.gesh.object.ObjectUtil {
    
    /**
     * 克隆一个对象，生成它的深拷贝。
     * @param obj 要克隆的对象。
     * @return 克隆后的新对象。  不显式返回object以免需要再构造
     */
    public static function clone(obj:Object) {
        var seenObjects:Object = {}; // 用于跟踪已处理的对象
        var cloneID:Object = { count: 0 }; // 唯一标识符计数器，以对象形式传递

        // 开始克隆过程
        var result:Object = cloneRecursive(obj, seenObjects, cloneID);

        // 清理所有对象上的 __objectutil_clone_id__ 标识
        for (var id:String in seenObjects) {
            var original:Object = seenObjects[id].original;
            delete original.__objectutil_clone_id__;
        }

        return result;
    }

    /**
     * 递归克隆对象的辅助方法。
     * @param obj 当前要克隆的对象。
     * @param seenObjects 已处理对象的映射表。
     * @param cloneID 当前的唯一标识符计数器。
     * @return 克隆后的对象。
     */
    private static function cloneRecursive(obj:Object, seenObjects:Object, cloneID:Object):Object {
        if (obj == null || typeof(obj) != "object") {
            return obj;
        }

        // 检查对象是否已经被标记
        if (obj.__objectutil_clone_id__ != undefined) {
            return seenObjects[obj.__objectutil_clone_id__].clone;
        }

        var copy:Object;

        // 处理 Date 对象
        if (obj instanceof Date) {
            return new Date(obj.getTime());
        }

        // 处理 RegExp 对象
        if (obj instanceof RegExp) {
            return new RegExp(obj.source, obj.flags);
        }

        // 处理 Array
        if (obj instanceof Array) {
            copy = [];
            // 标记对象
            cloneID.count++;
            obj.__objectutil_clone_id__ = cloneID.count;
            seenObjects[cloneID.count] = { original: obj, clone: copy };

            // 递归拷贝数组中的每个元素
            for (var i:Number = 0; i < obj.length; i++) {
                copy[i] = cloneRecursive(obj[i], seenObjects, cloneID);
            }
            return copy;
        }

        // 处理普通对象
        copy = {};
        cloneID.count++;
        obj.__objectutil_clone_id__ = cloneID.count;
        seenObjects[cloneID.count] = { original: obj, clone: copy };

        for (var key:String in obj) {
            if (obj.hasOwnProperty(key) && key != "__objectutil_clone_id__") {
                copy[key] = cloneRecursive(obj[key], seenObjects, cloneID);
            }
        }

        return copy;
    }

    /**
     * 比较两个对象，返回它们的差异。
     * @param obj1 第一个对象。
     * @param obj2 第二个对象。
     * @return Number -1 表示 obj1 < obj2, 1 表示 obj1 > obj2, 0 表示相等。
     */
    public static function compare(obj1:Object, obj2:Object):Number {
        if (obj1 === obj2) {
            return 0;
        }
        
        // 如果其中一个为 null 或 undefined
        if (obj1 == null) {
            return -1;
        }
        if (obj2 == null) {
            return 1;
        }
        
        // 如果类型不同
        var type1:String = typeof(obj1);
        var type2:String = typeof(obj2);
        if (type1 != type2) {
            return (type1 > type2) ? 1 : -1;
        }
        
        // 处理简单类型
        if (isSimple(obj1)) {
            if (obj1 > obj2) {
                return 1;
            } else if (obj1 < obj2) {
                return -1;
            } else {
                return 0;
            }
        }
        
        // 处理数组
        if (obj1 instanceof Array && obj2 instanceof Array) {
            var len1:Number = obj1.length;
            var len2:Number = obj2.length;
            if (len1 > len2) return 1;
            if (len1 < len2) return -1;
            for (var i:Number = 0; i < len1; i++) {
                var result:Number = compare(obj1[i], obj2[i]);
                if (result != 0) {
                    return result;
                }
            }
            return 0;
        }
        
        // 处理一般对象
        var keys1:Array = [];
        var keys2:Array = [];
        for (var key1:String in obj1) {
            keys1.push(key1);
        }
        for (var key2:String in obj2) {
            keys2.push(key2);
        }
        
        keys1 = InsertionSort.sort(keys1, function(a, b) { return a > b ? 1 : (a < b ? -1 : 0); });
        keys2 = InsertionSort.sort(keys2, function(a, b) { return a > b ? 1 : (a < b ? -1 : 0); });
        
        var lenKeys1:Number = keys1.length;
        var lenKeys2:Number = keys2.length;
        if (lenKeys1 > lenKeys2) return 1;
        if (lenKeys1 < lenKeys2) return -1;
        
        for (var j:Number = 0; j < keys1.length; j++) {
            if (keys1[j] > keys2[j]) return 1;
            if (keys1[j] < keys2[j]) return -1;
            var compareResult:Number = compare(obj1[keys1[j]], obj2[keys2[j]]);
            if (compareResult != 0) {
                return compareResult;
            }
        }
        return 0;
    }
    
    /**
     * 检查对象是否为简单数据类型（Number, String, Boolean）。
     * @param obj 要检查的对象。
     * @return Boolean true 表示简单类型，false 表示复杂对象。
     */
    public static function isSimple(obj:Object):Boolean {
        var type:String = typeof(obj);
        return (type == "number" || type == "string" || type == "boolean");
    }

    /**
     * 将对象转换为字符串表示形式（类似于 JSON 格式）。
     * @param obj 要转换的对象。
     * @return String 对象的字符串表示。
     */
    public static function toString(obj:Object):String {
        if (obj == null) {
            return "null";
        }

        var stack:Array = []; // 栈用于存储待处理的对象
        var result:String = ""; // 最终生成的字符串
        var current:Object = { type: "start", value: obj, isArray: (obj instanceof Array), keys: null, index: 0 };
        stack.push(current);

        while (stack.length > 0) {
            current = stack.pop();

            switch (current.type) {
                case "start":
                    if (current.value instanceof Array) {
                        result += "[";
                        if (current.value.length > 0) {
                            // 将结束标记压入栈
                            stack.push({ type: "endArray" });
                            // 逆序压入数组元素
                            for (var i:Number = current.value.length - 1; i >= 0; i--) {
                                stack.push({ type: "value", value: current.value[i], isArray: true, isFirst: (i == 0) });
                            }
                        } else {
                            result += "]";
                        }
                    } else if (current.value instanceof Date) {
                        result += '"' + current.value.toString() + '"';
                    } else if (current.value instanceof RegExp) {
                        result += '"' + current.value.source + '"';
                    } else {
                        result += "{";
                        var keys:Array = [];
                        for (var key:String in current.value) {
                            if (current.value.hasOwnProperty(key)) {
                                keys.push(key);
                            }
                        }
                        keys = InsertionSort.sort(keys, function(a, b) { return a > b ? 1 : (a < b ? -1 : 0); });
                        if (keys.length > 0) {
                            // 将结束标记压入栈
                            stack.push({ type: "endObject" });
                            // 逆序压入属性
                            for (var j:Number = keys.length - 1; j >= 0; j--) {
                                var prop:String = keys[j];
                                var propValue:Object = current.value[prop];
                                stack.push({ type: "property", key: prop, value: propValue, isFirst: (j == 0) });
                            }
                        } else {
                            result += "}";
                        }
                    }
                    break;

                case "endArray":
                    result += "]";
                    break;

                case "endObject":
                    result += "}";
                    break;

                case "property":
                    if (!current.isFirst) {
                        result += ", ";
                    }
                    result += '"' + current.key + '": ';
                    // 处理属性值
                    if (current.value == null) {
                        result += "null";
                    } else if (typeof(current.value) != "object") {
                        if (typeof(current.value) == "string") {
                            result += '"' + current.value + '"';
                        } else {
                            result += current.value.toString();
                        }
                    } else {
                        // 将对象的开始压入栈
                        stack.push({ type: "afterProperty" }); // 标记属性处理完毕
                        stack.push({ type: "start", value: current.value });
                    }
                    break;

                case "value":
                    if (!current.isFirst) {
                        result += ", ";
                    }
                    if (current.value == null) {
                        result += "null";
                    } else if (typeof(current.value) != "object") {
                        if (typeof(current.value) == "string") {
                            result += '"' + current.value + '"';
                        } else {
                            result += current.value.toString();
                        }
                    } else {
                        // 将对象的开始压入栈
                        stack.push({ type: "afterValue", isArray: current.isArray });
                        stack.push({ type: "start", value: current.value });
                    }
                    break;

                case "afterProperty":
                    // Nothing to do here; the comma is already handled
                    break;

                case "afterValue":
                    if (current.isArray) {
                        // Nothing additional needed
                    }
                    break;
            }
        }

        return result;
    }

    /**
     * 从源对象复制所有属性到目标对象中。
     * @param source 源对象。
     * @param destination 目标对象。
     */
    public static function copyProperties(source:Object, destination:Object):Void {
        if (source == null || destination == null) {
            return;
        }
        for (var key:String in source) {
            destination[key] = source[key];
        }
    }
    
    /**
     * 比较两个对象是否相等（递归比较所有属性）。
     * @param obj1 第一个对象。
     * @param obj2 第二个对象。
     * @return Boolean true 表示相等，false 表示不相等。
     */
    public static function equals(obj1:Object, obj2:Object):Boolean {
        // 如果是相同的引用，返回 true
        if (obj1 === obj2) {
            return true;
        }

        // 如果其中一个是 null 或 undefined，另一个不是，返回 false
        if (obj1 == null || obj2 == null) {
            return false;
        }

        // 如果类型不同，返回 false
        var type1:String = typeof(obj1);
        var type2:String = typeof(obj2);
        if (type1 != type2) {
            return false;
        }

        // 处理简单类型
        if (isSimple(obj1)) {
            return obj1 === obj2;
        }

        // 处理数组
        if (obj1 instanceof Array && obj2 instanceof Array) {
            if (obj1.length != obj2.length) return false;
            for (var i:Number = 0; i < obj1.length; i++) {
                if (!equals(obj1[i], obj2[i])) {
                    return false;
                }
            }
            return true;
        }

        // 处理普通对象
        var keys1:Array = [];
        var keys2:Array = [];

        // 仅比较自有属性，忽略原型链上的属性
        for (var key1:String in obj1) {
            if (obj1.hasOwnProperty(key1)) {
                keys1.push(key1);
            }
        }
        for (var key2:String in obj2) {
            if (obj2.hasOwnProperty(key2)) {
                keys2.push(key2);
            }
        }

        // 比较属性数量是否相同
        if (keys1.length != keys2.length) {
            return false;
        }

        // 按照属性名称排序后逐个比较
        keys1 = InsertionSort.sort(keys1, function(a, b) { return a > b ? 1 : (a < b ? -1 : 0); });
        keys2 = InsertionSort.sort(keys2, function(a, b) { return a > b ? 1 : (a < b ? -1 : 0); });

        for (var j:Number = 0; j < keys1.length; j++) {
            if (keys1[j] != keys2[j]) {
                return false;
            }
            if (!equals(obj1[keys1[j]], obj2[keys2[j]])) {
                return false;
            }
        }

        return true;
    }

    /**
     * 合并两个对象的属性，源对象的属性会覆盖目标对象的同名属性。
     * @param target 目标对象。
     * @param source 源对象。
     * @return Object 合并后的新对象。
     */
    public static function merge(target:Object, source:Object):Object {
        var result:Object = clone(target); // 深拷贝目标对象

        for (var key:String in source) {
            if (typeof(source[key]) == "object" && typeof(result[key]) == "object") {
                result[key] = merge(result[key], source[key]);
            } else {
                result[key] = source[key];
            }
        }

        return result;
    }

    /**
     * 检查两个对象是否具有相同的属性名和相同的属性值。
     * @param obj1 第一个对象。
     * @param obj2 第二个对象。
     * @return Boolean true 表示对象具有相同的属性和属性值，false 表示不同。
     */
    public static function deepEquals(obj1:Object, obj2:Object):Boolean {
        return equals(obj1, obj2);
    }
    
    /**
     * 将对象序列化为 JSON 字符串。
     * @param obj 要序列化的对象。
     * @param pretty 是否格式化输出。
     * @return String JSON 字符串，或 null 解析失败。
     */
    public static function toJSON(obj:Object, pretty:Boolean):String {
        var serializer:JSON = new JSON();
        try {
            var indent:String = pretty ? "  " : ""; // 控制是否格式化输出
            return serializer.stringify(obj, indent); // 序列化对象为 JSON 字符串
        } catch (e:Object) {
            trace("ObjectUtil.toJSON: 无法序列化对象为JSON字符串 - " + e.message);
            return null; // 处理异常并返回 null
        }
    }

    /**
     * 将 JSON 字符串解析为对象。
     * @param json JSON 字符串。
     * @return Object 解析后的对象，或 null 解析失败。
     */
    public static function fromJSON(json:String):Object {
        var parser:JSON = new JSON();
        try {
            return parser.parse(json); // 解析 JSON 字符串为对象
        } catch (e:Object) {
            trace("ObjectUtil.fromJSON: 无法解析JSON字符串 - " + e.message);
            return null; // 处理异常并返回 null
        }
    }
}

/*

// 文件路径: ObjectUtilTest.as

// 导入所需的类
import org.flashNight.gesh.object.ObjectUtil;
import org.flashNight.gesh.string.StringUtils;
import JSON;

trace("开始测试 ObjectUtil 类...\n");

// 1. 测试 clone 方法
trace("测试 clone 方法...");
var obj1:Object = { name: "Test", age: 25 };
var clone1:Object = ObjectUtil.clone(obj1);
trace("对象是否相等（深拷贝）: " + (obj1 !== clone1) + "，内容是否相同: " + ObjectUtil.equals(obj1, clone1));

var obj2:Object = { name: "Nested", info: { city: "New York" } };
var clone2:Object = ObjectUtil.clone(obj2);
trace("嵌套对象是否相等（深拷贝）: " + (obj2.info !== clone2.info) + "，内容是否相同: " + ObjectUtil.equals(obj2, clone2));

var arr:Array = [1, 2, 3];
var cloneArr:Array = ObjectUtil.clone(arr);
trace("数组是否相等（深拷贝）: " + (arr !== cloneArr) + "，内容是否相同: " + ObjectUtil.equals(arr, cloneArr));

trace("clone 方法测试完成。\n");

// 2. 测试 compare 方法
trace("测试 compare 方法...");
trace("比较数字: " + ObjectUtil.compare(10, 20)); // 应该返回 -1
trace("比较相同数字: " + ObjectUtil.compare(20, 20)); // 应该返回 0
trace("比较字符串: " + ObjectUtil.compare("abc", "xyz")); // 应该返回 -1

var objA:Object = { name: "Test", age: 25 };
var objB:Object = { name: "Test", age: 30 };
trace("比较不同对象: " + ObjectUtil.compare(objA, objB)); // 应该返回 -1

trace("compare 方法测试完成。\n");

// 3. 测试 isSimple 方法
trace("测试 isSimple 方法...");
trace("是否为简单类型（数字）: " + ObjectUtil.isSimple(123)); // 应该返回 true
trace("是否为简单类型（字符串）: " + ObjectUtil.isSimple("hello")); // 应该返回 true
trace("是否为简单类型（对象）: " + ObjectUtil.isSimple({})); // 应该返回 false

trace("isSimple 方法测试完成。\n");

// 4. 测试 toString 方法
trace("测试 toString 方法...");
var objC:Object = { name: "Test", age: 25 };
trace("对象的字符串表示: " + ObjectUtil.toString(objC)); // 应输出 {"name": "Test", "age": 25}

var nestedObj:Object = { name: "Nested", info: { city: "New York", zip: 10001 } };
trace("嵌套对象的字符串表示: " + ObjectUtil.toString(nestedObj)); // 应输出 {"name": "Nested", "info": {"city": "New York", "zip": 10001}}

var arrTest:Array = [1, 2, 3];
trace("数组的字符串表示: " + ObjectUtil.toString(arrTest)); // 应输出 [1, 2, 3]

trace("toString 方法测试完成。\n");

// 5. 测试 copyProperties 方法
trace("测试 copyProperties 方法...");
var source:Object = { name: "Source", age: 30 };
var destination:Object = {};
ObjectUtil.copyProperties(source, destination);
trace("目标对象内容: " + ObjectUtil.toString(destination)); // 应输出 {"name": "Source", "age": 30}

trace("copyProperties 方法测试完成。\n");

// 6. 测试 equals 方法
trace("测试 equals 方法...");
var objD:Object = { name: "Test", age: 25 };
var objE:Object = { name: "Test", age: 25 };
trace("对象是否相等: " + ObjectUtil.equals(objD, objE)); // 应该返回 true

var objF:Object = { name: "Test", age: 30 };
trace("对象是否相等: " + ObjectUtil.equals(objD, objF)); // 应该返回 false

trace("equals 方法测试完成。\n");

// 7. 测试 merge 方法
trace("测试 merge 方法...");
var target:Object = { name: "Target", age: 20 };
var sourceMerge:Object = { age: 30, city: "New York" };
var merged:Object = ObjectUtil.merge(target, sourceMerge);
trace("合并后的对象: " + ObjectUtil.toString(merged)); // 应输出 {"name": "Target", "age": 30, "city": "New York"}

trace("merge 方法测试完成。\n");

// 8. 测试 deepEquals 方法
trace("测试 deepEquals 方法...");
var objG:Object = { name: "Test", info: { city: "New York", zip: 10001 } };
var objH:Object = { name: "Test", info: { city: "New York", zip: 10001 } };
trace("对象深度相等: " + ObjectUtil.deepEquals(objG, objH)); // 应该返回 true

var objI:Object = { name: "Test", info: { city: "Los Angeles", zip: 90001 } };
trace("对象深度相等: " + ObjectUtil.deepEquals(objG, objI)); // 应该返回 false

trace("deepEquals 方法测试完成。\n");

// 9. 测试 toJSON 方法
trace("测试 toJSON 方法...");
var objJ:Object = { name: "Test", age: 25, info: { city: "New York" } };
trace("JSON 字符串 (紧凑): " + ObjectUtil.toJSON(objJ, false)); // 应输出 {"name":"Test","age":25,"info":{"city":"New York"}}
trace("JSON 字符串 (格式化): " + ObjectUtil.toJSON(objJ, true)); // 应输出格式化的 JSON

trace("toJSON 方法测试完成。\n");

// 10. 测试 fromJSON 方法
trace("测试 fromJSON 方法...");
var jsonString:String = '{"name":"Test","age":25,"info":{"city":"New York"}}';
var parsedObj:Object = ObjectUtil.fromJSON(jsonString);
trace("解析后的对象: " + ObjectUtil.toString(parsedObj)); // 应输出 {"name": "Test", "age": 25, "info": {"city": "New York"}}

var invalidJson:String = '{"name": "Test", "age": 25,';
var invalidParsed:Object = ObjectUtil.fromJSON(invalidJson);
trace("无效 JSON 解析结果: " + invalidParsed); // 应输出 null

trace("fromJSON 方法测试完成。\n");

trace("\n测试完毕。");


*/