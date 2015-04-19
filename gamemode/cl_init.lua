include( "shared.lua" )
include( "vignette.lua" )
include( "cl_scoreboard.lua" )

--[[ Global Variables ]]--

gradient = surface.GetTextureID("gui/gradient");
version = "Alpha 0.1"

ScreenW = ScrW() / 2
ScreenH = ScrH() / 2

surface.CreateFont( "VideahFont",
{
	font		= "Helvetica",
	size		= 52,
	weight		= 800
})

--[[ Avatar ]] --
local avatarX = ScreenW - 35 --Centre RoundedBox as RoundedBox's position is not centred.
local avatarY = 25

local Avatar = vgui.Create("AvatarImage")
Avatar:SetPos(avatarX + 3, avatarY + 3)
Avatar:SetSize(64, 64)
print("Created Avatar.")

--[[ The Menu ]]--
function GibMenu()

	Avatar:SetPlayer(LocalPlayer(), 43)

	local frame = vgui.Create( "DFrame" )
	local PropertySheet = vgui.Create( "DPropertySheet" )

	local teamPanel = vgui.Create( "DPanel" )
	local aboutPanel = vgui.Create( "DPanel" )

	local vsImage = vgui.Create("DImage", teamPanel)

	local redButton = vgui.Create( "DButton", teamPanel )
	local blueButton = vgui.Create( "DButton", teamPanel )

	local versionLabel = vgui.Create( "DLabel", aboutPanel )
	local gibLogo = vgui.Create( "DImage", aboutPanel )

	local frameW = 600
	local frameH = 425

	frame:SetPos(ScreenW - frameW / 2, ScreenH - frameH / 2)
	frame:SetSize( frameW, frameH )
	frame:SetTitle( "Gibber ".. version )
	frame:SetVisible( true )
	frame:SetDraggable( true )
	frame:MakePopup()

	if LocalPlayer():Team() == 0 then -- No Team
		frame:ShowCloseButton(false)
	else
		frame:ShowCloseButton(true)
	end

	function frame:Paint(w, h)

		draw.RoundedBox(0,0,0, w, h, Color( 155, 0, 0))
		surface.SetTexture(gradient)
		surface.SetDrawColor(255,100,100,255) -- So it draws in normal color.
		surface.DrawTexturedRectRotated( w / 2, h / 2, 500, 700,90) -- Note: Rotation is ANTI-CLOCKWISE.
		
	end
		
	PropertySheet:SetParent( frame )
	PropertySheet:SetPos( 5, 30 )
	PropertySheet:SetSize( frameW - 10, frameH - 35 )

	teamPanel:SetPos( 10, 30)
	teamPanel:SetSize( 200, 300)

	aboutPanel:SetPos( 10, 30)
	aboutPanel:SetSize( 200, 300)

	function PropertySheet:Paint(w, h)
	
		draw.RoundedBox(0,0,0, w, h , Color( 175, 55, 55))
		
	end

	redButton:SetPos( 10, 10 )
	redButton:SetText("") 
	redButton:SetSize(200,335)
	redButton.DoClick = function() -- Make the player join team red

		RunConsoleCommand( "team_red" ) 
		frame:Close()

	end

	blueButton:SetPos( 365, 10 ) 
	blueButton:SetText("")
	blueButton:SetSize(200,335)  
	blueButton.DoClick = function() -- Make the player join team blue

		RunConsoleCommand( "team_blue" ) 
		frame:Close()

	end


	function redButton:Paint(w, h)
	
		draw.RoundedBox(0,0,0, w, h , Color( 175, 55, 55))
		surface.SetTexture(gradient)
		surface.SetDrawColor(255,100,100,255)
		surface.DrawTexturedRectRotated( w / 2, h / 2 + 80, w, h,90) -- Note: Rotation is ANTI-CLOCKWISE.
		surface.SetDrawColor(255,255,255,255)
		draw.DrawText("Red", "VideahFont", w / 2, (h / 2) - (52 / 2), Color(255,255,255,255), 1)

		
	end
	
	function blueButton:Paint(w, h)
	
		draw.RoundedBox(0,0,0, w, h , Color( 56, 92, 120, 255))
		surface.SetTexture(gradient)
		surface.SetDrawColor(100,155,255,255)
		surface.DrawTexturedRectRotated( w / 2, h / 2 + 80, w, h,90) -- Note: Rotation is ANTI-CLOCKWISE.
		draw.DrawText("Blue", "VideahFont", w / 2, (h / 2) - (52 / 2), Color(255,255,255,255), 1)
		
	end

	vsImage:SetImage( "vgui/vs.png" )  
	vsImage:SetSize(128, 128)
	vsImage:SetPos(220, 110)

	versionLabel:SetPos( 320, 60)
	versionLabel:SetText( version )
	versionLabel:SizeToContents()
	versionLabel:SetDark( 1 )

	gibLogo:SetImage( "vgui/gibberlogo.png" )  
	gibLogo:SetSize(175, 75)
	gibLogo:SetPos(190, 0)

	PropertySheet:AddSheet("Team Select", teamPanel, nil, false, false)
	PropertySheet:AddSheet("About", aboutPanel, nil, false, false)

	for k, v in pairs(PropertySheet.Items) do -- Style the tabs.
		if (!v.Tab) then continue end

		v.Tab.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(175, 55, 55))
			if v.Tab == PropertySheet:GetActiveTab() then
				draw.RoundedBox(0, 0, 0, w, h, Color(235, 75, 75))
			end
		end
	end

end

concommand.Add( "gib_menu", GibMenu ) 

--[[Hide Hude]]--
function hideHud(name)

    for k, v in pairs{"CHudHealth", "CHudBattery", "CHudSecondaryAmmo", "CHudAmmo", "CHudWeaponSelection"} do
	
        if name == v then return false end
		
	end

end

hook.Add("HUDShouldDraw", "hidehud", hideHud)

--[[ F4 Menu ]]--
usermessage.Hook("OpenMenuF4", function(um)

	RunConsoleCommand( "gib_menu" ) 
	
end)

--[[ HUD ]]--

local redX = ScreenW - 35 - 100
local redY = 25

local bluX = ScreenW - 35 + 100
local bluY = 25

function ScoreHUD()

	local ply = LocalPlayer()
	
	draw.RoundedBox( 0, redX - 5, redY - 5, 80, 80, Color( 255, 255, 255, 155)) --WhiteRed
	draw.RoundedBox( 0, redX, redY, 70, 70, Color( 157, 48, 47, 255)) --Red
	
	draw.RoundedBox( 0, bluX - 5, bluY - 5, 80, 80, Color( 255, 255, 255, 155)) --WhiteBlue
	draw.RoundedBox( 0, bluX, bluY, 70, 70, Color( 56, 92, 120, 255)) --Blue
	
	local TCOLOR = team.GetColor( ply:Team() )
	
	if ply:Team() == 0 then
		TCOLOR = Color(255, 255, 255, 255)
	end

	draw.RoundedBox( 0, avatarX - 5, avatarY - 5, 80, 95, Color( 255, 255, 255, 155)) --AvatarWhite
	draw.RoundedBox( 0, avatarX, avatarY, 70, 70, TCOLOR) --AvatarColor
	
	local gradient = surface.GetTextureID("gui/gradient"); -- No file types.
	
	surface.SetTexture(gradient)
	surface.SetDrawColor(255,100,100,255) -- So it draws in normal color.
	surface.DrawTexturedRectRotated( redX + 35, redY + 35, 70, 70,90) -- Note: Rotation is ANTI-CLOCKWISE.
	
	surface.SetTexture(gradient)
	surface.SetDrawColor(100,155,255,255) -- So it draws in normal color.
	surface.DrawTexturedRectRotated( bluX + 35, bluY + 35, 70, 70,90) -- Note: Rotation is ANTI-CLOCKWISE.
	surface.SetTexture(gradient)

	if ply:Team() == 1 then
		surface.SetDrawColor(255,100,100,255) 
		
	elseif ply:Team() == 2 then
		surface.SetDrawColor(100,155,255,255) 
		
	else
		surface.SetDrawColor(200,200,200,255)
		
	end
	
	surface.DrawTexturedRectRotated( avatarX + 35, avatarY + 35, 70, 70,90) 
		
end

function drawKillCounter()  

	draw.WordBox( 8, avatarX + 6, avatarY + 65, "Kills: " .. LocalPlayer():GetNWInt("killcounter"), "Trebuchet18", Color(200,0,0,0), Color(0,0,0,225))  
	draw.DrawText(team.TotalFrags(1), "VideahFont", redX + 35, redY + 10, Color(255,255,255,255), 1)
	draw.DrawText(team.TotalFrags(2), "VideahFont", bluX + 35, bluY + 10, Color(255,255,255,255), 1)

end  

hook.Add("HUDPaint", "drawKillCounter", drawKillCounter)
hook.Add("HUDPaint", "ScoreHUD", ScoreHUD)