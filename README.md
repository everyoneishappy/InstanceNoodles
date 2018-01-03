# InstanceNoodles
Alpha 0.4 Tsukemen

Instance Noodles is a modular patching system for Compute & Geometry shaders in DX11/vvvv. Inspired by the fast & pleasant workflow in stock vvvv this lib aims to bring the same visual flow programming approach to GPGPU calculations & procedural geometry manipulation.

In 0.4 there are some new nodes, eg Subdivision (DX11.GeomFX), compute Zips, a nice LineBuffered(DX11.Layer) module (courtesy of Dávid “Microdee” Morass) and some general improvements such as adding a (hidden) thread group size pin and modernizing the default group size to 128 on all compute nodes.  +Quite a few other bits & bobs I’m too lazy to list.  Note that the pack now depends on ‘happy.fxh’ to be next to it in /packs in order to work.

Requires 
•	vvvv >= 35.7 + Addon Pack
•	DX11 pack >= 1.1
•	happy.fxh
•	a GPU that supports Shader Model 5. 
To install everything via VPM: https://vvvvpm.github.io/#InstanceNoodles
To install manually just place in /packs folder.  
For more frequent updates, bug fixes and issue reporting: https://github.com/everyoneishappy/InstanceNoodles

Substantial amounts of code borrowed from Vux, UNC, Microdee et al. If there is something that should be credited that's not just let me know.

MIT License- feel free to use in your creative & commercial projects.  If used in production a credit is very appreciated: 
[Kyle McLean] / [everyoneishappy.com]
I’m also very happy if you are doing something interesting and want to employ me on a project basis.


