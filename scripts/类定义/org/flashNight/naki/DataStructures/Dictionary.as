/*
### **字典类（Dictionary）实现说明 - README**

#### **简介**
`org.flashNight.naki.DataStructures.Dictionary` 类是一个通用的键值对存储容器，允许使用字符串、对象或函数作为键来存储对应的值。该类提供了高效的键值存储、检索、删除等操作，同时支持遍历字典中的所有键值对。与传统的键值存储方式不同，`Dictionary` 类能够处理复杂的数据结构，例如对象和函数作为键。

---

### **主要功能**

1. **支持多种类型的键**：
   - 可以使用字符串、对象和函数作为键，存储对应的值。
   - 对于对象和函数，`Dictionary` 使用唯一标识符（UID）来跟踪它们，确保每个对象和函数都能唯一识别。

2. **键值对管理**：
   - **添加或更新键值对**：通过 `setItem` 方法，可以向字典中添加或更新键值对。
   - **获取键对应的值**：通过 `getItem` 方法，可以根据键查找并返回对应的值。
   - **删除键值对**：通过 `removeItem` 方法，可以从字典中删除指定的键值对。
   - **检查键是否存在**：通过 `hasKey` 方法，可以检查字典中是否存在指定的键。

3. **性能优化**：
   - 提供键缓存机制，通过 `keysCache` 缓存键列表，避免频繁遍历存储对象。
   - **键值对遍历**：通过 `forEach` 方法，可以遍历字典中的所有键值对，并对每个键值对执行回调操作。

4. **高级功能**：
   - **获取键列表**：通过 `getKeys` 方法，可以返回所有键的数组（包括字符串键、对象键和函数键）。
   - **获取字典大小**：通过 `getCount` 方法，可以获取字典中键值对的数量。
   - **清空字典**：通过 `clear` 方法，可以清空字典中的所有数据。
   - **销毁字典**：通过 `destroy` 方法，可以清理所有引用，防止内存泄漏。

---

### **API 说明**

#### **1. 构造函数**
```actionscript
public function Dictionary()
```
- **功能**：创建一个新的字典实例，初始化存储结构。

#### **2. setItem**
```actionscript
public function setItem(key, value):Void
```
- **功能**：将键值对添加到字典中，支持字符串、对象和函数作为键。如果键已存在，则更新其对应的值。
- **参数**：
  - `key`：要存储的键，可以是字符串、对象或函数。
  - `value`：与键关联的值。

#### **3. getItem**
```actionscript
public function getItem(key)
```
- **功能**：获取指定键的值。
- **参数**：
  - `key`：要查找的键，可以是字符串、对象或函数。
- **返回值**：键对应的值，如果键不存在则返回 `null`。

#### **4. removeItem**
```actionscript
public function removeItem(key):Void
```
- **功能**：从字典中删除指定的键值对。
- **参数**：
  - `key`：要删除的键，可以是字符串、对象或函数。

#### **5. hasKey**
```actionscript
public function hasKey(key):Boolean
```
- **功能**：检查字典中是否包含指定的键。
- **参数**：
  - `key`：要检查的键，可以是字符串、对象或函数。
- **返回值**：如果键存在，返回 `true`；否则返回 `false`。

#### **6. getKeys**
```actionscript
public function getKeys():Array
```
- **功能**：获取字典中所有键的数组，包括字符串键、对象键和函数键。
- **返回值**：包含所有键的数组。

#### **7. clear**
```actionscript
public function clear():Void
```
- **功能**：清空字典，删除所有键值对。

#### **8. getCount**
```actionscript
public function getCount():Number
```
- **功能**：获取字典中键值对的数量。
- **返回值**：当前字典中的键值对数量。

#### **9. forEach**
```actionscript
public function forEach(callback:Function):Void
```
- **功能**：遍历字典中的所有键值对，并对每个键值对执行回调函数。
- **参数**：
  - `callback`：回调函数，格式为 `function(key, value)`，会对每个键值对执行该函数。

#### **10. destroy**
```actionscript
public function destroy():Void
```
- **功能**：销毁字典，清理所有引用，防止内存泄漏。

---

### **使用示例**

```actionscript
// 创建一个新的字典实例
var dict:Dictionary = new Dictionary();

// 添加字符串键
dict.setItem("name", "Alice");

// 添加对象键
var obj:Object = { id: 1 };
dict.setItem(obj, "对象一");

// 添加函数键
function greet():Void {
    trace("Hello!");
}
dict.setItem(greet, "问候函数");

// 获取值
trace(dict.getItem("name"));     // 输出: Alice
trace(dict.getItem(obj));        // 输出: 对象一
trace(dict.getItem(greet));      // 输出: 问候函数

// 检查键是否存在
trace(dict.hasKey("name"));      // 输出: true
trace(dict.hasKey("unknown"));   // 输出: false

// 获取所有键
var keys:Array = dict.getKeys();
for (var i:Number = 0; i < keys.length; i++) {
    trace(keys[i]);
}

// 删除键
dict.removeItem("name");

// 获取键值对数量
trace(dict.getCount());         // 输出当前的键值对数量

// 清空字典
dict.clear();
trace(dict.getCount());         // 输出: 0
```

---

### **注意事项**

1. **对象键和函数键的处理**：在使用对象和函数作为键时，字典会为每个对象和函数生成唯一标识符（UID），并通过该 UID 来存储和查找值。这确保了即使两个对象具有相同的内容，它们仍然能够作为独立的键来处理。

2. **性能**：字典类实现了缓存机制（`keysCache`），可以加速键列表的获取。但在大量增删操作后，可能需要重新计算键缓存。

3. **内存管理**：使用 `destroy` 方法来销毁字典并清理所有引用，以防止内存泄漏，特别是在不再使用该字典时。

---

*/


class org.flashNight.naki.DataStructures.Dictionary extends Object {

    private var stringStorage:Object;    // 用于存储字符串键的对象
    private var objectStorage:Object;    // 用于存储对象和函数键的对象
    private static var uidCounter:Number = 1; // 用于生成对象和函数键的唯一标识符（UID）
    private static var uidMap:Object = {}; // 用于映射对象和函数键的 UID 到原始对象
    private var count:Number = 0;         // 存储当前字典中的键值对数量

    // 缓存键列表及其状态
    private var keysCache:Array = null;  // 用于缓存所有键的数组
    private var isKeysCacheDirty:Boolean = true; // 标记缓存的键列表是否需要更新

    /**
     * 构造函数，初始化字典对象
     */
    public function Dictionary() {
        super();
        stringStorage = {};  // 初始化字符串键存储对象
        objectStorage = {};  // 初始化对象/函数键存储对象
    }

    /**
     * 添加或更新键值对
     * @param key 键（可以是字符串、对象或函数）
     * @param value 与键关联的值
     */
    public function setItem(key, value):Void {
        var keyType:String = typeof key;
        
        if (keyType == "string") {
            // 检查该字符串键是否不存在，若不存在则计数+1并标记缓存键列表为脏
            if (typeof(stringStorage[key]) == "undefined") {
                count++;
                isKeysCacheDirty = true;
            }
            stringStorage[key] = value;  // 为字符串键设置对应的值
        } else {
            // 处理对象或函数键
            var uid:Number = key.__dictUID;
            if (uid === undefined) {
                // 如果该对象没有 UID，则分配新的 UID 并存储在 uidMap 中
                uid = key.__dictUID = uidCounter++;
                uidMap[uid] = key;
                count++;
                isKeysCacheDirty = true;
            }
            var uidStr:String = String(uid);  // 将 UID 转换为字符串作为键
            if (typeof(objectStorage[uidStr]) == "undefined") {
                count++;
                isKeysCacheDirty = true;
            }
            objectStorage[uidStr] = value;  // 为对象/函数键设置对应的值
        }
    }

    /**
     * 获取指定键的值
     * @param key 键（可以是字符串、对象或函数）
     * @return 返回与该键关联的值，如果键不存在则返回 null
     */
    public function getItem(key) {
        var keyType:String = typeof key;
        
        if (keyType == "string") {
            var val = stringStorage[key];  // 从字符串存储中查找值
            return (val !== undefined) ? val : null;
        } else {
            var uid:Number = key.__dictUID;
            if (uid === undefined) return null;  // 如果该对象没有 UID，直接返回 null
            var uidStr:String = String(uid);
            var val = objectStorage[uidStr];  // 从对象存储中查找值
            return (val !== undefined) ? val : null;
        }
    }

    /**
     * 删除指定的键值对
     * @param key 键（可以是字符串、对象或函数）
     */
    public function removeItem(key):Void {
        var keyType:String = typeof key;
        
        if (keyType == "string") {
            // 如果字符串键存在，则删除并更新计数和缓存状态
            if (typeof(stringStorage[key]) != "undefined") {
                delete stringStorage[key];
                count--;
                isKeysCacheDirty = true;
            }
        } else {
            // 如果是对象或函数键，删除关联的 UID 和存储对象
            var uid:Number = key.__dictUID;
            if (uid !== undefined) {
                var uidStr:String = String(uid);
                if (typeof(objectStorage[uidStr]) != "undefined") {
                    delete objectStorage[uidStr];
                    delete uidMap[uid];  // 删除 UID 映射
                    delete key.__dictUID;  // 删除对象上的 UID 属性
                    count--;
                    isKeysCacheDirty = true;
                }
            }
        }
    }

    /**
     * 检查字典中是否包含指定的键
     * @param key 键（可以是字符串、对象或函数）
     * @return 如果键存在，返回 true；否则返回 false
     */
    public function hasKey(key):Boolean {
        var keyType:String = typeof key;
        
        if (keyType == "string") {
            return (typeof(stringStorage[key]) != "undefined");
        } else {
            var uid:Number = key.__dictUID;
            if (uid === undefined) return false;  // 对象或函数没有 UID 则返回 false
            var uidStr:String = String(uid);
            return (typeof(objectStorage[uidStr]) != "undefined");
        }
    }

    /**
     * 获取字典中所有的键
     * @return 返回包含所有键的数组（字符串键、对象键、函数键）
     */
    public function getKeys():Array {
        if (isKeysCacheDirty || keysCache === null) {
            keysCache = [];
            
            // 遍历存储字符串键的对象
            for (var key:String in stringStorage) {
                keysCache.push(key);
            }
            
            // 遍历存储对象/函数键的对象，并通过 UID 获取原始键
            for (var uidStr:String in objectStorage) {
                var originalKey = uidMap[Number(uidStr)];
                keysCache.push(originalKey);
            }
            
            isKeysCacheDirty = false;  // 键列表缓存更新完毕，标记为干净
        }
        
        return keysCache.concat();  // 返回键列表的副本，避免外部修改
    }

    /**
     * 清空字典
     * 移除所有的键值对，并清理相关的引用
     */
    public function clear():Void {
        // 清空字符串存储
        stringStorage = {};
        
        // 清空对象存储和 UID 映射
        for (var uidStr:String in objectStorage) {
            var key = uidMap[Number(uidStr)];
            if (key !== undefined) {
                delete key.__dictUID;  // 删除对象上的 UID 属性
            }
            delete objectStorage[uidStr];
            delete uidMap[Number(uidStr)];
        }
        
        uidCounter = 1;  // 重置 UID 计数器
        count = 0;       // 重置键值对数量
        isKeysCacheDirty = true;  // 标记键缓存为脏
        keysCache = null;         // 清空键缓存
    }

    /**
     * 获取字典中键值对的数量
     * @return 返回字典中的键值对数量
     */
    public function getCount():Number {
        return count;
    }

    /**
     * 遍历所有键值对，并对每个键值对执行回调函数
     * @param callback 回调函数，格式为 function(key, value)
     */
    public function forEach(callback:Function):Void {
        if (isKeysCacheDirty || keysCache === null) {
            getKeys();  // 确保键列表是最新的
        }
        var len:Number = keysCache.length;
        for (var i:Number = 0; i < len; i++) {
            var key = keysCache[i];
            var value = getItem(key);  // 获取键对应的值
            callback(key, value);  // 执行回调函数
        }
    }

    /**
     * 销毁字典
     * 清理所有的引用，防止内存泄漏
     */
    public function destroy():Void {
        clear();  // 清空字典内容
        stringStorage = null;  // 清理字符串存储对象
        objectStorage = null;  // 清理对象存储对象
        uidMap = null;         // 清理 UID 映射对象
        keysCache = null;      // 清理键缓存
    }
}


// import org.flashNight.naki.DataStructures.Dictionary;

// /**
//  * 优化后的基准测试工具函数
//  * @param name 测试名称
//  * @param testFunction 测试的具体操作
//  * @param iterations 迭代次数
//  */
// function benchmark(name:String, testFunction:Function, iterations:Number):Void {
//     var startTime:Number = getTimer();
    
//     // 执行测试函数
//     testFunction();

//     var endTime:Number = getTimer();
//     var elapsedTime:Number = endTime - startTime;
    
//     trace(name + " 耗时: " + elapsedTime + " 毫秒, 迭代次数: " + iterations);
// }

// /**
//  * 随机字符串生成
//  * 批量生成随机字符串，减少重复生成操作
//  * @param length 字符串长度
//  * @param count 批量生成的数量
//  * @return 字符串数组
//  */
// function generateRandomStrings(length:Number, count:Number):Array {
//     var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
//     var randomStrings:Array = [];
//     for (var i:Number = 0; i < count; i++) {
//         var result:String = "";
//         for (var j:Number = 0; j < length; j++) {
//             result += chars.charAt(Math.floor(Math.random() * chars.length));
//         }
//         randomStrings.push(result);
//     }
//     return randomStrings;
// }

// /**
//  * 自定义 Dictionary 测试
//  * 批量生成随机键值对，减少循环内部的生成开销
//  * @param iterations 迭代次数
//  */
// function testCustomDictionary(iterations:Number):Void {
//     var dict:Dictionary = new Dictionary();
//     var randomKeys:Array = generateRandomStrings(5, iterations);

//     // 批量插入操作
//     for (var i:Number = 0; i < iterations; i++) {
//         dict.setItem(randomKeys[i], i);
//     }

//     // 批量检索操作
//     for (var i:Number = 0; i < iterations; i++) {
//         dict.getItem(randomKeys[i]);
//     }

//     // 批量删除操作
//     for (var i:Number = 0; i < iterations; i++) {
//         dict.removeItem(randomKeys[i]);
//     }
// }

// /**
//  * 原生 Object 测试
//  * 批量生成随机键值对，减少循环内部的生成开销
//  * @param iterations 迭代次数
//  */
// function testNativeObject(iterations:Number):Void {
//     var obj:Object = {};
//     var randomKeys:Array = generateRandomStrings(5, iterations);

//     // 批量插入操作
//     for (var i:Number = 0; i < iterations; i++) {
//         obj[randomKeys[i]] = i;
//     }

//     // 批量检索操作
//     for (var i:Number = 0; i < iterations; i++) {
//         var value = obj[randomKeys[i]];
//     }

//     // 批量删除操作
//     for (var i:Number = 0; i < iterations; i++) {
//         delete obj[randomKeys[i]];
//     }
// }

// /**
//  * 正确性验证测试
//  */
// function correctnessTest():Void {
//     // 创建一个字典实例
//     var dict:Dictionary = new Dictionary();

//     // 使用字符串键
//     dict.setItem("name", "Alice");
//     trace("name: " + dict.getItem("name")); // 输出: Alice

//     // 使用对象键
//     var obj1:Object = { id: 1 };
//     var obj2:Object = { id: 2 };
//     dict.setItem(obj1, "对象一");
//     dict.setItem(obj2, "对象二");
//     trace("obj1: " + dict.getItem(obj1)); // 输出: 对象一
//     trace("obj2: " + dict.getItem(obj2)); // 输出: 对象二

//     // 使用函数键
//     function greet():Void {
//         trace("Hello!");
//     }
//     function farewell():Void {
//         trace("Goodbye!");
//     }
//     dict.setItem(greet, "问候函数");
//     dict.setItem(farewell, "告别函数");
//     trace("greet: " + dict.getItem(greet)); // 输出: 问候函数
//     trace("farewell: " + dict.getItem(farewell)); // 输出: 告别函数

//     // 检查键是否存在
//     trace("Has 'name': " + dict.hasKey("name")); // 输出: true
//     trace("Has obj1: " + dict.hasKey(obj1));    // 输出: true
//     trace("Has greet: " + dict.hasKey(greet));   // 输出: true
//     trace("Has 'unknown': " + dict.hasKey("unknown")); // 输出: false

//     // 获取所有键，格式化输出
//     var allKeys:Array = dict.getKeys();
//     for (var i:Number = 0; i < allKeys.length; i++) {
//         var key = allKeys[i];
//         var keyString:String;
        
//         // 检查键的类型，选择适当的输出
//         if (typeof key == "function") {
//             keyString = "[Function: anonymous]";
//         } else if (typeof key == "object") {
//             keyString = "[Object: " + (key.id != undefined ? "id=" + key.id : key.toString()) + "]";
//         } else {
//             keyString = key;
//         }
        
//         trace("键: " + keyString + " 值: " + dict.getItem(key));
//     }

//     // 使用 forEach 遍历所有键值对，格式化输出
//     dict.forEach(function(key, value):Void {
//         var keyString:String;
        
//         // 检查键的类型，选择适当的输出
//         if (typeof key == "function") {
//             keyString = "[Function: anonymous]";
//         } else if (typeof key == "object") {
//             keyString = "[Object: " + (key.id != undefined ? "id=" + key.id : key.toString()) + "]";
//         } else {
//             keyString = key;
//         }
        
//         trace("键: " + keyString + " 值: " + value);
//     });

//     // 删除一个键
//     dict.removeItem("name");
//     trace("Has 'name' after removal: " + dict.hasKey("name")); // 输出: false

//     // 获取键值对数量
//     trace("Item count: " + dict.getCount()); // 根据当前存储情况输出数量

//     // 清空字典
//     dict.clear();
//     trace("Item count after clear: " + dict.getCount()); // 输出: 0

//     // 销毁字典实例
//     dict.destroy();
// }

// /**
//  * 性能测试入口
//  */
// function runPerformanceTests():Void {
//     var iterations:Number = 100000;  // 设定迭代次数

//     benchmark("自定义 Dictionary 测试", function() {
//         testCustomDictionary(iterations);
//     }, iterations);

//     benchmark("原生 Object 测试", function() {
//         testNativeObject(iterations);
//     }, iterations);
// }

// // 运行正确性测试
// correctnessTest();

// // 运行性能测试
// runPerformanceTests();




/*

name: Alice
obj1: 对象一
obj2: 对象二
greet: 问候函数
farewell: 告别函数
Has 'name': true
Has obj1: true
Has greet: true
Has 'unknown': false
键: name 值: Alice
键: [Function: anonymous] 值: 告别函数
键: [Function: anonymous] 值: 问候函数
键: [Object: id=2] 值: 对象二
键: [Object: id=1] 值: 对象一
键: name 值: Alice
键: [Function: anonymous] 值: 告别函数
键: [Function: anonymous] 值: 问候函数
键: [Object: id=2] 值: 对象二
键: [Object: id=1] 值: 对象一
Has 'name' after removal: false
Item count: 8
Item count after clear: 0
自定义 Dictionary 测试 耗时: 2283 毫秒, 迭代次数: 100000
原生 Object 测试 耗时: 1822 毫秒, 迭代次数: 100000

*/
