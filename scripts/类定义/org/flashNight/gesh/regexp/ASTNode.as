class org.flashNight.gesh.regexp.ASTNode {
    public var type:String;
    public var value:Object;
    public var child:ASTNode;
    public var children:Array;
    public var left:ASTNode;
    public var right:ASTNode;
    public var min:Number;
    public var max:Number;
    public var negated:Boolean;
    public var capturing:Boolean;
    public var greedy:Boolean; // 新增属性，表示量词是否贪婪

    public function ASTNode(type:String) {
        this.type = type;
        this.value = null;
        this.child = null;
        this.children = null;
        this.left = null;
        this.right = null;
        this.min = 1;
        this.max = 1;
        this.negated = false;
        this.capturing = false;
        this.greedy = true; // 默认贪婪匹配
    }

    public function match(input:String, position:Number, captures:Array, ignoreCase:Boolean):Object {
        var result:Object = { matched: false, position: position, captures: captures.slice() };
        if (this.type == 'Literal') {
            if (position < input.length && charEquals(input.charAt(position), String(this.value), ignoreCase)) {
                result.matched = true;
                result.position = position + 1;
            }
        } else if (this.type == 'Any') {
            if (position < input.length) {
                result.matched = true;
                result.position = position + 1;
            }
        } else if (this.type == 'Sequence') {
            var currentPosition:Number = position;
            var currentCaptures:Array = captures.slice();
            for (var i:Number = 0; i < this.children.length; i++) {
                var childResult:Object = this.children[i].match(input, currentPosition, currentCaptures, ignoreCase);
                if (!childResult.matched) {
                    return { matched: false, position: position, captures: captures.slice() };
                }
                currentPosition = childResult.position;
                currentCaptures = childResult.captures; // 使用子节点的捕获组
            }
            result.matched = true;
            result.position = currentPosition;
            result.captures = currentCaptures; // 返回累积的捕获组
        } else if (this.type == 'CharacterClass') {
            if (position < input.length) {
                var char:String = input.charAt(position);
                var inSet:Boolean = false;
                for (var i:Number = 0; i < this.value.length; i++) {
                    if (charEquals(this.value[i], char, ignoreCase)) {
                        inSet = true;
                        break;
                    }
                }
                if (this.negated) {
                    inSet = !inSet;
                }
                if (inSet) {
                    result.matched = true;
                    result.position = position + 1;
                }
            }
        } else if (this.type == 'PredefinedCharacterClass') {
            if (position < input.length) {
                var char:String = input.charAt(position);
                var matched:Boolean = false;
                switch (this.value) {
                    case 'd':
                        matched = isDigit(char);
                        break;
                    case 'D':
                        matched = !isDigit(char);
                        break;
                    case 'w':
                        matched = isWordChar(char);
                        break;
                    case 'W':
                        matched = !isWordChar(char);
                        break;
                    case 's':
                        matched = isWhitespace(char);
                        break;
                    case 'S':
                        matched = !isWhitespace(char);
                        break;
                }
                if (matched) {
                    result.matched = true;
                    result.position = position + 1;
                }
            }
        } else if (this.type == 'Quantifier') {
            var count:Number = 0;
            var currentPosition:Number = position;
            var currentCaptures:Array = captures.slice();
            if (this.greedy) {
                // 贪婪匹配
                var positions:Array = [];
                while (count < this.max) {
                    var childResult:Object = this.child.match(input, currentPosition, currentCaptures, ignoreCase);
                    if (childResult.matched) {
                        if (childResult.position == currentPosition) {
                            break; // 防止无限循环
                        }
                        positions.push({ position: currentPosition, captures: currentCaptures.slice() });
                        currentPosition = childResult.position;
                        currentCaptures = childResult.captures.slice();
                        count++;
                    } else {
                        break;
                    }
                }
                // 回溯以满足最小匹配数
                while (count >= this.min) {
                    result.matched = true;
                    result.position = currentPosition;
                    result.captures = currentCaptures.slice();
                    return result;
                }
                // 不匹配
                return { matched: false, position: position, captures: captures.slice() };
            } else {
                // 非贪婪匹配
                if (count >= this.min) {
                    result.matched = true;
                    result.position = currentPosition;
                    result.captures = currentCaptures.slice();
                    return result;
                }
                while (count < this.max) {
                    var childResult:Object = this.child.match(input, currentPosition, currentCaptures, ignoreCase);
                    if (childResult.matched) {
                        if (childResult.position == currentPosition) {
                            break; // 防止无限循环
                        }
                        currentPosition = childResult.position;
                        currentCaptures = childResult.captures.slice();
                        count++;
                        if (count >= this.min) {
                            result.matched = true;
                            result.position = currentPosition;
                            result.captures = currentCaptures.slice();
                            return result;
                        }
                    } else {
                        break;
                    }
                }
                // 不匹配
                return { matched: false, position: position, captures: captures.slice() };
            }
        } else if (this.type == 'Alternation') {
            var leftResult:Object = this.left.match(input, position, captures.slice(), ignoreCase);
            if (leftResult.matched) {
                result = leftResult;
            } else {
                var rightResult:Object = this.right.match(input, position, captures.slice(), ignoreCase);
                if (rightResult.matched) {
                    result = rightResult;
                }
            }
        } else if (this.type == 'Group') {
            var groupResult:Object = this.child.match(input, position, captures.slice(), ignoreCase);
            if (groupResult.matched) {
                result.matched = true;
                result.position = groupResult.position;
                if (this.capturing) {
                    var groupMatch:String = input.substring(position, groupResult.position);
                    result.captures = captures.slice(); // 从父级传递下来的捕获组
                    result.captures.push(groupMatch); // 先添加当前组的匹配结果
                    result.captures = result.captures.concat(groupResult.captures); // 然后合并子节点的捕获组
                } else {
                    result.captures = captures.slice();
                    result.captures = result.captures.concat(groupResult.captures);
                }
            }
        } else if (this.type == 'Anchor') {
            if (this.value == 'start') {
                if (position == 0) {
                    result.matched = true;
                    result.position = position;
                }
            } else if (this.value == 'end') {
                if (position == input.length) {
                    result.matched = true;
                    result.position = position;
                }
            }
        }
        return result;
    }

    // 辅助方法：字符比较，考虑大小写
    private function charEquals(a:String, b:String, ignoreCase:Boolean):Boolean {
        if (ignoreCase) {
            return a.toLowerCase() == b.toLowerCase();
        } else {
            return a == b;
        }
    }

    // 辅助方法：判断是否为数字字符
    private function isDigit(char:String):Boolean {
        var code:Number = char.charCodeAt(0);
        return code >= 48 && code <= 57; // '0' to '9'
    }

    // 辅助方法：判断是否为单词字符
    private function isWordChar(char:String):Boolean {
        var code:Number = char.charCodeAt(0);
        return (code >= 48 && code <= 57) || // '0' to '9'
               (code >= 65 && code <= 90) || // 'A' to 'Z'
               (code >= 97 && code <= 122) || // 'a' to 'z'
               (char == '_');
    }

    // 辅助方法：判断是否为空白字符
    private function isWhitespace(char:String):Boolean {
        return char == ' ' || char == '\t' || char == '\n' || char == '\r' || char == '\f' || char == '\v';
    }
}


/* 

已支持的特性：

**字符匹配：**支持单个字符和字符串的匹配。

字符类：

**自定义字符类：**如 [abc]、[^abc]。
**字符范围：**如 [a-z]、[0-9]。
预定义字符类：

**\d、\D：数字字符和非数字字符。
**\w、\W：单词字符和非单词字符。
**\s、\S：空白字符和非空白字符。
**转义字符：**如 \n、\t、\\ 等。

量词：

贪婪量词：*、+、?、{n}、{n,}、{n,m}。
非贪婪量词：*?、+?、??、{n}?、{n,}?、{n,m}?。
分组和捕获：

捕获分组：( ... )，并支持嵌套分组。
非捕获分组：(?: ... )。
选择（或）操作符：|。

锚点：^（字符串开头）、$（字符串结尾）。

任意字符匹配：.。

标志：

**i：**忽略大小写匹配。
**g：**全局匹配（支持 lastIndex 属性）。
**m：**多行模式（尚未完全实现）。
**错误处理：**对非法量词等语法错误进行解析报错。

尚未支持的特性：

**反向引用：**如 \1、\2 等，在匹配时引用之前的捕获组。

零宽度断言（前瞻和后顾）：

正向前瞻：(?= ...)。
负向前瞻：(?! ...)。
正向后顾：(?<= ...)。
负向后顾：(?<! ...)。
**Unicode 支持：**对 Unicode 字符和字符类的支持。

**复杂的嵌套和递归模式：**如递归匹配嵌套的括号等。

// 测试脚本
import org.flashNight.gesh.regexp.*;
// 创建正则表达式对象
var regex1:RegExp = new RegExp("a*b", "");
trace("测试1：正则表达式 /a*b/ 匹配 'aaab'");
trace(regex1.test("aaab")); // 输出 true

var regex2:RegExp = new RegExp("(abc)+", "");
trace("测试2：正则表达式 /(abc)+/ 匹配 'abcabc'");
trace(regex2.test("abcabc")); // 输出 true

var regex3:RegExp = new RegExp("[a-z]{3}", "");
trace("测试3：正则表达式 /[a-z]{3}/ 匹配 'abc'");
trace(regex3.test("abc")); // 输出 true

var regex4:RegExp = new RegExp("a|b", "");
trace("测试4：正则表达式 /a|b/ 匹配 'a'");
trace(regex4.test("a")); // 输出 true

trace("测试5：正则表达式 /a|b/ 匹配 'b'");
trace(regex4.test("b")); // 输出 true

var regex5:RegExp = new RegExp("a+", "");
trace("测试6：正则表达式 /a+/ 匹配 'aa'");
trace(regex5.test("aa")); // 输出 true

var regex6:RegExp = new RegExp("a+", "");
trace("测试7：正则表达式 /a+/ 匹配 ''");
trace(regex6.test("")); // 输出 false

// 测试 exec() 方法
var regex7:RegExp = new RegExp("(a)(b)(c)", "");
var result:Array = regex7.exec("abc");
if (result != null) {
    trace("测试8：正则表达式 /(a)(b)(c)/ 匹配 'abc'");
    trace("匹配结果：" + result[0]); // 输出 'abc'
    trace("捕获组1：" + result[1]); // 输出 'a'
    trace("捕获组2：" + result[2]); // 输出 'b'
    trace("捕获组3：" + result[3]); // 输出 'c'
} else {
    trace("测试8失败：未匹配");
}

// 测试字符集
var regex8:RegExp = new RegExp("[^a-z]", "");
trace("测试9：正则表达式 /[^a-z]/ 匹配 '1'");
trace(regex8.test("1")); // 输出 true

trace("测试10：正则表达式 /[^a-z]/ 匹配 'a'");
trace(regex8.test("a")); // 输出 false

// 测试11：嵌套分组和量词的组合
var regex11:RegExp = new RegExp("(ab(c|d))*", "");

*/

// trace("测试11：正则表达式 /(ab(c|d))*/ 匹配 'abcdabcdabcc'");

/*
trace(regex11.test("abcdabcdabcc")); // 预期输出 true

// 测试12：量词 {0}
var regex12:RegExp = new RegExp("a{0}", "");
trace("测试12：正则表达式 /a{0}/ 匹配 'abc'");
trace(regex12.test("abc")); // 预期输出 true

// 测试13：量词 {3,1}，n > m 的情况
var regex13:RegExp = new RegExp("a{3,1}", "");
trace("测试13：正则表达式 /a{3,1}/ 匹配 'aaa'");
trace(regex13.test("aaa")); // 预期输出 false 或处理错误

// 测试14：匹配空字符串
var regex14:RegExp = new RegExp("^$", "");
trace("测试14：正则表达式 /^$/ 匹配 ''");
trace(regex14.test("")); // 预期输出 true

// 测试15：量词允许零次匹配
var regex15:RegExp = new RegExp("a*", "");

*/
// trace("测试15：正则表达式 /a*/ 匹配 ''");
/*
trace(regex15.test("")); // 预期输出 true

// 测试16：任意字符匹配
var regex16:RegExp = new RegExp("a.c", "");
trace("测试16：正则表达式 /a.c/ 匹配 'abc'");
trace(regex16.test("abc")); // 预期输出 true

trace("测试17：正则表达式 /a.c/ 匹配 'a c'");
trace(regex16.test("a c")); // 预期输出 true

trace("测试18：正则表达式 /a.c/ 匹配 'abbc'");
trace(regex16.test("abbc")); // 预期输出 false

// 测试19：字符集和量词的组合
var regex19:RegExp = new RegExp("[abc]+", "");
trace("测试19：正则表达式 /[abc]+/ 匹配 'aaabbbcccabc'");
trace(regex19.test("aaabbbcccabc")); // 预期输出 true

// 测试20：否定字符集和量词的组合
var regex20:RegExp = new RegExp("[^abc]+", "");
trace("测试20：正则表达式 /[^abc]+/ 匹配 'defg'");
trace(regex20.test("defg")); // 预期输出 true

// 测试21：多个选择的组合
var regex21:RegExp = new RegExp("a|b|c", "");
trace("测试21：正则表达式 /a|b|c/ 匹配 'b'");
trace(regex21.test("b")); // 预期输出 true

trace("测试22：正则表达式 /a|b|c/ 匹配 'd'");
trace(regex21.test("d")); // 预期输出 false

// 测试23：量词嵌套的情况
var regex23:RegExp = new RegExp("(a+)+", "");
trace("测试23：正则表达式 /(a+)+/ 匹配 'aaa'");
trace(regex23.test("aaa")); // 预期输出 true

// 测试24：无法匹配的情况
var regex24:RegExp = new RegExp("a{4}", "");
trace("测试24：正则表达式 /a{4}/ 匹配 'aaa'");
trace(regex24.test("aaa")); // 预期输出 false

// 测试25：匹配长字符串
var longString:String = "";
for (var i:Number = 0; i < 1000; i++) {
    longString += "a";
}
var regex25:RegExp = new RegExp("a{1000}", "");
trace("测试25：正则表达式 /a{1000}/ 匹配 1000 个 'a'");
trace(regex25.test(longString)); // 预期输出 true

// 测试26：嵌套捕获组
var regex26:RegExp = new RegExp("((a)(b(c)))", "");
var result26:Array = regex26.exec("abc");
if (result26 != null) {
    trace("测试26：正则表达式 /((a)(b(c)))/ 匹配 'abc'");
    trace("匹配结果：" + result26[0]); // 输出 'abc'
    trace("捕获组1：" + result26[1]); // 输出 'abc'
    trace("捕获组2：" + result26[2]); // 输出 'a'
    trace("捕获组3：" + result26[3]); // 输出 'bc'
    trace("捕获组4：" + result26[4]); // 输出 'c'
} else {
    trace("测试26失败：未匹配");
}

// 测试27：预定义字符类 \d
var regex27:RegExp = new RegExp("\\d+", "");
trace("测试27：正则表达式 /\\d+/ 匹配 '12345'");
trace(regex27.test("12345")); // 预期输出 true

// 测试28：预定义字符类 \D
var regex28:RegExp = new RegExp("\\D+", "");
trace("测试28：正则表达式 /\\D+/ 匹配 'abcDEF'");
trace(regex28.test("abcDEF")); // 预期输出 true

// 测试29：预定义字符类 \w
var regex29:RegExp = new RegExp("\\w+", "");
trace("测试29：正则表达式 /\\w+/ 匹配 'hello_world123'");
trace(regex29.test("hello_world123")); // 预期输出 true

// 测试30：预定义字符类 \W
var regex30:RegExp = new RegExp("\\W+", "");
trace("测试30：正则表达式 /\\W+/ 匹配 '!@#'");
trace(regex30.test("!@#")); // 预期输出 true

// 测试31：预定义字符类 \s
var regex31:RegExp = new RegExp("\\s+", "");
trace("测试31：正则表达式 /\\s+/ 匹配 '   '");
trace(regex31.test("   ")); // 预期输出 true

// 测试32：预定义字符类 \S
var regex32:RegExp = new RegExp("\\S+", "");
trace("测试32：正则表达式 /\\S+/ 匹配 'non-space'");
trace(regex32.test("non-space")); // 预期输出 true

// 测试33：转义字符 \n
var regex33:RegExp = new RegExp("hello\\nworld", "");
trace("测试33：正则表达式 /hello\\nworld/ 匹配 'hello\nworld'");
trace(regex33.test("hello\nworld")); // 预期输出 true

// 测试34：忽略大小写匹配
var regex34:RegExp = new RegExp("abc", "i");
trace("测试34：正则表达式 /abc/i 匹配 'AbC'");
trace(regex34.test("AbC")); // 预期输出 true

// 测试35：非贪婪量词
var regex35:RegExp = new RegExp("a+?", "");
trace("测试35：正则表达式 /a+?/ 匹配 'aaa'");
var result35:Array = regex35.exec("aaa");
if (result35 != null) {
    trace("匹配结果：" + result35[0]); // 预期输出 'a'
} else {
    trace("测试35失败：未匹配");
}

// 测试36：非捕获分组
var regex36:RegExp = new RegExp("a(?:bc)+", "");
trace("测试36：正则表达式 /a(?:bc)+/ 匹配 'abcbc'");
var result36:Array = regex36.exec("abcbc");
if (result36 != null) {
    trace("匹配结果：" + result36[0]); // 输出 'abcbc'
    trace("捕获组数：" + (result36.length - 1)); // 预期为0，因为没有捕获组
} else {
    trace("测试36失败：未匹配");
}

// 测试37：嵌套捕获组
var regex37:RegExp = new RegExp("(a(b(c)))", "");
var result37:Array = regex37.exec("abc");
if (result37 != null) {
    trace("测试37：正则表达式 /(a(b(c)))/ 匹配 'abc'");
    trace("匹配结果：" + result37[0]); // 预期输出 'abc'
    trace("捕获组1：" + result37[1]); // 预期输出 'abc'
    trace("捕获组2：" + result37[2]); // 预期输出 'bc'
    trace("捕获组3：" + result37[3]); // 预期输出 'c'
} else {
    trace("测试37失败：未匹配");
}
*/