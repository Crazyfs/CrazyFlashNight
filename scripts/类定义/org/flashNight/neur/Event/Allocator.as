import org.flashNight.neur.Event.Allocable.*;

class org.flashNight.neur.Event.Allocator {
    private var pool: Array;
    private var availSpace: Array;

    public function Allocator(_pool: Array, initialCapacity:Number) {
        this.pool = _pool;
        this.availSpace = new Array();
        for (var i:Number = initialCapacity - 1; i >= 0; i--) {
            this.pool.push(null);
            this.availSpace.push(i);
        }
    }

    public function Alloc(): Number {
        var ref:IAllocable = IAllocable(arguments[0]);
        var initArgs:Array = [];

        for (var i:Number = 1; i < arguments.length; i++) {
            initArgs.push(arguments[i]);
        }

        var index:Number;
        if (this.availSpace.length > 0) {
            index = Number(this.availSpace.pop()); // pop 应该返回最小的可用索引
            this.pool[index] = ref;
        } else {
            this.pool.push(ref);
            index = this.pool.length - 1;
        }
        ref.initialize.apply(ref, initArgs); // 初始化对象
        trace("Allocated index: " + index);
        return index;
    }

    public function Free(index: Number): Void {
        if (this.pool[index] == null) {
            trace("Warning: Attempted to free an unallocated or already freed index: " + index);
            return;
        }

        var obj: IAllocable = IAllocable(this.pool[index]);
        obj.reset();
        this.pool[index] = null;
        this.availSpace.push(index);
    }

    public function FreeAll(): Void {
        for (var i:Number = 0; i < this.pool.length; i++) {
            if (this.pool[i] != null && this.pool[i] != undefined) {
                var obj: IAllocable = IAllocable(this.pool[i]);
                obj.reset(); // 重置对象状态
                this.pool[i] = null;
            }
        }
        this.availSpace = [];
        for (var i:Number = this.pool.length - 1; i >= 0; i--) {
            this.availSpace.push(i); // 将索引从大到小压入 availSpace
        }
        trace("AvailSpace after FreeAll: " + this.availSpace);
    }

    public function getCallback(index:Number):Function {
        return this.pool[index];
    }

    public function getPoolSize(): Number {
        return this.pool.length;
    }

    public function getAvailSpaceCount(): Number {
        return this.availSpace.length;
    }

    public function isIndexAvailable(index:Number):Boolean {
        return this.availSpace.indexOf(index) >= 0;
    }
}
