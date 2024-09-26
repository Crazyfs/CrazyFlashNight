import org.flashNight.neur.Controller.PIDController;

class org.flashNight.neur.Optimizer.PIDOptimizer
{
	private var initialKp:Number;
	private var initialKi:Number;
	private var initialKd:Number;
	private var simulationFunction:Function;

	// 构造函数
	function PIDOptimizer(simulationFunc:Function, kpStart:Number, kiStart:Number, kdStart:Number)
	{
		this.simulationFunction = simulationFunc;
		this.initialKp = kpStart;
		this.initialKi = kiStart;
		this.initialKd = kdStart;
	}

	// 粗糙搜索
	private function coarseSearch():Object
	{
		var bestParams:Object = {Kp:initialKp, Ki:initialKi, Kd:initialKd, bestError:Number.MAX_VALUE};
		for (var kp:Number = 0; kp <= 10; kp += 1)
		{
			for (var ki:Number = 0; ki <= 1; ki += 0.1)
			{
				for (var kd:Number = 0; kd <= 1; kd += 0.1)
				{
					var error:Number = this.simulationFunction(kp, ki, kd);
					if (error < bestParams.bestError)
					{
						bestParams = {Kp:kp, Ki:ki, Kd:kd, bestError:error};
					}
				}
			}
		}
		return bestParams;
	}

	// 细致搜索
	private function fineSearch(coarseParams:Object):Object
	{
		var bestParams:Object = coarseParams;
		var stepSize:Number = 0.1;// 更细的调节步长
		for (var kp:Number = coarseParams.Kp - 1; kp <= coarseParams.Kp + 1; kp += stepSize)
		{
			for (var ki:Number = coarseParams.Ki - 0.05; ki <= coarseParams.Ki + 0.05; ki += stepSize)
			{
				for (var kd:Number = coarseParams.Kd - 0.05; kd <= coarseParams.Kd + 0.05; kd += stepSize)
				{
					var error:Number = this.simulationFunction(kp, ki, kd);
					if (error < bestParams.bestError)
					{
						bestParams = {Kp:kp, Ki:ki, Kd:kd, bestError:error};
					}
				}
			}
		}
		return bestParams;
	}

	// 公开的优化方法
	public function optimize():Void
	{
		var coarseResult:Object = this.coarseSearch();
		var fineResult:Object = this.fineSearch(coarseResult);
		trace("Optimized PID parameters: Kp=" + fineResult.Kp + ", Ki=" + fineResult.Ki + ", Kd=" + fineResult.Kd);
	}
}