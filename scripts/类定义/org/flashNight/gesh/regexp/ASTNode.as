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
                result.captures = groupResult.captures.slice(); // 先获取子节点的捕获组
                if (this.capturing) {
                    var groupMatch:String = input.substring(position, groupResult.position);
                    result.captures.push(groupMatch); // 将当前组的匹配结果添加到捕获组的末尾
                }
            }
        } else if (this.type == 'BackReference') {
            var groupNumber:Number = Number(this.value);
            if (captures.length >= groupNumber && captures[groupNumber - 1] != undefined) {
                var groupContent:String = captures[groupNumber - 1];
                var endPosition:Number = position + groupContent.length;
                var matchedStr:String = input.substring(position, endPosition);
                if (endPosition <= input.length && charEquals(matchedStr, groupContent, ignoreCase)) {
                    result.matched = true;
                    result.position = endPosition;
                }
            } else {
                // 捕获组不存在或未捕获内容，匹配失败
                result.matched = false;
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


