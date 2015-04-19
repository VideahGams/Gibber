

EFFECT.Mat = Material( "puff" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	 = data:GetStart()
	self.Normal		 = data:GetNormal()
	self.LifeTime 	 = CurTime() + 1
	self.sizeAdjust  = 10
	self.alpha = 0
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	if CurTime() > self.LifeTime then return false end
	self.sizeAdjust = self.sizeAdjust + 1
	self.alpha = self.alpha + 5
	return true
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	render.SetMaterial( self.Mat )

	render.DrawQuadEasy( self.StartPos, //position of the rect
						 self.Normal, //direction to face in
						 self.sizeAdjust, self.sizeAdjust, //size of the rect
						 Color( 255,255,255,255*(1/self.alpha) ) //color...
					   ) 
end
