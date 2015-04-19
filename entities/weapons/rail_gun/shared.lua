if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
	
end
SWEP.HoldType			= "ar2"
if ( CLIENT ) then

	SWEP.PrintName			= "Rail Gun"			
	SWEP.Author				= "Ruairidh Carmichael"

	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 65
	SWEP.IconLetter			= "x"
	SWEP.DrawCrosshair		= true
end
-----------------------Main functions----------------------------
 
-- function SWEP:Reload() --To do when reloading
-- end 

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation

end


function SWEP:DrawHUD()
	surface.SetTexture(surface.GetTextureID("sprites/tf_crosshair_01"))
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( ScrW()/2 - 13, ScrH()/2 - 13, 25, 25 )
end
 
function SWEP:Think() -- Called every frame
	if SERVER then
		if self.Owner:KeyDown(IN_ATTACK2) then
			self.Owner:SetFOV(45, .1)
		end
		if self.Owner:KeyReleased(IN_ATTACK2) then
			self.Owner:SetFOV(110, .2)
		end
	end
end

function SWEP:Equip()
	if SERVER then
		if self.Owner:IsPlayer() then 
			self.Owner:GiveAmmo(1000, "GaussEnergy")
		end
	end
end


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	
end

function SWEP:PrimaryAttack()
	
	--ply = LocalPlayer()
	
	local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10^14
		trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	
	local vAng = (tr.HitPos-self.Owner:GetShootPos()):GetNormal():Angle()
	
	if self.Owner:GetAmmoCount("GaussEnergy") == 0 then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:ShootBullet( 1000, 1, 0.0 )
	self.Owner:ViewPunch( Angle( -2, 0, 0 ) )
	self:ShootEffects()
	--print(vAng)
	for k, v in pairs(ents.FindInSphere(tr.HitPos, 70)) do
		if v == self.Owner then
			if tr.HitNormal == Vector(0,0,1) then
				self.Owner:SetVelocity(self.Owner:GetAimVector()*-500)
				print(tr.HitNormal)
			end
		end
	end	


	
	
	
	
	local dmginfo = DamageInfo();
	dmginfo:SetDamage( 100 );
	dmginfo:SetAttacker( self:GetOwner() );
	dmginfo:SetInflictor( self );
	
	if( dmginfo.SetDamageType ) then
		dmginfo:SetDamagePosition( tr.HitPos );
		dmginfo:SetDamageType( DMG_ENERGYBEAM  );
	end
	
	tr.Entity:DispatchTraceAttack( dmginfo, tr.HitPos, tr.HitPos - vAng:Forward() * 20 );
	
	tr.Entity:SetKeyValue("targetname", "disTarg")
	//local dis = ents.Create("env_entity_dissolver")
	--dis:SetPos(tr.Entity)
	//dis:SetKeyValue("magnitude", "5")
	//dis:SetKeyValue("dissolvetype", "0")
	//dis:SetKeyValue("target", "disTarg")
	//dis:Spawn()
	//dis:Fire("Dissolve", "disTarg", 0)
	//dis:Fire("kill", "", 0)

	local effect = EffectData()
		effect:SetStart(self.Owner:GetShootPos()+self.Owner:EyeAngles():Forward()*20+self.Owner:EyeAngles():Up()*-6+self.Owner:EyeAngles():Right()*5)
		effect:SetOrigin(tr.HitPos)
		effect:SetAngles(self.Owner:EyeAngles())
	if self.Owner:Team() == 1 then
		util.Effect("Rail_Spiral_Red", effect)
	elseif self.Owner:Team() == 2 then
		util.Effect("Rail_Spiral_Blue", effect)
	end
	util.Effect("AR2Impact", effect)
	util.Effect("CommandPointer", effect)
	local effect2 = EffectData()
		effect2:SetStart(tr.HitPos)
		effect2:SetNormal(tr.HitNormal)
	util.Effect("Rail_Puff", effect2)
	local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
	util.Decal("FadingScorch", hit1, hit2)
	self:EmitSound("railgun.wav")
end

function SWEP:SecondaryAttack()

end



function SWEP:ShootBullet( damage, num_bullets, aimcone )
	
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 0									// Show a tracer on every x bullets 
	bullet.Force	= 10								// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	bullet.HullSize = 2
	bullet.TracerName = "Rail_Spiral_Red"
	
	self.Owner:FireBullets( bullet )
	
	--self:ShootEffects()
	
end



-------------------------------------------------------------------

------------General Swep Info---------------
SWEP.Author   = "Ruairidh Carmichael"
SWEP.Contact        = ""
SWEP.Purpose        = ""
SWEP.Instructions   = ""
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.DrawAmmo = false
SWEP.Instructions = "Fire like fuck."
-----------------------------------------------

------------Models---------------------------
SWEP.ViewModel      = "models/weapons/v_IRifle.mdl"
SWEP.WorldModel   = ""
SWEP.ViewModelFOV = 30
SWEP.AnimPrefix		= "python"
-----------------------------------------------

-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.Delay			= 1 	--In seconds
SWEP.Primary.Recoil			= 0		--Gun Kick
SWEP.Primary.Damage			= 200	--Damage per Bullet
SWEP.Primary.NumShots		= 1		--Number of shots per one fire
SWEP.Primary.Cone			= 0 	--Bullet Spread
SWEP.Primary.ClipSize		= -1	--Use "-1 if there are no clips"
SWEP.Primary.DefaultClip	= 10	--Number of shots in next clip
SWEP.Primary.Automatic   	= true	--Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= "GaussEnergy"	--Ammo Type
-------------End Primary Fire Attributes------------------------------------
 
-------------Secondary Fire Attributes-------------------------------------
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"
-------------End Secondary Fire Attributes--------------------------------
