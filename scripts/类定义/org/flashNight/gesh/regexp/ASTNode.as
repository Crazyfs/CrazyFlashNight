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
    }
    
    public function match(input:String, position:Number):Object {
        var result:Object = { matched: false, position: position, captures: [] };
        if (this.type == 'Literal') {
            if (position < input.length && input.charAt(position) == this.value) {
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
            var captures:Array = [];
            for (var i:Number = 0; i < this.children.length; i++) {
                var childResult:Object = this.children[i].match(input, currentPosition);
                if (!childResult.matched) {
                    return { matched: false, position: position };
                }
                currentPosition = childResult.position;
                captures = captures.concat(childResult.captures);
            }
            result.matched = true;
            result.position = currentPosition;
            result.captures = captures;
        } else if (this.type == 'CharacterClass') {
            if (position < input.length) {
                var char:String = input.charAt(position);
                var inSet:Boolean = this.value.indexOf(char) >= 0;
                if (this.negated) {
                    inSet = !inSet;
                }
                if (inSet) {
                    result.matched = true;
                    result.position = position + 1;
                }
            }
        } else if (this.type == 'Quantifier') {
            var count:Number = 0;
            var currentPosition:Number = position;
            var captures:Array = [];
            while (count < this.max) {
                var childResult:Object = this.child.match(input, currentPosition);
                if (childResult.matched) {
                    if (childResult.position == currentPosition) {
                        // 防止无限循环（例如匹配空字符串的情况）
                        break;
                    }
                    currentPosition = childResult.position;
                    captures = captures.concat(childResult.captures);
                    count++;
                } else {
                    break;
                }
            }
            if (count >= this.min) {
                result.matched = true;
                result.position = currentPosition;
                result.captures = captures;
            }
        } else if (this.type == 'Alternation') {
            var leftResult:Object = this.left.match(input, position);
            if (leftResult.matched) {
                result = leftResult;
            } else {
                var rightResult:Object = this.right.match(input, position);
                if (rightResult.matched) {
                    result = rightResult;
                }
            }
        } else if (this.type == 'Group') {
            var groupResult:Object = this.child.match(input, position);
            if (groupResult.matched) {
                result.matched = true;
                result.position = groupResult.position;
                if (this.capturing) {
                    result.captures = [input.substring(position, groupResult.position)].concat(groupResult.captures);
                } else {
                    result.captures = groupResult.captures;
                }
            }
        }
        return result;
    }
}
