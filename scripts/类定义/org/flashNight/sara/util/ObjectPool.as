class org.flashNight.sara.util.ObjectPool {
    private var pool:Array;                  // 对象池数组，用于存储可重用的对象
    private var prototype:MovieClip;         // 原型对象，用于克隆新对象
    private var createFunc:Function;         // 创建新对象的函数
    private var resetFunc:Function;          // 重置对象状态的函数
    private var releaseFunc:Function;        // 释放对象时的自定义清理函数
    private var maxPoolSize:Number;          // 对象池的最大容量
    private var preloadSize:Number;          // 预加载对象的数量
    private var parentClip:MovieClip;        // 父级影片剪辑，用于确定创建对象的层次
    private var isLazyLoaded:Boolean;        // 是否启用懒加载模式
    private var isPrototypeEnabled:Boolean;  // 是否启用原型模式

    /**
     * 构造函数
     * @param createFunc 创建新对象的函数，必须返回一个 MovieClip 实例
     * @param resetFunc  重置对象状态的函数，获取对象时调用
     * @param releaseFunc 释放对象时的自定义清理函数
     * @param parentClip 父级影片剪辑，用于创建对象时的层次绑定
     * @param maxPoolSize 对象池的最大容量（可选，默认30）
     * @param preloadSize 预加载对象的数量（可选，默认5）
     * @param isLazyLoaded 是否启用懒加载模式（可选，默认 true）
     * @param isPrototypeEnabled 是否启用原型模式（可选，默认 true）
     */
    public function ObjectPool(createFunc:Function, resetFunc:Function, releaseFunc:Function, parentClip:MovieClip, maxPoolSize:Number, preloadSize:Number, isLazyLoaded:Boolean, isPrototypeEnabled:Boolean) {
        this.pool = [];
        this.createFunc = createFunc;                             // 保存创建函数
        this.resetFunc = resetFunc;
        this.releaseFunc = releaseFunc;
        this.parentClip = parentClip;                             // 保存父级影片剪辑
        this.maxPoolSize = maxPoolSize || 30;                     // 默认最大容量为30
        this.preloadSize = preloadSize || 5;                     // 默认预加载5个对象
        this.isLazyLoaded = (isLazyLoaded != undefined) ? isLazyLoaded : true;  // 默认启用懒加载
        this.isPrototypeEnabled = (isPrototypeEnabled != undefined) ? isPrototypeEnabled : true; // 默认启用原型模式

        // 初始化原型对象，只有在原型模式开启时才会初始化原型对象
        if (this.isPrototypeEnabled) {
            this.prototype = this.createFunc(this.parentClip);    // 创建原型对象，绑定到父级影片剪辑
        }
    }

    /**
     * 通过克隆原型对象创建新对象，如果原型模式被禁用则直接创建新对象
     * 支持传递额外的参数给 createFunc
     * @param ...args 额外的参数，可传递给 createFunc
     * @return 克隆的新 MovieClip 对象，或通过 createFunc 创建的新对象
     */
    private function createNewObject():MovieClip {
        var newObj:MovieClip;
        if (this.isPrototypeEnabled && this.prototype != undefined) {
            // 使用父级影片剪辑来克隆原型对象
            newObj = this.prototype.duplicateMovieClip("cloneMC" + this.parentClip.getNextHighestDepth(), this.parentClip.getNextHighestDepth());
        } else {
            // 直接调用 createFunc 创建新对象，传递 parentClip 和额外参数
            newObj = this.createFunc.apply(null, [this.parentClip].concat(Array.prototype.slice.call(arguments)));
        }

        // 为新对象添加对所属对象池的引用
        newObj._pool = this;

        // 为新对象添加 recycle 方法
        newObj.recycle = function():Void {
            this._pool.releaseObject(this);
        };
            return newObj;
        }


    /**
     * 设置对象池的最大容量
     * @param maxPoolSize 最大容量值
     */
    public function setPoolCapacity(maxPoolSize:Number):Void {
        this.maxPoolSize = maxPoolSize;
    }

    /**
     * 预加载对象到池中，以减少运行时的创建开销
     * @param preloadSize 要预加载的对象数量
     */
    public function preload(preloadSize:Number):Void {
        if (!this.isLazyLoaded) {
            this.preloadSize = preloadSize;
            for (var i:Number = 0; i < this.preloadSize; i++) {
                if (this.pool.length < this.maxPoolSize) {
                    var obj:MovieClip = this.createNewObject();    // 根据配置创建新对象
                    this.pool.push(obj);                           // 将新对象加入池中
                }
            }
        }
    }

    /**
     * 从对象池中获取一个对象，如果池为空则根据配置创建新对象
     * @param ...args 额外的参数，可传递给 resetFunc
     * @return 一个可用的 MovieClip 对象
     */
    public function getObject():MovieClip {
        var obj:MovieClip;
        if (this.pool.length > 0) {
            obj = MovieClip(this.pool.shift());       // 从池中取出第一个对象（FIFO）
        } else {
            obj = this.createNewObject.apply(this, arguments);  // 池为空，根据配置创建新对象
        }

        // 确保对象的 _pool 属性指向当前对象池
        obj._pool = this;

        // 确保对象具有 recycle 方法
        if (typeof obj.recycle !== "function") {
            obj.recycle = function():Void {
                this._pool.releaseObject(this);
            };
        }

        // 重置对象状态，传递所有参数给 resetFunc
        this.resetFunc.apply(obj, Array.prototype.slice.call(arguments));
        return obj;
    }


    /**
     * 将对象释放回对象池中，或在池满时销毁对象
     * @param obj 要释放的对象
     */
    public function releaseObject(obj:MovieClip):Void {
        // 检查对象是否有效或已被销毁
        if (obj == undefined || obj.__isDestroyed) {
            return;
        }

        obj._visible = false;           // 隐藏对象
        delete obj.onEnterFrame;        // 删除 onEnterFrame 事件，防止继续执行逻辑

        // 调用自定义的释放函数，传递除第一个参数外的所有参数
        if (this.releaseFunc != undefined) {
            this.releaseFunc.apply(obj, Array.prototype.slice.call(arguments, 1));
        }

        // 检查对象池是否已满
        if (this.pool.length < this.maxPoolSize) {
            this.pool.push(obj);        // 将对象放回池中
        } else {
            obj.__isDestroyed = true;   // 标记对象已被销毁
            obj.removeMovieClip();      // 从舞台上移除对象，释放内存
        }

        // 清理对象对对象池的引用，防止循环引用导致的内存泄漏
        delete obj._pool;
    }
}
