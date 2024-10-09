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
        while (this.position < this.tokens.length) {
            var token:Object = this.tokens[this.position];
            // trace("Processing token: " + token.type + " => " + token.value);

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
                    this.position++;
                    break;
            }

            if (this.hasErrorFlag) {
                break; // 停止解析
            }
        }

        return this.root;
    }

    public function hasError():Boolean {
        return this.hasErrorFlag;
    }

    private function handleKey(token:Object):Void {
        var key:String = token.value;
        // trace("Handling key: " + key);

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
        // trace("Parsed value for key '" + key + "': " + value);

        if (value !== null) {
            this.current[key] = value;
        } else {
            this.error("无法解析值", key);
        }

        // 更新位置到值标记之后
        this.position = valuePos + 1;
    }

    private function parseValue(token:Object):Object {
        // trace("Parsing value: " + token.type + " => " + token.value);
        switch (token.type) {
            case "STRING":
                return token.value;
            case "INTEGER":
                return Number(token.value);
            case "FLOAT":
                return Number(token.value);
            case "BOOLEAN":
                return token.value == true;
            case "DATETIME":
                return token.value;
            case "ARRAY":
                // 检查 token.value 是否已经是数组
                if (token.value instanceof Array) {
                    return token.value;
                } else {
                    return this.parseArray(token.value);
                }
            case "INLINE_TABLE":
                return this.parseInlineTable(token.value);
            default:
                this.error("未知的值类型: " + token.type, "");
                return null;
        }
    }

    private function parseArray(arrayData):Array {
        // trace("Parsing array: " + arrayData + ", type: " + typeof(arrayData));
        var array:Array = [];

        // 如果 arrayData 是数组，直接返回
        if (arrayData instanceof Array) {
            return arrayData;
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
        // trace("Array after trimming and removing line breaks: " + arrayData);

        if (arrayData.length == 0) {
            return array; // 返回空数组
        }

        // 按逗号分割数组元素
        var elements:Array = arrayData.split(",");
        for (var i:Number = 0; i < elements.length; i++) {
            var elem:String = org.flashNight.gesh.string.StringUtils.trim(elements[i]);
            // trace("Array element " + i + ": " + elem);

            if (elem.length == 0) continue;

            // 判断元素类型
            if (elem.charAt(0) == "\"" || elem.charAt(0) == "'") {
                array.push(this.stripQuotes(elem));  // 去掉引号的字符串
            } else if (elem == "true" || elem == "false") {
                array.push(elem == "true");
            } else if (!isNaN(Number(elem))) {
                array.push(Number(elem));
            } else {
                array.push(elem);
            }
        }
        return array;
    }

    private function parseInlineTable(tableStr:String):Object {
        // trace("Parsing inline table: " + tableStr);
        var table:Object = {};

        if (tableStr.charAt(0) == "{" && tableStr.charAt(tableStr.length - 1) == "}") {
            tableStr = tableStr.substring(1, tableStr.length - 1);
        }

        var pairs:Array = tableStr.split(",");
        for (var i:Number = 0; i < pairs.length; i++) {
            var pairStr:String = org.flashNight.gesh.string.StringUtils.trim(pairs[i]);
            // trace("Inline table pair " + i + ": " + pairStr);
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
            } else if (!isNaN(Number(valueStr))) {
                value = Number(valueStr);
            } else {
                value = valueStr;
            }

            // trace("Inline table parsed pair: " + key + " => " + value);
            table[key] = value;
        }
        return table;
    }

    private function handleTableHeader(tableName:String):Void {
        // trace("Handling table header: " + tableName);
        var path:Array = tableName.split(".");
        var current:Object = this.root;
        for (var i:Number = 0; i < path.length; i++) {
            var part:String = path[i];
            if (!current[part]) {
                current[part] = {};
            }
            current = current[part];
        }
        this.current = current;
    }

    private function handleTableArray(arrayName:String):Void {
        // trace("Handling table array: " + arrayName);
        var path:Array = arrayName.split(".");
        var current:Object = this.root;
        for (var i:Number = 0; i < path.length; i++) {
            var part:String = path[i];
            if (!current[part]) {
                current[part] = [];
            }
            if (i == path.length - 1) {
                var newTable:Object = {};
                current[part].push(newTable);
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
        // trace("removeLineBreaks input: " + str + ", type: " + typeof(str));
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
        // trace("removeLineBreaks output: " + result);
        return result;
    }

    private function error(message:String, key:String):Void {
        trace("解析错误: " + message + " 键: " + key + " 在标记位置: " + this.position);
        this.hasErrorFlag = true;
    }
}
