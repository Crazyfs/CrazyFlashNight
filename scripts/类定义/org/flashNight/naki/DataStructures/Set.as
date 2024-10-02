class org.flashNight.naki.DataStructures.Set {
    
    // 用于存储集合元素的对象
    private var items:Object;
    
    /**
     * 构造函数，初始化 Set
     */
    public function Set() {
        this.items = {};
    }
    
    /**
     * 添加元素到集合中
     * @param value 要添加的元素
     * @return 如果元素成功添加（不存在重复），返回 true；否则返回 false
     */
    public function add(value:Object):Boolean {
        if (!this.has(value)) {
            this.items[value] = true;
            return true;
        }
        return false;
    }
    
    /**
     * 从集合中移除元素
     * @param value 要移除的元素
     * @return 如果元素成功移除，返回 true；否则返回 false
     */
    public function remove(value:Object):Boolean {
        if (this.has(value)) {
            delete this.items[value];
            return true;
        }
        return false;
    }
    
    /**
     * 检查元素是否存在于集合中
     * @param value 要检查的元素
     * @return 如果元素存在，返回 true；否则返回 false
     */
    public function has(value:Object):Boolean {
        var key:String = String(value); // 将 value 强制转换为字符串
        return this.items.hasOwnProperty(key);
    }

    
    /**
     * 获取集合中所有的元素
     * @return 包含所有元素的数组
     */
    public function values():Array {
        var result:Array = [];
        for (var key:String in this.items) {
            result.push(key);
        }
        return result;
    }
    
    /**
     * 清空集合
     */
    public function clear():Void {
        this.items = {};
    }
    
    /**
     * 获取集合的大小
     * @return 集合中的元素数量
     */
    public function size():Number {
        var count:Number = 0;
        for (var key:String in this.items) {
            count++;
        }
        return count;
    }
    
    /**
     * 检查集合是否为空
     * @return 如果集合为空，返回 true；否则返回 false
     */
    public function isEmpty():Boolean {
        return this.size() == 0;
    }
}
