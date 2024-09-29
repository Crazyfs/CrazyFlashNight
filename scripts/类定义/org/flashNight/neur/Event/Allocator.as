import org.flashNight.neur.Event.Allocable.*;

class org.flashNight.neur.Event.Allocator
{
    private var pool: Array;
    private var availSpace: Array;

    // precondition: _pool 是一个空数组
    public function Allocator(_pool: Array, initialCapacity:Number)
    {
        this.pool = _pool;
        this.availSpace = new Array();
        for (var i:Number = 0; i < initialCapacity; i++) {
            this.pool.push(null);
            this.availSpace.push(i);
        }
    }

    /**
     * 分配对象，返回索引
     * @param ref 实现了 IAllocable 接口的对象
     * @return Number 分配对象的索引
     */
    public function Alloc(ref: IAllocable): Number
    {
        var index:Number;
        if (this.availSpace.length > 0)
        {
            index = this.availSpace.pop();
            this.pool[index] = ref;
        }
        else
        {
            this.pool.push(ref);
            index = this.pool.length - 1;
        }
        ref.initialize(); // 初始化对象
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
}
