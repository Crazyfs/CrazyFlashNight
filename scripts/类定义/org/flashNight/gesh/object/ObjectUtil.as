// 文件路径: org/flashNight/gesh/object/ObjectUtil.as

import org.flashNight.gesh.string.StringUtils;
import JSON;
class org.flashNight.gesh.object.ObjectUtil {
    
    /**
     * 克隆一个对象，生成它的深拷贝。
     * @param obj 要克隆的对象。
     * @return 克隆后的新对象。
     */
    public static function clone(obj:Object):Object {
        if (obj == null || typeof(obj) != "object") {
            return obj;
        }
        
        var copy:Object;
        
        // 处理日期对象
        if (obj instanceof Date) {
            copy = new Date(obj.getTime());
            return copy;
        }
        
        // 处理数组
        if (obj instanceof Array) {
            copy = [];
            for (var i:Number = 0; i < obj.length; i++) {
                copy[i] = clone(obj[i]);
            }
            return copy;
        }
        
        // 处理一般对象
        copy = {};
        for (var key:String in obj) {
            copy[key] = clone(obj[key]); // 递归处理嵌套对象
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
        if (obj == null) {
            return "null";
        }
        if (typeof(obj) != "object") {
            return obj.toString();
        }
        if (obj instanceof Array) {
            var arrayStr:String = "[";
            for (var i:Number = 0; i < obj.length; i++) {
                arrayStr += toString(obj[i]) + ",";
            }
            arrayStr = arrayStr.slice(0, -1) + "]";
            return arrayStr;
        }
        if (obj instanceof Date) {
            return '"' + obj.toString() + '"';
        }
        var str:String = "{";
        for (var key:String in obj) {
            str += '"' + key + '": ' + toString(obj[key]) + ", ";
        }
        if (str.length > 1) {
            str = str.slice(0, -2); // 移除最后的逗号和空格
        }
        str += "}";
        return str;
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
        return (compare(obj1, obj2) == 0);
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
    
    /**
     * 将对象转换为JSON字符串。
     * @param obj 要序列化的对象。
     * @param pretty 是否格式化输出。
     * @return JSON字符串。
     */
    public static function toJSON(obj:Object, pretty:Boolean):String {
        return StringUtils.toJSON(obj, pretty);
    }
    
    /**
     * 从JSON字符串解析对象。
     * 使用自定义的 JSON 解析器，避免使用 eval，提高安全性。
     * @param json 要解析的JSON字符串。
     * @return 解析后的对象。如果解析失败，返回 null。
     */
    public static function fromJSON(json:String):Object {
        var parser:JSON = new JSON();
        try {
            return parser.parse(json);
        } catch (e:Object) {
            trace("ObjectUtil.fromJSON: 无法解析JSON字符串 - " + e.message);
            return null;
        }
    }
}
