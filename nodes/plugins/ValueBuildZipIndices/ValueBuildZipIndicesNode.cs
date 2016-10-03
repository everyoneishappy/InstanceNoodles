#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "BuildZipIndices", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueBuildZipIndicesNode : IPluginEvaluate
	{
		[Input("Input 1 Bin Size", DefaultValue = 1.0)]
		public IDiffSpread<int> FBin1;
		
		[Input("Input 2 Bin Size", DefaultValue = 1.0)]
		public IDiffSpread<int> FBin2;
		
		[Input("Count", DefaultValue = 1.0, IsSingle = true)]
		public IDiffSpread<int> FCount;

		[Output("Index Buffer A")]
		public ISpread<int> FOutput1;

		[Output("Index Buffer B")]
		public ISpread<int> FOutput2;
		
		[Output("Updated", IsSingle = true)]
		public ISpread<bool> FUpdate;

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FCount[0] < 2) {
				FOutput1.SliceCount = 0;
				FOutput2.SliceCount = 0;
				return;
			}

			if (FCount.IsChanged || FBin1.IsChanged || FBin2.IsChanged) 
			{
				FUpdate[0] = true;
				int cnt = FCount[0];
				FOutput1.SliceCount = cnt;
				FOutput2.SliceCount = cnt;
			
				int index = 0; 
				int bufferAIndex = 0;
				int bufferBIndex = 0;
				int binIndex = 0;
				
				while (index < cnt)
				{
					int bin1 = FBin1[binIndex];
					int bin2 = FBin2[binIndex];
					
					for (int i = 0; i < bin1; i++)
					{
						FOutput1[index] = bufferAIndex;
						FOutput2[index] = -1;
						index ++;
						bufferAIndex ++;
					}
					
					for (int j = 0; j < bin2 && index < cnt; j++) 
					{
						FOutput1[index] = -1;
						FOutput2[index] = bufferBIndex;
						index ++;
						bufferBIndex ++;
					}
					binIndex++;
				}
			}
			else FUpdate[0] = false;
			
			
		}
	}
}
