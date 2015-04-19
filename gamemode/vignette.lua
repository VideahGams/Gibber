--[[ The first line tells Garry's Mod to make a console command to control the addon with ]]--

local pp_vignette             = CreateClientConVar( "pp_vignette",                 "1",         true, false )



--[[ These lines tell Garry's Mod to draw the Vignette texture as an overlay on the screen only if the console command is enabled ]]--

function DrawVignette()

	DrawMaterialOverlay( "overlays/vignette01", 1 )
end
 
hook.Add( "RenderScreenspaceEffects", "Vignette_Overlay", DrawVignette )