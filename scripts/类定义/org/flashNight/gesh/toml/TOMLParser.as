import org.flashNight.gesh.object.*;
import org.flashNight.gesh.string.*;
class org.flashNight.gesh.toml.TOMLParser {
    private var tokens:Array;       // 词法分析器生成的标记列表
    private var position:Number;    // 当前标记位置
    private var current:Object;     // 当前正在处理的对象
    private var root:Object;        // 最终解析后的结果对象
    private var hasErrorFlag:Boolean; // 错误标志

    public function TOMLParser(tokens:Array) {
        this.tokens = tokens;
        this.position = 0;
        this.root = {};
        this.current = this.root;
        this.hasErrorFlag = false;
    }

    public function parse():Object {
        trace("TOMLParser.parse: 开始解析");
        while (this.position < this.tokens.length) {
            var token:Object = this.tokens[this.position];
            trace("TOMLParser.parse: 处理 token " + this.position + ": " + token.type + " => " + token.value);

            switch (token.type) {
                case "KEY":
                    this.handleKey(token);
                    break;
                case "TABLE_HEADER":
                    this.handleTableHeader(token.value);
                    this.position++;
                    break;
                case "TABLE_ARRAY":
                    this.handleTableArray(token.value);
                    this.position++;
                    break;
                default:
                    this.error("未处理的 token 类型: " + token.type, "");
                    this.position++;
                    break;
            }

            if (this.hasErrorFlag) {
                trace("TOMLParser.parse: 解析过程中遇到错误，停止解析");
                break; // 停止解析
            }
        }
        trace("TOMLParser.parse: 解析完成");
        return this.root;
    }


    public function hasError():Boolean {
        return this.hasErrorFlag;
    }

    private function handleKey(token:Object):Void {
        var key:String = token.value;
        trace("TOMLParser.handleKey: 处理键: " + key);

        var nextPos:Number = this.position + 1;
        if (nextPos >= this.tokens.length || this.tokens[nextPos].type != "EQUALS") {
            this.error("期望 EQUALS 标记", key);
            return;
        }

        var valuePos:Number = nextPos + 1;
        if (valuePos >= this.tokens.length) {
            this.error("值缺失", key);
            return;
        }

        var valueToken:Object = this.tokens[valuePos];
        var value:Object = this.parseValue(valueToken);
        trace("TOMLParser.handleKey: 解析键 '" + key + "' 的值: " + ObjectUtil.toString(value));

        // 允许 null 值，不再将其视为错误
        this.current[key] = value;

        // 更新位置到值标记之后
        this.position = valuePos + 1;
    }

    private function parseValue(token:Object):Object {
        trace("TOMLParser.parseValue: 解析值 - 类型: " + token.type + ", 值: " + token.value);
        switch (token.type) {
            case "STRING":
                return token.value;
            case "INTEGER":
                return Number(token.value);
            case "FLOAT":
                return this.parseSpecialFloat(token.value);
            case "BOOLEAN":
                return token.value == true;
            case "DATETIME":
                return token.value;
            case "ARRAY":
                return this.parseArray(token.value);
            case "INLINE_TABLE":
                return this.parseInlineTable(token.value);
            case "NULL":
                return null;
            default:
                this.error("未知的值类型: " + token.type, "");
                return null;
        }
    }

    /**
     * 解析特殊浮点数值
     * @param value 字符串形式的浮点数值
     * @return AS2 中的数值类型（NaN, Infinity, -Infinity）
     */
    private function parseSpecialFloat(value:String):Object {
        switch (value) {
            case "nan":
                return NaN;
            case "inf":
                return Infinity;
            case "-inf":
                return -Infinity;
            default:
                return Number(value);
        }
    }

    private function parseArray(arrayData):Array {
        trace("TOMLParser.parseArray: 解析数组");
        var array:Array = [];

        // 如果 arrayData 已经是数组，直接返回
        if (arrayData instanceof Array) {
            trace("TOMLParser.parseArray: arrayData 已经是数组");
            // 确保元素类型正确
            for (var i:Number = 0; i < arrayData.length; i++) {
                var elem = arrayData[i];
                array.push(elem);
            }
            return array;
        }

        // 确保 arrayData 是字符串
        if (typeof(arrayData) != "string") {
            arrayData = String(arrayData);
        }

        // 去除外围的方括号
        if (arrayData.charAt(0) == "[" && arrayData.charAt(arrayData.length - 1) == "]") {
            arrayData = arrayData.substring(1, arrayData.length - 1);
        }

        // 移除所有换行符并修剪
        arrayData = this.removeLineBreaks(arrayData);
        arrayData = org.flashNight.gesh.string.StringUtils.trim(arrayData);
        trace("TOMLParser.parseArray: arrayData = " + arrayData);

        if (arrayData.length == 0) {
            trace("TOMLParser.parseArray: 空数组");
            return array; // 返回空数组
        }

        // 按逗号分割数组元素
        var elements:Array = arrayData.split(",");
        for (var i:Number = 0; i < elements.length; i++) {
            var elem:String = org.flashNight.gesh.string.StringUtils.trim(elements[i]);
            trace("TOMLParser.parseArray: 解析元素 " + i + ": " + elem);

            // 判断元素类型
            if (elem.length == 0) continue;

            // 判断元素类型
            if (elem.charAt(0) == "\"" || elem.charAt(0) == "'") {
                array.push(this.stripQuotes(elem));  // 去掉引号的字符串
            } else if (elem == "true" || elem == "false") {
                array.push(elem == "true");
            } else if (elem == "nan") {
                array.push(NaN);
            } else if (elem == "inf") {
                array.push(Infinity);
            } else if (elem == "-inf") {
                array.push(-Infinity);
            } else if (!isNaN(Number(elem))) {
                array.push(Number(elem));
            } else {
                array.push(elem);
            }
        }
        return array;
    }

    private function parseInlineTable(tableStr:String):Object {
        trace("TOMLParser.parseInlineTable: 解析内联表格");
        var table:Object = {};

        if (tableStr.charAt(0) == "{" && tableStr.charAt(tableStr.length - 1) == "}") {
            tableStr = tableStr.substring(1, tableStr.length - 1);
        }

        var pairs:Array = tableStr.split(",");
        for (var i:Number = 0; i < pairs.length; i++) {
            var pairStr:String = org.flashNight.gesh.string.StringUtils.trim(pairs[i]);
            trace("TOMLParser.parseInlineTable: 解析键值对 " + i + ": " + pairStr);
            if (pairStr.length == 0) continue;

            var eqIndex:Number = pairStr.indexOf("=");
            if (eqIndex == -1) {
                this.error("内联表格中的键值对缺少 '=': " + pairs[i], "");
                continue;
            }
            var key:String = org.flashNight.gesh.string.StringUtils.trim(pairStr.substring(0, eqIndex));
            var valueStr:String = org.flashNight.gesh.string.StringUtils.trim(pairStr.substring(eqIndex + 1));

            if (key.length == 0) {
                this.error("内联表格中的键为空: " + pairs[i], "");
                continue;
            }

            var value:Object;
            if (valueStr.charAt(0) == "\"" || valueStr.charAt(0) == "'") {
                value = this.stripQuotes(valueStr);
            } else if (valueStr == "true" || valueStr == "false") {
                value = valueStr == "true";
            } else if (valueStr == "nan") {
                value = NaN;
            } else if (valueStr == "inf") {
                value = Infinity;
            } else if (valueStr == "-inf") {
                value = -Infinity;
            } else if (!isNaN(Number(valueStr))) {
                value = Number(valueStr);
            } else {
                value = valueStr;
            }

            trace("TOMLParser.parseInlineTable: 解析结果 - " + key + " = " + value);
            table[key] = value;
        }
        return table;
    }

    private function handleTableHeader(tableName:String):Void {
        trace("TOMLParser.handleTableHeader: 处理表格头 - " + tableName);
        var path:Array = tableName.split(".");
        var current:Object = this.root;
        for (var i:Number = 0; i < path.length; i++) {
            var part:String = path[i];
            if (!current[part]) {
                current[part] = {};
                trace("TOMLParser.handleTableHeader: 创建嵌套表格 - " + part);
            }
            current = current[part];
        }
        this.current = current;
    }

    private function handleTableArray(arrayName:String):Void {
        trace("TOMLParser.handleTableArray: 处理表格数组 - " + arrayName);
        var path:Array = arrayName.split(".");
        var current:Object = this.root;
        for (var i:Number = 0; i < path.length; i++) {
            var part:String = path[i];
            if (!current[part]) {
                current[part] = [];
                trace("TOMLParser.handleTableArray: 创建表格数组 - " + part);
            }
            if (i == path.length - 1) {
                var newTable:Object = {};
                current[part].push(newTable);
                trace("TOMLParser.handleTableArray: 添加新表格到数组 - " + part);
                current = newTable;
            } else {
                current = current[part];
            }
        }
        this.current = current;
    }

    private function stripQuotes(str:String):String {
        if ((str.charAt(0) == "\"" && str.charAt(str.length - 1) == "\"") ||
            (str.charAt(0) == "'" && str.charAt(str.length - 1) == "'")) {
            return str.substring(1, str.length - 1);
        }
        return str;
    }

    private function removeLineBreaks(str:String):String {
        trace("TOMLParser.removeLineBreaks: 移除换行符");
        // 确保 str 是字符串
        if (typeof(str) != "string") {
            str = String(str);
        }
        var result:String = "";
        for (var i:Number = 0; i < str.length; i++) {
            var c:String = str.charAt(i);
            if (c != "\n" && c != "\r") {
                result += c;
            }
        }
        trace("TOMLParser.removeLineBreaks: 结果 - " + result);
        return result;
    }

    private function error(message:String, key:String):Void {
        trace("解析错误: " + message + " 键: " + key + " 在标记位置: " + this.position);
        this.hasErrorFlag = true;
    }
}
