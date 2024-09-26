import org.flashNight.naki.RandomNumberEngine.*;

// Store instances of the random number engines in _root
_root.linearEngine = LinearCongruentialEngine.getInstance();
_root.mersenneEngine = MersenneTwister.getInstance();

// Initialize engines with the current time as seed
_root.linearEngine.init(1192433993, 1013904223, 4294967296, new Date().getTime());
_root.mersenneEngine.initialize(new Date().getTime());

// 重置随机数种子，重新初始化线性同余引擎
_root.重置随机数种子 = function() {
    _root.random_seed = new Date().getTime() + this._currentframe + this._parent._currentframe + this._parent._currentframe;
    _root.linearEngine.setSeed(_root.random_seed);
    return _root.random_seed;
};

// 设置随机数种子，重新初始化梅森旋转器引擎
_root.srand_seed = function() {
    _root.random_seed = new Date().getTime() + this._currentframe;
    _root.mersenneEngine.initialize(_root.random_seed);
    _root.linearEngine.setSeed(_root.random_seed);
    return _root.random_seed;
};

// 使用线性同余引擎生成基础随机数
_root.basic_random = function() {
    return _root.linearEngine.nextFloat();
};

// 使用梅森旋转器引擎生成高级随机数
_root.advance_random = function() {
    return _root.mersenneEngine.nextFloat();
};

// 通过线性同余引擎计算成功率
_root.成功率 = function(probability_percent) {
    return _root.linearEngine.successRate(probability_percent);
};

// 通过线性同余引擎生成随机整数
_root.随机整数 = function(min, max) {
    return _root.linearEngine.randomInteger(min, max);
};

// 通过梅森旋转器引擎生成随机整数
_root.random_integer = function(min, max) {
    return _root.mersenneEngine.randomInteger(min, max);
};

// 通过线性同余引擎生成随机浮点数
_root.随机浮点 = function(min, max) {
    return _root.linearEngine.randomFloat(min, max);
};

// 通过梅森旋转器引擎生成随机浮点数
_root.random_float = function(min, max) {
    return _root.mersenneEngine.randomFloat(min, max);
};

// 通过线性同余引擎生成随机偏移
_root.随机偏移 = function(range:Number):Number {
    return _root.linearEngine.randomOffset(range);
};

// 通过梅森旋转器引擎生成随机偏移
_root.random_offset = function(range:Number):Number {
    return _root.mersenneEngine.randomOffset(range);
};

// 通过线性同余引擎生成随机浮点偏移
_root.随机浮点偏移 = function(range:Number):Number {
    return _root.linearEngine.randomFloatOffset(range);
};

// 通过梅森旋转器引擎生成随机浮点偏移
_root.random_float_offset = function(range:Number):Number {
    return _root.mersenneEngine.randomFloatOffset(range);
};

// 通过线性同余引擎生成随机波动
_root.随机波动 = function(波动幅度:Number):Number {
    return _root.linearEngine.randomFluctuation(波动幅度);
};

// 通过梅森旋转器引擎生成随机波动
_root.random_fluctuation = function(fluctuation_range:Number):Number {
    return _root.mersenneEngine.randomFluctuation(fluctuation_range);
};

// 通过线性同余引擎计算成功率
_root.rate_of_success = function(probability_percent) {
    return _root.mersenneEngine.successRate(probability_percent);
};

// 从数组中获取随机成员
_root.获取随机数组成员 = function(数组表:Array) {
    return _root.linearEngine.getRandomArrayElement(数组表);
};

// 使用线性同余引擎洗牌数组
_root.数组洗牌 = function(数组表:Array) {
    _root.linearEngine.shuffleArray(数组表);
};
