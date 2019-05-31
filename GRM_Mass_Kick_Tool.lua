
-- MASS KICK TOOL

-- Core Frame
GRM_UI.GRM_MassKickCoreFrame = CreateFrame( "Frame" , "GRM_MassKickCoreFrame" , UIParent , "TranslucentFrameTemplate" );
GRM_UI.GRM_MassKickCoreFrame:SetPoint ( "CENTER" , UIParent );
GRM_UI.GRM_MassKickCoreFrame:SetFrameStrata ( "HIGH" );
GRM_UI.GRM_MassKickCoreFrame:SetSize ( 600 , 465 );
GRM_UI.GRM_MassKickCoreFrame:EnableMouse ( true );
GRM_UI.GRM_MassKickCoreFrame:SetMovable ( true );
GRM_UI.GRM_MassKickCoreFrame:SetUserPlaced ( true );
GRM_UI.GRM_MassKickCoreFrame:SetToplevel ( true );
GRM_UI.GRM_MassKickCoreFrame:RegisterForDrag ( "LeftButton" );
GRM_UI.GRM_MassKickCoreFrame:SetScript ( "OnDragStart" , GRM_UI.GRM_MassKickCoreFrame.StartMoving );
GRM_UI.GRM_MassKickCoreFrame:SetScript ( "OnDragStop" , GRM_UI.GRM_MassKickCoreFrame.StopMovingOrSizing );
GRM_UI.GRM_MassKickCoreFrame:Hide();

GRM_UI.GRM_MassKickCoreFrame.GRM_MassKickCoreFrameCloseButton = CreateFrame( "Button" , "GRM_MassKickCoreFrameCloseButton" , GRM_UI.GRM_MassKickCoreFrame , "UIPanelCloseButton" );
GRM_UI.GRM_MassKickCoreFrame.GRM_MassKickCoreFrameCloseButton:SetPoint( "TOPRIGHT" , GRM_UI.GRM_MassKickCoreFrame , 3, 3 );

-- Use ESC key to exit window.
GRM_UI.GRM_MassKickCoreFrame:SetScript ( "OnKeyDown" , function ( self , key )
    self:SetPropagateKeyboardInput ( true );
    if key == "ESCAPE" then
        self:SetPropagateKeyboardInput ( false );
        self:Hide();
    end
end);