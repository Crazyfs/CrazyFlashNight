import org.flashNight.naki.DataStructures.*;
import org.flashNight.gesh.string.*;

class org.flashNight.gesh.string.RLE {

    /**
     * 压缩字符串使用 Run-Length Encoding (RLE)
     * 
     * @param input 要压缩的字符串
     * @return 压缩后的字符串
     */
    public static function compress(input:String):String {
        if (input == null || input.length == 0) {
            return "";
        }

        var compressed:String = "";
        var count:Number = 1;
        var currentChar:String = getNextChar(input, 0); // 获取第一个字符

        for (var i:Number = currentChar.length; i < input.length; i += currentChar.length) {
            var char:String = getNextChar(input, i); // 获取下一个完整字符
            if (char == currentChar) {
                count++;
            } else {
                compressed += currentChar + count;
                currentChar = char;
                count = 1;
            }
        }

        // 添加最后一组字符
        compressed += currentChar + count;

        trace("RLE 压缩完成。原长度: " + input.length + ", 压缩后长度: " + compressed.length);
        return compressed;
    }

    /**
     * 解压缩字符串使用 Run-Length Encoding (RLE)
     * 
     * @param input 要解压的字符串
     * @return 解压后的字符串
     */
    public static function decompress(input:String):String {
        if (input == null || input.length == 0) {
            return "";
        }

        var decompressed:String = "";
        var i:Number = 0;

        while (i < input.length) {
            var char:String = getNextChar(input, i); // 读取字符
            i += char.length;

            var countStr:String = "";
            // 读取数字部分
            while (i < input.length && isDigit(input.charAt(i))) {
                countStr += input.charAt(i);
                i++;
            }

            var count:Number = Number(countStr);
            if (isNaN(count)) {
                trace("RLE 解压缩错误: 无效的计数 '" + countStr + "'");
                return undefined;
            }

            for (var j:Number = 0; j < count; j++) {
                decompressed += char;
            }
        }

        trace("RLE 解压缩完成。解压后长度: " + decompressed.length);
        return decompressed;
    }

    /**
     * 判断一个字符是否是数字
     * 
     * @param char 要判断的字符
     * @return Boolean 是否是数字
     */
    private static function isDigit(char:String):Boolean {
        var code:Number = char.charCodeAt(0);
        return (code >= 48 && code <= 57); // '0'到'9'
    }

    /**
     * 获取下一个字符，处理单字节和双字节字符
     * @param input 输入字符串
     * @param index 当前索引
     * @return 完整字符
     */
    private static function getNextChar(input:String, index:Number):String {
        var charCode:Number = input.charCodeAt(index);
        // 检测是否是高代理项
        if (charCode >= 0xD800 && charCode <= 0xDBFF && index + 1 < input.length) {
            var nextCharCode:Number = input.charCodeAt(index + 1);
            // 如果下一个是低代理项，返回组合字符
            if (nextCharCode >= 0xDC00 && nextCharCode <= 0xDFFF) {
                return input.substr(index, 2); // 返回两个字符的组合
            }
        }
        return input.charAt(index); // 单字符
    }
}


/*


import org.flashNight.gesh.string.*;

trace("===== 测试 RLE 编码和解码 =====");

var testStr1:String = "aaabbbcc";
var compressed1:String = RLE.compress(testStr1);
var decompressed1:String = RLE.decompress(compressed1);
trace("Test 1 - 原始字符串: " + testStr1);
trace("Test 1 - 压缩后的字符串: " + compressed1);
trace("Test 1 - 解压后的字符串: " + decompressed1);
trace("Test 1 - 是否匹配: " + (testStr1 == decompressed1));

var testStr2:String = "hello 🌍 world";
var compressed2:String = RLE.compress(testStr2);
var decompressed2:String = RLE.decompress(compressed2);
trace("Test 2 - 原始字符串: " + testStr2);
trace("Test 2 - 压缩后的字符串: " + compressed2);
trace("Test 2 - 解压后的字符串: " + decompressed2);
trace("Test 2 - 是否匹配: " + (testStr2 == decompressed2));

// 边界测试：空字符串
var testStr3:String = "";
var compressed3:String = RLE.compress(testStr3);
var decompressed3:String = RLE.decompress(compressed3);
trace("Test 3 - 空字符串测试");
trace("Test 3 - 压缩后的字符串: " + compressed3);
trace("Test 3 - 解压后的字符串: " + decompressed3);
trace("Test 3 - 是否匹配: " + (testStr3 == decompressed3));

trace("===== 测试完成 =====");

trace("===== 所有测试完成 =====");
*/