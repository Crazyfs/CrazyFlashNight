/*
## 自适应快速排序与 PDQSort 使用指南

### 介绍

`自适应快速排序` 和 `PDQSort` 是两种高效的排序算法，适用于不同的数据集和应用场景。`自适应快速排序` 结合了标准快速排序和三路快速排序，在处理随机数据集、重复数据集时表现优异。而 `PDQSort` 基于模式识别技术，能够在处理已排序、逆序和部分有序的数据集时发挥强大的性能优势。

### 什么时候使用自适应快速排序？

`自适应快速排序` 在绝大多数情况下表现稳定，并且适合处理各种类型的数据集，特别是在以下场景下表现最佳：

1. **随机数据集**：
   - 自适应快速排序在处理随机分布的数据时表现高效且一致，特别是在小规模到中等规模的数据集（100 到 1000 个元素）上。即便是大规模的随机数据集，`自适应快速排序` 也能保持良好的性能表现。
   
2. **包含重复元素的数据集**：
   - 自适应快速排序在包含大量重复元素的数据集上表现尤为优异。通过三路快速排序的优化，它可以有效地减少重复元素的比较和交换操作，从而避免性能下降。在处理具有高重复率的数据集时，自适应快排明显优于 PDQSort。

3. **小规模数据集**：
   - 对于小规模的数据集（小于 1000 个元素），`自适应快速排序` 通常表现优于 PDQSort 和内建排序，因为它结合了快速排序和三路排序的优势，减少了不必要的递归和复杂度。

4. **不确定数据分布**：
   - 当数据分布不确定，或你无法预知数据集的特点时，`自适应快速排序` 是一个较为安全的选择。它可以在不同类型的数据集上提供一致的高性能表现，无需手动选择合适的排序算法。

### 什么时候使用 PDQSort？

尽管 `自适应快速排序` 在大多数情况下表现优异，`PDQSort` 在某些特定场景下具有显著的性能优势，特别是在以下情况下推荐使用 PDQSort：

1. **已排序或接近有序的数据集**：
   - `PDQSort` 在识别并处理已排序或部分有序的数据集时表现出色。它能够通过模式识别技术减少排序操作，从而显著缩短排序时间。特别是当数据集规模较大（如 1000+ 个元素）时，`PDQSort` 比 `自适应快排` 更为高效。

2. **完全逆序数据集**：
   - 在处理完全逆序的数据集时，`PDQSort` 能够避免快速排序可能出现的性能瓶颈，并通过堆排序保证较为稳定的性能。对于逆序数据，尤其是大规模数据（如 1000+ 元素），PDQSort 表现明显优于自适应快排。

3. **大规模数据集**：
   - 对于非常大的数据集（3000+ 元素），`PDQSort` 的性能往往更加稳定，尤其在已排序、逆序或部分有序的情况下。它可以通过模式识别减少不必要的排序开销，保持较低的时间复杂度。

### 性能表现总结

#### 1. 随机数据集
- **自适应快速排序**: 在处理 100 到 1000 元素的随机数据时表现优异，通常优于内建排序。在更大规模（10000+ 元素）的数据集上，性能依然稳定，建议优先使用。
- **PDQSort**: 在处理随机数据时表现不如自适应快排，尤其在大规模随机数据集上，PDQSort 有时会出现较高的性能开销。

#### 2. 已排序或部分有序数据集
- **PDQSort**: 对于已排序或部分有序的数据集，PDQSort 通过模式识别和优化能够显著减少排序时间。特别是在处理大规模数据集时（如 1000+ 元素），PDQSort 明显优于自适应快排。
- **自适应快速排序**: 在已排序数据集上表现良好，但在识别已排序模式方面不如 PDQSort。

#### 3. 完全逆序数据集
- **PDQSort**: 在处理完全逆序数据时表现稳定，避免了传统快速排序的性能瓶颈。它能够通过堆排序保证逆序数据的高效处理。
- **自适应快速排序**: 在处理逆序数据时性能仍然不错，但在极端情况下可能会略逊于 PDQSort。

#### 4. 重复数据集
- **自适应快速排序**: 通过三路快速排序的优化，自适应快排能够高效处理高重复率的数据集，避免不必要的比较和交换操作。
- **PDQSort**: 在高重复率数据集上，PDQSort 的模式识别能力表现不佳，可能导致性能大幅下降。建议在这种场景下优先选择自适应快排。

### 使用建议

1. **优先使用自适应快速排序**：
   - 在大部分场景下，`自适应快速排序` 提供了最佳的性能和一致性。特别是在处理随机数据和包含重复元素的数据集时，它是首选算法。

2. **在已排序、部分有序或完全逆序的数据集上，使用 PDQSort**：
   - 如果数据集是已排序、部分有序或完全逆序，`PDQSort` 能够通过模式识别减少排序操作，显著提高性能，特别是在处理大规模数据时。

3. **对于高重复率的数据集，优先选择自适应快速排序**：
   - 在处理具有高重复率的场景下，`自适应快速排序` 的三路快排优化能够有效减少比较和交换操作，避免性能下降。在这些情况下，PDQSort 的表现可能不佳。

4. **不确定数据分布时，使用自适应快速排序**：
   - 当数据分布不确定时，优先选择 `自适应快速排序`，它能够适应各种数据类型，并自动调整排序策略，保证性能稳定。

---

通过上述指南，您可以根据数据集的特性选择合适的排序算法，确保在不同场景下获得最佳的排序性能。
*/


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
        }

        var repetitiveCheckThreshold:Number = Math.ceil(256 / Math.log(length + 1));

        // 动态设置采样窗口和采样大小
        var windowSize:Number = Math.max(64, Math.floor(length / 16)); // 根据长度动态调整窗口大小
        var sampleSize:Number = Math.min(1024, Math.floor(length / 2)); // 增加样本大小以更好地检测重复率

        // 采样窗口内的重复度检测
        var overallDuplicateRatio:Number = 0;
        var totalSampledWindows:Number = 0;

        for (var iSample:Number = 0; iSample < sampleSize; iSample += windowSize) {
            var localUniqueCount:Number = 0;
            var localUniqueMap:Object = {};

            for (var jSample:Number = iSample; jSample < iSample + windowSize && jSample < sampleSize; jSample++) {
                var elem:String = String(arr[jSample]); // 转换为字符串以确保唯一性
                if (localUniqueMap[elem] == undefined) {
                    localUniqueMap[elem] = true;
                    localUniqueCount++;
                }
            }

            // 计算局部重复率
            var currentWindowSize:Number = Math.min(windowSize, sampleSize - iSample);
            var localDuplicateRatio:Number = 1 - (localUniqueCount / currentWindowSize);
            overallDuplicateRatio += localDuplicateRatio; // 计算整体重复率
            totalSampledWindows++;

            // 调试日志
            // trace("Initial Sampling - Window " + iSample + ": localDuplicateRatio = " + localDuplicateRatio);
            // trace("OverallDuplicateRatio (before averaging) = " + overallDuplicateRatio);

            // 如果局部重复率超过80%，提前终止，认为整个数组重复度较高
            if (localDuplicateRatio >= 0.8) {
                // trace("High duplicate ratio detected in initial sampling, switching to built-in sort.");
                arr.sort(compareFunction); // 使用内建排序
                return arr; // 直接返回，避免继续执行 PDQSort
            }
        }

        // 计算整体重复率
        overallDuplicateRatio = overallDuplicateRatio / totalSampledWindows;
        // trace("ALL OverallDuplicateRatio = " + overallDuplicateRatio);

        // 根据整体重复率调整 repetitiveCheckThreshold 并考虑退化到内建排序
        if (overallDuplicateRatio > 0.25) {
            repetitiveCheckThreshold = Math.max(12, Math.floor(repetitiveCheckThreshold / 1.5)); // 降低阈值，增加检测频率
            
            // 如果整体重复率非常高（> 0.25），直接退化为内建排序
            if (overallDuplicateRatio > 0.35) {
                // trace("High duplicate ratio detected, switching to built-in sort.");
                arr.sort(compareFunction);  // 使用内建排序
                return arr;  // 直接返回，避免继续执行 PDQSort
            }
        } else if (overallDuplicateRatio < 0.15) {
            repetitiveCheckThreshold = Math.min(64, repetitiveCheckThreshold * 2); // 提高阈值，减少检测频率
        }

        // 设置比较函数，默认使用数值比较
        var defaultCompare:Boolean = false;
        var compare:Function;
        if (compareFunction != null) {
            compare = compareFunction; // 使用自定义比较函数
        } else {
            defaultCompare = true; // 默认数值比较
            compare = function(a:Number, b:Number):Number {
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
        var operationCount:Number = 0;  // 分区操作计数

        if (defaultCompare) {
            // 使用默认数值比较的优化路径
            while (sp > 0) {
                right = Number(stack[--sp]);
                left = Number(stack[--sp]);

                // 使用插入排序处理小数组
                if (right - left <= 10) {
                    for (var iInsert:Number = left + 1; iInsert <= right; iInsert++) {
                        var key:Number = arr[iInsert];
                        var jInsert:Number = iInsert - 1;
                        while (jInsert >= left && arr[jInsert] > key) {
                            arr[jInsert + 1] = arr[jInsert];
                            jInsert--;
                        }
                        arr[jInsert + 1] = key;
                    }
                    continue;
                }

                operationCount++;

                // 每 threshold 次操作进行一次重复检测
                if (operationCount % repetitiveCheckThreshold == 0) {
                    var currentSampleSize:Number = Math.min(512, right - left + 1);
                    var uniqueCount:Number = 0;
                    var uniqueMap:Object = {};

                    for (var kSample:Number = left; kSample < left + currentSampleSize && kSample <= right; kSample++) {
                        var elemSample:Number = arr[kSample];
                        if (uniqueMap[elemSample] == undefined) {
                            uniqueMap[elemSample] = true;
                            uniqueCount++;
                        }
                    }

                    var duplicateRatio:Number = 1 - (uniqueCount / currentSampleSize);
                    // 调试日志
                    // trace("During sort: duplicateRatio = " + duplicateRatio);

                    if (duplicateRatio > 0.7) { // 将阈值从0.5降低到0.7
                        // trace("High duplicate ratio detected during sort, switching to built-in sort.");
                        arr.sort(compareFunction);
                        sp = 0; // 清空栈，因为数组已经排序
                        break;
                    }
                }

                // 模式检测：如果数组已接近有序，使用插入排序
                var orderedCount:Number = 0;
                for (var mCheck:Number = left + 1; mCheck <= right; mCheck++) {
                    if (arr[mCheck] >= arr[mCheck - 1]) {
                        orderedCount++;
                    }
                }
                if (orderedCount > (right - left) * 0.9) {
                    for (var nInsert:Number = left + 1; nInsert <= right; nInsert++) {
                        var keyVal:Number = arr[nInsert];
                        var p:Number = nInsert - 1;
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
                                    heapTemp = arr[current];
                                    arr[current] = arr[currentLargest];
                                    arr[currentLargest] = heapTemp;
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
                                heapSwapTemp = arr[heapK];
                                arr[heapK] = arr[heapMax];
                                arr[heapMax] = heapSwapTemp;
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

                // 每 threshold 次操作进行一次重复检测
                if (operationCount % repetitiveCheckThreshold == 0) {
                    var currentSampleSizeC:Number = Math.min(512, right - left + 1);
                    var uniqueCountC:Number = 0;
                    var uniqueMapC:Object = {};

                    for (var kC:Number = left; kC < left + currentSampleSizeC && kC <= right; kC++) {
                        var elemC:String = String(arr[kC]); // 转换为字符串
                        if (uniqueMapC[elemC] == undefined) {
                            uniqueMapC[elemC] = true;
                            uniqueCountC++;
                        }
                    }

                    var duplicateRatioC:Number = 1 - (uniqueCountC / currentSampleSizeC);
                    // 调试日志
                    // trace("During sort (custom compare): duplicateRatio = " + duplicateRatioC);

                    if (duplicateRatioC > 0.7) { // 将阈值从0.5降低到0.7
                        // trace("High duplicate ratio detected during sort, switching to built-in sort.");
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
                                    heapTempC = arr[currentC];
                                    arr[currentC] = arr[currentLargestC];
                                    arr[currentLargestC] = heapTempC;
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
                                heapSwapTempC = arr[heapK_C];
                                arr[heapK_C] = arr[heapMaxC];
                                arr[heapMaxC] = heapSwapTempC;
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
                if (i % 10 == 0) {
                    arr.push(Math.random() * size);
                } else {
                    arr.push(i);
                }
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

    // 测试内置 sort 方法
    if (sortType == "builtin") {
        startTime = getTimer();
        arr.sort(compareNumbers);
        endTime = getTimer();
        timeBuiltin = endTime - startTime;
        trace("Built-in sort time: " + timeBuiltin + " ms");
    }

    // 测试自定义快速排序
    if (sortType == "quicksort") {
        startTime = getTimer();
        QuickSort.sort(arrCopy, compareNumbers);
        endTime = getTimer();
        timeCustom = endTime - startTime;
        trace("Custom quicksort time: " + timeCustom + " ms");
    }

    // 测试三向快速排序
    if (sortType == "threeway") {
        startTime = getTimer();
        QuickSort.threeWaySort(arrCopy, compareNumbers);
        endTime = getTimer();
        timeCustom = endTime - startTime;
        trace("Three-way quicksort time: " + timeCustom + " ms");
    }

    // 测试自适应排序
    if (sortType == "adaptiveSort") {
        startTime = getTimer();
        QuickSort.adaptiveSort(arrCopy, compareNumbers);
        endTime = getTimer();
        timeCustom = endTime - startTime;
        trace("Adaptive sort time: " + timeCustom + " ms");
    }

    // 新增：测试 PDQSort
    if (sortType == "pdqsort") {
        startTime = getTimer();
        PDQSort.sort(arrCopy, compareNumbers);
        endTime = getTimer();
        timeCustom = endTime - startTime;
        trace("PDQSort time: " + timeCustom + " ms");
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
var testSizes:Array = [100, 1000, 3000];
var dataTypes:Array = ["random", "sorted", "reverse", "partial", "duplicates"];
var sortMethods:Array = ["builtin", "quicksort", "threeway", "adaptiveSort", "pdqsort"]; // 新增 pdqsort

// 依次执行测试
for (var i:Number = 0; i < testSizes.length; i++) {
    for (var j:Number = 0; j < dataTypes.length; j++) {
        for (var k:Number = 0; k < sortMethods.length; k++) {
            trace("Data Type: " + dataTypes[j] + ", Size: " + testSizes[i] + ", Sort Method: " + sortMethods[k]);
            performTest(testSizes[i], dataTypes[j], sortMethods[k]);
        }
    }
}


Data Type: random, Size: 100, Sort Method: builtin
Built-in sort time: 0 ms
-------------------------------
Data Type: random, Size: 100, Sort Method: quicksort
Custom quicksort time: 2 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 100, Sort Method: threeway
Three-way quicksort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 100, Sort Method: adaptiveSort
Adaptive sort time: 2 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 100, Sort Method: pdqsort
PDQSort time: 2 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: builtin
Built-in sort time: 3 ms
-------------------------------
Data Type: sorted, Size: 100, Sort Method: quicksort
Custom quicksort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: threeway
Three-way quicksort time: 2 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: adaptiveSort
Adaptive sort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 100, Sort Method: pdqsort
PDQSort time: 0 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: builtin
Built-in sort time: 3 ms
-------------------------------
Data Type: reverse, Size: 100, Sort Method: quicksort
Custom quicksort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: threeway
Three-way quicksort time: 13 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: adaptiveSort
Adaptive sort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 100, Sort Method: pdqsort
PDQSort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: builtin
Built-in sort time: 1 ms
-------------------------------
Data Type: partial, Size: 100, Sort Method: quicksort
Custom quicksort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: threeway
Three-way quicksort time: 3 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: adaptiveSort
Adaptive sort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 100, Sort Method: pdqsort
PDQSort time: 3 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: builtin
Built-in sort time: 3 ms
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: quicksort
Custom quicksort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: threeway
Three-way quicksort time: 3 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: adaptiveSort
Adaptive sort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 100, Sort Method: pdqsort
PDQSort time: 1 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 1000, Sort Method: builtin
Built-in sort time: 10 ms
-------------------------------
Data Type: random, Size: 1000, Sort Method: quicksort
Custom quicksort time: 21 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 1000, Sort Method: threeway
Three-way quicksort time: 29 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 1000, Sort Method: adaptiveSort
Adaptive sort time: 26 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 1000, Sort Method: pdqsort
PDQSort time: 52 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 1000, Sort Method: builtin
Built-in sort time: 295 ms
-------------------------------
Data Type: sorted, Size: 1000, Sort Method: quicksort
Custom quicksort time: 15 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 1000, Sort Method: threeway
Three-way quicksort time: 86 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 1000, Sort Method: adaptiveSort
Adaptive sort time: 15 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 1000, Sort Method: pdqsort
PDQSort time: 5 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 1000, Sort Method: builtin
Built-in sort time: 289 ms
-------------------------------
Data Type: reverse, Size: 1000, Sort Method: quicksort
Custom quicksort time: 18 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 1000, Sort Method: threeway
Three-way quicksort time: 1274 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 1000, Sort Method: adaptiveSort
Adaptive sort time: 18 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 1000, Sort Method: pdqsort
PDQSort time: 10 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 1000, Sort Method: builtin
Built-in sort time: 22 ms
-------------------------------
Data Type: partial, Size: 1000, Sort Method: quicksort
Custom quicksort time: 22 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 1000, Sort Method: threeway
Three-way quicksort time: 58 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 1000, Sort Method: adaptiveSort
Adaptive sort time: 20 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 1000, Sort Method: pdqsort
PDQSort time: 49 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 1000, Sort Method: builtin
Built-in sort time: 14 ms
-------------------------------
Data Type: duplicates, Size: 1000, Sort Method: quicksort
Custom quicksort time: 114 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 1000, Sort Method: threeway
Three-way quicksort time: 25 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 1000, Sort Method: adaptiveSort
Adaptive sort time: 14 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 1000, Sort Method: pdqsort
PDQSort time: 429 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 3000, Sort Method: builtin
Built-in sort time: 33 ms
-------------------------------
Data Type: random, Size: 3000, Sort Method: quicksort
Custom quicksort time: 81 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 3000, Sort Method: threeway
Three-way quicksort time: 101 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 3000, Sort Method: adaptiveSort
Adaptive sort time: 77 ms
Arrays are equal: true
-------------------------------
Data Type: random, Size: 3000, Sort Method: pdqsort
PDQSort time: 168 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 3000, Sort Method: builtin
Built-in sort time: 2585 ms
-------------------------------
Data Type: sorted, Size: 3000, Sort Method: quicksort
Custom quicksort time: 47 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 3000, Sort Method: threeway
Three-way quicksort time: 441 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 3000, Sort Method: adaptiveSort
Adaptive sort time: 54 ms
Arrays are equal: true
-------------------------------
Data Type: sorted, Size: 3000, Sort Method: pdqsort
PDQSort time: 13 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 3000, Sort Method: builtin
Built-in sort time: 2769 ms
-------------------------------
Data Type: reverse, Size: 3000, Sort Method: quicksort
Custom quicksort time: 64 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 3000, Sort Method: threeway
Three-way quicksort time: 12185 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 3000, Sort Method: adaptiveSort
Adaptive sort time: 64 ms
Arrays are equal: true
-------------------------------
Data Type: reverse, Size: 3000, Sort Method: pdqsort
PDQSort time: 29 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 3000, Sort Method: builtin
Built-in sort time: 88 ms
-------------------------------
Data Type: partial, Size: 3000, Sort Method: quicksort
Custom quicksort time: 71 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 3000, Sort Method: threeway
Three-way quicksort time: 311 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 3000, Sort Method: adaptiveSort
Adaptive sort time: 77 ms
Arrays are equal: true
-------------------------------
Data Type: partial, Size: 3000, Sort Method: pdqsort
PDQSort time: 166 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 3000, Sort Method: builtin
Built-in sort time: 56 ms
-------------------------------
Data Type: duplicates, Size: 3000, Sort Method: quicksort
Custom quicksort time: 394 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 3000, Sort Method: threeway
Three-way quicksort time: 97 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 3000, Sort Method: adaptiveSort
Adaptive sort time: 58 ms
Arrays are equal: true
-------------------------------
Data Type: duplicates, Size: 3000, Sort Method: pdqsort
PDQSort time: 55 ms
Arrays are equal: true
-------------------------------

*/