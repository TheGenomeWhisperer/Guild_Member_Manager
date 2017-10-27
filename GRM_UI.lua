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
-- Note: In explanation as to why they are not tabled, but kept in local, Lua allows 200 "locals" to be declared. Locals are insanely fast.
-- While it is probably unnecessary to be concerned about speed, since this is a fairly low-resource cost addon, I am a bit OCD in peaking performance.
-- As such, for the time being, frames will not be tabled to an array, but instead will be kept local for the fastest possible lookups and resource management.
-- This may change in the future, but for now, it is unnecessary.


GRM_UI = {};

-- Core Frame
GRM_MemberDetailMetaData = CreateFrame( "Frame" , "GRM_MemberDetailMetaData" , GuildRosterFrame , "TranslucentFrameTemplate" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton = CreateFrame( "Button" , "GRM_MemberDetailMetaDataCloseButton" , GRM_MemberDetailMetaData , "UIPanelCloseButton");
GRM_MemberDetailMetaData:Hide();  -- Prevent error where it sometimes auto-loads.

-- Guild Member Detail Frame UI and Children
GRM_SetPromoDateButton = CreateFrame ( "Button" , "GRM_SetPromoDateButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_SetPromoDateButton.GRM_SetPromoDateButtonText = GRM_SetPromoDateButton:CreateFontString ( "GRM_SetPromoDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

GRM_DayDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_DayDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_DayDropDownMenuSelected:Hide();
GRM_DayDropDownMenuSelected.DayText = GRM_DayDropDownMenuSelected:CreateFontString ( "GRM_DayDropDownMenuSelected.DayText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_DayDropDownMenu = CreateFrame ( "Frame" , "GRM_DayDropDownMenu" , GRM_DayDropDownMenuSelected , "InsetFrameTemplate" );
GRM_DayDropDownButton = CreateFrame ( "Button" , "GRM_DayDropDownButton" , GRM_DayDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

GRM_YearDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_YearDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_YearDropDownMenuSelected:Hide();
GRM_YearDropDownMenuSelected.YearText = GRM_YearDropDownMenuSelected:CreateFontString ( "GRM_YearDropDownMenuSelected.YearText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_YearDropDownMenu = CreateFrame ( "Frame" , "GRM_YearDropDownMenu" , GRM_YearDropDownMenuSelected , "InsetFrameTemplate" );
GRM_YearDropDownButton = CreateFrame ( "Button" , "GRM_YearDropDownButton" , GRM_YearDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

GRM_MonthDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_MonthDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_MonthDropDownMenuSelected:Hide();
GRM_MonthDropDownMenuSelected.MonthText = GRM_MonthDropDownMenuSelected:CreateFontString ( "GRM_MonthDropDownMenuSelected.MonthText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_MonthDropDownMenu = CreateFrame ( "Frame" , "GRM_MonthDropDownMenu" , GRM_MonthDropDownMenuSelected , "InsetFrameTemplate" );
GRM_MonthDropDownButton = CreateFrame ( "Button" , "GRM_MonthDropDownButton" , GRM_MonthDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

-- SUBMIT BUTTONS
GRM_DateSubmitButton = CreateFrame ( "Button" , "GRM_DateSubmitButton" , GRM_MemberDetailMetaData , "UIPanelButtonTemplate" );
GRM_DateSubmitCancelButton = CreateFrame ( "Button" , "GRM_DateSubmitCancelButton" , GRM_MemberDetailMetaData , "UIPanelButtonTemplate" );
GRM_DateSubmitButtonTxt = GRM_DateSubmitButton:CreateFontString ( "GRM_DateSubmitButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_DateSubmitCancelButtonTxt = GRM_DateSubmitCancelButton:CreateFontString ( "GRM_DateSubmitCancelButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );

-- Normal frame translucent
noteBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 18,
    insets = { left == 5 , right = 5 , top = 5 , bottom = 5 }
}

-- Thinnner frame translucent template
noteBackdrop2 = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 9,
    insets = { left == 2 , right = 2 , top = 3 , bottom = 2 }
}

GRM_PlayerNoteWindow = CreateFrame( "Frame" , "GRM_PlayerNoteWindow" , GRM_MemberDetailMetaData );
GRM_noteFontString1 = GRM_PlayerNoteWindow:CreateFontString ( "GRM_noteFontString1" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_PlayerNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerNoteEditBox" , GRM_MemberDetailMetaData );
GRM_PlayerOfficerNoteWindow = CreateFrame( "Frame" , "GRM_PlayerOfficerNoteWindow" , GRM_MemberDetailMetaData );
GRM_noteFontString2 = GRM_PlayerOfficerNoteWindow:CreateFontString ( "GRM_noteFontString2" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_PlayerOfficerNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerOfficerNoteEditBox" , GRM_MemberDetailMetaData );
GRM_NoteCount = GRM_MemberDetailMetaData:CreateFontString ( "GRM_NoteCount" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_PlayerNoteEditBox:Hide();
GRM_PlayerOfficerNoteEditBox:Hide();

-- Populating Frames with FontStrings
GRM_MemberDetailNameText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailNameText" , "OVERLAY" , "GameFontNormalLarge" );
GRM_MemberDetailMainText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMainText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_MemberDetailLevel = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLevel" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailRankTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailRankTxt" , "OVERLAY" , "GameFontNormal" );
GRM_MemberDetailRankDateTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailRankDateTxt" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailNoteTitle = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailNoteTitle" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailONoteTitle = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailONoteTitle" , "OVERLAY" , "GameFontNormalSmall" );

-- Fontstring for MemberRank History 
GRM_MemberDetailJoinDateButton = CreateFrame ( "Button" , "GRM_MemberDetailJoinDateButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_MemberDetailJoinDateButtonText = GRM_MemberDetailJoinDateButton:CreateFontString ( "GRM_MemberDetailJoinDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_JoinDateText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_JoinDateText" , "OVERLAY" , "GameFontWhiteTiny" );

-- LAST ONLINE
GRM_MemberDetailLastOnlineTitleTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLastOnlineTitleTxt" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailLastOnlineTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLastOnlineTxt" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_MemberDetailDateJoinedTitleTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailDateJoinedTitleTxt" , "OVERLAY" , "GameFontNormalSmall" );

-- STATUS TEXT
GRM_MemberDetailPlayerStatus = GRM_MemberDetailMetaData:CreateFontString ("GRM_MemberDetailPlayerStatus" , "OVERLAY" , "GameFontNormalSmall" );

-- ZONEINFORMATION
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoZoneText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1 = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoTimeText1" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2 = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoTimeText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- GROUP INVITE and REMOVE from Guild BUTTONS
GRM_GroupInviteButton = CreateFrame ( "Button" , "GRM_GroupInviteButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_GroupInviteButton.GRM_GroupInviteButtonText = GRM_GroupInviteButton:CreateFontString ( "GRM_GroupInviteButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- GRM_RemoveGuildieButton = CreateFrame ( "Button" , "GRM_RemoveGuildieButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
-- GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText = GRM_RemoveGuildieButton:CreateFontString ( "GRM_RemoveGuildieButton" , "OVERLAY" , "GameFontWhiteTiny" );

-- Tooltips
GRM_MemberDetailRankToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailRankToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailRankToolTip:Hide();
GRM_MemberDetailJoinDateToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailJoinDateToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailJoinDateToolTip:Hide();
GRM_MemberDetailServerNameToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailServerNameToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailJoinDateToolTip:Hide();
GRM_MemberDetailNotifyStatusChangeTooltip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailNotifyStatusChangeTooltip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailNotifyStatusChangeTooltip:Hide();

-- CUSTOM POPUPBOX FOR REUSE -- Avoids all possibility of UI Taint by just building my own, for those that use a lot of addons.
GRM_PopupWindow = CreateFrame ( "Frame" , "GRM_PopupWindow" , GuildMemberDetailFrame , "TranslucentFrameTemplate" );
GRM_PopupWindow:Hide() -- Prevents it from autopopping up on load like it sometimes will.
GRM_PopupWindowCheckButton1 = CreateFrame ( "CheckButton" , "GRM_PopupWindowCheckButton1" , GRM_PopupWindow , "OptionsSmallCheckButtonTemplate" );
GRM_PopupWindowCheckButtonText = GRM_PopupWindowCheckButton1:CreateFontString ( "GRM_PopupWindowCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

GRM_PopupWindowCheckButton2 = CreateFrame ( "CheckButton" , "GRM_PopupWindowCheckButton2" , GRM_PopupWindow , "OptionsSmallCheckButtonTemplate" );
GRM_PopupWindowCheckButton2Text = GRM_PopupWindowCheckButton2:CreateFontString ( "GRM_PopupWindowCheckButton2Text" , "OVERLAY" , "GameFontNormalSmall" );

-- EDIT BOX FOR ANYTHING ( like banned player note );
GRM_MemberDetailEditBoxFrame = CreateFrame ( "Frame" , "GRM_MemberDetailEditBoxFrame" , GRM_PopupWindow , "TranslucentFrameTemplate" );
GRM_MemberDetailEditBoxFrame:Hide();
GRM_MemberDetailPopupEditBox = CreateFrame ( "EditBox" , "GRM_MemberDetailPopupEditBox" , GRM_MemberDetailEditBoxFrame );

-- Banned Fontstring and Buttons
GRM_MemberDetailBannedText1 = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailBannedText1" , "OVERLAY" , "GameFontNormalSmall");
GRM_MemberDetailBannedIgnoreButton = CreateFrame ( "Button" , "GRM_MemberDetailBannedIgnoreButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText = GRM_MemberDetailBannedIgnoreButton:CreateFontString ( "GRM_MemberDetailBannedIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- ALT FRAMES!!!
GRM_CoreAltFrame = CreateFrame( "Frame" , "GRM_CoreAltFrame" , GRM_MemberDetailMetaData );
GRM_CoreAltFrame:Hide(); -- No need to show initially. Occasionally on init. it would popup the title text. Just keep hidden with init.
GRM_CoreAltScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_CoreAltScrollFrame" , GRM_CoreAltFrame );

-- CONTENT ALT FRAME (Child Frame)
GRM_CoreAltScrollChildFrame = CreateFrame ( "Frame" , "GRM_CoreAltScrollChildFrame" );
-- SLIDER
GRM_CoreAltScrollFrameSlider = CreateFrame ( "Slider" , "GRM_CoreAltScrollFrameSlider" , GRM_CoreAltScrollFrame , "UIPanelScrollBarTemplate" );
-- ALT HEADER
GRM_altFrameTitleText = GRM_CoreAltFrame:CreateFontString ( "GRM_altFrameTitleText" , "OVERLAY" , "GameFontNormalSmall" );
-- ALT OPTIONSFRAME
GRM_altDropDownOptions = CreateFrame ( "Frame" , "GRM_altDropDownOptions" , GRM_MemberDetailMetaData );
GRM_altDropDownOptions:Hide();
GRM_altOptionsText = GRM_altDropDownOptions:CreateFontString ( "GRM_altOptionsText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_altOptionsDividerText = GRM_altDropDownOptions:CreateFontString ( "GRM_altOptionsDividerText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT BUTTONS
GRM_AddAltButton = CreateFrame ( "Button" , "GRM_AddAltButton" , GRM_CoreAltFrame , "GameMenuButtonTemplate" );
GRM_AddAltButtonText = GRM_AddAltButton:CreateFontString ( "GRM_AddAltButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltButton2 = CreateFrame ( "Button" , "GRM_AddAltButton2" , GRM_CoreAltScrollChildFrame , "GameMenuButtonTemplate" );
GRM_AddAltButton2Text = GRM_AddAltButton2:CreateFontString ( "GRM_AddAltButton2Text" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_altSetMainButton = CreateFrame ( "Button" , "GRM_altSetMainButton" , GRM_altDropDownOptions  );
GRM_altSetMainButtonText = GRM_altSetMainButton:CreateFontString ( "GRM_altSetMainButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_altRemoveButton = CreateFrame ( "Button" , "GRM_altRemoveButton" , GRM_altDropDownOptions );
GRM_altRemoveButtonText = GRM_altRemoveButton:CreateFontString ( "GRM_altRemoveButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_altFrameCancelButton = CreateFrame ( "Button" , "GRM_altFrameCancelButton" , GRM_altDropDownOptions );
GRM_altFrameCancelButtonText = GRM_altFrameCancelButton:CreateFontString ( "GRM_altFrameCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT TOOLTIP
GRM_altFrameToolTip = CreateFrame ( "GameTooltip" , "GRM_altFrameToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
-- ALT NAMES (If I end up running short on FontStrings, I may need to convert to use static buttons.)
GRM_AltName1 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName1" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName2 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName3 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName3" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName4 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName4" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName5 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName5" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName6 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName6" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName7 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName7" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName8 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName8" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName9 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName9" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName10 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName10" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName11 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName11" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AltName12 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName12" , "OVERLAY" , "GameFontNormalSmall" );
-- ADD ALT EDITBOX Frame
GRM_AddAltEditFrame = CreateFrame ( "Frame" , "GRM_AddAltEditFrame" , GRM_CoreAltFrame , "TranslucentFrameTemplate" );
GRM_AddAltEditFrame:Hide();
GRM_AddAltTitleText = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltTitleText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AddAltEditBox = CreateFrame ( "EditBox" , "GRM_AddAltEditBox" , GRM_AddAltEditFrame , "InputBoxTemplate" );
GRM_AddAltNameButton1 = CreateFrame ( "Button" , "GRM_AddAltNameButton1" , GRM_AddAltEditFrame );
GRM_AddAltNameButton2 = CreateFrame ( "Button" , "GRM_AddAltNameButton2" , GRM_AddAltEditFrame );
GRM_AddAltNameButton3 = CreateFrame ( "Button" , "GRM_AddAltNameButton3" , GRM_AddAltEditFrame );
GRM_AddAltNameButton4 = CreateFrame ( "Button" , "GRM_AddAltNameButton4" , GRM_AddAltEditFrame );
GRM_AddAltNameButton5 = CreateFrame ( "Button" , "GRM_AddAltNameButton5" , GRM_AddAltEditFrame );
GRM_AddAltNameButton6 = CreateFrame ( "Button" , "GRM_AddAltNameButton6" , GRM_AddAltEditFrame );
GRM_AddAltNameButton1Text = GRM_AddAltNameButton1:CreateFontString ( "GRM_AddAltNameButton1" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltNameButton2Text = GRM_AddAltNameButton2:CreateFontString ( "GRM_AddAltNameButton2" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltNameButton3Text = GRM_AddAltNameButton3:CreateFontString ( "GRM_AddAltNameButton3" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltNameButton4Text = GRM_AddAltNameButton4:CreateFontString ( "GRM_AddAltNameButton4" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltNameButton5Text = GRM_AddAltNameButton5:CreateFontString ( "GRM_AddAltNameButton5" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltNameButton6Text = GRM_AddAltNameButton6:CreateFontString ( "GRM_AddAltNameButton6" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltEditFrameTextBottom = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameTextBottom" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddAltEditFrameHelpText = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameHelpText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_AddAltEditFrameHelpText2 = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameHelpText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- CALENDAR ADD EVENT WINDOW
GRM_AddEventFrame = CreateFrame ( "Frame" , "GRM_AddEventFrame" , UIParent , "BasicFrameTemplate" );
GRM_AddEventFrame:Hide();
GRM_AddEventFrameTitleText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_AddEventFrameNameTitleText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_AddEventFrameNameDateText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameDateText" , "OVERLAY" , "GameFontNormal" );
GRM_AddEventFrameStatusMessageText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_AddEventFrameNameToAddText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_AddEventFrameNameToAddTitleText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameToAddTitleText" , "OVERLAY" , "GameFontNormal" );   -- Will never be displayed, just a frame txt holder
-- Set and Ignore Buttons
GRM_AddEventFrameSetAnnounceButton = CreateFrame ( "Button" , "GRM_AddEventFrameSetAnnounceButton" , GRM_AddEventFrame , "UIPanelButtonTemplate" );
GRM_AddEventFrameSetAnnounceButtonText = GRM_AddEventFrameSetAnnounceButton:CreateFontString ( "GRM_AddEventFrameSetAnnounceButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_AddEventFrameIgnoreButton = CreateFrame ( "Button" , "GRM_AddEventFrameIgnoreButton" , GRM_AddEventFrame , "UIPanelButtonTemplate" );
GRM_AddEventFrameIgnoreButtonText = GRM_AddEventFrameIgnoreButton:CreateFontString ( "GRM_AddEventFrameIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- SCROLL FRAME
GRM_AddEventScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_AddEventScrollFrame" , GRM_AddEventFrame );
GRM_AddEventScrollBorderFrame = CreateFrame ( "Frame" , "GRM_AddEventScrollBorderFrame" , GRM_AddEventFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
GRM_AddEventScrollChildFrame = CreateFrame ( "Frame" , "GRM_AddEventScrollChildFrame" );
-- SLIDER
GRM_AddEventScrollFrameSlider = CreateFrame ( "Slider" , "GRM_AddEventScrollFrameSlider" , GRM_AddEventScrollFrame , "UIPanelScrollBarTemplate" );
-- EvntWindowButton
GRM_AddEventLoadFrameButton = CreateFrame( "Button" , "GRM_AddEventLoadFrameButton" , GuildRosterFrame , "UIPanelButtonTemplate" );
GRM_AddEventLoadFrameButtonText = GRM_AddEventLoadFrameButton:CreateFontString ( "GRM_AddEventLoadFrameButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_AddEventLoadFrameButton:Hide();

-- CORE GUILD LOG EVENT FRAME!!!
GRM_RosterChangeLogFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogFrame" , UIParent , "BasicFrameTemplate" );
GRM_RosterChangeLogFrame:Hide();
GRM_RosterChangeLogFrameTitleText = GRM_RosterChangeLogFrame:CreateFontString ( "GRM_RosterChangeLogFrameTitleText" , "OVERLAY" , "GameFontNormal" );
-- CHECKBOX FRAME
GRM_UI.GRM_RosterCheckBoxSideFrame = CreateFrame ( "Frame" , "GRM_RosterCheckBoxSideFrame" , GRM_RosterChangeLogFrame , "TranslucentFrameTemplate" );
-- CHECKBOXES
GRM_UI.GRM_RosterLoadOnLogonCheckButton = CreateFrame ( "CheckButton" , "GRM_UI.GRM_RosterLoadOnLogonCheckButton" , GRM_RosterChangeLogFrame , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterLoadOnLogonCheckButtonText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterLoadOnLogonCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterLoadOnLogonCheckButton:Hide();

-- Display options
GRM_RosterPromotionChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterPromotionChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterPromotionChangeCheckButtonText = GRM_RosterPromotionChangeCheckButton:CreateFontString ( "GRM_RosterPromotionChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterDemotionChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterDemotionChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterDemotionChangeCheckButtonText = GRM_RosterDemotionChangeCheckButton:CreateFontString ( "GRM_RosterDemotionChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterLeveledChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeveledChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterLeveledChangeCheckButtonText = GRM_RosterLeveledChangeCheckButton:CreateFontString ( "GRM_RosterLeveledChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterNoteChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNoteChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterNoteChangeCheckButtonText = GRM_RosterNoteChangeCheckButton:CreateFontString ( "GRM_RosterNoteChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterOfficerNoteChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterOfficerNoteChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterOfficerNoteChangeCheckButtonText = GRM_RosterOfficerNoteChangeCheckButton:CreateFontString ( "GRM_RosterOfficerNoteChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterJoinedCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterJoinedCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterJoinedCheckButtonText = GRM_RosterJoinedCheckButton:CreateFontString ( "GRM_RosterJoinedCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterLeftGuildCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeftGuildCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterLeftGuildCheckButtonText = GRM_RosterLeftGuildCheckButton:CreateFontString ( "GRM_RosterLeftGuildCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterInactiveReturnCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterInactiveReturnCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterInactiveReturnCheckButtonText = GRM_RosterInactiveReturnCheckButton:CreateFontString ( "GRM_RosterInactiveReturnCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterNameChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNameChangeCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterNameChangeCheckButtonText = GRM_RosterNameChangeCheckButton:CreateFontString ( "GRM_RosterNameChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterEventCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterEventCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterEventCheckButtonText = GRM_RosterEventCheckButton:CreateFontString ( "GRM_RosterEventCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterRankRenameCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRankRenameCheckButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterRankRenameCheckButtonText = GRM_RosterRankRenameCheckButton:CreateFontString ( "GRM_RosterRankRenameCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterRecommendationsButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendationsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterRecommendationsButtonText = GRM_RosterRecommendationsButton:CreateFontString ( "GRM_RosterRecommendationsButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterBannedPlayersButton = CreateFrame ( "CheckButton" , "GRM_RosterBannedPlayersButton" , GRM_UI.GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterBannedPlayersButtonText = GRM_RosterBannedPlayersButton:CreateFontString ( "GRM_RosterBannedPlayersButtonText" , "OVERLAY" , "GameFontNormalSmall" );
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
-- Fontstrings for side frame
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText = GRM_UI.GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_TitleSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText = GRM_UI.GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_ShowOnLogSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText = GRM_UI.GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_ShowOnChatSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );

-- SCROLL FRAME
GRM_RosterChangeLogScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_RosterChangeLogScrollFrame" , GRM_RosterChangeLogFrame );
GRM_RosterChangeLogScrollBorderFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogScrollBorderFrame" , GRM_RosterChangeLogFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
GRM_RosterChangeLogScrollChildFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogScrollChildFrame" );
-- SLIDER
GRM_RosterChangeLogScrollFrameSlider = CreateFrame ( "Slider" , "GRM_RosterChangeLogScrollFrameSlider" , GRM_RosterChangeLogScrollFrame , "UIPanelScrollBarTemplate" );
-- BUTTONS
GRM_LoadLogButton = CreateFrame( "Button" , "GRM_LoadLogButton" , GuildRosterFrame , "UIPanelButtonTemplate" );
GRM_LoadLogButton:Hide();
GRM_LoadLogButtonText = GRM_LoadLogButton:CreateFontString ( "GRM_LoadLogButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- OPTIONS PANEL BUTTONS ( in the Roster Log Frame)
-- CORE ADDON OPTIONS CONTROLS LISTED HERE!
-- Options Panel Checkboxes
GRM_RosterAddTimestampCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterAddTimestampCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_RosterAddTimestampCheckButtonText = GRM_RosterAddTimestampCheckButton:CreateFontString ( "GRM_RosterAddTimestampCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterOptionsButton = CreateFrame ( "Button" , "GRM_RosterOptionsButton" , GRM_RosterChangeLogFrame , "UIPanelButtonTemplate" );
GRM_RosterOptionsButtonText = GRM_RosterOptionsButton:CreateFontString ( "GRM_RosterOptionsButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_RosterClearLogButton = CreateFrame( "Button" , "GRM_RosterClearLogButton" , GRM_RosterChangeLogFrame , "UIPanelButtonTemplate" );
GRM_RosterClearLogButtonText = GRM_RosterClearLogButton:CreateFontString ( "GRM_RosterClearLogButtonText" , "OVERLAY" , "GameFontWhiteTiny");
--OPTIONS PANEL FONTSTRING DESCRIPTION ON OPTIONS CONTROLS
GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsHeaderText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsHeaderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSyncHeaderText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSyncHeaderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsRankRestrictHeaderText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsRankRestrictHeaderText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsScanDetailsText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsScanDetailsText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSlashCommandText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSlashCommandText" , "OVERLAY" , "GameFontNormal" );
--SLASH COMMAND FONTSTRINGS
GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandInstructionText = GRM_UI.GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandInstructionText" , "OVERLAY" , "GameFontNormal" );
-- Kick Recommendation Options
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendKickCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:CreateFontString ( "GRM_RosterRecommendKickCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2 = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:CreateFontString ( "GRM_RosterRecommendKickCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox = CreateFrame( "EditBox" , "GRM_RosterKickRecommendEditBox" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote = CreateFrame ( "Frame" , "GRM_RosterKickOverlayNote" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:CreateFontString ( "GRM_RosterKickOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Time Interval to Check for Changes
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterTimeIntervalCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton:CreateFontString ( "GRM_RosterTimeIntervalCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText2 = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton:CreateFontString ( "GRM_RosterTimeIntervalCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox = CreateFrame( "EditBox" , "GRM_RosterTimeIntervalEditBox" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:Hide();
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote = CreateFrame ( "Frame" , "GRM_RosterTimeIntervalOverlayNote" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNoteText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:CreateFontString ( "GRM_RosterTimeIntervalOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Report Inactive Options
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton = CreateFrame ( "CheckButton" , "GRM_RosterReportInactiveReturnButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:CreateFontString ( "GRM_RosterReportInactiveReturnButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2 = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:CreateFontString ( "GRM_RosterReportInactiveReturnButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox = CreateFrame( "EditBox" , "GRM_ReportInactiveReturnEditBox" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote = CreateFrame ( "Frame" , "GRM_ReportInactiveReturnOverlayNote" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:CreateFontString ( "GRM_ReportInactiveReturnOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Report Upcoming Events
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterReportUpcomingEventsCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportUpcomingEventsCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2 = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportUpcomingEventsCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox = CreateFrame( "EditBox" , "GRM_RosterReportUpcomingEventsEditBox" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote = CreateFrame ( "Frame" , "GRM_RosterReportUpcomingEventsOverlayNote" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:CreateFontString ( "GRM_RosterReportUpcomingEventsOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton = CreateFrame ( "CheckButton" , "GRM_RosterReportAddEventsToCalendarButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:CreateFontString ( "GRM_RosterReportAddEventsToCalendarButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Share changes with ONLINE guildies
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterSyncCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2 = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNotifyOnChangesCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Options RankDropDown
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected = CreateFrame ( "Frame" , "GRM_RosterSyncRankDropDownSelected" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "InsetFrameTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:CreateFontString ( "GRM_RosterSyncRankDropDownSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu = CreateFrame ( "Frame" , "GRM_RosterSyncRankDropDownMenu" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton = CreateFrame ( "Button" , "GRM_RosterSyncRankDropDownMenuButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "UIPanelScrollDownButtonTemplate" );

-- SYNC with players with outdated versions
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton = CreateFrame ( "CheckButton" , "GRM_SyncOnlyCurrentVersionCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton:CreateFontString ( "GRM_SyncOnlyCurrentVersionCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- SYNC with players with outdated versions
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList = CreateFrame ( "CheckButton" , "GRM_RosterSyncBanList" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:CreateFontString ( "GRM_RosterSyncBanListText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3 = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:CreateFontString ( "GRM_RosterSyncBanListText3" , "OVERLAY" , "GameFontNormalSmall" );

-- Options SYNC with Main Only
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterMainOnlyCheckButton" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , "OptionsSmallCheckButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:CreateFontString ( "GRM_RosterMainOnlyCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- Options Sync Ban List Drop Down
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected = CreateFrame ( "Frame" , "GRM_RosterBanListDropDownSelected" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "InsetFrameTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:CreateFontString ( "GRM_RosterBanListDropDownSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu = CreateFrame ( "Frame" , "GRM_RosterBanListDropDownMenu" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected , "InsetFrameTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton = CreateFrame ( "Button" , "GRM_RosterBanListDropDownMenuButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected , "UIPanelScrollDownButtonTemplate" );

-- Slash command Buttons in Options
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ScanOptionsButton = CreateFrame ( "Button" , "GRM_ScanOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOptionsButton = CreateFrame ( "Button" , "GRM_SyncOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_CenterOptionsButton = CreateFrame ( "Button" , "GRM_CenterOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_HelpOptionsButton = CreateFrame ( "Button" , "GRM_HelpOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ClearAllOptionsButton = CreateFrame ( "Button" , "GRM_ClearAllOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_VersionOptionsButton = CreateFrame ( "Button" , "GRM_VersionOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );
GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncInfoOptionsButton = CreateFrame ( "Button" , "GRM_SyncInfoOptionsButton" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "UIPanelButtonTemplate" );

-- Guild Event Log Frame Confirm Details.
GRM_RosterConfirmFrame = CreateFrame ( "Frame" , "GRM_RosterConfirmFrame" , UIPanel , "BasicFrameTemplate" );
GRM_RosterConfirmFrameText = GRM_RosterConfirmFrame:CreateFontString ( "GRM_RosterConfirmFrameText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_RosterConfirmYesButton = CreateFrame ( "Button" , "GRM_RosterConfirmYesButton" , GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
GRM_RosterConfirmYesButtonText = GRM_RosterConfirmYesButton:CreateFontString ( "GRM_RosterConfirmYesButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_RosterConfirmCancelButton = CreateFrame ( "Button" , "GRM_RosterConfirmCancelButton" , GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
GRM_RosterConfirmCancelButtonText = GRM_RosterConfirmCancelButton:CreateFontString ( "GRM_RosterConfirmCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- ADDON USERS FRAME
GRM_AddonUsersCoreFrame = CreateFrame ( "Frame" , "GRM_AddonUsersCoreFrame" , UIParent , "BasicFrameTemplate" );
GRM_AddonUsersCoreFrame:Hide();
GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameText = GRM_AddonUsersCoreFrame:CreateFontString ( "GRM_AddonUsersCoreFrameText" , "OVERLAY" , "GameFontNormal" );
GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameTitleText = GRM_AddonUsersCoreFrame:CreateFontString ( "GRM_AddonUsersCoreFrameTitleText" , "OVERLAY" , "GameFontNormal" );
-- SCROLL FRAME
GRM_AddonUsersScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_AddonUsersScrollFrame" , GRM_AddonUsersCoreFrame );
GRM_AddonUsersScrollBorderFrame = CreateFrame ( "Frame" , "GRM_AddonUsersScrollBorderFrame" , GRM_AddonUsersCoreFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
GRM_AddonUsersScrollChildFrame = CreateFrame ( "Frame" , "GRM_AddonUsersScrollChildFrame" );
GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2 = GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUsersCoreFrameTitleText2" , "OVERLAY" , "GameFontNormal" );
-- SLIDER
GRM_AddonUsersScrollFrameSlider = CreateFrame ( "Slider" , "GRM_AddonUsersScrollFrameSlider" , GRM_AddonUsersScrollFrame , "UIPanelScrollBarTemplate" );
-- EvntWindowButton
GRM_AddonUsersButton = CreateFrame( "Button" , "GRM_AddonUsersButton" , GuildRosterFrame , "UIPanelButtonTemplate" );
GRM_AddonUsersButtonText = GRM_AddonUsersButton:CreateFontString ( "GRM_AddonUsersButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_AddonUsersButton:Hide();

-- BAN LIST ALL FRAMES
-- BUTTONS
-- GRM_UI.GRM_RosterConfirmFrame = CreateFrame ( "Frame" , "GRM_RosterConfirmFrame" , UIPanel , "BasicFrameTemplate" );
-- GRM_UI.GRM_RosterConfirmFrameText = GRM_UI.GRM_RosterConfirmFrame:CreateFontString ( "GRM_RosterConfirmFrameText" , "OVERLAY" , "GameFontWhiteTiny");
-- GRM_UI.GRM_RosterConfirmYesButton = CreateFrame ( "Button" , "GRM_RosterConfirmYesButton" , GRM_UI.GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
-- GRM_UI.GRM_RosterConfirmYesButtonText = GRM_UI.GRM_RosterConfirmYesButton:CreateFontString ( "GRM_RosterConfirmYesButtonText" , "OVERLAY" , "GameFontWhiteTiny");
-- GRM_UI.GRM_RosterConfirmCancelButton = CreateFrame ( "Button" , "GRM_RosterConfirmCancelButton" , GRM_UI.GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
-- GRM_UI.GRM_RosterConfirmCancelButtonText = GRM_UI.GRM_RosterConfirmCancelButton:CreateFontString ( "GRM_RosterConfirmCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- CORE BANLIST FRAME
GRM_UI.GRM_CoreBanListFrame = CreateFrame ( "Frame" , "GRM_CoreBanListFrame" , UIParent , "BasicFrameTemplate" );
GRM_UI.GRM_CoreBanListFrame:Hide();
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2 = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText2" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3 = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText3" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4 = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameTitleText4" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameSelectedNameText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameNumBannedText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText = GRM_UI.GRM_CoreBanListFrame:CreateFontString ( "GRM_CoreBanListFrameAllOfflineText" , "OVERLAY" , "GameFontNormal" );
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:Hide();
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:Hide();
-- BANLIST SCROLL FRAME
GRM_UI.GRM_CoreBanListScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_CoreBanListScrollFrame" , GRM_UI.GRM_CoreBanListFrame );
GRM_UI.GRM_CoreBanListScrollBorderFrame = CreateFrame ( "Frame" , "GRM_CoreBanListScrollBorderFrame" , GRM_UI.GRM_CoreBanListFrame , "TranslucentFrameTemplate" );
-- BANLIST CONTENT FRAME (Child Frame)
GRM_UI.GRM_CoreBanListScrollChildFrame = CreateFrame ( "Frame" , "GRM_CoreBanListScrollChildFrame" );
-- BANLIST SLIDER
GRM_UI.GRM_CoreBanListScrollFrameSlider = CreateFrame ( "Slider" , "GRM_CoreBanListScrollFrameSlider" , GRM_UI.GRM_CoreBanListFrame , "UIPanelScrollBarTemplate" );
-- BANLIST BUTTON
GRM_UI.GRM_BanListButton = CreateFrame( "Button" , "GRM_BanListButton" , GuildRosterFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_BanListButtonText = GRM_UI.GRM_BanListButton:CreateFontString ( "GRM_BanListButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_UI.GRM_BanListButton:Hide();
-- Add and Remove BUTTONS
GRM_UI.GRM_BanListRemoveButton = CreateFrame ( "Button" , "GRM_BanListRemoveButton" , GRM_CoreBanListFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_BanListRemoveButtonText = GRM_UI.GRM_BanListRemoveButton:CreateFontString ( "GRM_BanListRemoveButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_UI.GRM_BanListAddButton = CreateFrame ( "Button" , "GRM_BanListAddButton" , GRM_CoreBanListFrame , "UIPanelButtonTemplate" );
GRM_UI.GRM_BanListAddButtonText = GRM_UI.GRM_BanListAddButton:CreateFontString ( "GRM_BanListAddButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- CUSTOM NOTE EDIT BOX FRAME INFO
-- GRM_UI.GRM_PlayerCustomNoteWindow = CreateFrame( "Frame" , "GRM_PlayerCustomNoteWindow" , GRM_MemberDetailMetaData );
-- GRM_UI.GRM_PlayerCustomNoteWindowFontString = GRM_UI.GRM_PlayerCustomNoteWindow:CreateFontString ( "GRM_PlayerCustomNoteWindowFontString" , "OVERLAY" , "GameFontWhiteTiny" );
-- GRM_UI.GRM_PlayerCustomNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerCustomNoteEditBox" , GRM_MemberDetailMetaData );
-- GRM_UI.GRM_PlayerCustomNoteEditBox:Hide();


-----------------------------------------------
--------- UI CONTROLS -------------------------
--------- AND PARAMETERS ----------------------
-----------------------------------------------


-- Method:          GR_MetaDataInitializeUIFirst()
-- What it Does:    Initializes "some of the frames"
-- Purpose:         Should only initialize as needed. Kept as local for speed
GRM_UI.GR_MetaDataInitializeUIFirst = function()
    -- Useful to build these buttons!
    -- GRM.CollectRosterButtons();

    -- Frame Control
    GRM_MemberDetailMetaData:EnableMouse ( true );
    GRM_MemberDetailMetaData:SetToplevel ( true );

    -- Placement and Dimensions
    GRM_MemberDetailMetaData:SetPoint ( "TOPLEFT" , GuildRosterFrame , "TOPRIGHT" , -4 , 5 );
    GRM_MemberDetailMetaData:SetSize( 300 , 330 );
    GRM_MemberDetailMetaData:SetScript( "OnShow" , function() 
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton:SetPoint( "TOPRIGHT" , GRM_MemberDetailMetaData , 3, 3 ); 
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton:Show();
    end);
    GRM_MemberDetailMetaData:SetScript ( "OnUpdate" , GRM.MemberDetailToolTips );

    -- Logic handling: If pause is set, this unpauses it. If it is not paused, this will then hide the window.
    GRM_MemberDetailMetaData:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_MemberDetailMetaData:SetPropagateKeyboardInput ( true );
        if key == "ESCAPE" then
            GRM_MemberDetailMetaData:SetPropagateKeyboardInput ( false );
            if GRM_AddonGlobals.pause then
                GRM_AddonGlobals.pause = false;
            else
                GRM_MemberDetailMetaData:Hide();
            end
        end
    end);

    -- For Fontstring logic handling, particularly of the alts.
    GRM_MemberDetailMetaData:SetScript ( "OnMouseDown" , function ( _ , button ) 
        if button == "RightButton" then
            GRM_AddonGlobals.selectedAlt = GRM.GetCoreFontStringClicked(); -- Setting to global the alt name chosen.
            if GRM_AddonGlobals.selectedAlt[1] ~= nil then
                GRM_AddonGlobals.pause = true;

                -- Positioning
                local cursorX , cursorY = GetCursorPosition();
                GRM_altDropDownOptions:ClearAllPoints();
                GRM_altDropDownOptions:SetPoint( "TOPLEFT" , UIParent , "BOTTOMLEFT" , cursorX , cursorY );
                GRM_altOptionsText:SetText ( GRM.SlimName ( GRM_AddonGlobals.selectedAlt[2] ) );
                local width = 70;
                if GRM_altOptionsText:GetStringWidth() + 15 > width then       -- For scaling the frame based on size of player name.
                    width = GRM_altOptionsText:GetStringWidth() + 15;
                end

                GRM_altSetMainButton:SetPoint ("TOPLEFT" , GRM_altDropDownOptions , 7 , -22 );
                GRM_altSetMainButton:SetSize ( 60 , 20 );
                GRM_altRemoveButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -36 );
                GRM_altRemoveButton:SetSize ( 60 , 20 );
                GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -55 );
                GRM_altOptionsDividerText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
                GRM_altOptionsDividerText:SetText ("__");
                GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -65 );
                GRM_altFrameCancelButton:SetSize ( 60 , 20 );
                GRM_altFrameCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
                
                if GRM_AddonGlobals.selectedAlt[1] == GRM_AddonGlobals.selectedAlt[2] then -- Not clicking an alt frame
                    if GRM_MemberDetailRankDateTxt:IsVisible() and GRM_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                        GRM_AddonGlobals.editPromoDate = true;
                        GRM_AddonGlobals.editJoinDate = false;
                        GRM_AddonGlobals.editFocusPlayer = false;
                        GRM_AddonGlobals.editStatusNotify = false;
                        GRM_AddonGlobals.editOnlineStatus = false;
                    elseif GRM_JoinDateText:IsVisible() and GRM_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                        GRM_AddonGlobals.editJoinDate = true;
                        GRM_AddonGlobals.editPromoDate = false;
                        GRM_AddonGlobals.editFocusPlayer = false;
                        GRM_AddonGlobals.editStatusNotify = false;
                        GRM_AddonGlobals.editOnlineStatus = false;
                    elseif GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                        GRM_AddonGlobals.editFocusPlayer = true;
                        GRM_AddonGlobals.editJoinDate = false;
                        GRM_AddonGlobals.editPromoDate = false;
                        GRM_AddonGlobals.editStatusNotify = false;
                        GRM_AddonGlobals.editOnlineStatus = false;
                    elseif GRM_MemberDetailPlayerStatus:IsMouseOver ( 2 , -2 , -2 , 2 ) and ( GRM_MemberDetailPlayerStatus:GetText() == "( AFK )" or GRM_MemberDetailPlayerStatus:GetText() == "( Busy )" or GRM_MemberDetailPlayerStatus:GetText() == "( Active )" or GRM_MemberDetailPlayerStatus:GetText() == "( Mobile )" or GRM_MemberDetailPlayerStatus:GetText() == "( Offline )" ) then
                        if GRM_MemberDetailPlayerStatus:GetText() == "( Offline )" or GRM_MemberDetailPlayerStatus:GetText() == "( Active )" then
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

                    GRM_MemberDetailRankToolTip:Hide();
                    GRM_MemberDetailJoinDateToolTip:Hide();
                    GRM_MemberDetailServerNameToolTip:Hide();
                    GRM_MemberDetailNotifyStatusChangeTooltip:Hide();
                    if GRM_AddonGlobals.editFocusPlayer then
                        if GRM_AddonGlobals.selectedAlt[4] ~= true then    -- player is not the main.
                            GRM_altSetMainButtonText:SetText ( "Set as Main" );
                        else -- player IS the main... place option to Demote From Main rahter than set as main.
                            GRM_altSetMainButtonText:SetText ( "Set as Alt" );
                        end
                        GRM_altRemoveButtonText:SetText ( "Reset Data!" );
                        GRM_altRemoveButton:Show();
                    elseif GRM_AddonGlobals.editStatusNotify then
                        GRM_altSetMainButtonText:SetText ( "Notify When Player is Active" );
                        GRM_altRemoveButtonText:SetText ( "Notify When Player Goes Offline" );
                        width = GRM_altRemoveButtonText:GetStringWidth() + 15;
                        GRM_altRemoveButton:SetSize ( 120 , 20 );
                        GRM_altSetMainButton:SetSize ( 120 , 20 );
                        GRM_altRemoveButton:Show();
                    elseif GRM_AddonGlobals.editOnlineStatus  then
                        if GRM_MemberDetailPlayerStatus:GetText() == "( Active )" then
                            GRM_altSetMainButtonText:SetText ( "Notify When Player Goes Offline" );
                        else
                            GRM_altSetMainButtonText:SetText ( "Notify When Player Comes Online" );
                        end
                        width = GRM_altSetMainButtonText:GetStringWidth() + 15;
                        GRM_altSetMainButton:SetSize ( 120 , 20 );
                        GRM_altRemoveButton:Hide();
                        GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -40 );
                        GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -55 );
                    else
                        GRM_altSetMainButtonText:SetText ( "Edit Date" );
                        GRM_altRemoveButtonText:SetText ( "Clear History" );
                        GRM_altRemoveButton:Show();
                    end
                else
                    if GRM_AddonGlobals.selectedAlt[4] ~= true then    -- player is not the main.
                        GRM_altSetMainButtonText:SetText ( "Set as Main" );
                    else -- player IS the main... place option to Demote From Main rahter than set as main.
                        GRM_altSetMainButtonText:SetText ( "Set as Alt" );
                    end
                    GRM_altRemoveButtonText:SetText ( "Remove" );
                    GRM_altRemoveButton:Show();
                end

                GRM_altDropDownOptions:SetSize ( width , 92 );
                GRM_altDropDownOptions:Show();
            end
        elseif button == "LeftButton" then
            if GRM_MemberDetailServerNameToolTip:IsVisible() and not GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                -- This makes the main window the alt that was clicked on! TempAltName is saved when mouseover action occurs.
                if GRM_AddonGlobals.tempAltName ~= "" then
                    GRM.SelectPlayerOnRoster ( GRM_AddonGlobals.tempAltName );
                end
            end
        end
    end);

    -- Useful for the ban window...
    -- Delay is there because it needs a moment to register frame change. 0.1 would prob be ok too.
    -- GRM_MemberDetailMetaData:SetScript ( "OnHide" , function()
    --     C_Timer.After ( 0.2 , function()
    --         if not GRM_MemberDetailMetaData:IsVisible() and GuildMemberDetailFrame:IsVisible() then
    --             GRM_PopupWindow:Show();
    --         end
    --     end);
    -- end);

    -- Keyboard Control for easy ESC closeButtons
    tinsert( UISpecialFrames, "GRM_MemberDetailMetaData" );

    -- Day Dropdown
    GRM_DayDropDownButton:SetPoint ( "LEFT" , GRM_DayDropDownMenuSelected , "RIGHT" , -2 , 0 );
    GRM_DayDropDownButton:SetSize (20 , 20 );

    GRM_DayDropDownMenuSelected:SetSize ( 30 , 20 );
    GRM_DayDropDownMenu:SetPoint ( "TOP" , GRM_DayDropDownMenuSelected , "BOTTOM" );
    GRM_DayDropDownMenu:SetWidth ( 34 );
    GRM_DayDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_DayDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_DayDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_DayDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_DayDropDownMenu:Hide();
            GRM_DayDropDownMenuSelected:Show();
        end
    end);

    GRM_DayDropDownMenuSelected:SetScript ( "OnShow" , function()
        GRM_DayDropDownMenu:Hide();
    end);

    GRM_MonthDropDownMenuSelected:SetSize ( 83 , 20 );
    GRM_MonthDropDownMenu:SetPoint ( "TOP" , GRM_MonthDropDownMenuSelected , "BOTTOM" );
    GRM_MonthDropDownMenu:SetWidth ( 80 );
    GRM_MonthDropDownMenu:SetFrameStrata ( "HIGH" );
    
    GRM_MonthDropDownButton:SetPoint ( "LEFT" , GRM_MonthDropDownMenuSelected , "RIGHT" , -2 , 0 );
    GRM_MonthDropDownButton:SetSize (20 , 20 );

    GRM_MonthDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_MonthDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_MonthDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_MonthDropDownMenu:Hide();
            GRM_MonthDropDownMenuSelected:Show();
        end
    end);

    GRM_MonthDropDownMenuSelected:SetScript ( "OnShow" , function()
        GRM_MonthDropDownMenu:Hide();
    end);

    GRM_YearDropDownMenuSelected:SetSize ( 53 , 20 );
    GRM_YearDropDownMenu:SetPoint ( "TOP" , GRM_YearDropDownMenuSelected , "BOTTOM" );
    GRM_YearDropDownMenu:SetWidth ( 52 );
    GRM_YearDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_YearDropDownButton:SetPoint ( "LEFT" , GRM_YearDropDownMenuSelected , "RIGHT" , -2 , 0 );
    GRM_YearDropDownButton:SetSize (20 , 20 );

    GRM_YearDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_YearDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_YearDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_YearDropDownMenu:Hide();
            GRM_YearDropDownMenuSelected:Show();
        end
    end);

    GRM_YearDropDownMenuSelected:SetScript ( "OnShow" , function()
        GRM_YearDropDownMenu:Hide();
    end);

    --Rank Drop down submit and cancel
    GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetPoint ( "CENTER" , GRM_SetPromoDateButton );
    GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetText ( "Date Promoted?" );
    GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_SetPromoDateButton:SetSize ( 90 , 18 );
    GRM_SetPromoDateButton:SetPoint ( "TOP" , GRM_MemberDetailRankTxt , "BOTTOM" , 0 , -4 );
    GRM_SetPromoDateButton:SetScript( "OnClick" , function( self , button , down ) 
        if button == "LeftButton" then
            GRM_SetPromoDateButton:Hide();
            GRM.SetDateSelectFrame ( "TOP" , GRM_MemberDetailMetaData , "PromoRank" );  -- Position, Frame, ButtonName
            GRM_AddonGlobals.pause = true;
        end
    end);

    GRM_DateSubmitButton:SetWidth( 74 );
    GRM_DateSubmitCancelButton:SetWidth( 74 );
    GRM_DateSubmitCancelButtonTxt:SetPoint ( "CENTER" , GRM_DateSubmitCancelButton );
    GRM_DateSubmitCancelButtonTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.9 );
    GRM_DateSubmitCancelButtonTxt:SetText ( "Cancel" );
    GRM_DateSubmitButtonTxt:SetPoint ( "CENTER" , GRM_DateSubmitButton );
    GRM_DateSubmitButtonTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.9 );
    GRM_DateSubmitButton:SetScript ( "OnShow" , function()
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Hide();
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Hide();
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Hide();
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Hide();
    end);


    DropDownList1Backdrop:HookScript ( "OnShow" , function() 
        if GuildMemberRankDropdownText:IsVisible() then
            GRM_AddonGlobals.CurrentRank = GuildMemberRankDropdownText:GetText();
        end
    end);
    
    -- Name Text
    GRM_MemberDetailNameText:SetPoint( "TOP" , 0 , -20 );
    GRM_MemberDetailNameText:SetFont (  GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );

    -- LEVEL Text
    GRM_MemberDetailLevel:SetPoint ( "TOP" , 0 , -38 );
    GRM_MemberDetailLevel:SetFont (  GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    -- Rank promotion date text
    GRM_MemberDetailRankTxt:SetPoint ( "TOP" , 0 , -54 );
    GRM_MemberDetailRankTxt:SetFont (  GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_MemberDetailRankTxt:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );

    -- "MEMBER SINCE"
    GRM_JoinDateText:SetPoint ( "TOPRIGHT" , GRM_MemberDetailMetaData , -21 , - 33 );
    GRM_JoinDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_JoinDateText:SetWidth ( 55 );
    GRM_JoinDateText:SetJustifyH ( "CENTER" );

    -- "LAST ONLINE" 
    GRM_MemberDetailLastOnlineTitleTxt:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 16 , -22 );
    GRM_MemberDetailLastOnlineTitleTxt:SetText ( "Last Online" );
    GRM_MemberDetailLastOnlineTitleTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_MemberDetailLastOnlineTxt:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 16 , -32 );
    GRM_MemberDetailLastOnlineTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_MemberDetailLastOnlineTxt:SetWidth ( 65 );
    GRM_MemberDetailLastOnlineTxt:SetJustifyH ( "CENTER" );
    
    -- PLAYER STATUS
    GRM_MemberDetailPlayerStatus:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 23 , - 52 );
    GRM_MemberDetailPlayerStatus:SetWidth ( 50 );
    GRM_MemberDetailPlayerStatus:SetJustifyH ( "CENTER" );
    GRM_MemberDetailPlayerStatus:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    -- ZONE
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetPoint ( "LEFT" , GRM_MemberDetailMetaData , 18 , 60 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetText ( GRM_Localize ( "Zone:" ) );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetPoint ( "LEFT" , GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText , "RIGHT" , 2 , 0 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetPoint ( "TOP" , GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText , "BOTTOM" , 10 , -2 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetText ( "Time In: " );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetPoint ( "LEFT" , GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1 , "RIGHT" , 2 , 0 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    
    -- Is Main Note!
    GRM_MemberDetailMainText:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -12 );
    GRM_MemberDetailMainText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );
    GRM_MemberDetailMainText:SetText ( "( Main )" );
    GRM_MemberDetailMainText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );

    GRM_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , GRM_MemberDetailRankTxt , "BOTTOM" , 0 , -4 );
    GRM_MemberDetailRankDateTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    
    -- Join Date Button Logic for visibility
    GRM_MemberDetailDateJoinedTitleTxt:SetPoint ( "TOPRIGHT" , GRM_MemberDetailMetaData , -14 , -22 );
    GRM_MemberDetailDateJoinedTitleTxt:SetText ( "Date Joined" );
    GRM_MemberDetailDateJoinedTitleTxt:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 , "THICKOUTLINE" );
    GRM_MemberDetailJoinDateButton:SetPoint ( "TOPRIGHT" , GRM_MemberDetailMetaData , -19 , - 32 );
    GRM_MemberDetailJoinDateButton:SetSize ( 60 , 17 );
    GRM_MemberDetailJoinDateButtonText:SetPoint ( "CENTER" , GRM_MemberDetailJoinDateButton );
    GRM_MemberDetailJoinDateButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_MemberDetailJoinDateButtonText:SetText ( "Join Date?" )
    GRM_MemberDetailJoinDateButton:SetScript ( "OnClick" , function ( self , button , down )
        if button == "LeftButton" then
            GRM_MemberDetailJoinDateButton:Hide();
            if GRM_MemberDetailRankDateTxt:IsVisible() then
                GRM_MemberDetailRankDateTxt:Hide();
            elseif GRM_SetPromoDateButton:IsVisible() then
                GRM_SetPromoDateButton:Hide();
            end
            GRM.SetDateSelectFrame ( "TOP" , GRM_MemberDetailMetaData , "JoinDate" );  -- Position, Frame, ButtonName
            GRM_AddonGlobals.pause = true;
        end
    end);

    -- GROUP INVITE BUTTON
    GRM_GroupInviteButton:SetPoint ( "BOTTOMLEFT" , GRM_MemberDetailMetaData , 16, 13 )
    GRM_GroupInviteButton:SetSize ( 88 , 19 );
    GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetPoint ( "CENTER" , GRM_GroupInviteButton );
    GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
        
    -- REMOVE GUILDIE BUTTON
    -- Overlay Button that will disappear on Click...
    -- GRM_RemoveGuildieButton:SetPoint ( "BOTTOMRIGHT" , GRM_MemberDetailMetaData , -15, 13 );
    -- GRM_RemoveGuildieButton:SetSize ( 88 , 19 );
    -- GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetPoint ( "CENTER" , GRM_RemoveGuildieButton , 2 , 0 );
    -- GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetText ( "Remove" );
    -- GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );

    -- GRM_RemoveGuildieButton:SetScript ( "OnClick" , function ( self , button )
    --     if button == "LeftButton" then
    --         -- GuildMemberDetailFrame:Show();
    --         GRM_MemberDetailMetaData:Hide();
    --         if GRM_AddonGlobals.firstTimeWarning then
    --             print ( "Due to Blizzard Addon protections, You Must Now Manually Remove Player" );
    --             GRM_AddonGlobals.firstTimeWarning = false;
    --         end
    --     end
    -- end);

    GuildMemberDetailFrame:HookScript ( "OnShow" , function()
        GRM_AddonGlobals.pause = true;
        GRM_MemberDetailMetaData:Hide(); 
    end);

    GuildMemberDetailFrame:HookScript ( "OnUpdate" , function ( self , elapsed ) 
        GRM_AddonGlobals.timer4 = GRM_AddonGlobals.timer4 + elapsed;
        if GRM_AddonGlobals.timer4 >= 0.4 then
            GRM_AddonGlobals.pause = true;
            GRM_AddonGlobals.currentName = GuildMemberDetailName:GetText();
            -- if GRM_AddonGlobals.addonPlayerName ~= GRM_AddonGlobals.currentName and CanGuildRemove() then
            --     GRM_PopupWindow:Show();
            -- else
            --     GRM_PopupWindow:Hide();
            -- end
            GRM_AddonGlobals.timer4 = 0;
        end 
    end);

    GuildMemberDetailFrame:HookScript ( "OnHide" , function()
        GRM_PopupWindow:Hide();
        GRM.RemoveRosterButtonHighlights();
        GRM_AddonGlobals.pause = false;
    end);

    GuildMemberRankDropdownButton:HookScript ( "OnClick" , function()
        GRM_AddonGlobals.currentName = GuildMemberDetailName:GetText();
    end)

    GuildMemberRemoveButton:HookScript ( "OnClick" , function()
        GRM_PopupWindow:Show();
    end);

    -- player note edit box and font string (31 characters)
    GRM_MemberDetailNoteTitle:SetPoint ( "BOTTOMLEFT" , GRM_PlayerNoteWindow , "TOPLEFT" , 5 , 0 );
    GRM_MemberDetailNoteTitle:SetText ( GRM_Localize ( "Note:" ) );
    GRM_MemberDetailNoteTitle:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );

    GRM_MemberDetailONoteTitle:SetPoint ( "BOTTOMLEFT" , GRM_PlayerOfficerNoteWindow , "TOPLEFT" , 5 , 0 );
    GRM_MemberDetailONoteTitle:SetText ( GRM_Localize ( "Officer's Note:" ) );
    GRM_MemberDetailONoteTitle:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );

    -- OFFICER AND PLAYER NOTES
    GRM_PlayerNoteWindow:SetPoint( "LEFT" , GRM_MemberDetailMetaData , 15 , 10 );
    GRM_noteFontString1:SetPoint ( "TOPLEFT" , GRM_PlayerNoteWindow , 9 , -11 );
    GRM_noteFontString1:SetWordWrap ( true );
    GRM_noteFontString1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_noteFontString1:SetSpacing ( 1 );
    GRM_noteFontString1:SetWidth ( 108 );
    GRM_noteFontString1:SetJustifyH ( "LEFT" );

    GRM_PlayerNoteWindow:SetBackdrop ( noteBackdrop );
    GRM_PlayerNoteWindow:SetSize ( 125 , 40 );
    
    GRM_PlayerNoteEditBox:SetPoint( "LEFT" , GRM_MemberDetailMetaData , 15 , 10 );
    GRM_PlayerNoteEditBox:SetSize ( 125 , 45 );
    GRM_PlayerNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_PlayerNoteEditBox:SetMaxLetters ( 31 );
    GRM_PlayerNoteEditBox:SetMultiLine( true );
    GRM_PlayerNoteEditBox:SetSpacing ( 1 );
    GRM_PlayerNoteEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_PlayerNoteEditBox:EnableMouse( true );
    GRM_PlayerNoteEditBox:SetFrameStrata ( "HIGH" );
    GRM_NoteCount:SetPoint ("TOPRIGHT" , GRM_PlayerNoteWindow , -6 , 8 );
    GRM_NoteCount:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );

    -- Officer Note
    GRM_PlayerOfficerNoteWindow:SetPoint( "RIGHT" , GRM_MemberDetailMetaData , -15 , 10 );
    GRM_noteFontString2:SetPoint ( "TOPLEFT" , GRM_PlayerOfficerNoteWindow , 9 , -11 );
    GRM_noteFontString2:SetWordWrap ( true );
    GRM_noteFontString2:SetSpacing ( 1 );
    GRM_noteFontString2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_noteFontString2:SetWidth ( 108 );
    GRM_noteFontString2:SetJustifyH ( "LEFT" );

    GRM_PlayerOfficerNoteWindow:SetBackdrop ( noteBackdrop );
    GRM_PlayerOfficerNoteWindow:SetSize ( 125 , 40 );
    
    GRM_PlayerOfficerNoteEditBox:SetPoint( "RIGHT" , GRM_MemberDetailMetaData , -15 , 10 );
    GRM_PlayerOfficerNoteEditBox:SetSize ( 125 , 45 );
    GRM_PlayerOfficerNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_PlayerOfficerNoteEditBox:SetMaxLetters ( 31 );
    GRM_PlayerOfficerNoteEditBox:SetMultiLine( true );
    GRM_PlayerOfficerNoteEditBox:SetSpacing ( 1 );
    GRM_PlayerOfficerNoteEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_PlayerOfficerNoteEditBox:EnableMouse( true );
    GRM_PlayerOfficerNoteEditBox:SetFrameStrata ( "HIGH" );
    
    -- Script handlers on Note Edit Boxes
    local defNotes = {};
    defNotes.defaultNote = "Click here to set a Public Note";
    defNotes.defaultONote = "Click here to set an Officer's Note";
    defNotes.tempNote = "";
    defNotes.finalNote = "";

    -- Script handlers on Note Frames
    GRM_PlayerNoteWindow:SetScript ( "OnMouseDown" , function ( self , button ) 
        if button == "LeftButton" and CanEditPublicNote() then 
            GRM_NoteCount:SetPoint ("TOPRIGHT" , GRM_PlayerNoteWindow , -6 , 8 );
            GRM_AddonGlobals.pause = true;
            GRM_noteFontString1:Hide();
            GRM_PlayerOfficerNoteEditBox:Hide();
            GRM_NoteCount:Hide();
            defNotes.tempNote = GRM_noteFontString2:GetText();
            if defNotes.tempNote ~= defNotes.defaultONote and defNotes.tempNote ~= "" then
                defNotes.finalNote = defNotes.tempNote;
            else
                defNotes.finalNote = "";
            end
            GRM_PlayerOfficerNoteEditBox:SetText( defNotes.finalNote );
            GRM_noteFontString2:Show();

            GRM_NoteCount:SetText( #GRM_PlayerNoteEditBox:GetText() .. "/31");
            GRM_PlayerNoteEditBox:Show();
            GRM_NoteCount:Show();
        end 
    end);

    GRM_PlayerOfficerNoteWindow:SetScript ( "OnMouseDown" , function ( self , button ) 
        if button == "LeftButton" and CanEditOfficerNote() then
            GRM_NoteCount:SetPoint ("TOPRIGHT" , GRM_PlayerOfficerNoteWindow , -6 , 8 );
            GRM_AddonGlobals.pause = true;
            GRM_noteFontString2:Hide();
            GRM_PlayerNoteEditBox:Hide();
            defNotes.tempNote = GRM_noteFontString1:GetText();
            if defNotes.tempNote ~= defNotes.defaultNote and defNotes.tempNote ~= "" then
                defNotes.finalNote = defNotes.tempNote;
            else
                defNotes.finalNote = "";
            end
            GRM_PlayerNoteEditBox:SetText( defNotes.finalNote );
            GRM_noteFontString1:Show();

             -- How many characters initially
            GRM_NoteCount:SetText( #GRM_PlayerOfficerNoteEditBox:GetText() .. "/31" );
            GRM_PlayerOfficerNoteEditBox:Show();
            GRM_NoteCount:Show();
        end 
    end);

    -- Cancels editing in Note editbox
    GRM_PlayerNoteEditBox:SetScript ( "OnEscapePressed" , function ( self ) 
        GRM_PlayerNoteEditBox:Hide();
        GRM_NoteCount:Hide();
        defNotes.tempNote = GRM_noteFontString1:GetText();
        if defNotes.tempNote ~= defNotes.defaultNote and defNotes.tempNote ~= "" then
            defNotes.finalNote = defNotes.tempNote;
        else
            defNotes.finalNote = "";
        end
        GRM_PlayerNoteEditBox:SetText ( defNotes.finalNote );
        GRM_noteFontString1:Show();
        if GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end);

    -- Updates char count as player types.
    GRM_PlayerNoteEditBox:SetScript ( "OnChar" , function ( self , text ) 
        local charCount = #GRM_PlayerNoteEditBox:GetText();
        charCount = charCount;
        GRM_NoteCount:SetText ( charCount .. "/31" );
    end);

    -- Update on backspace changes too
    GRM_PlayerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
        if text == "BACKSPACE" then
            local charCount = #GRM_PlayerNoteEditBox:GetText();
            charCount = charCount - 1;
            if charCount == -1 then
                charCount = 0;
            end
            GRM_NoteCount:SetText ( charCount .. "/31");
        end
    end);

    -- Updating the new information to Public Note
    GRM_PlayerNoteEditBox:SetScript ( "OnEnterPressed" , function ( self ) 
        local playerDetails = {};
        playerDetails.newNote = GRM_PlayerNoteEditBox:GetText();
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
                        local logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( playerDetails.name ) .. "'s PUBLIC Note has Changed\nFrom:  " .. publicNote .. "\nTo:       " .. playerDetails.newNote );
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
                            GRM.PrintLog ( 4 , logReport , false );
                        end
                        -- Also adding it to the log!
                        GRM.AddLog ( 4 , logReport );

                        if #playerDetails.newNote == 0 then
                            GRM_noteFontString1:SetText ( defNotes.defaultNote );
                        else
                            GRM_noteFontString1:SetText ( playerDetails.newNote );
                        end
                        GRM_PlayerNoteEditBox:SetText( playerDetails.newNote );

                        -- and if the event log window is open, might as well build it!
                        GRM.BuildLog();
                        break;
                    end
                end
                break;
            end
        end

        GRM_PlayerNoteEditBox:Hide();
        GRM_NoteCount:Hide();
        GRM_noteFontString1:Show();
        if GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end);

    GRM_PlayerOfficerNoteEditBox:SetScript ( "OnEscapePressed" , function ( self ) 
        GRM_PlayerOfficerNoteEditBox:Hide();
        GRM_NoteCount:Hide();
        defNotes.tempNote = GRM_noteFontString2:GetText();
        if defNotes.tempNote ~= defNotes.defaultONote and defNotes.tempNote ~= "" then
            defNotes.finalNote = defNotes.tempNote;
        else
            defNotes.finalNote = "";
        end
        GRM_PlayerOfficerNoteEditBox:SetText( defNotes.finalNote );
        GRM_noteFontString2:Show();
        if GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end);

    -- Updates char count as player types.
    GRM_PlayerOfficerNoteEditBox:SetScript ( "OnChar" , function ( self , text ) 
        local charCount = #GRM_PlayerOfficerNoteEditBox:GetText();
        charCount = charCount;
        GRM_NoteCount:SetText( charCount .. "/31" );
    end);

    -- Update on backspace changes too
    GRM_PlayerOfficerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
        if text == "BACKSPACE" then
            local charCount = #GRM_PlayerOfficerNoteEditBox:GetText();
            charCount = charCount - 1;
            if charCount == -1 then
                charCount = 0;
            end
            GRM_NoteCount:SetText( charCount .. "/31" );
        end
    end);

     -- Updating the new information to Public Note
    GRM_PlayerOfficerNoteEditBox:SetScript ( "OnEnterPressed" , function ( self ) 
        local playerDetails = {};
        playerDetails.newNote = GRM_PlayerOfficerNoteEditBox:GetText();
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
                        local logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( playerDetails.name ) .. "'s OFFICER Note has Changed\nFrom:  " .. officerNote .. "\nTo:       " .. playerDetails.newNote );
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
                            GRM.PrintLog ( 5 , logReport , false );
                        end
                        -- Also adding it to the log!
                        GRM.AddLog ( 5 , logReport );
                        
                        if #playerDetails.newNote == 0 then
                            GRM_noteFontString2:SetText ( defNotes.defaultONote );
                        else
                            GRM_noteFontString2:SetText ( playerDetails.newNote );
                        end
                        GRM_PlayerOfficerNoteEditBox:SetText( playerDetails.newNote );

                        -- and if the event log window is open, might as well build it!
                        GRM.BuildLog();
                        break;
                    end
                end
                break;
            end
        end

        GRM_PlayerOfficerNoteEditBox:Hide();
        GRM_NoteCount:Hide();
        GRM_noteFontString2:Show();
        if GRM_DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GRM_AddonGlobals.pause = false;
        end
    end);

    -- GRM_UI.GRM_PlayerCustomNoteWindow:SetPoint( "LEFT" , GRM_MemberDetailMetaData , 15 , -70 );
    -- GRM_UI.GRM_PlayerCustomNoteWindow:SetBackdrop ( noteBackdrop );
    -- GRM_UI.GRM_PlayerCustomNoteWindow:SetSize ( 125 , 105 );

    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetPoint ( "TOPLEFT" , GRM_UI.GRM_PlayerCustomNoteWindow , 9 , -11 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetWordWrap ( true );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetSpacing ( 1 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetWidth ( 108 );
    -- GRM_UI.GRM_PlayerCustomNoteWindowFontString:SetJustifyH ( "LEFT" );
    
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetPoint( "LEFT" , GRM_MemberDetailMetaData , 15 , 10 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetSize ( 125 , 45 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetMaxLetters ( 31 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetMultiLine( true );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetSpacing ( 1 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:EnableMouse( true );
    -- GRM_UI.GRM_PlayerCustomNoteEditBox:SetFrameStrata ( "HIGH" );
    
end



-- Method:                  GR_MetaDataInitializeUISecond()
-- What it Does:            Initializes "More of the frames values/scripts"
-- Purpose:                 Can only have 60 "up-values" in one function. This splits it up.
GRM_UI.GR_MetaDataInitializeUISecond = function()

    -- CUSTOM 
    GRM_PopupWindow:SetPoint ( "TOPLEFT" , StaticPopup1 , "BOTTOMLEFT" , -3 , 1 );
    GRM_PopupWindow:SetSize ( 247 , 45 );
    GRM_PopupWindow:EnableMouse ( true );
    GRM_PopupWindow:EnableKeyboard ( true );
    GRM_PopupWindow:SetToplevel ( true );
    GRM_PopupWindow:SetFrameStrata ( "HIGH" );

    GRM_PopupWindowCheckButton1:SetPoint ( "TOPLEFT" , GRM_PopupWindow , 15 , -10 );
    GRM_PopupWindowCheckButtonText:SetPoint ( "RIGHT" , GRM_PopupWindowCheckButton1 , 65 , 0 );
    GRM_PopupWindowCheckButtonText:SetText ( "Ban Player?" );
    GRM_PopupWindowCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_PopupWindowCheckButtonText:SetTextColor ( 1 , 0 , 0 , 1 );

    GRM_PopupWindow:SetScript( "OnShow" , function() 
        GRM_PopupWindowCheckButton1:SetChecked ( false );
        GRM_MemberDetailEditBoxFrame:Hide();
        GRM_AddonGlobals.isChecked = false;
        GRM_AddonGlobals.pause = true;
    end);

    StaticPopup1:HookScript ( "OnHide" , function()
        if GRM_PopupWindow:IsVisible() then
            GRM_PopupWindow:Hide();
        end
    end);

    -- Popup EDIT BOX
    GRM_MemberDetailEditBoxFrame:SetPoint ( "TOP" , GRM_PopupWindow , "BOTTOM" , 0 , 3 );
    GRM_MemberDetailEditBoxFrame:SetSize ( 247 , 73 );

    GRM_MemberDetailPopupEditBox:SetPoint( "CENTER" , GRM_MemberDetailEditBoxFrame );
    GRM_MemberDetailPopupEditBox:SetSize ( 224 , 63  );
    GRM_MemberDetailPopupEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_MemberDetailPopupEditBox:SetMaxLetters ( 155 );
    GRM_MemberDetailPopupEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    GRM_MemberDetailPopupEditBox:SetTextColor ( 1 , 1 , 1 , 1 );
    GRM_MemberDetailPopupEditBox:SetFrameStrata ( "HIGH" );
    GRM_MemberDetailPopupEditBox:EnableMouse( true );
    GRM_MemberDetailPopupEditBox:SetMultiLine( true );
    GRM_MemberDetailPopupEditBox:SetSpacing ( 1 );

    -- Script handler for General popup editbox.
    GRM_MemberDetailPopupEditBox:SetScript ( "OnEscapePressed" , function ( self )
        GRM_MemberDetailEditBoxFrame:Hide();
        GRM_PopupWindowCheckButton1:Click();
    end);

    GRM_PopupWindowCheckButton1:SetScript ( "OnHide" , function ()
        C_Timer.After ( 1 , function()
            GRM_AddonGlobals.isChecked = false;
        end);
    end);

    GRM_PopupWindowCheckButton1:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if GRM_PopupWindowCheckButton1:GetChecked() ~= true then
                GRM_MemberDetailEditBoxFrame:Hide();
                GRM_AddonGlobals.isChecked = false;
                
            else
                GRM_AddonGlobals.isChecked = true;
                GRM_MemberDetailPopupEditBox:SetText ( "Reason Banned?\nClick \"Yes\" When Done" );
                GRM_MemberDetailPopupEditBox:HighlightText ( 0 );
                GRM_MemberDetailEditBoxFrame:Show();
                GRM_MemberDetailPopupEditBox:Show();
            end
        end
    end);

    GRM_MemberDetailPopupEditBox:SetScript ( "OnEnterPressed" , function ( _ )
        -- If kick alts button is checked...
        print ( "Please Click \"Yes\" to Ban the Player!" );
    end);

    -- Heads-up text if player was previously banned
    GRM_MemberDetailBannedText1:SetPoint ( "BOTTOMLEFT" , GRM_MemberDetailMetaData , "TOPLEFT" , 13 , -2 );
    GRM_MemberDetailBannedText1:SetWordWrap ( true );
    GRM_MemberDetailBannedText1:SetJustifyH ( "LEFT" );
    GRM_MemberDetailBannedText1:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GRM_MemberDetailBannedText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8.0 );
    GRM_MemberDetailBannedText1:SetWidth ( 300 );
    GRM_MemberDetailBannedText1:SetText ( "WARNING! WARNING!\nPlayer Was Previously Banned!" );
    GRM_MemberDetailBannedIgnoreButton:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 11 , -5 );
    GRM_MemberDetailBannedIgnoreButton:SetWidth ( 85 );
    GRM_MemberDetailBannedIgnoreButton:SetHeight ( 15 );
    GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetPoint ( "CENTER" , GRM_MemberDetailBannedIgnoreButton );
    GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8.5 );
    GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetText ( "Ignore Ban" );
    
    
    -- ALT FRAME DETAILS!!!
    GRM_CoreAltFrame:SetPoint ( "BOTTOMRIGHT" , GRM_MemberDetailMetaData , -13.5 , 16 );
    GRM_CoreAltFrame:SetSize ( 128 , 140 );
    GRM_CoreAltFrame:SetParent ( GRM_MemberDetailMetaData );
       -- ALT FRAME SCROLL OPTIONS
    GRM_CoreAltScrollFrame:SetSize ( 128 , 105 );
    GRM_CoreAltScrollFrame:SetPoint ( "BOTTOMRIGHT" , GRM_MemberDetailMetaData , -13.5 , 33 );
    GRM_CoreAltScrollFrame:SetScrollChild ( GRM_CoreAltScrollChildFrame );
    -- Slider Parameters
    GRM_CoreAltScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_CoreAltScrollFrameSlider:SetSize( 12 , 86 );
    GRM_CoreAltScrollFrameSlider:SetPoint( "TOPLEFT" , GRM_CoreAltScrollFrame , "TOPRIGHT" , -10 , -10 );
    GRM_CoreAltScrollFrameSlider:SetValue( 0 );
    GRM_CoreAltScrollFrameSliderScrollUpButton:SetSize ( 12 , 10 );
    GRM_CoreAltScrollFrameSliderScrollDownButton:SetSize ( 12 , 10 );
    GRM_CoreAltScrollFrameSliderThumbTexture:SetSize ( 12 , 14 );
    GRM_CoreAltScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_CoreAltScrollFrame:SetVerticalScroll( self:GetValue() )
    end);

    GRM_altFrameTitleText:SetPoint ( "TOP" , GRM_CoreAltFrame , 3 , -4 );
    GRM_altFrameTitleText:SetText ( "Player Alts" );    
    GRM_altFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 , "THICKOUTLINE" );

    GRM_AddAltButton:SetSize ( 60 , 17 );
    GRM_AddAltButtonText:SetPoint ( "CENTER" , GRM_AddAltButton );
    GRM_AddAltButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltButtonText:SetText( "Add Alt") ; 

    GRM_AddAltButton2:SetSize ( 60 , 17 );
    GRM_AddAltButton2Text:SetPoint ( "CENTER" , GRM_AddAltButton2 );
    GRM_AddAltButton2Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltButton2Text:SetText( "Add Alt") ; 

    GRM_AltName1:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -20 );
    GRM_AltName1:SetWidth ( 60 );
    GRM_AltName1:SetJustifyH ( "CENTER" );
    GRM_AltName1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName2:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -20 );
    GRM_AltName2:SetWidth ( 60 );
    GRM_AltName2:SetJustifyH ( "CENTER" );
    GRM_AltName2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName3:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -37 );
    GRM_AltName3:SetWidth ( 60 );
    GRM_AltName3:SetJustifyH ( "CENTER" );
    GRM_AltName3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName4:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -37 );
    GRM_AltName4:SetWidth ( 60 );
    GRM_AltName4:SetJustifyH ( "CENTER" );
    GRM_AltName4:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName5:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -54 );
    GRM_AltName5:SetWidth ( 60 );
    GRM_AltName5:SetJustifyH ( "CENTER" );
    GRM_AltName5:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName6:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -54 );
    GRM_AltName6:SetWidth ( 60 );
    GRM_AltName6:SetJustifyH ( "CENTER" );
    GRM_AltName6:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName7:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -71 );
    GRM_AltName7:SetWidth ( 60 );
    GRM_AltName7:SetJustifyH ( "CENTER" );
    GRM_AltName7:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName8:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -71 );
    GRM_AltName8:SetWidth ( 60 );
    GRM_AltName8:SetJustifyH ( "CENTER" );
    GRM_AltName8:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName9:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -88 );
    GRM_AltName9:SetWidth ( 60 );
    GRM_AltName9:SetJustifyH ( "CENTER" );
    GRM_AltName9:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName10:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -88 );
    GRM_AltName10:SetWidth ( 60 );
    GRM_AltName10:SetJustifyH ( "CENTER" );
    GRM_AltName10:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName11:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -105 );
    GRM_AltName11:SetWidth ( 60 );
    GRM_AltName11:SetJustifyH ( "CENTER" );
    GRM_AltName11:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    GRM_AltName12:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -105 );
    GRM_AltName12:SetWidth ( 60 );
    GRM_AltName12:SetJustifyH ( "CENTER" );
    GRM_AltName12:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );

    -- ALT DROPDOWN OPTIONS
    GRM_altDropDownOptions:SetPoint ( "BOTTOMRIGHT" , GRM_MemberDetailMetaData , 15 , 0 );
    GRM_altDropDownOptions:SetBackdrop ( noteBackdrop2 );
    GRM_altDropDownOptions:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_altOptionsText:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -13 );
    GRM_altOptionsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_altOptionsText:SetText ( "Options" );
    GRM_altSetMainButton:SetPoint ("TOPLEFT" , GRM_altDropDownOptions , 7 , -22 );
    GRM_altSetMainButton:SetSize ( 60 , 20 );
    GRM_altSetMainButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_altSetMainButtonText:SetPoint ( "LEFT" , GRM_altSetMainButton );
    GRM_altSetMainButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_altRemoveButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -36 );
    GRM_altRemoveButton:SetSize ( 60 , 20 );
    GRM_altRemoveButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_altRemoveButtonText:SetPoint ( "LEFT" , GRM_altRemoveButton );
    GRM_altRemoveButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_altRemoveButtonText:SetText( "Remove" );
    GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -55 );
    GRM_altOptionsDividerText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_altOptionsDividerText:SetText ("__");
    GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -65 );
    GRM_altFrameCancelButton:SetSize ( 60 , 20 );
    GRM_altFrameCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_altFrameCancelButtonText:SetPoint ( "LEFT" , GRM_altFrameCancelButton );
    GRM_altFrameCancelButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_altFrameCancelButtonText:SetText ( "Cancel" );

end

-- Method:                  GR_MetaDataInitializeUIThird()
-- What it Does:            Initializes "More of the frames values/scripts"
-- Purpose:                 Can only have 60 "up-values" in one function. This splits it up.
GRM_UI.GR_MetaDataInitializeUIThird = function()

    --ADD ALT FRAME
    GRM_AddAltEditFrame:SetPoint ( "BOTTOMLEFT" , GRM_MemberDetailMetaData , "BOTTOMRIGHT" ,  -7 , 0 );
    GRM_AddAltEditFrame:SetSize ( 130 + ( #GRM_AddonGlobals.realmName * 3.5 ) , 170 );                -- Slightly wider for larger guild names.
    GRM_AddAltEditFrame:SetToplevel ( true );
    GRM_AddAltTitleText:SetPoint ( "TOP" , GRM_AddAltEditFrame , 0 , - 20 );
    GRM_AddAltTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 , "THICKOUTLINE" );
    GRM_AddAltTitleText:SetText ( "Choose Alt" );
    GRM_AddAltNameButton1:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -54 );
    GRM_AddAltNameButton1:SetSize ( 100 , 15 );
    GRM_AddAltNameButton1:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton1:Disable();
    GRM_AddAltNameButton1Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltNameButton1Text:SetPoint ( "LEFT" , GRM_AddAltNameButton1 );
    GRM_AddAltNameButton1Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton2:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -69 );
    GRM_AddAltNameButton2:SetSize ( 100 , 15 );
    GRM_AddAltNameButton2:Disable();
    GRM_AddAltNameButton2:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton2Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltNameButton2Text:SetPoint ( "LEFT" , GRM_AddAltNameButton2 );
    GRM_AddAltNameButton2Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton3:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -84 );
    GRM_AddAltNameButton3:SetSize ( 100 , 15 );
    GRM_AddAltNameButton3:Disable();
    GRM_AddAltNameButton3:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton3Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltNameButton3Text:SetPoint ( "LEFT" , GRM_AddAltNameButton3 );
    GRM_AddAltNameButton3Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton4:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -99 );
    GRM_AddAltNameButton4:SetSize ( 100 , 15 );
    GRM_AddAltNameButton4:Disable();
    GRM_AddAltNameButton4:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton4Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltNameButton4Text:SetPoint ( "LEFT" , GRM_AddAltNameButton4 );
    GRM_AddAltNameButton4Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton5:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -114 );
    GRM_AddAltNameButton5:SetSize ( 100 , 15 );
    GRM_AddAltNameButton5:Disable();
    GRM_AddAltNameButton5:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton5Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltNameButton5Text:SetPoint ( "LEFT" , GRM_AddAltNameButton5 );
    GRM_AddAltNameButton5Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton6:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -129 );
    GRM_AddAltNameButton6:SetSize ( 100 , 15 );
    GRM_AddAltNameButton6:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton6:Disable();
    GRM_AddAltNameButton6Text:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltNameButton6Text:SetPoint ( "LEFT" , GRM_AddAltNameButton6 );
    GRM_AddAltNameButton6Text:SetJustifyH ( "LEFT" );
    GRM_AddAltEditFrameTextBottom:SetPoint ( "TOP" , GRM_AddAltEditFrame , -18 , -146 );
    GRM_AddAltEditFrameTextBottom:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltEditFrameTextBottom:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    GRM_AddAltEditFrameTextBottom:SetText ( "(Press Tab)" );
    GRM_AddAltEditFrameHelpText:SetPoint ( "CENTER" , GRM_AddAltEditFrame );
    GRM_AddAltEditFrameHelpText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltEditFrameHelpText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_AddAltEditFrameHelpText2:SetPoint ( "BOTTOM" , GRM_AddAltEditFrame , 0 , 30 );
    GRM_AddAltEditFrameHelpText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltEditFrameHelpText2:SetText ( "Shift-Mouseover Name\nOn Roster Also Works");
        
    GRM_AddAltEditBox:SetPoint( "TOP" , GRM_AddAltEditFrame , 2.5 , -30 );
    GRM_AddAltEditBox:SetSize ( 95 + ( #GRM_AddonGlobals.realmName * 3.5 ) , 25 );
    GRM_AddAltEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_AddAltEditBox:SetMaxLetters ( 40 );
    GRM_AddAltEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddAltEditBox:EnableMouse( true );
    GRM_AddAltEditBox:SetAutoFocus( false );

    -- ALT EDIT BOX LOGIC
    GRM_AddAltButton:SetScript ( "OnClick" , function ( _ , button) 
        if button == "LeftButton" then

            -- Let's see if player is at hard cap first!
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
                if GRM_AddonGlobals.currentName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] >= 75 then
                        print ( "GRM addon does not support more than 75 alts! Hey, there has to be some cap put in place!" );
                    else
                        GRM_AddonGlobals.pause = true;
                        GRM_AddAltEditBox:SetAutoFocus( true );
                        GRM_AddAltEditBox:SetText( "" );
                        GRM.AddAltAutoComplete();
                        GRM_AddAltEditFrame:Show();
                        GRM_AddAltEditBox:SetAutoFocus( false );
                    end
                    break;
                end
            end           
        end
    end)

    -- ALT EDIT BOX LOGIC
    GRM_AddAltButton2:SetScript ( "OnClick" , function ( _ , button) 
        if button == "LeftButton" then

            -- Let's see if player is at hard cap first!
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
                if GRM_AddonGlobals.currentName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] >= 75 then
                        print ( "GRM addon does not support more than 75 alts! Hey, there has to be some cap put in place!" );
                    else
                        GRM_AddonGlobals.pause = true;
                        GRM_AddAltEditBox:SetAutoFocus( true );
                        GRM_AddAltEditBox:SetText( "" );
                        GRM.AddAltAutoComplete();
                        GRM_AddAltEditFrame:Show();
                        GRM_AddAltEditBox:SetAutoFocus( false );
                    end
                    break;
                end
            end           
        end
    end)


    GRM_AddAltEditBox:SetScript ( "OnEscapePressed" , function( _ )
        GRM_AddAltEditBox:ClearFocus();    
    end);

    GRM_AddAltEditBox:SetScript ( "OnEnterPressed" , function( _ )
        if GRM_AddAltEditBox:HasFocus() then
            local currentText = GRM_AddAltEditBox:GetText();
            if GRM_AddAltEditFrameHelpText:IsVisible() and ( GRM_AddAltEditFrameHelpText:GetText() == "Player Not Found" or GRM_AddAltEditFrameHelpText:GetText() == "Player Cannot Add\nThemselves as an Alt" ) then
                if GRM.SlimName ( GRM_AddonGlobals.currentName ) == GRM_AddAltEditBox:GetText() or GRM_AddonGlobals.currentName == GRM_AddAltEditBox:GetText() then
                    print ( "Player Cannot add themselves to be their own Alt!" );
                end
                print ("Please choose a VALID character, in guild, to set as an alt.");
            else
                if currentText ~= nil and currentText ~= "" then
                    local notFound = true;
                    if GRM_AddonGlobals.currentHighlightIndex == 1 and GRM_AddAltNameButton1Text:GetText() ~= currentText then
                        GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton1Text:GetText() );
                        notFound = false;
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 2 and GRM_AddAltNameButton2Text:GetText() ~= currentText then
                        GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton2Text:GetText() );
                        notFound = false;
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 3 and GRM_AddAltNameButton3Text:GetText() ~= currentText then
                        GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton3Text:GetText() );
                        notFound = false;
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 4 and GRM_AddAltNameButton4Text:GetText() ~= currentText then
                        GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton4Text:GetText() );
                        notFound = false;
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 5 and GRM_AddAltNameButton5Text:GetText() ~= currentText then
                        GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton5Text:GetText() );
                        notFound = false;
                    elseif notFound and GRM_AddonGlobals.currentHighlightIndex == 6 and GRM_AddAltNameButton6Text:GetText() ~= currentText then
                        GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton6Text:GetText() );
                        notFound = false;
                    end

                    if notFound then
                        -- Add the alt here, Hide the frame
                        GRM.AddAlt ( GRM_AddonGlobals.currentName , GRM_AddAltEditBox:GetText() , GRM_AddonGlobals.guildName , false , 0 );

                        -- Communicate the changes!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                            GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_ADDALT?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_AddonGlobals.currentName .. "?" .. GRM_AddAltEditBox:GetText() .. "?" .. tostring ( time() ) , "GUILD");
                        end

                        GRM_AddAltEditBox:ClearFocus();
                        GRM_AddAltEditFrame:Hide();
                    end
                else
                    print ( "Please choose a character to set as alt." );
                end
            end
        end
    end);

    GRM_AddAltNameButton1:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton1Text:GetText() );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_AddAltNameButton2:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton2Text:GetText() );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_AddAltNameButton3:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton3Text:GetText() );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_AddAltNameButton4:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton4Text:GetText() );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_AddAltNameButton5:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton5Text:GetText() );
            GRM.AddAltAutoComplete();
        end
    end);
    GRM_AddAltNameButton6:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_AddAltEditBox:SetText ( GRM_AddAltNameButton6Text:GetText() );
            GRM.AddAltAutoComplete();
        end
    end);

    -- Updating with each character typed
    GRM_AddAltEditBox:SetScript ( "OnChar" , function ( _ , text ) 
        GRM.AddAltAutoComplete();
    end);

    -- When pressing backspace.
    GRM_AddAltEditBox:SetScript ( "OnKeyDown" , function ( _ , key)
        if key == "BACKSPACE" then
            local text = GRM_AddAltEditBox:GetText();
            if text ~= nil and #text > 0 then
                GRM_AddAltEditBox:SetText ( string.sub ( text , 0 , #text - 1 ) ); -- Bring it down by 1 for function, then return to normal.
            end
            GRM.AddAltAutoComplete();
            GRM_AddAltEditBox:SetText( text ); -- set back to normal for normal Backspace upkey function... if I do not do this, it will delete 2 characters.
        end
    end);

    GRM_AddAltEditBox:SetScript ( "OnTabPressed" , function ( _ )
        local notSet = true;
        if IsShiftKeyDown() ~= true then
            if GRM_AddonGlobals.currentHighlightIndex == 1 and notSet then
                if GRM_AddAltNameButton2:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 2;
                    GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_AddAltNameButton2:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 2 and notSet then
                if GRM_AddAltNameButton3:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 3;
                    GRM_AddAltNameButton2:UnlockHighlight();
                    GRM_AddAltNameButton3:LockHighlight();
                    notSet = false;
                else
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_AddAltNameButton2:UnlockHighlight();
                    GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 3 and notSet then
                if GRM_AddAltNameButton4:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 4;
                    GRM_AddAltNameButton3:UnlockHighlight();
                    GRM_AddAltNameButton4:LockHighlight();
                    notSet = false;
                else
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_AddAltNameButton3:UnlockHighlight();
                    GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 4 and notSet then
                if  GRM_AddAltNameButton5:IsVisible() then
                    GRM_AddonGlobals.currentHighlightIndex = 5;
                    GRM_AddAltNameButton4:UnlockHighlight();
                    GRM_AddAltNameButton5:LockHighlight();
                    notSet = false;
                else
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_AddAltNameButton4:UnlockHighlight();
                    GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 5 and notSet then
                if GRM_AddAltNameButton6:IsVisible() and GRM_AddAltNameButton6Text:GetText() ~= "..." then
                    GRM_AddonGlobals.currentHighlightIndex = 6;
                    GRM_AddAltNameButton5:UnlockHighlight();
                    GRM_AddAltNameButton6:LockHighlight();
                    notSet = false;
                elseif ( GRM_AddAltNameButton6:IsVisible() and GRM_AddAltNameButton6Text:GetText() == "..." ) or GRM_AddAltNameButton6:IsVisible() ~= true then
                    GRM_AddonGlobals.currentHighlightIndex = 1;
                    GRM_AddAltNameButton5:UnlockHighlight();
                    GRM_AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 6 then
                GRM_AddonGlobals.currentHighlightIndex = 1;
                GRM_AddAltNameButton6:UnlockHighlight();
                GRM_AddAltNameButton1:LockHighlight();
                notSet = false;
            end
        else
            -- if at position 1... shift-tab goes back to any position.
            if GRM_AddonGlobals.currentHighlightIndex == 1 and notSet then
                if GRM_AddAltNameButton6:IsVisible() and GRM_AddAltNameButton6Text:GetText() ~= "..."  and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 6;
                    GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_AddAltNameButton6:LockHighlight();
                    notSet = false;
                elseif ( ( GRM_AddAltNameButton6:IsVisible() and GRM_AddAltNameButton6Text:GetText() == "..." ) or ( GRM_AddAltNameButton5:IsVisible() ) ) and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 5;
                    GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_AddAltNameButton5:LockHighlight();
                    notSet = false;
                elseif GRM_AddAltNameButton4:IsVisible() and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 4;
                    GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_AddAltNameButton4:LockHighlight();
                    notSet = false;
                elseif GRM_AddAltNameButton3:IsVisible() and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 3;
                    GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_AddAltNameButton3:LockHighlight();
                    notSet = false;
                elseif GRM_AddAltNameButton2:IsVisible() and notSet then
                    GRM_AddonGlobals.currentHighlightIndex = 2;
                    GRM_AddAltNameButton1:UnlockHighlight();
                    GRM_AddAltNameButton2:LockHighlight();
                    notSet = false;
                end
            elseif GRM_AddonGlobals.currentHighlightIndex == 2 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 1;
                GRM_AddAltNameButton2:UnlockHighlight();
                GRM_AddAltNameButton1:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 3 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 2;
                GRM_AddAltNameButton3:UnlockHighlight();
                GRM_AddAltNameButton2:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 4 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 3;
                GRM_AddAltNameButton4:UnlockHighlight();
                GRM_AddAltNameButton3:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 5 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 4;
                GRM_AddAltNameButton5:UnlockHighlight();
                GRM_AddAltNameButton4:LockHighlight();
                notSet = false;
            elseif GRM_AddonGlobals.currentHighlightIndex == 6 and notSet then
                GRM_AddonGlobals.currentHighlightIndex = 5;
                GRM_AddAltNameButton6:UnlockHighlight();
                GRM_AddAltNameButton5:LockHighlight();
                notSet = false;
            end
        end
    end);
    
    GRM_AddAltEditFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_AddAltEditFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_AddAltEditFrame:SetPropagateKeyboardInput ( false );
            GRM_AddAltEditFrame:Hide();
        end
    end);

    -- ALT FRAME LOGIC
    GRM_altSetMainButton:SetScript ( "OnClick" , function ( _ , button )
        
        if button == "LeftButton" then
            local altDetails = GRM_AddonGlobals.selectedAlt;
            local buttonName = GRM_altSetMainButtonText:GetText();
            if buttonName == "Set as Main" then
                if altDetails[1] ~= altDetails[2] then
                    GRM.SetMain ( altDetails[1] , altDetails[2] , altDetails[3] , false , 0 );
                    -- Now send Comm to sync details.
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                        GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_MAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                    end
                else
                    -- No need to set as main yet... let's set player to main here.
                      for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altDetails[1] then
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                                GRM.SetMain ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , altDetails[1] , altDetails[3] , false , 0 );
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
                            
                            GRM_MemberDetailMainText:Show();
                            break;
                        end
                    end
                end
                if GRM_MemberDetailMainText:IsVisible() and GRM_AddonGlobals.currentName ~= altDetails[2] then
                    GRM_MemberDetailMainText:Hide();
                end

                

                GRM.Report ( GRM.SlimName ( altDetails[2] ) .. " is now set as \"main\"" );
            elseif buttonName == "Set as Alt" then
                if altDetails[1] ~= altDetails[2] then
                    GRM.DemoteFromMain ( altDetails[1] , altDetails[2] , altDetails[3] , false , 0 );
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                        GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVMAIN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                    end
                else
                    -- No need to set as main yet... let's set player to main here.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altDetails[1] then
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                                GRM.DemoteFromMain ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , altDetails[1] , altDetails[3] , false , 0 );
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
                            GRM_MemberDetailMainText:Hide();
                            break;
                        end
                    end
                end
                GRM.Report ( GRM.SlimName ( altDetails[2] ) .. " is no longer set as \"main\"" );
            elseif buttonName == "Edit Date" then
                GRM_MemberDetailRankDateTxt:Hide();
                if GRM_AddonGlobals.editPromoDate then
                    GRM_SetPromoDateButton:Click();
                    GRM_DateSubmitButtonTxt:SetText ( "Edit Promo Date" );
                elseif GRM_AddonGlobals.editJoinDate then
                    GRM_JoinDateText:Hide();
                    GRM_MemberDetailJoinDateButton:Click();
                    GRM_DateSubmitButtonTxt:SetText ( "Edit Join Date" );
                end

            elseif buttonName == "Notify When Player is Active" then
                GRM.AddPlayerActiveCheck ( altDetails[1] );
                GRM_AddonGlobals.pause = false;
            elseif buttonName == "Notify When Player Comes Online" then
                GRM.AddPlayerOnlineStatusCheck ( altDetails[1] );
                GRM_AddonGlobals.pause = false;
            elseif buttonName == "Notify When Player Goes Offline" then
                GRM.AddPlayerOfflineStatusCheck ( altDetails[1] );
                GRM_AddonGlobals.pause = false;
            end
            GRM_altDropDownOptions:Hide();
        end
    end);

    -- Also functions to clear history...
    GRM_altRemoveButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local buttonName = GRM_altRemoveButtonText:GetText();
            local altDetails = GRM_AddonGlobals.selectedAlt;
            if buttonName == "Remove" then
                GRM.RemoveAlt ( altDetails[1] , altDetails[2] , altDetails[3] , false , 0 );
                -- Send comm out of the changes!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVALT?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] .. "?" .. tostring ( time() ) , "GUILD");
                end
            elseif buttonName == "Clear History" then
                if GRM_AddonGlobals.editPromoDate then
                    GRM.ClearPromoDateHistory ( altDetails[1] );
                elseif GRM_AddonGlobals.editJoinDate then
                    GRM.ClearJoinDateHistory ( altDetails[1] );
                end
            elseif buttonName == "Reset Data!" then
                GRM_RosterConfirmFrameText:SetText( "Reset All of " .. altDetails[1] .. "'s Data?" );
                GRM_RosterConfirmYesButtonText:SetText ( "Yes!" );
                GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( self , button )
                    if button == "LeftButton" then
                        GRM.ResetPlayerMetaData ( altDetails[1] , altDetails[3] );
                        GRM_RosterConfirmFrame:Hide();
                    end
                end);
                GRM_RosterConfirmFrame:Show();
            elseif buttonName == "Notify When Player Goes Offline" then
                GRM.AddPlayerOfflineStatusCheck ( altDetails[1] );
            end
            GRM_altDropDownOptions:Hide();
        end
    end);

    GRM_altFrameCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_altDropDownOptions:Hide();
            GRM_AddonGlobals.pause = false;
        end
    end);

    GRM_altDropDownOptions:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_altDropDownOptions:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_altDropDownOptions:SetPropagateKeyboardInput ( false );
            GRM_altDropDownOptions:Hide();
        end
    end);

    -- CALENDAR ADD EVENT FRAME
    -- SINCE PROTECTED FEATURE, PLAYER MUST MANUALLY ADD
    GRM_AddEventFrameTitleText:SetPoint ( "TOP" , GRM_AddEventFrame , 0 , - 3.5 );
    GRM_AddEventFrameTitleText:SetText ( "Event Calendar Manager" );
    GRM_AddEventFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_AddEventFrameNameTitleText:SetPoint ( "TOPLEFT" , GRM_AddEventScrollBorderFrame , 17 , 8 );
    GRM_AddEventFrameNameTitleText:SetText ( "Name:                 Event:" );
    GRM_AddEventFrameNameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    -- Scroll Frame Details
    GRM_AddEventScrollBorderFrame:SetSize ( 300 , 175 );
    GRM_AddEventScrollBorderFrame:SetPoint ( "Bottom" , GRM_AddEventFrame , 40 , 4 );
    GRM_AddEventScrollFrame:SetSize ( 280 , 153 );
    GRM_AddEventScrollFrame:SetPoint ( "RIGHT" , GRM_AddEventFrame , -25 , -21 );
    GRM_AddEventScrollFrame:SetScrollChild ( GRM_AddEventScrollChildFrame );
    -- Slider Parameters
    GRM_AddEventScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_AddEventScrollFrameSlider:SetSize( 20 , 130 );
    GRM_AddEventScrollFrameSlider:SetPoint( "TOPLEFT" , GRM_AddEventScrollFrame , "TOPRIGHT" , 0 , -11 );
    GRM_AddEventScrollFrameSlider:SetValue( 0 );
    GRM_AddEventScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_AddEventScrollFrame:SetVerticalScroll( self:GetValue() )
    end);
    -- Buttons
    GRM_AddEventLoadFrameButton:SetSize ( 90 , 11 );
    GRM_AddEventLoadFrameButton:SetPoint ( "TOPRIGHT" , GuildRosterFrame , -20 , -16 );
    GRM_AddEventLoadFrameButton:SetFrameStrata ( "HIGH" );
    GRM_AddEventLoadFrameButtonText:SetPoint ( "CENTER" , GRM_AddEventLoadFrameButton );
    GRM_AddEventLoadFrameButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddEventFrameSetAnnounceButton:SetPoint ( "LEFT" , GRM_AddEventFrame , 25 , -20 );
    GRM_AddEventFrameSetAnnounceButton:SetSize ( 60 , 50 );
    GRM_AddEventFrameSetAnnounceButtonText:SetPoint ( "CENTER" , GRM_AddEventFrameSetAnnounceButton );
    GRM_AddEventFrameSetAnnounceButtonText:SetText ( "Set\nEvent" );
    GRM_AddEventFrameSetAnnounceButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_AddEventFrameIgnoreButton:SetPoint ( "LEFT" , GRM_AddEventFrame , 25 , -80 );
    GRM_AddEventFrameIgnoreButton:SetSize ( 60 , 50 );
    GRM_AddEventFrameIgnoreButtonText:SetPoint ( "CENTER" , GRM_AddEventFrameIgnoreButton );
    GRM_AddEventFrameIgnoreButtonText:SetText ( "Ignore" );
    GRM_AddEventFrameIgnoreButtonText :SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    -- STATUS TEXT
    GRM_AddEventFrameStatusMessageText:SetPoint ( "LEFT" , GRM_AddEventFrame , 6 , 35 );
    GRM_AddEventFrameStatusMessageText:SetJustifyH ( "CENTER" );
    GRM_AddEventFrameStatusMessageText:SetWidth ( 98 );
    GRM_AddEventFrameStatusMessageText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_AddEventFrameStatusMessageText:SetText ( "Please Select\na Player" );
    GRM_AddEventFrameNameToAddText:SetPoint ( "LEFT" , GRM_AddEventFrame , 3 , 48 );
    GRM_AddEventFrameNameToAddText:SetWidth ( 105 );
    GRM_AddEventFrameNameToAddText:SetJustifyH ( "CENTER" );
    GRM_AddEventFrameNameToAddText:SetWordWrap ( true );
    GRM_AddEventFrameNameToAddText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_AddEventFrameNameDateText:SetPoint ( "TOP" , GRM_AddEventFrameNameToAddText , "BOTTOM" , 0 , -5 );
    GRM_AddEventFrameNameDateText:SetWidth ( 105 );
    GRM_AddEventFrameNameDateText:SetJustifyH ( "CENTER" );
    GRM_AddEventFrameNameDateText:SetWordWrap ( true );
    GRM_AddEventFrameNameDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_AddEventFrameNameDateText:SetTextColor ( 0 , 0.8 , 1.0 , 1.0 );
    GRM_AddEventFrameNameToAddTitleText:SetText( "" );

    -- BUTTONS
    GRM_LoadLogButton:SetSize ( 90 , 11 );
    GRM_LoadLogButton:SetPoint ( "TOPRIGHT" , GuildRosterFrame , -114 , -16 );
    GRM_LoadLogButton:SetFrameStrata ( "HIGH" );
    GRM_LoadLogButtonText:SetPoint ( "CENTER" , GRM_LoadLogButton );
    GRM_LoadLogButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_LoadLogButtonText:SetText ( "Guild Log" );

    GRM_LoadLogButton:SetScript ( "OnClick" , function ( _ , button)
        if button == "LeftButton" then
            if GRM_RosterChangeLogFrame:IsVisible() then
                GRM_RosterChangeLogFrame:Hide();
            else
                GRM_RosterChangeLogFrame:Show();
            end
        end
    end);

    -- Bring up the addon users window!
    GRM_AddonUsersButton:SetSize ( 62 , 11 );
    GRM_AddonUsersButton:SetPoint ( "BOTTOMRIGHT" , GuildRosterFrame , "TOPRIGHT" , -15 , 0.5 );
    GRM_AddonUsersButton:SetFrameStrata ( "HIGH" );
    GRM_AddonUsersButtonText:SetPoint ( "CENTER" , GRM_AddonUsersButton );
    GRM_AddonUsersButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_AddonUsersButtonText:SetText ( "Sync Info" );

    GRM_AddonUsersButton:SetScript ( "OnClick" , function ( _ , button)
        if button == "LeftButton" then
            if GRM_AddonUsersCoreFrame:IsVisible() then
                GRM_AddonUsersCoreFrame:Hide();
            else
                GRM_AddonUsersCoreFrame:Show();
            end
        end
    end);


    GRM_AddEventFrame:SetScript ( "OnShow" , function ( _ )
        GRM.RefreshAddEventFrame();
    end);

    GRM_AddEventFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_AddEventFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_AddEventFrame:SetPropagateKeyboardInput ( false );
            GRM_AddEventFrame:Hide();
        end
    end);

    GRM_AddEventLoadFrameButton:SetScript ( "OnClick" , function ( _ , button)
        if button == "LeftButton" then
            if GRM_AddEventFrame:IsVisible() then
                GRM_AddEventFrame:Hide();
            else
                GRM_AddEventFrame:Show();
            end
        end
    end);

    GRM_AddEventFrameSetAnnounceButton:SetScript ( "OnClick" , function ( self , button ) 
        if button == "LeftButton" then
            if not GRM_AddEventFrameNameToAddText:IsVisible() then
                print ( "No Player Event Has Been Selected" );
            else
                local tempTime = time();
                if tempTime - GRM_AddonGlobals.CalendarAddDelay > 5 then
                    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
                        local name = GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1];
                        local tempParsedTitle = ( GRM.SlimName ( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) - 1 ) ) ) ) .. string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                        if GRM_AddEventFrameNameToAddTitleText:GetText() == GRM.SlimName ( name ) and GRM_AddEventFrameNameToAddText:GetText() == tempParsedTitle then

                            -- Ensure it is not already on the calendar ( eventName , year , month , day )
                            if not GRM.IsCalendarEventAlreadyAdded (  GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][5] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][3] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][4] ) then
                                -- Add to Calendar
                                GRM.AddAnnouncementToCalendar ( GRM.SlimName ( name ) , tempParsedTitle , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][3] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][4] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][5] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][6] );
                                -- Do I really need a "SlimName" here?
                                GRM.Report ( GRM.SlimName ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] ) .. " Event Added to Calendar!" );
                                
                                -- Let's Broadcast the change to the other users now!
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_AC?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , "GUILD");
                                end

                                -- Remove from que
                                GRM.RemoveFromCalendarQue ( name , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                                -- Reset Frames
                                -- Clear the buttons first
                                if GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
                                    for i = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
                                        GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
                                    end
                                end
                                -- Status Notification logic
                                if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
                                    GRM_AddEventFrameStatusMessageText:SetText ( "Please Select\na Player" );
                                    GRM_AddEventFrameStatusMessageText:Show();
                                    GRM_AddEventFrameNameToAddText:Hide();
                                    GRM_AddEventFrameNameDateText:Hide();
                                else
                                    GRM_AddEventFrameStatusMessageText:SetText ( "No Events\nto Add");
                                    GRM_AddEventFrameStatusMessageText:Show();
                                    GRM_AddEventFrameNameToAddText:Hide();
                                    GRM_AddEventFrameNameDateText:Hide();
                                end
                    
                                -- Ok Building Frame!
                                GRM.BuildEventCalendarManagerScrollFrame();
                                -- Unlock the highlights too!
                                for i = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
                                    GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
                                end

                                GRM_AddonGlobals.CalendarAddDelay = tempTime;
                                break;
                            else
                                print ( GRM.SlimName ( name ) .. "'s event has already been added to the calendar!" );
                                GRM.RemoveFromCalendarQue ( name , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                            end
                        end
                    end
                else
                    print ( "Please wait " .. ( 6 - ( tempTime - GRM_AddonGlobals.CalendarAddDelay ) ) .. " more seconds to Add Event to the Calendar!" );
                end
            end
        end
    end);

    GRM_AddEventFrameIgnoreButton:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if not GRM_AddEventFrameNameToAddText:IsVisible() then
                print ( "No Player Event Has Been Selected" );
            else
                for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
                    local name = GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1];
                    local tempParsedTitle = ( GRM.SlimName( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) - 1 ) ) ) ) .. string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                    if GRM_AddEventFrameNameToAddTitleText:GetText() == GRM.SlimName ( name ) and GRM_AddEventFrameNameToAddText:GetText() == tempParsedTitle then
                        -- Remove from que
                        GRM.RemoveFromCalendarQue ( name , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] );
                        -- Reset Frames
                        -- Clear the buttons first
                        if GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
                            for i = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
                                GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
                            end
                        end
                        -- Status Notification logic
                        if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
                            GRM_AddEventFrameStatusMessageText:SetText ( "Please Select\na Player" );
                            GRM_AddEventFrameStatusMessageText:Show();
                            GRM_AddEventFrameNameToAddText:Hide();
                            GRM_AddEventFrameNameDateText:Hide();
                        else
                            GRM_AddEventFrameStatusMessageText:SetText ( "No Events\nto Add");
                            GRM_AddEventFrameStatusMessageText:Show();
                            GRM_AddEventFrameNameToAddText:Hide();
                            GRM_AddEventFrameNameDateText:Hide();
                        end
                        -- Ok Building Frame!
                        GRM.BuildEventCalendarManagerScrollFrame();
                        -- Unlock the highlights too!
                        for i = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
                            GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
                        end
                        -- Report
                        GRM.Report ( GRM.SlimName ( name ) .. "'s Event Removed From the Que!" );
                        break;
                    end                
                end
            end
        end
    end); 

    -- Hides both buttons.
    GuildRosterFrame:HookScript ( "OnHide" , function ( self ) 
        GRM_AddEventLoadFrameButton:Hide();
        GRM_LoadLogButton:Hide();
        GRM_AddonUsersButton:Hide();
        GRM_UI.GRM_BanListButton:Hide();
        GRM.ClearAllFrames();
    end);
    
    -- Needs to be initialized AFTER guild frame first logs or it will error, so only making it here now.
    GuildTextEditFrame.GuildMOTDcharCount = GuildTextEditFrame:CreateFontString ( "GuildMOTDcharCount" , "OVERLAY" , "GameFontNormalSmall" );
    GuildTextEditFrame.GuildMOTDcharCount:SetPoint ( "TOPRIGHT" , GuildTextEditBox , 15 , 19 )
    GuildTextEditFrame.GuildMOTDcharCount:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );

    -- MISC FRAMES INITIALZIATION AND LOGIC
    GuildTextEditBox:HookScript ( "OnEditFocusGained" , function()
        GuildTextEditFrame.GuildMOTDcharCount:SetText( tostring ( GuildTextEditBox:GetNumLetters() ) .. "/" .. GuildTextEditBox:GetMaxLetters() );
        GuildTextEditFrame.GuildMOTDcharCount:Show();
    
    end);
    GuildTextEditBox:HookScript ( "OnEditFocusLost" , function()
        GuildTextEditFrame.GuildMOTDcharCount:Hide();
    end);

    -- Updates char count as player types.
    GuildTextEditBox:HookScript ( "OnChar" , function ( self , text ) 
        local charCount = #GuildTextEditBox:GetText();
        charCount = charCount;
        GuildTextEditFrame.GuildMOTDcharCount:SetText( charCount .. "/" .. GuildTextEditBox:GetMaxLetters() );
    end);

    -- Update on backspace changes too
    GuildTextEditBox:HookScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
        if text == "BACKSPACE" then
            local charCount = #GuildTextEditBox:GetText();
            charCount = charCount - 1;
            if charCount == -1 then
                charCount = 0;
            end
            GuildTextEditFrame.GuildMOTDcharCount:SetText( charCount .. "/" .. GuildTextEditBox:GetMaxLetters() );
        end
    end);

    -- It is prudent to hide the frame because it deselects, server side, the players you are pulling data from. No need to keep the addon window up as it will be showing a wrong player.
    GuildRosterShowOfflineButton:HookScript ( "OnClick" , function()
        GRM_MemberDetailMetaData:Hide();
    end);

    -- TOOLTIP INIT
    GRM_MemberDetailRankToolTip:SetScale ( 0.85 );
    GRM_MemberDetailJoinDateToolTip:SetScale ( 0.85 );
    GRM_MemberDetailServerNameToolTip:SetScale ( 0.85 );
    GRM_MemberDetailNotifyStatusChangeTooltip:SetScale ( 0.65 );


    -- BAN LIST
    -- Bring up the window for the ban list!!!
    GRM_UI.GRM_BanListButton:SetSize ( 62 , 11 );
    GRM_UI.GRM_BanListButton:SetPoint ( "BOTTOMRIGHT" , GuildRosterFrame , "TOPRIGHT" , -75 , 0.5 );
    GRM_UI.GRM_BanListButton:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_BanListButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_BanListButton );
    GRM_UI.GRM_BanListButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 8 );
    GRM_UI.GRM_BanListButtonText:SetText ( "Ban List" );

    GRM_UI.GRM_BanListButton:SetScript ( "OnClick" , function ( _ , button)
        if button == "LeftButton" then
            if GRM_UI.GRM_CoreBanListFrame:IsVisible() then
                GRM_UI.GRM_CoreBanListFrame:Hide();
            else
                GRM_UI.GRM_CoreBanListFrame:Show();
            end
        end
    end);

end

-- Method:          GRM.PreAddonLoadUI()
-- What it Does:    Initializes the core Log Frame before the addon loads
-- Purpose:         One cannot use methods like "SetUserPlaced" to carry over between sessions sunless the frame is initalized BEFORE "ADDON_LOADED" event fires.
GRM_UI.PreAddonLoadUI = function()
    GRM_RosterChangeLogFrame:SetPoint ( "CENTER" , UIParent );
    GRM_RosterChangeLogFrame:SetFrameStrata ( "HIGH" );
    GRM_RosterChangeLogFrame:SetSize ( 600 , 440 );
    GRM_RosterChangeLogFrame:EnableMouse ( true );
    GRM_RosterChangeLogFrame:SetMovable ( true );
    GRM_RosterChangeLogFrame:SetUserPlaced ( true );
    GRM_RosterChangeLogFrame:SetToplevel ( true );
    -- GRM_RosterChangeLogFrame:SetResizable ( true );
    GRM_RosterChangeLogFrame:RegisterForDrag ( "LeftButton" );
    GRM_RosterChangeLogFrame:SetScript ( "OnDragStart" , GRM_RosterChangeLogFrame.StartMoving );
    GRM_RosterChangeLogFrame:SetScript ( "OnDragStop" , GRM_RosterChangeLogFrame.StopMovingOrSizing );

    -- Add Event Frame
    GRM_AddEventFrame:SetPoint ( "CENTER" , UIParent );
    GRM_AddEventFrame:SetFrameStrata ( "HIGH" );
    GRM_AddEventFrame:SetSize ( 425 , 225 );
    GRM_AddEventFrame:EnableMouse ( true );
    GRM_AddEventFrame:SetMovable ( true );
    GRM_AddEventFrame:SetUserPlaced ( true );
    GRM_AddEventFrame:SetToplevel ( true );
    GRM_AddEventFrame:RegisterForDrag ( "LeftButton" );
    GRM_AddEventFrame:SetScript ( "OnDragStart" , GRM_AddEventFrame.StartMoving );
    GRM_AddEventFrame:SetScript( "OnDragStop" , GRM_AddEventFrame.StopMovingOrSizing );

    -- Addon Users Frame
    GRM_AddonUsersCoreFrame:SetPoint ( "CENTER" , UIParent );
    GRM_AddonUsersCoreFrame:SetFrameStrata ( "HIGH" );
    GRM_AddonUsersCoreFrame:SetSize ( 425 , 225 );
    GRM_AddonUsersCoreFrame:EnableMouse ( true );
    GRM_AddonUsersCoreFrame:SetMovable ( true );
    GRM_AddonUsersCoreFrame:SetUserPlaced ( true );
    GRM_AddonUsersCoreFrame:SetToplevel ( true );
    GRM_AddonUsersCoreFrame:RegisterForDrag ( "LeftButton" );
    GRM_AddonUsersCoreFrame:SetScript ( "OnDragStart" , GRM_AddonUsersCoreFrame.StartMoving );
    GRM_AddonUsersCoreFrame:SetScript( "OnDragStop" , GRM_AddonUsersCoreFrame.StopMovingOrSizing );

    -- Ban List Frame
    GRM_UI.GRM_CoreBanListFrame:SetPoint ( "CENTER" , UIParent );
    GRM_UI.GRM_CoreBanListFrame:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_CoreBanListFrame:SetSize ( 600 , 225 );
    GRM_UI.GRM_CoreBanListFrame:EnableMouse ( true );
    GRM_UI.GRM_CoreBanListFrame:SetMovable ( true );
    GRM_UI.GRM_CoreBanListFrame:SetUserPlaced ( true );
    GRM_UI.GRM_CoreBanListFrame:SetToplevel ( true );
    GRM_UI.GRM_CoreBanListFrame:RegisterForDrag ( "LeftButton" );
    GRM_UI.GRM_CoreBanListFrame:SetScript ( "OnDragStart" , GRM_UI.GRM_CoreBanListFrame.StartMoving );
    GRM_UI.GRM_CoreBanListFrame:SetScript( "OnDragStop" , GRM_UI.GRM_CoreBanListFrame.StopMovingOrSizing );

    -- Due to some restrictions on guild controls, I also need to register a prefix for a "hack" workaround to determine if player has access to Guild Chat channel.
    -- If the player does not, then player
    GRM_FrameChatTest = CreateFrame ( "Frame" , "GRM_FrameChatTest");
    RegisterAddonMessagePrefix( "GRM_GCHAT" );
    GRM_FrameChatTest:RegisterEvent ( "CHAT_MSG_ADDON" );
    GRM_FrameChatTest:SetScript ( "OnEvent" , function ( self , event , prefix , msg , channel , sender )
        -- Only acknowledge if you are sending it to yourself, as this is just a check to see if you have access
        if event == "CHAT_MSG_ADDON" and channel == GRMsyncGlobals.channelName then
            if prefix == "GRM_GCHAT" and sender == GRM_AddonGlobals.addonPlayerName then
                GRM_AddonGlobals.HasAccessToGuildChat = true;
            end
        end
    end);
end

-- Method:          GRM_UI.BuildLogFrames()
-- What it Does:    Rebuilds the frames that hold the guild event log...
-- Purpose:         Easy access. Useful to rebuild frames on the fly at times, particularly if a player rank changes, just in case he receives/loses various permissions.
GRM_UI.BuildLogFrames = function()
        -- Button Positions
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] then
        GRM_RosterJoinedCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] then
        GRM_RosterLeveledChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] then
        GRM_RosterInactiveReturnCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] then
        GRM_RosterPromotionChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] then
        GRM_RosterDemotionChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] then
        GRM_RosterNoteChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] then
        GRM_RosterOfficerNoteChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] then
        GRM_RosterNameChangeCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] then
        GRM_RosterRankRenameCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] then
        GRM_RosterEventCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] then
        GRM_RosterLeftGuildCheckButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] then
        GRM_RosterRecommendationsButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] then
        GRM_RosterBannedPlayersButton:SetChecked( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetChecked ( true );
    end
    
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then                                         -- Show at Logon Button
        GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] then                                         -- Add Timestamp to Officer on Join Button
        GRM_RosterAddTimestampCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetChecked ( true );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:Disable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:SetChecked ( true );
    end
    
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton:SetChecked ( true );
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton:SetChecked ( true );
    end

    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:SetChecked ( true );
    end


    -- Display Information
    if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:IsVisible() then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
    end
    if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:IsVisible() then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end
    if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:IsVisible() then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end
    if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Disable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:Disable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:Disable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
    end
    -- Permissions... if not, disable button.
    if CanEditOfficerNote() then
        GRM_RosterAddTimestampCheckButton:Enable();
        GRM_RosterAddTimestampCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_RosterAddTimestampCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_RosterAddTimestampCheckButton:SetChecked ( false );
        GRM_RosterAddTimestampCheckButton:Disable();
    end
    if CanEditGuildEvent() then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:SetChecked ( false );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
    end
    if CanGuildRemove() then
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Enable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
    else
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetChecked ( false );
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:Disable();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Disable();
    end

    -- Get that Dropdown Menu Populated!
    GRM.CreateOptionsRankDropDown();
    -- Ok rebuild the log after changes!
    GRM.BuildLog();
end

-- Method           GRM.MetaDataInitializeUIrosterLog1()
-- What it Does:    Keeps the log initialization separate and part of the UIParent, so it can load upon logging in
-- Purpose:         Resource control. This loads upon login, but keeps the rest of the addon UI initialization from occuring unless as needed.
--                  In other words, this can be loaded upon logging, but the rest will only load if the guild roster window loads.
GRM_UI.MetaDataInitializeUIrosterLog1 = function()

    -- MAIN GUILD LOG FRAME!!!
    GRM_RosterChangeLogFrameTitleText:SetPoint ( "TOP" , GRM_RosterChangeLogFrame , 0 , - 3.5 );
    GRM_RosterChangeLogFrameTitleText:SetText ( "Guild Roster Event Log" );
    GRM_RosterChangeLogFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 16 );
    GRM_UI.GRM_RosterCheckBoxSideFrame:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , "TOPRIGHT" , -3 , 3 );
    GRM_UI.GRM_RosterCheckBoxSideFrame:SetSize ( 200 , 390 ); -- 509 is flush height
    -- Scroll Frame Details
    GRM_RosterChangeLogScrollBorderFrame:SetSize ( 583 , 425 );
    GRM_RosterChangeLogScrollBorderFrame:SetPoint ( "Bottom" , GRM_RosterChangeLogFrame , "BOTTOM" , -9 , -2 );
    GRM_RosterChangeLogScrollFrame:SetSize ( 565 , 402 );
    GRM_RosterChangeLogScrollFrame:SetPoint (  "Bottom" , GRM_RosterChangeLogFrame , "BOTTOM" , -2 , 10 );
    GRM_RosterChangeLogScrollFrame:SetScrollChild ( GRM_RosterChangeLogScrollChildFrame );
    -- Slider Parameters
    GRM_RosterChangeLogScrollFrameSlider:SetOrientation ( "VERTICAL" );
    GRM_RosterChangeLogScrollFrameSlider:SetSize ( 20 , 382 );
    GRM_RosterChangeLogScrollFrameSlider:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogScrollFrame , "TOPRIGHT" , -2.5 , -12 );
    GRM_RosterChangeLogScrollFrameSlider:SetValue ( 0 );
    GRM_RosterChangeLogScrollFrameSlider:SetScript ( "OnValueChanged" , function ( self )
        GRM_RosterChangeLogScrollFrame:SetVerticalScroll ( self:GetValue() );
    end);

    -- Options Buttons
    GRM_RosterOptionsButton:SetSize ( 90 , 16 );
    GRM_RosterOptionsButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 30 , -3 );
    GRM_RosterOptionsButton:SetFrameStrata ( "HIGH" );
    GRM_RosterOptionsButtonText:SetPoint ( "CENTER" , GRM_RosterOptionsButton );
    GRM_RosterOptionsButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    GRM_RosterOptionsButtonText:SetText ( "Options" );

    GRM_RosterOptionsButton:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) >= 500 then -- Since the height is a double, returns it as an int using math.floor
                GRM_RosterOptionsButton:Disable();
                if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:IsVisible() then
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
                end
                if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:IsVisible() then
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
                end
                if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:IsVisible() then
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
                end
                GRM.LogOptionsFadeOut();
                GRM.LogFrameTransformationClose();
            else
                GRM_RosterOptionsButton:Disable();
                GRM_UI.GRM_RosterLoadOnLogonCheckButton:Show();
                GRM.LogFrameTransformationOpen();   
            end
        end
    end);

    -- Clear Log Button
    GRM_RosterClearLogButton:SetSize ( 90 , 16 );
    GRM_RosterClearLogButton:SetPoint ( "TOPRIGHT" , GRM_RosterChangeLogFrame , -45 , -3 );
    GRM_RosterClearLogButton:SetFrameStrata ( "HIGH" );
    GRM_RosterClearLogButtonText:SetPoint ( "CENTER" , GRM_RosterClearLogButton );
    GRM_RosterClearLogButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11.5 );
    GRM_RosterClearLogButtonText:SetText ( "Clear Log" );
    GRM_RosterClearLogButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM_RosterChangeLogFrame:EnableMouse( false );
            GRM_RosterChangeLogFrame:SetMovable( false );
            GRM_RosterConfirmFrameText:SetText( "Really Clear the Guild Log?" );
            GRM_RosterConfirmYesButtonText:SetText ( "Yes!" );
            GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( self , button )
                if button == "LeftButton" then
                    GRM.ResetLogReport();       --Resetting!
                    GRM_RosterConfirmFrame:Hide();
                end
            end);
            GRM_RosterConfirmFrame:Show();
        end
    end);

    -- OPTIONS TEXT INFO
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsHeaderText:SetPoint ( "TOP" , GRM_RosterChangeLogFrame , 0 , - 30 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsHeaderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsHeaderText:SetText ( "__________________  OPTIONS  __________________" );
    -- GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsHeaderText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsScanDetailsText:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 18 , - 235 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsScanDetailsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsScanDetailsText:SetText ( "Scanning Roster:" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsScanDetailsText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsRankRestrictHeaderText:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 18 , -315 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsRankRestrictHeaderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsRankRestrictHeaderText:SetText ( "Guild Rank Restricted:" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsRankRestrictHeaderText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSyncHeaderText:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 18 , - 82 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSyncHeaderText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSyncHeaderText:SetText ( "Sync:" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSyncHeaderText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSlashCommandText:SetPoint ( "TOPRIGHT" , GRM_RosterChangeLogFrame , -30 , - 235 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSlashCommandText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSlashCommandText:SetText ( "Slash Commands" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.OptionsSlashCommandText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );

    -- SLASH COMMAND STRINGS
    GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText:SetPoint ( "TOPRIGHT" , GRM_RosterChangeLogFrame , 0 , - 260 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText:SetFont ( GRM_AddonGlobals.FontChoice , 14 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText:SetWidth ( 200 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText:SetJustifyH ( "LEFT" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText:SetSpacing ( 2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText:SetText ( "              /roster\n     |cffff0000Open Log/Options\n\n|cffffd100scan: |cffff0000Trigger scan for\n          changes manually\n\n|cffffd100sync: |cffff0000Trigger sync one\n          time manually\n\n|cffffd100reset: |cffff0000Centers log window\n\n|cffffd100help:  |cffff0000Slash command info\n\n|cffffd100clearall: |cffff0000Resets ALL data\n\n|cffffd100version: |cffff0000Report addon ver\n\n|cffffd100syncinfo: |cffff0000List addon Users" );

    -- Popup window to confirm!
    GRM_RosterConfirmFrame:Hide();
    GRM_RosterConfirmFrame:SetPoint ( "CENTER" , UIPanel , 0 , 200 );
    GRM_RosterConfirmFrame:SetSize ( 275 , 90 );
    GRM_RosterConfirmFrame:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_RosterConfirmFrameText:SetPoint ( "CENTER" , GRM_RosterConfirmFrame , 0 , 10 );
    GRM_RosterConfirmFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterConfirmFrameText:SetWidth ( 265 );
    GRM_RosterConfirmFrameText:SetSpacing ( 1 );
    GRM_RosterConfirmFrameText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterConfirmYesButton:SetPoint ( "BOTTOMLEFT" , GRM_RosterConfirmFrame , 15 , 5 );
    GRM_RosterConfirmYesButton:SetSize ( 70 , 35 );
    GRM_RosterConfirmYesButtonText:SetPoint ( "CENTER" , GRM_RosterConfirmYesButton );
    GRM_RosterConfirmYesButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );

    GRM_RosterConfirmCancelButton:SetPoint ( "BOTTOMRIGHT" , GRM_RosterConfirmFrame , -15 , 5 );
    GRM_RosterConfirmCancelButton:SetSize ( 70 , 35 );
    GRM_RosterConfirmCancelButtonText:SetPoint ( "CENTER" , GRM_RosterConfirmCancelButton );
    GRM_RosterConfirmCancelButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_RosterConfirmCancelButtonText:SetText ( "Cancel" );
    GRM_RosterConfirmCancelButton:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            GRM_RosterConfirmFrame:Hide();
        end
    end);
    GRM_RosterConfirmFrame:SetScript ( "OnHide" , function ( self )
        GRM_RosterChangeLogFrame:EnableMouse ( true );
        GRM_RosterChangeLogFrame:SetMovable ( true );
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame:SetScript ( "OnHide" , function ( self )
        if GRM_RosterConfirmFrameText:GetText() == "Really Clear the Guild Log?" then
            GRM_RosterConfirmFrame:Hide();
        end
    end);
    


    -- CORE OPTIONS
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -54 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterLoadOnLogonCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButtonText:SetText ( "Show at Logon" );
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetScript ( "OnClick", function()
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetAlpha ( 0 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:Hide();
        if GRM_UI.GRM_RosterLoadOnLogonCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] = false;
        end
    end);
    GRM_RosterAddTimestampCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -340 );
    GRM_RosterAddTimestampCheckButtonText:SetPoint ( "LEFT" , GRM_RosterAddTimestampCheckButton , 27 , 0 );
    GRM_RosterAddTimestampCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterAddTimestampCheckButtonText:SetText ( "Add Join Date to Officer Note   " ); -- Don't ask me why, but this spacing is needed for tabs to line up right in UI. Lua lol'
    GRM_RosterAddTimestampCheckButton:SetScript ( "OnClick", function()              
        if GRM_RosterAddTimestampCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = false;
        end
    end);

    -- Time Interval Controls on checking for changes!!!
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -260 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText:SetText ( "Scan for Changes Every" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText , "RIGHT" , 37.5 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText2:SetText ( "Seconds" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] = true;
            GRM.Report ( "Reactivating SCAN for Guild Member Changes..." );

            GuildRoster();
            C_Timer.After ( 5 , GRM.TriggerTrackingCheck );     -- 5 sec delay necessary to trigger server call.
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] = false;
            GRM.Report ( "Deactivating SCAN of Guild Member Changes..." );
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText , "RIGHT" , 1.0 , 0 )
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalCheckButtonText , "RIGHT" , -1 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetSize ( 40 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:EnableMouse ( true );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:IsEnabled() then
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:Hide();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetText ( "" );
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:Show()
            end
        end    
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetScript ( "OnEnterPressed" , function()
        local numSeconds = tonumber ( GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:GetText() );
        if numSeconds >= 10 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] = numSeconds;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNoteText:SetText ( numSeconds );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:Show();

            GuildRoster();
            C_Timer.After ( 5 , GRM.TriggerTrackingCheck );     -- 5 sec delay necessary to trigger server call.
        else
            print ( "\nDue to server data restrictions, a scan interval must be at least 10 seconds or more!\nPlease choose an scan interval 10 seconds or higher! " .. numSeconds .. " is too Low!" );
        end      
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterTimeIntervalOverlayNote:Show();
    end)

    -- Kick Recommendation!
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -365 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetText ( "Kick Inactive Player Reminder at" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , 32 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetText ( "Months" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] = false;
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , 1.0 , 0 )
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , -0.5 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetMaxLetters ( 2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:EnableMouse ( true );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:IsEnabled() then
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Hide();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetText ( "" );
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Show()
            end
        end    
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEnterPressed" , function()
        local numMonths = tonumber ( GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:GetText() );
        if numMonths > 0 and numMonths < 100 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] = numMonths;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetText ( numMonths );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
        else
            print ( "Please choose a month between 1 and 99" );
        end      
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
    end)

    -- Report Inactive Recommendation.
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -285 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton , 27 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText:SetText ( "Report Inactive Return if Player Offline" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] = false;
        end
    end);

    -- Sync Ban list
    
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -182 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList , 27 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetText ( "SYNC BAN List With Guildies at Rank " );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:GetChecked() then
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
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected , "RIGHT" , 21 , 0)
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetText ( "or Higher" );
    -- Sync Ban List Drop Down
        -- rank drop down 
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText , "RIGHT" , 0 , 1.5 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:SetSize (  130 , 18 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:SetWidth ( 130 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected , "BOTTOM" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetWidth ( 130 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:IsVisible() then
                 GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:Hide();
            else
                if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:IsVisible() then
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
                end
                GRM.PopulateBanListOptionsDropDown();
                 GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:Show();
            end
        end
    end);

    -- Options Slash command buttons
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ScanOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -48 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ScanOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ScanOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ScanOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if IsInGuild() then
                GRM.SlashCommandScan();
            end
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -97 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if IsInGuild() then
                GRM.SyncCommandScan();
            end
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_CenterOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -145 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_CenterOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_CenterOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_CenterOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM.SlashCommandCenter();
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ClearAllOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -207 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ClearAllOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ClearAllOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ClearAllOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM.SlashCommandClearAll();
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_HelpOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -175 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_HelpOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_HelpOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_HelpOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM.SlashCommandHelp();
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_VersionOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -239 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_VersionOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_VersionOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_VersionOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM.SlashCommandVersion();
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncInfoOptionsButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame.SlashCommandText , "TOPLEFT" , -5 , -271 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncInfoOptionsButton:SetSize ( 23 , 20 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncInfoOptionsButton:SetText ( "-" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncInfoOptionsButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if IsInGuild() then
                GRM.SlashCommandSyncInfo();
            end
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , 0.5 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( math.floor ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] / 24 ) );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetPoint( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , -5 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetSize ( 45 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetMaxLetters ( 3 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:EnableMouse( true );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , 32 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2:SetText ( "Days" );


    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetText ( "" );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Show();
        end    
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEnterPressed" , function()
        local numDays = tonumber ( GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:GetText() );
        if numDays > 0 and numDays < 181 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] = numDays * 24;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( numDays );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
        else
            print ( "Please choose between 1 and 180 days!" );
        end      
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end)

    -- Add Event Options on Announcing...
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -390 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton , 27 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetText ( "Announce Events" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , 32 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetText ( "Days in Advance" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] = true;
            if CanEditGuildEvent() then
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            else
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            end
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:Enable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] = false;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:Disable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            if CanEditGuildEvent() then
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Enable();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            else
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:Disable();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            end
        end
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , 0.5 , 0 )
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetSize ( 30 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) ;
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetPoint( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , -0.5 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetSize ( 35 , 22 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetMaxLetters ( 2 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetNumeric ( true );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:EnableMouse( true );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetScript ( "OnMouseDown" , function( self , button )
        if button == "LeftButton" then
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetText ( "" );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Show();
        end    
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEnterPressed" , function()
        local numDays = tonumber ( GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:GetText() );
        if numDays > 0 and numDays < 29 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] = numDays;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( numDays );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
        else
            print ( "Please choose between 1 and 28 days!" );
        end      
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end)


    -- Add Event Options Button to add events to calendar
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -440 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton , 27 , 0 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetText ( "Add Events to Calendar" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] = false;
        end
    end);

    -- SYNC WITH OTHER PLAYERS!
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -132 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , 27 , 0)
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText:SetText ( "SYNC Changes With Guildies at Rank " );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton , "RIGHT" , 1.5 , 0)
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2:SetText ( "or Higher" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = true;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Enable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:Enable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:Enable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
            if  GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetChecked( true );
            end
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                GRMsync.TriggerFullReset();
                -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                GRMsync.Initialize();
            end
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = false;
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Disable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanList:Disable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenuButton:Disable();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncBanListText3:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
            if GRMsync.MessageTracking ~= nil then
                GRMsync.MessageTracking:UnregisterAllEvents()
            end
            GRMsync.ResetDefaultValuesOnSyncReEnable();         -- Reset values to default, so that it resyncs if player re-enables.
        end
    end);

    -- GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:GetChecked()
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -157 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton , 27 , 0)
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetText ( "Display SYNC Update Messages" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] = false;
        end
    end);

    -- Rank Drop Down for Options Frame
        -- rank drop down 
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText , "RIGHT" , 1.0 , 1.5 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:SetSize (  130 , 18 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetPoint ( "CENTER" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetWidth ( 130 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "BOTTOM" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetWidth ( 130 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "RIGHT" , -1 , -0.5 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:Show();
        end
    end);

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:SetScript ( "OnShow" , function() 
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
    end)

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:IsVisible() then
                 GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
            else
                if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:IsVisible() then
                    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:Hide();
                end
                GRM.PopulateOptionsRankDropDown();
                 GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Show();
            end
        end
    end);


    -- Sync options - Restrict sync to current addon users only.
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -107 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton , 27 , 0)
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButtonText:SetText ( "Only Sync With Up-to-Date Addon Users" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_SyncOnlyCurrentVersionCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] = false;
        end
    end);

    -- Only announce Anniversaries of Player who is designated "main"
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -415 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetPoint ( "LEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton , 27 , 0)
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButtonText:SetText ( "Only Announce Anniversaries if Listed as 'Main'" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterMainOnlyCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] = false;
        end
    end);

end


-- Method           GRM.MetaDataInitializeUIrosterLog2()
-- What it Does:    Keeps the log initialization separate and part of the UIParent, so it can load upon logging in
-- Purpose:         Resource control. This loads upon login, but keeps the rest of the addon UI initialization from occuring unless as needed.
--                  In other words, this can be loaded upon logging, but the rest will only load if the guild roster window loads.
GRM_UI.MetaDataInitializeUIrosterLog2 = function()
    -- CHECKBUTTONS for Logging Details
    GRM_RosterJoinedCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -45 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -45 );
    GRM_RosterJoinedCheckButtonText:SetPoint ( "LEFT" , GRM_RosterJoinedCheckButton , 27 , 0 );
    GRM_RosterJoinedCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterJoinedCheckButtonText:SetTextColor ( 0.5 , 1.0 , 0.0 , 1.0 );
    GRM_RosterJoinedCheckButtonText:SetText ( "Joined" );
    GRM_RosterJoinedCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterJoinedCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] = false;
        end
    end);

    GRM_RosterLeveledChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -70 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -70 );
    GRM_RosterLeveledChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterLeveledChangeCheckButton , 27 , 0 );
    GRM_RosterLeveledChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterLeveledChangeCheckButtonText:SetTextColor ( 0.0 , 0.44 , 0.87 , 1.0 );
    GRM_RosterLeveledChangeCheckButtonText:SetText ( "Leveled" );
    GRM_RosterLeveledChangeCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterLeveledChangeCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] = false;
        end
    end);


    GRM_RosterInactiveReturnCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -95 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -95 );
    GRM_RosterInactiveReturnCheckButtonText:SetPoint ( "LEFT" , GRM_RosterInactiveReturnCheckButton , 27 , 0 );
    GRM_RosterInactiveReturnCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterInactiveReturnCheckButtonText:SetTextColor ( 0.0 , 1.0 , 0.87 , 1.0 );
    GRM_RosterInactiveReturnCheckButtonText:SetText ( "Inactive Return" );
    GRM_RosterInactiveReturnCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterInactiveReturnCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] = false;
        end
    end);

    GRM_RosterPromotionChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -120 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -120 );
    GRM_RosterPromotionChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterPromotionChangeCheckButton , 27 , 0 );
    GRM_RosterPromotionChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterPromotionChangeCheckButtonText:SetTextColor ( 1.0 , 0.914 , 0.0 , 1.0 );
    GRM_RosterPromotionChangeCheckButtonText:SetText ( "Promotions" );
    GRM_RosterPromotionChangeCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterPromotionChangeCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] = false;
        end
    end);

    GRM_RosterDemotionChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -145 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -145 );
    GRM_RosterDemotionChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterDemotionChangeCheckButton , 27 , 0 );
    GRM_RosterDemotionChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterDemotionChangeCheckButtonText:SetTextColor ( 0.91 , 0.388 , 0.047 , 1.0 );
    GRM_RosterDemotionChangeCheckButtonText:SetText ( "Demotions" );
    GRM_RosterDemotionChangeCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterDemotionChangeCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] = false;
        end
    end);

    GRM_RosterNoteChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -170 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -170 );
    GRM_RosterNoteChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterNoteChangeCheckButton , 27 , 0 );
    GRM_RosterNoteChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterNoteChangeCheckButtonText:SetTextColor ( 1.0 , 0.6 , 1.0 , 1.0 );
    GRM_RosterNoteChangeCheckButtonText:SetText ( "Note" );
    GRM_RosterNoteChangeCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterNoteChangeCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] = false;
        end
    end);

    GRM_RosterOfficerNoteChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -195 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -195 );
    GRM_RosterOfficerNoteChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterOfficerNoteChangeCheckButton , 27 , 0 );
    GRM_RosterOfficerNoteChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterOfficerNoteChangeCheckButtonText:SetTextColor ( 1.0 , 0.094 , 0.93 , 1.0 );
    GRM_RosterOfficerNoteChangeCheckButtonText:SetText ( "Officer Note" );
    GRM_RosterOfficerNoteChangeCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterOfficerNoteChangeCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] = false;
        end
    end);

    GRM_RosterNameChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -220 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -220 );
    GRM_RosterNameChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterNameChangeCheckButton , 27 , 0 );
    GRM_RosterNameChangeCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterNameChangeCheckButtonText:SetTextColor ( 0.90 , 0.82 , 0.62 , 1.0 );
    GRM_RosterNameChangeCheckButtonText:SetText ( "Name Change" );
    GRM_RosterNameChangeCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterNameChangeCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] = false;
        end
    end);

    GRM_RosterRankRenameCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -245 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -245 );
    GRM_RosterRankRenameCheckButtonText:SetPoint ( "LEFT" , GRM_RosterRankRenameCheckButton , 27 , 0 );
    GRM_RosterRankRenameCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterRankRenameCheckButtonText:SetTextColor ( 0.64 , 0.102 , 0.102 , 1.0 );
    GRM_RosterRankRenameCheckButtonText:SetText ( "Rank Renamed" );
    GRM_RosterRankRenameCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterRankRenameCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] = false;
        end
    end);

    GRM_RosterEventCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -270 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -270 );
    GRM_RosterEventCheckButtonText:SetPoint ( "LEFT" , GRM_RosterEventCheckButton , 27 , 0 );
    GRM_RosterEventCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterEventCheckButtonText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_RosterEventCheckButtonText:SetText ( "Event Announce" );
    GRM_RosterEventCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterEventCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] = false;
        end
    end);
     
    GRM_RosterLeftGuildCheckButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -295 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -295 );
    GRM_RosterLeftGuildCheckButtonText:SetPoint ( "LEFT" , GRM_RosterLeftGuildCheckButton , 27 , 0 );
    GRM_RosterLeftGuildCheckButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterLeftGuildCheckButtonText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    GRM_RosterLeftGuildCheckButtonText:SetText ( "Left" );
    GRM_RosterLeftGuildCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterLeftGuildCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] = false;
        end
    end);

    GRM_RosterRecommendationsButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -320 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -320 );
    GRM_RosterRecommendationsButtonText:SetPoint ( "LEFT" , GRM_RosterRecommendationsButton , 27 , 0 );
    GRM_RosterRecommendationsButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterRecommendationsButtonText:SetTextColor ( 0.65 , 0.19 , 1.0 , 1.0 );
    GRM_RosterRecommendationsButtonText:SetText ( "Recommendations" );
    GRM_RosterRecommendationsButton:SetScript ( "OnClick", function()
        if GRM_RosterRecommendationsButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] = false;
        end
    end);

    GRM_RosterBannedPlayersButton:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -345 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -345 );
    GRM_RosterBannedPlayersButtonText:SetPoint ( "LEFT" , GRM_RosterBannedPlayersButton , 27 , 0 );
    GRM_RosterBannedPlayersButtonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_RosterBannedPlayersButtonText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GRM_RosterBannedPlayersButtonText:SetText ( "Banned" );
    GRM_RosterBannedPlayersButton:SetScript ( "OnClick", function()
        if GRM_RosterBannedPlayersButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] = false;
        end
        GRM.BuildLog();
    end);
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetScript ( "OnClick", function()
        if GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] = false;
        end
    end);

    -- Propagate for keyboard control of the frames!!!
    GRM_RosterChangeLogFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_RosterChangeLogFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_RosterChangeLogFrame:SetPropagateKeyboardInput ( false );
            GRM_RosterChangeLogFrame:Hide();
        end
    end);

    GRM_RosterConfirmFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_RosterConfirmFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_RosterConfirmFrame:SetPropagateKeyboardInput ( false );
            GRM_RosterConfirmFrame:Hide();
        end
    end);

    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" and not GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:HasFocus() then
            GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetPropagateKeyboardInput ( false );
            GRM_RosterOptionsButton:Click();
        end
    end);

    -- Build Log Frames Function
    GRM_RosterChangeLogFrame:SetScript ( "OnShow" , GRM_UI.BuildLogFrames );

    --Side frame for reporting controls
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame , 0 , -12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetText ( "Display Changes" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterCheckBoxSideFrame , -14 , -28 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText:SetText ( "To Chat:" );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterCheckBoxSideFrame , 14 , -28 );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText:SetText ( "To Log:" );

    -- User with addon installed...
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameText:SetPoint ( "TOP" , GRM_AddonUsersCoreFrame , 0 , - 3.5 );
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameText:SetText ( "GRM Sync Info     ( Ver: " .. string.sub ( GRM_AddonGlobals.Version , string.find ( GRM_AddonGlobals.Version , "R" , -8 ) , #GRM_AddonGlobals.Version ) .. " )" );
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameTitleText:SetPoint ( "TOP" , GRM_AddonUsersCoreFrame , 0 , - 32 );
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameTitleText:SetJustifyH ( "LEFT" );
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameTitleText:SetText ( "NAME                           Sync                          Version" );
    GRM_AddonUsersCoreFrame.GRM_AddonUsersCoreFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetPoint ( "CENTER" , GRM_AddonUsersCoreFrame );
    GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    -- Scroll Frame Details
    GRM_AddonUsersScrollBorderFrame:SetSize ( 395 , 175 );
    GRM_AddonUsersScrollBorderFrame:SetPoint ( "Bottom" , GRM_AddonUsersCoreFrame , -5 , 4 );
    GRM_AddonUsersScrollFrame:SetSize ( 375 , 153 );
    GRM_AddonUsersScrollFrame:SetPoint ( "RIGHT" , GRM_AddonUsersCoreFrame , -25 , -21 );
    GRM_AddonUsersScrollFrame:SetScrollChild ( GRM_AddonUsersScrollChildFrame );
    -- Slider Parameters
    GRM_AddonUsersScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_AddonUsersScrollFrameSlider:SetSize( 20 , 130 );
    GRM_AddonUsersScrollFrameSlider:SetPoint( "TOPLEFT" , GRM_AddonUsersScrollFrame , "TOPRIGHT" , 0 , -11 );
    GRM_AddonUsersScrollFrameSlider:SetValue( 0 );
    GRM_AddonUsersScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_AddonUsersScrollFrame:SetVerticalScroll( self:GetValue() )
    end);

    GRM_AddonUsersCoreFrame:SetScript ( "OnShow" , GRM.RefreshAddonUserFrames );

    -- Let's refresh the frames every 15 seconds or so...
    GRM_AddonUsersCoreFrame:SetScript ( "OnUpdate" , function ( self , elapsed ) 
        GRM_AddonGlobals.timer5 = GRM_AddonGlobals.timer5 + elapsed;
        if GRM_AddonGlobals.timer5 >= 15 then
            GRM.RegisterGuildAddonUsersRefresh ();
            GRM_AddonGlobals.timer5 = 0;
        end
    end);

    GRM_AddonUsersCoreFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_AddonUsersCoreFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_AddonUsersCoreFrame:SetPropagateKeyboardInput ( false );
            GRM_AddonUsersCoreFrame:Hide();
        end
    end);

    -- BAN LIST FRAME LOGIC AND INITIALIZATION DETAILS!!!
    -- User with addon installed...
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText:SetPoint ( "TOP" , GRM_CoreBanListFrame , 0 , - 3.5 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText:SetText ( GRM_AddonGlobals.guildName .. " - Ban List" );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetPoint ( "BOTTOMLEFT" , GRM_CoreBanListScrollBorderFrame, "TOPLEFT" , 15 , -4 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2:SetText ( "NAME:" );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetPoint ( "BOTTOM" , GRM_CoreBanListScrollBorderFrame, "TOP" , 60 , -4 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText3:SetText ( "RANK" );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetPoint ( "BOTTOM" , GRM_CoreBanListScrollBorderFrame, "TOPRIGHT" , -54 , -4 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetTextColor ( 0.64 , 0.102 , 0.102 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText4:SetText ( "BAN DATE" );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetPoint ( "LEFT" , GRM_CoreBanListFrame , -5 , 35 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetWidth ( 100 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetWordWrap ( true );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 14 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetPoint ( "LEFT" , GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameTitleText2 , 60 , 0 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetJustifyH ( "CENTER" );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 15 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetPoint ( "TOPLEFT" , GRM_CoreBanListFrame , 8 , - 6 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetPoint ( "CENTER" , GRM_UI.GRM_CoreBanListScrollBorderFrame );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 17 );
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:SetText ( "No Players Have Been Banned\nfrom Your Guild" );
    -- Scroll Frame Details
    GRM_UI.GRM_CoreBanListScrollBorderFrame:SetSize ( 500 , 175 );
    GRM_UI.GRM_CoreBanListScrollBorderFrame:SetPoint ( "Bottom" , GRM_CoreBanListFrame , 30 , 4 );
    GRM_UI.GRM_CoreBanListScrollFrame:SetSize ( 480 , 153 );
    GRM_UI.GRM_CoreBanListScrollFrame:SetPoint ( "RIGHT" , GRM_CoreBanListFrame , -25 , -21 );
    GRM_UI.GRM_CoreBanListScrollFrame:SetScrollChild ( GRM_UI.GRM_CoreBanListScrollChildFrame );
    -- Slider Parameters
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetOrientation( "VERTICAL" );
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetSize( 20 , 130 );
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreBanListScrollFrame , "TOPRIGHT" , 0 , -11 );
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetValue( 0 );
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetFrameStrata ( "HIGH" );
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
        GRM_UI.GRM_CoreBanListScrollFrame:SetVerticalScroll( self:GetValue() )
    end);
    --Add and Remove Ban Buttons
    GRM_UI.GRM_BanListRemoveButton:SetPoint ( "LEFT" , GRM_UI.GRM_CoreBanListFrame , 8 , -20 );
    GRM_UI.GRM_BanListRemoveButton:SetSize ( 70 , 50 );
    GRM_UI.GRM_BanListRemoveButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_BanListRemoveButton );
    GRM_UI.GRM_BanListRemoveButtonText:SetText ( "Remove\nBan" );
    GRM_UI.GRM_BanListRemoveButtonText:SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
    GRM_UI.GRM_BanListAddButton:SetPoint ( "LEFT" , GRM_UI.GRM_CoreBanListFrame , 8 , -80 );
    GRM_UI.GRM_BanListAddButton:SetSize ( 70 , 50 );
    GRM_UI.GRM_BanListAddButtonText:SetPoint ( "CENTER" , GRM_UI.GRM_BanListAddButton );
    GRM_UI.GRM_BanListAddButtonText:SetText ( "Add" );
    GRM_UI.GRM_BanListAddButtonText :SetFont( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );

    -- For when the frame appears
    GRM_UI.GRM_CoreBanListFrame:SetScript ( "OnShow" , function()
        -- Reset the highlights and some certain frames...
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( "Select\na Player" );
        
        if GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons ~= nil then
            for i = 1 , #GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
            end
        end
        -- Build the frames...
        GRM.RefreshBanListFrames();
    end);

    -- So escape key can hide the frames.
    GRM_UI.GRM_CoreBanListFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_UI.GRM_CoreBanListFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_UI.GRM_CoreBanListFrame:SetPropagateKeyboardInput ( false );
            GRM_UI.GRM_CoreBanListFrame:Hide();
        end
    end);

    -- Removing a player from the ban list that is no longer in the guild.
    GRM_UI.GRM_BanListRemoveButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            if GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:IsVisible() then
                
                -- Send the unban out for sync'd players
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_UNBAN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] ) .. "?" .. GRM_AddonGlobals.TempBanTarget .. "?" , "GUILD");
                end
               
                -- Do the unban locally...
                GRM.BanListUnban ( GRM_AddonGlobals.TempBanTarget );

                -- Message
                if GRM_AddonGlobals.TempBanTarget ~= "" and GRM_AddonGlobals.TempBanTarget ~= nil then
                    DEFAULT_CHAT_FRAME:AddMessage ( GRM.SlimName ( GRM_AddonGlobals.TempBanTarget ) " has been Removed from the Ban List." , 1.0 , 0.84 , 0 );
                end
            else
                print ( "Please Select a Player to Unban!" );
            end
        end
    end);

end

-- Load this at start. You cannot save frame positions between sessions unless it initializes in initial login.
GRM_UI.PreAddonLoadUI();