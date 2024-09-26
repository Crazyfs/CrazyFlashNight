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
    private var prototypeInitArgs:Array;     // 原型初始化所需的额外参数

    /**
     * 构造函数，用于初始化对象池的各项参数
     * @param createFunc 创建新对象的函数，必须返回一个 MovieClip 实例
     * @param resetFunc  重置对象状态的函数，在获取对象时调用
     * @param releaseFunc 释放对象时调用的自定义清理函数
     * @param parentClip 父级影片剪辑，用于创建对象时的层次绑定
     * @param maxPoolSize 对象池的最大容量（可选，默认30）
     * @param preloadSize 预加载对象的数量（可选，默认5）
     * @param isLazyLoaded 是否启用懒加载模式（可选，默认 true）
     * @param isPrototypeEnabled 是否启用原型模式（可选，默认 true）
     * @param prototypeInitArgs 原型初始化所需的额外参数（可选，默认空数组）
     */
    public function ObjectPool(
        createFunc:Function,
        resetFunc:Function,
        releaseFunc:Function,
        parentClip:MovieClip,
        maxPoolSize:Number,
        preloadSize:Number,
        isLazyLoaded:Boolean,
        isPrototypeEnabled:Boolean,
        prototypeInitArgs:Array
    ) {
        this.pool = [];  // 初始化对象池数组
        this.createFunc = createFunc;  // 创建新对象的函数
        this.resetFunc = resetFunc;  // 重置对象的函数
        this.releaseFunc = releaseFunc;  // 释放对象的函数
        this.parentClip = parentClip;  // 父级影片剪辑
        this.maxPoolSize = maxPoolSize || 30;  // 设置最大容量，默认为30
        this.preloadSize = preloadSize || 5;  // 设置预加载数量，默认为5
        this.isLazyLoaded = (isLazyLoaded != undefined) ? isLazyLoaded : true;  // 是否启用懒加载，默认为 true
        this.isPrototypeEnabled = (isPrototypeEnabled != undefined) ? isPrototypeEnabled : true;  // 是否启用原型模式，默认为 true
        this.prototypeInitArgs = prototypeInitArgs || [];  // 原型初始化所需的额外参数，默认为空

        // 如果启用了原型模式，则初始化原型对象
        if (this.isPrototypeEnabled) {
            // 使用 createFunc 和初始化参数创建原型对象
            this.prototype = this.createFunc.apply(null, [this.parentClip].concat(this.prototypeInitArgs));
            this.prototype._visible = false;  // 原型对象不可见
        }
    }

    /**
     * 创建新对象
     * 如果启用了原型模式，将通过克隆原型对象创建新对象；否则直接调用 createFunc 创建新对象
     * @return 新创建的 MovieClip 对象
     */
    private function createNewObject():MovieClip {
        var newObj:MovieClip;

        // 如果启用了原型模式且原型对象存在，通过克隆原型创建新对象
        if (this.isPrototypeEnabled && this.prototype != undefined) {
            newObj = this.prototype.duplicateMovieClip("cloneMC" + this.parentClip.getNextHighestDepth(), this.parentClip.getNextHighestDepth());
        } else {
            // 否则直接调用 createFunc 创建新对象，传递 parentClip 和 prototypeInitArgs
            newObj = this.createFunc.apply(null, [this.parentClip].concat(this.prototypeInitArgs));
        }

        // 为新对象添加 _pool 引用，指向当前对象池
        newObj._pool = this;

        // 为新对象添加 recycle 方法，用于回收对象到池中
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
     * 只有在禁用懒加载时才会进行预加载
     * @param preloadSize 要预加载的对象数量
     */
    public function preload(preloadSize:Number):Void {
        if (!this.isLazyLoaded) {
            this.preloadSize = preloadSize;
            for (var i:Number = 0; i < this.preloadSize; i++) {
                if (this.pool.length < this.maxPoolSize) {
                    var obj:MovieClip = this.createNewObject();  // 根据配置创建新对象
                    this.pool.push(obj);  // 将新对象加入池中
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

        // 如果池中有对象，则取出第一个对象；否则创建新对象
        if (this.pool.length > 0) {
            obj = MovieClip(this.pool.shift());
        } else {
            obj = this.createNewObject();
        }

        // 确保对象的 _pool 属性指向当前对象池
        obj._pool = this;

        // 如果对象未包含 recycle 方法，确保为其添加 recycle 方法
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

        // 调用自定义的释放函数，传递除第一个参数外的所有参数
        if (this.releaseFunc != undefined) {
            this.releaseFunc.apply(obj, Array.prototype.slice.call(arguments, 1));
        }

        // 清理对象的 _pool 引用，防止内存泄漏
        delete obj._pool;
        delete obj.recycle;

        // 检查对象池是否已满
        if (this.pool.length < this.maxPoolSize) {
            this.pool.push(obj);  // 将对象放回池中
        } else {
            obj.__isDestroyed = true;  // 标记对象已被销毁
            obj.removeMovieClip();  // 从舞台上移除对象，释放内存
        }
    }

    /**
     * 获取池中的对象数量
     * @return 对象池中的当前对象数量
     */
    public function getPoolSize():Number {
        return this.pool.length;
    }

    /**
     * 获取对象池的最大容量
     * @return 最大容量值
     */
    public function getMaxPoolSize():Number {
        return this.maxPoolSize;
    }

    /**
     * 检查是否启用了懒加载
     * @return 是否启用懒加载模式
     */
    public function isLazyLoadingEnabled():Boolean {
        return this.isLazyLoaded;
    }

    /**
     * 检查是否启用了原型模式
     * @return 是否启用原型模式
     */
    public function isPrototypeModeEnabled():Boolean {
        return this.isPrototypeEnabled;
    }
}
