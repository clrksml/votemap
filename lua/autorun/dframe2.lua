if !CLIENT then return end

PANEL = {}

AccessorFunc( PANEL, "m_bIsMenuComponent", 		"IsMenu", 			FORCE_BOOL )
AccessorFunc( PANEL, "m_bDraggable", 			"Draggable", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable", 				"Sizable", 			FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock", 			"ScreenLock", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bDeleteOnClose", 		"DeleteOnClose", 	FORCE_BOOL )
AccessorFunc( PANEL, "m_bPaintShadow", 			"PaintShadow", 		FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth", 			"MinWidth" )
AccessorFunc( PANEL, "m_iMinHeight", 			"MinHeight" )

function PANEL:Init()
	self:SetFocusTopLevel( true )
	self:SetPaintShadow( true )
	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetScreenLock( false )
	self:SetDeleteOnClose( true )
	self:SetMinWidth( 50 );
	self:SetMinHeight( 50 );
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self.m_fCreateTime = SysTime()
	self:DockPadding( 5, 24 + 5, 5, 5 )
end

function PANEL:Close()
	self:SetVisible( false )
	
	if ( self:GetDeleteOnClose() ) then
		self:Remove()
	end
	
	self:OnClose()
end

function PANEL:OnClose()

end

function PANEL:Center()
	self:InvalidateLayout( true )
	self:SetPos( ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2 )
end

function PANEL:Think()
	local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )
	
	if ( self.Dragging ) then
		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]
		
		if ( self:GetScreenLock() ) then
			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		end
		self:SetPos( x, y )
	end
	
	if ( self.Sizing ) then
		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()
		
		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW() - px and self:GetScreenLock() ) then x = ScrW() - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH() - py and self:GetScreenLock() ) then y = ScrH() - py end
		
		self:SetSize( x, y )
		self:SetCursor( "sizenwse" )
		return
	end

	if ( self.Hovered &&
		 self.m_bSizable &&
		 mousex > (self.x + self:GetWide() - 20) &&
		 mousey > (self.y + self:GetTall() - 20) ) then	
		self:SetCursor( "sizenwse" )
		return
	end

	if ( self.Hovered && self:GetDraggable() && mousey < (self.y + 24) ) then
		self:SetCursor( "sizeall" )
		return
	end

	self:SetCursor( "arrow" )

	if ( self.y < 0 ) then
		self:SetPos( self.x, 0 )
	end
end

function PANEL:Paint( w, h )
	Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	
	derma.SkinHook( "Paint", "Frame", self, w, h )
	return true
end

function PANEL:OnMousePressed()
	if ( self.m_bSizable ) then
		if ( gui.MouseX() > (self.x + self:GetWide() - 20) &&
			gui.MouseY() > (self.y + self:GetTall() - 20) ) then
			self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
			self:MouseCapture( true )
			return
		end
	end
	
	if ( self:GetDraggable() && gui.MouseY() < (self.y + 24) ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )
end

function PANEL:PerformLayout()
end

function PANEL:IsActive()
	if ( self:HasFocus() ) then return true end
	if ( vgui.FocusedHasParent( self ) ) then return true end
	return false
end

derma.DefineControl( "DFrame2", "A simpe window", PANEL, "EditablePanel" )