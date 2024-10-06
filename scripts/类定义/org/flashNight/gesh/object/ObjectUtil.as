// 文件路径: org/flashNight/gesh/object/ObjectUtil.as

import org.flashNight.gesh.string.StringUtils;
import JSON;
class org.flashNight.gesh.object.ObjectUtil {
    
    /**
     * 克隆一个对象，生成它的深拷贝。
     * @param obj 要克隆的对象。
     * @return 克隆后的新对象。
     */
    public static function clone(obj:Object, seenObjects:Object):Object {
        // 如果对象为 null 或 undefined 或者不是对象，直接返回
        if (obj == null || typeof(obj) != "object") {
            return obj;
        }

        // 初始化循环引用检测的已见对象字典
        if (seenObjects == null) {
            seenObjects = {};
        }

        // 检测循环引用，如果对象已经被拷贝过，直接返回已有的拷贝
        if (seenObjects[obj] != undefined) {
            return seenObjects[obj];
        }

        var copy:Object;

        // 处理 Date 对象
        if (obj instanceof Date) {
            copy = new Date(obj.getTime());
            return copy;
        }

        // 处理 RegExp 对象
        if (obj instanceof RegExp) {
            copy = new RegExp(obj.source, obj.flags);
            return copy;
        }

        // 处理 Array
        if (obj instanceof Array) {
            copy = [];
            seenObjects[obj] = copy; // 标记当前数组，防止循环引用
            for (var i:Number = 0; i < obj.length; i++) {
                copy[i] = clone(obj[i], seenObjects); // 递归拷贝数组中的每个元素
            }
            return copy;
        }

        // 处理普通对象
        copy = {};
        seenObjects[obj] = copy; // 标记当前对象，防止循环引用
        for (var key:String in obj) {
            if (obj.hasOwnProperty(key)) { // 只拷贝自有属性，避免拷贝原型链属性
                copy[key] = clone(obj[key], seenObjects); // 递归拷贝对象的每个属性
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
        
        keys1.sort();
        keys2.sort();
        
        var lenKeys1:Number = keys1.length;
        var lenKeys2:Number = keys2.length;
        if (lenKeys1 > lenKeys2) return 1;
        if (lenKeys1 < lenKeys2) return -1;
        
        for (var j:Number = 0; j < lenKeys1; j++) {
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
     * 将对象转换为字符串表示形式。
     * @param obj 要转换的对象。
     * @return String 对象的字符串表示。
     */
    public static function toString(obj:Object):String {
        // 如果传入的对象为null，直接返回字符串 "null"
        if (obj == null) {
            return "null";
        }

        // 创建一个栈，模拟递归处理的堆栈结构，存储待处理的对象信息
        var stack:Array = [{value: obj, prefix: "", postfix: ""}]; // 每个元素包含待处理对象和前后缀
        var result:String = ""; // 最终生成的字符串结果
        var current:Object; // 当前正在处理的对象

        // 当栈中还有待处理的对象时，继续循环
        while (stack.length > 0) {
            current = stack.pop(); // 从栈顶弹出一个对象进行处理
            var value:Object = current.value; // 取出当前对象的值
            var prefix:String = current.prefix; // 处理前缀，表示对象或数组的开头部分
            var postfix:String = current.postfix; // 处理后缀，表示对象或数组的结尾部分

            // 处理 null 值
            if (value == null) {
                result += prefix + "null" + postfix; // 如果当前值为null，拼接 "null" 字符串
            }
            // 处理非对象类型（如字符串、数字、布尔值等）
            else if (typeof(value) != "object") {
                result += prefix + value.toString() + postfix; // 调用其toString方法，拼接结果
            }
            // 处理数组类型
            else if (value instanceof Array) {
                result += prefix + "["; // 数组开始，添加 "["
                for (var i:Number = 0; i < value.length; i++) {
                    if (i > 0) result += ","; // 元素之间用逗号分隔
                    // 将数组中的每个元素压入栈中等待处理
                    stack.push({value: value[i], prefix: "", postfix: ""});
                }
                result += "]" + postfix; // 数组结束，添加 "]"
            }
            // 处理日期类型
            else if (value instanceof Date) {
                result += prefix + '"' + value.toString() + '"' + postfix; // 日期类型返回带双引号的字符串
            }
            // 处理一般对象类型
            else {
                result += prefix + "{"; // 对象开始，添加 "{"
                var first:Boolean = true; // 标记是否为对象中的第一个键值对
                // 遍历对象的每个属性（键值对）
                for (var key:String in value) {
                    if (!first) result += ", "; // 每个键值对之间用逗号分隔
                    first = false; // 将标记置为false，表明已经处理了第一个键值对
                    // 将键值对压入栈中等待处理
                    stack.push({
                        value: value[key], // 属性值
                        prefix: '"' + key + '": ', // 属性名和冒号，作为前缀
                        postfix: "" // 对象内属性值不需要后缀
                    });
                }
                result += "}" + postfix; // 对象结束，添加 "}"
            }
        }

        // 返回最终拼接的字符串结果
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
            return obj1 === obj2; // 对于简单类型，直接比较值
        }
        
        // 处理数组
        if (obj1 instanceof Array && obj2 instanceof Array) {
            var len1:Number = obj1.length;
            var len2:Number = obj2.length;
            if (len1 != len2) return false;
            for (var i:Number = 0; i < len1; i++) {
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
        keys1.sort();
        keys2.sort();
        
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
        var result:Object = clone(target);
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
