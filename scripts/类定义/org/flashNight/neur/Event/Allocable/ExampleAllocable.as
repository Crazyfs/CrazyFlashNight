import org.flashNight.neur.Event.Allocable.*;

class org.flashNight.neur.Event.Allocable.ExampleAllocable implements IAllocable {
    public var data:Object;

    public function ExampleAllocable()
    {
        this.data = {};
    }

    // 初始化对象
    public function initialize():Void {
        // 设置初始状态
        this.data = arguments;
    }

    // 重置对象
    public function reset():Void {
        // 清理状态
        this.data = {};
    }
}
