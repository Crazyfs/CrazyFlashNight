import org.flashNight.gesh.regexp.*;

class org.flashNight.gesh.regexp.RegExp 
{
    private var pattern:String;
    private var flags:String;
    private var ast:ASTNode;
    private var ignoreCase:Boolean;
    private var global:Boolean;
    private var multiline:Boolean;
    public var lastIndex:Number = 0; // 新增属性

    public function RegExp(pattern:String, flags:String) {
        this.pattern = pattern;
        this.flags = flags;
        this.ignoreCase = flags.indexOf('i') >= 0;
        this.global = flags.indexOf('g') >= 0;
        this.multiline = flags.indexOf('m') >= 0;
        this.parse();
    }

    private function parse():Void {
        try {
            var parser:Parser = new Parser(this.pattern);
            this.ast = parser.parse();
        } catch (e:Error) {
            trace("正则表达式解析错误：" + e.message);
            this.ast = null;
        }
    }

    public function test(input:String):Boolean {
        var inputLength:Number = input.length;
        var startPos:Number = 0;
        if (this.pattern.charAt(0) == '^') {
            var result:Object = this.ast.match(input, 0, [], this.ignoreCase);
            return result.matched && result.position <= inputLength;
        } else {
            for (var pos:Number = 0; pos <= inputLength; pos++) {
                var result:Object = this.ast.match(input, pos, [], this.ignoreCase);
                if (result.matched) {
                    return true;
                }
            }
            return false;
        }
    }

    public function exec(input:String):Array {
        var inputLength:Number = input.length;
        var lastIndex:Number = 0;
        if (this.global) {
            lastIndex = this.lastIndex;
        }
        for (var pos:Number = lastIndex; pos <= inputLength; pos++) {
            var result:Object = this.ast.match(input, pos, [], this.ignoreCase);
            if (result.matched) {
                var captures:Array = result.captures;
                captures.unshift(input.substring(pos, result.position)); // 将整个匹配添加到数组开头
                captures.index = pos; // 匹配的位置
                captures.input = input;
                if (this.global) {
                    this.lastIndex = result.position;
                }
                return captures;
            }
        }
        if (this.global) {
            this.lastIndex = 0;
        }
        return null;
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