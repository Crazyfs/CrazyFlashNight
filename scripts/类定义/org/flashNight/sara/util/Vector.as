/**
 * Sara - Customized Dynamics Engine for FlashNight Game
 * Release based on Flade 0.6 alpha modified for project-specific functionalities
 * Copyright 2004, 2005 Alec Cove
 * Modifications by fs, 2024
 *
 * This file is part of Sara, a customized dynamics engine developed for the FlashNight game project.
 *
 * Sara is free software; you can redistribute it and/or modify it under the terms of the GNU General
 * Public License as published by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Sara is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License along with Sara; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 * Flash is a registered trademark of Adobe Systems Incorporated.
 */

// 正在考虑是否需要将point与vector区分出来

class org.flashNight.sara.util.Vector {

	// 向量的 x 和 y 分量
	public var x:Number;
	public var y:Number;

	/**
	 * 构造函数，初始化向量的 x 和 y 分量
	 * @param px 初始的 x 分量
	 * @param py 初始的 y 分量
	 */
	public function Vector(px:Number, py:Number) {
		x = px;
		y = py;
	}

	/**
	 * 设置向量的值
	 * @param px 新的 x 分量
	 * @param py 新的 y 分量
	 */
	public function setTo(px:Number, py:Number):Void {
		x = px;
		y = py;
	}

	/**
	 * 复制另一个向量的值到当前向量
	 * @param v 要复制的向量
	 */
	public function copy(v:Vector):Void {
		x = v.x;
		y = v.y;
	}

	/**
	 * 计算向量的点积
	 * @param v 另一个向量
	 * @return 当前向量和 v 的点积结果
	 */
	public function dot(v:Vector):Number {
		return x * v.x + y * v.y;
	}

	/**
	 * 计算向量的叉积
	 * @param v 另一个向量
	 * @return 当前向量和 v 的叉积结果（标量）
	 */
	public function cross(v:Vector):Number {
		return x * v.y - y * v.x;
	}

	/**
	 * 向当前向量加上另一个向量（原位修改）
	 * @param v 要相加的向量
	 * @return 当前向量（已修改）
	 */
	public function plus(v:Vector):Vector {
		x += v.x;
		y += v.y;
		return this;
	}

	/**
	 * 返回当前向量与另一个向量相加后的新向量
	 * @param v 要相加的向量
	 * @return 一个新的向量，表示当前向量和 v 相加的结果
	 */
	public function plusNew(v:Vector):Vector {
		return new Vector(x + v.x, y + v.y);
	}

	/**
	 * 向当前向量减去另一个向量（原位修改）
	 * @param v 要减去的向量
	 * @return 当前向量（已修改）
	 */
	public function minus(v:Vector):Vector {
		x -= v.x;
		y -= v.y;
		return this;
	}

	/**
	 * 返回当前向量减去另一个向量后的新向量
	 * @param v 要减去的向量
	 * @return 一个新的向量，表示当前向量减去 v 的结果
	 */
	public function minusNew(v:Vector):Vector {
		return new Vector(x - v.x, y - v.y);
	}

	/**
	 * 将当前向量乘以一个标量（原位修改）
	 * @param s 要乘的标量
	 * @return 当前向量（已修改）
	 */
	public function mult(s:Number):Vector {
		x *= s;
		y *= s;
		return this;
	}

	/**
	 * 返回当前向量乘以一个标量后的新向量
	 * @param s 要乘的标量
	 * @return 一个新的向量，表示当前向量乘以标量后的结果
	 */
	public function multNew(s:Number):Vector {
		return new Vector(x * s, y * s);
	}

	/**
	 * 计算两个向量之间的距离
	 * @param v 另一个向量
	 * @return 当前向量与 v 之间的欧几里得距离
	 */
	public function distance(v:Vector):Number {
		var dx:Number = x - v.x;
		var dy:Number = y - v.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * 将当前向量归一化，使其模长为 1
	 * @return 当前向量（已归一化）
	 */
	public function normalize():Vector {
	   var mag:Number = Math.sqrt(x * x + y * y);
	   if (mag > 0) {
		   x /= mag;
		   y /= mag;
	   }
	   return this;
	}

	/**
	 * 返回当前向量的模长（长度）
	 * @return 向量的模长
	 */
	public function magnitude():Number {
		return Math.sqrt(x * x + y * y);
	}

	/**
	 * 计算当前向量在另一个向量上的投影
	 * @param b 要投影的向量
	 * @return 投影后的新向量
	 */
	public function project(b:Vector):Vector {
		var adotb:Number = this.dot(b);
		var len:Number = (b.x * b.x + b.y * b.y);
		
		var proj:Vector = new Vector(0, 0);
		proj.x = (adotb / len) * b.x;
		proj.y = (adotb / len) * b.y;
		return proj;
	}

	/**
	 * 计算当前向量与另一个向量之间的夹角（弧度）
	 * @param v 另一个向量
	 * @return 两个向量之间的夹角（弧度）
	 */
	public function angleBetween(v:Vector):Number {
		var mag1:Number = this.magnitude();
		var mag2:Number = v.magnitude();
		if (mag1 > 0 && mag2 > 0) {
			return Math.acos(this.dot(v) / (mag1 * mag2));
		} else {
			return 0;
		}
	}

	/**
	 * 将当前向量按指定角度旋转（弧度）
	 * @param theta 旋转的角度（弧度）
	 * @return 旋转后的新向量
	 */
	public function rotate(theta:Number):Vector {
		var cosVal:Number = Math.cos(theta);
		var sinVal:Number = Math.sin(theta);
		return new Vector(x * cosVal - y * sinVal, x * sinVal + y * cosVal);
	}

	/**
	 * 在当前向量和目标向量之间进行线性插值
	 * @param v 目标向量
	 * @param t 插值因子，范围 0 <= t <= 1
	 * @return 插值后的新向量
	 */
	public function lerp(v:Vector, t:Number):Vector {
		return new Vector(x + (v.x - x) * t, y + (v.y - y) * t);
	}

	/**
	 * 计算当前向量的法线（垂直向量）
	 * @return 当前向量的法线
	 */
	public function perpendicular():Vector {
		return new Vector(-y, x); // 二维向量的法线为 (-y, x)
	}


	/**
	 * 将当前向量转换为字符串表示
	 * @return 字符串表示的当前向量
	 */
	public function toString():String {
		return x + "," + y;
	}
}

