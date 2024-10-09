class org.flashNight.gesh.toml.TOMLLexer {
    private var text:String;          // TOML 文件内容
    private var position:Number;      // 当前字符位置
    private var currentChar:String;   // 当前处理的字符
    private var loopCounter:Number;   // 循环计数器，用于防止死循环
    private var maxLoops:Number = 1000; // 最大循环次数
    private var inValue:Boolean;      // 标志当前是否在值的上下文中

    // 构造函数，初始化词法分析器
    public function TOMLLexer(text:String) {
        this.text = text;
        this.position = 0;
        this.loopCounter = 0;
        this.inValue = false;
        this.nextChar();  
    }

    // 移动到下一个字符
    private function nextChar():Void {
        if (this.position < this.text.length) {
            this.currentChar = this.text.charAt(this.position);
            this.position++;
        } else {
            this.currentChar = null; 
        }
    }

    // 跳过空白字符及注释
    private function skipWhitespaceAndComments():Void {
        while (this.currentChar != null && 
               (this.currentChar == " " || this.currentChar == "\t" || 
                this.currentChar == "\n" || this.currentChar == "\r" || this.currentChar == "#")) {
            if (this.currentChar == "#") {
                // 跳过注释，直到行末
                while (this.currentChar != "\n" && this.currentChar != null) {
                    this.nextChar();
                }
            }
            this.nextChar(); 
        }
    }

    // 获取下一个标记 (Token)
    public function getNextToken():Object {
        this.loopCounter = 0; 
        while (this.currentChar != null) {
            this.loopCounter++;
            if (this.loopCounter > this.maxLoops) {
                trace("警告: 循环次数过多，可能存在死循环");
                break;
            }

            this.skipWhitespaceAndComments();

            if (this.currentChar == null) {
                return null; 
            }

            var token:Object = {};

            if (this.isAlpha(this.currentChar)) {
                var keyword:String = this.readKey().value;
                if (keyword == "true" || keyword == "false") {
                    token = { type: "BOOLEAN", value: (keyword == "true") };
                    this.inValue = false;
                } else {
                    token = { type: "KEY", value: keyword };
                    this.inValue = false;
                }
                return token;
            } else if (this.currentChar == "=") {
                token = { type: "EQUALS", value: "=" };
                this.nextChar();
                this.inValue = true;
                return token;
            } else if (this.currentChar == "\"" || this.currentChar == "'") {
                token = this.readString();
                this.inValue = false;
                return token;
            } else if (this.isDigit(this.currentChar) || this.currentChar == "-") {
                token = this.readNumberOrDate();
                this.inValue = false;
                return token;
            } else if (this.currentChar == "[") {
                if (this.inValue) {
                    token = this.readArray(); // 解析为数组
                } else {
                    token = this.readTableHeader(); // 解析为表格或表格数组
                }
                this.inValue = false;
                return token;
            } else if (this.currentChar == "{") {
                token = this.readInlineTable(); // 解析内联表格
                this.inValue = false;
                return token;
            } else {
                this.error("未知的标记类型");
                return null;
            }
        }

        return null;
    }

    // 读取键名
    private function readKey():Object {
        var key:String = "";
        while (this.isAlphaNumeric(this.currentChar) || this.currentChar == "_") {
            key += this.currentChar;
            this.nextChar();
        }
        return { type: "KEY", value: key };
    }

    // 读取字符串（支持多行字符串）
    private function readString():Object {
        var str:String = "";
        var quoteType:String = this.currentChar;
        var isMultiline:Boolean = false;
        this.nextChar(); 

        if (this.currentChar == quoteType && this.peek() == quoteType) {
            isMultiline = true;
            this.nextChar(); this.nextChar(); 
        }

        while (this.currentChar != quoteType || 
              (isMultiline && this.peek() == quoteType && this.peekAhead(2) == quoteType)) {
            if (this.currentChar == null) {
                this.error("未关闭的字符串");
                break;
            }
            str += this.currentChar;
            this.nextChar();
        }

        this.nextChar(); 
        if (isMultiline) {
            this.nextChar(); this.nextChar(); 
        }

        return { type: "STRING", value: str };
    }

    // 读取数字或日期时间
    private function readNumberOrDate():Object {
        var number:String = "";
        var isFloat:Boolean = false;

        if (this.currentChar == "-") {  
            number += "-";
            this.nextChar();
        }

        while (this.isDigit(this.currentChar) || this.currentChar == "_") {
            number += this.currentChar;
            this.nextChar();
        }

        if (this.currentChar == ".") {  
            isFloat = true;
            number += ".";
            this.nextChar();
            while (this.isDigit(this.currentChar)) {
                number += this.currentChar;
                this.nextChar();
            }
        }

        // 如果下一个字符指示这是一个日期时间
        if (this.currentChar == "T" || this.currentChar == "Z" || this.currentChar == ":" || this.currentChar == "-") {
            return this.readDateTime(number);  
        }

        return { type: isFloat ? "FLOAT" : "INTEGER", value: number };
    }

    // 读取日期时间
    private function readDateTime(initial:String):Object {
        var dateTime:String = initial;

        while (this.isAlphaNumeric(this.currentChar) || this.currentChar == "-" || this.currentChar == ":" || this.currentChar == "T" || this.currentChar == "Z") {
            dateTime += this.currentChar;
            this.nextChar();
        }

        return { type: "DATETIME", value: dateTime };
    }

    // 读取数组
    private function readArray():Object {
        var array:Array = [];
        this.nextChar(); // 跳过 '['

        this.skipWhitespaceAndComments();

        while (this.currentChar != "]" && this.currentChar != null) {
            if (this.currentChar == ",") {
                this.nextChar(); // 跳过逗号
                this.skipWhitespaceAndComments();
                continue;
            }

            var element:Object;

            if (this.currentChar == "\"" || this.currentChar == "'") {
                element = this.readString();
            } else if (this.isDigit(this.currentChar) || this.currentChar == "-") {
                element = this.readNumberOrDate();
            } else {
                this.error("无效的数组元素");
                break;
            }

            array.push(element.value);
            this.skipWhitespaceAndComments();

            if (this.currentChar == ",") {
                this.nextChar(); // 跳过逗号
                this.skipWhitespaceAndComments();
            }
        }

        this.nextChar(); // 跳过 ']'
        return { type: "ARRAY", value: array };
    }

    // 读取内联表格
    private function readInlineTable():Object {
        var inlineTable:String = "";
        this.nextChar(); // 跳过 '{'

        while (this.currentChar != "}" && this.currentChar != null) {
            inlineTable += this.currentChar;
            this.nextChar();
        }

        this.nextChar(); // 跳过 '}'
        return { type: "INLINE_TABLE", value: inlineTable };
    }

    // 读取表格头或表格数组
    private function readTableHeader():Object {
        var tableName:String = "";
        this.nextChar(); // 跳过 '['

        // 检查是否为表格数组（开始于第二个 '['）
        if (this.currentChar == "[") {
            this.nextChar(); // 跳过第二个 '['
            while (this.currentChar != "]" || this.peek() != "]") {
                tableName += this.currentChar;
                this.nextChar();
            }
            this.nextChar(); // 跳过第一个 ']'
            this.nextChar(); // 跳过第二个 ']'
            return { type: "TABLE_ARRAY", value: tableName };
        }

        // 否则，解析为普通表格
        while (this.currentChar != "]" && this.currentChar != null) {
            tableName += this.currentChar;
            this.nextChar();
        }

        this.nextChar(); // 跳过 ']'
        return { type: "TABLE_HEADER", value: tableName };
    }

    // 检查字符是否为字母
    private function isAlpha(c:String):Boolean {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z");
    }

    // 检查字符是否为字母或数字
    private function isAlphaNumeric(c:String):Boolean {
        return this.isAlpha(c) || (c >= "0" && c <= "9");
    }

    // 检查字符是否为数字
    private function isDigit(c:String):Boolean {
        return c >= "0" && c <= "9";
    }

    // 查看下一个字符而不移动指针
    private function peek():String {
        if (this.position < this.text.length) {
            return this.text.charAt(this.position);
        }
        return "";
    }

    // 查看接下来的第 n 个字符而不移动指针
    private function peekAhead(n:Number):String {
        if (this.position + n < this.text.length) {
            return this.text.charAt(this.position + n);
        }
        return "";
    }

    // 抛出错误
    private function error(message:String):Void {
        trace("Error: " + message);
    }
}
