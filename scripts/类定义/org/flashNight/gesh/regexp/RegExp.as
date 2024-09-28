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
