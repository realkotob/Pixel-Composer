function __3dCubeFaces() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	object_counts = 6;
	
	static initModel = function() {
		
		vertex = [
			[
				new __vertex(-.5, -.5,  .5).setNormal(0, 0, 1).setUV(1, 1), 
				new __vertex( .5,  .5,  .5).setNormal(0, 0, 1).setUV(0, 0), 
				new __vertex( .5, -.5,  .5).setNormal(0, 0, 1).setUV(0, 1),
		    																  
				new __vertex(-.5, -.5,  .5).setNormal(0, 0, 1).setUV(1, 1), 
				new __vertex(-.5,  .5,  .5).setNormal(0, 0, 1).setUV(1, 0), 
				new __vertex( .5,  .5,  .5).setNormal(0, 0, 1).setUV(0, 0),
			],	
			[  
				new __vertex(-.5, -.5, -.5).setNormal(0, 0, -1).setUV(1, 1), 
				new __vertex( .5, -.5, -.5).setNormal(0, 0, -1).setUV(0, 1), 
				new __vertex( .5,  .5, -.5).setNormal(0, 0, -1).setUV(0, 0),
		    																   
				new __vertex(-.5, -.5, -.5).setNormal(0, 0, -1).setUV(1, 1), 
				new __vertex( .5,  .5, -.5).setNormal(0, 0, -1).setUV(0, 0), 
				new __vertex(-.5,  .5, -.5).setNormal(0, 0, -1).setUV(1, 0),
			],	
			[  
				new __vertex(-.5, -.5,  .5).setNormal(-1, 0, 0).setUV(1, 0), 
				new __vertex(-.5,  .5, -.5).setNormal(-1, 0, 0).setUV(0, 1), 
				new __vertex(-.5,  .5,  .5).setNormal(-1, 0, 0).setUV(0, 0),
		    																   
				new __vertex(-.5, -.5,  .5).setNormal(-1, 0, 0).setUV(1, 0), 
				new __vertex(-.5, -.5, -.5).setNormal(-1, 0, 0).setUV(1, 1), 
				new __vertex(-.5,  .5, -.5).setNormal(-1, 0, 0).setUV(0, 1),
			],	
			[  
				new __vertex( .5, -.5,  .5).setNormal(1, 0, 0).setUV(0, 0), 
				new __vertex( .5,  .5,  .5).setNormal(1, 0, 0).setUV(1, 0), 
				new __vertex( .5,  .5, -.5).setNormal(1, 0, 0).setUV(1, 1),
		    																  
				new __vertex( .5, -.5,  .5).setNormal(1, 0, 0).setUV(0, 0), 
				new __vertex( .5,  .5, -.5).setNormal(1, 0, 0).setUV(1, 1), 
				new __vertex( .5, -.5, -.5).setNormal(1, 0, 0).setUV(0, 1),
			],	
			[  
				new __vertex(-.5,  .5,  .5).setNormal(0, 1, 0).setUV(1, 0), 
				new __vertex( .5,  .5, -.5).setNormal(0, 1, 0).setUV(0, 1), 
				new __vertex( .5,  .5,  .5).setNormal(0, 1, 0).setUV(0, 0),
		    																  
				new __vertex(-.5,  .5,  .5).setNormal(0, 1, 0).setUV(1, 0), 
				new __vertex(-.5,  .5, -.5).setNormal(0, 1, 0).setUV(1, 1), 
				new __vertex( .5,  .5, -.5).setNormal(0, 1, 0).setUV(0, 1),
			],	
			[  
				new __vertex(-.5, -.5,  .5).setNormal(0, -1, 0).setUV(0, 0), 
				new __vertex( .5, -.5,  .5).setNormal(0, -1, 0).setUV(1, 0), 
				new __vertex( .5, -.5, -.5).setNormal(0, -1, 0).setUV(1, 1),
		    															   	   
				new __vertex(-.5, -.5,  .5).setNormal(0, -1, 0).setUV(0, 0), 
				new __vertex( .5, -.5, -.5).setNormal(0, -1, 0).setUV(1, 1), 
				new __vertex(-.5, -.5, -.5).setNormal(0, -1, 0).setUV(0, 1), 
			]
		];
		
		VB = build();
	} initModel();
}