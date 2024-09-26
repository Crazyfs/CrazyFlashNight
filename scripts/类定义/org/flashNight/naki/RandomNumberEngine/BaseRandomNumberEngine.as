﻿import org.flashNight.naki.DataStructures.*;

class org.flashNight.naki.RandomNumberEngine.BaseRandomNumberEngine {
    // 单例实例，确保全局只有一个实例
    private static var instance:BaseRandomNumberEngine;

    // 随机数生成器的种子，用于初始化随机数生成
    private var seed:Number;

    // 私有构造函数，防止直接实例化
    private function BaseRandomNumberEngine() {
        // 使用当前时间作为默认种子
        this.seed = new Date().getTime();
    }

    // 静态方法获取单例实例
    // 如果实例不存在则创建一个新的实例
    public static function getInstance():BaseRandomNumberEngine {
        if (instance == null) {
            instance = new BaseRandomNumberEngine();
        }
        return instance;
    }

    // 设置随机数种子
    // @param newSeed: 新的种子值
    public function setSeed(newSeed:Number):Void {
        this.seed = newSeed;
    }

    // 获取当前种子
    // @return 当前的种子值
    public function getSeed():Number {
        return this.seed;
    }

    // 生成下一个随机数的方法
    // 这个方法应该在派生类中被覆盖
    // @return 随机数
    public function next():Number {
        trace("base next");
        return 0; // 默认实现（无实际用途）
    }

    // 生成一个0到1之间的随机浮点数
    // @return 0到1之间的随机浮点数
    public function nextFloat():Number {
        trace("base nextFloat");
        return next() / 0x100000000; // 默认实现（无实际用途）
    }

    // 判断给定的成功率是否发生
    // @param probabilityPercent: 成功率的百分比（0-100）
    // @return 是否发生成功事件
    public function successRate(probabilityPercent:Number):Boolean {
        var randomValue:Number = nextFloat() * 100;
        return randomValue <= probabilityPercent;
    }

    // 在指定范围内生成一个随机整数
    // @param min: 最小值
    // @param max: 最大值
    // @return 生成的随机整数
    public function randomInteger(min:Number, max:Number):Number {
        return Math.floor(nextFloat() * (max - min + 1)) + min;
    }

    // 在指定范围内生成一个随机浮点数
    // @param min: 最小值
    // @param max: 最大值
    // @return 生成的随机浮点数
    public function randomFloat(min:Number, max:Number):Number {
        return nextFloat() * (max - min) + min;
    }

    // 在指定范围内生成一个随机整数偏移
    // @param range: 偏移范围
    // @return 生成的随机整数偏移
    public function randomOffset(range:Number):Number {
        trace("range: " + range);
        return Math.floor(nextFloat() * (range * 2 + 1)) - range;
    }

    // 在指定范围内生成一个随机浮点数偏移
    // @param range: 偏移范围
    // @return 生成的随机浮点数偏移
    public function randomFloatOffset(range:Number):Number {
        return nextFloat() * (range * 2) - range;
    }

    // 根据指定范围生成一个波动的乘数
    // @param fluctuationRange: 波动范围百分比
    // @return 波动后的乘数
    public function randomFluctuation(fluctuationRange:Number):Number {
        return 1 + (nextFloat() * (fluctuationRange * 2) - fluctuationRange) / 100;
    }

    // 从数组中获取一个随机元素
    // @param array: 待选数组
    // @return 数组中的随机元素
    public function getRandomArrayElement(array:Array):Object {
        if (array.length == 0) {
            return null; // 如果数组为空，返回null
        }
        var randomIndex:Number = randomInteger(0, array.length - 1); // 生成随机索引
        return array[randomIndex]; // 返回随机索引处的元素
    }

    // 随机打乱数组
    // @param array: 需要打乱的数组
    public function shuffleArray(array:Array):Void {
        var len:Number = array.length;
        if (len <= 1) {
            return; // 如果数组长度为0或1，无需打乱
        }
        for (var i:Number = 0; i < len; i++) {
            var j:Number = randomInteger(i, len - 1);
            var temp:Object = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    // 根据权重从数组中随机选择一个元素
    // @param array: 待选数组
    // @param weights: 权重数组
    // @return 根据权重选择的随机元素
    public function getWeightedRandomElement(array:Array, weights:Array):Object {
        if (array.length == 0 || array.length != weights.length) {
            return null; // 确保数组和权重非空且长度相同
        }
        var totalWeight:Number = 0;
        for (var i:Number = 0; i < weights.length; i++) {
            totalWeight += weights[i];
        }
        var random:Number = nextFloat() * totalWeight;
        for (i = 0; i < weights.length; i++) {
            random -= weights[i];
            if (random <= 0) {
                return array[i];
            }
        }
        return array[array.length - 1]; // 备用方案
    }

    // 生成一个指定大小的随机排列
    // @param size: 数组大小
    // @return 生成的随机排列
    public function generatePermutation(size:Number):Array {
        var array:Array = new Array(size);
        for (var i:Number = 0; i < size; i++) {
            array[i] = i;
        }
        shuffleArray(array);
        return array;
    }

    // 从流中随机选择k个样本
    // @param stream: 数据流
    // @param k: 样本大小
    // @return 随机选择的k个样本
    public function reservoirSample(stream:Array, k:Number):Array {
        var reservoir:Array = stream.slice(0, k);
        for (var i:Number = k; i < stream.length; i++) {
            var j:Number = randomInteger(0, i);
            if (j < k) {
                reservoir[j] = stream[i];
            }
        }
        return reservoir;
    }

    // 生成一个随机颜色
    // @return 生成的随机颜色值
    public function randomColor():Number {
        return randomInteger(0, 0xFFFFFF);
    }

    // 生成符合高斯分布的随机数
    // @param mean: 均值
    // @param standardDeviation: 标准差
    // @return 生成的高斯分布随机数
    public function randomGaussian(mean:Number, standardDeviation:Number):Number {
        var u1:Number = nextFloat();
        var u2:Number = nextFloat();
        var z0:Number = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
        return z0 * standardDeviation + mean;
    }

    // 生成符合指数分布的随机数
    // @param lambda: 指数分布的参数
    // @return 生成的指数分布随机数
    public function randomExponential(lambda:Number):Number {
        var u:Number = nextFloat();
        return -Math.log(1 - u) / lambda;
    }

    // 生成一个随机布尔值
    // @param probability: 返回true的概率（0到1之间）
    // @return 生成的随机布尔值
    public function randomBoolean(probability:Number):Boolean {
        // 如果未提供参数，使用默认值0.5
        if (probability == undefined) {
            probability = 0.5;
        }
        return nextFloat() < probability;
    }

    // 生成指定长度的随机字符串
    // @param length: 字符串长度
    // @return 生成的随机字符串
    public function randomString(length:Number):String {
        var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var str:String = "";
        for (var i:Number = 0; i < length; i++) {
            str += chars.charAt(randomInteger(0, chars.length - 1));
        }
        return str;
    }

    // 生成一个随机角度（0到360度）
    // @return 生成的随机角度
    public function randomAngle():Number {
        return nextFloat() * 360;
    }

    // 生成一个位于圆内的随机点
    // @param radius: 圆的半径
    // @return 圆内的随机点（包含x和y坐标）
    public function randomPointInCircle(radius:Number):Object {
        var angle:Number = randomAngle();
        var distance:Number = Math.sqrt(nextFloat()) * radius;
        return { x: distance * Math.cos(angle), y: distance * Math.sin(angle) };
    }

    // 获取数组中指定数量的唯一随机元素
    // @param array: 原始数组
    // @param count: 需要获取的元素数量
    // @return 数组中的唯一随机元素
    public function getUniqueRandomElements(array:Array, count:Number):Array {
        if (count > array.length) {
            return null; // 无法获取超过数组长度的唯一元素
        }
        shuffleArray(array);
        return array.slice(0, count);
    }
}
