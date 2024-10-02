class org.flashNight.naki.DataStructures.ArrayStack {
    
    // 用于存储栈元素的数组
    private var items:Array;
    
    /**
     * 构造函数，初始化栈
     */
    public function ArrayStack() {
        this.items = [];
    }
    
    /**
     * 入栈操作，将元素压入栈顶
     * @param value 要压入栈的元素
     */
    public function push(value:Object):Void {
        this.items.push(value);
    }
    
    /**
     * 出栈操作，移除并返回栈顶元素
     * @return 栈顶元素，如果栈为空则返回 null
     */
    public function pop():Object {
        if (this.isEmpty()) {
            return null; // 栈为空
        }
        return this.items.pop(); // 移除并返回数组末尾的元素
    }
    
    /**
     * 查看栈顶的元素但不移除
     * @return 栈顶的元素，如果栈为空则返回 null
     */
    public function peek():Object {
        if (this.isEmpty()) {
            return null; // 栈为空
        }
        return this.items[this.items.length - 1]; // 返回数组末尾的元素
    }
    
    /**
     * 检查栈是否为空
     * @return 如果栈为空，返回 true；否则返回 false
     */
    public function isEmpty():Boolean {
        return this.items.length == 0;
    }
    
    /**
     * 获取栈的大小
     * @return 栈中的元素数量
     */
    public function getSize():Number {
        return this.items.length;
    }
    
    /**
     * 清空栈
     */
    public function clear():Void {
        this.items = [];
    }
}
