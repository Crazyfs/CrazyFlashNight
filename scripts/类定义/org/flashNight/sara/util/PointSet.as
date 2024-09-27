import org.flashNight.sara.util.*; 

class org.flashNight.sara.util.PointSet 
{

	// 用于存储 Vector 实例的数组，每个 Vector 表示一个点
	private var points:Array;

	/** 
	 * 构造函数，初始化点集
	 */
	public function PointSet() {
		points = []; // 初始化一个空的数组，用于存储 Vector 实例
	}

	/**
	 * 添加一个新的点到点集中
	 * @param x 点的 x 坐标
	 * @param y 点的 y 坐标
	 */
	public function addPoint(x:Number, y:Number):Void {
		var point:Vector = new Vector(x, y); // 创建一个新的 Vector 实例表示点
		points.push(point); // 将点添加到数组中
	}

	/**
	 * 获取点集中的某个点
	 * @param index 点的索引
	 * @return 点的 Vector 实例
	 */
	public function getPoint(index:Number):Vector 
	{
		if (index >= 0 && index < points.length) {
			return points[index]; // 返回指定索引的 Vector
		}
		return null; // 如果索引无效，返回 null
	}

	/**
	 * 移除点集中的某个点
	 * @param index 要移除的点的索引
	 */
	public function removePoint(index:Number):Void {
		if (index >= 0 && index < points.length) {
			points.splice(index, 1); // 从数组中移除指定索引的 Vector
		}
	}

	/**
	 * 获取点集的大小
	 * @return 点集中的点的数量
	 */
	public function size():Number {
		return points.length; // 返回数组的长度，即点的数量
	}

	/**
	 * 计算点集的质心（中心点）
	 * @return 质心的坐标 Vector 实例
	 */
	public function getCentroid():Vector {
		var sumX:Number = 0;
		var sumY:Number = 0;
		var totalPoints:Number = points.length;

		for (var i:Number = 0; i < totalPoints; i++) {
			sumX += points[i].x;
			sumY += points[i].y;
		}

		// 返回质心的 Vector 实例
		return new Vector(sumX / totalPoints, sumY / totalPoints);
	}

	/**
	 * 使用 AABB 类计算点集的包围盒
	 * @return AABB 实例，表示包围盒
	 */
	public function getBoundingBox():AABB {
		if (points.length == 0) return null;

		var minX:Number = points[0].x;
		var maxX:Number = points[0].x;
		var minY:Number = points[0].y;
		var maxY:Number = points[0].y;

		// 计算点集中的最小和最大坐标
		for (var i:Number = 1; i < points.length; i++) {
			if (points[i].x < minX) minX = points[i].x;
			if (points[i].x > maxX) maxX = points[i].x;
			if (points[i].y < minY) minY = points[i].y;
			if (points[i].y > maxY) maxY = points[i].y;
		}

		// 使用计算出的最小和最大坐标创建并返回 AABB 实例
		return new AABB(minX, maxX, minY, maxY);
	}

	/**
	 * 计算两个点集之间的最小距离
	 * @param other 另一个点集
	 * @return 最小距离
	 */
	public function getMinDistanceTo(other:PointSet):Number {
		var minDistance:Number = Number.MAX_VALUE;

		for (var i:Number = 0; i < this.points.length; i++) {
			for (var j:Number = 0; j < other.size(); j++) {
				var pointA:Vector = this.points[i];
				var pointB:Vector = other.getPoint(j);
				var distance:Number = pointA.distance(pointB); // 使用 Vector 类的 distance 方法
				if (distance < minDistance) {
					minDistance = distance;
				}
			}
		}

		return minDistance;
	}
}
