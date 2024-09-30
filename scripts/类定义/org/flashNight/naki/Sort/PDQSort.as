class org.flashNight.naki.Sort.PDQSort {

    /**
     * PDQSort 的主排序方法
     * 
     * @param arr 要排序的数组
     * @param compareFunction 自定义比较函数
     * @return 排序后的数组
     */
    public static function sort(arr:Array, compareFunction:Function):Array {
        var length:Number = arr.length;
    
        // 长度为 0 或 1 的数组直接返回，不需要继续进行其他操作
        if (length <= 1) {
            return arr;
        } else if (length > 512) {
            var sampleSize:Number = 512; // 检查前 512 个元素
            var uniqueCount:Number = 0;
            var uniqueMap:Object = {};
            
            // 内联重复度检测逻辑
            for (var i:Number = 0; i < sampleSize; i++) {
                var elem = arr[i];
                if (uniqueMap[elem] == undefined) {
                    uniqueMap[elem] = true;
                    uniqueCount++;
                }
            }
            
            var duplicateRatio:Number = 1 - (uniqueCount / sampleSize); // 计算重复比例
            // 如果重复度超过 80%，直接使用内建排序
            if (duplicateRatio >= 0.8) {
                arr.sort(compareFunction); // 使用内建排序函数
                return arr;
            }
        }

        // 设置比较函数，默认使用数值比较
        var defaultCompare:Boolean = false;
        var compare:Function;
        if (compareFunction != undefined) {
            compare = compareFunction; // 使用自定义比较函数
        } else {
            defaultCompare = true; // 默认数值比较
            compare = function(a, b):Number {
                return a - b;
            };
        }

        // 使用栈模拟递归，避免递归调用带来的栈深度问题
        var stack:Array = new Array(2 * length);
        var sp:Number = 0;

        var left:Number = 0;
        var right:Number = length - 1;

        // 初始左右边界入栈
        stack[sp++] = left;
        stack[sp++] = right;

        // 最大允许的递归深度，基于内省排序策略
        var maxDepth:Number = Math.floor(2 * Math.log(length));

        // 重复检测阈值
        var repetitiveCheckThreshold:Number = 50;  // 固定阈值，简化逻辑
        var operationCount:Number = 0;  // 分区操作计数

        if (defaultCompare) {
            // 使用默认数值比较的优化路径
            while (sp > 0) {
                right = Number(stack[--sp]);
                left = Number(stack[--sp]);

                // 使用插入排序处理小数组
                if (right - left <= 10) {
                    for (var i:Number = left + 1; i <= right; i++) {
                        var key:Number = arr[i];
                        var j:Number = i - 1;
                        while (j >= left && arr[j] > key) {
                            arr[j + 1] = arr[j];
                            j--;
                        }
                        arr[j + 1] = key;
                    }
                    continue;
                }

                operationCount++;

                // 每threshold次操作进行一次重复检测
                if (operationCount % repetitiveCheckThreshold == 0) {
                    var sampleSize:Number = Math.min(512, right - left + 1);
                    var uniqueCount:Number = 0;
                    var uniqueMap:Object = {};

                    for (var k:Number = left; k < left + sampleSize && k <= right; k++) {
                        var elem:Number = arr[k];
                        if (uniqueMap[elem] == undefined) {
                            uniqueMap[elem] = true;
                            uniqueCount++;
                        }
                    }

                    var duplicateRatio:Number = 1 - (uniqueCount / sampleSize);
                    if (duplicateRatio > 0.9) { // 如果重复率超过90%，则切换到内建排序
                        arr.sort(compareFunction);
                        sp = 0; // 清空栈，因为数组已经排序
                        break;
                    }
                }

                // 模式检测：如果数组已接近有序，使用插入排序
                var orderedCount:Number = 0;
                for (var m:Number = left + 1; m <= right; m++) {
                    if (arr[m] >= arr[m - 1]) {
                        orderedCount++;
                    }
                }
                if (orderedCount > (right - left) * 0.9) {
                    for (var n:Number = left + 1; n <= right; n++) {
                        var keyVal:Number = arr[n];
                        var p:Number = n - 1;
                        while (p >= left && arr[p] > keyVal) {
                            arr[p + 1] = arr[p];
                            p--;
                        }
                        arr[p + 1] = keyVal;
                    }
                    continue;
                }

                // 内省排序策略，深度超出阈值时，切换到堆排序
                if (maxDepth-- <= 0) {
                    // 堆排序实现（循环版堆化）
                    // 构建最大堆
                    for (var heapI:Number = Math.floor((right - left) / 2) + left; heapI >= left; heapI--) {
                        var heapLargest:Number = heapI;
                        var heapLeftChild:Number = 2 * (heapI - left) + 1 + left;
                        var heapRightChild:Number = 2 * (heapI - left) + 2 + left;

                        if (heapLeftChild <= right && arr[heapLeftChild] > arr[heapLargest]) {
                            heapLargest = heapLeftChild;
                        }

                        if (heapRightChild <= right && arr[heapRightChild] > arr[heapLargest]) {
                            heapLargest = heapRightChild;
                        }

                        if (heapLargest != heapI) {
                            // 交换
                            var heapTemp:Number = arr[heapI];
                            arr[heapI] = arr[heapLargest];
                            arr[heapLargest] = heapTemp;

                            // 循环堆化
                            var current:Number = heapLargest;
                            while (true) {
                                var currentLargest:Number = current;
                                var currentLeft:Number = 2 * (current - left) + 1 + left;
                                var currentRight:Number = 2 * (current - left) + 2 + left;

                                if (currentLeft <= right && arr[currentLeft] > arr[currentLargest]) {
                                    currentLargest = currentLeft;
                                }

                                if (currentRight <= right && arr[currentRight] > arr[currentLargest]) {
                                    currentLargest = currentRight;
                                }

                                if (currentLargest != current) {
                                    // 交换
                                    var currentTemp:Number = arr[current];
                                    arr[current] = arr[currentLargest];
                                    arr[currentLargest] = currentTemp;
                                    current = currentLargest;
                                } else {
                                    break;
                                }
                            }
                        }
                    }

                    // 提取元素并调整堆
                    for (var heapJ:Number = right; heapJ > left; heapJ--) {
                        // 交换最大元素到末尾
                        var heapSwapTemp:Number = arr[left];
                        arr[left] = arr[heapJ];
                        arr[heapJ] = heapSwapTemp;

                        // 循环堆化
                        var heapK:Number = left;
                        while (true) {
                            var heapLChild:Number = 2 * (heapK - left) + 1 + left;
                            var heapRChild:Number = 2 * (heapK - left) + 2 + left;
                            var heapMax:Number = heapK;

                            if (heapLChild <= heapJ - 1 && arr[heapLChild] > arr[heapMax]) {
                                heapMax = heapLChild;
                            }

                            if (heapRChild <= heapJ - 1 && arr[heapRChild] > arr[heapMax]) {
                                heapMax = heapRChild;
                            }

                            if (heapMax != heapK) {
                                // 交换
                                var heapNewTemp:Number = arr[heapK];
                                arr[heapK] = arr[heapMax];
                                arr[heapMax] = heapNewTemp;
                                heapK = heapMax;
                            } else {
                                break;
                            }
                        }
                    }
                    continue;
                }

                // 三路分区实现内联
                // 使用三点取中法选择 pivot
                var mid:Number = left + Math.floor((right - left) / 2);
                // Median of Three
                if (arr[left] > arr[mid]) {
                    var tempMedian:Number = arr[left];
                    arr[left] = arr[mid];
                    arr[mid] = tempMedian;
                }
                if (arr[left] > arr[right]) {
                    var tempMedian2:Number = arr[left];
                    arr[left] = arr[right];
                    arr[right] = tempMedian2;
                }
                if (arr[mid] > arr[right]) {
                    var tempMedian3:Number = arr[mid];
                    arr[mid] = arr[right];
                    arr[right] = tempMedian3;
                }
                // Now, arr[left] <= arr[mid] <= arr[right]
                var pivotIndex:Number = mid;
                var pivotValue:Number = arr[pivotIndex];

                // 将 pivot 移动到起始位置
                var pivotTemp:Number = arr[left];
                arr[left] = arr[pivotIndex];
                arr[pivotIndex] = pivotTemp;

                var lessIndex:Number = left + 1; // 初始化为 left +1
                var greatIndex:Number = right;
                var iLoop:Number = left + 1;

                while (iLoop <= greatIndex) {
                    var cmp:Number = arr[iLoop] - pivotValue;
                    if (cmp < 0) {
                        // 交换 arr[iLoop] 和 arr[lessIndex]
                        var swapTemp:Number = arr[iLoop];
                        arr[iLoop] = arr[lessIndex];
                        arr[lessIndex] = swapTemp;
                        lessIndex++;
                        iLoop++;
                    } else if (cmp > 0) {
                        // 交换 arr[iLoop] 和 arr[greatIndex]
                        var swapTemp2:Number = arr[iLoop];
                        arr[iLoop] = arr[greatIndex];
                        arr[greatIndex] = swapTemp2;
                        greatIndex--;
                    } else {
                        iLoop++;
                    }
                }

                // 将 pivot 移动到其正确的位置 lessIndex -1
                var finalPivotTemp:Number = arr[left];
                arr[left] = arr[lessIndex - 1];
                arr[lessIndex - 1] = finalPivotTemp;

                // 计算子数组大小
                var leftSubarraySize:Number = lessIndex - 1 - left;
                var rightSubarraySize:Number = right - greatIndex;

                // 优先处理较小的子数组，减少栈深度
                if (leftSubarraySize < rightSubarraySize) {
                    if (left < lessIndex - 1) {
                        stack[sp++] = left;
                        stack[sp++] = lessIndex - 2;
                    }
                    if (greatIndex + 1 < right) {
                        stack[sp++] = greatIndex + 1;
                        stack[sp++] = right;
                    }
                } else {
                    if (greatIndex + 1 < right) {
                        stack[sp++] = greatIndex + 1;
                        stack[sp++] = right;
                    }
                    if (left < lessIndex - 1) {
                        stack[sp++] = left;
                        stack[sp++] = lessIndex - 2;
                    }
                }
            }
        } else {
            // 使用自定义比较函数的优化路径
            while (sp > 0) {
                right = Number(stack[--sp]);
                left = Number(stack[--sp]);

                // 使用插入排序处理小数组
                if (right - left <= 10) {
                    for (var iC:Number = left + 1; iC <= right; iC++) {
                        var keyC = arr[iC];
                        var jC:Number = iC - 1;
                        while (jC >= left && compare(arr[jC], keyC) > 0) {
                            arr[jC + 1] = arr[jC];
                            jC--;
                        }
                        arr[jC + 1] = keyC;
                    }
                    continue;
                }

                operationCount++;

                // 每threshold次操作进行一次重复检测
                if (operationCount % repetitiveCheckThreshold == 0) {
                    var sampleSizeC:Number = Math.min(512, right - left + 1);
                    var uniqueCountC:Number = 0;
                    var uniqueMapC:Object = {};

                    for (var kC:Number = left; kC < left + sampleSizeC && kC <= right; kC++) {
                        var elemC = arr[kC];
                        if (uniqueMapC[elemC] == undefined) {
                            uniqueMapC[elemC] = true;
                            uniqueCountC++;
                        }
                    }

                    var duplicateRatioC:Number = 1 - (uniqueCountC / sampleSizeC);
                    if (duplicateRatioC > 0.9) { // 如果重复率超过90%，则切换到内建排序
                        arr.sort(compareFunction);
                        sp = 0; // 清空栈，因为数组已经排序
                        break;
                    }
                }

                // 模式检测：如果数组已接近有序，使用插入排序
                var orderedCountC:Number = 0;
                for (var mC:Number = left + 1; mC <= right; mC++) {
                    if (compare(arr[mC], arr[mC - 1]) >= 0) {
                        orderedCountC++;
                    }
                }
                if (orderedCountC > (right - left) * 0.9) {
                    for (var nC:Number = left + 1; nC <= right; nC++) {
                        var keyValC = arr[nC];
                        var pC:Number = nC - 1;
                        while (pC >= left && compare(arr[pC], keyValC) > 0) {
                            arr[pC + 1] = arr[pC];
                            pC--;
                        }
                        arr[pC + 1] = keyValC;
                    }
                    continue;
                }

                // 内省排序策略，深度超出阈值时，切换到堆排序
                if (maxDepth-- <= 0) {
                    // 堆排序实现（循环版堆化）
                    // 构建最大堆
                    for (var heapI_C:Number = Math.floor((right - left) / 2) + left; heapI_C >= left; heapI_C--) {
                        var heapLargestC:Number = heapI_C;
                        var heapLeftChildC:Number = 2 * (heapI_C - left) + 1 + left;
                        var heapRightChildC:Number = 2 * (heapI_C - left) + 2 + left;

                        if (heapLeftChildC <= right && compare(arr[heapLeftChildC], arr[heapLargestC]) > 0) {
                            heapLargestC = heapLeftChildC;
                        }

                        if (heapRightChildC <= right && compare(arr[heapRightChildC], arr[heapLargestC]) > 0) {
                            heapLargestC = heapRightChildC;
                        }

                        if (heapLargestC != heapI_C) {
                            // 交换
                            var heapTempC:Number = arr[heapI_C];
                            arr[heapI_C] = arr[heapLargestC];
                            arr[heapLargestC] = heapTempC;

                            // 循环堆化
                            var currentC:Number = heapLargestC;
                            while (true) {
                                var currentLargestC:Number = currentC;
                                var currentLeftC:Number = 2 * (currentC - left) + 1 + left;
                                var currentRightC:Number = 2 * (currentC - left) + 2 + left;

                                if (currentLeftC <= right && compare(arr[currentLeftC], arr[currentLargestC]) > 0) {
                                    currentLargestC = currentLeftC;
                                }

                                if (currentRightC <= right && compare(arr[currentRightC], arr[currentLargestC]) > 0) {
                                    currentLargestC = currentRightC;
                                }

                                if (currentLargestC != currentC) {
                                    // 交换
                                    var currentTempC:Number = arr[currentC];
                                    arr[currentC] = arr[currentLargestC];
                                    arr[currentLargestC] = currentTempC;
                                    currentC = currentLargestC;
                                } else {
                                    break;
                                }
                            }
                        }
                    }

                    // 提取元素并调整堆
                    for (var heapJ_C:Number = right; heapJ_C > left; heapJ_C--) {
                        // 交换最大元素到末尾
                        var heapSwapTempC:Number = arr[left];
                        arr[left] = arr[heapJ_C];
                        arr[heapJ_C] = heapSwapTempC;

                        // 循环堆化
                        var heapK_C:Number = left;
                        while (true) {
                            var heapLChildC:Number = 2 * (heapK_C - left) + 1 + left;
                            var heapRChildC:Number = 2 * (heapK_C - left) + 2 + left;
                            var heapMaxC:Number = heapK_C;

                            if (heapLChildC <= heapJ_C - 1 && compare(arr[heapLChildC], arr[heapMaxC]) > 0) {
                                heapMaxC = heapLChildC;
                            }

                            if (heapRChildC <= heapJ_C - 1 && compare(arr[heapRChildC], arr[heapMaxC]) > 0) {
                                heapMaxC = heapRChildC;
                            }

                            if (heapMaxC != heapK_C) {
                                // 交换
                                var heapNewTempC:Number = arr[heapK_C];
                                arr[heapK_C] = arr[heapMaxC];
                                arr[heapMaxC] = heapNewTempC;
                                heapK_C = heapMaxC;
                            } else {
                                break;
                            }
                        }
                    }
                    continue;
                }

                // 三路分区实现内联
                // 使用三点取中法选择 pivot
                var midC:Number = left + Math.floor((right - left) / 2);
                // Median of Three
                if (compare(arr[left], arr[midC]) > 0) {
                    var tempMedianC:Number = arr[left];
                    arr[left] = arr[midC];
                    arr[midC] = tempMedianC;
                }
                if (compare(arr[left], arr[right]) > 0) {
                    var tempMedian2C:Number = arr[left];
                    arr[left] = arr[right];
                    arr[right] = tempMedian2C;
                }
                if (compare(arr[midC], arr[right]) > 0) {
                    var tempMedian3C:Number = arr[midC];
                    arr[midC] = arr[right];
                    arr[right] = tempMedian3C;
                }
                // Now, arr[left] <= arr[midC] <= arr[right]
                var pivotIndexC:Number = midC;
                var pivotValueC:Number = arr[pivotIndexC];

                // 将 pivot 移动到起始位置
                var pivotTempC:Number = arr[left];
                arr[left] = arr[pivotIndexC];
                arr[pivotIndexC] = pivotTempC;

                var lessIndexC:Number = left + 1; // 初始化为 left +1
                var greatIndexC:Number = right;
                var iLoopC:Number = left + 1;

                while (iLoopC <= greatIndexC) {
                    var cmpC:Number = compare(arr[iLoopC], pivotValueC);
                    if (cmpC < 0) {
                        // 交换 arr[iLoopC] 和 arr[lessIndexC]
                        var swapTempC:Number = arr[iLoopC];
                        arr[iLoopC] = arr[lessIndexC];
                        arr[lessIndexC] = swapTempC;
                        lessIndexC++;
                        iLoopC++;
                    } else if (cmpC > 0) {
                        // 交换 arr[iLoopC] 和 arr[greatIndexC]
                        var swapTemp2C:Number = arr[iLoopC];
                        arr[iLoopC] = arr[greatIndexC];
                        arr[greatIndexC] = swapTemp2C;
                        greatIndexC--;
                    } else {
                        iLoopC++;
                    }
                }

                // 将 pivot 移动到其正确的位置 lessIndexC -1
                var finalPivotTempC:Number = arr[left];
                arr[left] = arr[lessIndexC - 1];
                arr[lessIndexC - 1] = finalPivotTempC;

                // 计算子数组大小
                var leftSubarraySizeC:Number = lessIndexC - 1 - left;
                var rightSubarraySizeC:Number = right - greatIndexC;

                // 优先处理较小的子数组，减少栈深度
                if (leftSubarraySizeC < rightSubarraySizeC) {
                    if (left < lessIndexC - 1) {
                        stack[sp++] = left;
                        stack[sp++] = lessIndexC - 2;
                    }
                    if (greatIndexC + 1 < right) {
                        stack[sp++] = greatIndexC + 1;
                        stack[sp++] = right;
                    }
                } else {
                    if (greatIndexC + 1 < right) {
                        stack[sp++] = greatIndexC + 1;
                        stack[sp++] = right;
                    }
                    if (left < lessIndexC - 1) {
                        stack[sp++] = left;
                        stack[sp++] = lessIndexC - 2;
                    }
                }
            }
        }

        return arr;
    }
}
