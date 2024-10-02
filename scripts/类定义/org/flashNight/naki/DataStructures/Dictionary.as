class org.flashNight.naki.DataStructures.Dictionary extends Object {
    
    // 构造函数，用于初始化字典对象
    function Dictionary() {
        // 调用父类 Object 的构造函数
        super();
    }

    /**
     * 添加或更新键值对
     * @param key 键（必须是字符串）
     * @param value 与键关联的值（可以是任何类型）
     * 该方法将新键值对添加到字典中，如果键已存在则更新其值
     */
    function setItem(key:String, value):Void {
        this[key] = value;
    }

    /**
     * 获取指定键的值
     * @param key 要查找的键
     * @return 如果键存在，返回其对应的值；如果键不存在，返回 null
     */
    function getItem(key:String) {
        if (this.hasOwnProperty(key)) {
            return this[key];
        }
        return null; // 键不存在时返回 null
    }

    /**
     * 删除指定的键值对
     * @param key 要删除的键
     * 该方法将从字典中移除指定的键值对
     */
    function removeItem(key:String):Void {
        if (this.hasOwnProperty(key)) {
            delete this[key];
        }
    }

    /**
     * 检查字典中是否包含指定的键
     * @param key 要检查的键
     * @return 如果键存在，返回 true；否则返回 false
     */
    function hasKey(key:String):Boolean {
        return this.hasOwnProperty(key);
    }

    /**
     * 获取字典中所有的键
     * @return 包含所有键的数组
     * 
     * 测试结果表明，返回的键的顺序并不一定与插入顺序相同，AS2 中 Object 的键存储是无序的。
     */
    function getKeys():Array {
        var keys:Array = [];
        for (var key in this) {
            keys.push(key); // 将所有键存入数组
        }
        return keys;
    }

    /**
     * 清空字典
     * 该方法会移除字典中的所有键值对
     */
    function clear():Void {
        for (var key in this) {
            delete this[key]; // 删除每一个键值对
        }
    }

    /**
     * 获取字典中键值对的数量
     * @return 返回字典中的键值对数量
     * 
     * 测试结果表明，`getCount()` 能够正确返回字典中的键值对数量。
     */
    function getCount():Number {
        var count:Number = 0;
        for (var key in this) {
            count++; // 通过遍历计算键值对数量
        }
        return count;
    }

    /**
     * 遍历所有键值对，并对每个键值对执行回调函数
     * @param callback 需要执行的回调函数，格式为 function(key:String, value)
     * 
     * 测试中，`forEach()` 能够正确遍历字典中的每一个键值对，并执行回调函数。
     */
    function forEach(callback:Function):Void {
        for (var key in this) {
            callback(key, this[key]); // 对每个键值对执行回调函数
        }
    }
}
