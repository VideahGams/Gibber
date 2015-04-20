
surface.CreateFont( "ScoreboardDefault",
{
	font		= "Helvetica",
	size		= 22,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})


--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--

local PLAYER_LINE = 
{
	Init = function( self )

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )		

		self.Name		= self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:SetTextColor(Color( 0, 0, 0, 225 ))
		self.Name:DockMargin( 8, 0, 0, 0 )

		self.Mute		= self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )

		self.Ping		= self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetTextColor(Color( 0, 0, 0, 225 ))
		self.Ping:SetContentAlignment( 5 )

		self.Deaths		= self:Add( "DLabel" )
		self.Deaths:Dock( RIGHT )
		self.Deaths:SetWidth( 50 )
		self.Deaths:SetFont( "ScoreboardDefault" )
		self.Deaths:SetTextColor(Color( 0, 0, 0, 225 ))
		self.Deaths:SetContentAlignment( 5 )

		self.Kills		= self:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 50 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetTextColor(Color( 0, 0, 0, 225 ))
		self.Kills:SetContentAlignment( 5 )

		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 5, 5, 5, 5 )

	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		self.Name:SetText( pl:Nick() )
		self.Team = self.Player:Team()

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end

		if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
			self.NumKills	=	self.Player:Frags()
			self.Kills:SetText( self.NumKills )
		end

		if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
			self.NumDeaths	=	self.Player:Deaths()
			self.Deaths:SetText( self.NumDeaths )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing	=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end

		--
		-- This is what sorts the list. The panels are docked in the z order, 
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos( (self.NumKills * -50) + self.NumDeaths )

		if self.Team ~= self.Player:Team() then
			self:Remove()
		end

	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		-- if ( self.Player:Team() == TEAM_CONNECTING ) then
		-- 	draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 200 ) )
		-- 	return
		-- end

		-- if  ( !self.Player:Alive() ) then
		-- 	draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 200, 200, 255 ) )
		-- 	return
		-- end

		-- if ( self.Player:IsAdmin() ) then
		-- 	draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 255, 230, 255 ) )
		-- 	return
		-- end

		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 155 ))

		--draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230, 255 ) )

	end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );

--
-- Here we define a new panel table for the scoreboard. It basically consists 
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = 
{
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )

		self.Logo = self.Header:Add( "DImage" )
		self.Logo:SetImage("vgui/gibberlogobig.png")  
		self.Logo:SetSize(175, 75)
		self.Logo:SetContentAlignment( 5 )
		self.Logo:SetPos((700 / 2) - (175 / 2), 0)

		self.RedPanel = self:Add("Panel")
		self.RedPanel:Dock( TOP )
		self.RedPanel:SetHeight((ScrH() - 300) / 2)
		self.RedPanel:DockMargin( 5, 5, 5, 5 )

		function self.RedPanel:Paint(w, h)

			local gradient = surface.GetTextureID("gui/gradient")

			draw.RoundedBox( 0, 0, 0, w, h, team.GetColor(1) )


			surface.SetTexture(gradient)
			surface.SetDrawColor(255,100,100,255)
			surface.DrawTexturedRectRotated( 0, h - 80, h, w * 2, 90) 

		end

		self.BluePanel = self:Add("Panel")
		self.BluePanel:Dock( TOP )
		self.BluePanel:SetHeight(((ScrH() - 300) / 2) - 15)
		self.BluePanel:DockMargin( 5, 0, 5, 0 )

		function self.BluePanel:Paint(w, h)

			local gradient = surface.GetTextureID("gui/gradient")

			draw.RoundedBox( 0, 0, 0, w, h, team.GetColor(2) )

			surface.SetTexture(gradient)
			surface.SetDrawColor(100,155,255,255)
			surface.DrawTexturedRectRotated( 0, h - 80, h + 1, w * 2, 90) 

		end

		self.versionLabel = self.Header:Add("DLabel")
		self.versionLabel:SetTextColor( Color( 0, 0, 0, 255 ) )
		self.versionLabel:SetPos( 320, 60)
		self.versionLabel:SetText( version )
		self.versionLabel:SizeToContents()



		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )

		self.RedScores = self.RedPanel:Add( "DScrollPanel" )
		self.RedScores:Dock( FILL )

		self.BlueScores = self.BluePanel:Add( "DScrollPanel" )
		self.BlueScores:Dock( FILL )

	end,

	PerformLayout = function( self )

		self:SetSize( 700, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 350, 150 )

	end,

	Paint = function( self, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 155 ) )

	end,

	Think = function( self, w, h )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			if self.RedScores ~= nil and self.BlueScores ~= nil then

				if pl:Team() == 1 then

					pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
					pl.ScoreEntry:Setup( pl )

					self.RedScores:AddItem( pl.ScoreEntry )

				elseif pl:Team() == 2 then

					pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
					pl.ScoreEntry:Setup( pl )

					self.BlueScores:AddItem( pl.ScoreEntry )

				end
			end
		end		

	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end

end


--[[---------------------------------------------------------
   Name: gamemode:HUDDrawScoreBoard( )
   Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()

end

