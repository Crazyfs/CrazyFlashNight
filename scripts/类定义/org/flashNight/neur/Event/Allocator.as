import org.flashNight.neur.Event.Allocable.*;

class org.flashNight.neur.Event.Allocator
{
    private var pool: Array;
    private var availSpace: Array;

    // precondition: _pool 是一个空数组
    // 反转 availSpace 的初始化顺序，使得 pop() 方法首先返回索引 0。
    public function Allocator(_pool: Array, initialCapacity:Number)
    {
        this.pool = _pool;
        this.availSpace = new Array();
        for (var i:Number = initialCapacity - 1; i >= 0; i--) {
            this.pool.push(null);
            this.availSpace.push(i);
        }
    }


    /**
     * 分配对象，返回索引
     * @param ref 实现了 IAllocable 接口的对象
     * @param ...args 传递给 initialize 方法的额外参数
     * @return Number 分配对象的索引
     */
    public function Alloc(): Number
    {
        var ref:IAllocable = IAllocable(arguments[0]);
        var initArgs:Array = [];
        for (var i:Number = 1; i < arguments.length; i++) {
            initArgs.push(arguments[i]);
        }

        var index:Number;
        if (this.availSpace.length > 0)
        {
            index = Number(this.availSpace.pop());
            this.pool[index] = ref;
        }
        else
        {
            this.pool.push(ref);
            index = this.pool.length - 1;
        }
        ref.initialize.apply(ref, initArgs); // 初始化对象，传递额外参数
        return index;
    }

    /**
     * 释放指定索引的对象
     * @param index Number 要释放的对象索引
     */
    public function Free(index: Number): Void
    {
        if ((this.pool[index] == null) || (this.pool[index] == undefined))
        {
            trace("Warning: Attempted to free an unallocated or already freed index: " + index);
            return;
        }

        var obj: IAllocable = IAllocable(this.pool[index]);
        obj.reset(); // 重置对象状态
        this.pool[index] = null;
        this.availSpace.push(index);
    }

    /**
     * 释放所有对象，重置池
     */
    public function FreeAll(): Void
    {
        for (var i:Number = 0; i < this.pool.length; i++) {
            if (this.pool[i] != null && this.pool[i] != undefined) {
                var obj: IAllocable = IAllocable(this.pool[i]);
                obj.reset(); // 重置对象状态
                this.pool[i] = null;
            }
        }
        this.availSpace = new Array();
    }

    /**
     * 获取回调函数
     * @param index Number 回调函数的索引
     * @return 改为obj以适应不同需求
     */
    public function getCallback(index:Number):Function {
        return this.pool[index];
    }


    /**
     * 获取当前池的大小
     * @return Number
     */
    public function getPoolSize(): Number {
        return this.pool.length;
    }

    /**
     * 获取可用空间的数量
     * @return Number
     */
    public function getAvailSpaceCount(): Number {
        return this.availSpace.length;
    }

    /**
     * 检查指定索引是否在可用空间中
     * @param index Number 要检查的索引
     * @return Boolean 如果在可用空间中则返回 true，否则返回 false
     */
    public function isIndexAvailable(index:Number):Boolean {
        for (var i:Number = 0; i < this.availSpace.length; i++) {
            if (this.availSpace[i] == index) {
                return true;
            }
        }
        return false;
    }

    /**
     * 打印当前 Allocator 的状态
     */
    public function logStatus(): Void {
        trace("Allocator Status:");
        trace("Pool Size: " + this.getPoolSize());
        trace("Available Indices: " + this.getAvailSpaceCount());
    }
}
