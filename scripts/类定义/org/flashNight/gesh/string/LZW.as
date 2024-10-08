/**
 * LZW 压缩和解压缩类（支持16进制编码）
 * 
 * @version 2.1
 * @author fs
 */
class org.flashNight.gesh.string.LZW {
    
    private static var MAX_DICT_SIZE:Number = 4096; // 最大字典大小
    private static var HEX_DIGITS:Number = 4; // 每个编码的十六进制位数

    /**
     * 压缩字符串
     * 
     * @param input 要压缩的字符串
     * @return 压缩后的十六进制编码字符串
     */
    public static function compress(input:String):String {
        if (input == null || input.length == 0) {
            return "";
        }

        // 将输入字符串转换为 UTF-8 字节数组
        var data:Array = stringToUTF8Bytes(input);
        var byteString:String = bytesToString(data); // 每个字节作为一个字符

        var dict:Object = {};
        var output:Array = [];
        var phrase:String = byteString.charAt(0);
        var code:Number = 256; // 初始编码，从256开始，因为0-255为单字符编码

        // 初始化字典，添加所有单字节字符
        for (var i:Number = 0; i < 256; i++) {
            dict[String.fromCharCode(i)] = i;
        }

        for (var j:Number = 1; j < byteString.length; j++) {
            var currentChar:String = byteString.charAt(j);
            var combined:String = phrase + currentChar;
            if (dict[combined] != undefined) {
                phrase = combined;
            } else {
                output.push(dict[phrase]);
                if (code < MAX_DICT_SIZE) {
                    dict[combined] = code;
                    code++;
                }
                phrase = currentChar;
            }
        }

        // 输出最后一个字串
        output.push(dict[phrase]);

        // 将编码数组转换为固定长度的16进制字符串
        var hexOutput:String = "";
        for (var k:Number = 0; k < output.length; k++) {
            hexOutput += padHex(output[k].toString(16));
        }

        return hexOutput;
    }

    /**
     * 解压缩十六进制编码字符串
     * 
     * @param compressed 压缩后的十六进制编码字符串
     * @return 解压后的原始字符串
     */
    public static function decompress(compressed:String):String {
        if (compressed == null || compressed.length == 0) {
            return "";
        }

        var dict:Object = {};
        var data:Array = splitHexString(compressed);
        var currentCode:Number = parseInt(data[0], 16);
        var currentPhrase:String = codeToString(currentCode);
        var result:String = currentPhrase;
        var oldPhrase:String = currentPhrase;
        var code:Number = 256; // 初始编码，从256开始

        // 初始化字典，添加所有单字节字符
        for (var i:Number = 0; i < 256; i++) {
            dict[i] = String.fromCharCode(i);
        }

        for (var j:Number = 1; j < data.length; j++) {
            currentCode = parseInt(data[j], 16);
            var phrase:String;

            if (dict[currentCode] != undefined) {
                phrase = dict[currentCode];
            } else {
                // 特殊情况：当前编码不存在于字典中
                phrase = oldPhrase + oldPhrase.charAt(0);
            }

            result += phrase;

            // 添加新字串到字典
            if (code < MAX_DICT_SIZE) {
                dict[code] = oldPhrase + phrase.charAt(0);
                code++;
            }

            oldPhrase = phrase;
        }

        // 将字节字符串转换回 UTF-8 字符串
        var decompressedBytes:Array = bytesFromString(result);
        return utf8BytesToString(decompressedBytes);
    }

    /**
     * 将编码数字转换为字符串（仅限0-255）
     * @param code 编码数字
     * @return 字符串
     */
    private static function codeToString(code:Number):String {
        if (code >= 0 && code < 256) {
            return String.fromCharCode(code);
        } else {
            // 对于大于等于256的编码，初始dict中未定义，返回空字符串
            return "";
        }
    }

    /**
     * 将编码字符串拆分为固定长度的16进制数组
     * 
     * @param hexStr 压缩后的16进制字符串
     * @return 编码数组
     */
    private static function splitHexString(hexStr:String):Array {
        var data:Array = [];
        for (var i:Number = 0; i < hexStr.length; i += HEX_DIGITS) {
            var hexCode:String = hexStr.substr(i, HEX_DIGITS);
            if (hexCode.length < HEX_DIGITS) {
                // 填充不足的部分
                hexCode = padHex(hexCode);
            }
            data.push(hexCode);
        }
        return data;
    }

    /**
     * 将编码数字转换为固定长度的16进制字符串
     * 
     * @param hexStr 当前编码的16进制字符串
     * @return 补齐后的16进制字符串
     */
    private static function padHex(hexStr:String):String {
        while (hexStr.length < HEX_DIGITS) {
            hexStr = "0" + hexStr;
        }
        return hexStr.toUpperCase();
    }

    /**
     * 将字节数组转换为字符串，每个字节对应一个字符
     * @param bytes 字节数组
     * @return 字符串
     */
    private static function bytesToString(bytes:Array):String {
        var str:String = "";
        for (var i:Number = 0; i < bytes.length; i++) {
            str += String.fromCharCode(bytes[i]);
        }
        return str;
    }

    /**
     * 将字符串转换为字节数组，每个字符代表一个字节
     * @param str 字符串
     * @return 字节数组
     */
    private static function bytesFromString(str:String):Array {
        var bytes:Array = [];
        for (var i:Number = 0; i < str.length; i++) {
            bytes.push(str.charCodeAt(i));
        }
        return bytes;
    }

    /**
     * 将字符串转换为 UTF-8 字节数组
     * @param str 要转换的字符串
     * @return UTF-8 字节数组
     */
    private static function stringToUTF8Bytes(str:String):Array {
        var bytes:Array = [];
        var i:Number = 0;
        while (i < str.length) {
            var c:Number = str.charCodeAt(i++);
            // 检查是否是高代理项
            if (c >= 0xD800 && c <= 0xDBFF && i < str.length) {
                var c2:Number = str.charCodeAt(i++);
                if (c2 >= 0xDC00 && c2 <= 0xDFFF) {
                    // 组合高低代理项
                    var codePoint:Number = ((c - 0xD800) << 10) + (c2 - 0xDC00) + 0x10000;
                    // 编码为4字节UTF-8
                    bytes.push(0xF0 | ((codePoint >> 18) & 0x07));
                    bytes.push(0x80 | ((codePoint >> 12) & 0x3F));
                    bytes.push(0x80 | ((codePoint >> 6) & 0x3F));
                    bytes.push(0x80 | (codePoint & 0x3F));
                } else {
                    throw new Error("Invalid surrogate pair in string.");
                }
            } else if (c < 0x80) {
                bytes.push(c);  // 1字节的UTF-8字符
            } else if (c < 0x800) {
                bytes.push(0xC0 | (c >> 6));  // 2字节的UTF-8字符
                bytes.push(0x80 | (c & 0x3F));
            } else {
                bytes.push(0xE0 | (c >> 12));  // 3字节的UTF-8字符
                bytes.push(0x80 | ((c >> 6) & 0x3F));
                bytes.push(0x80 | (c & 0x3F));
            }
        }
        return bytes;
    }

    /**
     * 将 UTF-8 字节数组转换回字符串
     * @param bytes UTF-8 字节数组
     * @return 解码后的字符串
     */
    private static function utf8BytesToString(bytes:Array):String {
        var str:String = "";
        var i:Number = 0;
        while (i < bytes.length) {
            var c:Number = bytes[i++];
            if (c < 0x80) {
                str += String.fromCharCode(c);
            }
            else if ((c & 0xE0) == 0xC0) {
                var c2:Number = bytes[i++];
                if ((c2 & 0xC0) != 0x80) {
                    throw new Error("Invalid UTF-8 encoding.");
                }
                var charCode:Number = ((c & 0x1F) << 6) | (c2 & 0x3F);
                str += String.fromCharCode(charCode);
            }
            else if ((c & 0xF0) == 0xE0) {
                var c2a:Number = bytes[i++];
                var c3:Number = bytes[i++];
                if (((c2a & 0xC0) != 0x80) || ((c3 & 0xC0) != 0x80)) {
                    throw new Error("Invalid UTF-8 encoding.");
                }
                var charCode2:Number = ((c & 0x0F) << 12) | ((c2a & 0x3F) << 6) | (c3 & 0x3F);
                str += String.fromCharCode(charCode2);
            }
            else if ((c & 0xF8) == 0xF0) {
                var c2b:Number = bytes[i++];
                var c3a:Number = bytes[i++];
                var c4:Number = bytes[i++];
                if (((c2b & 0xC0) != 0x80) || ((c3a & 0xC0) != 0x80) || ((c4 & 0xC0) != 0x80)) {
                    throw new Error("Invalid UTF-8 encoding.");
                }
                var codePoint:Number = ((c & 0x07) << 18) | ((c2b & 0x3F) << 12) | ((c3a & 0x3F) << 6) | (c4 & 0x3F);
                // 转换为代理对
                var highSurrogate:Number = Math.floor((codePoint - 0x10000) / 0x400) + 0xD800;
                var lowSurrogate:Number = ((codePoint - 0x10000) % 0x400) + 0xDC00;
                str += String.fromCharCode(highSurrogate) + String.fromCharCode(lowSurrogate);
            }
            else {
                throw new Error("Invalid UTF-8 encoding.");
            }
        }
        return str;
    }
}


/*

// 测试脚本：RLETest.as

import org.flashNight.naki.DataStructures.*;
import org.flashNight.gesh.string.*;

// 测试 LZW 压缩和解压缩
var testStr:String = "TOBEORNOTTOBEORTOBEORNOT";
trace("===== 开始测试 LZW 编码和解码 =====");
trace("测试字符串: " + testStr);

// 开始编码
var compressed:String = org.flashNight.gesh.string.LZW.compress(testStr);
trace("编码后的十六进制字符串: " + compressed);

// 开始解码
var decompressed:String = org.flashNight.gesh.string.LZW.decompress(compressed);
trace("解码后的字符串: " + decompressed);

// 检查是否匹配
var match:Boolean = (testStr == decompressed);
trace("编码后解码是否匹配: " + match);
trace("===== 测试完成 =====");

*/