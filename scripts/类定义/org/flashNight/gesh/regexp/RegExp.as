import org.flashNight.gesh.regexp.*;

class org.flashNight.gesh.regexp.RegExp 
{

    private var pattern:String;
    private var flags:String;
    private var ast:ASTNode;
    
    public function RegExp(pattern:String, flags:String) {
        this.pattern = pattern;
        this.flags = flags;
        this.parse();
    }
    
    private function parse():Void {
        var parser:Parser = new Parser(this.pattern);
        this.ast = parser.parse();
    }
    
    public function test(input:String):Boolean {
        var inputLength:Number = input.length;
        for (var pos:Number = 0; pos <= inputLength; pos++) {
            var result:Object = this.ast.match(input, pos);
            if (result.matched) {
                return true;
            }
        }
        return false;
    }
    
    public function exec(input:String):Array {
        var inputLength:Number = input.length;
        for (var pos:Number = 0; pos <= inputLength; pos++) {
            var result:Object = this.ast.match(input, pos);
            if (result.matched) {
                var captures:Array = result.captures;
                captures.unshift(input.substring(pos, result.position)); // 将整个匹配添加到数组开头
                captures.index = pos; // 匹配的位置
                captures.input = input;
                return captures;
            }
        }
        return null;
    }
}

