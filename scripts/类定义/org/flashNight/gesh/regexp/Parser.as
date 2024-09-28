import org.flashNight.gesh.regexp.ASTNode;

class org.flashNight.gesh.regexp.Parser {
    private var pattern:String;
    private var index:Number;
    private var length:Number;
    
    public function Parser(pattern:String) {
        this.pattern = pattern;
        this.index = 0;
        this.length = pattern.length;
    }
    
    public function parse():ASTNode {
        return this.parseExpression();
    }
    
    private function parseExpression():ASTNode {
        var term:ASTNode = this.parseSequence();
        while (this.index < this.length && this.peek() == '|') {
            this.consume(); // 跳过 '|'
            var rightTerm:ASTNode = this.parseSequence();
            var alternationNode:ASTNode = new ASTNode('Alternation');
            alternationNode.left = term;
            alternationNode.right = rightTerm;
            term = alternationNode;
        }
        return term;
    }
    
    private function parseSequence():ASTNode {
        var nodes:Array = [];
        while (this.index < this.length && this.peek() != ')' && this.peek() != '|') {
            var node:ASTNode = this.parseTerm();
            if (node != null) {
                nodes.push(node);
            }
        }
        if (nodes.length == 1) {
            return nodes[0];
        } else {
            var sequenceNode:ASTNode = new ASTNode('Sequence');
            sequenceNode.children = nodes;
            return sequenceNode;
        }
    }
    
    private function parseTerm():ASTNode {
        var node:ASTNode = null;
        var char:String = this.peek();
        
        if (char == '^') {
            this.consume();
            node = new ASTNode('Anchor');
            node.value = 'start';
            node = this.parseQuantifier(node);
        } else if (char == '$') {
            this.consume();
            node = new ASTNode('Anchor');
            node.value = 'end';
            node = this.parseQuantifier(node);
        } else if (char == '(') {
            node = this.parseGroup();
        } else if (char == '[') {
            node = this.parseCharacterClass();
            node = this.parseQuantifier(node);
        } else if (char == '.') {
            this.consume();
            node = new ASTNode('Any');
            node = this.parseQuantifier(node);
        } else if (char == '\\') {
            this.consume();
            var escapedChar:String = this.consume();
            node = new ASTNode('Literal');
            node.value = escapedChar;
            node = this.parseQuantifier(node);
        } else {
            // 字面量字符
            node = new ASTNode('Literal');
            node.value = this.consume();
            node = this.parseQuantifier(node);
        }
        return node;
    }
    
    private function parseGroup():ASTNode {
        this.consume(); // 跳过 '('
        var node:ASTNode = new ASTNode('Group');
        node.capturing = true; // 简化处理，假设所有分组都是捕获分组
        node.child = this.parseExpression();
        this.consume(); // 跳过 ')'
        node = this.parseQuantifier(node);
        return node;
    }
    
    private function parseCharacterClass():ASTNode {
        var node:ASTNode = new ASTNode('CharacterClass');
        this.consume(); // 跳过 '['
        if (this.peek() == '^') {
            node.negated = true;
            this.consume(); // 跳过 '^'
        }
        var chars:Array = [];
        while (this.index < this.length && this.peek() != ']') {
            var char:String = this.consume();
            if (char == '\\') {
                char = this.consume(); // 获取转义字符
            }
            if (char == '-' && chars.length > 0 && this.peek() != ']') {
                var startChar:String = String(chars.pop());
                var endChar:String = this.consume();
                var startCode:Number = startChar.charCodeAt(0);
                var endCode:Number = endChar.charCodeAt(0);
                for (var code:Number = startCode; code <= endCode; code++) {
                    chars.push(String.fromCharCode(code));
                }
            } else {
                chars.push(char);
            }
        }
        this.consume(); // 跳过 ']'
        node.value = chars;
        return node;
    }
    
    private function parseQuantifier(node:ASTNode):ASTNode {
        if (this.index >= this.length) {
            return node;
        }
        var char:String = this.peek();
        if (char == '*' || char == '+' || char == '?' || char == '{') {
            var quantNode:ASTNode = new ASTNode('Quantifier');
            quantNode.child = node;
            if (char == '*') {
                quantNode.min = 0;
                quantNode.max = Number.MAX_VALUE;
                this.consume();
            } else if (char == '+') {
                quantNode.min = 1;
                quantNode.max = Number.MAX_VALUE;
                this.consume();
            } else if (char == '?') {
                quantNode.min = 0;
                quantNode.max = 1;
                this.consume();
            } else if (char == '{') {
                this.consume(); // 跳过 '{'
                var numbers:String = "";
                while (this.index < this.length && this.peek() != '}') {
                    numbers += this.consume();
                }
                this.consume(); // 跳过 '}'
                var parts:Array = numbers.split(',');
                quantNode.min = parseInt(parts[0]);
                if (parts.length == 1) {
                    quantNode.max = quantNode.min;
                } else if (parts[1] == "") {
                    quantNode.max = Number.MAX_VALUE;
                } else {
                    quantNode.max = parseInt(parts[1]);
                }
                // 添加检查
                if (quantNode.min > quantNode.max) {
                    throw new Error("Invalid quantifier: {" + quantNode.min + "," + quantNode.max + "}");
                }
            }
            return quantNode;
        } else {
            return node;
        }
    }

    
    private function consume():String {
        return this.pattern.charAt(this.index++);
    }
    
    private function peek():String {
        return this.pattern.charAt(this.index);
    }
}
