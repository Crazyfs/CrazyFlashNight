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


//TBD: rename this to reflect its vector and/or default nature

import org.flashNight.naki.Interpolation.*;

class org.flashNight.sara.graphics.Graphics {

	public static function paintLine (
			dmc:MovieClip, 
			x0:Number, 
			y0:Number, 
			x1:Number, 
			y1:Number):Void {
		
		dmc.moveTo(x0, y0);
		dmc.lineTo(x1, y1);
	}


	public static function paintCircle (dmc:MovieClip, x:Number, y:Number, r:Number):Void {

		var mtp8r:Number = Math.tan(Math.PI/8) * r;
		var msp4r:Number = Math.sin(Math.PI/4) * r;

		with (dmc) {
			moveTo(x + r, y);
			curveTo(r + x, mtp8r + y, msp4r + x, msp4r + y);
			curveTo(mtp8r + x, r + y, x, r + y);
			curveTo(-mtp8r + x, r + y, -msp4r + x, msp4r + y);
			curveTo(-r + x, mtp8r + y, -r + x, y);
			curveTo(-r + x, -mtp8r + y, -msp4r + x, -msp4r + y);
			curveTo(-mtp8r + x, -r + y, x, -r + y);
			curveTo(mtp8r + x, -r + y, msp4r + x, -msp4r + y);
			curveTo(r + x, -mtp8r + y, r + x, y);
		}
	}
	
	
	public static function paintRectangle(
			dmc:MovieClip, 
			x:Number, 
			y:Number, 
			w:Number, 
			h:Number):Void {
		
		var w2:Number = w/2;
		var h2:Number = h/2;
		
		with (dmc) {
			moveTo(x - w2, y - h2);
			lineTo(x + w2, y - h2);
			lineTo(x + w2, y + h2);
			lineTo(x - w2, y + h2);
			lineTo(x - w2, y - h2);
		}
	}

	public static function drawInterpolatedCurve(
		dmc:MovieClip, 
		points:Array, 
		mode:String, 
		step:Number
	):Void {
		// 如果 mode 未传入，或者 mode 是 undefined 或空值，默认设置为 "bezier"
		if (mode == undefined || mode == "" || typeof mode != "string") {
			mode = "bezier";
		}
		
		// 如果 step 未传入，或者 step 是 undefined 或 NaN，默认设置为 0.01
		if (step == undefined || isNaN(step)) {
			step = 0.01;
		}

		// 确保 points 至少有两个点用于插值
		if (points.length < 2) {
			trace("点集必须至少包含两个点");
			return;
		}

		// 创建 PointSetInterpolator 实例
		var interpolator:PointSetInterpolator = new PointSetInterpolator(points, mode);

		// 获取第一个插值点，作为曲线的起始点
		var result:Object = interpolator.interpolate(0);
		
		if (result == null) {
			trace("起始插值点获取失败");
			return;
		}
		
		dmc.moveTo(result.x, result.y);  // 将绘图移动到第一个插值点
		
		// 循环生成插值点，t 从 0 递增到 1
		for (var t:Number = 0; t <= 1; t += step) {
			result = interpolator.interpolate(t);
			if (result != null) {
				// 画线到下一个插值点
				dmc.lineTo(result.x, result.y);
			} else {
				trace("插值失败，停止插值");
				break;  // 插值失败时跳出循环，防止死循环
			}
		}
	}
}
