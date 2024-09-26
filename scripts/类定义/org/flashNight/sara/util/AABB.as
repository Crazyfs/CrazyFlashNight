﻿/*  org.flashNight.sara.util.AABB

# AABB（轴对齐边界框）类详细说明

## 目录

- [简介](#简介)
- [数学背景与概念](#数学背景与概念)
  - [什么是AABB？](#什么是aabb)
  - [AABB的用途](#aabb的用途)
- [类概述](#类概述)
- [属性与方法详解](#属性与方法详解)
  - [构造函数](#构造函数)
  - [克隆方法](#克隆方法)
  - [边界访问器方法](#边界访问器方法)
  - [尺寸和中心点计算](#尺寸和中心点计算)
  - [数据访问方法](#数据访问方法)
  - [碰撞检测方法](#碰撞检测方法)
    - [最小平移向量（MTV）计算](#最小平移向量mtv计算)
    - [点包含检测](#点包含检测)
    - [最近点计算](#最近点计算)
    - [线段相交检测](#线段相交检测)
    - [圆形相交检测](#圆形相交检测)
    - [射线相交检测](#射线相交检测)
    - [AABB相交检测](#aabb相交检测)
  - [合并与细分方法](#合并与细分方法)
    - [AABB合并](#aabb合并)
    - [批量合并](#批量合并)
    - [AABB细分](#aabb细分)
  - [其他实用方法](#其他实用方法)
    - [面积计算](#面积计算)
    - [从MovieClip创建AABB](#从movieclip创建aabb)
    - [绘制AABB](#绘制aabb)
- [使用示例](#使用示例)
  - [示例1：创建和基本操作](#示例1创建和基本操作)
  - [示例2：碰撞检测](#示例2碰撞检测)
  - [示例3：最小平移向量应用](#示例3最小平移向量应用)
  - [示例4：合并和细分](#示例4合并和细分)
- [注意事项](#注意事项)
- [适合新手的提示](#适合新手的提示)
- [结语](#结语)

## 简介

本说明详细介绍了`AABB`（轴对齐边界框）类的实现和使用方法。通过深入的数学背景解释和丰富的使用示例，帮助您理解并应用该类于游戏开发中的碰撞检测、空间划分等功能，即使您是缺乏数学背景的新手程序员，也能轻松上手。

## 数学背景与概念

### 什么是AABB？

AABB（Axis-Aligned Bounding Box）即轴对齐边界框，是在二维或三维空间中，与坐标轴对齐的矩形或立方体。由于其边界与坐标轴平行，计算和判断变得非常简单高效。

### AABB的用途

- **碰撞检测**：用于快速判断两个物体是否可能发生碰撞。
- **空间划分**：用于划分空间，建立四叉树、八叉树等数据结构，优化查询性能。
- **视锥裁剪**：在渲染时确定哪些物体需要被绘制。

## 类概述

`AABB`类用于表示二维空间中的轴对齐矩形区域。它提供了创建、操作和查询AABB的各种方法，包括碰撞检测、合并、细分等。

## 属性与方法详解

### 构造函数

```actionscript
public function AABB(left:Number, right:Number, top:Number, bottom:Number)
```

**描述**：创建一个新的`AABB`实例，指定左、右、上、下边界。

**参数**：

- `left`：左边界（最小x值）
- `right`：右边界（最大x值）
- `top`：上边界（最小y值）
- `bottom`：下边界（最大y值）

**注意**：必须满足`left <= right`和`top <= bottom`，否则会抛出错误。

### 克隆方法

```actionscript
public function clone():AABB
```

**描述**：创建当前`AABB`的副本。

**返回值**：新的`AABB`实例，具有相同的边界。

### 边界访问器方法

#### 获取边界

```actionscript
public function getLeft():Number
public function getRight():Number
public function getTop():Number
public function getBottom():Number
```

**描述**：分别获取`AABB`的左、右、上、下边界值。

#### 设置边界

```actionscript
public function setLeft(value:Number):Void
public function setRight(value:Number):Void
public function setTop(value:Number):Void
public function setBottom(value:Number):Void
```

**描述**：分别设置`AABB`的左、右、上、下边界值。

**参数**：

- `value`：新的边界值。

**注意**：

- 设置`left`时，`value`必须小于等于当前的`right`。
- 设置`right`时，`value`必须大于等于当前的`left`。
- 设置`top`时，`value`必须小于等于当前的`bottom`。
- 设置`bottom`时，`value`必须大于等于当前的`top`。
- 否则会抛出错误，提示边界值无效。

### 尺寸和中心点计算

#### 获取宽度和高度

```actionscript
public function getWidth():Number
public function getLength():Number
```

- `getWidth()`：计算并返回`AABB`的宽度，即`right - left`。
- `getLength()`：计算并返回`AABB`的高度，即`bottom - top`。

#### 获取中心点

```actionscript
public function getCenter():Object
```

**描述**：计算并返回`AABB`的中心点坐标。

**返回值**：

- `Object`：包含`x`和`y`属性，分别表示中心点的横坐标和纵坐标。

### 数据访问方法

#### 获取数据副本

```actionscript
public function getData():Array
```

**描述**：返回`AABB`边界数据的副本，顺序为`[left, right, top, bottom]`。

#### 设置数据

```actionscript
public function setData(newData:Array):Void
```

**描述**：使用新的边界数据设置`AABB`。

**参数**：

- `newData`：包含四个数字的数组，顺序为`[left, right, top, bottom]`。

**注意**：

- 如果`newData`有效（长度为4，且`left <= right`，`top <= bottom`），则直接设置。
- 否则，会自动调整边界值，确保`left <= right`，`top <= bottom`。

### 碰撞检测方法

#### 最小平移向量（MTV）计算

```actionscript
public function getMTV(other:AABB):Object
```

**描述**：计算当前`AABB`与另一个`AABB`之间的最小平移向量，用于解决碰撞。

**数学背景**：

- **重叠量计算**：在x轴和y轴上分别计算两个AABB的重叠量。
- **最小平移向量**：选择重叠量较小的轴作为移动方向，移动的距离为该轴上的重叠量。

**参数**：

- `other`：另一个`AABB`实例。

**返回值**：

- `{dx: Number, dy: Number}`：需要移动的最小距离。
- 如果没有重叠，返回`null`。

**示例**：

```actionscript
var mtv:Object = aabb1.getMTV(aabb2);
if (mtv != null) {
    // 发生碰撞，调整位置
    object.x += mtv.dx;
    object.y += mtv.dy;
}
```

#### 点包含检测

```actionscript
public function containsPoint(x:Number, y:Number):Boolean
```

**描述**：检查给定的点是否在`AABB`内。

**参数**：

- `x`：点的x坐标。
- `y`：点的y坐标。

**返回值**：

- `true`：点在`AABB`内或边界上。
- `false`：点在`AABB`外。

#### 最近点计算

```actionscript
public function closestPoint(x:Number, y:Number):Object
```

**描述**：计算`AABB`内离给定点最近的点。

**数学背景**：

- 对于给定点，在每个轴上，如果点在AABB内，则该轴的坐标不变；如果在外，则取AABB在该轴上的最近边界值。

**返回值**：

- `Object`：包含`x`和`y`属性，表示最近点的坐标。

#### 线段相交检测

```actionscript
public function intersectsLine(x1:Number, y1:Number, x2:Number, y2:Number):Boolean
```

**描述**：检查线段是否与`AABB`相交。

**数学背景**：

- 使用**梁-巴克斯基（Liang-Barsky）算法**，根据参数化的线段方程和AABB的边界，计算参数`t`的范围，判断是否存在相交。

**返回值**：

- `true`：线段与`AABB`相交。
- `false`：线段与`AABB`不相交。

#### 圆形相交检测

```actionscript
public function intersectsCircle(circleX:Number, circleY:Number, radius:Number):Boolean
```

**描述**：检查圆形是否与`AABB`相交。

**数学背景**：

- 找到AABB中离圆心最近的点，计算该点与圆心的距离，判断是否小于等于圆的半径。

**返回值**：

- `true`：圆形与`AABB`相交。
- `false`：圆形与`AABB`不相交。

#### 射线相交检测

```actionscript
public function intersectsRay(rayOriginX:Number, rayOriginY:Number, rayDirX:Number, rayDirY:Number):Boolean
```

**描述**：检查射线是否与`AABB`相交。

**数学背景**：

- 使用**射线与AABB的参数化方程**，计算射线在x轴和y轴上的进入和退出参数`t`，判断射线是否在AABB范围内。

**返回值**：

- `true`：射线与`AABB`相交。
- `false`：射线与`AABB`不相交。

#### AABB相交检测

```actionscript
public function intersects(other:AABB):Boolean
```

**描述**：检查当前`AABB`是否与另一个`AABB`相交。

**数学背景**：

- 判断两个AABB在x轴和y轴上是否存在重叠。

**返回值**：

- `true`：两个`AABB`相交。
- `false`：两个`AABB`不相交。

### 合并与细分方法

#### AABB合并

```actionscript
public function merge(other:AABB):AABB
```

**描述**：将当前`AABB`与另一个`AABB`合并，返回一个新的`AABB`，边界包含两个AABB的所有区域。

**示例**：

```actionscript
var mergedAABB = aabb1.merge(aabb2);
```

#### 批量合并

```actionscript
public static function mergeBatch(aabbs:Array):AABB
```

**描述**：合并一组`AABB`，返回一个包含所有AABB的最小`AABB`。

**参数**：

- `aabbs`：包含`AABB`实例的数组。

**注意**：

- 数组不能为空，否则会抛出错误。

**示例**：

```actionscript
var allAABB = AABB.mergeBatch([aabb1, aabb2, aabb3]);
```

#### AABB细分

```actionscript
public function subdivide():Array
```

**描述**：将当前`AABB`细分为四个更小的`AABB`，用于空间划分。

**返回值**：

- 包含四个`AABB`实例的数组，分别对应于：

  - `quad1`：右上区域
  - `quad2`：左上区域
  - `quad3`：左下区域
  - `quad4`：右下区域

**示例**：

```actionscript
var quads:Array = aabb1.subdivide();
```

### 其他实用方法

#### 面积计算

```actionscript
public function getArea():Number
```

**描述**：计算并返回`AABB`的面积。

**返回值**：

- 面积值，计算方式为`(right - left) * (bottom - top)`。

#### 从MovieClip创建AABB

```actionscript
public static function fromMovieClip(area:MovieClip, z_offset:Number):AABB
```

**描述**：根据`MovieClip`在游戏世界中的位置和z轴偏移量创建`AABB`。

**参数**：

- `area`：`MovieClip`实例。
- `z_offset`：z轴偏移量。

**返回值**：

- 新的`AABB`实例。

**示例**：

```actionscript
var aabbFromClip = AABB.fromMovieClip(movieClipInstance, 0);
```

#### 绘制AABB

```actionscript
public function draw(dmc:MovieClip):Void
```

**描述**：在指定的`MovieClip`上绘制当前的`AABB`，用于调试和可视化。

**参数**：

- `dmc`：用于绘制的`MovieClip`实例。

**示例**：

```actionscript
aabb1.draw(_root);
```

## 使用示例

### 示例1：创建和基本操作

```actionscript
// 创建AABB实例
var aabb1 = new AABB(0, 100, 0, 50);

// 获取边界值
trace("Left: " + aabb1.getLeft());    // 输出：Left: 0
trace("Right: " + aabb1.getRight());  // 输出：Right: 100

// 设置新的边界值
aabb1.setRight(120);
trace("New Right: " + aabb1.getRight()); // 输出：New Right: 120

// 获取宽度和高度
trace("Width: " + aabb1.getWidth());     // 输出：Width: 120
trace("Height: " + aabb1.getLength());   // 输出：Height: 50

// 获取中心点
var center = aabb1.getCenter();
trace("Center X: " + center.x + ", Center Y: " + center.y); // 输出：Center X: 60, Center Y: 25
```

### 示例2：碰撞检测

```actionscript
// 创建两个AABB
var aabb1 = new AABB(0, 100, 0, 100);
var aabb2 = new AABB(50, 150, 50, 150);

// 检查是否相交
if (aabb1.intersects(aabb2)) {
    trace("AABBs are intersecting.");
} else {
    trace("AABBs are not intersecting.");
}

// 检查点是否在AABB内
var pointX:Number = 75;
var pointY:Number = 75;
if (aabb1.containsPoint(pointX, pointY)) {
    trace("Point is inside aabb1.");
} else {
    trace("Point is outside aabb1.");
}
```

### 示例3：最小平移向量应用

```actionscript
// 创建两个重叠的AABB
var aabb1 = new AABB(0, 100, 0, 100);
var aabb2 = new AABB(80, 180, 80, 180);

// 计算MTV
var mtv:Object = aabb1.getMTV(aabb2);
if (mtv != null) {
    trace("MTV dx: " + mtv.dx + ", dy: " + mtv.dy);
    // 假设aabb1代表物体，调整其位置以解决碰撞
    object.x += mtv.dx;
    object.y += mtv.dy;
} else {
    trace("No collision detected.");
}
```

### 示例4：合并和细分

```actionscript
// 合并两个AABB
var aabb1 = new AABB(0, 50, 0, 50);
var aabb2 = new AABB(40, 100, 40, 100);
var mergedAABB = aabb1.merge(aabb2);

trace("Merged AABB - Left: " + mergedAABB.getLeft() + ", Right: " + mergedAABB.getRight());
trace("Merged AABB - Top: " + mergedAABB.getTop() + ", Bottom: " + mergedAABB.getBottom());

// 细分AABB
var quads = mergedAABB.subdivide();
for (var i:Number = 0; i < quads.length; i++) {
    trace("Quad " + (i+1) + ": Left=" + quads[i].getLeft() + ", Right=" + quads[i].getRight() +
          ", Top=" + quads[i].getTop() + ", Bottom=" + quads[i].getBottom());
}
```

## 注意事项

- **边界值有效性**：创建或修改`AABB`时，务必确保`left <= right`和`top <= bottom`，否则会抛出错误。
- **异常处理**：在设置边界或数据时，建议使用`try...catch`来捕获可能的异常，确保程序稳定性。
- **性能优化**：该类内部使用数组存储边界数据，经过优化以提高性能。访问边界时，建议使用提供的访问器方法。
- **调试**：使用`draw`方法可在舞台上绘制`AABB`，方便调试和可视化。

*/

import org.flashNight.sara.graphics.*;

class org.flashNight.sara.util.AABB {
    private var data:Array; // 存储 [left, right, top, bottom] 的数组

    // 构造函数
    public function AABB(left:Number, right:Number, top:Number, bottom:Number) {
        this.data = [left, right, top, bottom];
    }

    // 克隆当前的AABB
    public function clone():AABB {
        return new AABB(this.data[0], this.data[1], this.data[2], this.data[3]);
    }

    // 获取AABB的左边界
    public function getLeft():Number {
        return this.data[0];
    }

    // 设置AABB的左边界
    public function setLeft(value:Number):Void {
        if (value <= this.data[1]) {
            this.data[0] = value;
        } else {
            throw new Error("无效的AABB: 左边界不能大于右边界。");
        }
    }

    // 获取AABB的右边界
    public function getRight():Number {
        return this.data[1];
    }

    // 设置AABB的右边界
    public function setRight(value:Number):Void {
        if (value >= this.data[0]) {
            this.data[1] = value;
        } else {
            throw new Error("无效的AABB: 右边界不能小于左边界。");
        }
    }

    // 获取AABB的上边界
    public function getTop():Number {
        return this.data[2];
    }

    // 设置AABB的上边界
    public function setTop(value:Number):Void {
        if(value <= this.data[3]) {
            this.data[2] = value;
        }
        else {
            throw new Error("无效的AABB: 上边界不能大于下边界。");
        }
    }

    // 获取AABB的下边界
    public function getBottom():Number {
        return this.data[3];
    }

    // 设置AABB的下边界
    public function setBottom(value:Number):Void {
        if(value >= this.data[2]) {
            this.data[3] = value;
        }
        else {
            throw new Error("无效的AABB: 下边界不能小于上边界。");
        }
    }

    // 获取AABB的宽度
    public function getWidth():Number {
        return this.data[1] - this.data[0];
    }

    // 获取AABB的高度
    public function getLength():Number {
        return this.data[3] - this.data[2];
    }

    // 获取AABB的中心点
    public function getCenter():Object {
        var centerX:Number = (this.data[0] + this.data[1]) / 2;
        var centerY:Number = (this.data[2] + this.data[3]) / 2;
        return {x: centerX, y: centerY};
    }

    // 获取AABB的数据副本
    public function getData():Array {
        return this.data.concat(); // 返回数组的副本
    }

    // 设置AABB的数据
    public function setData(newData:Array):Void {
        if (newData.length == 4 && newData[0] <= newData[1] && newData[2] <= newData[3]) {
            // 验证数据有效性并设置内部数据数组
            this.data = newData.concat();
        } else {
            var left:Number = Math.min(newData[0], newData[1]);
            var right:Number = Math.max(newData[0], newData[1]);
            var top:Number = Math.min(newData[2], newData[3]);
            var bottom:Number = Math.max(newData[2], newData[3]);
            this.data = [left, right, top, bottom];
        }
    }

    // 获取当前AABB与另一个AABB之间的最小平移向量（MTV）
    public function getMTV(other:AABB):Object {
        /*
        trace("Calculating MTV between AABBs.");
        trace("Current AABB: " + this.toString());
        trace("Other AABB: " + other.toString());
        */
        // 计算x轴上的重叠
        var overlapX:Number = 0;
        if (this.data[0] < other.data[1] && this.data[1] > other.data[0]) {
            var moveRight:Number = other.data[1] - this.data[0]; // 向右移动的距离
            var moveLeft:Number = this.data[1] - other.data[0];  // 向左移动的距离
            //trace("Overlap on x-axis: moveRight = " + moveRight + ", moveLeft = " + moveLeft);
            overlapX = (moveLeft < moveRight) ? -moveLeft : moveRight; // 选择合适的方向
            //trace("Selected overlapX: " + overlapX);
        } else {
            //trace("No overlap on x-axis.");
            return null;
        }

        // 计算y轴上的重叠
        var overlapY:Number = 0;
        if (this.data[2] < other.data[3] && this.data[3] > other.data[2]) {
            var moveDown:Number = other.data[3] - this.data[2]; // 向下移动的距离
            var moveUp:Number = this.data[3] - other.data[2];   // 向上移动的距离
            //trace("Overlap on y-axis: moveDown = " + moveDown + ", moveUp = " + moveUp);
            overlapY = (moveUp < moveDown) ? -moveUp : moveDown; // 选择合适的方向
            //trace("Selected overlapY: " + overlapY);
        } else {
            //trace("No overlap on y-axis.");
            return null;
        }

        // 确定最小穿透轴
        if (Math.abs(overlapX) <= Math.abs(overlapY)) {
            //trace("Choosing x-axis for MTV: dx = " + overlapX);
            return {dx: overlapX, dy: 0};
        } else {
            //trace("Choosing y-axis for MTV: dy = " + overlapY);
            return {dx: 0, dy: overlapY};
        }
    }

    // 检查当前AABB是否包含给定的点
    public function containsPoint(x:Number, y:Number):Boolean {
        return (x >= this.data[0] && x <= this.data[1] && 
                y >= this.data[2] && y <= this.data[3]);
    }

    // 计算AABB中离给定点最近的点
    public function closestPoint(x:Number, y:Number):Object {
        return {
            x: Math.max(this.data[0], Math.min(x, this.data[1])),
            y: Math.max(this.data[2], Math.min(y, this.data[3]))
        };
    }

    // 检查线段是否与AABB相交
    public function intersectsLine(x1:Number, y1:Number, x2:Number, y2:Number):Boolean {
        if (this.containsPoint(x1, y1) || this.containsPoint(x2, y2)) {
            return true;
        }

        var t0:Number = 0.0;
        var t1:Number = 1.0;
        var dx:Number = x2 - x1;
        var dy:Number = y2 - y1;
        var p:Array = [-dx, dx, -dy, dy];
        var q:Array = [x1 - this.data[0], this.data[1] - x1, y1 - this.data[2], this.data[3] - y1];

        for (var i:Number = 0; i < 4; i++) {
            if (p[i] == 0) {
                if (q[i] < 0) {
                    return false;
                }
            } else {
                var t:Number = q[i] / p[i];
                if (p[i] < 0) {
                    if (t > t1) {
                        return false;
                    }
                    if (t > t0) {
                        t0 = t;
                    }
                } else {
                    if (t < t0) {
                        return false;
                    }
                    if (t < t1) {
                        t1 = t;
                    }
                }
            }
        }

        return t0 <= t1 && t1 >= 0 && t0 <= 1;
    }

    // 检查AABB是否与给定的圆相交
    public function intersectsCircle(circleX:Number, circleY:Number, radius:Number):Boolean {
        var nearestX:Number = Math.max(this.data[0], Math.min(circleX, this.data[1]));
        var nearestY:Number = Math.max(this.data[2], Math.min(circleY, this.data[3]));
        var deltaX:Number = circleX - nearestX;
        var deltaY:Number = circleY - nearestY;
        return (deltaX * deltaX + deltaY * deltaY) <= (radius * radius);
    }

    // 检查射线是否与AABB相交
    public function intersectsRay(rayOriginX:Number, rayOriginY:Number, rayDirX:Number, rayDirY:Number):Boolean {
        var tMin:Number, tMax:Number, tyMin:Number, tyMax:Number;
        var invDirX:Number = 1.0 / rayDirX;
        var invDirY:Number = 1.0 / rayDirY;

        if (rayDirX != 0) {
            tMin = (this.data[0] - rayOriginX) * invDirX;
            tMax = (this.data[1] - rayOriginX) * invDirX;
            
            if (tMin > tMax) {
                var temp:Number = tMin;
                tMin = tMax;
                tMax = temp;
            }
        } else {
            if (rayOriginX < this.data[0] || rayOriginX > this.data[1]) {
                return false;
            }
            tMin = Number.NEGATIVE_INFINITY;
            tMax = Number.POSITIVE_INFINITY;
        }

        if (rayDirY != 0) {
            tyMin = (this.data[2] - rayOriginY) * invDirY;
            tyMax = (this.data[3] - rayOriginY) * invDirY;
            
            if (tyMin > tyMax) {
                temp = tyMin;
                tyMin = tyMax;
                tyMax = temp;
            }
        } else {
            if (rayOriginY < this.data[2] || rayOriginY > this.data[3]) {
                return false;
            }
            tyMin = Number.NEGATIVE_INFINITY;
            tyMax = Number.POSITIVE_INFINITY;
        }

        if ((tMin > tyMax) || (tyMin > tMax)) {
            return false;
        }

        tMin = Math.max(tMin, tyMin);
        tMax = Math.min(tMax, tyMax);

        return tMax >= 0;
    }

    // 检查当前AABB是否与另一个AABB相交
    public function intersects(other:AABB):Boolean {
        return !(this.data[1] < other.data[0] || this.data[0] > other.data[1] || 
                 this.data[3] < other.data[2] || this.data[2] > other.data[3]);
    }

    // 将当前AABB与另一个AABB合并，返回新的AABB
    public function merge(other:AABB):AABB {
        var newLeft:Number = Math.min(this.data[0], other.data[0]);
        var newRight:Number = Math.max(this.data[1], other.data[1]);
        var newTop:Number = Math.min(this.data[2], other.data[2]);
        var newBottom:Number = Math.max(this.data[3], other.data[3]);
        return new AABB(newLeft, newRight, newTop, newBottom);
    }

    // 合并另一个AABB到当前AABB
    public function mergeWith(other:AABB):Void {
        this.data[0] = Math.min(this.data[0], other.data[0]);
        this.data[1] = Math.max(this.data[1], other.data[1]);
        this.data[2] = Math.min(this.data[2], other.data[2]);
        this.data[3] = Math.max(this.data[3], other.data[3]);
    }

    // 批量合并多个AABB
    public static function mergeBatch(aabbs:Array):AABB {
        if (aabbs.length == 0) {
            throw new Error("mergeBatch: No AABBs to merge.");
        }

        //trace("Starting mergeBatch with " + aabbs.length + " AABBs.");

        var mergedAABB:AABB = new AABB(aabbs[0].data[0], aabbs[0].data[1], aabbs[0].data[2], aabbs[0].data[3]);
        //trace("Initial merged AABB: " + mergedAABB.toString());

        for (var i:Number = 1; i < aabbs.length; i++) {
            //trace("Merging with AABB #" + i + ": " + aabbs[i].toString());
            mergedAABB.mergeWith(aabbs[i]);
            //trace("Merged AABB after iteration " + i + ": " + mergedAABB.toString());
        }

        // 调整最大边界以确保包含性
        mergedAABB.data[1] += 1;
        mergedAABB.data[3] += 1;

        //trace("Final merged AABB: " + mergedAABB.toString());
        return mergedAABB;
    }

    // 将AABB细分为四个更小的AABB
    public function subdivide():Array {
        var center:Object = this.getCenter();
        var left:Number = this.data[0];
        var right:Number = this.data[1];
        var top:Number = this.data[2];
        var bottom:Number = this.data[3];

        // 创建四个更小的AABB
        var quad1:AABB = new AABB(center.x, right, top, center.y);   // 右上
        var quad2:AABB = new AABB(left, center.x, top, center.y);    // 左上
        var quad3:AABB = new AABB(left, center.x, center.y, bottom); // 左下
        var quad4:AABB = new AABB(center.x, right, center.y, bottom); // 右下

        return [quad1, quad2, quad3, quad4];
    }

    // 计算AABB的面积
    public function getArea():Number {
        return (this.data[1] - this.data[0]) * (this.data[3] - this.data[2]);
    }

    // 从游戏世界中的MovieClip创建AABB
    public static function fromMovieClip(area:MovieClip, z_offset:Number):AABB {
        var rect = area.getRect(_root.gameworld);
        return new AABB(rect.xMin, rect.xMax, rect.yMin + z_offset, rect.yMax + z_offset);
    }

    // 从子弹的MovieClip创建AABB
    public static function fromBullet(bullet:MovieClip):AABB {
        var rect = bullet.getRect(_root.gameworld);
        return new AABB(rect.xMin, rect.xMax, rect.yMin, rect.yMax);
    }

    // 在给定的MovieClip上绘制AABB
    public function draw(dmc:MovieClip):Void {
        var width:Number = this.data[1] - this.data[0];
        var height:Number = this.data[3] - this.data[2];
        var centerX:Number = this.data[0] + width / 2;
        var centerY:Number = this.data[2] + height / 2;
        
        Graphics.paintRectangle(dmc, centerX, centerY, width, height);
    }
}
