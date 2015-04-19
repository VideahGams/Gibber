
local function DrawVignette()

	DrawMaterialOverlay("overlays/vignette01", 1)

end
 
hook.Add("RenderScreenspaceEffects", "Vignette_Overlay", DrawVignette)