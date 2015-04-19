

EFFECT.Mat = Material( "cable/redlaser" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	 = data:GetStart()
	self.EndPos 	 = data:GetOrigin()
	self.Angles		 = data:GetAngles()
	self.LifeTime = CurTime() + 1.5
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	if CurTime() > self.LifeTime then return false end

	return true
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	render.SetMaterial( self.Mat )

	local StartPos = self.StartPos;
	local EndPos = self.EndPos;
	local Ang = (EndPos-StartPos):GetNormal():Angle()
	local Forward	= Ang:Forward();
	local Right 	= Ang:Right();
	local Up 		= Ang:Up();
	local Distance 	= StartPos:Distance(EndPos);
	local StepSize  = 10;
	local RingTightness = 2;
	local LastPos;
	for i=1, Distance, StepSize do
		local sin = math.sin( math.rad( i * RingTightness ) ) ;
		local cos = math.cos( math.rad( i * RingTightness ) );
		local Pos = StartPos+(Forward*i)+(Up*sin*2)+(Right*cos*2);
		if LastPos then
			render.DrawBeam(LastPos,Pos,5,0,0,Color(1,1,1,255))
		end
		LastPos = Pos
		if (i >= Distance - StepSize) then
			local adjustPos = Pos - (Up*sin*2)-(Right*cos*2);
			render.DrawBeam(StartPos, adjustPos, 5, 0, 1, Color(255,255,255,255));
		end
	end
end
