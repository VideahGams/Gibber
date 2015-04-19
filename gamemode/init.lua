AddCSLuaFile( "cl_init.lua" ) --Tell the server that the client need to download cl_init.lua 
AddCSLuaFile( "shared.lua" ) --Tell the server that the client need to download shared.lua 
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "vignette.lua" )

--[[ Spawn Code ]]--

function GM:PlayerInitialSpawn( ply ) 
 
    ply:ConCommand( "gib_menu" ) 
 
	ply:SetGravity  ( 0.75 )  
    ply:SetMaxHealth( 100, true )  
 	ply:SetJumpPower( 200 )
    ply:SetWalkSpeed( 425 )  
    ply:SetRunSpeed ( 525 ) 
    
end

--[[ Remove Fall Damage ]]--

function GM:GetFallDamage( ply, speed )
 
	return 0
 
end

--[[ F4 Menu]]--
hook.Add("ShowSpare2", "SendUMSG", function(ply)

	umsg.Start("OpenMenuF4", ply)
	umsg.End()
	
end)

--[[ Team Command Setup]]--

function team_red( ply ) 

	if ply:Team() ~= 1 then
		ply:SetTeam(1) -- Make the player join red
		ply:UnSpectate()
		ply:Spawn()
		BroadcastLua('chat.AddText(Color(255, 255, 255), "' .. ply:Name() ..  ' has joined team", team.GetColor(1), " Red", Color(255, 255, 255), ".")') -- Jesus christ, broadcasting client side lua is horrible
	end

end
 
function team_blue( ply ) 

	if ply:Team() ~= 2 then
		ply:SetTeam(2) -- Make the player join blue
		ply:UnSpectate()
		ply:Spawn()
		BroadcastLua('chat.AddText(Color(255, 255, 255), "' .. ply:Name() ..  ' has joined team", team.GetColor(2), " Blue", Color(255, 255, 255), ".")')
	end

end
 
 concommand.Add( "team_red", team_red ) -- Add the command to set the players team to red
 
 concommand.Add( "team_blue", team_blue ) -- Add the command to set the players team to blue
 
 --[[ Player Loadouts ]]--
 function GM:PlayerLoadout(ply)
	
	ply:StripWeapons() 
 
	if ply:Team() == 1 then 

		ply:SetModel( "models/player/odessa.mdl" )

		ply:Give("rail_gun")

		ply:SetPlayerColor( Vector( 1,0,0 ) )

		ply:SetFOV(110, .2)

 	 	ply:EmitSound("begin.wav")

	elseif ply:Team() == 2 then 

		ply:SetModel( "models/player/odessa.mdl" )
	
		ply:Give("rail_gun")

 		ply:SetPlayerColor( Vector( 0,0.5,1 ) )

 		ply:SetFOV(110, .2)

 	 	ply:EmitSound("begin.wav")

	end
 
end

function GM:PlayerShouldTakeDamage(ply, victim)

	if ply:IsPlayer() and victim:IsPlayer() then

		if ply:Team() == victim:Team() then
			return false
		end

	end

	return true
end

local function setDeathModel(victim, killer, weapon)

	local ragdoll = victim:GetRagdollEntity()

	ragdoll:SetModel("models/Humans/Charple01.mdl")

end

local function KillCounter(victim, killer, weapon)

	if victim == killer then
		killer:SetNWInt("killcounter", killer:GetNWInt("killcounter") - 1)
	else
		killer:SetNWInt("killcounter", killer:GetNWInt("killcounter") + 1)
	end

end

local function checkForWin(victim, killer, weapon)

	local redFrags = team.TotalFrags(1)
	local blueFrags = team.TotalFrags(2)
	
	if redFrags == -10 then
		print("HURRAY")
	end

end

local function onPlayerDeath(victim, killer, weapon)

	setDeathModel(victim, killer, weapon)
	KillCounter(victim, killer, weapon)
	checkForWin(victim, killer, weapon)

end

hook.Add("PlayerDeath", "onPlayerGibbed", onPlayerDeath)