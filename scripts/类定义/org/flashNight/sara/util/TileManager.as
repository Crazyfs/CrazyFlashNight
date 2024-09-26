import org.flashNight.sara.util.*;
import org.flashNight.neur.Server.ServerManager;  // 引入ServerManager类

class org.flashNight.sara.util.TileManager {
    private var tileSize:Number;               // 瓦片大小
    public var mapClip:MovieClip;             // 地图影片剪辑
    private var parentClip:MovieClip;          // 父级影片剪辑
    public var tileCache:Object;              // 瓦片缓存，键为"tileX_tileY"
    public var tileContainers:Array;          // 瓦片容器数组
    private var mapWidth:Number;               // 地图宽度
    private var mapHeight:Number;              // 地图高度
    private var lastCenterTileX:Number; // 上一次的中心瓦片 X 索引
    private var lastCenterTileY:Number; // 上一次的中心瓦片 Y 索引

    // 构造函数
    public function TileManager(tileSize:Number, mapClip:MovieClip, parentClip:MovieClip) {
        this.tileSize = tileSize;
        this.mapClip = mapClip;
        this.parentClip = parentClip;
        this.tileCache = {};
        this.tileContainers = [];
        this.mapWidth = mapClip._width;
        this.mapHeight = mapClip._height;

        // 创建9个瓦片容器
        for (var i:Number = 0; i < 9; i++) {
            var containerName:String = "tileContainer_" + i;
            var depth:Number = parentClip.getNextHighestDepth();
            var tileContainer:TileContainer = new TileContainer(parentClip, containerName, depth, 0, 0);
            this.tileContainers.push(tileContainer);
        }

        this.lastCenterTileX = null; // 初始值为 null，表示尚未更新过
        this.lastCenterTileY = null;

        // 初始化瓦片缓存
        this.initializeTileCache();
    }

private function initializeTileCache():Void {
    for (var tileY:Number = 0; tileY < Math.ceil(this.mapHeight / this.tileSize); tileY++) {
        for (var tileX:Number = 0; tileX < Math.ceil(this.mapWidth / this.tileSize); tileX++) {
            var tileID:String = tileX + "_" + tileY;
            var tileLeft:Number = tileX * this.tileSize;
            var tileTop:Number = tileY * this.tileSize;

            // 创建瓦片并缓存
            var bounds:AABB = new AABB(tileLeft, tileLeft + this.tileSize, tileTop, tileTop + this.tileSize);
            var tile:Tile = new Tile(this.mapClip, bounds);
            this.tileCache[tileID] = tile;

            // 日志
            ServerManager.getInstance().sendServerMessage("初始化瓦片: " + tileID + "，位置: (" + tileLeft + ", " + tileTop + ")");
        }
    }

    // 日志：缓存大小
    ServerManager.getInstance().sendServerMessage("瓦片缓存初始化完成，缓存大小: " + this.tileCache.length);
}



public function update(playerX:Number, playerY:Number):Void {
    // 确保使用传递的参数，并进行限制
    var clampedX:Number = Math.max(0, Math.min(playerX, this.mapWidth));
    var clampedY:Number = Math.max(0, Math.min(playerY, this.mapHeight));

    // 日志：传递和限制后的坐标
    ServerManager.getInstance().sendServerMessage("TileManager.update called with: (" + playerX + ", " + playerY + ")");
    ServerManager.getInstance().sendServerMessage("Clamped coordinates: (" + clampedX + ", " + clampedY + ")");

    // 计算玩家所在的瓦片索引
    var centerTileX:Number = Math.floor(clampedX / this.tileSize);
    var centerTileY:Number = Math.floor(clampedY / this.tileSize);

    // 日志：中心瓦片索引
    ServerManager.getInstance().sendServerMessage("Center Tile: (" + centerTileX + ", " + centerTileY + ")");

    // 如果玩家仍在同一瓦片内，且瓦片容器已经初始化，则不需要更新
    if (this.lastCenterTileX == centerTileX && this.lastCenterTileY == centerTileY) {
        ServerManager.getInstance().sendServerMessage("玩家仍在同一瓦片内，无需更新: (" + centerTileX + ", " + centerTileY + ")");
        return; // 直接返回，避免不必要的更新
    }

    // 更新 lastCenterTileX 和 lastCenterTileY
    this.lastCenterTileX = centerTileX;
    this.lastCenterTileY = centerTileY;
    ServerManager.getInstance().sendServerMessage("更新瓦片，玩家位置: (" + clampedX + ", " + clampedY + ")，中心瓦片: (" + centerTileX + ", " + centerTileY + ")");

    // 计算需要显示的瓦片范围（以玩家所在瓦片为中心的3x3区域）
    var index:Number = 0;
    for (var dy:Number = -1; dy <= 1; dy++) {
        for (var dx:Number = -1; dx <= 1; dx++) {
            var tileX:Number = centerTileX + dx;
            var tileY:Number = centerTileY + dy;

            // 获取对应的瓦片容器
            var tileContainer:TileContainer = this.tileContainers[index];

            // 边界检查，防止超出地图范围
            if (tileX >= 0 && tileX < Math.ceil(this.mapWidth / this.tileSize) && 
                tileY >= 0 && tileY < Math.ceil(this.mapHeight / this.tileSize)) {
                // 瓦片的像素位置
                var tileLeft:Number = tileX * this.tileSize;
                var tileTop:Number = tileY * this.tileSize;

                // 获取瓦片ID
                var tileID:String = tileX + "_" + tileY;

                // 从缓存中获取瓦片
                var tile:Tile = this.tileCache[tileID];

                // 设置瓦片容器的位置
                tileContainer.setPosition(tileLeft, tileTop);

                // **仅当瓦片内容发生变化时，才更新瓦片容器的内容**
                if (tileContainer.currentTileID != tileID) {
                    tileContainer.setTile(tile);
                    tileContainer.currentTileID = tileID; // 保存当前瓦片的 ID
                    ServerManager.getInstance().sendServerMessage("设置瓦片容器内容，容器索引: " + index + "，瓦片ID: " + tileID);
                }
            } else {
                // 如果超出地图范围，清空对应的瓦片容器
                tileContainer.clear(); // 清空容器内容
                tileContainer.currentTileID = null; // 重置当前瓦片 ID
                ServerManager.getInstance().sendServerMessage("超出地图范围，清空瓦片容器: 容器索引 " + index);
            }

            index++;
        }
    }
}

}
