// Delegate 类定义
class org.flashNight.neur.Event.Delegate {
    public static function create(scope:Object, method:Function):Function {
        return function() {
            return method.apply(scope, arguments);
        };
    }
}
