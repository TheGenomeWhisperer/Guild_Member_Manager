-- Author: TheGenomeWhisperer (Arkaan)

-- Guild Roster Manager UI
-- Fully built in Lua, as to avoid building an XML UI. I initially started building it in Lua as a proof-of-concept to see how powerful the tools were. I was not disappointed.

------------------------
------ FRAMES ----------
------------------------
--------------------------------------
---- UI BUILDING COMPLETELY IN LUA ---
---- FRAMES, FONTS, STYLES, ETC. -----
--------------------------------------

-- Contains the entire UI initialization of frames (no logic details yet)
GRM_UI = {};

-- Just controls for reloading in ElvUI in case of language chain which rebuilds the UI in new language.
GRM_UI.ElvUIReset = false;
GRM_UI.ElvUIReset2 = false;

-- Core Frame
GRM_UI.GRM_MemberDetailMetaData = CreateFrame( "Frame" , "GRM_MemberDetailMetaData" , GuildRosterFrame , "TranslucentFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton = CreateFrame( "Button" , "GRM_MemberDetailMetaDataCloseButton" , GRM_UI.GRM_MemberDetailMetaData , "UIPanelCloseButton");
GRM_UI.GRM_MemberDetailMetaData:Hide();  -- Prevent error where it sometimes auto-loads.

-- Guild Member Detail Frame UI and Children
GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton = CreateFrame ( "Button" , "GRM_SetPromoDateButton" , GRM_UI.GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton.GRM_SetPromoDateButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:CreateFontString ( "GRM_SetPromoDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_DayDropDownMenuSelected" , GRM_UI.GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText = GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:CreateFontString ( "GRM_DayText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu = CreateFrame ( "Frame" , "GRM_DayDropDownMenu" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected , "InsetFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownButton = CreateFrame ( "Button" , "GRM_DayDropDownButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_YearDropDownMenuSelected" , GRM_UI.GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText = GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:CreateFontString ( "GRM_YearText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu = CreateFrame ( "Frame" , "GRM_YearDropDownMenu" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected , "InsetFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownButton = CreateFrame ( "Button" , "GRM_YearDropDownButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_MonthDropDownMenuSelected" , GRM_UI.GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText = GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:CreateFontString ( "GRM_MonthText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu = CreateFrame ( "Frame" , "GRM_MonthDropDownMenu" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected , "InsetFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownButton = CreateFrame ( "Button" , "GRM_MonthDropDownButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

-- SUBMIT BUTTONS
GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton = CreateFrame ( "Button" , "GRM_DateSubmitButton" , GRM_UI.GRM_MemberDetailMetaData , "UIPanelButtonTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton = CreateFrame ( "Button" , "GRM_DateSubmitCancelButton" , GRM_UI.GRM_MemberDetailMetaData , "UIPanelButtonTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt = GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:CreateFontString ( "GRM_DateSubmitButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButtonTxt = GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:CreateFontString ( "GRM_DateSubmitCancelButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );
-- Fontstring for MemberRank History 
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton = CreateFrame ( "Button" , "GRM_MemberDetailJoinDateButton" , GRM_UI.GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:CreateFontString ( "GRM_MemberDetailJoinDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_JoinDateText" , "OVERLAY" , "GameFontWhiteTiny" );
-- if player doesn't know their join date or promo date.
GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton = CreateFrame ( "Button" , "GRM_SetUnknownButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton , "GameMenuButtonTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton.GRM_SetUnknownButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton:CreateFontString ( "GRM_SetUnknownButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- Normal frame translucent
GRM_UI.noteBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 18,
    insets = { left = 5 , right = 5 , top = 5 , bottom = 5 }
}

-- Thinnner frame translucent template
GRM_UI.noteBackdrop2 = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 9,
    insets = { left = 2 , right = 2 , top = 3 , bottom = 2 }
}

GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow = CreateFrame( "Frame" , "GRM_PlayerNoteWindow" , GRM_UI.GRM_MemberDetailMetaData );
GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1 = GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow:CreateFontString ( "GRM_noteFontString1" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerNoteEditBox" , GRM_UI.GRM_MemberDetailMetaData );
GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow = CreateFrame( "Frame" , "GRM_PlayerOfficerNoteWindow" , GRM_UI.GRM_MemberDetailMetaData );
GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2 = GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow:CreateFontString ( "GRM_noteFontString2" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerOfficerNoteEditBox" , GRM_UI.GRM_MemberDetailMetaData );
GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_NoteCount" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:Hide();

-- Populating Frames with FontStrings
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailNameText" , "OVERLAY" , "GameFontNormalLarge" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMainText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLevel" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailRankTxt" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailRankDateTxt" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailNoteTitle" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailONoteTitle" , "OVERLAY" , "GameFontNormalSmall" );

-- LAST ONLINE
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTitleTxt = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLastOnlineTitleTxt" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLastOnlineTxt" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailDateJoinedTitleTxt" , "OVERLAY" , "GameFontNormalSmall" );

-- STATUS TEXT
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailPlayerStatus" , "OVERLAY" , "GameFontNormalSmall" );

-- ZONEINFORMATION
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoZoneText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1 = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoTimeText1" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2 = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoTimeText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- GROUP INVITE 
GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton = CreateFrame ( "Button" , "GRM_GroupInviteButton" , GRM_UI.GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:CreateFontString ( "GRM_GroupInviteButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- Tooltips
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailRankToolTip" , GRM_UI.GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailJoinDateToolTip" , GRM_UI.GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailServerNameToolTip" , GRM_UI.GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailNotifyStatusChangeTooltip" , GRM_UI.GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:Hide();
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailNJDSyncTooltip" , GRM_UI.GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:Hide();

--Sync Join Date Side Frame Options
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame = CreateFrame ( "Frame" , "GRM_SyncJoinDateSideFrame" , GRM_UI.GRM_MemberDetailMetaData , "TranslucentFrameTemplate" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_SyncJoinDateText = GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:CreateFontString ( "GRM_SyncJoinDateText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton = CreateFrame ( "Button" , "GRM_JDMainButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame  );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton:CreateFontString ( "GRM_JDMainButtonText" , "OVERLAY" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButton = CreateFrame ( "Button" , "GRM_JDSelectedPlayerButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame  );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButton:CreateFontString ( "GRM_JDSelectedPlayerButtonText" , "OVERLAY" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton = CreateFrame ( "Button" , "GRM_JDOldestButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame  );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton:CreateFontString ( "GRM_JDOldestButtonText" , "OVERLAY" );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton = CreateFrame ( "Button" , "GRM_JDSyncCancelButton" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame  );
GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButtonText = GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton:CreateFontString ( "GRM_JDSyncCancelButtonText" , "OVERLAY" );

-- CUSTOM POPUPBOX FOR REUSE -- Avoids all possibility of UI Taint by just building my own, for those that use a lot of addons.
GRM_UI.GRM_PopupWindow = CreateFrame ( "Frame" , "GRM_PopupWindow" , StaticPopup1 , "TranslucentFrameTemplate" );
GRM_UI.GRM_PopupWindow:Hide() -- Prevents it from autopopping up on load like it sometimes will.
GRM_UI.GRM_PopupWindowCheckButton1 = CreateFrame ( "CheckButton" , "GRM_PopupWindowCheckButton1" , GRM_UI.GRM_PopupWindow , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_PopupWindowCheckButtonText = GRM_UI.GRM_PopupWindowCheckButton1:CreateFontString ( "GRM_PopupWindowCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

GRM_UI.GRM_PopupWindowCheckButton2 = CreateFrame ( "CheckButton" , "GRM_PopupWindowCheckButton2" , GRM_UI.GRM_PopupWindow , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_PopupWindowCheckButton2Text = GRM_UI.GRM_PopupWindowCheckButton2:CreateFontString ( "GRM_PopupWindowCheckButton2Text" , "OVERLAY" , "GameFontNormalSmall" );

-- EDIT BOX FOR ANYTHING ( like banned player note );
GRM_UI.GRM_MemberDetailEditBoxFrame = CreateFrame ( "Frame" , "GRM_MemberDetailEditBoxFrame" , GRM_UI.GRM_PopupWindow , "TranslucentFrameTemplate" );
GRM_UI.GRM_MemberDetailEditBoxFrame:Hide();
GRM_UI.GRM_MemberDetailPopupEditBox = CreateFrame ( "EditBox" , "GRM_MemberDetailPopupEditBox" , GRM_UI.GRM_MemberDetailEditBoxFrame );

-- Banned Fontstring and Buttons
GRM_UI.GRM_MemberDetailBannedText1 = GRM_UI.GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailBannedText1" , "OVERLAY" , "GameFontNormalSmall");
GRM_UI.GRM_MemberDetailBannedIgnoreButton = CreateFrame ( "Button" , "GRM_MemberDetailBannedIgnoreButton" , GRM_UI.GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_UI.GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText = GRM_UI.GRM_MemberDetailBannedIgnoreButton:CreateFontString ( "GRM_MemberDetailBannedIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- ALT FRAMES!!!
GRM_UI.GRM_CoreAltFrame = CreateFrame( "Frame" , "GRM_CoreAltFrame" , GRM_UI.GRM_MemberDetailMetaData );
GRM_UI.GRM_CoreAltFrame:Hide(); -- No need to show initially. Occasionally on init. it would popup the title text. Just keep hidden with init.
GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_CoreAltScrollFrame" , GRM_UI.GRM_CoreAltFrame );

-- CONTENT ALT FRAME (Child Frame)
GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame = CreateFrame ( "Frame" , "GRM_CoreAltScrollChildFrame" );
-- SLIDER
GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider = CreateFrame ( "Slider" , "GRM_CoreAltScrollFrameSlider" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame , "UIPanelScrollBarTemplate" );
-- ALT HEADER
GRM_UI.GRM_altFrameTitleText = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_altFrameTitleText" , "OVERLAY" , "GameFontNormalSmall" );
-- ALT OPTIONSFRAME
GRM_UI.GRM_altDropDownOptions = CreateFrame ( "Frame" , "GRM_altDropDownOptions" , GRM_UI.GRM_MemberDetailMetaData );
GRM_UI.GRM_altDropDownOptions:Hide();
GRM_UI.GRM_altOptionsText = GRM_UI.GRM_altDropDownOptions:CreateFontString ( "GRM_altOptionsText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_altOptionsDividerText = GRM_UI.GRM_altDropDownOptions:CreateFontString ( "GRM_altOptionsDividerText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT BUTTONS
GRM_UI.GRM_AddAltButton = CreateFrame ( "Button" , "GRM_AddAltButton" , GRM_UI.GRM_CoreAltFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_AddAltButtonText = GRM_UI.GRM_AddAltButton:CreateFontString ( "GRM_AddAltButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_AddAltButton2 = CreateFrame ( "Button" , "GRM_AddAltButton2" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_AddAltButton2Text = GRM_UI.GRM_AddAltButton2:CreateFontString ( "GRM_AddAltButton2Text" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_altSetMainButton = CreateFrame ( "Button" , "GRM_altSetMainButton" , GRM_UI.GRM_altDropDownOptions  );
GRM_UI.GRM_altSetMainButtonText = GRM_UI.GRM_altSetMainButton:CreateFontString ( "GRM_altSetMainButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_altRemoveButton = CreateFrame ( "Button" , "GRM_altRemoveButton" , GRM_UI.GRM_altDropDownOptions );
GRM_UI.GRM_altRemoveButtonText = GRM_UI.GRM_altRemoveButton:CreateFontString ( "GRM_altRemoveButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_altFrameCancelButton = CreateFrame ( "Button" , "GRM_altFrameCancelButton" , GRM_UI.GRM_altDropDownOptions );
GRM_UI.GRM_altFrameCancelButtonText = GRM_UI.GRM_altFrameCancelButton:CreateFontString ( "GRM_altFrameCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT NAMES (If I end up running short on FontStrings, I may need to convert to use static buttons.)
GRM_UI.GRM_CoreAltFrame.GRM_AltName1 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName1" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName2 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName3 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName3" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName4 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName4" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName5 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName5" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName6 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName6" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName7 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName7" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName8 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName8" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName9 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName9" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName10 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName10" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName11 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName11" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AltName12 = GRM_UI.GRM_CoreAltFrame:CreateFontString ( "GRM_AltName12" , "OVERLAY" , "GameFontNormalSmall" );
-- ADD ALT EDITBOX Frame
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame = CreateFrame ( "Frame" , "GRM_AddAltEditFrame" , GRM_UI.GRM_CoreAltFrame , "TranslucentFrameTemplate" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltTitleText = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltTitleText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox = CreateFrame ( "EditBox" , "GRM_AddAltEditBox" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame , "InputBoxTemplate" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1 = CreateFrame ( "Button" , "GRM_AddAltNameButton1" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2 = CreateFrame ( "Button" , "GRM_AddAltNameButton2" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3 = CreateFrame ( "Button" , "GRM_AddAltNameButton3" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4 = CreateFrame ( "Button" , "GRM_AddAltNameButton4" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5 = CreateFrame ( "Button" , "GRM_AddAltNameButton5" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6 = CreateFrame ( "Button" , "GRM_AddAltNameButton6" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:CreateFontString ( "GRM_AddAltNameButton1" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:CreateFontString ( "GRM_AddAltNameButton2" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:CreateFontString ( "GRM_AddAltNameButton3" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:CreateFontString ( "GRM_AddAltNameButton4" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:CreateFontString ( "GRM_AddAltNameButton5" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:CreateFontString ( "GRM_AddAltNameButton6" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameTextBottom" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameHelpText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2 = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameHelpText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- CORE GUILD LOG EVENT FRAME!!!
GRM_UI.GRM_RosterChangeLogFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogFrame" , UIParent , "BasicFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame:Hide();
-- Log Frame
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame = CreateFrame ( "Frame" , "GRM_LogFrame" , GRM_UI.GRM_RosterChangeLogFrame );
-- Options Frame
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame = CreateFrame ( "Frame" , "GRM_OptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame = CreateFrame ( "Frame" , "GRM_SyncOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame = CreateFrame ( "Frame" , "GRM_ScanningOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame = CreateFrame ( "Frame" , "GRM_OfficerOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame = CreateFrame ( "Frame" , "GRM_HelpOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame = CreateFrame ( "Frame" , "GRM_GeneralOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame = CreateFrame ( "Frame" , "GRM_UIOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame );
--Options Frame Sub-Tabs
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab = CreateFrame ( "Button" , "GRM_GeneralTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab = CreateFrame ( "Button" , "GRM_ScanTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab = CreateFrame ( "Button" , "GRM_SyncTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab = CreateFrame ( "Button" , "GRM_HelpTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab = CreateFrame ( "Button" , "GRM_OfficerTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab = CreateFrame ( "Button" , "GRM_UITab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab = CreateFrame ( "Button" , "GRM_HordeTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTabText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab:CreateFontString ( "GRM_HordeTabText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab = CreateFrame ( "Button" , "GRM_AllianceTab" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "TabButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTabText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab:CreateFontString ( "GRM_AllianceTabText" , "OVERLAY" , "GameFontNormal" );

-- Addon Users Frame
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame = CreateFrame ( "Frame" , "GRM_AddonUsersFrame" , GRM_UI.GRM_RosterChangeLogFrame );
-- Add Event Frame
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame = CreateFrame ( "Frame" , "GRM_EventsFrame" , GRM_UI.GRM_RosterChangeLogFrame );
-- Ban List Frame
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame = CreateFrame ( "Frame" , "GRM_CoreBanListFrame" , GRM_UI.GRM_RosterChangeLogFrame );
-- Audit Frame
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame = CreateFrame ( "Frame" , "GRM_AuditFrame" , GRM_UI.GRM_RosterChangeLogFrame );

--TAB BUTTONS
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab = CreateFrame ( "Button" , "GRM_OptionsTab" , GRM_UI.GRM_RosterChangeLogFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab = CreateFrame ( "Button" , "GRM_LogTab" , GRM_UI.GRM_RosterChangeLogFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab = CreateFrame ( "Button" , "GRM_AddonUsersTab" , GRM_UI.GRM_RosterChangeLogFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab = CreateFrame ( "Button" , "GRM_AddEventTab" , GRM_UI.GRM_RosterChangeLogFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab = CreateFrame ( "Button" , "GRM_BanListTab" , GRM_UI.GRM_RosterChangeLogFrame , "GameMenuButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab = CreateFrame ( "Button" , "GRM_GuildAuditTab" , GRM_UI.GRM_RosterChangeLogFrame , "GameMenuButtonTemplate" );

-- CALENDAR ADD EVENT FRAMES
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameNameTitleText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameNameTitleText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameNameDateText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameStatusMessageText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameStatusMessageText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameNameToAddText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:CreateFontString ( "GRM_EventsFrameNameToAddTitleText" , "OVERLAY" , "GameFontNormal" );   -- Will never be displayed, just a frame txt holder
-- Set and Ignore Buttons
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton = CreateFrame ( "Button" , "GRM_EventsFrameSetAnnounceButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton:CreateFontString ( "GRM_EventsFrameSetAnnounceButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton = CreateFrame ( "Button" , "GRM_EventsFrameIgnoreButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton:CreateFontString ( "GRM_RosterChangeLogFrame.GRM_EventsFrameIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- SCROLL FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_AddEventScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollBorderFrame = CreateFrame ( "Frame" , "GRM_AddEventScrollBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame = CreateFrame ( "Frame" , "GRM_AddEventScrollChildFrame" );
-- SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider = CreateFrame ( "Slider" , "GRM_AddEventScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame , "UIPanelScrollBarTemplate" );
-- TOOLTIP
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsTooltip = CreateFrame ( "GameTooltip" , "GRM_EventsTooltip" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , "GameTooltipTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsTooltip:Hide();

-- CHECKBOX FRAME
GRM_UI.GRM_RosterCheckBoxSideFrame = CreateFrame ( "Frame" , "GRM_RosterCheckBoxSideFrame" , GRM_UI.GRM_RosterChangeLogFrame , "TranslucentFrameTemplate" );
-- CHECKBOXES
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLoadOnLogonCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_RosterLoadOnLogonCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLoadOnLogonChangesCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_RosterLoadOnLogonChangesCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterShowMainTagCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_RosterShowMainTagCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton = CreateFrame ( "CheckButton" , "GRM_ShowMinimapButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton:CreateFontString ( "GRM_ShowMinimapButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton = CreateFrame ( "CheckButton" , "GRM_SyncAllSettingsCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton:CreateFontString ( "GRM_SyncAllSettingsCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Color Select
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame = CreateFrame ( "Frame" , "GRM_ColorSelectOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame.GRM_OptionsTexture = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame:CreateTexture ( nil , "Background" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorPickerOptionsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:CreateFontString ( "GRM_ColorPickerOptionsText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:CreateFontString ( "GRM_MainTagFormatText" , "OVERLAY" , "GameFontNormalSmall" );
-- Main Name Format
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected = CreateFrame ( "Frame" , "GRM_MainTagFormatSelected" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:CreateFontString ( "GRM_TagText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu = CreateFrame ( "Frame" , "GRM_MainTagFormatMenu" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenuButton = CreateFrame ( "Button" , "GRM_MainTagFormatMenuButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected , "UIPanelScrollDownButtonTemplate" );
-- Color Picker Editboxes
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR = CreateFrame ( "EditBox" , "GRM_ColorPickerR" , ColorPickerFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG = CreateFrame ( "EditBox" , "GRM_ColorPickerG" , ColorPickerFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB = CreateFrame ( "EditBox" , "GRM_ColorPickerB" , ColorPickerFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR.GRM_R_Text = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:CreateFontString ( "GRM_R_Text" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG.GRM_G_Text = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:CreateFontString ( "GRM_G_Text" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB.GRM_B_Text = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:CreateFontString ( "GRM_B_Text" , "OVERLAY" , "GameFontWhiteTiny" );
-- Language Selection
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelectionText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:CreateFontString ( "GRM_LanguageSelectionText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:CreateFontString ( "GRM_LanguageCountText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected = CreateFrame ( "Frame" , "GRM_LanguageSelected" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected.GRM_LanguageSelectedText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:CreateFontString ( "GRM_LanguageSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu = CreateFrame ( "Frame" , "GRM_LanguageDropDownMenu" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenuButton = CreateFrame ( "Button" , "GRM_LanguageDropDownMenuButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected , "UIPanelScrollDownButtonTemplate" );

-- Font Selection
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:CreateFontString ( "GRM_FontText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected = CreateFrame ( "Frame" , "GRM_FontSelected" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:CreateFontString ( "GRM_FontSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu = CreateFrame ( "Frame" , "GRM_FontDropDownMenu" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenuButton = CreateFrame ( "Button" , "GRM_FontDropDownMenuButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected , "UIPanelScrollDownButtonTemplate" );

-- Display options
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterPromotionChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:CreateFontString ( "GRM_RosterPromotionChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterDemotionChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:CreateFontString ( "GRM_RosterDemotionChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeveledChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:CreateFontString ( "GRM_RosterLeveledChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:CreateFontString ( "GRM_RosterLeveledChangeCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNoteChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:CreateFontString ( "GRM_RosterNoteChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterOfficerNoteChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:CreateFontString ( "GRM_RosterOfficerNoteChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterJoinedCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:CreateFontString ( "GRM_RosterJoinedCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeftGuildCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:CreateFontString ( "GRM_RosterLeftGuildCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterInactiveReturnCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:CreateFontString ( "GRM_RosterInactiveReturnCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNameChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:CreateFontString ( "GRM_RosterNameChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterEventCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:CreateFontString ( "GRM_RosterEventCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRankRenameCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:CreateFontString ( "GRM_RosterRankRenameCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendationsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:CreateFontString ( "GRM_RosterRecommendationsButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton = CreateFrame ( "CheckButton" , "GRM_RosterBannedPlayersButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:CreateFontString ( "GRM_RosterBannedPlayersButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButton = CreateFrame ( "CheckButton" , "GRM_RosterCheckAllLogButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButton:CreateFontString ( "GRM_RosterCheckAllLogButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- CHAT BOX CONFIRM CHECKBOXES
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterJoinedChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeveledChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterInactiveReturnChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterPromotionChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterDemotionChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNoteChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterOfficerNoteChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNameChangeChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRankRenameChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterEventChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeftGuildChatCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendationsChatButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton = CreateFrame ( "CheckButton" , "GRM_RosterBannedPlayersButtonChatButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterCheckAllChatButton = CreateFrame ( "CheckButton" , "GRM_RosterCheckAllChatButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
-- Fontstrings for side frame
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText = GRM_UI.GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_TitleSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText = GRM_UI.GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_ShowOnLogSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText = GRM_UI.GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_ShowOnChatSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );

-- SCROLL FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_RosterChangeLogScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollBorderFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogScrollBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogScrollChildFrame" );
-- SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider = CreateFrame ( "Slider" , "GRM_RosterChangeLogScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame , "UIPanelScrollBarTemplate" );
-- BUTTONS -- NO LONGER NECESSARY WHEN MINIMAP BUTTON IS CREATED
GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton = CreateFrame( "Button" , "GRM_LoadLogButton" , GuildFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:CreateFontString ( "GRM_LoadLogButtonText" , "OVERLAY" , "GameFontWhiteTiny");
-- TITTLE
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:CreateFontString ( "GRM_RosterChangeLogFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:CreateFontString ( "GRM_RosterChangeLogFrameNumEntriesText" , "OVERLAY" , "GameFontNormal" );
-- Edit Box
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox = CreateFrame( "EditBox" , "GRM_LogEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame );

-- OPTIONS PANEL BUTTONS ( in the Roster Log Frame)
-- CORE ADDON OPTIONS CONTROLS LISTED HERE!
-- BACKUP OPTIONS
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox = CreateFrame ( "CheckButton" , "GRM_AutoBackupCheckBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:CreateFontString ( "GRM_MemoryUsageText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:CreateFontString ( "DaysOnAutoBackupText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:CreateFontString ( "DaysOnAutoBackupText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_CoreBackupScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame = CreateFrame ( "Frame" , "GRM_CoreBackupScrollBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "TranslucentFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox = CreateFrame( "EditBox" , "GRM_AutoBackupTimeEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote = CreateFrame ( "Frame" , "GRM_AutoBackupTimeOverlayNote" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNoteText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:CreateFontString ( "GRM_AutoBackupTimeOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );

-- CONTENT FRAME (Child Frame)
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame = CreateFrame ( "Frame" , "GRM_CoreBackupScrollChildFrame" );
-- SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider = CreateFrame ( "Slider" , "GRM_CoreBackupScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "UIPanelScrollBarTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CreationDateText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:CreateFontString ( "GRM_CreationDateText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNumMembersText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:CreateFontString ( "GRM_GuildNumMembersText" , "OVERLAY" , "GameFontNormal" );
-- Tooltip and custom Right-Click frame on Backup window in options...
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip = CreateFrame ( "GameTooltip" , "GRM_GuildNameTooltip" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "GameTooltipTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption = CreateFrame ( "Frame" , "GRM_BackupPurgeGuildOption" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton = CreateFrame ( "Button" , "GRM_BackupPurgeGuildOptionButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton:CreateFontString ( "GRM_BackupPurgeGuildOptionText" , "OVERLAY" , "GameFontWhiteTiny" );

-- Options Panel Checkboxes
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterAddTimestampCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:CreateFontString ( "GRM_RosterAddTimestampCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:CreateFontString ( "GRM_RosterAddTimestampCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1 = CreateFrame ( "CheckButton" , "GRM_RosterAddTimestampRadioButton1" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , "UIRadioButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton2 = CreateFrame ( "CheckButton" , "GRM_RosterAddTimestampRadioButton2" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , "UIRadioButtonTemplate" );

--OPTIONS PANEL FONTSTRING DESCRIPTION ON OPTIONS CONTROLS
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:CreateFontString ( "GRM_OptionsFrame.OptionsHeaderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:CreateFontString ( "GRM_OptionsFrame.OptionsHeaderText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:CreateFontString ( "GRM_OptionsFrame.OptionsHeaderText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.OptionsSyncHeaderText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame:CreateFontString ( "GRM_SyncOptionsFrame.OptionsSyncHeaderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_GeneralOptionsFrameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:CreateFontString ( "GRM_GeneralOptionsFrameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.OptionsRankRestrictHeaderText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame:CreateFontString ( "GRM_OptionsFrame.OptionsRankRestrictHeaderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.OptionsScanDetailsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame:CreateFontString ( "GRM_OptionsFrame.OptionsScanDetailsText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.OptionsSlashCommandText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_OptionsFrame.OptionsSlashCommandText" , "OVERLAY" , "GameFontNormal" );
--SLASH COMMAND FONTSTRINGS
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText4 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText4" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText5 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText5" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText6 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText6" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText7 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText7" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText8 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText8" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText9 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText9" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText10 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:CreateFontString ( "GRM_SlashCommandText10" , "OVERLAY" , "GameFontNormal" );
-- Kick Recommendation Options
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendKickCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:CreateFontString ( "GRM_RosterRecommendKickCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:CreateFontString ( "GRM_RosterRecommendKickCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox = CreateFrame( "EditBox" , "GRM_RosterKickRecommendEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote = CreateFrame ( "Frame" , "GRM_RosterKickOverlayNote" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:CreateFontString ( "GRM_RosterKickOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Time Interval to Check for Changes
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterTimeIntervalCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:CreateFontString ( "GRM_RosterTimeIntervalCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:CreateFontString ( "GRM_RosterTimeIntervalCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox = CreateFrame( "EditBox" , "GRM_RosterTimeIntervalEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote = CreateFrame ( "Frame" , "GRM_RosterTimeIntervalOverlayNote" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:CreateFontString ( "GRM_RosterTimeIntervalOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Minimum level to scan
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox = CreateFrame ( "EditBox" , "GRM_RosterMinLvlEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:Hide();
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote = CreateFrame ( "Frame" , "GRM_RosterMinLvlOverlayNote" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:CreateFontString ( "GRM_RosterMinLvlOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Report Inactive Options
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton = CreateFrame ( "CheckButton" , "GRM_RosterReportInactiveReturnButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton:CreateFontString ( "GRM_RosterReportInactiveReturnButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton:CreateFontString ( "GRM_RosterReportInactiveReturnButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox = CreateFrame( "EditBox" , "GRM_ReportInactiveReturnEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote = CreateFrame ( "Frame" , "GRM_ReportInactiveReturnOverlayNote" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:CreateFontString ( "GRM_ReportInactiveReturnOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Report Upcoming Events
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterReportUpcomingEventsCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportUpcomingEventsCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportUpcomingEventsCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox = CreateFrame( "EditBox" , "GRM_RosterReportUpcomingEventsEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote = CreateFrame ( "Frame" , "GRM_RosterReportUpcomingEventsOverlayNote" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:CreateFontString ( "GRM_RosterReportUpcomingEventsOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton = CreateFrame ( "CheckButton" , "GRM_RosterReportAddEventsToCalendarButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:CreateFontString ( "GRM_RosterReportAddEventsToCalendarButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Share changes with ONLINE guildies
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterSyncCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNotifyOnChangesCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton = CreateFrame ( "CheckButton" , "GRM_SyncAllRestrictReceiveButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:CreateFontString ( "GRM_SyncAllRestrictReceiveButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Options RankDropDown
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected = CreateFrame ( "Frame" , "GRM_RosterSyncRankDropDownSelected" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:CreateFontString ( "GRM_RosterSyncRankDropDownSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu = CreateFrame ( "Frame" , "GRM_RosterSyncRankDropDownMenu" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenuButton = CreateFrame ( "Button" , "GRM_RosterSyncRankDropDownMenuButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected , "UIPanelScrollDownButtonTemplate" );

-- SYNC with players with outdated versions
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton = CreateFrame ( "CheckButton" , "GRM_SyncOnlyCurrentVersionCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton:CreateFontString ( "GRM_SyncOnlyCurrentVersionCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- SYNC with players with outdated versions
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList = CreateFrame ( "CheckButton" , "GRM_RosterSyncBanList" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:CreateFontString ( "GRM_RosterSyncBanListText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:CreateFontString ( "GRM_RosterSyncBanListText3" , "OVERLAY" , "GameFontNormalSmall" );


-- Options Sync Ban List Drop Down
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected = CreateFrame ( "Frame" , "GRM_RosterBanListDropDownSelected" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:CreateFontString ( "GRM_RosterBanListDropDownSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu = CreateFrame ( "Frame" , "GRM_RosterBanListDropDownMenu" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton = CreateFrame ( "Button" , "GRM_RosterBanListDropDownMenuButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected , "UIPanelScrollDownButtonTemplate" );

-- Options Scan Announce events for Main only
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterMainOnlyCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:CreateFontString ( "GRM_RosterMainOnlyCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- Option to notify when players request to join
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton = CreateFrame ( "CheckButton" , "GRM_RecruitNotificationCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:CreateFontString ( "GRM_RecruitNotificationCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- Slash command Buttons in Options
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton = CreateFrame ( "Button" , "GRM_ScanOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton = CreateFrame ( "Button" , "GRM_SyncOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton = CreateFrame ( "Button" , "GRM_CenterOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton = CreateFrame ( "Button" , "GRM_HelpOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton = CreateFrame ( "Button" , "GRM_ClearAllOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearGuildOptionsButton = CreateFrame ( "Button" , "GRM_ClearGuildOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton = CreateFrame ( "Button" , "GRM_VersionOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , "UIPanelButtonTemplate" );

-- Reset Defaults Button
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton = CreateFrame ( "Button" , "GRM_ResetDefaultOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:CreateFontString ( "GRM_ResetDefaultOptionsButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- SYNC speed slider
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider = CreateFrame ( "Slider" , "GRM_SyncSpeedSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , "OptionsSliderTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:CreateFontString ( "GRM_SyncSpeedSliderText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:CreateFontString ( "GRM_SyncSpeedSliderText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- OPTIONS font size slider
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider = CreateFrame ( "Slider" , "GRM_FontSizeSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , "OptionsSliderTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:CreateFontString ( "GRM_FontSizeSliderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:CreateFontString ( "GRM_FontSizeSliderText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:CreateFontString ( "GRM_FontSizeSliderText3" , "OVERLAY" , "GameFontNormal" );

-- Guild Event Log Frame Confirm Details.
GRM_UI.GRM_RosterConfirmFrame = CreateFrame ( "Frame" , "GRM_RosterConfirmFrame" , UIPanel , "BasicFrameTemplate" );
GRM_UI.GRM_RosterConfirmFrameText = GRM_UI.GRM_RosterConfirmFrame:CreateFontString ( "GRM_RosterConfirmFrameText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_UI.GRM_RosterConfirmYesButton = CreateFrame ( "Button" , "GRM_RosterConfirmYesButton" , GRM_UI.GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterConfirmYesButtonText = GRM_UI.GRM_RosterConfirmYesButton:CreateFontString ( "GRM_RosterConfirmYesButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_UI.GRM_RosterConfirmCancelButton = CreateFrame ( "Button" , "GRM_RosterConfirmCancelButton" , GRM_UI.GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterConfirmCancelButtonText = GRM_UI.GRM_RosterConfirmCancelButton:CreateFontString ( "GRM_RosterConfirmCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- ADDON USERS FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:CreateFontString ( "GRM_AddonUsersCoreFrameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:CreateFontString ( "GRM_AddonUsersCoreFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:CreateFontString ( "GRM_AddonUsersCoreFrameTitleText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:CreateFontString ( "GRM_AddonUsersCoreFrameTitleText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:CreateFontString ( "GRM_AddonUsersSyncEnabledText" , "OVERLAY" , "GameFontNormal" );

-- SCROLL FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_AddonUsersScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollBorderFrame = CreateFrame ( "Frame" , "GRM_AddonUsersScrollBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame = CreateFrame ( "Frame" , "GRM_AddonUsersScrollChildFrame" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUsersCoreFrameTitleText2" , "OVERLAY" , "GameFontNormal" );
-- SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider = CreateFrame ( "Slider" , "GRM_AddonUsersScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame , "UIPanelScrollBarTemplate" );
--TOOLTIP
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersTooltip = CreateFrame ( "GameTooltip" , "GRM_AddonUsersTooltip" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , "GameTooltipTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersTooltip:Hide();

-- CORE BANLIST FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4 = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText4" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameSelectedNameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameNumBannedText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameAllOfflineText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:Hide();
-- BANLIST SCROLL FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_CoreBanListScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame = CreateFrame ( "Frame" , "GRM_CoreBanListScrollBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , "TranslucentFrameTemplate" );
-- BANLIST CONTENT FRAME (Child Frame)
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame = CreateFrame ( "Frame" , "GRM_CoreBanListScrollChildFrame" );
-- BANLIST SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider = CreateFrame ( "Slider" , "GRM_CoreBanListScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , "UIPanelScrollBarTemplate" );
-- Add and Remove BUTTONS
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton = CreateFrame ( "Button" , "GRM_BanListRemoveButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton:CreateFontString ( "GRM_BanListRemoveButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButton = CreateFrame ( "Button" , "GRM_BanListAddButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButton:CreateFontString ( "GRM_BanListAddButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- Add player ban window
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame = CreateFrame( "Frame" , "GRM_AddBanFrame" , UIPanel , "BasicFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:CreateFontString ( "GRM_AddBanTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:CreateFontString ( "GRM_AddBanNameSelectionWarningText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:CreateFontString ( "GRM_AddBanNameSelectionWarningText2" , "OVERLAY" , "GameFontWhiteTiny" );
-- Name selection to add ban
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox = CreateFrame( "EditBox" , "GRM_AddBanNameSelectionEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "InputBoxTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:CreateFontString ( "GRM_AddBanNameSelectionText" , "OVERLAY" , "GameFontNormal" );
-- Server selection to add ban
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox = CreateFrame( "EditBox" , "GRM_AddBanServerSelectionEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "InputBoxTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:CreateFontString ( "GRM_AddBanServerSelectionText" , "OVERLAY" , "GameFontNormal" );
-- Reason for the ban
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox = CreateFrame( "EditBox" , "GRM_AddBanReasonEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:CreateFontString ( "GRM_AddBanReasonEditBoxText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame = CreateFrame ( "Frame" , "GRM_AddBanReasonEditBoxFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame );
-- Add Ban CLASS selection dropdown
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanClassSelectionText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:CreateFontString ( "GRM_AddBanClassSelectionText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected = CreateFrame ( "Frame" , "GRM_AddBanDropDownClassSelected" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame, "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:CreateFontString ( "GRM_AddBanDropDownClassSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu = CreateFrame ( "Frame" , "GRM_AddBanDropDownMenu" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenuButton = CreateFrame ( "Button" , "GRM_AddBanDropDownMenuButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected, "UIPanelScrollDownButtonTemplate" );
-- Submit button
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton = CreateFrame ( "Button" , "GRM_AddBanConfirmButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton:CreateFontString ( "GRM_AddBanConfirmButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ADD BAN MEMBER CONFIRM FRAME UNIQUE
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame = CreateFrame ( "Frame" , "GRM_PopupWindowConfirmFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "TranslucentFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:CreateFontString ( "GRM_PopupWindowConfirmFrameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:CreateFontString ( "GRM_PopupWindowConfirmFrameText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButton = CreateFrame ( "Button" , "GRM_PopupWindowConfirmFrameYesButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButton:CreateFontString ( "GRM_PopupWindowConfirmFrameYesButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButton = CreateFrame ( "Button" , "GRM_PopupWindowConfirmFrameCancelButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButton:CreateFontString ( "GRM_PopupWindowConfirmFrameCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- AUDIT FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameTitleText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText1" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText4 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText4" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText5" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText6 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText6" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText7" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:CreateFontString ( "GRM_AuditFrameText8" , "OVERLAY" , "GameFontNormal" );
-- AUDIT FRAME SCROLL FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_AuditScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame = CreateFrame ( "Frame" , "GRM_AuditScrollBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "TranslucentFrameTemplate" );
-- BANLIST CONTENT FRAME (Child Frame)
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame = CreateFrame ( "Frame" , "GRM_AuditScrollChildFrame" );
-- BANLIST SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider = CreateFrame ( "Slider" , "GRM_AuditScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "UIPanelScrollBarTemplate" );
-- CHECKBOXES
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox = CreateFrame ( "CheckButton" , "GRM_AuditFrameShowAllCheckbox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox.GRM_AudtFrameCheckBoxText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox:CreateFontString ( "GRM_AudtFrameCheckBoxText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox = CreateFrame ( "CheckButton" , "GRM_AuditFrameIncludeUnknownCheckBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox.GRM_AuditFrameIncludeUnknownCheckBoxText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox:CreateFontString ( "GRM_AuditFrameIncludeUnknownCheckBoxText" , "OVERLAY" , "GameFontNormal" );
-- BUTTONS
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton = CreateFrame ( "Button" , "GRM_SetJoinUnkownButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton:CreateFontString ( "GRM_SetJoinUnkownButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton = CreateFrame ( "Button" , "GRM_SetPromoUnkownButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton:CreateFontString ( "GRM_SetJoinUnkownButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- MINIMAP BUTTON
GRM_UI.GRM_MinimapButton = CreateFrame ( "Button" , "GRM_MinimapButton" , Minimap );
GRM_UI.GRM_MinimapButton.GRM_MinimapButtonIcon = GRM_UI.GRM_MinimapButton:CreateTexture ( "GRM_MinimapButtonIcon" , "BORDER" );
GRM_UI.GRM_MinimapButton.GRM_MinimapButtonBorder = GRM_UI.GRM_MinimapButton:CreateTexture ( "GRM_MinimapButtonBorder" , "OVERLAY" );

-- LOG EXPORT AND TOOLS
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame = CreateFrame ( "Frame" , "GRM_ExportLogBorderFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame , "TranslucentFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_BorderFrameCloseButton = CreateFrame ( "Button" , "GRM_BorderFrameCloseButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame , "UIPanelCloseButton" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLogText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:CreateFontString ( "GRM_ExportLogText" , "OVERLYA" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox = CreateFrame ( "EditBox" , "GRM_ExportLogFrameEditBox" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame );
-- SCROLL FRAME
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_ExportLogScrollFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame );
-- CONTENT FRAME (Child Frame)
-- SLIDER
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider = CreateFrame ( "Slider" , "GRM_ExportLogScrollFrameSlider" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame , "UIPanelScrollBarTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:CreateFontString ( "GRM_ExportLoadingText" , "OVERLAY" , "GameFontNormal" );

-- Log Frame OPTIONS BOX
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame = CreateFrame ( "Frame" , "GRM_LogExtraOptionsFrame" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , "TranslucentFrameTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton = CreateFrame ( "Button" , "GRM_LogExtraOptionsButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton:CreateFontString ( "GRM_LogExtraOptionsButtonText" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton = CreateFrame ( "Button" , "GRM_LogExportButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton.GRM_ExportButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton:CreateFontString ( "GRM_ExportButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton = CreateFrame ( "CheckButton" , "GRM_LogShowLinesCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton:CreateFontString ( "GRM_LogShowLinesCheckButtonText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton = CreateFrame ( "CheckButton" , "GRM_LogEnableRmvClickCheckButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton:CreateFontString ( "GRM_LogEnableRmvClickCheckButtonText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:CreateFontString ( "GRM_LogExtraText1" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:CreateFontString ( "GRM_LogExtraText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton = CreateFrame ( "Button" , "GRM_ConfirmClearButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton.GRM_ConfirmClearButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton:CreateFontString ( "GRM_ConfirmClearButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- Clear Log Button
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButton = CreateFrame( "Button" , "GRM_RosterClearLogButton" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButton:CreateFontString ( "GRM_RosterClearLogButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1 = CreateFrame ( "EditBox" , "GRM_LogExtraEditBox1" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "InputBoxTemplate" );
GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2 = CreateFrame ( "EditBox" , "GRM_LogExtraEditBox2" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "InputBoxTemplate" );

-- GUILD REQUEST TO JOIN WINDOW
GRM_UI.GRM_RequestToJoinWindow = CreateFrame ( "Frame" , "GRM_RequestToJoinWindow" , GuildInfoFrameApplicantsContainerScrollChild );

-- MISC UI EVENTS TEXT
GRM_UI.GRM_GroupInfo = CreateFrame ( "Frame" );
GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck = GRM_UI.GRM_GroupInfo:CreateFontString ( "InvisFontStringWidthCheck" );
GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText = GRM_UI.GRM_GroupInfo:CreateFontString ( "GRM_NumGuildiesText" , "OVERLAY" , "GameFontNormalSmall" );

-- CUSTOM NOTE EDIT BOX FRAME INFO
-- GRM_UI.GRM_PlayerCustomNoteWindow = CreateFrame( "Frame" , "GRM_PlayerCustomNoteWindow" , GRM_UI.GRM_MemberDetailMetaData );
-- GRM_UI.GRM_PlayerCustomNoteWindowFontString = GRM_UI.GRM_PlayerCustomNoteWindow:CreateFontString ( "GRM_PlayerCustomNoteWindowFontString" , "OVERLAY" , "GameFontWhiteTiny" );
-- GRM_UI.GRM_PlayerCustomNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerCustomNoteEditBox" , GRM_UI.GRM_MemberDetailMetaData );
-- GRM_UI.GRM_PlayerCustomNoteEditBox:Hide();


-----------------------------------------------
--------- UI CONTROLS -------------------------
--------- AND PARAMETERS ----------------------
-----------------------------------------------

-- Frame modifications
GRM_UI.SetDynamicWidth = function ( fontstring , spacingOnEachSide )
    local result = -1;
    if fontstring ~= nil and fontstring:GetObjectType() == "FontString" then
        result = fontstring:GetWidth() + ( spacingOnEachSide * 2 );
    end
    return result; 
end

-- Method:          GRM_UI.ReloadAllFrames()
-- What it Does:    Reloads all of the frames in case there have been modifications to them, in one big batch, like if the language was changed.
-- Purpose:         Management of UI text and font formatting and localization controls.
GRM_UI.ReloadAllFrames = function( isManualUpdate )
    if not isManualUpdate then
        GRM_UI.PreAddonLoadUI();
    end
    GRM_UI.MetaDataInitializeUIrosterLog1( isManualUpdate );
    GRM_UI.MetaDataInitializeUIrosterLog2();
    if GRM_AddonGlobals.FramesInitialized then
        GRM_UI.GR_MetaDataInitializeUIFirst( isManualUpdate );
        GRM_UI.GR_MetaDataInitializeUISecond( isManualUpdate );
        GRM_UI.GR_MetaDataInitializeUIThird( isManualUpdate );
    end
    if GuildMemberDetailFrame and GuildMemberDetailFrame:IsVisible() then
        GuildMemberDetailFrame:Hide();
    end
    if GRM_UI.GRM_MemberDetailMetaData and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
        GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
    end
    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        GRM_OptionsTab:Click();
    end
end

-- Method:          GR_MetaDataInitializeUIFirst( boolean )
-- What it Does:    Initializes "some of the frames"
-- Purpose:         Should only initialize as needed. Kept as local for speed
GRM_UI.GR_MetaDataInitializeUIFirst = function( isManualUpdate )
    -- Useful to build these buttons!
    -- GRM.CollectRosterButtons();

    -- Frame Control
    GRM_UI.GRM_MemberDetailMetaData:EnableMouse ( true );
    GRM_UI.GRM_MemberDetailMetaData:SetToplevel ( true );

    -- Placement and Dimensions
    GRM_UI.GRM_MemberDetailMetaData:SetPoint ( "TOPLEFT" , GuildRosterFrame , "TOPRIGHT" , -4 , 5 );
    GRM_UI.GRM_MemberDetailMetaData:SetSize( 300 , 330 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton:SetPoint( "TOPRIGHT" , GRM_UI.GRM_MemberDetailMetaData , 3, 3 ); 
    
    GRM_UI.GRM_MemberDetailMetaData:SetScript ( "OnUpdate" , GRM.MemberDetailToolTips );

    -- Logic handling: If pause is set, this unpauses it. If it is not paused, this will then hide the window.
    GRM_UI.GRM_MemberDetailMetaData:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_MemberDetailMetaData:SetPropagateKeyboardInput ( true );
        if key == "ESCAPE" then
            GRM_UI.GRM_MemberDetailMetaData:SetPropagateKeyboardInput ( false );
            if GRM_AddonGlobals.pause then
                GRM_AddonGlobals.pause = false;
            else
                GRM_UI.GRM_MemberDetailMetaData:Hide();
            end
        end
    end);

    -- For Fontstring logic handling, particularly of the alts.
    GRM_UI.GRM_MemberDetailMetaData:SetScript ( "OnMouseDown" , function ( _ , button ) 
        if button == "RightButton" then
            GRM_AddonGlobals.selectedAlt = GRM.GetCoreFontStringClicked(); -- Setting to global the alt name chosen.
            if GRM_AddonGlobals.selectedAlt[1] ~= nil then
                if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) and not GRM.PlayerHasAltsOrIsMain ( GRM_AddonGlobals.currentName ) then
                    -- DO nothing... as no alts are register.
                else
                    GRM_AddonGlobals.pause = true;
                end

                -- Positioning
                if not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                    local cursorX , cursorY = GetCursorPosition();
                    GRM_UI.GRM_altDropDownOptions:ClearAllPoints();
                    GRM_UI.GRM_altDropDownOptions:SetPoint( "TOPLEFT" , UIParent , "BOTTOMLEFT" , cursorX , cursorY );
                    GRM_UI.GRM_altOptionsText:SetText ( GRM.SlimName ( GRM_AddonGlobals.selectedAlt[2] ) );
                    local width = 70;
                    if GRM_UI.GRM_altOptionsText:GetStringWidth() + 15 > width then       -- For scaling the frame based on size of player name.
                        width = GRM_UI.GRM_altOptionsText:GetStringWidth() + 15;
                    end

                    GRM_UI.GRM_altSetMainButton:SetPoint ("TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -22 );
                    GRM_UI.GRM_altSetMainButton:SetSize ( 60 , 20 );
                    GRM_UI.GRM_altRemoveButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -36 );
                    GRM_UI.GRM_altRemoveButton:SetSize ( 60 , 20 );
                    GRM_UI.GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -55 );
                    GRM_UI.GRM_altOptionsDividerText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
                    GRM_UI.GRM_altOptionsDividerText:SetText ("__");
                    GRM_UI.GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -65 );
                    GRM_UI.GRM_altFrameCancelButton:SetSize ( 60 , 20 );
                    GRM_UI.GRM_altFrameCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
                    
                    if GRM_AddonGlobals.selectedAlt[1] == GRM_AddonGlobals.selectedAlt[2] then -- Not clicking an alt frame
                        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                            GRM_AddonGlobals.editPromoDate = true;
                            GRM_AddonGlobals.editJoinDate = false;
                            GRM_AddonGlobals.editFocusPlayer = false;
                            GRM_AddonGlobals.editStatusNotify = false;
                            GRM_AddonGlobals.editOnlineStatus = false;
                        elseif GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                            GRM_AddonGlobals.editJoinDate = true;
                            GRM_AddonGlobals.editPromoDate = false;
                            GRM_AddonGlobals.editFocusPlayer = false;
                            GRM_AddonGlobals.editStatusNotify = false;
                            GRM_AddonGlobals.editOnlineStatus = false;
                        elseif GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                            GRM_AddonGlobals.editFocusPlayer = true;
                            GRM_AddonGlobals.editJoinDate = false;
                            GRM_AddonGlobals.editPromoDate = false;
                            GRM_AddonGlobals.editStatusNotify = false;
                            GRM_AddonGlobals.editOnlineStatus = false;
                        elseif GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:IsMouseOver ( 2 , -2 , -2 , 2 ) and ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( AFK )" ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Busy )" ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Active )" ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Mobile )" ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Offline )" ) ) then
                            if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Offline )" ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Active )" ) then
                                GRM_AddonGlobals.editOnlineStatus = true;
                                GRM_AddonGlobals.editStatusNotify = false;
                                GRM_AddonGlobals.editFocusPlayer = false;
                                GRM_AddonGlobals.editJoinDate = false;
                                GRM_AddonGlobals.editPromoDate = false;
                            else
                                GRM_AddonGlobals.editStatusNotify = true;
                                GRM_AddonGlobals.editFocusPlayer = false;
                                GRM_AddonGlobals.editJoinDate = false;
                                GRM_AddonGlobals.editPromoDate = false;
                                GRM_AddonGlobals.editOnlineStatus = false;
                            end
                        end

                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:Hide();
                        if GRM_AddonGlobals.editFocusPlayer then
                            if GRM_AddonGlobals.selectedAlt[3] ~= true then    -- player is not the main.
                                GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Set as Main" ) );
                            else -- player IS the main... place option to Demote From Main rahter than set as main.
                                GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Set as Alt" ) );
                            end
                            GRM_UI.GRM_altRemoveButtonText:SetText ( GRM.L ( "Reset Data!" ) );
                            GRM_UI.GRM_altRemoveButton:Show();
                        elseif GRM_AddonGlobals.editStatusNotify then
                            GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Notify When Player is Active" ) );
                            GRM_UI.GRM_altRemoveButtonText:SetText ( GRM.L ( "Notify When Player Goes Offline" ) );
                            width = GRM_UI.GRM_altRemoveButtonText:GetStringWidth() + 15;
                            GRM_UI.GRM_altRemoveButton:SetSize ( 120 , 20 );
                            GRM_UI.GRM_altSetMainButton:SetSize ( 120 , 20 );
                            GRM_UI.GRM_altRemoveButton:Show();
                        elseif GRM_AddonGlobals.editOnlineStatus  then
                            if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:GetText() == GRM.L ( "( Active )" ) then
                                GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Notify When Player Goes Offline" ) );
                            else
                                GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Notify When Player Comes Online" ) );
                            end
                            width = GRM_UI.GRM_altSetMainButtonText:GetStringWidth() + 15;
                            GRM_UI.GRM_altSetMainButton:SetSize ( 120 , 20 );
                            GRM_UI.GRM_altRemoveButton:Hide();
                            GRM_UI.GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -40 );
                            GRM_UI.GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -55 );
                        else
                            GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Edit Date" ) );
                            GRM_UI.GRM_altRemoveButtonText:SetText ( GRM.L ( "Clear History" ) );
                            GRM_UI.GRM_altRemoveButton:Show();
                        end
                    else
                        if GRM_AddonGlobals.selectedAlt[3] ~= true then    -- player is not the main.
                            GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Set as Main" ) );
                        else -- player IS the main... place option to Demote From Main rahter than set as main.
                            GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Set as Alt" ) );
                        end
                        GRM_UI.GRM_altRemoveButtonText:SetText ( GRM.L ( "Remove" ) );
                        GRM_UI.GRM_altRemoveButton:Show();
                    end

                    GRM_UI.GRM_altDropDownOptions:SetSize ( width , 92 );
                    GRM_UI.GRM_altDropDownOptions:Show();
                else
                    -- Special Logic for sync dates.
                    -- Don't want to mess with the logic here if the date submit buttons are already up...
                    if not GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() and not GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:IsVisible() and GRM.PlayerOrAltHasJD ( GRM_AddonGlobals.currentName ) and not GRM.IsAltJoinDatesSynced( GRM_AddonGlobals.currentName ) then
                        -- Hide the other custom frame...
                        GRM_UI.GRM_altDropDownOptions:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Show();
                    end
                end
            end
        elseif button == "LeftButton" then
            if not IsShiftKeyDown() then
                if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:IsVisible() and not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                    -- This makes the main window the alt that was clicked on! TempAltName is saved when mouseover action occurs.
                    if GRM_AddonGlobals.tempAltName ~= "" then
                        GRM.SelectPlayerOnRoster ( GRM_AddonGlobals.tempAltName );
                    end
                end
            else
                if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                    GRM_AddonGlobals.tempAltName = GRM_AddonGlobals.currentName;
                end
                if GRM_AddonGlobals.tempAltName ~= "" then
                    GRM.GR_Roster_Click ( GRM_AddonGlobals.tempAltName );
                    GRM_AddonGlobals.tempAltName = "";
                end
            end
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData:SetScript ( "OnHide" , function()
        GRM.ClearAllFrames( true );
    end);

    -- Keyboard Control for easy ESC closeButtons
    -- tinsert( UISpecialFrames, "GRM_UI.GRM_MemberDetailMetaData" );

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData , "TOPRIGHT" , -7 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:SetSize ( 315 , 130 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_SyncJoinDateText:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame , 0 , -22 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_SyncJoinDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_SyncJoinDateText:SetText ( GRM.L ( "Please Select Which Join Date to Sync" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_SyncJoinDateText:SetWidth ( 285 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_SyncJoinDateText , "BOTTOM" , 0 , -2 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton:SetSize ( 275 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton , "LEFT" , 10 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton , "BOTTOMLEFT" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton:SetSize ( 275 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton , "LEFT" , 10 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDMainButton , "BOTTOMLEFT" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButton:SetSize ( 275 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButton , "LEFT" , 10 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSelectedPlayerButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame , "BOTTOMLEFT" , 10 , 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton:SetSize ( 275 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton , "LEFT" , 10 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButtonText:SetText ( GRM.L ( "Cancel" ) );

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDSyncCancelButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
            GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
        end
    end);

    -- Do not want to give player the option to sync JD data if they remove all their alts or reset JD data whilst this frame is open... close it if changes. Check every 2 seconds.
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:SetScript ( "OnUpdate" , function ( self , elapsed )
        GRM_AddonGlobals.SyncJDTimer = GRM_AddonGlobals.SyncJDTimer + elapsed;
        if GRM_AddonGlobals.SyncJDTimer > 2 then
            if not GRM.PlayerOrAltHasJD ( GRM_AddonGlobals.currentName ) then
                self:Hide();
            end
            GRM_AddonGlobals.SyncJDTimer = 0;
        end
    end)
    -- Logic for syncing JDs...
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame.GRM_JDOldestButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM.SyncJoinDateUsingEarliest();
            GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
            GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
        end
    end);
    

    -- Logic for when the sync frame loads up...
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:SetScript ( "OnShow" , function ( self )
        -- True for each of the buttons... which will depend on the logic of what to show.
        local count = 0;
        local mainName = "";
        local playerHasJD = GRM.PlayerHasJoinDate ( GRM_AddonGlobals.currentName )[1];
        local oldestPlayerAndDate = GRM.GetAltWithOldestJoinDate ( GRM_AddonGlobals.currentName );
        local mainHasJD = {};
        -- Ok, need this data in case we want to sync to the main. But we don't want to ask the player that if main has no date set...
        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:IsVisible() then
            mainName = GRM_AddonGlobals.currentName;
        else
            mainName = GRM.GetPlayerMain ( GRM_AddonGlobals.currentName );
        end
        -- Get Main info...
        if mainName ~= nil and mainName ~= GRM_AddonGlobals.currentName then
            mainHasJD = GRM.PlayerHasJoinDate ( mainName )[1];
        end

        -- First Button
        self.GRM_JDOldestButtonText:SetText ( ">  " .. GRM.L ( "Sync All Alts to the Earliest Join Date: {name}" , GRM.GetClassifiedName ( oldestPlayerAndDate[1] , true ) ) );

        -- Second Button
        if mainName ~= nil and mainName ~= GRM_AddonGlobals.currentName and oldestPlayerAndDate[1] ~= mainName and mainHasJD then
            self.GRM_JDMainButtonText:SetText ( ">  " .. GRM.L ( "Sync All Alts to {name}'s |cffff0000(main)|r Join Date" , GRM.GetClassifiedName ( mainName , true ) ) );
            -- Set the script to proper button
            self.GRM_JDMainButton:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    GRM.SyncJoinDateUsingMain();
                    GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
                    self:Hide();
                end
            end);
            self.GRM_JDMainButton:Show();
            count = count + 1;
        elseif oldestPlayerAndDate[1] ~= GRM_AddonGlobals.currentName and playerHasJD then
            self.GRM_JDMainButtonText:SetText ( ">  " .. GRM.L ( "Sync All Alts to {name}'s Join Date" , GRM.GetClassifiedName ( GRM_AddonGlobals.currentName , true ) ) );
            self.GRM_JDMainButton:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    GRM.SyncJoinDateUsingCurrentSelected();
                    GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
                    self:Hide();
                end
            end);
            self.GRM_JDMainButton:Show();
            count = count + 2;
        end

        -- Third Button
        -- If the 2nd button wasn't filled, well, neither will the third... hide both the 2nd and 3rd buttons
        if count == 0 then
            self.GRM_JDMainButton:Hide();
            self.GRM_JDSelectedPlayerButton:Hide();
            -- transform logic to size for just 1 button
            self:SetSize ( 315 , 85 )

        -- This means that the potential 3rd position was filled to the 2nd, thus we can hide the 3rd button.
        elseif count == 2 then
            self.GRM_JDSelectedPlayerButton:Hide();
            -- transform logic to size for just 2 buttons
            self:SetSize ( 315 , 105 )
        -- this means that the first button was filled, the 2nd button was filled, now let's determine if the 3rd button will also be filled.
        elseif count == 1 then
            -- No need to repeat this, since the oldest will permanently be on button 1
            if oldestPlayerAndDate[1] ~= GRM_AddonGlobals.currentName and playerHasJD then
                self:SetSize ( 315 , 130 );
                self.GRM_JDSelectedPlayerButtonText:SetText ( ">  " .. GRM.L ( "Sync All Alts to {name}'s Join Date" , GRM.GetClassifiedName ( GRM_AddonGlobals.currentName , true ) ) );
                self.GRM_JDSelectedPlayerButton:SetScript ( "OnClick" , function ( self , button )
                    if button == "LeftButton" then
                        GRM.SyncJoinDateUsingCurrentSelected();
                        GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
                        self:Hide();
                    end
                end);
                self.GRM_JDSelectedPlayerButton:Show();
            else
                self:SetSize ( 315 , 105 )
                self.GRM_JDSelectedPlayerButton:Hide();
            end
        end
    end);
    

    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
        end
    end);

    -- Day Dropdown
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownButton:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected , "RIGHT" , -2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownButton:SetSize (20 , 20 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:SetSize ( 30 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownButton , "RIGHT" , -2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected , "BOTTOM" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetWidth ( 34 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_DayDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:IsVisible() then
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Hide();
            else
                GRM.InitializeDropDownDay();
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Show();
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Hide();
            end
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Show();
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:SetScript ( "OnShow" , function()
        GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Hide();
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:SetSize ( 83 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt , "BOTTOM" , -67 , -4 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected , "BOTTOM" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetWidth ( 80 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetFrameStrata ( "HIGH" );
    
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownButton:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected , "RIGHT" , -2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownButton:SetSize (20 , 20 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:IsVisible() then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Hide();
            else
                GRM.InitializeDropDownMonth();
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Show();
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Hide();
            end
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Show();
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:SetScript ( "OnShow" , function()
        GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Hide();
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:SetSize ( 53 , 20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownButton , "RIGHT" , -2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected , "BOTTOM" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetWidth ( 52 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownButton:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected , "RIGHT" , -2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownButton:SetSize (20 , 20 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:IsVisible() then
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Hide();
            else
                GRM.InitializeDropDownYear();
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Show();
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Hide();
            end
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Show();
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:SetScript ( "OnShow" , function()
        GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Hide();
    end);

    --Rank Drop down submit and cancel
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetText ( GRM.L ( "Date Promoted?" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:SetSize ( 90 , 18 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt , "BOTTOM" , 0 , -4 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:SetScript( "OnClick" , function( self , button ) 
        if button == "LeftButton" then
            self:Hide();
            GRM.SetDateSelectFrame ( "PromoRank" );  -- Position, Frame, ButtonName
            GRM_AddonGlobals.pause = true;
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton , "RIGHT" , 6 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton:SetWidth( 74 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton.GRM_SetUnknownButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton.GRM_SetUnknownButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton.GRM_SetUnknownButtonText:SetText ( GRM.L ( "Unknown" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" and not GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:IsVisible() then
            local buttonText = GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:GetText();
            if buttonText == GRM.L ( "Set Join Date" ) or buttonText == GRM.L ( "Edit Join Date" ) then
                GRM.ClearJoinDateHistory ( GRM_AddonGlobals.currentName , true );
                GRM.DateSubmitCancelResetLogic( true , "join" , false , nil);
            elseif buttonText == GRM.L ( "Set Promo Date" ) or buttonText == GRM.L ( "Edit Promo Date" ) then
                GRM.ClearPromoDateHistory( GRM_AddonGlobals.currentName , true );
                GRM.DateSubmitCancelResetLogic( true , "promo" , false , nil );
            end

            if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                GRM.RefreshAuditFrames();
            end
        end    
    end);
    
  
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" and not GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:IsVisible() then
            GRM.DateSubmitCancelResetLogic( false , nil , false , nil );
        end
    end);

    if not isManualUpdate then
        DropDownList1Backdrop:HookScript ( "OnShow" , function() 
            if GuildMemberRankDropdownText:IsVisible() then
                GRM_AddonGlobals.CurrentRank = GuildMemberRankDropdownText:GetText();
            end
        end);
    end
    
    -- Name Text
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetPoint( "TOP" , 0 , -20 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetFont (  GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );

    -- LEVEL Text
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel:SetPoint ( "TOP" , 0 , -38 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel:SetFont (  GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    -- Rank promotion date text
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:SetPoint ( "TOP" , 0 , -54 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:SetFont (  GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );

    -- "MEMBER SINCE"
    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt , "BOTTOM" , 0 , -2 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetWidth ( 55 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetJustifyH ( "CENTER" );

    -- "LAST ONLINE" 
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTitleTxt:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData , 16 , -22 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTitleTxt:SetText ( GRM.L ( "Last Online" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTitleTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTitleTxt , "BOTTOM" , -2 , -2 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetWidth ( 65 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetJustifyH ( "CENTER" );
    
    -- PLAYER STATUS
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt , "BOTTOM" , 0 , - 18 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetWidth ( 50 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetWordWrap ( false );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    -- ZONE
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData , 18 , 60 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetText ( GRM.L ( "Zone:" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText , "RIGHT" , 2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText , "BOTTOM" , 10 , -2 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetText ( GRM.L ( "Time In:" ) .. " " );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1 , "RIGHT" , 2 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    
    -- Is Main Note!
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData , 0 , -12 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:SetText ( GRM.L ( "( Main )" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );

    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt , "BOTTOM" , 0 , -4 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    
    -- Join Date Button Logic for visibility
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_MemberDetailMetaData , -14 , -22 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:SetText ( GRM.L ( "Date Joined" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_MemberDetailMetaData , -19 , - 32 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:SetSize ( 60 , 17 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButtonText:SetText ( GRM.L ( "Join Date?" ) )
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            self:Hide();
            if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsVisible() then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
            elseif GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:IsVisible() then
                GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
            end
            GRM.SetDateSelectFrame ( "JoinDate" );  -- Position, Frame, ButtonName
            GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
            GRM_AddonGlobals.pause = true;
        end
    end);

    -- GROUP INVITE BUTTON
    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_MemberDetailMetaData , 16, 13 )
    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetSize ( 88 , 19 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton );
    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
        
    GuildMemberDetailFrame:SetScript ( "OnShow" , function( self )
        if not IsShiftKeyDown() then
            GRM_AddonGlobals.pause = true;
            self:SetPoint ( "TOPLEFT" , GuildRosterFrame , "TOPRIGHT" , 0 , 2 );
            GRM_UI.GRM_MemberDetailMetaData:SetPoint ( "TOPLEFT" , self , "TOPRIGHT" , -4 , 5 );
        else
            self:Hide();
        end
    end);

    if not isManualUpdate then
        GuildMemberDetailFrame:HookScript ( "OnUpdate" , function ( self , elapsed ) 
            GRM_AddonGlobals.timer4 = GRM_AddonGlobals.timer4 + elapsed;
            if GRM_AddonGlobals.timer4 >= 0.05 then
                if GetCurrentKeyBoardFocus() ~= nil and IsShiftKeyDown() and IsMouseButtonDown ( 1 ) then
                    -- Add Logic... if needed for future use
                    self:Hide();
                else
                    GRM_AddonGlobals.pause = true;
                    local name = GuildMemberDetailName:GetText();
                    if name ~= GRM_AddonGlobals.currentName then
                        GRM_AddonGlobals.currentName = name;
                        GRM.ClearAllFrames( false );
                        GRM.PopulateMemberDetails ( name );
                    end
                end
                GRM_AddonGlobals.timer4 = 0;
            end 
        end);
        GuildMemberRankDropdownButton:HookScript ( "OnClick" , function()
            GRM_AddonGlobals.currentName = GuildMemberDetailName:GetText();
        end)
        GuildMemberRemoveButton:HookScript ( "OnClick" , function()
            GRM_UI.GRM_PopupWindow:Show();
        end);
    end

    GuildMemberDetailFrame:SetScript ( "OnHide" , function()
        GRM_UI.GRM_PopupWindow:Hide();
        GRM.RemoveRosterButtonHighlights();
        GRM_UI.GRM_MemberDetailMetaData:SetPoint ( "TOPLEFT" , GuildRosterFrame , "TOPRIGHT" , -4 , 5 );
    end);

    GuildMemberDetailFrame:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
        end
    end);


    -- player note edit box and font string (31 characters)
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow , "TOPLEFT" , 5 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle:SetText ( GRM.L ( "Note:" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle:SetWidth ( 120 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNoteTitle:SetWordWrap ( false );

    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow , "TOPLEFT" , 5 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle:SetText ( GRM.L ( "Officer's Note:" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle:SetWidth ( 120 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailONoteTitle:SetWordWrap ( false );

    -- OFFICER AND PLAYER NOTES
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow:SetPoint( "LEFT" , GRM_UI.GRM_MemberDetailMetaData , 15 , 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow , 9 , -11 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetWordWrap ( true );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetSpacing ( 1 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetWidth ( 108 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetJustifyH ( "LEFT" );

    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow:SetBackdrop ( GRM_UI.noteBackdrop );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow:SetSize ( 125 , 40 );
    
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetPoint( "LEFT" , GRM_UI.GRM_MemberDetailMetaData , 15 , 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetSize ( 125 , 45 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetMaxLetters ( 31 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetMultiLine( true );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetSpacing ( 1 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:EnableMouse( true );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetPoint ("TOPRIGHT" , GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow , -6 , 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );

    -- Officer Note
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow:SetPoint( "RIGHT" , GRM_UI.GRM_MemberDetailMetaData , -15 , 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow , 9 , -11 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetWordWrap ( true );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetSpacing ( 1 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetWidth ( 108 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetJustifyH ( "LEFT" );

    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow:SetBackdrop ( GRM_UI.noteBackdrop );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow:SetSize ( 125 , 40 );
    
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetPoint( "RIGHT" , GRM_UI.GRM_MemberDetailMetaData , -15 , 10 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetSize ( 125 , 45 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetMaxLetters ( 31 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetMultiLine( true );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetSpacing ( 1 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:EnableMouse( true );
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetFrameStrata ( "HIGH" );
    
    -- Script handlers on Note Edit Boxes
    local defNotes = {};
    defNotes.defaultNote = GRM.L ( "Click here to set a Public Note" );
    defNotes.defaultONote = GRM.L ( "Click here to set an Officer's Note" );
    defNotes.tempNote = "";
    defNotes.finalNote = "";

    -- Script handlers on Note Frames
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteWindow:SetScript ( "OnMouseDown" , function ( self , button ) 
        if button == "LeftButton" and CanEditPublicNote() then 
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetPoint ("TOPRIGHT" , self , -6 , 8 );
            GRM_AddonGlobals.pause = true;
            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
            defNotes.tempNote = GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:GetText();
            if defNotes.tempNote ~= defNotes.defaultONote and defNotes.tempNote ~= "" then
                defNotes.finalNote = defNotes.tempNote;
            else
                defNotes.finalNote = "";
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText( defNotes.finalNote );
            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:Show();
            GRM_AddonGlobals.CharCount = #GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:GetText();

            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText( #GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:GetText() .. "/31");
            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:Show();
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Show();
        end 
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteWindow:SetScript ( "OnMouseDown" , function ( self , button ) 
        if button == "LeftButton" and CanEditOfficerNote() then
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetPoint ("TOPRIGHT" , self , -6 , 8 );
            GRM_AddonGlobals.pause = true;
            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:Hide();
            defNotes.tempNote = GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:GetText();
            if defNotes.tempNote ~= defNotes.defaultNote and defNotes.tempNote ~= "" then
                defNotes.finalNote = defNotes.tempNote;
            else
                defNotes.finalNote = "";
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetText( defNotes.finalNote );
            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:Show();
            GRM_AddonGlobals.CharCount = #GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:GetText()

             -- How many characters initially
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText( #GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:GetText() .. "/31" );
            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:Show();
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Show();
        end 
    end);

    -- Method:          GRM_UI.PlayerPublicNoteEditBox()
    -- What it Does:    Performs the exit note logic where it does not save the public note
    -- Purpose:         Repeat use, clean logic use
    GRM_UI.PlayerPublicNoteEditBox = function()
        GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
        defNotes.tempNote = GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:GetText();
        if defNotes.tempNote ~= defNotes.defaultNote and defNotes.tempNote ~= "" then
            defNotes.finalNote = defNotes.tempNote;
        else
            defNotes.finalNote = "";
        end
        GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetText ( defNotes.finalNote );
        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:Show();
        if GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end

    -- Cancels editing in Note editbox
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetScript ( "OnEscapePressed" , GRM_UI.PlayerPublicNoteEditBox );

    -- Updates char count as player types.
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetScript ( "OnChar" , function ( self ) 
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText ( #self:GetText() .. "/31" );
    end);

    -- Update on backspace/delte changes too  
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more process efficient to have 2.
        if ( text == "BACKSPACE" and self:GetCursorPosition() ~= 0 ) or ( text == "DELETE" and self:GetCursorPosition() ~= GRM_AddonGlobals.CharCount ) then
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText ( #self:GetText() -1 .. "/31");
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetScript ( "OnKeyUp" , function ( self )
        GRM_AddonGlobals.CharCount = #self:GetText(); 
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText ( #self:GetText() .. "/31");
    end);

    -- Updating the new information to Public Note
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetScript ( "OnEnterPressed" , function ( self ) 
        local playerDetails = {};
        playerDetails.newNote = self:GetText();
        playerDetails.name = GRM_AddonGlobals.currentName;
        
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerDetails.name then         -- Player Found and Located.
                -- -- First, let's add the change to the official server-sde note
                for h = 1 , GRM.GetNumGuildies() do
                    local playerName ,_,_,_,_,_, publicNote = GetGuildRosterInfo( h );
                    if playerName == playerDetails.name and publicNote ~= playerDetails.newNote and CanEditPublicNote() then      -- No need to update old note if it is the same.
                        GRM_AddonGlobals.changeHappenedExitScan = true;

                        -- Saving the changes!
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][7] = playerDetails.newNote;          -- Metadata
                        GuildRosterSetPublicNote ( h , playerDetails.newNote );                                                                 -- Server Side

                        -- To metadata reporting
                        local logReport = "";
                        local simpleName = GRM.GetStringClassColorByName ( playerDetails.name ) .. GRM.SlimName ( playerDetails.name ) .. "|r";
                        if publicNote == "" then
                            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Added" , simpleName , nil , nil , playerDetails.newNote ) );
                        elseif playerDetails.newNote == "" then
                            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Removed" , simpleName , nil , nil , publicNote ) );
                        else
                            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" to \"{custom2}\"" , simpleName , nil , nil , publicNote , playerDetails.newNote ) );
                        end

                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
                            GRM.PrintLog ( 4 , logReport , false );
                        end
                        -- Also adding it to the log!
                        GRM.AddLog ( 4 , logReport );

                        if #playerDetails.newNote == 0 then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( defNotes.defaultNote );
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( playerDetails.newNote );
                        end
                        self:SetText( playerDetails.newNote );

                        -- and if the event log window is open, might as well build it!
                        GRM.BuildLogComplete();
                        break;
                    end
                end
                break;
            end
        end

        self:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:Show();
        if GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end);

    -- Method:          GRM_UI.EscapeOfficerNoteEditBox ( EdiitBox )
    -- What it Does:    Holds the logic for the editbox
    -- Purpose:         For repeat use...
    GRM_UI.EscapeOfficerNoteEditBox = function ()
        GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
        defNotes.tempNote = GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:GetText();
        if defNotes.tempNote ~= defNotes.defaultONote and defNotes.tempNote ~= "" then
            defNotes.finalNote = defNotes.tempNote;
        else
            defNotes.finalNote = "";
        end
        GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText( defNotes.finalNote );
        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:Show();
        if GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end

    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetScript ( "OnEscapePressed" , GRM_UI.EscapeOfficerNoteEditBox );
    
    -- Updates char count as player types.
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetScript ( "OnChar" , function ( self ) 
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText( #self:GetText() .. "/31" );
    end);

    -- Update on backspace/delte changes too  
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more process efficient to have 2.
        if ( text == "BACKSPACE" and self:GetCursorPosition() ~= 0 ) or ( text == "DELETE" and self:GetCursorPosition() ~= GRM_AddonGlobals.CharCount ) then
            GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText ( #self:GetText() - 1 .. "/31");
        end
    end);

    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetScript ( "OnKeyUp" , function ( self )
        GRM_AddonGlobals.CharCount = #self:GetText(); 
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:SetText ( #self:GetText() .. "/31");
    end);

     -- Updating the new information to Public Note
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetScript ( "OnEnterPressed" , function ( self ) 
        local playerDetails = {};
        playerDetails.newNote = self:GetText();
        playerDetails.name = GRM_AddonGlobals.currentName;
        
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerDetails.name then         -- Player Found and Located.
                -- -- First, let's add the change to the official server-sde note
                for h = 1 , GRM.GetNumGuildies() do
                    local playerName ,_,_,_,_,_,_, officerNote = GetGuildRosterInfo( h );
                    if playerName == playerDetails.name and officerNote ~= playerDetails.newNote and CanEditOfficerNote() then      -- No need to update old note if it is the same.
                        GRM_AddonGlobals.changeHappenedExitScan = true;

                        -- Saving the new note details!
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] = playerDetails.newNote;      -- to addon metadata
                        GuildRosterSetOfficerNote ( h , playerDetails.newNote );                                                            -- to server side officer note save.
                        
                        -- To metadata reporting
                        local logReport = "";
                        local simpleName = GRM.GetStringClassColorByName ( playerDetails.name ) .. GRM.SlimName ( playerDetails.name ) .. "|r";
                        if officerNote == "" then
                            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Added" , simpleName , nil , nil , playerDetails.newNote ) );
                        elseif playerDetails.newNote == "" then
                            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Removed" , simpleName , nil , nil , officerNote ) );
                        else
                            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" to \"{custom2}\"" , simpleName , nil , nil , officerNote , playerDetails.newNote ) );
                        end
                        
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
                            GRM.PrintLog ( 5 , logReport , false );
                        end
                        -- Also adding it to the log!
                        GRM.AddLog ( 5 , logReport );
                        
                        if #playerDetails.newNote == 0 then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( defNotes.defaultONote );
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( playerDetails.newNote );
                        end
                        self:SetText( playerDetails.newNote );

                        -- and if the event log window is open, might as well build it!
                        GRM.BuildLogComplete();
                        break;
                    end
                end
                break;
            end
        end

        self:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:Show();
        if GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end);

    
    -- GRM_UI.GRM_PlayerCustomNoteWindow:SetPoint( "LEFT" , GRM_UI.GRM_MemberDetailMetaData , 15 , -70 );
    -- GRM_UI.GRM_PlayerCustomNoteWindow:SetBackdrop ( GRM_UI.noteBackdrop );
    -- GRM_UI.GRM_PlayerCustomNoteWindow:SetSize ( 125 , 105 );

    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetPoint ( "TOPLEFT" , GRM_UI.GRM_PlayerCustomNoteWindow , 9 , -11 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetWordWrap ( true );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetSpacing ( 1 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetWidth ( 108 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetJustifyH ( "LEFT" );
    
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetPoint( "LEFT" , GRM_UI.GRM_MemberDetailMetaData , 15 , 10 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetSize ( 125 , 45 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetMaxLetters ( 31 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetMultiLine( true );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetSpacing ( 1 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:EnableMouse( true );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetFrameStrata ( "HIGH" );
    
end



-- Method:                  GR_MetaDataInitializeUISecond( boolean )
-- What it Does:            Initializes "More of the frames values/scripts"
-- Purpose:                 Can only have 60 "up-values" in one function. This splits it up.
GRM_UI.GR_MetaDataInitializeUISecond = function( isManualUpdate )

    -- CUSTOM 
    GRM_UI.GRM_PopupWindow:SetPoint ( "TOP" , StaticPopup1 , "BOTTOM" , 0 , 1 );
    GRM_UI.GRM_PopupWindow:EnableMouse ( true );
    GRM_UI.GRM_PopupWindow:EnableKeyboard ( true );
    GRM_UI.GRM_PopupWindow:SetToplevel ( true );
    GRM_UI.GRM_PopupWindow:SetFrameStrata ( "HIGH" );

    GRM_UI.GRM_PopupWindowCheckButton1:SetPoint ( "TOPLEFT" , GRM_UI.GRM_PopupWindow , 15 , -10 );
    GRM_UI.GRM_PopupWindowCheckButtonText:SetPoint ( "RIGHT" , GRM_UI.GRM_PopupWindowCheckButton1 , 65 , 0 );
    GRM_UI.GRM_PopupWindowCheckButtonText:SetText ( GRM.L ( "Ban Player?" ) );
    GRM_UI.GRM_PopupWindowCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_PopupWindowCheckButtonText:SetTextColor ( 1 , 0 , 0 , 1 );

    GRM_UI.GRM_PopupWindowCheckButton2:SetPoint ( "TOP" , GRM_UI.GRM_PopupWindowCheckButton1 , "BOTTOM" , 0 , 0 );
    GRM_UI.GRM_PopupWindowCheckButton2Text:SetPoint ( "TOPLEFT" , GRM_UI.GRM_PopupWindowCheckButtonText , "BOTTOMLEFT" , 0 , -15 );
    GRM_UI.GRM_PopupWindowCheckButton2Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_PopupWindowCheckButton2Text:SetTextColor ( 1 , 0 , 0 , 1 );

    GRM_UI.GRM_PopupWindowCheckButton2:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if self:GetChecked() ~= true then
                GRM_AddonGlobals.isChecked2 = false;
            else
                GRM_AddonGlobals.isChecked2 = true;
            end
        end
    end);

    GRM_UI.GRM_PopupWindow:SetScript( "OnShow" , function() 
        GRM_UI.GRM_PopupWindowCheckButton1:SetChecked ( false );
        GRM_UI.GRM_PopupWindowCheckButton2:SetChecked ( false );
        GRM_UI.GRM_PopupWindowCheckButton2:Hide();
        GRM_UI.GRM_MemberDetailEditBoxFrame:Hide();
        GRM_UI.GRM_PopupWindow:SetSize ( 320 , 45 );
        GRM_AddonGlobals.isChecked = false;
        GRM_AddonGlobals.isChecked2 = false;
        GRM_AddonGlobals.pause = true;
    end);

    if not isManualUpdate then
        StaticPopup1:HookScript ( "OnHide" , function()
            if GRM_UI.GRM_PopupWindow:IsVisible() then
                GRM_UI.GRM_PopupWindow:Hide();
            end
        end);
    end

    -- Popup EDIT BOX
    GRM_UI.GRM_MemberDetailEditBoxFrame:SetPoint ( "TOP" , GRM_UI.GRM_PopupWindow , "BOTTOM" , 0 , 3 );
    GRM_UI.GRM_MemberDetailEditBoxFrame:SetSize ( 320 , 73 );

    GRM_UI.GRM_MemberDetailPopupEditBox:SetPoint( "CENTER" , GRM_UI.GRM_MemberDetailEditBoxFrame );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetSize ( 224 , 63  );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetMaxLetters ( 75 );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetTextColor ( 1 , 1 , 1 , 1 );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_MemberDetailPopupEditBox:EnableMouse( true );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetMultiLine( true );
    GRM_UI.GRM_MemberDetailPopupEditBox:SetSpacing ( 1 );

    -- Script handler for General popup editbox.
    GRM_UI.GRM_MemberDetailPopupEditBox:SetScript ( "OnEscapePressed" , function ()
        GRM_UI.GRM_MemberDetailEditBoxFrame:Hide();
        GRM_UI.GRM_PopupWindowCheckButton1:Click();
        GRM_UI.GRM_PopupWindowCheckButton2:SetChecked ( false );
        GRM_UI.GRM_PopupWindowCheckButton2:Hide();
        GRM_UI.GRM_PopupWindow:SetSize ( 320 , 45 );
    end);

    GRM_UI.GRM_PopupWindowCheckButton1:SetScript ( "OnHide" , function ()
        C_Timer.After ( 1 , function()
            GRM_AddonGlobals.isChecked = false;
            GRM_AddonGlobals.isChecked2 = false;
        end);
    end);

    GRM_UI.GRM_PopupWindowCheckButton1:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_PopupWindowCheckButton1:GetChecked() ~= true then
                GRM_UI.GRM_MemberDetailEditBoxFrame:Hide();
                GRM_AddonGlobals.isChecked = false;
                GRM_AddonGlobals.isChecked2 = false;
                GRM_UI.GRM_PopupWindowCheckButton2:SetChecked ( false );
                GRM_UI.GRM_PopupWindowCheckButton2:Hide();
                GRM_UI.GRM_PopupWindow:SetSize ( 320 , 45 );                
            else
                GRM_AddonGlobals.isChecked = true;
                GRM_UI.GRM_MemberDetailPopupEditBox:SetText ( GRM.L ( "Reason Banned?" ) .. "\n" .. GRM.L ( "Click \"YES\" When Done" ) );
                GRM_UI.GRM_MemberDetailPopupEditBox:HighlightText ( 0 );
                GRM_UI.GRM_MemberDetailEditBoxFrame:Show();
                GRM_UI.GRM_MemberDetailPopupEditBox:Show();

                -- Check if player has alts...
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.currentName then
                        local numAlts = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11];
                        if numAlts > 0 then
                            if numAlts > 1 then
                                GRM_UI.GRM_PopupWindowCheckButton2Text:SetText ( GRM.L ( "Ban the Player's {num} alts too?" , nil , nil , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11] ) );
                            else
                                GRM_UI.GRM_PopupWindowCheckButton2Text:SetText ( GRM.L ( "Ban the Player's {num} alt too?" , nil , nil , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11] ) );
                            end
                            GRM_UI.GRM_PopupWindow:SetSize ( 320 , 70 );
                            GRM_UI.GRM_PopupWindowCheckButton2:Show();
                        end
                        break;
                    end
                end
            end
        end
    end);

    GRM_UI.GRM_MemberDetailPopupEditBox:SetScript ( "OnEnterPressed" , function ( _ )
        -- If kick alts button is checked...
        GRM.Report ( GRM.L ( "Please Click \"Yes\" to Ban the Player!" ) );
    end);

    -- Heads-up text if player was previously banned
    GRM_UI.GRM_MemberDetailBannedText1:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_MemberDetailMetaData , "TOPLEFT" , 13 , -2 );
    GRM_UI.GRM_MemberDetailBannedText1:SetWordWrap ( true );
    GRM_UI.GRM_MemberDetailBannedText1:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_MemberDetailBannedText1:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GRM_UI.GRM_MemberDetailBannedText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8.0 );
    GRM_UI.GRM_MemberDetailBannedText1:SetWidth ( 300 );
    GRM_UI.GRM_MemberDetailBannedText1:SetText ( GRM.L ( "WARNING!" ) .. "\n" .. GRM.L ( "Player Was Previously Banned!" ) );
    GRM_UI.GRM_MemberDetailBannedIgnoreButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MemberDetailMetaData , 11 , -5 );
    GRM_UI.GRM_MemberDetailBannedIgnoreButton:SetWidth ( 85 );
    GRM_UI.GRM_MemberDetailBannedIgnoreButton:SetHeight ( 15 );
    GRM_UI.GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailBannedIgnoreButton );
    GRM_UI.GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8.5 );
    GRM_UI.GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetText ( GRM.L ( "Ignore Ban" ) );
    
    
    -- ALT FRAME DETAILS!!!
    GRM_UI.GRM_CoreAltFrame:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_MemberDetailMetaData , -13.5 , 16 );
    GRM_UI.GRM_CoreAltFrame:SetSize ( 128 , 140 );
    GRM_UI.GRM_CoreAltFrame:SetParent ( GRM_UI.GRM_MemberDetailMetaData );
       -- ALT FRAME SCROLL OPTIONS
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:SetSize ( 128 , 105 );
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_MemberDetailMetaData , -13.5 , 33 );
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:SetScrollChild ( GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetSize( 12 , 86 );
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame , "TOPRIGHT" , -10 , -10 );
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetValue( 0 );
    GRM_CoreAltScrollFrameSliderScrollUpButton:SetSize ( 12 , 10 );
    GRM_CoreAltScrollFrameSliderScrollDownButton:SetSize ( 12 , 10 );
    GRM_CoreAltScrollFrameSliderThumbTexture:SetSize ( 12 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:SetVerticalScroll( self:GetValue() )
    end);

    GRM_UI.GRM_altFrameTitleText:SetPoint ( "TOP" , GRM_UI.GRM_CoreAltFrame , 3 , -4 );
    GRM_UI.GRM_altFrameTitleText:SetText ( GRM.L ( "Player Alts" ) );    
    GRM_UI.GRM_altFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 , "THICKOUTLINE" );

    GRM_UI.GRM_AddAltButton:SetSize ( 60 , 17 );
    GRM_UI.GRM_AddAltButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_AddAltButton );
    GRM_UI.GRM_AddAltButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_AddAltButtonText:SetText( GRM.L ( "Add Alt" ) ) ; 

    GRM_UI.GRM_AddAltButton2:SetSize ( 60 , 17 );
    GRM_UI.GRM_AddAltButton2Text:SetPoint ( "CENTER" , GRM_UI.GRM_AddAltButton2 );
    GRM_UI.GRM_AddAltButton2Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_AddAltButton2Text:SetText( GRM.L ( "Add Alt" ) ) ; 

    GRM_UI.GRM_CoreAltFrame.GRM_AltName1:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame , 1 , -20 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName1:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName1:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName2:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_CoreAltFrame , 0 , -20 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName2:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName2:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName3:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame , 1 , -37 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName3:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName3:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName4:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_CoreAltFrame , 0 , -37 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName4:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName4:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName4:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName5:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame , 1 , -54 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName5:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName5:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName5:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName6:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_CoreAltFrame , 0 , -54 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName6:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName6:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName6:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName7:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame , 1 , -71 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName7:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName7:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName7:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName8:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_CoreAltFrame , 0 , -71 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName8:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName8:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName8:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName9:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame , 1 , -88 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName9:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName9:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName9:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName10:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_CoreAltFrame , 0 , -88 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName10:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName10:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName10:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName11:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame , 1 , -105 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName11:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName11:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName11:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_UI.GRM_CoreAltFrame.GRM_AltName12:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_CoreAltFrame , 0 , -105 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName12:SetWidth ( 60 );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName12:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreAltFrame.GRM_AltName12:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    -- ALT DROPDOWN OPTIONS
    GRM_UI.GRM_altDropDownOptions:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_MemberDetailMetaData , 15 , 0 );
    GRM_UI.GRM_altDropDownOptions:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_altDropDownOptions:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_UI.GRM_altOptionsText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -13 );
    GRM_UI.GRM_altOptionsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_altOptionsText:SetText ( GRM.L ( "Options" ) );
    GRM_UI.GRM_altSetMainButton:SetPoint ("TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -22 );
    GRM_UI.GRM_altSetMainButton:SetSize ( 60 , 20 );
    GRM_UI.GRM_altSetMainButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_altSetMainButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_altSetMainButton );
    GRM_UI.GRM_altSetMainButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_altRemoveButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -36 );
    GRM_UI.GRM_altRemoveButton:SetSize ( 60 , 20 );
    GRM_UI.GRM_altRemoveButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_altRemoveButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_altRemoveButton );
    GRM_UI.GRM_altRemoveButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_altRemoveButtonText:SetText( GRM.L ( "Remove" ) );
    GRM_UI.GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -55 );
    GRM_UI.GRM_altOptionsDividerText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_altOptionsDividerText:SetText ("__");
    GRM_UI.GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_altDropDownOptions , 7 , -65 );
    GRM_UI.GRM_altFrameCancelButton:SetSize ( 60 , 20 );
    GRM_UI.GRM_altFrameCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_altFrameCancelButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_altFrameCancelButton );
    GRM_UI.GRM_altFrameCancelButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_altFrameCancelButtonText:SetText ( GRM.L ( "Cancel" ) );

    -- REQUEST TO JOIN WINDOW
    GRM_UI.GRM_RequestToJoinWindow:Hide();
    GRM_UI.GRM_RequestToJoinWindow:SetFrameStrata ( "HIGH" );

    if not isManualUpdate then
        GuildInfoFrameApplicants:HookScript ( "OnShow" , function()
            GRM.CheckRequestPlayersIfOnline ( GRM.GetGuildApplicantNames() );
            GRM_AddonGlobals.requestToJoinTimeInterval = 15;     -- Temporarily check every 5 seconds...
            GRM_UI.GRM_RequestToJoinWindow:Show();
        end);

        GuildInfoFrameApplicants:HookScript ( "OnHide" , function()
            GRM_AddonGlobals.requestToJoinTimeInterval = 60;    -- Reset it back to normal...
            GRM_UI.GRM_RequestToJoinWindow:Hide();
            GRM_UI.GRM_RequestToJoinWindow.allFontStrings[1]:Hide();
        end);
    end

    GRM_UI.GRM_RequestToJoinWindow:SetScript ( "OnShow" , function()
        GRM_UI.GRM_RequestToJoinWindow.allFontStrings = GRM_UI.GRM_RequestToJoinWindow.allFontStrings or {};
        local numRequestTojoinButtons = 6;

        for i = 1 , numRequestTojoinButtons do
            if not GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i] then
                if i == 1 then
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i] = GRM_UI.GRM_RequestToJoinWindow:CreateFontString ( "GRM_NeedFriendsCleanedUpWarning" , "OVERLAY" , "GameFontNormal" );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetPoint ( "BOTTOM" , GuildInfoFrameApplicantsContainer , "TOP" , 20 , 19)
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetText ( GRM.L ( "Please free up spaces on your friends list to utilize all GRM features" ) );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetTextColor ( 1 , 0 , 0 , 1 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetWidth( 180 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:Hide();
                    
                elseif i == 2 then
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i] = GRM_UI.GRM_RequestToJoinWindow:CreateFontString ( "GRM_ReqToJoinText" .. i - 1 , "OVERLAY" , "GameFontNormal" );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetPoint ( "BOTTOMRIGHT" , GuildInfoFrameApplicantsContainerButton1 , "BOTTOMRIGHT" , - 15 , 8 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
                elseif i == 3 then
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i] = GRM_UI.GRM_RequestToJoinWindow:CreateFontString ( "GRM_ReqToJoinText" .. i - 1 , "OVERLAY" , "GameFontNormal" );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetPoint ( "BOTTOMRIGHT" , GuildInfoFrameApplicantsContainerButton2 , "BOTTOMRIGHT" , - 15 , 8 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
                elseif i == 4 then
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i] = GRM_UI.GRM_RequestToJoinWindow:CreateFontString ( "GRM_ReqToJoinText" .. i - 1 , "OVERLAY" , "GameFontNormal" );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetPoint ( "BOTTOMRIGHT" , GuildInfoFrameApplicantsContainerButton3 , "BOTTOMRIGHT" , - 15 , 8 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
                elseif i == 5 then
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i] = GRM_UI.GRM_RequestToJoinWindow:CreateFontString ( "GRM_ReqToJoinText" .. i - 1 , "OVERLAY" , "GameFontNormal" );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetPoint ( "BOTTOMRIGHT" , GuildInfoFrameApplicantsContainerButton4 , "BOTTOMRIGHT" , - 15 , 8 );
                    GRM_UI.GRM_RequestToJoinWindow.allFontStrings[i]:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
                end
            end
        end
    end);
    

    GRM_UI.GRM_RequestToJoinWindow:SetScript ( "OnUpdate" , function ( self , elapsed ) 
        GRM_AddonGlobals.requestToJoinTimer = GRM_AddonGlobals.requestToJoinTimer + elapsed;
        if GRM_AddonGlobals.requestToJoinTimer > 0.05 then

            if GetNumFriends() < 100 then
                local online = string.upper ( GRM.L ( "Online" ) );
                local offline = string.upper ( GRM.L ( "Offline" ) );
                local color = { 0.12 , 1 , 0 };
                local color2 = { 1 , 0.82 , 0 };
                -- GRM.IsRequestToJoinPlayerCurrentlyOnline

                -- Ok, let's cycle each of the 5 buttons now...
                if GuildInfoFrameApplicantsContainerButton1:IsVisible() then
                    if GRM.IsRequestToJoinPlayerCurrentlyOnline ( GuildInfoFrameApplicantsContainerButton1Name:GetText() ) then
                        self.allFontStrings[2]:SetText ( online );
                        self.allFontStrings[2]:SetTextColor ( color[1] , color[2] , color[3] , 1 );
                        self.allFontStrings[2]:Show();
                    else
                        self.allFontStrings[2]:SetTextColor ( color2[1] , color2[2] , color2[3] , 1 );
                        self.allFontStrings[2]:SetText ( offline );
                    end
                else
                    self.allFontStrings[2]:Hide();
                end
                if GuildInfoFrameApplicantsContainerButton2:IsVisible() then
                    if GRM.IsRequestToJoinPlayerCurrentlyOnline ( GuildInfoFrameApplicantsContainerButton2Name:GetText() ) then
                        self.allFontStrings[3]:SetText ( online );
                        self.allFontStrings[3]:SetTextColor ( color[1] , color[2] , color[3] , 1 );
                        self.allFontStrings[3]:Show();
                    else
                        self.allFontStrings[3]:SetTextColor ( color2[1] , color2[2] , color2[3] , 1 );
                        self.allFontStrings[3]:SetText ( offline );
                    end
                else
                    self.allFontStrings[3]:Hide();
                end
                if GuildInfoFrameApplicantsContainerButton3:IsVisible() then
                    if GRM.IsRequestToJoinPlayerCurrentlyOnline ( GuildInfoFrameApplicantsContainerButton3Name:GetText() ) then
                        self.allFontStrings[4]:SetText ( online );
                        self.allFontStrings[4]:SetTextColor ( color[1] , color[2] , color[3] , 1 );
                        self.allFontStrings[4]:Show();
                    else
                        self.allFontStrings[4]:SetTextColor ( color2[1] , color2[2] , color2[3] , 1 );
                        self.allFontStrings[4]:SetText ( offline );
                    end
                else
                    self.allFontStrings[4]:Hide();
                end
                if GuildInfoFrameApplicantsContainerButton4:IsVisible() then
                    if GRM.IsRequestToJoinPlayerCurrentlyOnline ( GuildInfoFrameApplicantsContainerButton4Name:GetText() ) then
                        self.allFontStrings[5]:SetText ( online );
                        self.allFontStrings[5]:SetTextColor ( color[1] , color[2] , color[3] , 1 );
                        self.allFontStrings[5]:Show();
                    else
                        self.allFontStrings[5]:SetTextColor ( color2[1] , color2[2] , color2[3] , 1 );
                        self.allFontStrings[5]:SetText ( offline );
                    end
                else
                    self.allFontStrings[5]:Hide();
                end
            else
                for i = 2 , #self.allFontStrings do
                    self.allFontStrings[i]:Hide();
                end
                self.allFontStrings[1]:Show();
            end
            GRM_AddonGlobals.requestToJoinTimer = 0;
        end
    end);
end

-- Method:                  GR_MetaDataInitializeUIThird( boolean )
-- What it Does:            Initializes "More of the frames values/scripts"
-- Purpose:                 Can only have 60 "up-values" in one function. This splits it up.
GRM_UI.GR_MetaDataInitializeUIThird = function( isManualUpdate )

    --ADD ALT FRAME
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_MemberDetailMetaData , "BOTTOMRIGHT" ,  -7 , 0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:SetSize ( 130 + ( #GRM_AddonGlobals.realmName * 3.5 ) , 170 );                -- Slightly wider for larger guild names.
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:SetToplevel ( true );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltTitleText:SetPoint ( "TOP" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame , 0 , - 20 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 , "THICKOUTLINE" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltTitleText:SetText ( GRM.L ( "Choose Alt" ) );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:SetPoint ( "TOP" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox , "BOTTOM" , 8 , -2 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:SetSize ( 112 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:Disable();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:SetPoint ( "LEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1 , "BOTTOMLEFT" , 0 , 0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:SetSize ( 112 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:Disable();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:SetPoint ( "LEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2 , "BOTTOMLEFT" , 0 , 0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:SetSize ( 112 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:Disable();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:SetPoint ( "LEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3 , "BOTTOMLEFT" , 0 , 0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:SetSize ( 112 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:Disable();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:SetPoint ( "LEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4 , "BOTTOMLEFT" , 0 , 0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:SetSize ( 112 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:Disable();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:SetPoint ( "LEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:SetPoint ( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5 , "BOTTOMLEFT" , 0 , 0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:SetSize ( 112 , 14 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:Disable();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetPoint ( "LEFT" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:SetPoint ( "TOP" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame , -18 , -146 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:SetText ( GRM.L ( "(Press Tab)" ) );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetPoint ( "CENTER" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetWidth ( 110 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetWordWrap ( true );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetSpacing ( 1 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:SetPoint ( "BOTTOM" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame , 0 , 30 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:SetText ( GRM.L ( "Shift-Mouseover Name On Roster Also Works" ) );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:SetWidth ( 110 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:SetWordWrap ( true );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:SetSpacing ( 1 );
        
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetPoint( "TOP" , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltTitleText , "BOTTOM" , 0 , -5 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetSize ( 95 + ( #GRM_AddonGlobals.realmName * 3.5 ) , 25 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetMaxLetters ( 40 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:EnableMouse( true );
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetAutoFocus( false );

    -- ALT EDIT BOX LOGIC
    GRM_UI.GRM_AddAltButton:SetScript ( "OnClick" , function ( _ , button) 
        if button == "LeftButton" then

            -- Let's see if player is at hard cap first!
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
                if GRM_AddonGlobals.currentName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] >= 75 then
                        GRM.Report ( GRM.L ( "Addon does not currently support more than 75 alts!" ) );
                    else
                        GRM_AddonGlobals.pause = true;
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetAutoFocus( true );
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText( "" );
                        GRM.AddAltAutoComplete();
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Show();
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetAutoFocus( false );
                    end
                    break;
                end
            end           
        end
    end)

    -- ALT EDIT BOX LOGIC
    GRM_UI.GRM_AddAltButton2:SetScript ( "OnClick" , function ( _ , button) 
        if button == "LeftButton" then

            -- Let's see if player is at hard cap first!
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
                if GRM_AddonGlobals.currentName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] >= 75 then
                        GRM.Report ( GRM.L ( "Addon does not currently support more than 75 alts!" ) );
                    else
                        GRM_AddonGlobals.pause = true;
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetAutoFocus( true );
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText( "" );
                        GRM.AddAltAutoComplete();
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Show();
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetAutoFocus( false );
                    end
                    break;
                end
            end           
        end
    end)


    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetScript ( "OnEscapePressed" , function( _ )
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:ClearFocus();    
    end);

    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetScript ( "OnEnterPressed" , function( _ )
        if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:HasFocus() then
            local currentText = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:GetText();
            if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:IsVisible() and ( GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:GetText() == GRM.L ( "Player Not Found" ) or GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:GetText() == GRM.L ( "Player Cannot Add Themselves as an Alt" ) ) then
                if GRM.SlimName ( GRM_AddonGlobals.currentName ) == currentText or GRM_AddonGlobals.currentName == currentText then
                    GRM.Report ( GRM.L ( "Player Cannot Add Themselves as an Alt" ) );
                end
                GRM.Report ( GRM.L ( "Please choose a VALID character to set as an Alt" ) );
            else
                if currentText ~= nil and currentText ~= "" then
                    local notFound = true;
                    if GRM_AddonGlobals.currentHighlightIndex == 1 then
                        local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:GetText();
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
                        if result ~= currentText then
                            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
                            notFound = false;
                        end
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 2 then
                        local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:GetText();
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
                        if result ~= currentText then
                            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
                            notFound = false;
                        end
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 3 then
                        local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:GetText();
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
                        if result ~= currentText then
                            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
                            notFound = false;
                        end
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 4 then
                        local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:GetText();
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
                        if result ~= currentText then
                            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
                            notFound = false;
                        end
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 5 then
                        local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:GetText();
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
                        if result ~= currentText then
                            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
                            notFound = false;
                        end
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 6 then
                        local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:GetText();
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
                        result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
                        if result ~= currentText then
                            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
                            notFound = false;
                        end
                    end
                    if notFound then
                        -- Refresh alt frames
                        local gateCheck = false;
                        if not GRM.PlayerHasAltsOrIsMain ( GRM_AddonGlobals.currentName ) or not GRM.PlayerHasAltsOrIsMain ( GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:GetText() )  then
                            gateCheck = true;
                        end
                        -- Add the alt here, Hide the frame
                        GRM.AddAlt ( GRM_AddonGlobals.currentName , GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:GetText() , GRM_AddonGlobals.guildName , false , 0 );

                        -- This gate is important because if I had looked if they had alts after they were added, it would return true, and I need to know before
                        -- However, I don't want to refresh the audit frames until AFTER the alt is added.
                        if gateCheck then
                            if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                                GRM.RefreshAuditFrames();
                            end
                        end

                        -- Communicate the changes!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                            GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_ADDALT?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_AddonGlobals.currentName .. "?" .. GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:GetText() .. "?" .. tostring ( time() ) , "GUILD");
                        end

                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:ClearFocus();
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
                    end
                else
                    GRM.Report ( GRM.L ( "Please choose a character to set as alt." ) );
                end
            end
        end
    end);

    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:GetText();
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:GetText();
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:GetText();
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:GetText();
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:GetText();
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local result = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:GetText();
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<M>" ) , "" );
            result = gsub ( result , "|cffab0000 " .. GRM.L ( "<A>" ) , "" );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText ( result );
            GRM.AddAltAutoComplete();
        end
    end);

    -- Updating with each character typed
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetScript ( "OnChar" , function () 
        GRM.AddAltAutoComplete();
    end);

    -- When pressing backspace.
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetScript ( "OnKeyDown" , function ( self , key)
        if key == "BACKSPACE" then
            local text = self:GetText();
            if text ~= nil and #text > 0 then
                self:SetText ( string.sub ( text , 0 , #text - 1 ) ); -- Bring it down by 1 for function, then return to normal.
            end
            GRM.AddAltAutoComplete();
            self:SetText( text ); -- set back to normal for normal Backspace upkey function... if I do not do this, it will delete 2 characters.
        elseif key == "DOWN" or key == "UP" then
            GRM_UI.AddAltSelectionControls ( self , key );
        end
    end);

    GRM_UI.AddAltSelectionControls = function( _ , key )
        local notSet = true;
        if key == "DOWN" or ( key ~= "UP" and IsShiftKeyDown() ~= true ) then
            if GRM_AddonGlobals.currentHighlightIndex == 1 and notSet then
                if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 2;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 2 and notSet then
                if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 3;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:LockHighlight();
                    notSet = false;
                else
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 3 and notSet then
                if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 4;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:LockHighlight();
                    notSet = false;
                else
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 4 and notSet then
                if  GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 5;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:LockHighlight();
                    notSet = false;
                else
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 5 and notSet then
                if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:GetText() ~= "..." then
                    GRM_AddonGlobals.currentHighlightIndex = 6;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:LockHighlight();
                    notSet = false;
                elseif ( GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:GetText() == "..." ) or GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:IsVisible() ~= true then
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 6 then
                GRM_AddonGlobals.currentHighlightIndex = 1;
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:UnlockHighlight();
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
                notSet = false;
            end
        elseif key == "UP" or ( key ~= "DOWN" and IsShiftKeyDown() ) then
            -- if at position 1... shift-tab goes back to any position.
            if GRM_AddonGlobals.currentHighlightIndex == 1 and notSet then
                if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:GetText() ~= "..."  and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 6;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:LockHighlight();
                    notSet = false;
                elseif ( ( GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:GetText() == "..." ) or ( GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:IsVisible() ) ) and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 5;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:LockHighlight();
                    notSet = false;
                elseif GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:IsVisible() and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 4;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:LockHighlight();
                    notSet = false;
                elseif GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:IsVisible() and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 3;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:LockHighlight();
                    notSet = false;
                elseif GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:IsVisible() and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 2;
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 2 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 1;
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:UnlockHighlight();
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 3 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 2;
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:UnlockHighlight();
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 4 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 3;
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:UnlockHighlight();
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 5 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 4;
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:UnlockHighlight();
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 6 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 5;
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:UnlockHighlight();
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:LockHighlight();
                notSet = false;
            end
        end
    end

    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetScript ( "OnTabPressed" , GRM_UI.AddAltSelectionControls );

   
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
        end
    end);

    -- ALT FRAME LOGIC
    GRM_UI.GRM_altSetMainButton:SetScript ( "OnClick" , function ( _ , button )
        
        if button == "LeftButton" then
            local altDetails = GRM_AddonGlobals.selectedAlt;
            local buttonName = GRM_UI.GRM_altSetMainButtonText:GetText();
            if buttonName == GRM.L ( "Set as Main" ) then
                if altDetails[1] ~= altDetails[2] then
                    GRM.SetMain ( altDetails[1] , altDetails[2] , false , 0 );

                    -- Now send Comm to sync details.
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                        GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_MAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                    end
                else
                    -- No need to set as main yet... let's set player to main here.
                      for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altDetails[1] then
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                                GRM.SetMain ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , altDetails[1] , false , 0 );
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_MAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] .. "?" .. altDetails[1] , "GUILD");
                                end
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = true;
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = time();
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_MAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                                end
                            end
                            -- Now send Comm to sync details.
                            
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Show();
                            break;
                        end
                    end
                end
                if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:IsVisible() and GRM_AddonGlobals.currentName ~= altDetails[2] then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Hide();
                end                
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                    GRM.RefreshAuditFrames();
                end
                GRM.Report ( GRM.L ( "{name} is now set as \"main\"" , GRM.GetClassifiedName ( altDetails[2] , true ) ) );
            elseif buttonName == GRM.L ( "Set as Alt" ) then
                if altDetails[1] ~= altDetails[2] then
                    GRM.DemoteFromMain ( altDetails[1] , altDetails[2] , false , 0 );

                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                        GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVMAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                    end
                else
                    -- No need to set as main yet... let's set player to main here.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altDetails[1] then
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                                GRM.DemoteFromMain ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , altDetails[1] , false , 0 );
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVMAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] .. "?" .. altDetails[1] , "GUILD");
                                end
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = false;
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = time();
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVMAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");        -- both alt details will be same name...
                                end
                            end
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Hide();
                            break;
                        end
                    end
                end
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                    GRM.RefreshAuditFrames();
                end
                GRM.Report ( GRM.L ( "{name} is no longer set as \"main\"" , GRM.GetClassifiedName ( altDetails[2] , true ) ) );
            elseif buttonName == GRM.L ( "Edit Date" ) then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
                if GRM_AddonGlobals.editPromoDate then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Click();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( GRM.L ( "Edit Promo Date" ) );
                elseif GRM_AddonGlobals.editJoinDate then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Hide();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Click();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( GRM.L ( "Edit Join Date" ) );
                end

            elseif buttonName == GRM.L ( "Notify When Player is Active" ) then
                GRM.AddPlayerStatusCheck ( altDetails[1] , 1 );
                GRM_AddonGlobals.pause = false;
            elseif buttonName == GRM.L ( "Notify When Player Comes Online" ) then
                GRM.AddPlayerStatusCheck ( altDetails[1] , 2 );
                GRM_AddonGlobals.pause = false;
            elseif buttonName == GRM.L ( "Notify When Player Goes Offline" ) then
                GRM.AddPlayerStatusCheck ( altDetails[1] , 3 );
                GRM_AddonGlobals.pause = false;
            end
            GRM_UI.GRM_altDropDownOptions:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
        end
    end);

    -- Also functions to clear history...
    GRM_UI.GRM_altRemoveButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local buttonName = GRM_UI.GRM_altRemoveButtonText:GetText();
            local altDetails = GRM_AddonGlobals.selectedAlt;
            if buttonName == GRM.L ( "Remove" ) then
                GRM.RemoveAlt ( altDetails[1] , altDetails[2] , false , 0 , false );
                -- Send comm out of the changes!
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                    GRM.RefreshAuditFrames();
                end
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVALT?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] .. "?" .. tostring ( time() ) , "GUILD");
                end
            elseif buttonName == GRM.L ( "Clear History" ) then
                if GRM_AddonGlobals.editPromoDate then
                    GRM.ClearPromoDateHistory ( altDetails[1] , false );
                elseif GRM_AddonGlobals.editJoinDate then
                    GRM.ClearJoinDateHistory ( altDetails[1] , false );
                end
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                    GRM.RefreshAuditFrames();
                end
            elseif buttonName == GRM.L ( "Reset Data!" ) then
                GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Reset All of {name}'s Data?" , GRM.GetClassifiedName ( altDetails[1] , true ) ) );
                GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                    if button == "LeftButton" then
                        GRM.ResetPlayerMetaData ( altDetails[1] );
                        GRM_UI.GRM_RosterConfirmFrame:Hide();
                        if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                            GRM.RefreshAuditFrames();
                        end
                    end
                end);
                GRM_UI.GRM_RosterConfirmFrame:Show();
            elseif buttonName == GRM.L ( "Notify When Player Goes Offline" ) then
                GRM.AddPlayerOfflineStatusCheck ( altDetails[1] );
            end
            GRM_UI.GRM_altDropDownOptions:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
        end
    end);

    GRM_UI.GRM_altFrameCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_UI.GRM_altDropDownOptions:Hide();
            GRM_AddonGlobals.pause = false;
        end
    end);

    GRM_UI.GRM_altDropDownOptions:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_altDropDownOptions:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_altDropDownOptions:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_altDropDownOptions:Hide();
        end
    end);

    
    -- BUTTONS
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:SetSize ( 90 , 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:SetPoint ( "BOTTOMRIGHT" , GuildFrame , "TOPRIGHT" , 0 , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButtonText:SetText ( GRM.L ( "Guild Log" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:SetScript ( "OnClick" , function ( _ , button)
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
                GRM_UI.GRM_RosterChangeLogFrame:Hide();
            else
                GRM_UI.GRM_RosterChangeLogFrame:Show();
            end
        end
    end);

    -- Show button on window open
    if not isManualUpdate then
        GuildFrame:HookScript ( "OnShow" , function ()
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:Show();
        end);

        -- Show button on window open
        GuildFrame:HookScript ( "OnHide" , function ()
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:Hide();
        end);

        -- Close Meta data window
        GuildRosterFrame:HookScript ( "OnHide" , function ()
            GRM.ClearAllFrames( true );
            GRM_UI.GRM_MemberDetailMetaData:Hide();
        end);

        -- MISC FRAMES INITIALZIATION AND LOGIC
        GuildInfoEditMOTDButton:HookScript ( "OnClick" , function( _ , button )
            if button == "LeftButton" then
                GuildTextEditBox:HighlightText( 0 );
                GRM_AddonGlobals.CharCount = GuildTextEditBox:GetNumLetters();
                GuildTextEditFrame.GuildMOTDcharCount:SetText( GRM_AddonGlobals.CharCount .. "/" .. GuildTextEditBox:GetMaxLetters() );
                GuildTextEditFrame.GuildMOTDcharCount:Show();
            end
        end);
        GuildInfoEditDetailsButton:HookScript ( "OnClick" , function( _ , button )
            if button == "LeftButton" then
                GRM_AddonGlobals.CharCount = GuildTextEditBox:GetNumLetters();
                GuildTextEditFrame.GuildMOTDcharCount:SetText( GRM_AddonGlobals.CharCount .. "/" .. GuildTextEditBox:GetMaxLetters() );
                GuildTextEditFrame.GuildMOTDcharCount:Show();
            end
        end);

        GuildTextEditBox:HookScript ( "OnEditFocusLost" , function()
            GuildTextEditFrame.GuildMOTDcharCount:Hide();
        end);

        -- Updates char count as player types.
        GuildTextEditBox:HookScript ( "OnChar" , function ( self ) 
            GuildTextEditFrame.GuildMOTDcharCount:SetText( #self:GetText() .. "/" .. self:GetMaxLetters() );
        end);

        -- Update on backspace changes too
        GuildTextEditBox:HookScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
            if ( text == "BACKSPACE" and self:GetCursorPosition() ~= 0 ) or ( text == "DELETE" and self:GetCursorPosition() ~= GRM_AddonGlobals.CharCount ) then
                GuildTextEditFrame.GuildMOTDcharCount:SetText( #self:GetText() - 1 .. "/" .. self:GetMaxLetters() );
            end
        end);

        GuildTextEditBox:SetScript ( "OnKeyUp" , function ( self )
            GRM_AddonGlobals.CharCount = #self:GetText(); 
            GuildTextEditFrame.GuildMOTDcharCount:SetText( #self:GetText() .. "/" .. self:GetMaxLetters() );
        end);

        -- It is prudent to hide the frame because it deselects, server side, the players you are pulling data from. No need to keep the addon window up as it will be showing a wrong player.
        GuildRosterShowOfflineButton:HookScript ( "OnClick" , function()
            GRM_UI.GRM_MemberDetailMetaData:Hide();
        end);
    end
    
    -- Needs to be initialized AFTER guild frame first logs or it will error, so only making it here now.
    GuildTextEditFrame.GuildMOTDcharCount = GuildTextEditFrame:CreateFontString ( "GuildMOTDcharCount" , "OVERLAY" , "GameFontNormalSmall" );
    GuildTextEditFrame.GuildMOTDcharCount:SetPoint ( "TOPRIGHT" , GuildTextEditFrame , -33 , -18 )
    GuildTextEditFrame.GuildMOTDcharCount:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );

    

    -- TOOLTIP INIT
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:SetScale ( 0.85 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:SetScale ( 0.85 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetScale ( 0.85 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:SetScale ( 0.65 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:SetScale ( 0.65 );
end

-- Method:          GRM.PreAddonLoadUI()
-- What it Does:    Initializes the core Log Frame before the addon loads
-- Purpose:         One cannot use methods like "SetUserPlaced" to carry over between sessions sunless the frame is initalized BEFORE "ADDON_LOADED" event fires.
GRM_UI.PreAddonLoadUI = function()
    GRM_UI.GRM_RosterChangeLogFrame:SetPoint ( "CENTER" , UIParent );
    GRM_UI.GRM_RosterChangeLogFrame:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame:SetSize ( 600 , 465 );
    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse ( true );
    GRM_UI.GRM_RosterChangeLogFrame:SetMovable ( true );
    GRM_UI.GRM_RosterChangeLogFrame:SetUserPlaced ( true );
    GRM_UI.GRM_RosterChangeLogFrame:SetToplevel ( true );
    -- GRM_UI.GRM_RosterChangeLogFrame:SetResizable ( true );
    GRM_UI.GRM_RosterChangeLogFrame:RegisterForDrag ( "LeftButton" );
    GRM_UI.GRM_RosterChangeLogFrame:SetScript ( "OnDragStart" , GRM_UI.GRM_RosterChangeLogFrame.StartMoving );
    GRM_UI.GRM_RosterChangeLogFrame:SetScript ( "OnDragStop" , GRM_UI.GRM_RosterChangeLogFrame.StopMovingOrSizing );

    -- OPTIONS TAB FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:SetSize ( 600 , 465 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:SetAlpha ( 0 );

    -- LOG TAB FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:SetSize ( 600 , 465 );

    -- ADDON USERS FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:SetSize ( 600 , 465 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:SetAlpha ( 0 );

    -- EVENTS TO ADD FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:SetSize ( 600 , 465 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:SetAlpha ( 0 );

    -- BAN LIST FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:SetSize ( 600 , 465 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:SetAlpha ( 0 );

    -- AUDIT FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:SetSize ( 600 , 465 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:SetAlpha ( 0 );

    -- TAB BUTTONS
    -- Change Log Tab
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetSize ( 99.2 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetFrameStrata ( "MEDIUM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetText ( GRM.L ( "LOG" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:IsVisible() then -- Since the height is a double, returns it as an int using math.floor
                GRM.DisableTabButtons ( true );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:Show();
                GRM_UI.GRM_RosterCheckBoxSideFrame:Show()
                GRM.FrameTransition ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , GRM.GetTransitionFrameToFade() , true );
                GRM.FrameTransition ( GRM_UI.GRM_RosterCheckBoxSideFrame , nil , false );
            end
        end
    end);
    -- Event to add tab
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab , "BOTTOMRIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetSize ( 99.2 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetFrameStrata ( "MEDIUM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetText ( GRM.L ( "EVENTS" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:IsVisible() then -- Since the height is a double, returns it as an int using math.floor
                GRM.DisableTabButtons ( true );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:Show();
                GRM.FrameTransition ( GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , GRM.GetTransitionFrameToFade() , true );
                GRM.FrameTransition ( nil , GRM_UI.GRM_RosterCheckBoxSideFrame , false );
            end
        end
    end);
    -- Add Event Frame
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetScript ( "OnUpdate" , function( self , elapsed )
        GRM_AddonGlobals.eventTimer = GRM_AddonGlobals.eventTimer + elapsed;
        if GRM_AddonGlobals.eventTimer >= 1 then
            if GRM_AddonGlobals.saveGID ~=0 then
                if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] then
                    self:SetText ( GRM.L ( "EVENTS" ) .. ": " .. #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 );     -- First index will be nil.
                else
                    self:SetText ( GRM.L ( "EVENTS" ) );
                end
            end
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:IsVisible() then
                if CanEditGuildEvent() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Hide();
                else
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Show();
                end
            end
            GRM_AddonGlobals.eventTimer = 0;
        end
    end);
    -- ban list tab
    GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab , "BOTTOMRIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetSize ( 99.2 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetFrameStrata ( "MEDIUM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetText ( GRM.L ( "BAN LIST" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then -- Since the height is a double, returns it as an int using math.floor
                GRM.DisableTabButtons ( true );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:Show();
                GRM.FrameTransition ( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , GRM.GetTransitionFrameToFade() , true );
                GRM.FrameTransition ( nil , GRM_UI.GRM_RosterCheckBoxSideFrame , false );
            end
        end
    end);
    -- Audit Tab
    GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab , "BOTTOMRIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetSize ( 99.2 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetFrameStrata ( "MEDIUM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetText ( GRM.L ( "AUDIT" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then -- Since the height is a double, returns it as an int using math.floor
                GRM.DisableTabButtons ( true );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:Show();
                GRM.FrameTransition ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , GRM.GetTransitionFrameToFade() , true );
                GRM.FrameTransition ( nil , GRM_UI.GRM_RosterCheckBoxSideFrame , false );
            end
        end
    end);
    -- Current Addon Users Tab
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab , "BOTTOMRIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetSize ( 99.2 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetFrameStrata ( "MEDIUM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetText ( GRM.L ( "SYNC USERS" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then -- Since the height is a double, returns it as an int using math.floor
                GRM.DisableTabButtons ( true );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:Show();
                GRM.FrameTransition ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , GRM.GetTransitionFrameToFade() , true );
                GRM.FrameTransition ( nil , GRM_UI.GRM_RosterCheckBoxSideFrame , false );
            end
        end
    end);
    -- Options Tab
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab , "BOTTOMRIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetSize ( 99.2 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetFrameStrata ( "MEDIUM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetText ( string.upper ( GRM.L ( "Options" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:IsVisible() then -- Since the height is a double, returns it as an int using math.floor
                GRM.DisableTabButtons ( true );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:Show();
                GRM_UI.GRM_RosterCheckBoxSideFrame:Show()
                GRM.FrameTransition ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , GRM.GetTransitionFrameToFade() , true );
                GRM.FrameTransition ( GRM_UI.GRM_RosterCheckBoxSideFrame , nil , false );
            end
        end
    end);
    

    -- Due to some restrictions on guild controls, I also need to register a prefix for a "hack" workaround to determine if player has access to Guild Chat channel.
    -- If the player does not, then player
    GRM_FrameChatTest = CreateFrame ( "Frame" , "GRM_FrameChatTest");
    RegisterAddonMessagePrefix( "GRM_GCHAT" );
    GRM_FrameChatTest:RegisterEvent ( "CHAT_MSG_ADDON" );
    GRM_FrameChatTest:SetScript ( "OnEvent" , function ( _ , event , prefix , _ , channel , sender )
        -- Only acknowledge if you are sending it to yourself, as this is just a check to see if you have access
        if event == "CHAT_MSG_ADDON" and prefix == "GRM_GCHAT" and sender == GRM_AddonGlobals.addonPlayerName then
            if channel == GRMsyncGlobals.channelName then
                GRM_AddonGlobals.HasAccessToGuildChat = true;
            elseif channel == "OFFICER" then
                GRM_AddonGlobals.HasAccessToOfficerChat = true;
            end
        end
    end);

    -- Initialize the Minimap
    GRM_UI.GRM_MinimapButton:EnableMouse ( true );
    GRM_UI.GRM_MinimapButton:SetMovable ( false );
    GRM_UI.GRM_MinimapButton:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_MinimapButton:SetWidth ( 33 );
    GRM_UI.GRM_MinimapButton:SetHeight ( 33 );
    -- GRM_UI.GRM_MinimapButton:SetPoint ( "TOPLEFT" , Minimap , "TOPLEFT" , 2 , 0 );
    GRM_UI.GRM_MinimapButton:SetHighlightTexture ( "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight" );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonIcon:SetWidth ( 20 );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonIcon:SetHeight ( 20 );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonIcon:SetPoint ( "CENTER" , GRM_UI.GRM_MinimapButton , -2 , 1 );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonIcon:SetTexture ( "Interface\\Icons\\garrison_building_magetower" );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonBorder:SetWidth ( 52 );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonBorder:SetHeight ( 52 );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonBorder:SetPoint ( "TOPLEFT" , GRM_UI.GRM_MinimapButton );
    GRM_UI.GRM_MinimapButton.GRM_MinimapButtonBorder:SetTexture ( "Interface\\Minimap\\MiniMap-TrackingBorder" );


    GRM_UI.GRM_MinimapButtonInit  = function()
        -- Initialise defaults if not present
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][32] == false then
            GRM_UI.GRM_MinimapButton:Hide()
        else
            GRM_UI.GRM_MinimapButton:Show()
        end
        GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][26] = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][26] or 78;
        GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][25] = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][25] or 345;
        
        GRM_UI.GRM_MinimapButtonUpdatePos()
    end
    GRM_UI.GRM_MinimapButtonUpdatePos = function()
        GRM_UI.GRM_MinimapButton:SetPoint ( "TOPLEFT" , Minimap , "TOPLEFT" , 54 - ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][26] * cos ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][25] ) ) , ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][26] * sin ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][25] ) ) - 55 );
    end

    -- Thanks to Yatlas for this code
    GRM_UI.GRM_MinimapButtonDuringDrag = function()
        local x , y = GetCursorPosition()
        local xmin , ymin = Minimap:GetLeft() , Minimap:GetBottom();

        x = xmin - x / UIParent:GetScale() + 70;
        y = y / UIParent:GetScale() - ymin - 70;

        local vector = math.deg ( math.atan2 ( y , x ) );
        if vector < 0 then
            vector = vector + 360
        end
        if GRM_AddonGlobals.setPID == 0 then
            for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                    GRM_AddonGlobals.setPID = i;
                    break;
                end
            end
        end
        GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][25] = vector;
        GRM_UI.GRM_MinimapButtonUpdatePos();
    end

    GRM_UI.MinimapOnLeave = function ()
        ResetCursor();
        GameTooltip:Hide();
    end

    GRM_UI.GRM_MinimapButton:RegisterForDrag ( "RightButton" );
    GRM_UI.GRM_MinimapButton:SetScript ( "OnDragStart" , function ( self )
        self:SetScript ( "OnUpdate" , GRM_UI.GRM_MinimapButtonDuringDrag );
    end);
    GRM_UI.GRM_MinimapButton:SetScript ( "OnDragStop" , function ( self )
        self:SetScript ( "OnUpdate" , nil );
    end)
    GRM_UI.GRM_MinimapButton:SetScript ( "OnEnter" , function(self)
        GameTooltip:SetOwner ( self , "ANCHOR_LEFT" );
        GameTooltip:AddLine ( "|CFF00CCFF" .. GRM.L ( "GRM" ) .. " " .. string.sub ( GRM_AddonGlobals.Version , string.find ( GRM_AddonGlobals.Version , "R" ) + 1 ) );
        GameTooltip:AddLine ( GRM.L ( "|CFFE6CC7FClick|r to open GRM" ) );
        GameTooltip:AddLine( GRM.L ( "|CFFE6CC7FCtrl-Shift-Click|r to Hide this Button." ) );
        GameTooltip:AddLine( GRM.L ( "|CFFE6CC7FRight-Click|r and drag to move this button." ) );
        GameTooltip:Show();
    end)
    GRM_UI.GRM_MinimapButton:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if IsShiftKeyDown() and IsControlKeyDown() then
                self:Hide();
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][32] = false;
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton ~= nil and GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton:SetChecked ( false );
                end
            else
                if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame:Hide();
                else
                    if IsInGuild() then
                        GRM_UI.GRM_RosterChangeLogFrame:Show();
                    else
                        GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Player is Not Currently in a Guild" ) );
                    end
                end
            end
        end
    end)
    GRM_UI.GRM_MinimapButton:SetScript ( "OnLeave" , GRM_UI.MinimapOnLeave );
end

-- Method:          GRM_UI.BuildLogFilterSideFrame()
-- What it Does:    Builds the side roster checkboxes properly
-- Purpose:         Front end UI log filtering.
GRM_UI.BuildLogFilterSideFrame = function()
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetChecked ( true );
    end
end

-- Method:          GRM_UI.BuildLogFrames()
-- What it Does:    Rebuilds the frames that hold the guild event log...
-- Purpose:         Easy access. Useful to rebuild frames on the fly at times, particularly if a player rank changes, just in case he receives/loses various permissions.
GRM_UI.BuildLogFrames = function()
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then                                         -- Show at Logon Button
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] then                                         -- Add Timestamp to Officer on Join Button
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton:SetChecked ( true );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:SetChecked ( true );
    end
    
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton:SetChecked ( true );
    end

    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1:SetChecked ( true );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton2:SetChecked ( false );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetText ( GRM.L ( "Add Join Date to:  |cffff0000Officer Note|r" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetText ( GRM.L ( "Public Note" ) );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1:SetChecked ( false );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton2:SetChecked ( true );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetText ( GRM.L ( "Add Join Date to:  Officer Note" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetText ( "|cffff0000" .. GRM.L ( "Public Note" ) );
    end

    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][27] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][28] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][29] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][31] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][32] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][35] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:SetChecked ( true );
    end
    -- Sliders
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetValue ( ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][24] / 40 ) * 100 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetValue ( ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][45] * 10 ) + 100 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText2:SetText ( math.floor ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:GetValue() + 0.5 ) .. "%" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    
    -- Reset the editboxes
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) ;    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( math.floor ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] / 24 ) );
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] == 0 then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetText ( 1 );
    else
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] );
    end

    -- Display Information
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:IsVisible() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:Show();
    end
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:IsVisible() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:IsVisible() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:GetChecked() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
    end
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:GetChecked() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
    end
    -- Permissions... if not, disable button.
    if CanEditOfficerNote() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:SetChecked ( false );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:Disable();
    end
    if CanEditGuildEvent() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:SetChecked ( false );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
    end
    if CanGuildRemove() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:Enable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText2:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText2:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:SetChecked ( false );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:Disable();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:Disable();
    end
    if CanGuildInvite() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:Enable()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:SetChecked ( false );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:Disable();
    end
    -- Reset these Extra Log window values (removes the red coloring of the text otherwise.)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetText ( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetText ( 0 );

    -- Get that Dropdown Menu Populated!
    GRM.CreateOptionsRankDropDown();
    GRM.BuildLog();
    -- Ok rebuild the log after changes!
end

-- Method           GRM.MetaDataInitializeUIrosterLog1( boolean )
-- What it Does:    Keeps the log initialization separate and part of the UIParent, so it can load upon logging in
-- Purpose:         Resource control. This loads upon login, but keeps the rest of the addon UI initialization from occuring unless as needed.
--                  In other words, this can be loaded upon logging, but the rest will only load if the guild roster window loads.
GRM_UI.MetaDataInitializeUIrosterLog1 = function( isManualUpdate )
    -- Popup window to confirm!
    GRM_UI.GRM_RosterConfirmFrame:Hide();
    GRM_UI.GRM_RosterConfirmFrame:SetPoint ( "CENTER" , UIPanel , 0 , 200 );
    GRM_UI.GRM_RosterConfirmFrame:SetSize ( 275 , 90 );
    GRM_UI.GRM_RosterConfirmFrame:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_UI.GRM_RosterConfirmFrameText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterConfirmFrame , 0 , 10 );
    GRM_UI.GRM_RosterConfirmFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterConfirmFrameText:SetWidth ( 265 );
    GRM_UI.GRM_RosterConfirmFrameText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterConfirmFrameText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterConfirmYesButton:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterConfirmFrame , 15 , 5 );
    GRM_UI.GRM_RosterConfirmYesButton:SetSize ( 70 , 35 );
    GRM_UI.GRM_RosterConfirmYesButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterConfirmYesButton );
    GRM_UI.GRM_RosterConfirmYesButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );

    GRM_UI.GRM_RosterConfirmCancelButton:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterConfirmFrame , -15 , 5 );
    GRM_UI.GRM_RosterConfirmCancelButton:SetSize ( 70 , 35 );
    GRM_UI.GRM_RosterConfirmCancelButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterConfirmCancelButton );
    GRM_UI.GRM_RosterConfirmCancelButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterConfirmCancelButtonText:SetText ( GRM.L ( "Cancel" ) );
    GRM_UI.GRM_RosterConfirmCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterConfirmFrame:Hide();
        end
    end);
    GRM_UI.GRM_RosterConfirmFrame:SetScript ( "OnHide" , function ()
        GRM_UI.GRM_RosterChangeLogFrame:EnableMouse ( true );
        GRM_UI.GRM_RosterChangeLogFrame:SetMovable ( true );
    end);

    -- MAIN GUILD LOG FRAME!!!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameTitleText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame , 0 , - 3.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameTitleText:SetText ( GRM.L ( "Guild Roster Event Log" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPRIGHT" , -20 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText:SetWidth ( 180 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterCheckBoxSideFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPRIGHT" , -3 , 3 );
    GRM_UI.GRM_RosterCheckBoxSideFrame:SetSize ( 200 , 410 ); -- 509 is flush height
    -- Scroll Frame DetailsGRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollBorderFrame:SetSize ( 584 , 450 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollBorderFrame:SetPoint ( "Bottom" , GRM_UI.GRM_RosterChangeLogFrame , "BOTTOM" , -10 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:SetSize ( 566 , 427 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:SetPoint (  "Bottom" , GRM_UI.GRM_RosterChangeLogFrame , "BOTTOM" , -3 , 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetOrientation ( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetSize ( 20 , 405 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame , "TOPRIGHT" , -2.5 , -12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetScript ( "OnValueChanged" , function ( self )
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:SetVerticalScroll ( self:GetValue() );          
    end);

    -- Log window Editbox Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetSize ( 175 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , "TOPLEFT" , 13 , -2.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetMaxLetters ( 30 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetAutoFocus( false )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText ( GRM.L ( "Search Filter" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:ClearFocus();
        self:SetText ( GRM.L ( "Search Filter" ) );
        GRM.BuildLogComplete();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetScript ( "OnEditFocusGained" , function( self )
        if self:GetText() == GRM.L ( "Search Filter" ) then
            self:SetText ( "" );
        else
            self:HighlightText ( 0 );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetScript ( "OnEditFocusLost" , function( self )
        if self:GetText() == "" then
            self:SetText ( GRM.L ( "Search Filter" ) );
        else
            self:HighlightText ( 0 , 0 );
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetScript ( "OnEnterPressed" , function( self )
        if self:GetText() == "" then
            self:SetText ( GRM.L ( "Search Filter" ) );
            GRM.BuildLogComplete();
        end
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetScript ( "OnTextChanged" , GRM.BuildLogComplete );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetScript ( "OnShow" , function ( self )
        if self:GetText() == "" then
            self:SetText ( GRM.L ( "Search Filter" ) );
        end
    end);

    -- LOG TOOLS
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , "BOTTOMLEFT" , -4 , 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:SetSize ( 608 , 155 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton:SetSize ( 80 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:IsVisible() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:Hide();
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:Show();
            end
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText:SetText ( GRM.L ( "Open Log Tools" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText:SetWidth ( 70 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:SetScript ( "OnHide" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText:SetText ( GRM.L ( "Open Log Tools" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:ClearFocus();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:SetScript ( "OnShow" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsButton.GRM_LogExtraOptionsButtonText:SetText ( GRM.L ( "Hide Log Tools" ) );
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][36] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][37] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton:SetChecked ( true );
        end
    end);

    -- Export Frames and their logic...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "TOPLEFT" , 15 , -20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButtonText:SetText ( GRM.L ( "Numbered Lines" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][36] = true;
                GRM.BuildLogComplete();
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][36] = false;
                GRM.BuildLogComplete();
            end
        end
    end);

    -- Export Button
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "TOP" , 0 , -15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton:SetSize ( 80 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:Show();
            GRM.BuildExportLogFrame ( GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate, 2 , -1 );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton.GRM_ExportButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton.GRM_ExportButtonText:SetText ( GRM.L ( "Export Log" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton.GRM_ExportButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton.GRM_ExportButtonText:SetWidth ( 70 );

    -- Clear Log Button
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButton:SetSize ( 80 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame , "TOPRIGHT" , -15 , -15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButton , 0 , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButtonText:SetText ( GRM.L ( "Clear Log" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_RosterClearLogButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
            GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
            GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really Clear the Guild Log?" ) );
            GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
            GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                if button == "LeftButton" then
                    GRM.ResetLogReport();       --Resetting!
                    GRM_UI.GRM_RosterConfirmFrame:Hide();
                end
            end);
            GRM_UI.GRM_RosterConfirmFrame:Show();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton , "BottomLeft" , 0 , -20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButtonText:SetText ( GRM.L ( "Enable Ctrl-Shift-Click Line Removal" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton:SetScript ( "OnClick" , function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][37] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][37] = false;
        end
    end);


    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText1:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogEnableRmvClickCheckButton , "BOTTOMLEFT" , 6 , -20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText1:SetText ( GRM.L ( "Clear Lines:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText1:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1 , "RIGHT" , 8 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText2:SetText ( GRM.L ( "To" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText2:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );

    -- Extra Log Options Editboxes
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetSize ( 50 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText1 , "RIGHT" , 12 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetMaxLetters ( 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetAutoFocus( false )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetText ( "0" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetSize ( 50 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraText2 , "RIGHT" , 10 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetMaxLetters ( 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetAutoFocus( false )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetText ( "0" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton:SetSize ( 80 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExportButton , "BOTTOM" , 0 , -40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton.GRM_ConfirmClearButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton.GRM_ConfirmClearButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton.GRM_ConfirmClearButtonText:SetText ( GRM.L ( "Confirm Clear" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton.GRM_ConfirmClearButtonText:SetWidth ( 70 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_ConfirmClearButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local numBox1 = tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:GetText() );
            local numBox2 = tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:GetText() );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:ClearFocus();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:ClearFocus();
            if numBox1 == 0 and numBox1 == numBox2 then
               GRM.Report ( GRM.L ( "Please Select Range of Lines from the Log You Wish to Remove" ) );
            elseif numBox1 > numBox2 then
                GRM.Report ( GRM.L ( "Please put the lowest number in the first box" ) );
            elseif numBox1 > GRM_AddonGlobals.FinalCountVisible then
                GRM.Report ( GRM.L ( "Line selection is not valid" ) );
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton:GetChecked() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogShowLinesCheckButton:SetChecked ( true );
                    GRM.Report ( GRM.L ( "Enabling Line Numbers... Please choose within the given range" ) );
                    GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][36] = true;
                    GRM.BuildLogComplete();
                end
            else
                GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                if numBox2 > GRM_AddonGlobals.FinalCountVisible then
                    numBox2 = GRM_AddonGlobals.FinalCountVisible;
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetText ( numBox2 );
                end
                if numBox1 == numBox2 then 
                    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really Clear line {num}?" , nil , nil , numBox1 ) );
                else
                    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really Clear lines {custom1} to {custom2}?" , nil , nil , nil , numBox1 , numBox2 ) );
                end
                GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                    if button == "LeftButton" then
                        GRM.ClearVisibleLogLinesWithinRange ( numBox1 , numBox2 );
                        GRM_UI.GRM_RosterConfirmFrame:Hide();
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetText ( "0" );
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetText ( "0" );
                        GRM.BuildLogComplete();
                    end
                end);
                GRM_UI.GRM_RosterConfirmFrame:Show();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetScript ( "OnEscapePressed" , function( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetScript ( "OnEditFocusGained" , function ( self )
        self:HighlightText( 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetScript ( "OnEditFocusLost" , function ( self )
        self:HighlightText( 0 , 0 );
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetScript ( "OnTabPressed" , function ( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetFocus();
        GRM_AddonGlobals.LogNumbersColorUpdate = true;
        GRM.BuildLogComplete();
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetScript ( "OnEnterPressed" , function( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
        GRM_AddonGlobals.LogNumbersColorUpdate = true;
        GRM.BuildLogComplete();
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetScript ( "OnEscapePressed" , function( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetScript ( "OnEditFocusGained" , function ( self )
        self:HighlightText( 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetScript ( "OnEditFocusLost" , function ( self )
        if tonumber ( self:GetText() ) > GRM_AddonGlobals.FinalCountVisible then
            self:SetText ( GRM_AddonGlobals.FinalCountVisible );
        end
        self:HighlightText( 0 , 0 );
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetScript ( "OnTabPressed" , function ( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:SetFocus();
        GRM_AddonGlobals.LogNumbersColorUpdate = true;
        GRM.BuildLogComplete();
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:SetScript ( "OnEnterPressed" , function( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText ( "0" );
        end
        GRM_AddonGlobals.LogNumbersColorUpdate = true;
        GRM.BuildLogComplete();
    end);

    -- Log One Click Behavior
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame:SetScript ( "OnMouseDown" , function ( self , button ) 
        if button == "LeftButton" and IsControlKeyDown() and IsShiftKeyDown() and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][37] and not GRM_UI.GRM_RosterConfirmFrame:IsVisible() then
            for i = 1 , #self.allFontStrings do
                if self.allFontStrings[i][1]:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                    GRM.RemoveItemFromLog ( GRM.Trim( self.allFontStrings[i][1]:GetText() ) , true );
                    break;
                end
            end
        end
    end);


    -- LOG EXPORT 
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetPoint ( "CENTER" , UIPanel );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetSize ( 463 , 500 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetFrameStrata ( "DIALOG");
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetToplevel ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetMovable ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:EnableMouse ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:RegisterForDrag ( "LeftButton" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetScript ( "OnDragStart" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.StartMoving );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetScript ( "OnDragStop" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.StopMovingOrSizing );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_BorderFrameCloseButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame , "TOPRIGHT" , 2, 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_BorderFrameCloseButton:SetWidth ( 30 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLogText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame , 0 , -25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLogText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLogText:SetText ( GRM.L ( "Ctrl-C to Copy <> Ctrl-P to Paste <> Ctrl-A to Select All" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:SetText ( GRM.L ( "Building Log for Export..." ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetSize ( 430 , 428 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetAutoFocus ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetMultiLine ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:EnableMouse ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetSpacing ( 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetTextInsets ( 2 , 3 , 3 , 2 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame:SetSize ( 440 , 433 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame:SetPoint (  "Bottom" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame , "BOTTOM" , 3 , 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetOrientation ( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetSize ( 20 , 403 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame , "TOPRIGHT" , 4 , -15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetScript ( "OnValueChanged" , function ( self )
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame:SetVerticalScroll ( self:GetValue() );          
    end);

    -- Export Frames and their logic...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetScript ( "OnEscapePressed" , function ( self )
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetScript ( "OnEnterPressed" , function ( self )
        self:ClearFocus();
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetScript ( "OnEditFocusGained" , function ( self )
        self:HighlightText( 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetScript ( "OnEditFocusLost" , function ( self )
        self:HighlightText( 0 , 0 );
    end);


    -- Method:          GRM.OptionTabFrameControl ( buttonWidget )
    -- What it Does:    It Locks the highlight of the current tab and it unlocks the others, as well as showing the correct frame, whilst hiding the others
    -- Purpose:         Options are plentiful. Need sub-tabs to keep it clean. This helps control UI display logic on the tabs.
    GRM.OptionTabFrameControl = function ( tabNotToUnlock )
        GRM.DisableSubTabButtons ( true );
        local tabs = { GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab };
        local frames = { GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame };
        local fadeFrame;
        local fadeInFrame; 
                
        for i = 1 , #tabs do
            if tabs[i] ~= tabNotToUnlock then
                -- Lock highlight
                tabs[i]:UnlockHighlight();
            else
                -- Corresponding tab frame should now be shown whilst hiding the rest. Index will match
                fadeInFrame = frames[i];                
            end
        end

        for j = 1 , #frames do
            if frames[j]:GetAlpha() == 1 then
                fadeFrame = frames[j];
                break;
            end
        end
        -- Ok, let's do the work!
        GRM.FrameTransition ( fadeInFrame , fadeFrame , false , true );
    end

    -- OPTIONS TABS
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText2 , "BOTTOMLEFT" , 1 , 7 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetSize ( 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetText ( GRM.L ( "General" ) );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab , nil , 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:IsVisible() then
                self:LockHighlight();
                GRM.OptionTabFrameControl ( self );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:Show();
            end
        end
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetScript ( "OnShow" , function()
        local count = GRML.GetNumberUntranslatedLines ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][43] );
        if count > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetText ( GRM.L ( "{num} phrases still need translation to {name}" , GRML.Languages[GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][43]] , nil , count ) );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:Show();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:Hide();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab , "RIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:SetSize ( 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:SetText ( GRM.L ( "Scan" ) );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab , nil , 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame:IsVisible() then
                self:LockHighlight();
                GRM.OptionTabFrameControl ( self );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:Show();
            end
        end
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab , "RIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:SetSize ( 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:SetText ( GRM.L ( "Sync" ) );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab , nil , 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame:IsVisible() then
                self:LockHighlight();
                GRM.OptionTabFrameControl ( self );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:Show();
            end
        end
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText3 , "BOTTOMRIGHT" , -1 , 7 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:SetSize ( 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:SetText ( GRM.L ( "Help" ) );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab , nil , 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:IsVisible() then
                self:LockHighlight();
                GRM.OptionTabFrameControl ( self );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:Show();
            end
        end
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:SetPoint ( "RIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab , "LEFT" , -1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:SetSize ( 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:SetText ( GRM.L ( "Backup" ) );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab , nil , 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:IsVisible() then
                self:LockHighlight();
                GRM.OptionTabFrameControl ( self );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:Hide();

                -- Now load the correct frame as well...
                if not GRM_AddonGlobals.BackupLoadedOnce then
                    GRM_AddonGlobals.BackupLoadedOnce = true;
                    if GRM_AddonGlobals.FID == 1 then
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab:LockHighlight();
                        GRM_AddonGlobals.selectedFID = 1;
                        GRM.BuildBackupScrollFrame ( 1 );
                    else
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab:LockHighlight();
                        GRM_AddonGlobals.selectedFID = 2;
                        GRM.BuildBackupScrollFrame ( 2 );
                    end
                end
            end
        end
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:SetPoint ( "RIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab , "LEFT" , -1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:SetSize ( 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:SetText ( GRM.L ( "Officer" ) );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab , nil , 76 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame:IsVisible() then
                self:LockHighlight();
                GRM.OptionTabFrameControl ( self );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:Show();
            end
        end
    end)
    
    -- Options Frames
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:SetSize ( 600 , 410 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame:SetSize ( 600 , 410 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame:SetSize ( 600 , 410 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:SetSize ( 600 , 410 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:SetSize ( 600 , 410 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame:SetSize ( 600 , 410 );
    
    -- no need to reset the frames if the UI is already loaded.
    if not GRM_AddonGlobals.UIIsLoaded then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:LockHighlight();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame:SetAlpha ( 0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame:SetAlpha ( 0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:SetAlpha ( 0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:SetAlpha ( 0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame:SetAlpha ( 0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame:Hide();
    end

    -- OPTIONS TEXT INFO
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame , 0 , - 30 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText:SetText ( string.upper ( GRM.L ( "Options" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText2:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPLEFT" , 10 , - 35 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText2:SetText ( "_____________________" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText3:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame , "TOPRIGHT" , -10 , - 35 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText3:SetText ( "_____________________" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.OptionsScanDetailsText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , 18 , - 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.OptionsScanDetailsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.OptionsScanDetailsText:SetText ( GRM.L ( "Scanning Roster:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.OptionsScanDetailsText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.OptionsRankRestrictHeaderText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame , 18 , -12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.OptionsRankRestrictHeaderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.OptionsRankRestrictHeaderText:SetText ( GRM.L ( "Guild Rank Restricted:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.OptionsRankRestrictHeaderText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.OptionsSyncHeaderText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , 18 , - 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.OptionsSyncHeaderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.OptionsSyncHeaderText:SetText ( GRM.L ( "Sync:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.OptionsSyncHeaderText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_GeneralOptionsFrameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , 18 , - 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_GeneralOptionsFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_GeneralOptionsFrameText:SetText ( GRM.L ( "General:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_GeneralOptionsFrameText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    -- BACKUP OPTIONS FRAME
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText2 , "BOTTOMLEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox:SetScript ( "OnClick", function( self)
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][34] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][34] = false;
        end
    end);

    -- Backup Frame tooltip setup
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:SetWidth ( 300 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:SetFrameStrata ( "DIALOG" );
    -- Backup Right click dropdown
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText:SetWidth ( 230 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText:SetText ( GRM.L ( "Click Here to Remove all traces of this guild, or hit ESC" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOptionText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:SetSize ( 250 , 55 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton:SetSize ( 235 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );   
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption , "LEFT" , 8 , 0 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption.GRM_BackupPurgeGuildOptionButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            GRM_AddonGlobals.changeHappenedExitScan = true;
            local faction = "Horde";
            if GRM_AddonGlobals.selectedFID == 2 then
                faction = "Alliance";
            end
            GRM.PurgeGuildFromDatabase ( GRM_AddonGlobals.BackupFrameSelectDetails[2] , GRM_AddonGlobals.BackupFrameSelectDetails[3] , faction );
            -- Need to set IDs again!
            GRM.EstablishDatabasePoints ( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:Hide();
            GRM_UI.GRM_MemberDetailMetaData:Hide();
            GRM.BuildBackupScrollFrame( GRM_AddonGlobals.selectedFID );
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:SetScript ( "OnUpdate" , GRM.BuildBackupFrameTooltip );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:SetScript ( "OnShow" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:Hide();
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "RightButton" and GRM.GetClickedStringFromBackupFrameDetails() then
            if self.GRM_BackupPurgeGuildOption:IsVisible() then
                self.GRM_BackupPurgeGuildOption:Hide();
            else
                self.GRM_BackupPurgeGuildOption:ClearAllPoints();
                self.GRM_BackupPurgeGuildOption:SetPoint( "RIGHT" , self.GRM_CoreBackupScrollChildFrame.AllBackupButtons[GRM_AddonGlobals.BackupFrameSelectDetails[1]][1] , "LEFT" , -19 , 0 );

                self.GRM_BackupPurgeGuildOption:Show();
                self.GRM_GuildNameTooltip:Hide();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
        end
    end);
       

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.OptionsHeaderText3 , "BOTTOMRIGHT" , -10 , -5 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText:SetJustifyH ( "LEFT" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox , "RIGHT" , 1 , 0 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText:SetText ( GRM.L ( "Enable Auto-Backup Once Every" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText , "RIGHT" , 32 , 0 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetJustifyH ( "LEFT" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText , "RIGHT" , 1.0 , 0 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText , "RIGHT" , -1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetSize ( 40 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetMaxLetters ( 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:EnableMouse ( true );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:IsEnabled() then
                self:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetText ( "" );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:Show()
            end
        end    
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetScript ( "OnEnterPressed" , function( self )
        local numDays = tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:GetText() );
        if numDays >= 1 and numDays < 100 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][41] = numDays;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNoteText:SetText ( numDays );
            if numDays > 1 then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetText ( GRM.L ( "Days" ) );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetText ( GRM.L ( "Day" ) );
            end
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:Show();
        else
            GRM.Report ( GRM.Report ( "Please Choose a Time Interval Between 1 and 99 Days!" ) );
        end      
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeEditBox:SetScript ( "OnEditFocusLost" , function( self ) 
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNote:Show();
    end)


    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame:SetSize ( 584 , 352 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , "BOTTOMLEFT" , -2 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame:SetSize ( 566 , 329 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame , "BOTTOMLEFT" , 0 , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetOrientation ( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetSize ( 20 , 310 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame , "TOPRIGHT" , 13.5 , -10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetScript ( "OnValueChanged" , function ( self )
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame:SetVerticalScroll ( self:GetValue() );          
    end);
    -- Options Backup Horde/Ally Tabs
    -- OPTIONS TABS
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame , "TOPLEFT" , 5 , -1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab:SetSize ( 100 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTabText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab , 0 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTabText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTabText:SetText ( GRM.L ( "Horde" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTabText:SetTextColor ( 0.61 , 0.14 , 0.137 );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab , nil , 100 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            GRM_AddonGlobals.selectedFID = 1;
            self:LockHighlight();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab:UnlockHighlight();
            GRM.BuildBackupScrollFrame ( 1 );
        end
    end)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab , "RIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab:SetSize ( 100 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTabText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab , 0 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTabText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTabText:SetText ( GRM.L ( "Alliance" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTabText:SetTextColor ( 0.078 , 0.34 , 0.73 );
    PanelTemplates_TabResize ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab , nil , 100 , 25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AllianceTab:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            GRM_AddonGlobals.selectedFID = 2;
            self:LockHighlight();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_HordeTab:UnlockHighlight();
            GRM.BuildBackupScrollFrame ( 2 );
        end
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CreationDateText:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame , "TOP" , 57.5 , -3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CreationDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CreationDateText:SetText ( GRM.L ( "Creation Date" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNumMembersText:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollBorderFrame , "TOPRIGHT" , -37 , -3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNumMembersText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNumMembersText:SetText ( GRM.L ( "Members" ) );


    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.OptionsSlashCommandText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , 18 , - 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.OptionsSlashCommandText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.OptionsSlashCommandText:SetText ( GRM.L ( "Slash Commands" ) .. ":" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.OptionsSlashCommandText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    -- SLASH COMMAND STRINGS
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.OptionsSlashCommandText , "BOTTOMLEFT" , 0 , - 5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText:SetSpacing ( 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText:SetText ( "/roster or /grm - |cffff0000" .. GRM.L ( "Open Addon Window" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText2:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText2:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText2:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText2:SetText( "|cffff0000" .. GRM.L ( "Trigger scan for changes manually" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText3:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText3:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText3:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText3:SetText( "|cffff0000" .. GRM.L ( "Trigger sync one time manually" ) );
    

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText4:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText4:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText4:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText4:SetText( "|cffff0000" .. GRM.L ( "Centers all Windows" ) );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText5:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText5:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText5:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText5:SetText( "|cffff0000" .. GRM.L ( "Slash command info" ) );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText6:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText6:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText6:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText6:SetText( "|cffff0000" .. GRM.L ( "Resets ALL data" ) );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText7:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText7:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText7:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText7:SetText( "|cffff0000" .. GRM.L ( "Report addon ver" ) );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText10:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearGuildOptionsButton , "TOPRIGHT" , 1 , - 4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText10:SetFont ( GRM_AddonGlobals.FontChoice , 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText10:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText10:SetText( "|cffff0000" .. GRM.L ( "Resets Guild data" ) );

    GRM_UI.GRM_RosterCheckBoxSideFrame:SetScript ( "OnHide" , function ()
        if GRM_UI.GRM_RosterConfirmFrameText:GetText() == GRM.L ( "Really Clear the Guild Log?" ) then
            GRM_UI.GRM_RosterConfirmFrame:Hide();
        end
    end);

    if not isManualUpdate then
        GRM_UI.GRM_RosterCheckBoxSideFrame:HookScript ( "OnShow" , function()
            GRM_UI.BuildLogFilterSideFrame();
        end);
    end


    -- CORE OPTIONS
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_GeneralOptionsFrameText , "BOTTOMLEFT" , -4 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButtonText:SetText ( GRM.L ( "Show at Logon" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] = true;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:Enable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] = false;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:Disable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButtonText:SetText ( GRM.L ( "Show 'Main' Name in Chat" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][29] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][29] = false;
            end
        end
    end);
    
    -- COLOR PICKER!!!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorPickerOptionsText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButtonText , "RIGHT" , 18 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorPickerOptionsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorPickerOptionsText:SetText ( "|cffff0000<>|r " .. GRM.L ( "Choose Color:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorPickerOptionsText , "RIGHT" , 5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame:SetSize ( 18 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame:SetBackdrop (
        {
            bgFile = nil,
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 9,
            insets = { left = -2 , right = -2 , top = -3 , bottom = -2 }
        }
    );
    -- color box texture
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame:SetScript ( "OnShow" , function( self )
        self.GRM_OptionsTexture:SetPoint ( "CENTER" , self );
        self.GRM_OptionsTexture:SetSize( 15 , 15 );
        self.GRM_OptionsTexture:SetColorTexture ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][1] , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][2] , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][3] , 1.0 );
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame:SetScript ( "OnMouseDown" , function ( _ , button )
        if button == "LeftButton" then
            GRM.ShowCustomColorPicker ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][1] , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][2] , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][3] , 1.0 , function() end );
            if IsAddOnLoaded ( "ColorPickerPlus" ) then
                OpacitySliderFrame:Hide();
                ColorPickerFrame:SetSize ( 380 , 380 );
            elseif IsAddOnLoaded ( "ColorPickerAdvanced" ) then
                ColorPickerFrame.hasOpacity = true;
                ColorPickerFrame.opacity = 1;
            elseif IsAddOnLoaded ( "ElvUI" ) then
                ColorPickerFrame:SetSize ( 345 , 240 );
            else
                OpacitySliderFrame:Hide();
                ColorPickerFrame:SetWidth ( 305 );
            end
        end
    end);

    -- Main Format settings
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame , "RIGHT" , 18 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatText:SetText ( "|cffff0000<>|r " .. GRM.L ( "Format:" ) );
    
    -- Rank Drop Down for Options Frame
    -- rank drop down 
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatText , "RIGHT" , 1.0 , 1.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:SetSize (  90 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected , "BOTTOM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:SetWidth ( 90 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:Hide();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:IsVisible() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:Hide();
            else
                GRM.PopulateMainTagDropdown();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:Show();
            end
        end
    end);

    if not isManualUpdate then
        ColorPickerOkayButton:HookScript ( "OnClick" , function ()
            if GRM_AddonGlobals.MainTagColor then
                GRM_AddonGlobals.MainTagColor = false;
                ColorPickerFrame.func = nil;
                ColorPickerFrame.opacityFunc = nil;
                ColorPickerFrame.cancelFunc = nil;
                local r , g , b = ColorPickerFrame:GetColorRGB();
                ColorPickerFrame.previousValues = { r , g , b , 1 };
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46] = { r , g , b };
                -- Update the dropdown window color too
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetTextColor ( r , g , b , 1 );
            end
        end);
    
        ColorPickerFrame:HookScript ( "OnHide" , function()
            C_Timer.After ( 0.1 , function()
                if GRM_AddonGlobals.MainTagColor then
                    -- local hexCode = GRM.rgbToHex ( { GRM.ConvertRGBScale ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][1] , true ) , GRM.ConvertRGBScale ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][2] , true ) , GRM.ConvertRGBScale ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46][3] , true ) } );
                    GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][46] = { ColorPickerFrame.previousValues[1] , ColorPickerFrame.previousValues[2] , ColorPickerFrame.previousValues[3] };
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame.GRM_OptionsTexture:SetColorTexture ( ColorPickerFrame.previousValues[1] , ColorPickerFrame.previousValues[2] , ColorPickerFrame.previousValues[3] , ColorPickerFrame.previousValues[4] );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetTextColor ( ColorPickerFrame.previousValues[1] , ColorPickerFrame.previousValues[2] , ColorPickerFrame.previousValues[3] , ColorPickerFrame.previousValues[4] );
                end
            end);
            -- Just need a slight delay for previous action to execute.
            C_Timer.After ( 0.2 , function()
                GRM_AddonGlobals.MainTagColor = false;
                ColorPickerFrame.func = nil;
                ColorPickerFrame.opacityFunc = nil;
                ColorPickerFrame.cancelFunc = nil;
            end);
        end);
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:SetScript ( "OnHide" , function()
            ColorPickerFrame:Hide();
        end);
    
        -- Color window... let's make it moveable!
        ColorPickerFrame:EnableMouse ( true );
        ColorPickerFrame:SetMovable ( true );
        ColorPickerFrame:RegisterForDrag ( "LeftButton" );
        ColorPickerFrame:SetScript ( "OnDragStart" , function()
            if ColorPickerFrameHeader:IsMouseOver( 0.5 , -0.5 , -0.5 , 0.5 ) and not ColorPickerWheel:IsMouseOver( 1 , -1 , -1 , 1 ) then
                ColorPickerFrame:StartMoving();
            end
        end);
        ColorPickerFrame:SetScript ( "OnDragStop" , ColorPickerFrame.StopMovingOrSizing );
    
        -- Fill in the edit boxes
        ColorPickerFrame:HookScript ( "OnShow" , function()
            -- Make the editboxes visible too
            if IsAddOnLoaded ( "ColorPickerAdvanced" ) or IsAddOnLoaded ( "ColorPickerPlus" ) or IsAddOnLoaded ( "ElvUI" ) then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:Hide();
            else
                local r , g , b = ColorPickerFrame:GetColorRGB();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetText ( math.floor ( r * 255 ) );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:Show();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetText ( math.floor ( g * 255 ) );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:Show();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetText ( math.floor ( b * 255 ) );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:Show();
            end
        end);
    
        local colorTimer = 0;
        ColorPickerFrame:HookScript ( "OnUpdate" , function ( _ , elapsed )
            colorTimer = colorTimer + elapsed;
            if colorTimer > 0.01 and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:HasFocus() and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:HasFocus() and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:HasFocus() then
                GRM.ColorSelectMainName();
                colorTimer = 0;
            end
        end);
    
        ColorPickerFrame:HookScript ( "OnMouseDown" , function()
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:IsMouseOver( 1 , -1 , -1 , 1 ) and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:IsMouseOver( 1 , -1 , -1 , 1 ) and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:IsMouseOver( 1 , -1 , -1 , 1 ) then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:ClearFocus();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:ClearFocus();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:ClearFocus();
            end
        end);
    end
    

    -- Colorpicker window RGB editboxes!
    -- Let's also establish the RGB editboxes
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB.GRM_B_Text:SetPoint ( "BOTTOM" , ColorPickerCancelButton , "TOP" , -6 , 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB.GRM_B_Text:SetText ( "B" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB.GRM_B_Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG.GRM_G_Text:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB.GRM_B_Text , "TOP" , 0 , 5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG.GRM_G_Text:SetText ( "G" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG.GRM_G_Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR.GRM_R_Text:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG.GRM_G_Text , "TOP" , 0 , 5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR.GRM_R_Text:SetText ( "R" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR.GRM_R_Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetSize ( 42 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetPoint ( "Left" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR.GRM_R_Text , "RIGHT" , 3 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetAutoFocus ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetTextInsets( 5 , 5 , 3 , 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetBackdrop ( GRM_UI.noteBackdrop2 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetScript ( "OnEscapePressed" , function ( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetScript ( "OnEnterPressed" , function ( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
            GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "RGB Values Must be Between 1 and 255." ) );
        end
        ColorPickerFrame:SetColorRGB ( tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:GetText() ) / 255 , 1 );
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetScript ( "OnEditFocusGained" , function( self )
        self:HighlightText ( 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetScript ( "OnEditFocusLost" , function( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        self:HighlightText ( 0 , 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetScript ( "OnTabPressed" , function ( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        ColorPickerFrame:SetColorRGB ( tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:GetText() ) / 255 , 1 );
        GRM.ColorSelectMainName();
        if IsShiftKeyDown() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetFocus();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetFocus();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetSize ( 42 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetPoint ( "Left" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB.GRM_B_Text , "RIGHT" , 3 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetAutoFocus ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetTextInsets( 5 , 5 , 3 , 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetBackdrop ( GRM_UI.noteBackdrop2 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetScript ( "OnEscapePressed" , function ( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetScript ( "OnEnterPressed" , function ( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
            GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "RGB Values Must be Between 1 and 255." ) );
        end
        ColorPickerFrame:SetColorRGB ( tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:GetText() ) / 255 , 1 );
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetScript ( "OnEditFocusGained" , function( self )
        self:HighlightText ( 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetScript ( "OnEditFocusLost" , function( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        self:HighlightText ( 0 , 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetScript ( "OnTabPressed" , function ( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        ColorPickerFrame:SetColorRGB ( tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:GetText() ) / 255 , 1 );
        GRM.ColorSelectMainName();
        if IsShiftKeyDown() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetFocus();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetFocus();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetSize ( 42 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetPoint ( "Left" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG.GRM_G_Text , "RIGHT" , 3 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetAutoFocus ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:ClearFocus();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetTextInsets( 5 , 5 , 3 , 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetBackdrop ( GRM_UI.noteBackdrop2 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetScript ( "OnEscapePressed" , function ( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetScript ( "OnEnterPressed" , function ( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
            GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "RGB Values Must be Between 1 and 255." ) );
        end
        ColorPickerFrame:SetColorRGB ( tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:GetText() ) / 255 , 1 );
        self:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetScript ( "OnEditFocusGained" , function( self )
        self:HighlightText ( 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetScript ( "OnEditFocusLost" , function( self )
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        self:HighlightText ( 0 , 0 );
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetScript ( "OnTabPressed" , function ( self )
        self:ClearFocus();
        if self:GetText() == "" then
            self:SetText( "0" );
        elseif tonumber ( self:GetText() ) > 255 then
            self:SetText( "255" );
        end
        ColorPickerFrame:SetColorRGB ( tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:GetText() ) / 255 , tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:GetText() ) / 255 , 1 );
        GRM.ColorSelectMainName();
        if IsShiftKeyDown() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetFocus();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetFocus();
        end
    end);

    -- LANGUAGE SELECTION
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelectionText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton , "BOTTOMLEFT" , 5 , -12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelectionText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelectionText:SetText ( GRM.L ( "Language Selection:" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenuButton , "RIGHT" , 5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetWidth ( 290 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetWordWrap ( false );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelectionText , "RIGHT" , 8 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:SetSize (  115 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected.GRM_LanguageSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected.GRM_LanguageSelectedText:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected.GRM_LanguageSelectedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected , "BOTTOM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:SetWidth ( 115 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:IsVisible() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:Hide();
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:Hide();
                GRM.PopulateLanguageDropdown();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:Show();
            end
        end
    end);

    -- FONT SELECTION
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelectionText , "BOTTOMLEFT" , 0 , -16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontText:SetText ( GRM.L ( "Font Selection:" ) );
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected , "BOTTOMLEFT" , 0 , -10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:SetSize (  115 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected , "BOTTOM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:SetWidth ( 115 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:IsVisible() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:Hide();
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:Hide();
                GRM.PopulateFontDropdown();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:Show();
            end
        end
    end);

    
    -- -- FONT SLIDER
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenuButton , "RIGHT" , 20 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText:SetText ( GRM.L ( "Font Scale:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText , "RIGHT" , 10 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetMinMaxValues ( 75 , 125 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetObeyStepOnDrag ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetValueStep ( 5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider , "RIGHT" , 10 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText3:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider , "BOTTOM" , 0 , -15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText3:SetText ( GRM.L ( "Example" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider.GRM_FontSizeSliderText3:SetTextColor ( 1 , 1 , 1 , 1 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetScript ( "OnValueChanged" , function( self , value )
        self.GRM_FontSizeSliderText2:SetText ( math.floor ( value + 0.5 ) .. "%" );
        self.GRM_FontSizeSliderText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 + ( ( math.floor ( value + 0.5 ) - 100  ) / 10 ) );
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetScript ( "OnMouseUp" , function ( self , button )
        if button == "RightButton" then
            self:SetValue ( 100 );
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][45] ~= 0 then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][45] = 0;
                GRML.SetNewFont ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][44] );
            end
        elseif button == "LeftButton" then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][45] = ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:GetValue() - 100 ) / 10;
            GRML.SetNewFont ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][44] );
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetScript ( "OnEnter" , function ( self )
        GameTooltip:SetOwner ( self , "ANCHOR_CURSOR" );
        GameTooltip:AddLine( GRM.L ( "Right-Click to Reset to 100%" ) );
        GameTooltip:Show();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSizeSlider:SetScript ( "OnLeave" , function ()
        GameTooltip:Hide();
    end);
    
    -- Minimap Button!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterShowMainTagCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButtonText:SetText ( GRM.L ( "Show Minimap Button" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][32] = true;
                GRM_UI.GRM_MinimapButton:Show();
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][32] = false;
                GRM_UI.GRM_MinimapButton:Hide();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ShowMinimapButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButtonText:SetText ( GRM.L ( "Sync Addon Settings on All Alts in Same Guild" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_SyncAllSettingsCheckButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][31] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][31] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonCheckButtonText , "RIGHT" , 6 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButtonText:SetText ( GRM.L ( "Only Show if Log Changes" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_RosterLoadOnLogonChangesCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][28] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][28] = false;
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.OptionsRankRestrictHeaderText , "BOTTOMLEFT" , -4 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText , "RIGHT" , 2 , -1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1 , "RIGHT" , 4 , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetText ( GRM.L ( "Public Note" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2 , "RIGHT" , 2 , -1 );    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:SetScript ( "OnClick", function()              
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = false;
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] = true;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetText ( GRM.L ( "Add Join Date to:  |cffff0000Officer Note|r" ) );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetText ( GRM.L ( "Public Note" ) );
            self:SetChecked ( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton2:SetChecked ( false );
        end
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton2:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] = false;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText:SetText ( GRM.L ( "Add Join Date to:  Officer Note" ) );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButtonText2:SetText ( "|cffff0000" .. GRM.L ( "Public Note" ) );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampRadioButton1:SetChecked ( false );
            self:SetChecked ( true );
        end
    end)

    -- Time Interval Controls on checking for changes!!!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.OptionsScanDetailsText , "BOTTOMLEFT" , -4 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText:SetText ( GRM.L ( "Scan for Changes Every" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText , "RIGHT" , 37.5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText2:SetText ( GRM.L ( "Seconds" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] = true;
            GRM.Report ( GRM.L ( "Reactivating SCAN for Guild Member Changes..." ) );

            GuildRoster();
            C_Timer.After ( 5 , GRM.TriggerTrackingCheck );     -- 5 sec delay necessary to trigger server call.
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] = false;
            GRM.Report ( GRM.L ( "Deactivating SCAN of Guild Member Changes..." ) );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText , "RIGHT" , 1.0 , 0 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButtonText , "RIGHT" , -1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetSize ( 40 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:EnableMouse ( true );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:IsEnabled() then
                self:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetText ( "" );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:Show()
            end
        end    
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetScript ( "OnEnterPressed" , function( self )
        local numSeconds = tonumber ( self:GetText() );
        if numSeconds >= 10 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] = numSeconds;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNoteText:SetText ( numSeconds );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:Show();

            GuildRoster();
            C_Timer.After ( 5 , GRM.TriggerTrackingCheck );     -- 5 sec delay necessary to trigger server call.
        else
            GRM.Report ( "\n" .. GRM.L ( "Due to server data restrictions, a scan interval must be at least 10 seconds or more!" ) .. "\n" .. GRM.L ( "Please choose an scan interval 10 seconds or higher!" ) .. " " .. GRM.L ( "{num} is too Low!" , nil , nil , numSeconds ) );
        end      
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalEditBox:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_RosterTimeIntervalOverlayNote:Show();
    end)

    -- Level filtering
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2 , "RIGHT" , 1.0 , 0 )
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2 , "RIGHT" , -1 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetSize ( 40 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:EnableMouse ( true );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:IsEnabled() then
                self:Hide();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetText ( "" );
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:Show()
            end
        end    
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetScript ( "OnEnterPressed" , function( self )
        local level = tonumber ( self:GetText() );
        if level < 2 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] = 1;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetText ( 1 );
        elseif level > GRM_AddonGlobals.LvlCap then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] = GRM_AddonGlobals.LvlCap;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetText ( GRM_AddonGlobals.LvlCap );
            GRM.Report ( GRM.L ( "The Current Lvl Cap is {num}." , nil , nil , GRM_AddonGlobals.LvlCap ) );
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] = level;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNoteText:SetText ( level );
        end
        self:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:Show();
        GRM.BuildLogComplete();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlEditBox:SetScript ( "OnEditFocusLost" , function( self ) 
        self:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMinLvlOverlayNote:Show();
    end)

    -- Kick Recommendation!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText:SetText ( GRM.L ( "Kick Inactive Player Reminder at" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , 32 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText2:SetText ( GRM.L ( "Months" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] = false;
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , 1.0 , 0 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , -0.5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetMaxLetters ( 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:EnableMouse ( true );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:IsEnabled() then
                self:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetText ( "" );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:Show()
            end
        end    
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEnterPressed" , function( self )
        local numMonths = tonumber ( self:GetText() );
        if numMonths > 0 and numMonths < 100 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] = numMonths;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNoteText:SetText ( numMonths );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:Show();
        else
            GRM.Report ( GRM.L ( "Please choose a month between 1 and 99" ) );
        end      
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEditFocusLost" , function( self ) 
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterKickOverlayNote:Show();
    end)

    -- Report Inactive Recommendation.
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText:SetText ( GRM.L ( "Report Inactive Return if Player Offline" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] = false;
        end
    end);

    -- Sync Ban list
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetText ( GRM.L ( "SYNC BAN List With Guildies at Rank" ) .. " " );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] = true;
            -- Now, let's resync it up!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                GRMsync.TriggerFullReset();
                -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                C_Timer.After ( 3 , GRMsync.Initialize );
            end        
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] = false;
        end
    end);

    -- SYNC WITH OTHER PLAYERS!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected , "RIGHT" , 21 , 0)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetText ( GRM.L ( "or Higher" ) );
    -- Sync Ban List Drop Down
        -- rank drop down 
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText , "RIGHT" , 0 , 1.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:SetSize (  130 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected , "BOTTOM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:IsVisible() then
                 GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Hide();
            else
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:Hide();
                end
                GRM.PopulateBanListOptionsDropDown();
                 GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Show();
            end
        end
    end);

    -- Options Slash command buttons
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SlashCommandText , "BOTTOMLEFT" , -2 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton:SetText ( GRM.L ( "scan" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            if IsInGuild() then
                GRM.SlashCommandScan();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ScanOptionsButton , "BOTTOMLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton:SetText ( GRM.L ( "sync" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            if IsInGuild() then
                GRM.SyncCommandScan();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_SyncOptionsButton , "BOTTOMLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton:SetText ( GRM.L ( "center" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.SlashCommandCenter();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_CenterOptionsButton , "BOTTOMLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton:SetText ( GRM.L ( "help" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.SlashCommandHelp();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_HelpOptionsButton , "BOTTOMLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton:SetText ( GRM.L ( "version" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.SlashCommandVersion();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_VersionOptionsButton , "BOTTOMLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton:SetText ( GRM.L ( "resetall" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.SlashCommandClearAll();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearGuildOptionsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearAllOptionsButton , "BOTTOMLEFT" , 0 , -8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearGuildOptionsButton:SetSize ( 85 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearGuildOptionsButton:SetText ( GRM.L ( "resetguild" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame.GRM_ClearGuildOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.SlashCommandClearGuild();
        end
    end);

    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame , "BOTTOMRIGHT" , -15 , 5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:SetSize ( 130 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText:SetWidth ( 125 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButtonText:SetText ( GRM.L ( "Restore Defaults" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ResetDefaultOptionsButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.ResetDefaultSettings();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , 0.5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( math.floor ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] / 24 ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetPoint( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , -5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetSize ( 45 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , 32 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButtonText2:SetText ( GRM.L ( "Days" ) );


    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetText ( "" );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:Show();
        end    
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEnterPressed" , function( self )
        local numDays = tonumber ( self:GetText() );
        if numDays > 0 and numDays < 181 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] = numDays * 24;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( numDays );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:Show();
        else
            GRM.Report ( GRM.L ( "Please choose between 1 and 180 days!" ) );
        end      
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEditFocusLost" , function( self ) 
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end)

    -- Add Event Options on Announcing...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportInactiveReturnButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetText ( GRM.L ( "Announce Events" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , 32 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetText ( GRM.L ( "Days in Advance" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] = true;
            if CanEditGuildEvent() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            end
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:Enable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] = false;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:Disable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            if CanEditGuildEvent() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            end
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , 0.5 , 0 )
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) ;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetPoint( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , -0.5 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetMaxLetters ( 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:EnableMouse( true );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetScript ( "OnMouseDown" , function( self , button )
        if button == "LeftButton" then
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetText ( "" );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:Show();
        end    
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEscapePressed" , function( self )
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEnterPressed" , function()
        local numDays = tonumber ( self:GetText() );
        if numDays > 0 and numDays < 29 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] = numDays;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( numDays );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
        else
            GRM.Report ( GRM.L ( "Please choose between 1 and 28 days!" ) );
        end      
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEditFocusLost" , function( self ) 
        self:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end)


    -- Add Event Options Button to add events to calendar
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterRecommendKickCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetText ( GRM.L ( "Add Events to Calendar" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterReportAddEventsToCalendarButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] = false;
        end
    end);

    -- SYNC WITH OTHER PLAYERS!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton , 27 , 0)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText:SetText ( GRM.L ( "SYNC Changes With Guildies at Rank" ) .. " " );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenuButton , "RIGHT" , 1.5 , 0)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText2:SetText ( GRM.L ( "or Higher" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM.Report ( GRM.L ( "Reactivating Data SYNC with Guildies..." ) );
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = true;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:Enable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:Enable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:Enable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:Enable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            if  GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:SetChecked( true );
            end
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                GRMsync.TriggerFullReset();
                -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                GRMsync.Initialize();
            end
        else
            GRM.Report ( GRM.L ( "Deactivating Data SYNC with Guildies..." ) );
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = false;
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:Show();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:Disable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:Disable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenuButton:Disable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanListText3:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:Disable();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            if GRMsync.MessageTracking ~= nil then
                GRMsync.MessageTracking:UnregisterAllEvents()
            end
            GRMsync.ResetDefaultValuesOnSyncReEnable();         -- Reset values to default, so that it resyncs if player re-enables.
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton , "BOTTOMRIGHT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton , 27 , 0);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButtonText:SetText ( GRM.L ( "Only Restrict Incoming Player Data to Rank Threshold, not Outgoing" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncAllRestrictReceiveButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][35] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][35] = false;
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton , 27 , 0);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetText ( GRM.L ( "Display SYNC Update Messages" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterNotifyOnChangesCheckButton:SetScript ( "OnClick", function( self)
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] = false;
        end
    end);

    -- Rank Drop Down for Options Frame
        -- rank drop down 
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButtonText , "RIGHT" , 1.0 , 1.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:SetSize (  130 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected , "BOTTOM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:SetWidth ( 130 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:SetScript ( "OnKeyDown" , function ( self , key )
        self:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput ( false );
            self:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:IsVisible() then
                 GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:Hide();
            else
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Hide();
                end
                GRM.PopulateOptionsRankDropDown();
                 GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:Show();
            end
        end
    end);


    -- Sync options - Restrict sync to current addon users only.
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText , "BOTTOMLEFT" , -4 , -14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton , 27 , 0)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButtonText:SetText ( GRM.L ( "Only Sync With Up-to-Date Addon Users" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncOnlyCurrentVersionCheckButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] = false;
        end
    end);

    -- Only announce Anniversaries of Player who is designated "main"
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterReportUpcomingEventsCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton , 27 , 0)
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButtonText:SetText ( GRM.L ( "Only Announce Anniversaries if Listed as 'Main'" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterMainOnlyCheckButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] = false;
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.OptionsSyncHeaderText , "BOTTOMLEFT" , 0 , -10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText:SetText ( GRM.L ( "Speed:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText:SetTextColor ( 1 , 0 , 0 , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText , "RIGHT" , 10 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetMinMaxValues ( 10 , 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetValue ( 100 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider , "RIGHT" , 10 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText2:SetText ( "100%" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider.GRM_SyncSpeedSliderText2:SetTextColor ( 1 , 0 , 0 , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetScript ( "OnValueChanged" , function( self , value )
        local value2 = math.floor ( value + 0.5 );
        if value > 100.1 then
            self.GRM_SyncSpeedSliderText2:SetText ( value2 .. "%" .. "  " .. GRM.L ( "Syncing too fast may cause disconnects!" ) );
        else
            self.GRM_SyncSpeedSliderText2:SetText ( value2 .. "%" );
        end
        GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][24] = ( value2 / 100 ) * 40              -- The new syncCap number for speed throttling...
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetScript ( "OnMouseUp" , function ( self , button ) 
        if button == "RightButton" then
            self:SetValue ( 100 );
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetScript ( "OnEnter" , function ( self )
        GameTooltip:SetOwner ( self , "ANCHOR_CURSOR" );
        GameTooltip:AddLine( GRM.L ( "|CFFE6CC7FRight-Click|r to Reset to 100%" ) );
        GameTooltip:Show();
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_SyncSpeedSlider:SetScript ( "OnLeave" , function ()
        GameTooltip:Hide();
    end);


    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected , "BOTTOM" , -13 , -3 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetWidth( 74 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:SetWidth( 74 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:SetPoint ( "LEFT" , GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton , "RIGHT" , 6 , 0 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButtonTxt:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButtonTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButtonTxt:SetText ( GRM.L ( "Cancel" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetPoint ( "CENTER" , GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.9 );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( GRM.L ( "Set Join Date" ) );
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetScript ( "OnShow" , function()
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Hide();
    end);
end


-- Method           GRM.MetaDataInitializeUIrosterLog2( boolean )
-- What it Does:    Keeps the log initialization separate and part of the UIParent, so it can load upon logging in
-- Purpose:         Resource control. This loads upon login, but keeps the rest of the addon UI initialization from occuring unless as needed.
--                  In other words, this can be loaded upon logging, but the rest will only load if the guild roster window loads.
GRM_UI.MetaDataInitializeUIrosterLog2 = function()

    
    GRM_UI.GRM_GroupInfo:SetFrameStrata ( "High" );
    GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:SetPoint ( "TOP" , RaidFrame , 0 , -32 );
    GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );

    -- CHECKBUTTONS for Logging Details
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -45 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -45 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetTextColor ( 0.5 , 1.0 , 0.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetText ( GRM.L ( "Joined" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -70 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -70 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetTextColor ( 0.0 , 0.44 , 0.87 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetText ( GRM.L ( "Leveled" ) .. " " );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetWidth ( 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText , "RIGHT" , 1 , -1.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButtonText2:SetText ( GRM.L ( "Min:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] = false;
            end
        end
    end);


    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -95 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -95 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetTextColor ( 0.0 , 1.0 , 0.87 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetText ( GRM.L ( "Inactive Return" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -120 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -120 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetTextColor ( 1.0 , 0.914 , 0.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetText ( GRM.L ( "Promotions" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -145 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -145 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetTextColor ( 0.91 , 0.388 , 0.047 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetText ( GRM.L ( "Demotions" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetScript ( "OnClick", function(self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -170 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -170 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetTextColor ( 1.0 , 0.6 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetText ( GRM.L ( "Note" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -195 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -195 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetTextColor ( 1.0 , 0.094 , 0.93 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetText ( GRM.L ( "Officer's Note" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:SetScript ( "OnClick", function(self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -220 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -220 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetTextColor ( 0.90 , 0.82 , 0.62 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetText ( GRM.L ( "Name Change" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -245 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -245 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetTextColor ( 0.64 , 0.102 , 0.102 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetText ( GRM.L ( "Rank Renamed" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -270 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -270 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetText ( GRM.L ( "Event Announce" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] = false;
            end
        end
    end);
     
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -295 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -295 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetText ( GRM.L ( "Left" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -320 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -320 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetTextColor ( 0.65 , 0.19 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetText ( GRM.L ( "Recommendations" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -345 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -345 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton , 27 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetText ( GRM.L ( "Banned" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetWordWrap ( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetWidth ( 120 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButtonText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] = false;
            end
            GRM.BuildLogComplete();
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetScript ( "OnClick", function( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] = false;
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -370 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButtonText:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterCheckBoxSideFrame , 0 , 22 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButtonText:SetText ( "<  " .. GRM.L ( "Check All" ) .. "  >" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterCheckAllChatButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -370 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterCheckAllChatButton:SetHitRectInsets ( 0 , 0 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCheckAllLogButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            for i = 1 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3] do
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][i] = true;
            end
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:SetChecked( true );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:SetChecked( true );

        else
            for i = 1 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3] do
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][i] = false;
            end
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:SetChecked( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:SetChecked( false );
        end
        GRM.BuildLogComplete();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterCheckAllChatButton:SetScript ( "OnClick", function( self )
        if self:GetChecked() then
            for i = 1 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13] do
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][i] = true;
            end
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetChecked( true );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetChecked( true );

        else
            for i = 1 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13] do
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][i] = false;
            end
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetChecked( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetChecked( false );
        end
        GRM.BuildLogComplete();
    end);
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RosterAddTimestampCheckButton , "BOTTOMLEFT" , 0 , -6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton , "RIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButtonText:SetText ( GRM.L ( "Notify When Players Request to Join the Guild" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame.GRM_RecruitNotificationCheckButton:SetScript ( "OnClick", function ( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][27] = true;
                GRM.UpdateRecruitmentPlayerStatus();
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][27] = false;
            end
        end
    end);

    -- Propagate for keyboard control of the frames!!!
    GRM_UI.GRM_RosterChangeLogFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterChangeLogFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterChangeLogFrame:SetPropagateKeyboardInput ( false );
            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                if GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox ~= nil and GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:HasFocus() then
                    GRM_UI.EscapeOfficerNoteEditBox();
                elseif GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox ~= nil and GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:HasFocus() then
                    GRM_UI.PlayerPublicNoteEditBox();
                elseif GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox ~= nil and GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:IsVisible() then
                    if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:HasFocus() then
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:SetText( "" );
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:ClearFocus();
                    else
                        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
                    end
                elseif GuildMemberDetailFrame ~= nil and GuildMemberDetailFrame:IsVisible() then
                    GuildMemberDetailFrame:Hide();
                    GRM_AddonGlobals.pause = true;
                else
                    GRM_AddonGlobals.pause = false;
                    GRM_UI.GRM_MemberDetailMetaData:Hide();
                end
            else
                GRM_UI.GRM_RosterChangeLogFrame:Hide();
            end
            
        end
    end);

    GRM_UI.GRM_RosterConfirmFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterConfirmFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterConfirmFrame:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterConfirmFrame:Hide();
        end
    end);

    -- Build Log Frames Function
    GRM_UI.GRM_RosterChangeLogFrame:SetScript ( "OnShow" , function()
        GRM_UI.BuildLogFrames()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText( GRM.L ( "Search Filter" ) );
    end);

    --Side frame for reporting controls
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame , 0 , -12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetText ( GRM.L ( "Display Changes" ) );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -28 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText:SetText ( GRM.L ( "To Chat:" ) );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -28 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText:SetText ( GRM.L  ( "To Log:" ) );

    -- User with addon installed...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , 0 , - 3.8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameText:SetText ( GRM.L ( "GRM Sync Info" ) .. "     ( " .. GRM.L ( "Ver: {custom1}" , nil , nil , nil , string.sub ( GRM_AddonGlobals.Version , string.find ( GRM_AddonGlobals.Version , "R" , -8 ) , #GRM_AddonGlobals.Version ) ) .. " )" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollBorderFrame , "TOPLEFT" , 20 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText:SetText ( string.upper ( GRM.L ( "Name:" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText2:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollBorderFrame , "TOP" , 0 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText2:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText2:SetText ( string.upper ( GRM.L ( "Sync" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText3:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollBorderFrame , "TOPRIGHT" , -20 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText3:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText3:SetText ( string.upper ( GRM.L ( "Version" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersCoreFrameTitleText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , 0 , 45 ) ;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 13 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:SetText ( string.upper ( GRM.L ( "Your Sync is Currently Disabled" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:SetTextColor ( 1 , 0 , 0 , 1 );
    
    -- Scroll Frame Details
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollBorderFrame:SetSize ( 584 , 420 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollBorderFrame:SetPoint ( "Bottom" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , -10 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:SetSize ( 566 , 397 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame , -3 , 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetSize ( 20 , 378 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame , "TOPRIGHT" , -2.5 , -9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:SetVerticalScroll( self:GetValue() )
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:SetScript ( "OnShow" , function()
        GRM.RefreshAddonUserFrames();
     end);

    -- The mouseover tooltip for the addon users window!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersTooltip:SetWidth ( 300 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersTooltip:SetFrameStrata ( "DIALOG" );
    -- Tooltip logic for on update
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:SetScript ( "OnUpdate" , function ( self , elapsed )
        GRM_AddonGlobals.usersTimerTooltip = GRM_AddonGlobals.usersTimerTooltip + elapsed;
        if GRM_AddonGlobals.usersTimerTooltip >= 0.1 then
            local isOver = false;
            for i = 1 , #self.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings do
                if self.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1]:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                    isOver = true;
                    if not self.GRM_AddonUsersTooltip:IsVisible() then
                        local classColorRGB = GRM.GetClassColorRGB ( GRM.GetPlayerClass ( GRM_AddonGlobals.currentAddonUsers[i][1] ) );
                        self.GRM_AddonUsersTooltip:SetOwner( self.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1] , "ANCHOR_LEFT" );
                        self.GRM_AddonUsersTooltip:AddLine( GRM_AddonGlobals.currentAddonUsers[i][1] , classColorRGB[1] , classColorRGB[2] , classColorRGB[3] , true );
                        self.GRM_AddonUsersTooltip:Show();
                    end
                    break
                end
            end
            if not isOver then
                self.GRM_AddonUsersTooltip:Hide();
            end
            GRM_AddonGlobals.usersTimerTooltip = 0;
        end
        -- Update the refresh frames...
        GRM_AddonGlobals.timer5 = GRM_AddonGlobals.timer5 + elapsed;
        if GRM_AddonGlobals.timer5 >= 5 then
            GRM.RegisterGuildAddonUsersRefresh ();
            GRM_AddonGlobals.timer5 = 0;
        end
    end);

    -- AUDIT FRAME VALUES
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameTitleText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , 0 , - 3.8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameTitleText:SetText ( GRM.L ( "Guild Data Audit" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText1:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame , "TOPLEFT" , 20 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText1:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText1:SetText ( string.upper ( GRM.L ( "Name" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText2:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame , "TOP" , -70 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText2:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText2:SetText ( string.upper ( GRM.L ( "Join Date" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText3:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame , "TOP" , 50 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText3:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText3:SetText ( string.upper ( GRM.L ( "Promo Date" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText4:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame , "TOPRIGHT" , -20 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText4:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText4:SetText ( string.upper ( GRM.L ( "Main/Alt" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText4:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "TOPLEFT" , 7 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText6:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "TOPRIGHT" , -35 , -4.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText6:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText6:SetText ( GRM.L ( "Click Player to Edit" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText6:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText6:SetTextColor ( 1 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8 , "TOP" , 0 , 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText4 , "TOP" , 0 , 3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , "TOPLEFT" , 11 , -24 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox.GRM_AudtFrameCheckBoxText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox , "RIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox.GRM_AudtFrameCheckBoxText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox.GRM_AudtFrameCheckBoxText:SetText ( GRM.L ( "Only Show Incomplete Guildies" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox.GRM_AudtFrameCheckBoxText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox.GRM_AudtFrameCheckBoxText:SetWidth( 170 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][30] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][30] = false;
            end
            GRM.SetGuildInfoDetails();
            GRM.RefreshAuditFrames();
        end
    end);
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox , "BOTTOMLEFT" , 0 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox.GRM_AuditFrameIncludeUnknownCheckBoxText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox , "RIGHT" , 1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox.GRM_AuditFrameIncludeUnknownCheckBoxText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox.GRM_AuditFrameIncludeUnknownCheckBoxText:SetText ( GRM.L ( "Include Unknown as Incomplete" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox.GRM_AuditFrameIncludeUnknownCheckBoxText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox.GRM_AuditFrameIncludeUnknownCheckBoxText:SetWidth( 170 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if self:GetChecked() then
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][33] = true;
            else
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][33] = false;
            end
            GRM.SetGuildInfoDetails();
            GRM.RefreshAuditFrames();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText2 , "TOP" , 0 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton:SetSize ( 100 , 34 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetWidth ( 90 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            GRM.SetAllIncompleteJoinUnknown();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText3 , "TOP" , 0 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton:SetSize ( 100 , 34 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetWidth ( 90 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            GRM.SetAllIncompletePromoUnknown();
        end
    end);

    -- Scroll Frame Details
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame:SetSize ( 584 , 380 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollBorderFrame:SetPoint ( "Bottom" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , -10 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:SetSize ( 566 , 355 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame , -3 , 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetSize ( 20 , 336 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame , "TOPRIGHT" , -2.5 , -9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:SetVerticalScroll( self:GetValue() )
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:SetScript ( "OnShow" , function()
        GRM.SetGuildInfoDetails();
        GRM.RefreshAuditFrames()
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][30] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameShowAllCheckbox:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][33] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameIncludeUnknownCheckBox:SetChecked ( true );
        end
    end);

    -- For tooltip on the audit frame...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:SetScript ( "OnUpdate" , function ( self , elapsed )
        GRM_AddonGlobals.auditTimer = GRM_AddonGlobals.auditTimer + elapsed;
        if GRM_AddonGlobals.auditTimer > 0.05 then
            local isOverAFrame = false;
            for i = 1 , #self.GRM_AuditScrollChildFrame.AllFrameFontstrings do
                if self.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][1]:IsMouseOver ( 3 , -3 , -3 , 3 ) or self.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][2]:IsMouseOver ( 3 , -3 , -3 , 3 ) or self.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][3]:IsMouseOver ( 3 , -3 , -3 , 3 ) or self.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][4]:IsMouseOver ( 3 , -3 , -3 , 3 ) then
                    isOverAFrame = true;
                    if GRM_AddonGlobals.currentAuditFontstringIndex ~= i then        -- This is just checking if need to reprocess tooltip
                        GRM_AddonGlobals.currentAuditFontstringIndex = i;
                        
                        GameTooltip:SetOwner ( self , "ANCHOR_CURSOR" );
                        GameTooltip:AddLine ( GRM.GetClassifiedName ( self.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][1]:GetText() , false ) );
                        GameTooltip:AddLine ( GRM.L ( "|CFFE6CC7FClick|r to open Player Window" ) );
                        GameTooltip:AddLine( GRM.L ( "|CFFE6CC7FCtrl-Shift-Click|r to Search the Log for Player" ) );
                        GameTooltip:Show();
                    end
                    break;
                end
            end
            if not isOverAFrame then
                GRM_AddonGlobals.currentAuditFontstringIndex = 0;
                GameTooltip:Hide();
            end
            GRM_AddonGlobals.auditTimer = 0;
        end   
    end);
    
    -- On Click -- to bring up the roster window and the player specifically
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame:SetScript ( "OnMouseDown" , function ( self , button ) 
        if button == "LeftButton" and not GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton:IsMouseOver (1 , -1 , -1 , 1 ) and not GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton:IsMouseOver (1 , -1 , -1 , 1 ) and GRM_AddonGlobals.currentAuditFontstringIndex > 0 then

            local playerName = self.AllFrameFontstrings[GRM_AddonGlobals.currentAuditFontstringIndex][1]:GetText();
            if IsShiftKeyDown() and IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:Click();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText( GRM.SlimName ( playerName ) );

            else
                if not GuildFrame or not GuildFrame:IsVisible() then
                    GuildMicroButton:Click();
                end
                if not GuildRosterFrame:IsVisible() then
                    GuildFrameTab2:Click();
                end
                GRM_AddonGlobals.currentName = playerName;
                GRM_AddonGlobals.pause = false;
                GRM.ClearAllFrames( true );
                GRM.PopulateMemberDetails ( playerName );
                GRM_UI.GRM_MemberDetailMetaData:Show();
                GuildMemberDetailFrame:Hide();
                GRM_AddonGlobals.pause = true;
            end

        end
    end);

    -- BAN LIST FRAME LOGIC AND INITIALIZATION DETAILS!!!
    -- User with addon installed...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , 0 , - 3.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame , "TOPLEFT" , 20 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetText ( string.upper ( GRM.L ( "Name:" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame , "TOP" , 68 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetText ( string.upper ( GRM.L ( "Rank" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame , "TOPRIGHT" , -35 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetText ( string.upper ( GRM.L ( "Ban Date" ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3 , "TOP" , 0 , 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetWidth ( 100 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText , "RIGHT" , 30 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , 8 , - 6 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 17 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetWidth ( 275 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetText ( GRM.L ( "No Players Have Been Banned from Your Guild" ) );
    -- Scroll Frame Details
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame:SetSize ( 584 , 375 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollBorderFrame:SetPoint ( "Bottom" , GRM_UI.GRM_RosterChangeLogFrame , -10 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:SetSize ( 566 , 353 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame , -3 , 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetSize( 20 , 334 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame , "TOPRIGHT" , -2.5 , -9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:SetVerticalScroll( self:GetValue() )
    end);
    --Add and Remove Ban Buttons
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame , "TOPLEFT" , 25 , -28 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton:SetSize ( 80 , 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText:SetWidth ( 70 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText:SetText ( GRM.L ( "Remove Ban" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton , "RIGHT" , 25 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButton:SetSize ( 80 , 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButtonText:SetText ( GRM.L ( "Add" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButtonText :SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );

    -- Add Ban Frame and details..
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetPoint ( "CENTER" , UIPanel );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetSize ( 300 , 210 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetFrameStrata ( "DIALOG" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetToplevel ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:EnableMouse ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetMovable ( true );    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:RegisterForDrag ( "LeftButton" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetScript ( "OnDragStart" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.StartMoving );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetScript( "OnDragStop" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.StopMovingOrSizing );
    
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanTitleText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , 0 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanTitleText:SetText ( GRM.L ( "Add Player to Ban List" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanTitleText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "TOPLEFT" , 18 , -35 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionText:SetText ( GRM.L ( "Name:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    -- Edit Box Values
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionText , "RIGHT" , 20 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetSize ( 125 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetMaxLetters ( 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetAutoFocus( false );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox , "BOTTOMLEFT" , 0 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetSize ( 125 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetMaxLetters ( 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetAutoFocus( false );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected , "BOTTOMLEFT" , 0 , -3 );
    -- GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame:SetFrameStrata ( "DIALOG" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame:SetBackdrop ( GRM_UI.noteBackdrop2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame:SetSize ( 128 , 60 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame:EnableMouse ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame:SetScript ( "OnMouseDown" , function ( _ , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetFocus();
        end
    end);
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxFrame , "TOPLEFT" , 2 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetSize ( 125 , 60 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetMaxLetters ( 75 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:EnableMouse( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetAutoFocus( false );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetMultiLine( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetSpacing ( 1 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionText , "BOTTOMLEFT" , 0 , -10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionText:SetText ( GRM.L ( "Server:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanClassSelectionText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionText , "BOTTOMLEFT" , 0 , -10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanClassSelectionText:SetText ( GRM.L ( "Class:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanClassSelectionText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanClassSelectionText , "BOTTOMLEFT" , 0 , -10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxText:SetText ( GRM.L ( "Reason:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBoxText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , 0 , 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText:SetText ( GRM.L ( "It is CRITICAL the player's name and server are spelled correctly for accurate tracking and notifications." ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText:SetWidth ( 250 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText:SetTextColor ( 1 , 0 , 0 , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionWarningText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );

    -- Edibox controls
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetScript ( "OnEscapePressed" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetScript ( "OnEnterPressed" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton:Click();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetScript ( "OnCursorChanged" , function( self )
        if self:GetHeight() > 56 then
            local text =  self:GetText();
            self:SetText ( string.sub ( text , 1 , #text - 1 ) );
        end
    end);

    -- Confirm Button Values
    -- Bring up the window for the ban list!!!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton:SetSize ( 55 , 40 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "TOPRIGHT" , -30 , -25 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton , 0 , -1.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText:SetWidth ( 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButtonText:SetText ( GRM.L ( "Submit Ban" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetScript ( "OnEnterPressed" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetScript ( "OnTabPressed" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:ClearFocus();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
        if IsShiftKeyDown() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetFocus();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetFocus();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetCursorPosition ( 0 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:HighlightText ( 0 );
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetScript ( "OnEnterPressed" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:ClearFocus();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetScript ( "OnTabPressed" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:ClearFocus();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
        if IsShiftKeyDown() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetFocus();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetCursorPosition ( 0 );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:HighlightText ( 0 );
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Show();        
        end
    end);


    -- CLASS DROP DOWN MENU 
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox , "BOTTOMLEFT" , -3.8 , -4 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:SetSize (  129 , 18 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetWidth ( 129 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected , "BOTTOM" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetWidth ( 129 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:Show();
        elseif key == "TAB" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
            if IsShiftKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetFocus();
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetFocus();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetScript ( "OnHide" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetScript ( "OnTabPressed" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:ClearFocus();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
        if IsShiftKeyDown() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Show();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetFocus();            
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetScript ( "OnEditFocusGained" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:HighlightText ( 0 );
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetScript ( "OnEditFocusLost" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:HighlightText ( #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:GetText() );
    end);
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
            else
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Show();
            end
        end
    end);

    -- Resets the values on loading the "Add Ban" window...
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetScript ( "OnShow" , function()
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetFocus();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetText ( "" );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:ClearFocus();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetText ( GetRealmName() );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetText ( GRM.L ( "Deathknight" ) );
        GRM_AddonGlobals.tempAddBanClass = "DEATHKNIGHT";
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetText ( GRM.L ( "Reason Banned?" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
        
        GRM.PopulateClassDropDownMenu();
    end)

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame , "BOTTOM" , -1 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetSize ( 307 , 100 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:EnableKeyboard ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetToplevel ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetFrameStrata ( "DIALOG" );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButton:SetPoint ( "BOTTOMLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame , "BOTTOMLEFT" , 25 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButton:SetSize ( 50 , 30 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButtonText:SetText ( GRM.L ( "Confirm" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButton:SetPoint ( "BOTTOMRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame , "BOTTOMRIGHT" , -25 , 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButton:SetSize ( 50 , 30 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButtonText:SetText ( GRM.L ( "Cancel" ) );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame , 0 , -20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText:SetText ( GRM.L ( "Confirm Ban for the Following Player?" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText2:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText , "BOTTOM" , 0 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText2:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanConfirmButton:SetScript ( "OnClick" , function ( _ , button)
        if button == "LeftButton" then
            -- Run some logic... and if it is good, confirm popup window pop
            local name = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:GetText();
            local server = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:GetText();
            local needsToReEnter = false;

            if #name <= 1 or not GRM.IsValidName( name ) then
                DEFAULT_CHAT_FRAME:AddMessage ( GRM.L ( "Please Enter a Valid Player Name" ) , 1.0 , 0.84 , 0 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:SetFocus();
                needsToReEnter = true;
            end
            if #server <= 1 or tonumber ( server ) ~= nil then
                DEFAULT_CHAT_FRAME:AddMessage ( GRM.L ( "Please Enter a Valid Server Name" ) , 1.0 , 0.84 , 0 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:SetFocus();
                needsToReEnter = true;
            end

            if not needsToReEnter then
                -- Popupwindow confirm.
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:ClearFocus();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:ClearFocus();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:ClearFocus();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();

                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText2:SetText ( GRM.Trim( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:GetText() ) .. "-" .. GRM.Trim( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:GetText() ) );
                local classColors = GRM.GetClassColorRGB ( string.upper ( GRM_AddonGlobals.tempAddBanClass ) );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameText2:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Show();
            end
        end
    end);

    -- So escape key can hide the frames.
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:Hide();
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrameYesButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            -- This is where the actual logic for doling out the ban takes place!!!
            
            -- Required info to add the player...
            local fullName = GRM.Trim( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanNameSelectionEditBox:GetText() ) .. "-" .. string.gsub ( string.gsub ( GRM.Trim( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanServerSelectionEditBox:GetText() ) , "-" , "" ) , "%s+" , "" );
            local banReason = GRM.Trim ( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:GetText() );
            if banReason == GRM.L ( "Reason Banned?" ) or banReason == nil then
                banReason = "";
            end

            -- Ok, let's check if this player is already currently in the guild.
            local isFoundInLeft = false;
            local isFoundInGuild = false;
            local indexFound = 0;
            for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == fullName then
                    isFoundInLeft = true;
                    indexFound = i;
                    break;
                end
            end

            if not isFoundInLeft then
                for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == fullName then
                        isFoundInGuild = true;
                        indexFound = j;
                        break;
                    end
                end
            end

            if isFoundInLeft then
                GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][17][1] = true;
                GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][17][2] = time();
                GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][17][3] = false;
                GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][18] = banReason;
            
            elseif isFoundInGuild then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][17][1] = true;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][17][2] = time();
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][17][3] = false;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][indexFound][18] = banReason;
                
            else

                local memberInfoToAdd = {
                    fullName,
                    "< " .. GRM.L ( "Unknown" ) .. " >",
                    GuildControlGetNumRanks() - 1,
                    1,
                    "",
                    "",
                    string.upper ( GRM_AddonGlobals.tempAddBanClass ),
                    1,
                    "",
                    100,
                    false,
                    1,
                    false,
                    0
                }
                -- Add ban of in-guild guildie with notification!!!
                GRM.AddMemberToLeftPlayers ( memberInfoToAdd , GRM.GetTimestamp() , time() , GRM.GetTimestamp() , time() - 5000 );

                -- Now, let's implement the ban!
                for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == fullName then
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][1] = true;
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][2] = time();
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][3] = false;
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] = banReason;
                        break;
                    end
                end
            end
            -- Finally, close the window
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_PopupWindowConfirmFrame:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:Hide();

            if banReason == "" then
                banReason = GRM.L ( "None Given" );
            end
            local colorCode = GRM.GetClassColorRGB ( string.upper ( GRM_AddonGlobals.tempAddBanClass ) , true );
            local log = GRM.L ( "{name} has BANNED {name2} from the guild!" , GRM.GetClassifiedName ( GRM_AddonGlobals.addonPlayerName , true ) , colorCode .. GRM.SlimName ( fullName ) .. "|r" );
            local logEntry = ( GRM.GetTimestamp() .. " : " .. log );
            if banReason ~= GRM.L ( "None Given" ) then
                GRM.AddLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. banReason );
            end
            GRM.AddLog ( 17 , logEntry );
        
            -- Report the change to chat window...
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] then
                DEFAULT_CHAT_FRAME:AddMessage ( log , 1.0 , 0 , 0 );
                DEFAULT_CHAT_FRAME:AddMessage ( GRM.L ( "Reason Banned:" ) .. " " .. banReason , 1.0 , 1.0 , 1.0 );
            end
        
            GRM.BuildLogComplete();

            -- Live Sync the ban
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_BAN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] ) .. "?" .. fullName .. "?" .. tostring ( false ) .. "?" .. banReason .. "?" .. GRM_AddonGlobals.tempAddBanClass , "GUILD" );
            end

            -- and Update the live frames too!
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
                GRM.RefreshBanListFrames();
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListAddButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:Show();
        end
    end);
    -- For when the frame appears
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:SetScript ( "OnShow" , function()
        -- Reset the highlights and some certain frames...
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText:SetText ( GRM.L ( "{name} - Ban List" , GRM_AddonGlobals.guildName ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( GRM.L ( "Select a Player" ) );
        
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons ~= nil then
            for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
            end
        end
        -- Build the frames...
        GRM.RefreshBanListFrames();
    end);

    -- Removing a player from the ban list that is no longer in the guild.
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_BanListRemoveButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:IsVisible() then
                
                -- Send the unban out for sync'd players
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_UNBAN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] ) .. "?" .. GRM_AddonGlobals.TempBanTarget[1] .. "?" , "GUILD");
                end
               
                -- Do the unban locally...
                GRM.BanListUnban ( GRM_AddonGlobals.TempBanTarget[1] );

                -- Message
                if GRM_AddonGlobals.TempBanTarget ~= nil and #GRM_AddonGlobals.TempBanTarget ~= 0 then
                    local colorCode = GRM.rgbToHex ( { GRM_AddonGlobals.TempBanTarget[2][1] , GRM_AddonGlobals.TempBanTarget[2][2] , GRM_AddonGlobals.TempBanTarget[2][3] } );
                    GRM.Report ( GRM.L ( "{name} has been Removed from the Ban List." , colorCode .. GRM.SlimName ( GRM_AddonGlobals.TempBanTarget[1] ) .. "|r" ) );
                end
            else
                GRM.Report ( GRM.L ( "Please Select a Player to Unban!" ) );
            end
        end
    end);

    -- CALENDAR ADD EVENT FRAME
    -- SINCE PROTECTED FEATURE, PLAYER MUST MANUALLY ADD
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameTitleText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , 0 , - 3.5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameTitleText:SetText ( GRM.L ( "Event Calendar Manager" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollBorderFrame , 17 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText:SetText ( GRM.L ( "Name:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText2:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollBorderFrame , -150 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText2:SetText ( GRM.L ( "Event:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText3:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollBorderFrame , -200 , 8 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText3:SetText ( GRM.L ( "Description:" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameTitleText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    -- Scroll Frame Details
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollBorderFrame:SetSize ( 584 , 375 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollBorderFrame:SetPoint ( "Bottom" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , -10 , -2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:SetSize ( 566 , 353 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:SetPoint ( "BOTTOM" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , -3 , 10 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:SetScrollChild ( GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetSize( 20 , 334 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame , "TOPRIGHT" , -2.5 , -9 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue( 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValueStep ( 20 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetStepsPerPage ( 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:SetVerticalScroll( self:GetValue() )
    end);
    -- Buttons
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , "TOPLEFT" , 25 , -28 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton:SetSize ( 80 , 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText:SetWidth ( 70 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText:SetText ( GRM.L ( "Add to Calendar" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton , "RIGHT" , 25 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton:SetSize ( 80 , 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText:SetText ( GRM.L ( "Ignore Event" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText:SetWidth ( 70 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButtonText :SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    -- STATUS TEXT
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton , "RIGHT" , 130 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetWidth ( 140 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetSpacing ( 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton , "RIGHT" , 130 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText , "BOTTOM" , 0 , -5 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetWidth ( 105 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetWordWrap ( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetTextColor ( 0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddTitleText:SetText( "" );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame , 0 , 50 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:SetText ( GRM.L ( "You Do Not Have Permission to Add Events to Calendar" ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:SetTextColor ( 1 , 0 , 0 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Hide();
    
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:SetScript ( "OnShow" , function ( _ )
        if CanEditGuildEvent() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Hide();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Show();
        end
        GRM.CalendarQueCheck();
        GRM.RefreshAddEventFrame();
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameSetAnnounceButton:SetScript ( "OnClick" , function ( _ , button ) 
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:IsVisible() then
                GRM.Report ( GRM.L ( "No Player Event Has Been Selected" ) );
            else
                if CanEditGuildEvent() then
                    local tempTime = time();
                    if tempTime - GRM_AddonGlobals.CalendarAddDelay > 5 then
                        for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
                            local name = GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1];
                            local tempParsedTitle = ( GRM.SlimName ( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , 1 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) - 1 ) ) ) ) .. string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                            if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddTitleText:GetText() == GRM.SlimName ( name ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:GetText() == tempParsedTitle then

                                -- Ensure it is not already on the calendar ( eventName , year , month , day )
                                if not GRM.IsCalendarEventAlreadyAdded (  GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][5] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][3] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][4] ) then
                                    -- Add to Calendar
                                    GRM.AddAnnouncementToCalendar ( tempParsedTitle , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][3] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][4] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][5] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][6] );
                                    -- Do I really need a "SlimName" here?
                                    GRM.Report ( GRM.L ( "Event Added to Calendar: {custom1}" , nil , nil , nil , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] ) );
                                    
                                    -- Let's Broadcast the change to the other users now!
                                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                        GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_AC?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , "GUILD");
                                    end

                                    -- Remove from que
                                    GRM.RemoveFromCalendarQue ( name , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                                    -- Reset Frames
                                    -- Clear the buttons first
                                    if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
                                        for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
                                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
                                        end
                                    end
                                    -- Status Notification logic
                                    if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetText ( GRM.L ( "Please Select Event to Add to Calendar" ) );
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Show();
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Hide();
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Hide();
                                    else
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetText ( GRM.L ( "No Calendar Events to Add" ) );
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Show();
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Hide();
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Hide();
                                    end
                        
                                    -- Ok Building Frame!
                                    GRM.BuildEventCalendarManagerScrollFrame();
                                    -- Unlock the highlights too!
                                    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
                                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
                                    end

                                    GRM_AddonGlobals.CalendarAddDelay = tempTime;
                                    break;
                                else
                                    GRM.Report ( GRM.L ( "{name}'s event has already been added to the calendar!" , GRM.SlimName ( name ) ) );
                                    GRM.RemoveFromCalendarQue ( name , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                                end
                            end
                        end
                    else
                        GRM.Report ( GRM.L ( "Please wait {num} more seconds to Add Event to the Calendar!" , nil , nil , ( 6 - ( tempTime - GRM_AddonGlobals.CalendarAddDelay ) ) ) );
                    end
                else
                    GRM.Report ( GRM.L ( "You Do Not Have Permission to Add Events to Calendar" ) );
                end
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameIgnoreButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:IsVisible() then
                GRM.Report ( GRM.L ( "No Player Event Has Been Selected" ) );
            else
                for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
                    local name = GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1];
                    local tempParsedTitle = ( GRM.SlimName( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) - 1 ) ) ) ) .. string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                    if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddTitleText:GetText() == GRM.SlimName ( name ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:GetText() == tempParsedTitle then
                        -- Remove from que
                        GRM.RemoveFromCalendarQue ( name , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                        -- Reset Frames
                        -- Clear the buttons first
                        if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
                            for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
                                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
                            end
                        end
                        -- Status Notification logic
                        if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetText ( GRM.L ( "Please Select Event to Add to Calendar" ) );
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Show();
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Hide();
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Hide();
                        else
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetText ( GRM.L ( "No Calendar Events to Add" ) );
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Show();
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Hide();
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Hide();
                        end
                        -- Ok Building Frame!
                        GRM.BuildEventCalendarManagerScrollFrame();
                        -- Unlock the highlights too!
                        for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
                        end
                        -- Report
                        GRM.Report ( GRM.L ( "{name}'s Event Removed From the Que!" , GRM.SlimName ( name ) ) );
                        break;
                    end                
                end
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:SetScript ( "OnShow" , function ( _ )
        GRM.RefreshAddEventFrame();
    end);

    -- Tooltip
    -- GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsTooltip:SetScale ( 0.85 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsTooltip:SetWidth ( 300 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsTooltip:SetFrameStrata ( "DIALOG" );
    -- Tooltip logic for on update
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:SetScript ( "OnUpdate" , function ( self , elapsed )
        GRM_AddonGlobals.eventTimerTooltip = GRM_AddonGlobals.eventTimerTooltip + elapsed;
        if GRM_AddonGlobals.eventTimerTooltip >= 0.1 then
            for i = 1 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 do
                local descript = GetClickFrame ( "PlayerToAdd" .. i );
                if descript ~= nil and descript:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                    for j = 1 , #self.GRM_AddEventScrollChildFrame.allFrameButtons do
                        if self.GRM_AddEventScrollChildFrame.allFrameButtons[j][1] == descript then
                            if self.GRM_EventsTooltip:IsVisible() and not self.GRM_AddEventScrollChildFrame.allFrameButtons[j][2]:IsMouseOver ( 2 , -2 , -2 , 2 ) and not self.GRM_AddEventScrollChildFrame.allFrameButtons[j][4]:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                                self.GRM_EventsTooltip:Hide();
                            else
                                if self.GRM_AddEventScrollChildFrame.allFrameButtons[j][2]:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                                    local classColorRGB = GRM.GetClassColorRGB ( GRM.GetPlayerClass ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][1] ) );
                                    self.GRM_EventsTooltip:SetOwner( self.GRM_AddEventScrollChildFrame.allFrameButtons[j][2] , "ANCHOR_LEFT" );
                                    self.GRM_EventsTooltip:AddLine( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][1] , classColorRGB[1] , classColorRGB[2] , classColorRGB[3] , true );
                                    self.GRM_EventsTooltip:Show();
                                elseif self.GRM_AddEventScrollChildFrame.allFrameButtons[j][4]:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                                    self.GRM_EventsTooltip:SetOwner( self.GRM_AddEventScrollChildFrame.allFrameButtons[j][4] , "ANCHOR_RIGHT"  );
                                    self.GRM_EventsTooltip:AddLine( "|cFFFFFFFF" .. string.upper ( GRM.L ( "Full Description:" ) ) .. "\n");
                                    self.GRM_EventsTooltip:AddLine( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][6] , 1.0 , 0.84 , 0 , true );
                                    self.GRM_EventsTooltip:Show();
                                end
                            end
                            break;
                        end
                    end
                    break;
                elseif self.GRM_EventsTooltip:IsVisible() and not descript:IsMouseOver(1,-1,-1,1) then
                    self.GRM_EventsTooltip:Hide();                  
                end
            end
            GRM_AddonGlobals.eventTimerTooltip = 0;
        end
    end);

end

-- Load this at start. You cannot save frame positions between sessions unless it initializes in initial login.
GRM_UI.PreAddonLoadUI();
