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
        var currentChar:String = input.charAt(0);
        
        for (var i:Number = 1; i < input.length; i++) {
            var char:String = input.charAt(i);
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
            var char:String = input.charAt(i);
            i++;
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
        
        trace("RLE 解压缩完成。压缩前长度: " + decompressed.length + ", 压缩后长度: " + input.length);
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
}
