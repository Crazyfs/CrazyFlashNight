import org.flashNight.naki.Interpolation.Interpolatior;

class org.flashNight.naki.Interpolation.PointSetInterpolator {

    private var points:Array;  // 存储排序后的点集
    private var mode:String;   // 插值模式

    /**
     * 构造函数，初始化点集和插值模式，并对点集进行 x 坐标排序
     * 
     * @param points 点集，格式为 [[x1, y1], [x2, y2], ...]
     * @param mode 插值模式，接受 "linear", "cubic", "bezier", "catmullRom", "easeInOut", "bilinear", "bicubic", "exponential", "sine", "elastic", "logarithmic"
     */
    public function PointSetInterpolator(points:Array, mode:String) {
        this.points = points.sort(this.sortByX);  // 根据 x 坐标排序
        this.mode = mode;
    }

    /**
     * 点集排序函数，按照 x 坐标进行升序排序
     * 
     * @param a 点 a 的坐标 [x, y]
     * @param b 点 b 的坐标 [x, y]
     * @return 返回 -1, 0 或 1 表示比较结果
     */
    private function sortByX(a:Array, b:Array):Number {
        return a[0] - b[0];  // 按 x 坐标升序排序
    }

    /**
     * 进行插值计算
     * 
     * @param t 插值进度参数，范围 [0, 1]
     * @return 返回插值计算结果
     */
    public function interpolate(t:Number):Object {
        return this.applyInterpolatior(this.mode, t);
    }

    /**
     * 通用插值方法，调用 Interpolatior 中的方法来计算结果
     * 
     * @param method 插值方法名称，对应于 Interpolatior 中的方法名
     * @param t 插值进度参数，范围 [0, 1]
     * @return 返回插值计算结果
     */
    private function applyInterpolatior(method:String, t:Number):Object {
        var p0 = this.points[0];  // 起点
        var p1 = this.points[1];  // 终点
        var result:Object = {x: 0, y: 0};

        // 判断插值方法并调用相应的 Interpolatior 方法
        switch (method) {
            case "linear":
                result.x = Interpolatior.linear(t, 0, 1, p0[0], p1[0]);
                result.y = Interpolatior.linear(t, 0, 1, p0[1], p1[1]);
                break;
            case "cubic":
                if (this.points.length < 4) {
                    trace("三次插值需要至少4个点");
                    return null;
                }
                result.x = Interpolatior.cubic(t, p0[0], this.points[1][0], this.points[2][0], this.points[3][0]);
                result.y = Interpolatior.cubic(t, p0[1], this.points[1][1], this.points[2][1], this.points[3][1]);
                break;
            case "bezier":
                if (this.points.length < 4) {
                    trace("贝塞尔插值需要至少4个点");
                    return null;
                }
                result.x = Interpolatior.bezier(t, p0[0], this.points[1][0], this.points[2][0], this.points[3][0]);
                result.y = Interpolatior.bezier(t, p0[1], this.points[1][1], this.points[2][1], this.points[3][1]);
                break;
            case "catmullRom":
                if (this.points.length < 4) {
                    trace("Catmull-Rom 样条插值需要至少4个点");
                    return null;
                }
                result.x = Interpolatior.catmullRom(t, p0[0], this.points[1][0], this.points[2][0], this.points[3][0]);
                result.y = Interpolatior.catmullRom(t, p0[1], this.points[1][1], this.points[2][1], this.points[3][1]);
                break;
            case "easeInOut":
                result.x = Interpolatior.easeInOut(t) * (p1[0] - p0[0]) + p0[0];
                result.y = Interpolatior.easeInOut(t) * (p1[1] - p0[1]) + p0[1];
                break;
            case "bilinear":
                if (this.points.length < 4) {
                    trace("双线性插值需要至少4个点");
                    return null;
                }
                result.x = Interpolatior.bilinear(t, t, p0[0], this.points[1][0], this.points[2][0], this.points[3][0], 0, 1, 0, 1);
                result.y = Interpolatior.bilinear(t, t, p0[1], this.points[1][1], this.points[2][1], this.points[3][1], 0, 1, 0, 1);
                break;
            case "bicubic":
                if (this.points.length < 4) {
                    trace("双三次插值需要至少4个点");
                    return null;
                }
                result.x = Interpolatior.bicubic(t, p0[0], this.points[1][0], this.points[2][0], this.points[3][0]);
                result.y = Interpolatior.bicubic(t, p0[1], this.points[1][1], this.points[2][1], this.points[3][1]);
                break;
            case "exponential":
                result.x = Interpolatior.exponential(t, 2) * (p1[0] - p0[0]) + p0[0];
                result.y = Interpolatior.exponential(t, 2) * (p1[1] - p0[1]) + p0[1];
                break;
            case "sine":
                result.x = Interpolatior.sine(t) * (p1[0] - p0[0]) + p0[0];
                result.y = Interpolatior.sine(t) * (p1[1] - p0[1]) + p0[1];
                break;
            case "elastic":
                result.x = Interpolatior.elastic(t) * (p1[0] - p0[0]) + p0[0];
                result.y = Interpolatior.elastic(t) * (p1[1] - p0[1]) + p0[1];
                break;
            case "logarithmic":
                result.x = Interpolatior.logarithmic(t, 2) * (p1[0] - p0[0]) + p0[0];
                result.y = Interpolatior.logarithmic(t, 2) * (p1[1] - p0[1]) + p0[1];
                break;
            default:
                trace("未知的插值方法: " + method);
                return null;
        }

        return result;
    }
}
