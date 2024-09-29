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
    private var totalGroups:Number; // 新增属性，记录总捕获组数

    public function RegExp(pattern:String, flags:String) {
        this.pattern = pattern;
        this.flags = flags;
        this.ignoreCase = flags.indexOf('i') >= 0;
        this.global = flags.indexOf('g') >= 0;
        this.multiline = flags.indexOf('m') >= 0;
        this.lastIndex = 0;
        this.parse();
    }

    private function parse():Void {
        try {
            var parser:Parser = new Parser(this.pattern);
            this.ast = parser.parse();
            this.totalGroups = parser.getTotalGroups(); // 获取总捕获组数
        } catch (e:Error) {
            trace("正则表达式解析错误：" + e.message);
            this.ast = null;
            this.totalGroups = 0;
        }
    }

    public function test(input:String):Boolean {
        if (this.ast == null) return false;
        var inputLength:Number = input.length;
        var startPos:Number = 0;
        if (this.pattern.charAt(0) == '^') {
            var captures:Array = initializeCaptures();
            var result:Object = this.ast.match(input, 0, captures, this.ignoreCase);
            return result.matched && result.position <= inputLength;
        } else {
            for (var pos:Number = 0; pos <= inputLength; pos++) {
                var captures:Array = initializeCaptures();
                var result:Object = this.ast.match(input, pos, captures, this.ignoreCase);
                if (result.matched) {
                    return true;
                }
            }
            return false;
        }
    }

    public function exec(input:String):Array {
        if (this.ast == null) return null;
        var inputLength:Number = input.length;
        var lastIndex:Number = this.global ? this.lastIndex : 0;
        for (var pos:Number = lastIndex; pos <= inputLength; pos++) {
            // Initialize captures array with nulls
            var captures:Array = initializeCaptures();
            var result:Object = this.ast.match(input, pos, captures, this.ignoreCase);
            if (result.matched) {
                captures[0] = input.substring(pos, result.position); // Entire match
                captures.index = pos;
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

    // 新增方法：初始化 captures 数组
    private function initializeCaptures():Array {
        var captures:Array = new Array(this.totalGroups + 1);
        for (var i:Number = 0; i <= this.totalGroups; i++) {
            captures[i] = null;
        }
        return captures;
    }
}


// import org.flashNight.gesh.regexp.*;
// // 创建正则表达式对象
// var regex1:RegExp = new RegExp("a*b", "");
// trace("测试1：正则表达式 /a*b/ 匹配 'aaab'");
// trace(regex1.test("aaab")); // 输出 true

// var regex2:RegExp = new RegExp("(abc)+", "");
// trace("测试2：正则表达式 /(abc)+/ 匹配 'abcabc'");
// trace(regex2.test("abcabc")); // 输出 true

// var regex3:RegExp = new RegExp("[a-z]{3}", "");
// trace("测试3：正则表达式 /[a-z]{3}/ 匹配 'abc'");
// trace(regex3.test("abc")); // 输出 true

// var regex4:RegExp = new RegExp("a|b", "");
// trace("测试4：正则表达式 /a|b/ 匹配 'a'");
// trace(regex4.test("a")); // 输出 true

// trace("测试5：正则表达式 /a|b/ 匹配 'b'");
// trace(regex4.test("b")); // 输出 true

// var regex5:RegExp = new RegExp("a+", "");
// trace("测试6：正则表达式 /a+/ 匹配 'aa'");
// trace(regex5.test("aa")); // 输出 true

// var regex6:RegExp = new RegExp("a+", "");
// trace("测试7：正则表达式 /a+/ 匹配 ''");
// trace(regex6.test("")); // 输出 false

// // 测试 exec() 方法
// var regex7:RegExp = new RegExp("(a)(b)(c)", "");
// var result:Array = regex7.exec("abc");
// if (result != null) {
//     trace("测试8：正则表达式 /(a)(b)(c)/ 匹配 'abc'");
//     trace("匹配结果：" + result[0]); // 输出 'abc'
//     trace("捕获组1：" + result[1]); // 输出 'a'
//     trace("捕获组2：" + result[2]); // 输出 'b'
//     trace("捕获组3：" + result[3]); // 输出 'c'
// } else {
//     trace("测试8失败：未匹配");
// }

// // 测试字符集
// var regex8:RegExp = new RegExp("[^a-z]", "");
// trace("测试9：正则表达式 /[^a-z]/ 匹配 '1'");
// trace(regex8.test("1")); // 输出 true

// trace("测试10：正则表达式 /[^a-z]/ 匹配 'a'");
// trace(regex8.test("a")); // 输出 false

// // 测试11：嵌套分组和量词的组合
// var regex11:RegExp = new RegExp("(ab(c|d))*", "");



// // trace("测试11：正则表达式 /(ab(c|d))*/ 匹配 'abcdabcdabcc'");

// trace(regex11.test("abcdabcdabcc")); // 预期输出 true

// // 测试12：量词 {0}
// var regex12:RegExp = new RegExp("a{0}", "");
// trace("测试12：正则表达式 /a{0}/ 匹配 'abc'");
// trace(regex12.test("abc")); // 预期输出 true

// // 测试13：量词 {3,1}，n > m 的情况
// var regex13:RegExp = new RegExp("a{3,1}", "");
// trace("测试13：正则表达式 /a{3,1}/ 匹配 'aaa'");
// trace(regex13.test("aaa")); // 预期输出 false 或处理错误

// // 测试14：匹配空字符串
// var regex14:RegExp = new RegExp("^$", "");
// trace("测试14：正则表达式 /^$/ 匹配 ''");
// trace(regex14.test("")); // 预期输出 true

// // 测试15：量词允许零次匹配
// var regex15:RegExp = new RegExp("a*", "");


// // trace("测试15：正则表达式 /a*/ 匹配 ''");

// trace(regex15.test("")); // 预期输出 true

// // 测试16：任意字符匹配
// var regex16:RegExp = new RegExp("a.c", "");
// trace("测试16：正则表达式 /a.c/ 匹配 'abc'");
// trace(regex16.test("abc")); // 预期输出 true

// trace("测试17：正则表达式 /a.c/ 匹配 'a c'");
// trace(regex16.test("a c")); // 预期输出 true

// trace("测试18：正则表达式 /a.c/ 匹配 'abbc'");
// trace(regex16.test("abbc")); // 预期输出 false

// // 测试19：字符集和量词的组合
// var regex19:RegExp = new RegExp("[abc]+", "");
// trace("测试19：正则表达式 /[abc]+/ 匹配 'aaabbbcccabc'");
// trace(regex19.test("aaabbbcccabc")); // 预期输出 true

// // 测试20：否定字符集和量词的组合
// var regex20:RegExp = new RegExp("[^abc]+", "");
// trace("测试20：正则表达式 /[^abc]+/ 匹配 'defg'");
// trace(regex20.test("defg")); // 预期输出 true

// // 测试21：多个选择的组合
// var regex21:RegExp = new RegExp("a|b|c", "");
// trace("测试21：正则表达式 /a|b|c/ 匹配 'b'");
// trace(regex21.test("b")); // 预期输出 true

// trace("测试22：正则表达式 /a|b|c/ 匹配 'd'");
// trace(regex21.test("d")); // 预期输出 false

// // 测试23：量词嵌套的情况
// var regex23:RegExp = new RegExp("(a+)+", "");
// trace("测试23：正则表达式 /(a+)+/ 匹配 'aaa'");
// trace(regex23.test("aaa")); // 预期输出 true

// // 测试24：无法匹配的情况
// var regex24:RegExp = new RegExp("a{4}", "");
// trace("测试24：正则表达式 /a{4}/ 匹配 'aaa'");
// trace(regex24.test("aaa")); // 预期输出 false

// // 测试25：匹配长字符串
// var longString:String = "";
// for (var i:Number = 0; i < 1000; i++) {
//     longString += "a";
// }
// var regex25:RegExp = new RegExp("a{1000}", "");
// trace("测试25：正则表达式 /a{1000}/ 匹配 1000 个 'a'");
// trace(regex25.test(longString)); // 预期输出 true

// // 测试26：嵌套捕获组
// var regex26:RegExp = new RegExp("((a)(b(c)))", "");
// var result26:Array = regex26.exec("abc");
// if (result26 != null) {
//     trace("测试26：正则表达式 /((a)(b(c)))/ 匹配 'abc'");
//     trace("匹配结果：" + result26[0]); // 输出 'abc'
//     trace("捕获组1：" + result26[1]); // 输出 'abc'
//     trace("捕获组2：" + result26[2]); // 输出 'a'
//     trace("捕获组3：" + result26[3]); // 输出 'bc'
//     trace("捕获组4：" + result26[4]); // 输出 'c'
// } else {
//     trace("测试26失败：未匹配");
// }

// // 测试27：预定义字符类 \d
// var regex27:RegExp = new RegExp("\\d+", "");
// trace("测试27：正则表达式 /\\d+/ 匹配 '12345'");
// trace(regex27.test("12345")); // 预期输出 true

// // 测试28：预定义字符类 \D
// var regex28:RegExp = new RegExp("\\D+", "");
// trace("测试28：正则表达式 /\\D+/ 匹配 'abcDEF'");
// trace(regex28.test("abcDEF")); // 预期输出 true

// // 测试29：预定义字符类 \w
// var regex29:RegExp = new RegExp("\\w+", "");
// trace("测试29：正则表达式 /\\w+/ 匹配 'hello_world123'");
// trace(regex29.test("hello_world123")); // 预期输出 true

// // 测试30：预定义字符类 \W
// var regex30:RegExp = new RegExp("\\W+", "");
// trace("测试30：正则表达式 /\\W+/ 匹配 '!@#'");
// trace(regex30.test("!@#")); // 预期输出 true

// // 测试31：预定义字符类 \s
// var regex31:RegExp = new RegExp("\\s+", "");
// trace("测试31：正则表达式 /\\s+/ 匹配 '   '");
// trace(regex31.test("   ")); // 预期输出 true

// // 测试32：预定义字符类 \S
// var regex32:RegExp = new RegExp("\\S+", "");
// trace("测试32：正则表达式 /\\S+/ 匹配 'non-space'");
// trace(regex32.test("non-space")); // 预期输出 true

// // 测试33：转义字符 \n
// var regex33:RegExp = new RegExp("hello\\nworld", "");
// trace("测试33：正则表达式 /hello\\nworld/ 匹配 'hello\nworld'");
// trace(regex33.test("hello\nworld")); // 预期输出 true

// // 测试34：忽略大小写匹配
// var regex34:RegExp = new RegExp("abc", "i");
// trace("测试34：正则表达式 /abc/i 匹配 'AbC'");
// trace(regex34.test("AbC")); // 预期输出 true

// // 测试35：非贪婪量词
// var regex35:RegExp = new RegExp("a+?", "");
// trace("测试35：正则表达式 /a+?/ 匹配 'aaa'");
// var result35:Array = regex35.exec("aaa");
// if (result35 != null) {
//     trace("匹配结果：" + result35[0]); // 预期输出 'a'
// } else {
//     trace("测试35失败：未匹配");
// }

// // 测试36：非捕获分组
// var regex36:RegExp = new RegExp("a(?:bc)+", "");
// trace("测试36：正则表达式 /a(?:bc)+/ 匹配 'abcbc'");
// var result36:Array = regex36.exec("abcbc");
// if (result36 != null) {
//     trace("匹配结果：" + result36[0]); // 输出 'abcbc'
//     trace("捕获组数：" + (result36.length - 1)); // 预期为0，因为没有捕获组
// } else {
//     trace("测试36失败：未匹配");
// }

// // 测试37：嵌套捕获组
// var regex37:RegExp = new RegExp("(a(b(c)))", "");
// var result37:Array = regex37.exec("abc");
// if (result37 != null) {
//     trace("测试37：正则表达式 /(a(b(c)))/ 匹配 'abc'");
//     trace("匹配结果：" + result37[0]); // 预期输出 'abc'
//     trace("捕获组1：" + result37[1]); // 预期输出 'abc'
//     trace("捕获组2：" + result37[2]); // 预期输出 'bc'
//     trace("捕获组3：" + result37[3]); // 预期输出 'c'
// } else {
//     trace("测试37失败：未匹配");
// }

// // Test38: Backreference with single group
// var regex38:RegExp = new RegExp("(a)\\1", "");
// trace("测试38：正则表达式 /(a)\\1/ 匹配 'aa'");
// trace(regex38.test("aa")); // 预期输出 true

// // Test39: Backreference with multiple groups (should not match)
// var regex39:RegExp = new RegExp("(a)(b)\\1\\2", "");
// trace("测试39：正则表达式 /(a)(b)\\1\\2/ 匹配 'abba'");
// trace(regex39.test("abba")); // 预期输出 false

// // Test40: Backreference with multiple groups (should match)
// var regex40:RegExp = new RegExp("(a)(b)\\2\\1", "");
// trace("测试40：正则表达式 /(a)(b)\\2\\1/ 匹配 'abba'");
// trace(regex40.test("abba")); // 预期输出 true

// // Test41: Backreference with nested groups
// var regex41:RegExp = new RegExp("((a)b)\\1", "");
// trace("测试41：正则表达式 /((a)b)\\1/ 匹配 'abab'");
// trace(regex41.test("abab")); // 预期输出 true

// // Test42: Positive Lookahead (Assuming future support)
// var regex42:RegExp = new RegExp("a(?=b)", "");
// trace("测试42：正则表达式 /a(?=b)/ 匹配 'ab'");
// trace(regex42.test("ab")); // 预期输出 true

// trace("测试42：正则表达式 /a(?=b)/ 匹配 'ac'");
// trace(regex42.test("ac")); // 预期输出 false

// // Test43: Negative Lookahead (Assuming future support)
// var regex43:RegExp = new RegExp("a(?!b)", "");
// trace("测试43：正则表达式 /a(?!b)/ 匹配 'ac'");
// trace(regex43.test("ac")); // 预期输出 true

// trace("测试43：正则表达式 /a(?!b)/ 匹配 'ab'");
// trace(regex43.test("ab")); // 预期输出 false

// // Test44: Positive Lookbehind (Assuming future support)
// var regex44:RegExp = new RegExp("(?<=a)b", "");
// trace("测试44：正则表达式 /(?<=a)b/ 匹配 'ab'");
// trace(regex44.test("ab")); // 预期输出 true

// trace("测试44：正则表达式 /(?<=a)b/ 匹配 'cb'");
// trace(regex44.test("cb")); // 预期输出 false

// // Test45: Negative Lookbehind (Assuming future support)
// var regex45:RegExp = new RegExp("(?<!a)b", "");
// trace("测试45：正则表达式 /(?<!a)b/ 匹配 'cb'");
// trace(regex45.test("cb")); // 预期输出 true

// trace("测试45：正则表达式 /(?<!a)b/ 匹配 'ab'");
// trace(regex45.test("ab")); // 预期输出 false

// // Test46: Named Capturing Group (Assuming future support)
// var regex46:RegExp = new RegExp("(?<first>a)(?<second>b)", "");
// trace("测试46：正则表达式 /(?<first>a)(?<second>b)/ 匹配 'ab'");
// var result46:Array = regex46.exec("ab");
// if (result46 != null) {
//     trace("匹配结果：" + result46[0]); // 输出 'ab'
//     trace("捕获组1(first)：" + result46[1]); // 输出 'a'
//     trace("捕获组2(second)：" + result46[2]); // 输出 'b'
// } else {
//     trace("测试46失败：未匹配");
// }

// // Test47: Start and End Anchors with Multiline Flag
// var regex47:RegExp = new RegExp("^a", "m");
// trace("测试47：正则表达式 /^a/m 匹配 'a\\nb'");
// trace(regex47.test("a\nb")); // 预期输出 true

// var regex48:RegExp = new RegExp("b$", "m");
// trace("测试48：正则表达式 /b$/m 匹配 'a\\nb'");
// trace(regex48.test("a\nb")); // 预期输出 true

// // Test49: Unclosed Group
// try {
//     var regex49:RegExp = new RegExp("(a", "");
//     trace("测试49：正则表达式 /(a/ 匹配 'a'");
//     trace(regex49.test("a")); // 应该抛出错误
// } catch (e:Error) {
//     trace("测试49：捕获到错误 - " + e.message);
// }

// // Test50: Empty Pattern
// var regex50:RegExp = new RegExp("", "");
// trace("测试50：空模式 /''/ 匹配 'abc'");
// trace(regex50.test("abc")); // 预期输出 true

// // Test51: Pattern with Only Quantifiers
// try {
//     var regex51:RegExp = new RegExp("*", "");
//     trace("测试51：正则表达式 /*/ 匹配 'a'");
//     trace(regex51.test("a")); // 应该抛出错误
// } catch (e:Error) {
//     trace("测试51：捕获到错误 - " + e.message);
// }

// // Test52: Matching a Very Long String
// var longString10000:String = "";
// for (var j:Number = 0; j < 10000; j++) {
//     longString10000 += "a";
// }
// var regex52:RegExp = new RegExp("a{10000}", "");
// trace("测试52：正则表达式 /a{10000}/ 匹配 10000 个 'a'");
// trace(regex52.test(longString10000)); // 预期输出 true

// // Test53: Catastrophic Backtracking
// try {
//     var regex53:RegExp = new RegExp("(a+)+b", "");
//     trace("测试53：正则表达式 /(a+)+b/ 匹配 'aaaaa'");
//     trace(regex53.test("aaaaa")); // 应该返回 false without excessive backtracking
// } catch (e:Error) {
//     trace("测试53：捕获到错误 - " + e.message);
// }

// // Test54: Unicode Characters
// var regex54:RegExp = new RegExp("\\u0041", "");
// trace("测试54：正则表达式 /\\u0041/ 匹配 'A'");
// trace(regex54.test("A")); // 预期输出 true

// // Test55: Escaped Special Characters
// var regex55:RegExp = new RegExp("\\.", "");
// trace("测试55：正则表达式 /\\./ 匹配 '.'");
// trace(regex55.test(".")); // 预期输出 true

// trace("测试55：正则表达式 /\\./ 匹配 'a'");
// trace(regex55.test("a")); // 预期输出 false