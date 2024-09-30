import org.flashNight.gesh.regexp.*;

class org.flashNight.gesh.string.StringUtils {
    
    // 检查字符串是否包含子字符串
    public static function includes(str:String, substring:String):Boolean {
        return str.indexOf(substring) != -1;
    }

    // 检查字符串是否以指定子字符串开头
    public static function startsWith(str:String, prefix:String):Boolean {
        return str.indexOf(prefix) == 0;
    }

    // 检查字符串是否以指定子字符串结尾
    public static function endsWith(str:String, suffix:String):Boolean {
        var index:Number = str.lastIndexOf(suffix);
        return index != -1 && index == str.length - suffix.length;
    }

    // 移除字符串两端的空白字符
    public static function trim(str:String):String {
        return StringUtils.trimLeft(StringUtils.trimRight(str));
    }

    // 移除字符串左边的空白字符
    public static function trimLeft(str:String):String {
        while (str.charAt(0) == " ") {
            str = str.substring(1);
        }
        return str;
    }

    // 移除字符串右边的空白字符
    public static function trimRight(str:String):String {
        while (str.charAt(str.length - 1) == " ") {
            str = str.substring(0, str.length - 1);
        }
        return str;
    }

    // 将字符串重复指定次数
    public static function repeat(str:String, count:Number):String {
        var result:String = "";
        for (var i:Number = 0; i < count; i++) {
            result += str;
        }
        return result;
    }

    // 在字符串开头填充字符，直到字符串达到指定长度
    public static function padStart(str:String, targetLength:Number, padString:String):String {
        while (str.length < targetLength) {
            str = padString + str;
        }
        return str;
    }

    // 在字符串末尾填充字符，直到字符串达到指定长度
    public static function padEnd(str:String, targetLength:Number, padString:String):String {
        while (str.length < targetLength) {
            str += padString;
        }
        return str;
    }

    // 使用正则表达式匹配，返回匹配的数组
    public static function match(str:String, pattern:String, flags:String):Array {
        var regex:RegExp = new RegExp(pattern, flags);
        var result:Array = [];
        var match:Array = regex.exec(str);
        
        while (match != null) {
            result.push(match[0]);  // 添加整个匹配结果
            match = regex.exec(str);  // 继续匹配
        }
        
        return result.length > 0 ? result : null;
    }

    // 使用正则表达式替换
    public static function replace(str:String, pattern:String, replacement:String, flags:String):String {
        var regex:RegExp = new RegExp(pattern, flags);
        var result:String = "";
        var lastIndex:Number = 0;
        var match:Array = regex.exec(str);

        while (match != null) {
            result += str.substring(lastIndex, match.index);  // 添加非匹配部分
            result += replacement;  // 添加替换内容
            lastIndex = match.index + match[0].length;  // 更新索引
            match = regex.exec(str);  // 继续匹配
        }
        
        result += str.substring(lastIndex);  // 添加剩余部分
        return result;
    }

    // 使用正则表达式查找位置
    public static function search(str:String, pattern:String, flags:String):Number {
        var regex:RegExp = new RegExp(pattern, flags);
        var match:Array = regex.exec(str);
        return match != null ? match.index : -1;
    }

    // 使用正则表达式拆分字符串
    public static function split(str:String, pattern:String, flags:String):Array {
        var regex:RegExp = new RegExp(pattern, flags);
        var result:Array = [];
        var lastIndex:Number = 0;
        var match:Array = regex.exec(str);

        while (match != null) {
            result.push(str.substring(lastIndex, match.index));  // 添加拆分的部分
            lastIndex = match.index + match[0].length;  // 更新索引
            match = regex.exec(str);  // 继续匹配
        }

        result.push(str.substring(lastIndex));  // 添加剩余部分
        return result;
    }
}
