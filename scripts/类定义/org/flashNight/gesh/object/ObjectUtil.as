import org.flashNight.gesh.string.StringUtils;
import org.flashNight.naki.Sort.InsertionSort;
import JSON;
import Base64;
import org.flashNight.naki.DataStructures.Dictionary;

class org.flashNight.gesh.object.ObjectUtil {
    
    /**
     * 克隆一个对象，生成它的深拷贝。
     * @param obj 要克隆的对象。
     * @return 克隆后的新对象。
     */
    public static function clone(obj:Object) {
        var seenObjects:Dictionary = new Dictionary(); // 使用 Dictionary 追踪已处理的对象
        return cloneRecursive(obj, seenObjects);
    }

    /**
     * 递归克隆对象的辅助方法。
     * @param obj 当前要克隆的对象。
     * @param seenObjects 已处理对象的映射表。
     * @return 克隆后的对象。
     */
    private static function cloneRecursive(obj:Object, seenObjects:Dictionary):Object {
        if (obj == null || typeof(obj) != "object") {
            return obj;
        }

        // 检查对象是否已经被克隆过
        if (seenObjects.getItem(obj) != undefined) {
            return seenObjects.getItem(obj);
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
            seenObjects.setItem(obj, copy);  // 标记对象，防止循环引用
            for (var i:Number = 0; i < obj.length; i++) {
                copy[i] = cloneRecursive(obj[i], seenObjects);
            }
            return copy;
        }

        // 处理一般对象
        copy = {};
        seenObjects.setItem(obj, copy);  // 标记对象
        for (var key:String in obj) {
            if (obj.hasOwnProperty(key) && !isInternalKey(key)) {  // 忽略 __dictUID
                copy[key] = cloneRecursive(obj[key], seenObjects);
            }
        }

        return copy;
    }

    /**
     * 比较两个对象，返回它们的差异。
     * @param obj1 第一个对象。
     * @param obj2 第二个对象。
     * @param seenObjects (可选) 追踪已比较的对象，防止循环引用
     * @return Number -1 表示 obj1 < obj2, 1 表示 obj1 > obj2, 0 表示相等。
     */
    public static function compare(obj1:Object, obj2:Object, seenObjects:Dictionary):Number {
        // 如果 seenObjects 为空，则在此处初始化
        if (seenObjects == null) {
            seenObjects = new Dictionary();
        }

        if (obj1 === obj2) return 0;

        // 防止循环比较，标记已比较的对象
        if (seenObjects.getItem(obj1) === obj2) return 0;

        seenObjects.setItem(obj1, obj2);

        // 如果其中一个为 null
        if (obj1 == null) return -1;
        if (obj2 == null) return 1;

        // 类型比较
        var type1:String = typeof(obj1);
        var type2:String = typeof(obj2);
        if (type1 != type2) return (type1 > type2) ? 1 : -1;

        // 简单类型比较
        if (isSimple(obj1)) return (obj1 > obj2) ? 1 : (obj1 < obj2 ? -1 : 0);

        // 数组比较
        if (obj1 instanceof Array && obj2 instanceof Array) {
            if (obj1.length != obj2.length) return (obj1.length > obj2.length) ? 1 : -1;
            for (var i:Number = 0; i < obj1.length; i++) {
                var result:Number = compare(obj1[i], obj2[i], seenObjects);
                if (result != 0) return result;
            }
            return 0;
        }

        // 对象属性比较
        var keys1:Array = getKeys(obj1);
        var keys2:Array = getKeys(obj2);
        keys1 = InsertionSort.sort(keys1, function(a, b):Number { return a > b ? 1 : (a < b ? -1 : 0); });
        keys2 = InsertionSort.sort(keys2, function(a, b):Number { return a > b ? 1 : (a < b ? -1 : 0); });

        if (keys1.length != keys2.length) return (keys1.length > keys2.length) ? 1 : -1;

        for (var j:Number = 0; j < keys1.length; j++) {
            if (keys1[j] != keys2[j]) return (keys1[j] > keys2[j]) ? 1 : -1;
            var compareResult:Number = compare(obj1[keys1[j]], obj2[keys2[j]], seenObjects);
            if (compareResult != 0) return compareResult;
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
     * @param seenObjects (可选) 追踪已转换的对象，防止循环引用
     * @return String 对象的字符串表示。
     */
    public static function toString(obj:Object, seenObjects:Dictionary):String {
        if (seenObjects == null) {
            seenObjects = new Dictionary();
        }

        if (obj == null) return "null";

        if (seenObjects.getItem(obj) != undefined) {
            return "[Circular]";
        }

        seenObjects.setItem(obj, true);

        var result:String = "";
        if (obj instanceof Array) {
            result += "[";
            for (var i:Number = 0; i < obj.length; i++) {
                if (i > 0) result += ", ";
                result += toString(obj[i], seenObjects);
            }
            result += "]";
        } else if (typeof(obj) == "object") {
            result += "{";
            var keys:Array = getKeys(obj);
            keys = InsertionSort.sort(keys, function(a, b):Number { return a > b ? 1 : (a < b ? -1 : 0); });
            for (var j:Number = 0; j < keys.length; j++) {
                if (j > 0) result += ", ";
                if (!isInternalKey(keys[j])) {  // 忽略 __dictUID
                    result += '"' + keys[j] + '": ' + toString(obj[keys[j]], seenObjects);
                }
            }
            result += "}";
        } else {
            result = String(obj);
        }

        return result;
    }

    /**
     * 忽略对象的内部键。
     * @param key 要检查的键。
     * @return Boolean true 表示这是一个内部键，应该忽略。
     */
    private static function isInternalKey(key:String):Boolean {
        return key.indexOf("__") == 0;  // 忽略所有以 "__" 开头的内部键
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
            if (source.hasOwnProperty(key) && !isInternalKey(key)) {  // 忽略内部键
                destination[key] = source[key];
            }
        }
    }

    /**
     * 从对象获取所有的键。
     * @param obj 要获取键的对象。
     * @return Array 键数组。
     */
    public static function getKeys(obj:Object):Array {
        var keys:Array = [];
        for (var key:String in obj) {
            if (obj.hasOwnProperty(key) && !isInternalKey(key)) {  // 忽略内部键
                keys.push(key);
            }
        }
        return keys;
    }

    /**
     * 比较两个对象是否相等（递归比较所有属性）。
     * @param obj1 第一个对象。
     * @param obj2 第二个对象。
     * @param seenObjects (可选) 追踪已比较的对象，防止循环引用
     * @return Boolean true 表示相等，false 表示不相等。
     */
    public static function equals(obj1:Object, obj2:Object, seenObjects:Dictionary):Boolean {
        if (seenObjects == null) {
            seenObjects = new Dictionary();
        }

        if (obj1 === obj2) return true;

        // 防止循环引用
        if (seenObjects.getItem(obj1) === obj2) return true;

        seenObjects.setItem(obj1, obj2);

        if (obj1 == null || obj2 == null) return false;

        var type1:String = typeof(obj1);
        var type2:String = typeof(obj2);
        if (type1 != type2) return false;

        // 简单类型比较
        if (isSimple(obj1)) return obj1 === obj2;

        // 数组比较
        if (obj1 instanceof Array && obj2 instanceof Array) {
            if (obj1.length != obj2.length) return false;
            for (var i:Number = 0; i < obj1.length; i++) {
                if (!equals(obj1[i], obj2[i], seenObjects)) return false;
            }
            return true;
        }

        // 对象属性比较
        var keys1:Array = getKeys(obj1);
        var keys2:Array = getKeys(obj2);
        keys1 = InsertionSort.sort(keys1, function(a, b):Number { return a > b ? 1 : (a < b ? -1 : 0); });
        keys2 = InsertionSort.sort(keys2, function(a, b):Number { return a > b ? 1 : (a < b ? -1 : 0); });
        if (keys1.length != keys2.length) return false;

        for (var j:Number = 0; j < keys1.length; j++) {
            if (keys1[j] != keys2[j]) return false;
            if (!equals(obj1[keys1[j]], obj2[keys2[j]], seenObjects)) return false;
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
            } else if (!isInternalKey(key)) {  // 忽略内部键
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
        return equals(obj1, obj2, null);
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

    /**
     * 将对象序列化为压缩后的 Base64 编码字符串。
     * @param obj 要序列化的对象。
     * @param pretty 是否格式化输出 JSON。
     * @return String 压缩并编码后的 Base64 字符串，或 null 如果失败。
     */
    public static function toBase64(obj:Object, pretty:Boolean):String {
        var jsonString:String = toJSON(obj, pretty);
        if (jsonString == null) {
            trace("ObjectUtil.toBase64: 序列化为 JSON 失败");
            return null;
        }

        // 压缩 JSON 字符串
        var compressedString:String = StringUtils.compress(jsonString);
        if (compressedString == null) {
            trace("ObjectUtil.toBase64: 压缩 JSON 失败");
            return null;
        }

        // 将压缩后的字符串编码为 Base64
        var base64String:String = Base64.encode(compressedString);
        return base64String;
    }

    /**
     * 从压缩并编码的 Base64 字符串解析对象。
     * @param base64String 压缩并编码后的 Base64 字符串。
     * @return Object 解析后的对象，或 null 如果失败。
     */
    public static function fromBase64(base64String:String):Object {
        var compressedString:String = Base64.decode(base64String);
        if (compressedString == null) {
            trace("ObjectUtil.fromBase64: Base64 解码失败");
            return null;
        }

        // 解压缩字符串
        var jsonString:String = StringUtils.decompress(compressedString);
        if (jsonString == null) {
            trace("ObjectUtil.fromBase64: 解压缩失败");
            return null;
        }

        // 将 JSON 字符串解析为对象
        return fromJSON(jsonString);
    }

    /**
     * 将对象序列化为压缩后的 Base64 编码字符串。
     * @param obj 要序列化的对象。
     * @param pretty 是否格式化输出 JSON。
     * @return String 压缩并编码后的 Base64 字符串，或 null 如果失败。
     */
    public static function toCompress(obj:Object, pretty:Boolean):String {
        var jsonString:String = toJSON(obj, pretty);
        if (jsonString == null) {
            trace("ObjectUtil.toBase64: 序列化为 JSON 失败");
            return null;
        }

        // 压缩 JSON 字符串
        var compressedString:String = StringUtils.compress(jsonString);
        if (compressedString == null) {
            trace("ObjectUtil.toBase64: 压缩 JSON 失败");
            return null;
        }
        return compressedString;
    }

    /**
     * 从压缩并编码的 Base64 字符串解析对象。
     * @param base64String 压缩并编码后的 Base64 字符串。
     * @return Object 解析后的对象，或 null 如果失败。
     */
    public static function fromCompress(compressedString:String):Object {
        // 解压缩字符串
        var jsonString:String = StringUtils.decompress(compressedString);
        if (jsonString == null) {
            trace("ObjectUtil.fromBase64: 解压缩失败");
            return null;
        }

        // 将 JSON 字符串解析为对象
        return fromJSON(jsonString);
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

var invalidJson:String = '{"name": "Test", "age": 25,'; // Invalid JSON string
var invalidParsed:Object = ObjectUtil.fromJSON(invalidJson);
trace("无效 JSON 解析结果: " + invalidParsed); // 应输出 null

trace("fromJSON 方法测试完成。\n");

// 11. 测试 toBase64 和 fromBase64 方法
trace("测试 toBase64 和 fromBase64 方法...");
var testObject:Object = { name: "Test", value: 123, nested: { key: "value" } };

var base64String:String = ObjectUtil.toBase64(testObject, false);
trace("Base64 编码结果: " + base64String); // 输出 Base64 编码结果

var decodedObject:Object = ObjectUtil.fromBase64(base64String);
trace("从 Base64 解析的对象: " + ObjectUtil.toString(decodedObject)); // 输出解码结果

trace("对象是否一致: " + ObjectUtil.equals(testObject, decodedObject)); // 应该输出 true

trace("toBase64 和 fromBase64 方法测试完成。\n");

trace("\n测试完毕。");

*/