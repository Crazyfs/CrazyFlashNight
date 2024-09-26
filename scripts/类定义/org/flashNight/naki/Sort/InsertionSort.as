/*

class org.flashNight.naki.Sort.InsertionSort

# InsertionSort 排序类使用指南

## 介绍
`InsertionSort` 类实现了一种高效的插入排序算法，专门用于小规模数据的排序。该实现通过避免递归和函数调用，最大化性能，尤其适合于处理小型数组和几乎有序的数据。

## 方法概述

1. **sort(arr:Array, compareFunction:Function)**:
   - 实现高效的插入排序算法。
   - **使用场景**：
     - 当数据集较小时（如 100 个元素），插入排序通常能提供较快的排序速度。
     - 数据几乎有序时，插入排序能迅速完成排序。
     - 对于实时或增量数据插入场景，插入排序能够高效处理。

## 方法使用示例

```actionscript
import org.flashNight.naki.Sort.InsertionSort;

// 假设我们有一个包含随机数的数组
var arr:Array = [5, 2, 9, 1, 5, 6];

// 调用插入排序
var sortedArray:Array = InsertionSort.sort(arr);

// 输出排序后的数组
trace(sortedArray); // [1, 2, 5, 5, 6, 9]

*/

class org.flashNight.naki.Sort.InsertionSort {

    /**
     * 高效的插入排序实现，专门用于小规模数据的排序。
     * 通过避免递归和函数调用，最大化性能。
     *
     * @param arr 要排序的数组。
     * @param compareFunction 自定义的比较函数，定义排序顺序。
     * @return 排序后的数组。
     */
    public static function sort(arr:Array, compareFunction:Function):Array {
        var length:Number = arr.length;
        if (length <= 1) {
            return arr; // 数组无需排序
        }

        // 默认比较函数
        var compare:Function;
        if (compareFunction != undefined) {
            compare = compareFunction; // 使用自定义比较函数
        } else {
            compare = function(a, b):Number {
                return a - b;
            };
        }

        var i:Number, j:Number, key;
        for (i = 1; i < length; i++) {
            key = arr[i]; // 当前元素
            j = i - 1;

            // 手动内联展开的插入过程
            while (j >= 0 && compare(arr[j], key) > 0) {
                arr[j + 1] = arr[j]; // 移动元素
                j--;
            }
            arr[j + 1] = key; // 插入元素
        }

        return arr; // 返回排序后的数组
    }
}


/*

import org.flashNight.naki.Sort.*;

// 生成测试数据的函数
function generateTestData(size:Number, dataType:String):Array {
    var arr:Array = [];
    var i:Number;

    switch (dataType) {
        case "random":
            for (i = 0; i < size; i++) {
                arr.push(Math.random() * size);
            }
            break;
        case "sorted":
            for (i = 0; i < size; i++) {
                arr.push(i);
            }
            break;
        case "reverse":
            for (i = size - 1; i >= 0; i--) {
                arr.push(i);
            }
            break;
        case "partial":
            for (i = 0; i < size; i++) {
                arr.push(i % 10 == 0 ? Math.random() * size : i);
            }
            break;
        case "duplicates":
            for (i = 0; i < size; i++) {
                arr.push(i % 100);
            }
            break;
        default:
            for (i = 0; i < size; i++) {
                arr.push(Math.random() * size);
            }
            break;
    }

    return arr;
}

// 比较函数
function compareNumbers(a, b):Number {
    return a - b;
}

// 测试函数
// 测试函数
function performTest(size:Number, dataType:String, sortType:String):Void {
    var arr:Array;
    var arrCopy:Array;
    var startTime:Number;
    var endTime:Number;
    var timeBuiltin:Number;
    var timeCustom:Number;

    // 生成测试数据
    arr = generateTestData(size, dataType);
    arrCopy = arr.concat(); // 复制数组用于自定义排序

    var scale:Number = Math.ceil(600000 / size); // Scale factor

    // 测试内置 sort 方法
    if (sortType == "builtin") {
        for (var s:Number = 0; s < scale; s++) {
            startTime = getTimer();
            arr.sort(compareNumbers);
            endTime = getTimer();
        }
        timeBuiltin = (endTime - startTime) / scale;
        trace("Built-in sort time: " + timeBuiltin + " ms");
    }

    // 测试自定义快速排序
    if (sortType == "quicksort") {
        for (var s:Number = 0; s < scale; s++) {
            arrCopy = arr.concat(); // Reset array
            startTime = getTimer();
            QuickSort.sort(arrCopy, compareNumbers);
            endTime = getTimer();
        }
        timeCustom = (endTime - startTime) / scale;
        trace("Custom quicksort time: " + timeCustom + " ms");
    }

    // 测试三向快速排序
    if (sortType == "threeway") {
        for (var s:Number = 0; s < scale; s++) {
            arrCopy = arr.concat(); // Reset array
            startTime = getTimer();
            QuickSort.threeWaySort(arrCopy, compareNumbers);
            endTime = getTimer();
        }
        timeCustom = (endTime - startTime) / scale;
        trace("Three-way quicksort time: " + timeCustom + " ms");
    }

    // 测试自适应快速排序
    if (sortType == "adaptiveSort") {
        for (var s:Number = 0; s < scale; s++) {
            arrCopy = arr.concat(); // Reset array
            startTime = getTimer();
            QuickSort.adaptiveSort(arrCopy, compareNumbers);
            endTime = getTimer();
        }
        timeCustom = (endTime - startTime) / scale;
        trace("Adaptive quicksort time: " + timeCustom + " ms");
    }

    // 测试插入排序
    if (sortType == "insertionSort") {
        for (var s:Number = 0; s < scale; s++) {
            arrCopy = arr.concat(); // Reset array
            startTime = getTimer();
            InsertionSort.sort(arrCopy, compareNumbers);
            endTime = getTimer();
        }
        timeCustom = (endTime - startTime) / scale;
        trace("Insertion sort time: " + timeCustom + " ms");
    }

    // 验证排序结果是否一致
    var isEqual:Boolean = true;
    if (sortType != "builtin") {
        arr.sort(compareNumbers);
        for (var i:Number = 0; i < size; i++) {
            if (arr[i] != arrCopy[i]) {
                isEqual = false;
                break;
            }
        }
        trace("Arrays are equal: " + isEqual);
    }

    trace("-------------------------------");
}

// 测试配置
var testSizes:Array = [100]; // 这里可以根据需要调整大小
var dataTypes:Array = ["duplicates", "sorted", "reverse", "partial", "duplicates"];
var sortMethods:Array = ["builtin", "quicksort", "threeway", "adaptiveSort", "insertionSort"]; // 添加插入排序

// 依次执行测试
for (var i:Number = 0; i < testSizes.length; i++) {
    for (var j:Number = 0; j < dataTypes.length; j++) {
        for (var k:Number = 0; k < sortMethods.length; k++) {
            trace("Data Type: " + dataTypes[j] + ", Size: " + testSizes[i] + ", Sort Method: " + sortMethods[k]);
            performTest(testSizes[i], dataTypes[j], sortMethods[k]);
        }
    }
}


Data Type: duplicates, Size: 100, Sort Method: builtin
Built-in sort time: 0.0005 ms
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: quicksort
Custom quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: threeway
Three-way quicksort time: 0.000333333333333333 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: adaptiveSort
Adaptive quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: insertionSort
Insertion sort time: 0 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: builtin
Built-in sort time: 0.0005 ms
-------------------------------
Data Type: sorted, Size: 100, Sort Method: quicksort
Custom quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: threeway
Three-way quicksort time: 0.000333333333333333 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: adaptiveSort
Adaptive quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: insertionSort
Insertion sort time: 0 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: builtin
Built-in sort time: 0.0005 ms
-------------------------------
Data Type: reverse, Size: 100, Sort Method: quicksort
Custom quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: threeway
Three-way quicksort time: 0.00233333333333333 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: adaptiveSort
Adaptive quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: insertionSort
Insertion sort time: 0.00166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: builtin
Built-in sort time: 0.0005 ms
-------------------------------
Data Type: partial, Size: 100, Sort Method: quicksort
Custom quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: threeway
Three-way quicksort time: 0.000333333333333333 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: adaptiveSort
Adaptive quicksort time: 0.000333333333333333 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: insertionSort
Insertion sort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: builtin
Built-in sort time: 0.0005 ms
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: quicksort
Custom quicksort time: 0 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: threeway
Three-way quicksort time: 0.0005 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: adaptiveSort
Adaptive quicksort time: 0.000166666666666667 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: insertionSort
Insertion sort time: 0 ms
Arrays are equal: true
-------------------------------

*/