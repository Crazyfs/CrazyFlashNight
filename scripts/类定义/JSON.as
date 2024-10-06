

/*
   //  # JSON 类 使用文档

   // ## 概述

   // `JSON` 类是一个用于在 ActionScript 2 (AS2) 中解析和序列化 JSON 数据的工具。除了支持标准的 JSON 功能外，该类还扩展了对注释（单行 `//` 和多行 `/ * * /`）的支持，增强了 JSON 数据在开发过程中的可读性和可维护性。此外，`JSON` 类具备循环引用检测和递归深度限制等高级特性，确保数据处理的稳定性和安全性。

   // ## 版本信息

   // - **版本**: 1.2
   // - **发布日期**: 2024-10-06

   // ## 类结构

   // ```actionscript
   // class JSON {
   //     // 私有变量
   //     private var text:String;
   //     private var ch:String;
   //     private var at:Number;
   //     private var line:Number;
   //     private var column:Number;
   //     private var seen:Array;
   //     private var maxDepth:Number;
   //     private var currentDepth:Number;

   //     // 构造函数
   //     public function JSON();

   //     // 公共方法
   //     public function stringify(arg, indent:String):String;
   //     public function parse(_text:String):Object;

   //     // 私有方法
   //     // ...（省略内部方法详细内容）
   // }
   // ```

   // ## 构造函数

   // ### `JSON()`

   // 创建一个新的 `JSON` 实例。

   // **示例**：

   // ```actionscript
   // var jsonParser:JSON = new JSON();
   // ```

   // ## 主要方法

   // ### `stringify(arg, indent:String):String`

   // 将 ActionScript 对象序列化为 JSON 字符串。

   // - **参数**：
   //   - `arg`：要序列化的对象。
   //   - `indent`（可选）：用于格式化输出的缩进字符串（如 `"  "` 或 `"\t"`）。如果不传递此参数，输出的 JSON 字符串将不进行缩进格式化。

   // - **返回值**：序列化后的 JSON 字符串。

   // - **示例**：

   // ```actionscript
   // var obj:Object = { name: "张三", age: 30, hobbies: ["读书", "游泳"] };
   // var jsonString:String = jsonParser.stringify(obj, "  ");
   // trace(jsonString);
   // /*
   // 输出：
   // {
   //   "name":"张三",
   //   "age":30,
   //   "hobbies":[
   //     "读书",
   //     "游泳"
   //   ]
   // }
   // */
// ```

// ### `parse(_text:String):Object`

// 将 JSON 字符串解析为 ActionScript 对象。该方法支持标准 JSON 格式，并扩展支持单行和多行注释。

// - **参数**：
//   - `_text`：要解析的 JSON 字符串。

// - **返回值**：解析后的 ActionScript 对象。

// - **示例**：

// ```actionscript
// var jsonString:String = '{
//   // 用户信息
//   "name": "张三",
//   "age": 30,
//   /* 爱好列表 */
//   "hobbies": ["读书", "游泳"]
// }';
// var obj:Object = jsonParser.parse(jsonString);
// trace(obj.name); // 输出：张三
// trace(obj.age);  // 输出：30
// trace(obj.hobbies); // 输出：读书,游泳
// ```

// ## 特性详解

// ### 1. **标准 JSON 支持**

// `JSON` 类完整支持标准 JSON 的序列化和解析，包括对象、数组、字符串、数字、布尔值和 `null`。

// ### 2. **注释支持**

// 标准 JSON 不支持注释，而 `JSON` 类通过扩展实现了单行注释 `//` 和多行注释 `/* */` 的解析。这使得 JSON 文件在开发过程中更具可读性和可维护性。

// **示例**：

// ```json
// {
//   // 这是一个用户对象
//   "name": "李四",
//   /* 用户年龄 */
//   "age": 25
// }
// ```

// ### 3. **错误处理**

// `JSON` 类在解析和序列化过程中提供详细的错误信息，包括错误类型、错误信息以及错误发生的位置（行号和列号），有助于开发者快速定位和修复问题。

// **示例**：

// 如果 JSON 字符串中存在未终止的多行注释，调用 `parse` 方法将抛出如下错误：

// ```actionscript
// {
//   /* 未终止的注释
//   "name": "王五"
// }
// ```

// 抛出的错误对象：

// ```actionscript
// {
//   name: "JSONError",
//   message: "未终止的多行注释",
//   line: 3,
//   column: 1,
//   text: "{ /* 未终止的注释 \n \"name\": \"王五\" \n}"
// }
// ```

// ### 4. **循环引用检测**

// 在序列化过程中，`JSON` 类会检测对象的循环引用，防止因无限递归导致的栈溢出或性能问题。如果检测到循环引用，将抛出错误。

// **示例**：

// ```actionscript
// var obj:Object = {};
// obj.self = obj;
// jsonParser.stringify(obj); // 将抛出 "循环引用被检测到" 错误
// ```

// ### 5. **递归深度限制**

// 为了防止过深的嵌套结构导致的性能问题或栈溢出，`JSON` 类设置了默认的最大解析深度 `maxDepth`（默认值为 1000）。如果解析深度超过此限制，将抛出错误。

// **示例**：

// ```actionscript
// var deepObj:Object = {};
// var current:Object = deepObj;
// for (var i:Number = 0; i < 1001; i++) {
//     current["child"] = {};
//     current = current["child"];
// }
// jsonParser.stringify(deepObj); // 将抛出 "解析深度超过最大限制: 1000" 错误
// ```

// ### 6. **自定义 `toJSON` 方法支持**

// 如果对象具有 `toJSON` 方法，`JSON` 类在序列化时将优先调用该方法，以获取对象的序列化表示。这为开发者提供了自定义序列化逻辑的灵活性。

// **示例**：

// ```actionscript
// var user:Object = {
//     name: "赵六",
//     birthdate: new Date(),
//     toJSON: function() {
//         return { 
//             name: this.name, 
//             birthdate: this.birthdate.getTime() 
//         };
//     }
// };
// var jsonString:String = jsonParser.stringify(user);
// trace(jsonString); // 输出：{"name":"赵六","birthdate":1633072800000}
// ```

// ## 使用示例

// ### 1. 序列化对象为 JSON 字符串

// ```actionscript
// var jsonParser:JSON = new JSON();

// var user:Object = {
//     name: "张三",
//     age: 30,
//     hobbies: ["读书", "游泳"],
//     address: {
//         city: "北京",
//         zip: "100000"
//     }
// };

// var jsonString:String = jsonParser.stringify(user, "  ");
// trace(jsonString);
// /*
// 输出：
// {
//   "name":"张三",
//   "age":30,
//   "hobbies":[
//     "读书",
//     "游泳"
//   ],
//   "address":{
//     "city":"北京",
//     "zip":"100000"
//   }
// }
// */
// ```

// ### 2. 解析 JSON 字符串为对象

// ```actionscript
// var jsonParser:JSON = new JSON();

// var jsonString:String = '{
//   // 用户信息
//   "name": "李四",
//   /* 用户年龄 */
//   "age": 25,
//   "hobbies": ["音乐", "篮球"]
// }';

// var user:Object = jsonParser.parse(jsonString);
// trace(user.name); // 输出：李四
// trace(user.age);  // 输出：25
// trace(user.hobbies); // 输出：音乐,篮球
// ```

// ### 3. 处理循环引用

// ```actionscript
// var jsonParser:JSON = new JSON();

// var obj:Object = {};
// obj.self = obj;

// try {
//     var jsonString:String = jsonParser.stringify(obj);
// } catch (e:Object) {
//     trace(e.message); // 输出：循环引用被检测到
// }
// ```

// ### 4. 使用自定义 `toJSON` 方法

// ```actionscript
// var jsonParser:JSON = new JSON();

// var product:Object = {
//     name: "手机",
//     price: 2999.99,
//     toJSON: function() {
//         return { 
//             productName: this.name, 
//             productPrice: this.price 
//         };
//     }
// };

// var jsonString:String = jsonParser.stringify(product, "\t");
// trace(jsonString);
// /*
// 输出：
// {
// 	"productName": "手机",
// 	"productPrice": 2999.99
// }
// */
// ```

// ## 错误处理

// `JSON` 类在解析和序列化过程中可能会抛出各种错误。错误对象包含以下属性：

// - `name`：错误名称（通常为 `"JSONError"`）。
// - `message`：错误信息描述。
// - `line`：错误发生的行号。
// - `column`：错误发生的列号。
// - `text`：被解析的 JSON 字符串。

// **示例**：

// ```actionscript
// var jsonParser:JSON = new JSON();

// var invalidJson:String = '{ "name": "张三", "age": 30, }'; // 末尾多余的逗号

// try {
//     var obj:Object = jsonParser.parse(invalidJson);
// } catch (e:Object) {
//     trace(e.name);    // 输出：JSONError
//     trace(e.message); // 输出：对象解析错误：期望 ',' 
//     trace("行号: " + e.line + ", 列号: " + e.column);
// }
// ```

// ## 注意事项

// 1. **注释的非标准性**：虽然 `JSON` 类支持注释，但这不符合标准 JSON 规范。在与其他严格遵循标准 JSON 解析器交互时，可能会导致兼容性问题。建议在必要时移除注释或使用标准 JSON 格式。

// 2. **性能考虑**：
//    - **循环引用检测**：当前实现使用数组 `seen` 进行循环引用检测，时间复杂度为 O(n)。在处理大型对象时，可能会影响性能。对于性能要求较高的场景，需谨慎使用。
//    - **字符串拼接**：`stringifyString` 方法通过数组 `escaped` 进行字符串拼接，对于非常长的字符串，性能可能较低。

// 3. **Unicode 字符处理**：当前实现支持基本的 Unicode 转义字符，但未处理代理对（surrogate pairs）。在处理包含复杂 Unicode 字符的字符串时，可能会存在解析问题。

// 4. **数字解析的严格性**：`num` 方法在解析数字时，可能未对某些无效格式（如前导零、多余的小数点等）进行严格验证。确保输入的数字格式符合标准规范。

// 5. **数据类型支持**：当前实现主要支持常见的数据类型（对象、数组、字符串、数字、布尔值和 `null`）。特殊对象类型（如 `Date`、`RegExp` 等）在序列化时依赖于自定义逻辑或可能被忽略。

// 6. **错误对象类型**：`error` 方法抛出的错误为普通对象，未使用 ActionScript 的 `Error` 类。开发者在处理错误时需根据对象属性进行判断和处理。

// 7. **最大解析深度**：默认的 `maxDepth` 为 1000。根据实际需求，可能需要调整此值以适应不同的嵌套结构深度。

// ## 总结

// `JSON` 类为 ActionScript 2 开发者提供了强大而灵活的 JSON 解析与序列化功能，扩展支持注释和循环引用检测，极大地提升了开发效率和代码可维护性。通过详细的错误处理和多种高级特性，`JSON` 类能够满足多样化的开发需求。然而，在使用过程中需注意其非标准特性带来的兼容性问题，并根据实际场景进行适当的优化和调整。




/**
 * JSON 类
 * 提供解析和序列化 JSON 数据的功能，支持注释（单行和多行），并具有循环引用检测和最大递归深度限制。
 *
 * @version 1.2
 * @date 2024-10-06
 */
class JSON {
    private var text:String; // 要解析的 JSON 字符串
    private var ch:String; // 当前字符
    private var at:Number; // 当前解析位置索引
    private var line:Number; // 当前行号
    private var column:Number; // 当前列号
    private var seen:Array; // 用于循环引用检测

    private var maxDepth:Number; // 最大解析深度
    private var currentDepth:Number; // 当前解析深度

    /**
     * 构造函数，初始化 JSON 解析器对象。
     * 设置默认的最大解析深度为 1000，并重置解析状态。
     */
    public function JSON() {
        this.text = "";
        this.ch = "";
        this.at = 0;
        this.line = 1;
        this.column = 0;
        this.seen = [];
        this.maxDepth = 1000; // 默认最大解析深度
        this.currentDepth = 0;
    }

    /**
     * 将 ActionScript 对象序列化为 JSON 字符串。
     * 支持处理自定义的 `toJSON` 方法，并检测循环引用。
     * @param arg 要序列化的对象
     * @param indent (可选) 用于缩进的字符串
     * @return 序列化后的 JSON 字符串
     */
    public function stringify(arg, indent:String):String {
        this.seen = []; // 初始化循环引用检测的对象列表
        this.currentDepth = 0; // 初始化当前解析深度
        return this.serialize(arg, indent, 0); // 开始递归序列化
    }

    /**
     * 序列化函数，递归处理不同类型的数据。
     * 支持对象、数组、字符串、数字和布尔值等类型。
     * @param value 要序列化的值
     * @param indent 缩进字符串，用于格式化输出
     * @param level 当前的嵌套深度，用于控制缩进
     * @return 序列化的 JSON 字符串
     */
    private function serialize(value, indent:String, level:Number):String {
        var type:String = typeof value;

        // 如果对象有自定义的 toJSON 方法，优先使用该方法获取序列化后的数据
        if (type === "object" && value && typeof value.toJSON === "function") {
            value = value.toJSON();
            type = typeof value;
        }

        switch (type) {
            case "object":
                if (value === null) {
                    return "null"; // 处理 null 值
                }

                // 递增当前解析深度并检测是否超出最大解析深度
                this.currentDepth++;
                if (this.currentDepth > this.maxDepth) {
                    this.error("解析深度超过最大限制: " + this.maxDepth);
                }

                // 检测是否有循环引用
                if (this.isCircular(value)) {
                    this.error("循环引用被检测到");
                }
                this.seen.push(value); // 将当前对象存入循环检测数组中

                // 如果是数组，递归处理数组内容
                if (value instanceof Array) {
                    var arrayString:String = this.stringifyArray(value, indent, level);
                    this.seen.pop();
                    this.currentDepth--;
                    return arrayString;
                } else { // 处理普通对象
                    var objectString:String = this.stringifyObject(value, indent, level);
                    this.seen.pop();
                    this.currentDepth--;
                    return objectString;
                }

            case "number":
                return isFinite(value) ? String(value) : "null"; // 处理数字

            case "string":
                return this.stringifyString(value); // 处理字符串

            case "boolean":
                return String(value); // 处理布尔值

            default:
                return "null"; // 处理 undefined 和函数
        }
    }

    /**
     * 检测对象是否存在循环引用，防止无限递归。
     * @param obj 要检测的对象
     * @return 如果存在循环引用则返回 true，否则返回 false
     */
    private function isCircular(obj):Boolean {
        for (var i:Number = 0; i < this.seen.length; i++) {
            if (this.seen[i] === obj) {
                return true;
            }
        }
        return false;
    }

    /**
     * 序列化数组，递归处理每个数组元素。
     * @param array 要序列化的数组
     * @param indent 缩进字符串
     * @param level 当前嵌套级别
     * @return JSON 数组的字符串表示
     */
    private function stringifyArray(array:Array, indent:String, level:Number):String {
        var parts:Array = [];
        var newLine:String = "";
        var separator:String = ",";

        // 根据是否需要缩进，设置换行符和分隔符
        if (indent) {
            newLine = "\n";
            separator += newLine + this.getIndent(indent, level + 1);
        }

        // 递归序列化数组中的每个元素
        for (var i:Number = 0; i < array.length; i++) {
            var serializedValue:String = this.serialize(array[i], indent, level + 1);
            parts.push(serializedValue);
        }

        // 组合数组元素为 JSON 字符串
        var joined:String = parts.join(separator);
        if (indent) {
            return "[" + newLine + this.getIndent(indent, level + 1) + joined + newLine + this.getIndent(indent, level) + "]";
        } else {
            return "[" + joined + "]";
        }
    }

    /**
     * 序列化对象，递归处理每个键值对。
     * @param obj 要序列化的对象
     * @param indent 缩进字符串
     * @param level 当前嵌套级别
     * @return JSON 对象的字符串表示
     */
    private function stringifyObject(obj:Object, indent:String, level:Number):String {
        var parts:Array = [];
        var keys:Array = [];

        // 收集对象中的所有有效键
        for (var key in obj) {
            var value = obj[key];
            if (typeof value !== "undefined" && typeof value !== "function") {
                keys.push(key);
            }
        }

        var newLine:String = "";
        var separator:String = ",";

        // 根据是否需要缩进，设置换行符和分隔符
        if (indent) {
            newLine = "\n";
            separator += newLine + this.getIndent(indent, level + 1);
        }

        // 递归序列化每个键值对
        for (var i:Number = 0; i < keys.length; i++) {
            var currentKey:String = keys[i];
            var serializedKey:String = this.stringifyString(currentKey);
            var serializedValue:String = this.serialize(obj[currentKey], indent, level + 1);
            parts.push(serializedKey + ":" + serializedValue);
        }

        // 组合对象的键值对为 JSON 字符串
        var joined:String = parts.join(separator);
        if (indent) {
            return "{" + newLine + this.getIndent(indent, level + 1) + joined + newLine + this.getIndent(indent, level) + "}";
        } else {
            return "{" + joined + "}";
        }
    }

    /**
     * 序列化字符串，处理必要的转义字符（如引号、反斜杠等）。
     * @param str 要序列化的字符串
     * @return JSON 格式的字符串
     */
    private function stringifyString(str:String):String {
        var escaped:Array = [];
        escaped.push('"'); // 加上引号

        // 处理字符串中的每个字符，进行转义
        for (var i:Number = 0; i < str.length; i++) {
            var char:String = str.charAt(i);
            switch (char) {
                case '"':
                    escaped.push('\\"');
                    break;
                case '\\':
                    escaped.push('\\\\');
                    break;
                case '\b':
                    escaped.push('\\b');
                    break;
                case '\f':
                    escaped.push('\\f');
                    break;
                case '\n':
                    escaped.push('\\n');
                    break;
                case '\r':
                    escaped.push('\\r');
                    break;
                case '\t':
                    escaped.push('\\t');
                    break;
                default:
                    escaped.push(char); // 非特殊字符直接添加
            }
        }

        escaped.push('"'); // 结束引号
        return escaped.join(""); // 返回组合后的字符串
    }

    /**
     * 获取缩进字符串，递归层次越深，缩进越多。
     * @param indent 缩进字符串
     * @param level 当前缩进级别
     * @return 拼接后的缩进字符串
     */
    private function getIndent(indent:String, level:Number):String {
        var result:String = "";
        for (var i:Number = 0; i < level; i++) {
            result += indent;
        }
        return result;
    }

    /**
     * 将 JSON 字符串解析为 ActionScript 对象。
     * @param _text 要解析的 JSON 字符串
     * @return 解析后的对象
     */
    public function parse(_text:String):Object {
        this.text = _text;
        this.at = 0;
        this.ch = " "; // 初始化为一个空格字符
        this.line = 1; // 从第一行开始
        this.column = 0; // 列号从 0 开始
        this.currentDepth = 0; // 初始化深度
        this.seen = []; // 初始化循环引用检测数组
        return this.value(); // 解析 JSON 数据
    }

    /**
     * 跳过 JSON 字符串中的空白字符和注释（支持单行和多行注释）。
     */
    private function white():Void {
        while (this.ch) {
            if (this.isWhitespace(this.ch)) {
                this.next();
            } else if (this.ch == "/") { // 检测到注释
                var nextChar:String = this.next();
                if (nextChar == "/") {
                    // 跳过单行注释
                    while (this.ch && this.ch != "\n" && this.ch != "\r") {
                        this.next();
                    }
                } else if (nextChar == "*") {
                    // 跳过多行注释
                    this.next();
                    var foundEnd:Boolean = false;
                    while (this.ch) {
                        if (this.ch == "*") {
                            if (this.next() == "/") {
                                foundEnd = true;
                                break;
                            }
                        } else {
                            this.next();
                        }
                    }
                    if (!foundEnd) {
                        this.error("未终止的多行注释");
                    }
                    this.next();
                } else {
                    this.error("无效的注释开始");
                }
            } else {
                break;
            }
        }
    }

    /**
     * 判断字符是否为空白字符。
     * @param c 字符
     * @return 如果是空白字符则返回 true，否则返回 false
     */
    private function isWhitespace(c:String):Boolean {
        return (c <= " " && (c == " " || c == "\n" || c == "\r" || c == "\t" || c == "\b" || c == "\f"));
    }

    /**
     * 抛出解析错误。
     * @param message 错误信息
     */
    private function error(message:String):Void {
        throw{name: "JSONError", message: message, line: this.line, column: this.column, text: this.text};
    }

    /**
     * 获取 JSON 字符串中的下一个字符，并更新行列号。
     * @return 当前字符
     */
    private function next():String {
        if (this.at < this.text.length) {
            this.ch = this.text.charAt(this.at); // 读取下一个字符
            this.at += 1;
            if (this.ch == "\n") {
                this.line += 1; // 更新行号
                this.column = 0; // 重置列号
            } else {
                this.column += 1; // 更新列号
            }
            return this.ch;
        } else {
            this.ch = ""; // 到达末尾
            return this.ch;
        }
    }

    /**
     * 解析 JSON 字符串中的字符串部分。
     * @return 解析后的字符串
     */
    private function str():String {
        var result:String = "";
        if (this.ch == '"') { // 确保起始字符为引号
            while (this.next()) {
                if (this.ch == '"') { // 检测到结束引号
                    this.next();
                    return result;
                }
                if (this.ch == "\\") { // 处理转义字符
                    var escapeChar:String = this.next();
                    switch (escapeChar) {
                        case "b":
                            result += "\b";
                            break;
                        case "f":
                            result += "\f";
                            break;
                        case "n":
                            result += "\n";
                            break;
                        case "r":
                            result += "\r";
                            break;
                        case "t":
                            result += "\t";
                            break;
                        case "u": // 处理 Unicode 转义字符
                            var hex:String = "";
                            for (var i:Number = 0; i < 4; i++) {
                                var hexChar:String = this.next();
                                if (!this.isHexDigit(hexChar)) {
                                    this.error("无效的 Unicode 转义字符");
                                }
                                hex += hexChar;
                            }
                            var code:Number = parseInt(hex, 16);
                            if (isNaN(code)) {
                                this.error("无效的 Unicode 转义字符");
                            }
                            result += String.fromCharCode(code);
                            break;
                        default:
                            var escapedMapping:Object = new Object();
                            escapedMapping['"'] = '"';
                            escapedMapping['\\'] = '\\';
                            escapedMapping['/'] = '/';
                            escapedMapping['b'] = '\b';
                            escapedMapping['f'] = '\f';
                            escapedMapping['n'] = '\n';
                            escapedMapping['r'] = '\r';
                            escapedMapping['t'] = '\t';

                            result += escapedMapping[escapeChar] !== undefined ? escapedMapping[escapeChar] : escapeChar;
                    }
                } else {
                    result += this.ch; // 普通字符直接加入结果
                }
            }
        }
        this.error("字符串解析错误");
        return null; // 实际上不会到达这里
    }

    /**
     * 判断字符是否为十六进制数字。
     * @param c 字符
     * @return 如果是十六进制数字返回 true，否则返回 false
     */
    private function isHexDigit(c:String):Boolean {
        return ((c >= "0" && c <= "9") || (c >= "A" && c <= "F") || (c >= "a" && c <= "f"));
    }

    /**
     * 解析 JSON 数组部分。
     * @return 解析后的数组
     */
    private function arr():Array {
        var array:Array = [];
        if (this.ch == "[") {
            this.next();
            this.white();
            if (this.ch == "]") {
                this.next();
                return array; // 空数组
            }
            while (this.ch) {
                array.push(this.value()); // 递归解析数组中的值
                this.white();
                if (this.ch == "]") {
                    this.next();
                    return array;
                }
                if (this.ch != ",") {
                    break;
                }
                this.next();
                this.white();
            }
        }
        this.error("数组解析错误");
        return null; // 实际上不会到达这里
    }

    /**
     * 解析 JSON 对象部分。
     * @return 解析后的对象
     */
    private function obj():Object {
        var object:Object = {};
        if (this.ch == "{") {
            this.next();
            this.white();
            if (this.ch == "}") {
                this.next();
                return object; // 空对象
            }
            while (this.ch) {
                var key:String = this.str(); // 解析键
                this.white();
                if (this.ch != ":") {
                    this.error("对象解析错误：期望 ':'");
                }
                this.next();
                var value:Object = this.value(); // 解析值
                object[key] = value;
                this.white();
                if (this.ch == "}") {
                    this.next();
                    return object;
                }
                if (this.ch != ",") {
                    this.error("对象解析错误：期望 ','");
                }
                this.next();
                this.white();
            }
        }
        this.error("对象解析错误");
        return null; // 实际上不会到达这里
    }

    /**
     * 解析 JSON 数字部分。
     * @return 解析后的数字
     */
    private function num():Number {
        var numStr:String = "";
        if (this.ch == "-") { // 处理负号
            numStr = "-";
            this.next();
        }
        while (this.ch >= "0" && this.ch <= "9") {
            numStr += this.ch;
            this.next();
        }
        if (this.ch == ".") { // 处理小数部分
            numStr += ".";
            this.next();
            while (this.ch >= "0" && this.ch <= "9") {
                numStr += this.ch;
                this.next();
            }
        }
        if (this.ch == "e" || this.ch == "E") { // 处理指数部分
            numStr += this.ch;
            this.next();
            if (this.ch == "-" || this.ch == "+") {
                numStr += this.ch;
                this.next();
            }
            while (this.ch >= "0" && this.ch <= "9") {
                numStr += this.ch;
                this.next();
            }
        }
        var number:Number = Number(numStr);
        if (!isFinite(number)) {
            this.error("无效的数字");
        }
        return number;
    }

    /**
     * 解析 JSON 字面量（true, false, null）。
     * @return 解析后的值
     */
    private function word() {
        switch (this.ch) {
            case "t":
                if (this.next() == "r" && this.next() == "u" && this.next() == "e") {
                    this.next();
                    return true;
                }
                break;
            case "f":
                if (this.next() == "a" && this.next() == "l" && this.next() == "s" && this.next() == "e") {
                    this.next();
                    return false;
                }
                break;
            case "n":
                if (this.next() == "u" && this.next() == "l" && this.next() == "l") {
                    this.next();
                    return null;
                }
                break;
        }
        this.error("无效的字面量");
    }

    /**
     * 解析 JSON 值，根据当前字符类型判断并调用相应的解析方法。
     * @return 解析后的值
     */
    private function value():Object {
        this.white();
        switch (this.ch) {
            case "{":
                return this.obj(); // 解析对象
            case "[":
                return this.arr(); // 解析数组
            case '"':
                return this.str(); // 解析字符串
            case '-':
                return this.num(); // 解析数字
            default:
                if (this.ch >= "0" && this.ch <= "9") {
                    return this.num(); // 解析数字
                } else {
                    return this.word(); // 解析 true/false/null
                }
        }
    }
}
