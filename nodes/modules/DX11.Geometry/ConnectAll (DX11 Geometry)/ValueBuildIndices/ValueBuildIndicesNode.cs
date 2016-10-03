#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "BuildIndices", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueBuildIndicesNode : IPluginEvaluate
	{
		[Input("Count", DefaultValue = 1.0, IsSingle=true)]
		public IDiffSpread<int> FInput;

		[Output("Output 1")]
		public ISpread<int> FOutput1;
		
		[Output("Output 2")]
		public ISpread<int> FOutput2;

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FInput[0] < 2)
			{
				FOutput1.SliceCount = 0;
				FOutput2.SliceCount = 0;
				return;
			}
			
			if (FInput.IsChanged)
			{
				int cnt = FInput[0];
				int elementCount = 0;
				for (int i = 1; i < cnt;i++)
				{
					elementCount += i;	
				}
				FOutput1.SliceCount = elementCount;
				FOutput2.SliceCount = elementCount;
				
				int idx = 0;
				for (int i = 0; i < cnt; i++)
				{
					for (int j = (i+1); j < cnt; j++)
					{
						FOutput1[idx] = i;
						FOutput2[idx] = j;
						idx++;
					}
				}
			}	
		}
	}
}
