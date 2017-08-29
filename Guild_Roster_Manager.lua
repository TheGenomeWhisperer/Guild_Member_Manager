-- Author: Arkaan
-- Addon Name: "Guild Roster Manager"

local Version = "7.3.0R1.08";
local PatchDay = 1504018933; -- In Epoch Time
local Patch = "7.3";

-- Table to hold all functions
GRM = {};

-- Global tables saved account wide.
-- Just load the settings the first time addon is loaded.
GRM_AddonSettings_Save = {};
GRM_LogReport_Save = {};                 -- This will be the stored Log of events and changes.
GRM_GuildMemberHistory_Save = {}         -- Detailed information on each guild member
GRM_PlayersThatLeftHistory_Save = {};    -- Data storage of all players that left the guild, so metadata is stored if they return. Useful for "rejoin" tracking, and to see if players were banned.
GRM_CalendarAddQue_Save = {};            -- Since the add to calendar is protected, and requires a player input, this will be qued here between sessions. { name , eventTitle , eventMonth , eventDay , eventYear , eventDescription } 

-- slash commands
SLASH_GRM1 = '/roster';

-- Useful Variables ( kept in table to keep low upvalues count )
GRM_AddonGlobals = {};
-- Live tracking settings
-- Initialization Useful Globals
-- ADDON
GRM_AddonGlobals.addonName = "Guild_Roster_Manager";
-- Player Details
GRM_AddonGlobals.guildName = GetGuildInfo ( "PLAYER" );
GRM_AddonGlobals.realmName = string.gsub ( GetRealmName() , "%s+" , "" );       -- Remove the space since server return calls don't include space on multi-name servers
GRM_AddonGlobals.addonPlayerName = ( GetUnitName ( "PLAYER" , false ) .. "-" .. GRM_AddonGlobals.realmName );
GRM_AddonGlobals.faction = UnitFactionGroup ( "PLAYER" );
GRM_AddonGlobals.rank = 1;
GRM_AddonGlobals.FID = 0;        -- index for Horde = 1; Ally = 2
GRM_AddonGlobals.logGID = 0;     -- index of the guild, so no need for repeat lookups.
GRM_AddonGlobals.saveGID = 0;    -- Needs a separate GID "Guild Index ID" because it may not match the log index depending on if a log entry is cleared vs guild info, whcih can be separate.
GRM_AddonGlobals.setPID = 0;     -- Since settings are player unique, PID = Player ID

-- To ensure frame initialization occurse just once... what a waste in resources otherwise.
GRM_AddonGlobals.timeDelayValue = 0;
GRM_AddonGlobals.timeDelayValue2 = 0;
GRM_AddonGlobals.FramesInitialized = false;
GRM_AddonGlobals.OnFirstLoad = true;
GRM_AddonGlobals.currentlyTracking = false;
GRM_AddonGlobals.trackingTriggered = false;

-- Guild Status holder for checkover.
GRM_AddonGlobals.guildStatusChecked = false;

-- Tempt Logs For FinalReport()
GRM_AddonGlobals.TempNewMember = {};
GRM_AddonGlobals.TempLogPromotion = {};
GRM_AddonGlobals.TempInactiveReturnedLog = {};
GRM_AddonGlobals.TempEventRecommendKickReport = {};
GRM_AddonGlobals.TempLogDemotion = {};
GRM_AddonGlobals.TempLogLeveled = {};
GRM_AddonGlobals.TempLogNote = {};
GRM_AddonGlobals.TempLogONote = {};
GRM_AddonGlobals.TempRankRename = {};
GRM_AddonGlobals.TempRejoin = {};
GRM_AddonGlobals.TempBannedRejoin = {};
GRM_AddonGlobals.TempLeftGuild = {};
GRM_AddonGlobals.TempNameChanged = {};
GRM_AddonGlobals.TempEventReport = {};

-- Useful Globals for Quick Use
GRM_AddonGlobals.tempName = "";
GRM_AddonGlobals.rankIndex = 1;
GRM_AddonGlobals.playerIndex = -1;
GRM_AddonGlobals.monthIndex = 1;
GRM_AddonGlobals.yearIndex = 1;
GRM_AddonGlobals.dayIndex = 1;

-- Alt Helpers
GRM_AddonGlobals.selectedAlt = {};
GRM_AddonGlobals.selectedAltList = {};
GRM_AddonGlobals.currentHighlightIndex = 1;

-- Guildie info
GRM_AddonGlobals.listOfGuildies = {};

-- MISC Globals for resource handling... generally to avoid wasteful checks based on timers, position, pause controls.
-- Some of this is just to prevent messy carryover by keeping 1 less argument to a method, by just keeping a global. 
-- Some are for frame/UI control, like "pause" to stop mouseover updates if you actually click on a player's name.
GRM_AddonGlobals.timer = 0;
GRM_AddonGlobals.timer2 = 0; 
GRM_AddonGlobals.timer3 = 0;
GRM_AddonGlobals.DelayedAtLeastOnce = false;
GRM_AddonGlobals.CalendarAddDelay = 0; -- Needs to be at least 5 seconds...
GRM_AddonGlobals.RaidGCountBeingChecked = false;
GRM_AddonGlobals.timerUIChange = 0;
GRM_AddonGlobals.position = 0;
GRM_AddonGlobals.ScrollPosition = 0;
GRM_AddonGlobals.ShowOfflineChecked = false;
GRM_AddonGlobals.pause = false;
GRM_AddonGlobals.rankDateSet = false;
GRM_AddonGlobals.editPromoDate = false;
GRM_AddonGlobals.editJoinDate = false;
GRM_AddonGlobals.editFocusPlayer = false;
GRM_AddonGlobals.editStatusNotify = false
GRM_AddonGlobals.editOnlineStatus = false;
GRM_AddonGlobals.numPlayersRequestingGuildInv = 0;
GRM_AddonGlobals.guildFinderReported = false;
GRM_AddonGlobals.changeHappenedExitScan = false;
GRM_AddonGlobals.currentName = "";
GRM_AddonGlobals.RecursiveStop = false;

GRM_AddonGlobals.VersionChecked = false;
GRM_AddonGlobals.VersionCheckRegistered = false;
GRM_AddonGlobals.VersionCheckedNames = {};

GRM_AddonGlobals.ActiveCheckQue = {};
GRM_AddonGlobals.ActiveStatusQue = {};

 -- Which frame to send AddMessage
local chat = DEFAULT_CHAT_FRAME;


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

-- Live Frames
local Initialization = CreateFrame ( "Frame" );
local GeneralEventTracking = CreateFrame ( "Frame" );
local UI_Events = CreateFrame ( "Frame" );
local VersionCheck = CreateFrame ( "Frame" );

-- Core Frame
local GRM_MemberDetailMetaData = CreateFrame( "Frame" , "GRM_MemberDetailMetaData" , GuildRosterFrame , "TranslucentFrameTemplate" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton = CreateFrame( "Button" , "GRM_MemberDetailMetaDataCloseButton" , GRM_MemberDetailMetaData , "UIPanelCloseButton");
GRM_MemberDetailMetaData:Hide();  -- Prevent error where it sometimes auto-loads.

-- Guild Member Detail Frame UI and Children
local GRM_SetPromoDateButton = CreateFrame ( "Button" , "GRM_SetPromoDateButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_SetPromoDateButton.GRM_SetPromoDateButtonText = GRM_SetPromoDateButton:CreateFontString ( "GRM_SetPromoDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

local GRM_DayDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_DayDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_DayDropDownMenuSelected:Hide();
GRM_DayDropDownMenuSelected.DayText = GRM_DayDropDownMenuSelected:CreateFontString ( "GRM_DayDropDownMenuSelected.DayText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_DayDropDownMenu = CreateFrame ( "Frame" , "GRM_DayDropDownMenu" , GRM_DayDropDownMenuSelected , "InsetFrameTemplate" );
local GRM_DayDropDownButton = CreateFrame ( "Button" , "GRM_DayDropDownButton" , GRM_DayDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

local GRM_YearDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_YearDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_YearDropDownMenuSelected:Hide();
GRM_YearDropDownMenuSelected.YearText = GRM_YearDropDownMenuSelected:CreateFontString ( "GRM_YearDropDownMenuSelected.YearText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_YearDropDownMenu = CreateFrame ( "Frame" , "GRM_YearDropDownMenu" , GRM_YearDropDownMenuSelected , "InsetFrameTemplate" );
local GRM_YearDropDownButton = CreateFrame ( "Button" , "GRM_YearDropDownButton" , GRM_YearDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

local GRM_MonthDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_MonthDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_MonthDropDownMenuSelected:Hide();
GRM_MonthDropDownMenuSelected.MonthText = GRM_MonthDropDownMenuSelected:CreateFontString ( "GRM_MonthDropDownMenuSelected.MonthText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_MonthDropDownMenu = CreateFrame ( "Frame" , "GRM_MonthDropDownMenu" , GRM_MonthDropDownMenuSelected , "InsetFrameTemplate" );
local GRM_MonthDropDownButton = CreateFrame ( "Button" , "GRM_MonthDropDownButton" , GRM_MonthDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );

-- SUBMIT BUTTONS
local GRM_DateSubmitButton = CreateFrame ( "Button" , "GRM_DateSubmitButton" , GRM_MemberDetailMetaData , "UIPanelButtonTemplate" );
local GRM_DateSubmitCancelButton = CreateFrame ( "Button" , "GRM_DateSubmitCancelButton" , GRM_MemberDetailMetaData , "UIPanelButtonTemplate" );
local GRM_DateSubmitButtonTxt = GRM_DateSubmitButton:CreateFontString ( "GRM_DateSubmitButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_DateSubmitCancelButtonTxt = GRM_DateSubmitCancelButton:CreateFontString ( "GRM_DateSubmitCancelButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );

-- RANK DROPDOWN
local GRM_guildRankDropDownMenuSelected = CreateFrame ( "Frame" , "GRM_guildRankDropDownMenuSelected" , GRM_MemberDetailMetaData , "InsetFrameTemplate" );
GRM_guildRankDropDownMenuSelected:Hide();
GRM_guildRankDropDownMenuSelected.RankText = GRM_guildRankDropDownMenuSelected:CreateFontString ( "GRM_guildRankDropDownMenuSelected.RankText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_RankDropDownMenu = CreateFrame ( "Frame" , "GRM_RankDropDownMenu" , GRM_guildRankDropDownMenuSelected , "InsetFrameTemplate" );
local GRM_RankDropDownMenuButton = CreateFrame ( "Button" , "GRM_RankDropDownMenuButton" , GRM_guildRankDropDownMenuSelected , "UIPanelScrollDownButtonTemplate" );


-- Normal frame translucent
local noteBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 18,
    insets = { left == 5 , right = 5 , top = 5 , bottom = 5 }
}

-- Thinnner frame translucent template
local noteBackdrop2 = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 9,
    insets = { left == 2 , right = 2 , top = 3 , bottom = 2 }
}

local GRM_PlayerNoteWindow = CreateFrame( "Frame" , "GRM_PlayerNoteWindow" , GRM_MemberDetailMetaData );
local GRM_noteFontString1 = GRM_PlayerNoteWindow:CreateFontString ( "GRM_noteFontString1" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_PlayerNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerNoteEditBox" , GRM_MemberDetailMetaData );
local GRM_PlayerOfficerNoteWindow = CreateFrame( "Frame" , "GRM_PlayerOfficerNoteWindow" , GRM_MemberDetailMetaData );
local GRM_noteFontString2 = GRM_PlayerOfficerNoteWindow:CreateFontString ( "GRM_noteFontString2" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_PlayerOfficerNoteEditBox = CreateFrame( "EditBox" , "GRM_PlayerOfficerNoteEditBox" , GRM_MemberDetailMetaData );
local GRM_NoteCount = GRM_MemberDetailMetaData:CreateFontString ( "GRM_NoteCount" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_PlayerNoteEditBox:Hide();
GRM_PlayerOfficerNoteEditBox:Hide();

-- Populating Frames with FontStrings
local GRM_MemberDetailNameText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailNameText" , "OVERLAY" , "GameFontNormalLarge" );
local GRM_MemberDetailMainText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMainText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_MemberDetailLevel = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLevel" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_MemberDetailRankTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailRankTxt" , "OVERLAY" , "GameFontNormal" );
local GRM_MemberDetailRankDateTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailRankDateTxt" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_MemberDetailNoteTitle = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailNoteTitle" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_MemberDetailONoteTitle = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailONoteTitle" , "OVERLAY" , "GameFontNormalSmall" );

-- Fontstring for MemberRank History 
local GRM_MemberDetailJoinDateButton = CreateFrame ( "Button" , "GRM_MemberDetailJoinDateButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
local GRM_MemberDetailJoinDateButtonText = GRM_MemberDetailJoinDateButton:CreateFontString ( "GRM_MemberDetailJoinDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_JoinDateText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_JoinDateText" , "OVERLAY" , "GameFontWhiteTiny" );

-- LAST ONLINE
local GRM_MemberDetailLastOnlineTitleTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLastOnlineTitleTxt" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_MemberDetailLastOnlineTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailLastOnlineTxt" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_MemberDetailDateJoinedTitleTxt = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailDateJoinedTitleTxt" , "OVERLAY" , "GameFontNormalSmall" );

-- STATUS TEXT
local GRM_MemberDetailPlayerStatus = GRM_MemberDetailMetaData:CreateFontString ("GRM_MemberDetailPlayerStatus" , "OVERLAY" , "GameFontNormalSmall" );

-- ZONEINFORMATION
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoZoneText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1 = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoTimeText1" , "OVERLAY" , "GameFontNormalSmall" );
GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2 = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailMetaZoneInfoTimeText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- GROUP INVITE and REMOVE from Guild BUTTONS
local GRM_GroupInviteButton = CreateFrame ( "Button" , "GRM_GroupInviteButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_GroupInviteButton.GRM_GroupInviteButtonText = GRM_GroupInviteButton:CreateFontString ( "GRM_GroupInviteButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_RemoveGuildieButton = CreateFrame ( "Button" , "GRM_RemoveGuildieButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText = GRM_RemoveGuildieButton:CreateFontString ( "GRM_RemoveGuildieButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- Tooltips
local GRM_MemberDetailRankToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailRankToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailRankToolTip:Hide();
local GRM_MemberDetailJoinDateToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailJoinDateToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailJoinDateToolTip:Hide();
local GRM_MemberDetailServerNameToolTip = CreateFrame ( "GameTooltip" , "GRM_MemberDetailServerNameToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
GRM_MemberDetailJoinDateToolTip:Hide();

-- CUSTOM POPUPBOX FOR REUSE -- Avoids all possibility of UI Taint by just building my own, for those that use a lot of addons.
local GRM_PopupWindow = CreateFrame ( "Frame" , "GRM_PopupWindow" , GRM_MemberDetailMetaData , "TranslucentFrameTemplate" );
GRM_PopupWindow:Hide() -- Prevents it from autopopping up on load like it sometimes will.
local GRM_PopupWindowButton1 = CreateFrame ( "Button" , "GRM_PopupWindowButton1" , GRM_PopupWindow , "UIPanelButtonTemplate" );
GRM_PopupWindowButton1.GRM_PopupWindowButton1Text = GRM_PopupWindowButton1:CreateFontString ( "GRM_PopupWindowButton1Text" , "OVERLAY" , "GameFontNormal" );
local GRM_PopupWindowButton2 = CreateFrame ( "Button" , "GRM_PopupWindowButton2" , GRM_PopupWindow , "UIPanelButtonTemplate" );
GRM_PopupWindowButton2.GRM_PopupWindowButton2Text = GRM_PopupWindowButton2:CreateFontString ( "GRM_PopupWindowButton2Text" , "OVERLAY" , "GameFontNormal" );
local GRM_PopupWindowCheckButton1 = CreateFrame ( "CheckButton" , "GRM_PopupWindowCheckButton1" , GRM_PopupWindow , "OptionsSmallCheckButtonTemplate" );
local GRM_PopupWindowCheckButtonText = GRM_PopupWindowCheckButton1:CreateFontString ( "GRM_PopupWindowCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_PopupWindowCheckButton2 = CreateFrame ( "CheckButton" , "GRM_PopupWindowCheckButton2" , GRM_PopupWindow , "OptionsSmallCheckButtonTemplate" );
local GRM_PopupWindowCheckButton2Text = GRM_PopupWindowCheckButton2:CreateFontString ( "GRM_PopupWindowCheckButton2Text" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_PopupWindowConfirmText = GRM_PopupWindow:CreateFontString ( "GRM_PopupWindowConfirmText" , "OVERLAY" , "GameFontNormal" );

-- EDIT BOX FOR ANYTHING ( like banned player note );
local GRM_MemberDetailEditBoxFrame = CreateFrame ( "Frame" , "GRM_MemberDetailEditBoxFrame" , GRM_PopupWindow , "TranslucentFrameTemplate" );
GRM_MemberDetailEditBoxFrame:Hide();
local GRM_MemberDetailPopupEditBox = CreateFrame ( "EditBox" , "GRM_MemberDetailPopupEditBox" , GRM_MemberDetailEditBoxFrame );

-- Banned Fontstring and Buttons
local GRM_MemberDetailBannedText1 = GRM_MemberDetailMetaData:CreateFontString ( "GRM_MemberDetailBannedText1" , "OVERLAY" , "GameFontNormalSmall");
local GRM_MemberDetailBannedIgnoreButton = CreateFrame ( "Button" , "GRM_MemberDetailBannedIgnoreButton" , GRM_MemberDetailMetaData , "GameMenuButtonTemplate" );
GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText = GRM_MemberDetailBannedIgnoreButton:CreateFontString ( "GRM_MemberDetailBannedIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

-- ALT FRAMES!!!
local GRM_CoreAltFrame = CreateFrame( "Frame" , "GRM_CoreAltFrame" , GRM_MemberDetailMetaData );
GRM_CoreAltFrame:Hide(); -- No need to show initially. Occasionally on init. it would popup the title text. Just keep hidden with init.
local GRM_CoreAltScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_CoreAltScrollFrame" , GRM_CoreAltFrame );
-- GRM_CoreAltScrollFrame:Hide();
-- CONTENT ALT FRAME (Child Frame)
local GRM_CoreAltScrollChildFrame = CreateFrame ( "Frame" , "GRM_CoreAltScrollChildFrame" );
-- SLIDER
local GRM_CoreAltScrollFrameSlider = CreateFrame ( "Slider" , "GRM_CoreAltScrollFrameSlider" , GRM_CoreAltScrollFrame , "UIPanelScrollBarTemplate" );
-- ALT HEADER
local GRM_altFrameTitleText = GRM_CoreAltFrame:CreateFontString ( "GRM_altFrameTitleText" , "OVERLAY" , "GameFontNormalSmall" );
-- ALT OPTIONSFRAME
local GRM_altDropDownOptions = CreateFrame ( "Frame" , "GRM_altDropDownOptions" , GRM_MemberDetailMetaData );
GRM_altDropDownOptions:Hide();
local GRM_altOptionsText = GRM_altDropDownOptions:CreateFontString ( "GRM_altOptionsText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_altOptionsDividerText = GRM_altDropDownOptions:CreateFontString ( "GRM_altOptionsDividerText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT BUTTONS
local GRM_AddAltButton = CreateFrame ( "Button" , "GRM_AddAltButton" , GRM_CoreAltFrame , "GameMenuButtonTemplate" );
local GRM_AddAltButtonText = GRM_AddAltButton:CreateFontString ( "GRM_AddAltButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltButton2 = CreateFrame ( "Button" , "GRM_AddAltButton2" , GRM_CoreAltScrollChildFrame , "GameMenuButtonTemplate" );
local GRM_AddAltButton2Text = GRM_AddAltButton2:CreateFontString ( "GRM_AddAltButton2Text" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_altSetMainButton = CreateFrame ( "Button" , "GRM_altSetMainButton" , GRM_altDropDownOptions  );
local GRM_altSetMainButtonText = GRM_altSetMainButton:CreateFontString ( "GRM_altSetMainButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_altRemoveButton = CreateFrame ( "Button" , "GRM_altRemoveButton" , GRM_altDropDownOptions );
local GRM_altRemoveButtonText = GRM_altRemoveButton:CreateFontString ( "GRM_altRemoveButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_altFrameCancelButton = CreateFrame ( "Button" , "GRM_altFrameCancelButton" , GRM_altDropDownOptions );
local GRM_altFrameCancelButtonText = GRM_altFrameCancelButton:CreateFontString ( "GRM_altFrameCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT TOOLTIP
local GRM_altFrameToolTip = CreateFrame ( "GameTooltip" , "GRM_altFrameToolTip" , GRM_MemberDetailMetaData , "GameTooltipTemplate" );
-- ALT NAMES (If I end up running short on FontStrings, I may need to convert to use static buttons.)
local GRM_AltName1 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName1" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName2 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName2" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName3 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName3" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName4 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName4" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName5 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName5" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName6 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName6" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName7 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName7" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName8 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName8" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName9 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName9" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName10 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName10" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName11 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName11" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AltName12 = GRM_CoreAltFrame:CreateFontString ( "GRM_AltName12" , "OVERLAY" , "GameFontNormalSmall" );
-- ADD ALT EDITBOX Frame
local GRM_AddAltEditFrame = CreateFrame ( "Frame" , "GRM_AddAltEditFrame" , GRM_CoreAltFrame , "TranslucentFrameTemplate" );
GRM_AddAltEditFrame:Hide();
local GRM_AddAltTitleText = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltTitleText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AddAltEditBox = CreateFrame ( "EditBox" , "GRM_AddAltEditBox" , GRM_AddAltEditFrame , "InputBoxTemplate" );
local GRM_AddAltNameButton1 = CreateFrame ( "Button" , "GRM_AddAltNameButton1" , GRM_AddAltEditFrame );
local GRM_AddAltNameButton2 = CreateFrame ( "Button" , "GRM_AddAltNameButton2" , GRM_AddAltEditFrame );
local GRM_AddAltNameButton3 = CreateFrame ( "Button" , "GRM_AddAltNameButton3" , GRM_AddAltEditFrame );
local GRM_AddAltNameButton4 = CreateFrame ( "Button" , "GRM_AddAltNameButton4" , GRM_AddAltEditFrame );
local GRM_AddAltNameButton5 = CreateFrame ( "Button" , "GRM_AddAltNameButton5" , GRM_AddAltEditFrame );
local GRM_AddAltNameButton6 = CreateFrame ( "Button" , "GRM_AddAltNameButton6" , GRM_AddAltEditFrame );
local GRM_AddAltNameButton1Text = GRM_AddAltNameButton1:CreateFontString ( "GRM_AddAltNameButton1" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltNameButton2Text = GRM_AddAltNameButton2:CreateFontString ( "GRM_AddAltNameButton2" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltNameButton3Text = GRM_AddAltNameButton3:CreateFontString ( "GRM_AddAltNameButton3" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltNameButton4Text = GRM_AddAltNameButton4:CreateFontString ( "GRM_AddAltNameButton4" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltNameButton5Text = GRM_AddAltNameButton5:CreateFontString ( "GRM_AddAltNameButton5" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltNameButton6Text = GRM_AddAltNameButton6:CreateFontString ( "GRM_AddAltNameButton6" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltEditFrameTextBottom = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameTextBottom" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddAltEditFrameHelpText = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameHelpText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_AddAltEditFrameHelpText2 = GRM_AddAltEditFrame:CreateFontString ( "GRM_AddAltEditFrameHelpText2" , "OVERLAY" , "GameFontWhiteTiny" );

-- CALENDAR ADD EVENT WINDOW
local GRM_AddEventFrame = CreateFrame ( "Frame" , "GRM_AddEventFrame" , UIParent , "BasicFrameTemplate" );
GRM_AddEventFrame:Hide();
local GRM_AddEventFrameTitleText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameTitleText" , "OVERLAY" , "GameFontNormal" );
local GRM_AddEventFrameNameTitleText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
local GRM_AddEventFrameStatusMessageText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
local GRM_AddEventFrameNameToAddText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameTitleText" , "OVERLAY" , "GameFontNormal" );
local GRM_AddEventFrameNameToAddTitleText = GRM_AddEventFrame:CreateFontString ( "GRM_AddEventFrameNameToAddTitleText" , "OVERLAY" , "GameFontNormal" );   -- Will never be displayed, just a frame txt holder
-- Set and Ignore Buttons
local GRM_AddEventFrameSetAnnounceButton = CreateFrame ( "Button" , "GRM_AddEventFrameSetAnnounceButton" , GRM_AddEventFrame , "UIPanelButtonTemplate" );
local GRM_AddEventFrameSetAnnounceButtonText = GRM_AddEventFrameSetAnnounceButton:CreateFontString ( "GRM_AddEventFrameSetAnnounceButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GRM_AddEventFrameIgnoreButton = CreateFrame ( "Button" , "GRM_AddEventFrameIgnoreButton" , GRM_AddEventFrame , "UIPanelButtonTemplate" );
local GRM_AddEventFrameIgnoreButtonText = GRM_AddEventFrameIgnoreButton:CreateFontString ( "GRM_AddEventFrameIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- SCROLL FRAME
local GRM_AddEventScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_AddEventScrollFrame" , GRM_AddEventFrame );
local GRM_AddEventScrollBorderFrame = CreateFrame ( "Frame" , "GRM_AddEventScrollBorderFrame" , GRM_AddEventFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
local GRM_AddEventScrollChildFrame = CreateFrame ( "Frame" , "GRM_AddEventScrollChildFrame" );
-- SLIDER
local GRM_AddEventScrollFrameSlider = CreateFrame ( "Slider" , "GRM_AddEventScrollFrameSlider" , GRM_AddEventScrollFrame , "UIPanelScrollBarTemplate" );
-- EvntWindowButton
local GRM_AddEventLoadFrameButton = CreateFrame( "Button" , "GRM_AddEventLoadFrameButton" , GuildRosterFrame , "UIPanelButtonTemplate" );
local GRM_AddEventLoadFrameButtonText = GRM_AddEventLoadFrameButton:CreateFontString ( "GRM_AddEventLoadFrameButtonText" , "OVERLAY" , "GameFontWhiteTiny");
GRM_AddEventLoadFrameButton:Hide();

-- CORE GUILD LOG EVENT FRAME!!!
local GRM_RosterChangeLogFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogFrame" , UIParent , "BasicFrameTemplate" );
GRM_RosterChangeLogFrame:Hide();
local GRM_RosterChangeLogFrameTitleText = GRM_RosterChangeLogFrame:CreateFontString ( "GRM_RosterChangeLogFrameTitleText" , "OVERLAY" , "GameFontNormal" );
-- CHECKBOX FRAME
local GRM_RosterCheckBoxSideFrame = CreateFrame ( "Frame" , "GRM_RosterCheckBoxSideFrame" , GRM_RosterChangeLogFrame , "TranslucentFrameTemplate" );
-- CHECKBOXES
local GRM_RosterPromotionChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterPromotionChangeCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterPromotionChangeCheckButtonText = GRM_RosterPromotionChangeCheckButton:CreateFontString ( "GRM_RosterPromotionChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterDemotionChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterDemotionChangeCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterDemotionChangeCheckButtonText = GRM_RosterDemotionChangeCheckButton:CreateFontString ( "GRM_RosterDemotionChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterLeveledChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeveledChangeCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterLeveledChangeCheckButtonText = GRM_RosterLeveledChangeCheckButton:CreateFontString ( "GRM_RosterLeveledChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterNoteChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNoteChangeCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterNoteChangeCheckButtonText = GRM_RosterNoteChangeCheckButton:CreateFontString ( "GRM_RosterNoteChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterOfficerNoteChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterOfficerNoteChangeCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterOfficerNoteChangeCheckButtonText = GRM_RosterOfficerNoteChangeCheckButton:CreateFontString ( "GRM_RosterOfficerNoteChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterJoinedCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterJoinedCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterJoinedCheckButtonText = GRM_RosterJoinedCheckButton:CreateFontString ( "GRM_RosterJoinedCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterLeftGuildCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeftGuildCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterLeftGuildCheckButtonText = GRM_RosterLeftGuildCheckButton:CreateFontString ( "GRM_RosterLeftGuildCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterInactiveReturnCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterInactiveReturnCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterInactiveReturnCheckButtonText = GRM_RosterInactiveReturnCheckButton:CreateFontString ( "GRM_RosterInactiveReturnCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterNameChangeCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNameChangeCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterNameChangeCheckButtonText = GRM_RosterNameChangeCheckButton:CreateFontString ( "GRM_RosterNameChangeCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterEventCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterEventCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterEventCheckButtonText = GRM_RosterEventCheckButton:CreateFontString ( "GRM_RosterEventCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterShowAtLogonCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterShowAtLogonCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterShowAtLogonCheckButtonText = GRM_RosterShowAtLogonCheckButton:CreateFontString ( "GRM_RosterShowAtLogonCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterRankRenameCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRankRenameCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterRankRenameCheckButtonText = GRM_RosterRankRenameCheckButton:CreateFontString ( "GRM_RosterRankRenameCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterRecommendationsButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendationsButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterRecommendationsButtonText = GRM_RosterRecommendationsButton:CreateFontString ( "GRM_RosterRecommendationsButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterBannedPlayersButton = CreateFrame ( "CheckButton" , "GRM_RosterBannedPlayersButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterBannedPlayersButtonText = GRM_RosterBannedPlayersButton:CreateFontString ( "GRM_RosterBannedPlayersButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- CHAT BOX CONFIRM CHECKBOXES
GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterJoinedChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeveledChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterInactiveReturnChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterPromotionChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterDemotionChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNoteChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterOfficerNoteChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNameChangeChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRankRenameChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterEventChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLeftGuildChatCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendationsChatButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton = CreateFrame ( "CheckButton" , "GRM_RosterBannedPlayersButtonChatButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
-- Fontstrings for side frame
GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText = GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_TitleSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText = GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_ShowOnLogSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText = GRM_RosterCheckBoxSideFrame:CreateFontString ( "GRM_ShowOnChatSideFrameText" , "OVERLAY" , "GameFontNormalSmall" );

-- SCROLL FRAME
local GRM_RosterChangeLogScrollFrame = CreateFrame ( "ScrollFrame" , "GRM_RosterChangeLogScrollFrame" , GRM_RosterChangeLogFrame );
local GRM_RosterChangeLogScrollBorderFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogScrollBorderFrame" , GRM_RosterChangeLogFrame , "TranslucentFrameTemplate" );
-- CONTENT FRAME (Child Frame)
local GRM_RosterChangeLogScrollChildFrame = CreateFrame ( "Frame" , "GRM_RosterChangeLogScrollChildFrame" );
-- SLIDER
local GRM_RosterChangeLogScrollFrameSlider = CreateFrame ( "Slider" , "GRM_RosterChangeLogScrollFrameSlider" , GRM_RosterChangeLogScrollFrame , "UIPanelScrollBarTemplate" );
-- BUTTONS
local GRM_LoadLogButton = CreateFrame( "Button" , "GRM_LoadLogButton" , GuildRosterFrame , "UIPanelButtonTemplate" );
GRM_LoadLogButton:Hide();
local GRM_LoadLogButtonText = GRM_LoadLogButton:CreateFontString ( "GRM_LoadLogButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- OPTIONS PANEL BUTTONS ( in the Roster Log Frame)
-- CORE ADDON OPTIONS CONTROLS LISTED HERE!
local GRM_RosterOptionsButton = CreateFrame ( "Button" , "GRM_RosterOptionsButton" , GRM_RosterChangeLogFrame , "UIPanelButtonTemplate" );
local GRM_RosterOptionsButtonText = GRM_RosterOptionsButton:CreateFontString ( "GRM_RosterOptionsButtonText" , "OVERLAY" , "GameFontWhiteTiny");
local GRM_RosterClearLogButton = CreateFrame( "Button" , "GRM_RosterClearLogButton" , GRM_RosterCheckBoxSideFrame , "UIPanelButtonTemplate" );
local GRM_RosterClearLogButtonText = GRM_RosterClearLogButton:CreateFontString ( "GRM_RosterClearLogButtonText" , "OVERLAY" , "GameFontWhiteTiny");
-- Options Panel Checkboxes
local GRM_RosterLoadOnLogonCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterLoadOnLogonCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterLoadOnLogonCheckButtonText = GRM_RosterLoadOnLogonCheckButton:CreateFontString ( "GRM_RosterLoadOnLogonCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GRM_RosterAddTimestampCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterAddTimestampCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
local GRM_RosterAddTimestampCheckButtonText = GRM_RosterAddTimestampCheckButton:CreateFontString ( "GRM_RosterAddTimestampCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Kick Recommendation Options
GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterRecommendKickCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText = GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:CreateFontString ( "GRM_RosterRecommendKickCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2 = GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:CreateFontString ( "GRM_RosterRecommendKickCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox = CreateFrame( "EditBox" , "GRM_RosterKickRecommendEditBox" , GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton );
GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote = CreateFrame ( "Frame" , "GRM_RosterKickOverlayNote" , GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton );
GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText = GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:CreateFontString ( "GRM_RosterKickOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Report Inactive Options
GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton = CreateFrame ( "CheckButton" , "GRM_RosterReportInactiveReturnButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText = GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:CreateFontString ( "GRM_RosterReportInactiveReturnButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2 = GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:CreateFontString ( "GRM_RosterReportInactiveReturnButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox = CreateFrame( "EditBox" , "GRM_ReportInactiveReturnEditBox" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton );
GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote = CreateFrame ( "Frame" , "GRM_ReportInactiveReturnOverlayNote" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton );
GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText = GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:CreateFontString ( "GRM_ReportInactiveReturnOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
-- Report Upcoming Events
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterReportUpcomingEventsCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText = GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportUpcomingEventsCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2 = GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportUpcomingEventsCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox = CreateFrame( "EditBox" , "GRM_RosterReportUpcomingEventsEditBox" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote = CreateFrame ( "Frame" , "GRM_RosterReportUpcomingEventsOverlayNote" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText = GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:CreateFontString ( "GRM_RosterReportUpcomingEventsOverlayNoteText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton = CreateFrame ( "CheckButton" , "GRM_RosterReportAddEventsToCalendarButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText = GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:CreateFontString ( "GRM_RosterReportAddEventsToCalendarButtonText" , "OVERLAY" , "GameFontNormalSmall" );
-- Share changes with ONLINE guildies
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterSyncCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2 = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText2" , "OVERLAY" , "GameFontNormalSmall" );
GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton = CreateFrame ( "CheckButton" , "GRM_RosterNotifyOnChangesCheckButton" , GRM_RosterCheckBoxSideFrame , "OptionsSmallCheckButtonTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText = GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:CreateFontString ( "GRM_RosterSyncCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );

-- Options RankDropDown
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected = CreateFrame ( "Frame" , "GRM_RosterSyncRankDropDownSelected" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , "InsetFrameTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:CreateFontString ( "GRM_RosterSyncRankDropDownSelectedText" , "OVERLAY" , "GameFontWhiteTiny" );
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu = CreateFrame ( "Frame" , "GRM_RosterSyncRankDropDownMenu" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "InsetFrameTemplate" );
GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton = CreateFrame ( "Button" , "GRM_RosterSyncRankDropDownMenuButton" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "UIPanelScrollDownButtonTemplate" );

-- Guild Event Log Frame Confirm Details.
local GRM_RosterConfirmFrame = CreateFrame ( "Frame" , "GRM_RosterConfirmFrame" , UIPanel , "BasicFrameTemplate" );
local GRM_RosterConfirmFrameText = GRM_RosterConfirmFrame:CreateFontString ( "GRM_RosterConfirmFrameText" , "OVERLAY" , "GameFontWhiteTiny");
local GRM_RosterConfirmYesButton = CreateFrame ( "Button" , "GRM_RosterConfirmYesButton" , GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
local GRM_RosterConfirmYesButtonText = GRM_RosterConfirmYesButton:CreateFontString ( "GRM_RosterConfirmYesButtonText" , "OVERLAY" , "GameFontWhiteTiny");
local GRM_RosterConfirmCancelButton = CreateFrame ( "Button" , "GRM_RosterConfirmCancelButton" , GRM_RosterConfirmFrame , "UIPanelButtonTemplate" );
local GRM_RosterConfirmCancelButtonText = GRM_RosterConfirmCancelButton:CreateFontString ( "GRM_RosterConfirmCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny");

-- MISC FRAMES
UI_Events.GRM_NumGuildiesText = UI_Events:CreateFontString ( "GRM_NumGuildiesText" , "OVERLAY" , "GameFontNormalSmall" );

--------------------------
--- FUNCTIONS ------------
--------------------------


-- Method:          GRM.ClearPermData()
-- What it Does:    Resets all the saved data back to nothing... and does not rebuid it.
-- Purpose:         Mainly for use if ever there is a need to purge the data, in beta, without rebuilding the roster.
GRM.ClearPermData = function()
    -- SPECIAL NOTE (if ever needed);

    GRM_GuildMemberHistory_Save = nil;
    GRM_GuildMemberHistory_Save = {};
    table.insert ( GRM_GuildMemberHistory_Save , { "Horde" } );
    table.insert ( GRM_GuildMemberHistory_Save , { "Alliance" } );

    GRM_PlayersThatLeftHistory_Save = nil;
    GRM_PlayersThatLeftHistory_Save = {};
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Horde" } );
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Alliance" } );

    GRM_LogReport_Save = nil;
    GRM_LogReport_Save = {};
    table.insert ( GRM_LogReport_Save , { "Horde" } );
    table.insert ( GRM_LogReport_Save , { "Alliance" } );

    GRM_CalendarAddQue_Save = nil;
    GRM_CalendarAddQue_Save = {};
    table.insert ( GRM_CalendarAddQue_Save , { "Horde" } );
    table.insert ( GRM_CalendarAddQue_Save , { "Alliance" } );
    
    GRM_AddonSettings_Save = nil;
    GRM_AddonSettings_Save = {};
    table.insert ( GRM_AddonSettings_Save , { "Horde" } );
    table.insert ( GRM_AddonSettings_Save , { "Alliance" } );
    
end

-- Method:          GRM.LoadSettings()
-- What it Does:    On first time loading addon, it builds default addon settings. It checks for addon version change
--                  And, if there are any changes, they will be added into that logic block. 
--                  And new setting can be tagged on.
-- Purpose:         Saving settings between gaming sessions. Also, this is built to provide backwards compatibility for future flexibility on feature adding, if necessary.
GRM.LoadSettings = function()
    -- Build the settings
    -- First, determine if addon settings have ever been initialized.
    if GRM_AddonSettings_Save[1] == nil then
        GRM.ClearPermData();                        -- This will purge the old data and then it needs to be built and reinitialized.
    end

    -- Find the player
    local isFound = false;
    local indexFound = 0;
    for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
            isFound = true;
            indexFound = i;
        end
    end

    -- Build settings for first time.
    if not isFound then
         -- Add new player
        table.insert ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID] , { GRM_AddonGlobals.addonPlayerName } );
        print ( "\nConfiguring Guild Roster Manager for " .. GetUnitName ( "PLAYER" , false ) .. " for the first time." );

        local AllDefaultSettings = {

            Version,                                                                                                -- 1)  Version
            true,                                                                                                   -- 2)  View on Load
            { true , true , true , true , true , true , true , true , true , true , true , true , true },           -- 3)  All buttons are checked in the log window (13 so far)
            336,                                                                                                    -- 4)  Report inactive return of player coming back (2 weeks is default value)
            14,                                                                                                     -- 5)  Event Announce in Advance - Cannot be higher than 4 weeks ( 28 days ) ( 1 week is default);
            10,                                                                                                     -- 6)  How often to check for changes ( in seconds )
            true,                                                                                                   -- 7)  Add Timestamp on join to Officer Note
            true,                                                                                                   -- 8)  Use Calendar Announcements
            12,                                                                                                     -- 9)  Months Player Has Been Offline to Add Announcement To Kick
            false,                                                                                                  -- 10) Recommendations!
            true,                                                                                                   -- 11) Report Inactive Returns
            true,                                                                                                   -- 12) Announce Upcoming Events.
            { true , true , true , true , true , true , true , true , true , true , true , true , true },           -- 13) Checkbox for message frame announcing. Disable 
            true,                                                                                                   -- 14) Allow Data sharing between guildies
            1,                                                                                                      -- 15) Rank Player must be to accept sync updates from them.
            true,                                                                                                   -- 16) Receive Notifications if others in the guild send updates!
            
            true,                                                                                                   -- 17) MISC TO BE USED IN THE FUTURE IF NEEDED
            true,                                                                                                   -- 18) ''
            true,                                                                                                   -- 19) ''
            true,                                                                                                   -- 20) ''
            true,                                                                                                   -- 21) ''
            0,                                                                                                      -- 22) ''
            0,                                                                                                      -- 23) ''
            0,                                                                                                      -- 24) ''
            0,                                                                                                      -- 25) ''
            0                                                                                                       -- 26) ''

        };
       
        -- Unique Settings added to the player.
        table.insert ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][ #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] ] , AllDefaultSettings );

    elseif GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] ~= Version then
        -- Table that will have all of the release patch names.
        local ListOfReleasePatches = { "7.2.5r1.00" , "7.2.5r1.01" } ;
            
        -------------------------------
        --- START PATCH FIXES ---------
        -------------------------------



        -------------------------------
        -- END OF PATCH FIXES ---------
        -------------------------------

        -- Ok, let's update the version!
        print ( GRM_AddonGlobals.addonName .. " v" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] .. " has been Updated to v" .. Version );

        -- Updating the version for ALL saved accoutns.
        for i = 1 , #GRM_AddonSettings_Save do
            for j = 2 , #GRM_AddonSettings_Save[i] do
                GRM_AddonSettings_Save[i][j][2][1] = Version;      -- Changing version for all indexes.
            end
        end
    end    
end

-- Method:          VersionCheck ( string )
-- What it Does:    Checks player version compared to another player's and recommends updating your version if needed
-- Purpose:         Encourage the player to keep their addon up to date!
GRM.VersionCheck = function( msg )
    -- parse the message
    local version = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local time = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    -- If the versions are not equal and the received data is larger (more recent) than player's time, player should receive reminder to update!
    if version ~= Version then
        if not GRM_AddonGlobals.VersionChecked and time > PatchDay then
            -- Let's report the need to update to the player!
            chat:AddMessage ( "|cff00c8ffGRM: |cffffffffA new version of Guild Roster Manager is Available! |cffff0044Please Upgrade!");
            -- No need to send comm because he has the update, not you!

        elseif time < PatchDay then
            -- Your version is more up to date! Send comms out!
            SendAddonMessage ( "GRMVER" , Version .. "?" .. tostring ( PatchDay ) , "GUILD" ); -- Remember, patch day is an int in epoch time, so needs to be converted to string for comms
        end
    end
end

-- Method:          GRM.RegisterVersionCheck()
-- What it Does:    Registers the logic for comm talk between addon users to do a version check.
-- Purpose:         Version checking! Encourages the player to upgrade their addon if it is outdated!
GRM.RegisterVersionCheck = function()
    -- Registering comm prefix, establishing event monitoring for comm activity across guild channel.
    RegisterAddonMessagePrefix ( "GRMVER" );
    VersionCheck:RegisterEvent ( "CHAT_MSG_ADDON" );
    -- Register used prefixes!

    -- Setup tracking actions
    VersionCheck:SetScript ( "OnEvent" , function( self , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and prefix == "GRMVER" and channel == "GUILD" then
            -- sender = GRMsync.SyncName ( sender , "enGB" ) -- This will eventually be localized
                -- Gotta filter my own messages out too!
            if sender ~= GRM_AddonGlobals.addonPlayerName then

                -- Just to ensure it only does a check one time from each player with the addon installed.
                local isFound = false;
                for i = 1 , #GRM_AddonGlobals.VersionCheckedNames do
                    if GRM_AddonGlobals.VersionCheckedNames[i] == sender then
                        isFound = true;
                        break;
                    end
                end

                -- Player has never commed on version with you. Add their name, then do a version check!
                if not isFound then
                    table.insert ( GRM_AddonGlobals.VersionCheckedNames , sender );
                    GRM.VersionCheck ( msg );
                end
            end
        end
    end);
end


-- Method:          GRM.SlimName(string)
-- What it Does:    Removes the server name after character name.
-- Purpose:         Server name is not important in a guild since all will be server name.
GRM.SlimName = function( name )
    if string.find ( name , "-" , 1 ) ~= nil then
        return string.sub ( name , 1 , string.find ( name ,"-" ) - 1 );
    else
        return name;
    end
end

-- Method:          GRM.ParseClass(string) 
-- DEPRECATED for now as a result of custom UI being built
-- What it Does:    Takes a line of text from GuildMemberDetailFrame and parses out the Class
-- Purpose:         While a call can be made to the server after parsing the index number in a built-in API lookup, that is resource hungry.
--                  Since the server has already pulled the info in text form, this saves a lot of resources from querying the server for player class.
GRM.ParseClass = function( class )
    local result = "";
    local numFound = false;
    for i = 1 , #class do
        if numFound ~= true then
            if tonumber ( string.sub ( class , i , i ) ) ~= nil then
                -- NUM FOUND!
                numFound = true;
            end
        else
            if tonumber ( string.sub ( class , i , i ) ) == nil then   -- I am at the space after the player level ends
                result = string.sub ( class , i + 1 );
                break;  
            end
        end
    end
    return result;
end

-- Method:          GRM.ParseLevel(string)
-- DEPRECATED for now...
-- What it Does:    Takes the same text line from GuildMemberDetailFrame and parses out the Level
-- Purpose:         To obtain a player's level one needs to query the server. Since the string is already available, this just grabs the string simply.
GRM.ParseLevel = function ( level )
    local result = "";
    local numFound = false;
    local startIndex = 1;

    for i = 1, #level do
        if numFound ~= true then
            if tonumber ( string.sub ( level , i , i ) ) ~= nil then
                -- Num Found!
                numFound = true;
                startIndex = i;
            end
        else
            if tonumber ( string.sub ( level , i , i ) ) == nil then
                result = string.sub ( level , startIndex , i - 1 );
                break;
            end
        end
    end
    return result;
end

-- Method           GRM.Trim ( string )
-- What it Does:    Removes the white space at front and at tail of string.
-- Purpose:         Cleanup strings for ease of logic control, as needed.
GRM.Trim = function ( str )
    return ( str:gsub ( "^%s*(.-)%s*$" , "%1" ) );
end

-- Method:          GRM.GetNumGuildies()
-- What it Does:    Returns the int number of total toons within the guild, including main/alts
-- Purpose:         For book-keeping and tracking total guild membership.
--                  Overall, this is mostly redundant as a simple GetNumGuildMembers() call is the same thing, however, this is just a tech Demo
--                  as a coding example of how to pull info and return it in your own function.
--                  A simple "GetNumGuildMembers()" would result in the same result in less steps. This is just more explicit to keep it within the style of the functions of the addon.
GRM.GetNumGuildies = function()
    return GetNumGuildMembers();
end

-- Method:          GRM.ResetTempLogs()
-- What it Does:    Empties the arrays of the reporting logs
-- Purpose:         Logs are used to build changes in the guild and then to cleanly report them in order.
GRM.ResetTempLogs = function()
    GRM_AddonGlobals.TempNewMember = {};
    GRM_AddonGlobals.TempInactiveReturnedLog = {};
    GRM_AddonGlobals.TempLogPromotion = {};
    GRM_AddonGlobals.TempLogDemotion = {};
    GRM_AddonGlobals.TempLogLeveled = {};
    GRM_AddonGlobals.TempLogNote = {};
    GRM_AddonGlobals.TempLogONote = {};
    GRM_AddonGlobals.TempRankRename = {};
    GRM_AddonGlobals.TempRejoin = {};
    GRM_AddonGlobals.TempBannedRejoin = {};
    GRM_AddonGlobals.TempLeftGuild = {};
    GRM_AddonGlobals.TempNameChanged = {};
    GRM_AddonGlobals.TempEventReport = {};
    GRM_AddonGlobals.TempEventRecommendKickReport = {};
end

-- Method:          GRM.ModifyCustomNote(string,string)
-- What it Does:    Adds a new note to the custom notes string
-- Purpose:         For expanded information on players to create in-game notes or tracking.
GRM.ModifyCustomNote = function ( newNote , playerName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                       -- Scanning through guild Roster
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then       -- Player Found
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][23] = newNote;             -- Storing new note.
            break;
        end
    end
end

------------------------------------
------ TIME TRACKING TOOLS ---------
--- TIMESTAMPS , TIMEPASSED, ETC. --
------------------------------------

-- Useful Lookup Tables for date indexing.
local monthEnum = { Jan = 1 , Feb = 2 , Mar = 3 , Apr = 4 , May = 5 , Jun = 6 , Jul = 7 , Aug = 8 , Sep = 9 , Oct = 10 , Nov = 11 , Dec = 12 };
local monthsFullnameEnum = { January = 1 , February = 2 , March = 3 , April = 4 , May = 5 , June = 6 , July = 7 , August = 8 , September = 9 , October = 10 , November = 11 , December = 12 };
local daysBeforeMonthEnum = { ['1']=0 , ['2']=31 , ['3']=31+28 , ['4']=31+28+31 , ['5']=31+28+31+30 , ['6']=31+28+31+30+31 , ['7']=31+28+31+30+31+30 , 
                                ['8']=31+28+31+30+31+30+31 , ['9']=31+28+31+30+31+30+31+31 , ['10']=31+28+31+30+31+30+31+31+30 ,['11']=31+28+31+30+31+30+31+31+30+31, ['12']=31+28+31+30+31+30+31+31+30+31+30 };
local daysInMonth = { ['1']=31 , ['2']=28 , ['3']=31 , ['4']=30 , ['5']=31 , ['6']=30 , ['7']=31 , ['8']=31 , ['9']=30 , ['10']=31 , ['11']=30 , ['12']=31 };

-- Method:          GRM.IsLeapYear(int)
-- What it Does:    Returns true if the given year is a leapYear
-- Purpose:         For this addon, the calendar date selection, allows it to know to produce 29 days on leap year.
GRM.IsLeapYear = function ( yearDate )
    if ( ( ( yearDate % 4 == 0 ) and ( yearDate % 100 ~= 0 ) ) or ( yearDate % 400 == 0 ) ) then
        return true;
    else
        return false;
    end
end

-- Method:          GRM.GetHoursSinceLastOnline(int)
-- What it Does:    Returns the total numbner of hours since the player last logged in at given index position of guild roster
-- Purpose:         For player management to notify addon user of too much time has passed, for recommendation to kick,
GRM.GetHoursSinceLastOnline = function ( index )
    local years , months, days, hours = GetGuildRosterLastOnline ( index );
    if years == nil then
        years = 0;
    end
    if months == nil then
        months = 0;
    end
    if days == nil then
        days = 0;
    end
    if hours == nil then
        hours = 0;
    end
    if ( years == 0 ) and ( months == 0 ) and ( days == 0 ) and ( hours == 0) then
        hours = 0.5;    -- This can be any value less than 1, but must be between 0 and 1, to just make the point that total number of hrs since last login is < 1
    end
    local totalHours = math.floor ( ( years * 8766 ) + ( months * 730.5 ) + ( days * 24 ) + hours );
    return totalHours;
end

-- Method:          GRM.IsValidSubmitDate ( int , int , boolean )
-- What it Does:    Returns true if the submission date is valid (not an untrue day or in the future)
-- Purpose:         Check to ensure the wrong date is not submitted on accident.
GRM.IsValidSubmitDate = function ( daySelected , monthSelected , yearSelected , IsLeapYearSelected )
    local closeButtons = true;
    local _ , month , day , year = CalendarGetDate()
    local numDays;

    if monthSelected == 1 or monthSelected == 3 or monthSelected == 5 or monthSelected == 7 or monthSelected == 8 or monthSelected == 10 or monthSelected == 12 then
        numDays = 31;
    elseif monthSelected == 2 and IsLeapYearSelected then
        numDays = 29;
    elseif monthSelected == 2 then
        numDays = 28;
    else
        numDays = 30;
    end
    if daySelected > numDays then
        closeButtons = false;
    end
    
    if closeButtons then
        if ( year < yearSelected ) or ( year == yearSelected and month < monthSelected ) or ( year == yearSelected and month == monthSelected and day < daySelected ) then
            print ( "Player Does Not Have a Time Machine!" );
            closeButtons = false;
        end
    end

    if closeButtons == false then
        print ( "Please choose a valid DAY" );
    end
    return closeButtons;
end

-- Method:          GRM.TimeStampToEpoch(timestamp)
-- What it Does:    Converts a given timestamp: "22 Mar '17" into Epoch Seconds time.
-- Purpose:         On adding notes, epoch time is considered when calculating how much time has passed, for exactness and custom dates need to include it.
GRM.TimeStampToEpoch = function ( timestamp )
    -- Parsing Timestamp to useful data.
    local year = tonumber ( string.sub ( timestamp , string.find ( timestamp , "'" )  + 1 ) ) + 2000;
    local leapYear = GRM.IsLeapYear ( year );
    -- Find second index of spaces
    local count = 0;
    local index = 0;
    local dayInd = -1;
    for i = 1 , #timestamp do
        if string.sub( timestamp , i , i ) == " " then
            count = count + 1;
        end
        if count == 1 and dayInd == -1 then
            dayInd = i;
        end
        if count == 2 then
            index = i;
            break;
        end
    end
    local month = monthEnum [ string.sub ( timestamp , index + 1 , index + 3) ];
    local day = tonumber ( string.sub ( timestamp , dayInd + 1 , index - 1 ) );

    -- End timestamp Parsing... 
    local hour , minute = GetGameTime();
    local tempTime = date ( '*t' );
    local seconds = tempTime.sec;

    -- calculate the number of seconds passed since 1970 based on number of years that have passed.
    local totalSeconds = 0;
    for i = year - 1 , 1970 , -1 do
        if GRM.IsLeapYear ( i ) then
            totalSeconds = totalSeconds + ( 366 * 24 * 3600 ); -- leap year = 366 days
        else
            totalSeconds = totalSeconds + ( 365 * 24 * 3600 ); -- 365 days in normal year
        end
    end
    
    -- Now lets calculate how much time this year...
    local monthDays = daysBeforeMonthEnum [ tostring ( month ) ];
    if month > 2 and leapYear then -- Adding 1 for the leap year
        monthDays = monthDays + 1;
    end
    -- adding month days so far this year to result so far.
    totalSeconds = totalSeconds + ( monthDays * 24 * 3600);

    -- The rest is easy... as of now, I will not import hours/minutes/seconds, but I will leave the calculations in place in case need arises.
    totalSeconds = totalSeconds + ( ( day - 1 ) * 24 * 3600 );  -- days
    totalSeconds = totalSeconds + ( hour * 3600 );
    totalSeconds = totalSeconds + ( minute * 60 );
    totalSeconds = totalSeconds + seconds;
    
    return totalSeconds;
end


-- Method:          GRM.GetTimestamp()
-- What it Does:    Reports the current moment in time in a much more clear, concise, pretty way. Example: "9 Feb '17 1:36pm" instead of 09/02/2017/13:36
-- Purpose:         Just for cleaner presentation of the results. Also, need to report based on server time. In-game API only returns hour/min, not month and day. This resolves that.
GRM.GetTimestamp = function()
    -- Time Variables
    local morning = true;
    local months = { "Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" , "Oct" , "Nov" , "Dec" };
    local hour, minutes = GetGameTime();
    local weekday, month, day, year = CalendarGetDate();
    local stampMonth = months [ month ];

    -- Formatting...
    if minutes < 10 then
        minutes = ( "0" .. minutes ); -- Example, if it was 6:09, the minutes would only be "9" not "09" - so this looks better.
    end
     -- Swap from military time
    if hour > 12 then
        hour = hour - 12;
        morning = false;
    elseif hour == 12 then
        morning = false;
    elseif hour == 0 then
        hour = 12;
    end

    year = tostring ( year );
    year = string.sub ( year , 3 );
   
    -- Establishing proper format
    local time = ( day .. " " .. stampMonth .. " '" .. year .. " " .. hour .. ":" .. minutes );
    if morning then
        time =  ( time .. "am" );
    else
        time =  ( time .. "pm" );
    end
    return time;
end

-- Method:          GRM.GetTimePassed ( oldTimestamp )
-- What it Does:    Reports back the elapsed, in English, since the previous given timestamp, based on the 1970 seconds count.
-- Purpose:         Time tracking to keep track of elapsed time since previous action.
GRM.GetTimePassed = function ( oldTimestamp )

    -- Need to consider Leap year, but for now, no biggie. 24hr differentiation only in 4 years.
    local totalSeconds = time() - oldTimestamp;
    local year = math.floor ( totalSeconds / 31536000 ); -- seconds in a year
    local yearTag = "year";
    local month = math.floor ( ( totalSeconds % 31536000 ) / 2592000 ); -- etc. 
    local monthTag = "month";
    local days = math.floor ( ( totalSeconds % 2592000) / 86400 );
    local dayTag = "day";
    local hours = math.floor ( ( totalSeconds % 86400 ) / 3600 );
    local hoursTag = "hour";
    local minutes = math.floor ( ( totalSeconds % 3600 ) / 60 );
    local minutesTag = "minute";
    local seconds = math.floor ( ( totalSeconds % 60) );
    local secondsTag = "second";
    
    local timestamp = "";
    if year > 1 then
        yearTag = "years";
    end
    if month > 1 then
        monthTag = "months";
    end
    if days > 1 then
        dayTag = "days";
    end
    if hours > 1 then
        hoursTag = "hours";
    end
    if minutes > 1 then
        minutesTag = "minutes";
    end
    if seconds > 1 then
        secondsTag = "seconds";
    end

    if year > 0 or month > 0 or days > 0 then
        if year > 0 then
            timestamp = ( year .. " " .. yearTag );
        end
        if month > 0 then
            timestamp = ( timestamp .. " " .. month .. " " .. monthTag );
        end
        if days > 0 then
            timestamp = ( timestamp .. " " .. days .. " " .. dayTag );
        else
            timestamp = ( timestamp .. " " .. days .. " " .. "days" ); -- exception to put zero days since it seems smoother, aesthetically.
        end
    else
        if hours > 0 or minutes > 0 then
            if hours > 0 then
                timestamp = ( timestamp .. " " .. hours .. " " .. hoursTag );
            end
            if minutes > 0 then
                timestamp = ( timestamp .. " " .. minutes .. " " .. minutesTag );
            end
        else
            timestamp = ( seconds .. " " .. secondsTag );
        end
    end
    
    return timestamp;
end

-- Method:          GRM.GetTimePassedUsingStringStamp()
-- What it Does:    Returns the Years, hours, and days that have passed since the given timestamp ( In format "day mon 'year")
-- Purpose:         Honestly, simpler solution than build a solution to parse through epoch time, since I don't need hours, minutes, seconds.
GRM.GetTimePassedUsingStringStamp = function ( timestamp )
    local startYear = tonumber ( string.sub ( timestamp , string.find ( timestamp , "'" )  + 1 ) ) + 2000;
    local index = string.find ( timestamp , " " );
    local monthName = string.sub ( timestamp , index + 1 , index + 3 );
    local startMonth = monthEnum [ monthName ];
    local startDay = tonumber ( string.sub ( timestamp , 0 , index - 1 ) );
    local _ , month , day , year = CalendarGetDate();
    local LeapYear = GRM.IsLeapYear ( year );
    local result = { 0 , 0 , 0 , "" };           -- resultYear, resultMonth , resultDay;
    -- Narrow down the year!
    if year > startYear then                -- If this event happened in a previous year.
        result[1] = year - startYear;
        if month < startMonth then          -- Event is less than a year!
            result[1] = result[1] - 1;
        elseif month == startMonth then
            -- Need to check the day!
            if day < startDay then
                result[1] = result[1] - 1;
            else
                result[1] = year - startYear;   -- If >= then it counts as 1 year.
            end
        else                                -- month > start meaning it's been a year.
            result[1] = year - startYear;
        end
    else
        result[1] = 0;
    end

    -- Ok, now let's get the month! Much easier!
    if month < startMonth then
        result[2] = month + ( 12 - startMonth );
        if day < startDay then          -- Not quite 1 month
            result[2] = result[2] - 1;
        end
    elseif month == startMonth then
        if startYear == year then
            result[2] = 0;
        else
            if day < startDay then
                result[2] = 11;
            else
                result[2] = 0;
            end
        end
    else                        -- month > start 
        if day < startDay then
            result[2] = ( month - startMonth ) - 1;
        else
            result[2] = month - startMonth;
        end
    end

    -- Finally, let's do the day!
    if day < startDay then
        -- Gonna have to take leap year into account now!
        local tempMonth = month;
        if tempMonth == 12 then
            tempMonth = 1;
        end
        result[3] = day + ( daysInMonth [ tostring ( tempMonth ) ] - startDay );
        if LeapYear then
            result[3] = result[3] + 1;
        end
    else
        result[3] = day - startDay;
    end

    --Final text report
    if result[1] > 0 then
        if result[1] == 1 then
            result[4] = result[1] .. " year ";
        else
            result[4] =  result[1] .. " years ";
        end
    end
    if result[2] > 0 then
        if result[2] == 1 then
            result[4] = result[4] .. "" .. result[2] .. " month ";
        else
            result[4] = result[4] .. "" .. result[2] .. " months ";
        end
    end
    if result[3] > 0 then
        if result[3] == 1 then
            result[4] = result[4] .. "" .. result[3] .. " day";
        else
            result[4] = result[4] .. "" .. result[3] .. " days";
        end
    end
    -- Clear off any white space.
    if result[1] == 0 and result[2] == 0 and result[3] == 0 then
        result[4] = "< 1 day";
    else
        result[4] = GRM.Trim ( result[4] );
    end
    return result;
end

-- Method:          GRM.HoursReport(int)
-- What it Does:    Reports as a string the time passed since player last logged on.
-- Purpose:         Cleaner reporting to the log, and it just reports the lesser info, no seconds and so on.
GRM.HoursReport = function ( hours )
    local result = "";
    local years = math.floor ( hours / 8766 );
    local months = math.floor ( ( hours % 8766 ) / 730.5 );
    local days = math.floor ( ( hours % 730.5 ) / 24 );

    -- Continue calculations.
    local hours = math.floor ( ( ( hours % 8760 ) % 730 ) % 24 );
    
    
    if years >= 1 then
        if years > 1 then
            result = result .. "" .. years .. " yrs ";
        else
            result = result .. "" .. years .. " yr ";
        end
    end

    if months >= 1 then
        if years > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if months > 1 then
            result = result .. "" .. months .. " mos ";
        else
            result = result .. "" .. months .. " mo ";
        end
    end

    if days >= 1 then
        if months > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if days > 1 then
            result = result .. "" .. days .. " days ";
        else
            result = result .. "" .. days .. " day ";
        end
    end

    if hours >= 1 and years < 1 and months < 1 then  -- No need to give exact hours on anything over than a month, just the day is good enough.
        if days > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if hours > 1 then
            result = result .. "" .. hours .. " hrs";
        else
            result = result .. "" .. hours .. " hr";
        end
    end

    if result == "" or result == nil then
        result = result .. "< 1 hour"
    end
    return result;
end

------------------------------------
------ END OF TIME METHODS ---------
------------------------------------


------------------------------------
---- ALT MANAGEMENT METHODS --------
------------------------------------

-- Method:          GRM.GetMouseOverName()
-- What it Does:    Returns the full player's name with server on mouseover
-- Purpose:         Name needed to check metadata to populate UI window.
GRM.GetMouseOverName = function( button )
    -- This disables the annoying mouseover sound.
    local isSoundEnabled = ( GetCVar ( "Sound_EnableAllSound") == "1" );
    SetCVar ( "Sound_EnableAllSound" , false );
    button:Click();
    -- button:UnlockHighlight();
    SetCVar ( "Sound_EnableAllSound" , isSoundEnabled );

    local name = GuildMemberDetailName:GetText();
    local MobileIconCheck = "\"" .. name .. "\"";
    local length = 84;

    if #MobileIconCheck > 50 then
        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
            length = 85
        end
        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
    end
    return name;
end

-- Method:          GRM.GetMobileFreeName()
-- What it Does:    Returns the cleared name properly as if player is on mobile the string will not pass through data right.
-- Purpose:         String name has an icon attached. This resolves that.
GRM.GetMobileFreeName = function ( name )
    local MobileIconCheck = "\"" .. name .. "\"";
    local length = 84;

    if #MobileIconCheck > 50 then
        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
            length = 85
        end
        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
    end
    return name;
end

-- Method:          GRM.AltButtonPos(int)
-- What it Does:    Returns the horizontal and vertical coordinates for the button position on frame
-- Purpose:         To adjust the position of the AddAlt button based on the number of alts.
GRM.AltButtonPos = function ( index )
    local result;
    if index == 0 then
        result = { 2 , -16 };
    elseif index == 1 then
        result = { 32 , -20 };
    elseif index == 2 then
        result = { -32 , -37 };
    elseif index == 3 then
        result = { 32 , -37 };
    elseif index == 4 then
        result = { -32 , -54 };
    elseif index == 5 then
        result = { 32 , -54 };
    elseif index == 6 then
        result = { -32 , -71 };
    elseif index == 7 then
        result = { 32 , -71 };
    elseif index == 8 then
        result = { -32 , -88 };
    elseif index == 9 then
        result = { 32 , -88 };
    elseif index == 10 then
        result = { -32 , -103 };
    elseif index == 11 then
        result = { 32 , -103 };
    else -- is 12+ alts
        result = { -64 , -124 };
    end
    return result;
end

-- Method:          GRM.PopulateAltFrames(string, int , int )
-- What it Does:    This generates the alt frames in the main addon metadata detail frame
-- Purpose:         Clean formatting of the alt frames.
GRM.PopulateAltFrames = function ( index1 )
    -- let's start by prepping the frames.
    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11];
    local numAlts = #listOfAlts

    if numAlts < 13 then
        local butPos = GRM.AltButtonPos ( numAlts );
        GRM_AddAltButton:SetPoint ( "TOP" , GRM_CoreAltFrame , butPos[1] , butPos[2] );
        GRM_AddAltButton:Show();
        GRM_CoreAltScrollFrame:Hide();
        -- now, let's populate them
        if numAlts > 0 then
            local result = GRM.SlimName ( listOfAlts[1][1] );
            if listOfAlts[1][5] == true then  --- this person is the main!
                result = result .. "\n|cffff0000(main)"
            end
            GRM_AltName1:SetText ( result );
            GRM_AltName1:SetTextColor ( listOfAlts[1][2] , listOfAlts[1][3] , listOfAlts[1][4] , 1.0 );
            GRM_AltName1:Show();
        else
            GRM_AltName1:Hide();
        end
        if numAlts > 1 then
            GRM_AltName2:SetText ( GRM.SlimName ( listOfAlts[2][1] ) );
            GRM_AltName2:SetTextColor ( listOfAlts[2][2] , listOfAlts[2][3] , listOfAlts[2][4] , 1.0 );
            GRM_AltName2:Show();
        else
            GRM_AltName2:Hide();
        end
        if numAlts > 2 then
            GRM_AltName3:SetText ( GRM.SlimName ( listOfAlts[3][1] ) );
            GRM_AltName3:SetTextColor ( listOfAlts[3][2] , listOfAlts[3][3] , listOfAlts[3][4] , 1.0 );
            GRM_AltName3:Show();
        else
            GRM_AltName3:Hide();
        end
        if numAlts > 3 then
            GRM_AltName4:SetText ( GRM.SlimName ( listOfAlts[4][1] ) );
            GRM_AltName4:SetTextColor ( listOfAlts[4][2] , listOfAlts[4][3] , listOfAlts[4][4] , 1.0 );
            GRM_AltName4:Show();
        else
            GRM_AltName4:Hide();
        end
        if numAlts > 4 then
            GRM_AltName5:SetText ( GRM.SlimName ( listOfAlts[5][1] ) );
            GRM_AltName5:SetTextColor ( listOfAlts[5][2] , listOfAlts[5][3] , listOfAlts[5][4] , 1.0 );
            GRM_AltName5:Show();
        else
            GRM_AltName5:Hide();
        end
        if numAlts > 5 then
            GRM_AltName6:SetText ( GRM.SlimName ( listOfAlts[6][1] ) );
            GRM_AltName6:SetTextColor ( listOfAlts[6][2] , listOfAlts[6][3] , listOfAlts[6][4] , 1.0 );
            GRM_AltName6:Show();
        else
            GRM_AltName6:Hide();
        end
        if numAlts > 6 then
            GRM_AltName7:SetText ( GRM.SlimName ( listOfAlts[7][1] ) );
            GRM_AltName7:SetTextColor ( listOfAlts[7][2] , listOfAlts[7][3] , listOfAlts[7][4] , 1.0 );
            GRM_AltName7:Show();
        else
            GRM_AltName7:Hide();
        end
        if numAlts > 7 then
            GRM_AltName8:SetText ( GRM.SlimName ( listOfAlts[8][1] ) );
            GRM_AltName8:SetTextColor ( listOfAlts[8][2] , listOfAlts[8][3] , listOfAlts[8][4] , 1.0 );
            GRM_AltName8:Show();
        else
            GRM_AltName8:Hide();
        end
        if numAlts > 8 then
            GRM_AltName9:SetText ( GRM.SlimName ( listOfAlts[9][1] ) );
            GRM_AltName9:SetTextColor ( listOfAlts[9][2] , listOfAlts[9][3] , listOfAlts[9][4] , 1.0 );
            GRM_AltName9:Show();
        else
            GRM_AltName9:Hide();
        end
        if numAlts > 9 then
            GRM_AltName10:SetText ( GRM.SlimName ( listOfAlts[10][1] ) );
            GRM_AltName10:SetTextColor ( listOfAlts[10][2] , listOfAlts[10][3] , listOfAlts[10][4] , 1.0 );
            GRM_AltName10:Show();
        else
            GRM_AltName10:Hide();
        end
        if numAlts > 10 then
            GRM_AltName11:SetText ( GRM.SlimName ( listOfAlts[11][1] ) );
            GRM_AltName11:SetTextColor ( listOfAlts[11][2] , listOfAlts[11][3] , listOfAlts[11][4] , 1.0 );
            GRM_AltName11:Show();
        else
            GRM_AltName11:Hide();
        end
        if numAlts > 11 then
            GRM_AltName12:SetText ( GRM.SlimName ( listOfAlts[12][1] ) );
            GRM_AltName12:SetTextColor ( listOfAlts[12][2] , listOfAlts[12][3] , listOfAlts[12][4] , 1.0 );
            GRM_AltName12:Show();
        else
            GRM_AltName12:Hide();
        end
    
    else

        --- ALT SCROLL FRAME IF PLAYER HAS MORE THAN 12 ALTS!!!
        GRM_AddAltButton:Hide();
        GRM_AltName1:Hide();GRM_AltName2:Hide();GRM_AltName3:Hide();GRM_AltName4:Hide();GRM_AltName5:Hide();GRM_AltName6:Hide();GRM_AltName7:Hide();
        GRM_AltName8:Hide();GRM_AltName9:Hide();GRM_AltName10:Hide();GRM_AltName11:Hide();GRM_AltName12:Hide();
        GRM_CoreAltScrollFrame:Show();
        GRM_CoreAltScrollChildFrame:Show();
        local scrollHeight = 0;
        local scrollWidth = 128;
        local buffer = 1;

        GRM_CoreAltScrollChildFrame.allFrameButtons = GRM_CoreAltScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
        -- populating the window correctly.
        for i = 1 , numAlts do
            --GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11]
            -- if font string is not created, do so.
            if not GRM_CoreAltScrollChildFrame.allFrameButtons[i] then
                local tempButton = CreateFrame ( "Button" , "GRM_AltAdded" .. i , GRM_CoreAltScrollChildFrame ); -- Names each Button 1 increment up
                GRM_CoreAltScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "GRM_AltAddedText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
            end

            if i == numAlts and #GRM_CoreAltScrollChildFrame.allFrameButtons > numAlts then
                for j = numAlts + 1 , #GRM_CoreAltScrollChildFrame.allFrameButtons do
                    GRM_CoreAltScrollChildFrame.allFrameButtons[j][1]:Hide();
                end
            end

            local AltButtons = GRM_CoreAltScrollChildFrame.allFrameButtons[i][1];
            local AltButtonsText = GRM_CoreAltScrollChildFrame.allFrameButtons[i][2];
            AltButtons:SetWidth ( 65 );
            AltButtons:SetHeight ( 15 );
            AltButtons:RegisterForClicks( "RightButtonDown" , "LeftButtonDown" );

            -- Check if main
            local result = GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][1] );
            if i == 1 then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][5] == true then  --- this person is the main!
                    result = result .. "\n|cffff0000(main)"
                    AltButtonsText:SetWordWrap ( true );
                end
            else
                AltButtonsText:SetWordWrap ( false );
            end
            AltButtonsText:SetText ( result );
            AltButtonsText:SetTextColor ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][2] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][4] , 1.0 );
            AltButtonsText:SetWidth ( 63 );
            
            AltButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );
            AltButtonsText:SetPoint ( "CENTER" , AltButtons );
            AltButtonsText:SetJustifyH ( "CENTER" );

            -- Logic
            AltButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "RightButton" then
                    -- Parse the button number, so the alt position can be identified...
                    local altNum;
                    local isMain = false;
                    if tonumber ( string.sub ( AltButtons:GetName() , #AltButtons:GetName() - 1 ) ) ~= nil then
                        altNum = tonumber ( string.sub ( AltButtons:GetName() , #AltButtons:GetName() - 1 ) );
                    else
                        altNum = tonumber ( string.sub ( AltButtons:GetName() , #AltButtons:GetName() ) );
                    end

                    -- Ok, populate the buttons properly...
                    GRM_AddonGlobals.pause = true;
                    local cursorX , cursorY = GetCursorPosition();
                    GRM_altDropDownOptions:ClearAllPoints();
                    GRM_altDropDownOptions:SetPoint( "TOPLEFT" , UIParent , "BOTTOMLEFT" , cursorX , cursorY );

                    if string.find ( AltButtonsText:GetText() , "(main)" ) == nil then
                        GRM_altSetMainButtonText:SetText ( "Set as Main" );
                        GRM_altOptionsText:SetText ( AltButtonsText:GetText() );
                    else -- player IS the main... place option to Demote From Main rahter than set as main.
                        GRM_altSetMainButtonText:SetText ( "Set as Alt" );
                        isMain = true;
                        GRM_altOptionsText:SetText ( string.sub ( AltButtonsText:GetText() , 1 , string.find ( AltButtonsText:GetText() , "\n" ) - 1 ) );
                    end

                    
                    local width = 70;
                    if GRM_altOptionsText:GetStringWidth() + 15 > width then       -- For scaling the frame based on size of player name.
                        width = GRM_altOptionsText:GetStringWidth() + 15;
                    end
                    GRM_altDropDownOptions:SetSize ( width , 92 );
                    GRM_altDropDownOptions:Show();

                    GRM_altRemoveButtonText:SetText ( "Remove" );

                    -- Set the Global info now!
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GuildMemberDetailName:GetText() then
                            GRM_AddonGlobals.selectedAlt = { GuildMemberDetailName:GetText() , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][altNum][1] , GRM_AddonGlobals.guildName , isMain };
                            break;
                        end
                    end
                end
            end);
            
            -- Now let's pin it!
            if i == 1 then
                AltButtons:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame , 0 , - 1 );
                scrollHeight = scrollHeight + AltButtons:GetHeight();
            elseif i == 2 then
                AltButtons:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame.allFrameButtons[i - 1][1] , "TOPRIGHT" , 1 , 0 );
            else
                AltButtons:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame.allFrameButtons[i - 2][1] , "BOTTOMLEFT" , 0 , - buffer );
                if i % 2 ~= 0 then
                    scrollHeight = scrollHeight + AltButtons:GetHeight() + buffer;
                end
            end
            -- Ok, let's place the button now!
            if i == numAlts then
                GRM_AddAltButton2:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame.allFrameButtons[numAlts - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
                if numAlts % 2 == 0 then
                    scrollHeight = scrollHeight + AltButtons:GetHeight() + buffer;
                end
                GRM_AddAltButton2:Show();
            end
            AltButtons:Show();
        end

        

        -- Update the size -- it either grows or it shrinks!
        GRM_CoreAltScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

        --Set Slider Parameters ( has to be done after the above details are placed )
        local scrollMax = ( scrollHeight - 90 ) + ( buffer * .5 );
        if scrollMax < 0 then
            scrollMax = 0;
        end
        
        GRM_CoreAltScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
        -- Mousewheel Scrolling Logic
        GRM_CoreAltScrollFrame:EnableMouseWheel( true );
        GRM_CoreAltScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
            local current = GRM_CoreAltScrollFrameSlider:GetValue();
            
            if IsShiftKeyDown() and delta > 0 then
                GRM_CoreAltScrollFrameSlider:SetValue ( 0 );
            elseif IsShiftKeyDown() and delta < 0 then
                GRM_CoreAltScrollFrameSlider:SetValue ( scrollMax );
            elseif delta < 0 and current < scrollMax then
                GRM_CoreAltScrollFrameSlider:SetValue ( current + 20 );
            elseif delta > 0 and current > 1 then
                GRM_CoreAltScrollFrameSlider:SetValue ( current - 20 );
            end
        end);

        
    end
    GRM_CoreAltFrame:Show();
end

-- Method:          GRM.GetClassColorRGB ( string )
-- What it Does:    Returns the 0-1 RGB color scale for the player class
-- Purpose:         Easy class color tagging for UI feature.
GRM.GetClassColorRGB = function ( className )
    local result = {};
     if className == "DEATHKNIGHT" then
        result = { 0.77 , 0.12 , 0.23 }
    elseif className == "DEMONHUNTER" then
        result = { 0.64 , 0.19 , 0.79 }
    elseif className == "DRUID" then
        result = { 1.0 , 0.49 , 0.04 }
    elseif className == "HUNTER" then
        result = { 0.67 , 0.83 , 0.45 }
    elseif className == "MAGE" then
        result = { 0.41 , 0.80 , 0.94 }
    elseif className == "MONK" then
        result = { 0.0 , 1.0 , 0.59 }
    elseif className == "PALADIN" then
        result = { 0.96 , 0.55 , 0.73 }
    elseif className == "PRIEST" then
        result = { 1.0 , 1.0 , 1.0 }
    elseif className == "ROGUE" then
        result = { 1.0 , 0.96 , 0.41 }
    elseif className == "SHAMAN" then
        result = { 0.0 , 0.44 , 0.87 }
    elseif className == "WARLOCK" then
        result = { 0.58 , 0.51 , 0.79 }
    elseif className == "WARRIOR" then
        result = { 0.78 , 0.61 , 0.43 }
    end
    return result;
end

-- Method:          GRM.RemoveAlt(string , string , string , boolean , int )
-- What it Does:    Detags the given altName to that set of toons.
-- Purpose:         Alt management, so whoever has addon installed can tag player.
GRM.RemoveAlt = function ( playerName , altName , guildName , isSync , syncTimeStamp )
    local isRemoveMain = false;
    local epochTime;
    if isSync then
        epochTime = syncTimeStamp;
    else
        epochTime = time();
    end

    if playerName ~= altName then
        local index1;
        local altIndex1;
        local count = 0;

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index1 = j;
            end
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex1 = j;
                -- Need to preserve the list, in the case of syncing to live update the frames if they are on the alt of the alt.
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                    GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                end
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 1 and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then -- No need to report if the person is removing the last alt. No need to set oneself as main.
                    isRemoveMain = true;
                end
            end
            if count == 2 then
                break;
            end
        end

        -- Removing the alt from all of the player's alts.'
        local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11];
        if #listOfAlts > 0 then                                                                                                     -- There is more than 1 alt for new alt to be added to
            for i = 1 , #listOfAlts do
                if listOfAlts[i][1] ~= altName then                                                                                 -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                                             -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then                                       -- name on current focus altList found in the metadata and is not the alt to be removed.
                            -- Now, we have the list!
                            for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] == altName then
                                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m] ) -- Adding the alt to removed alts list
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37][ #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37] ][6] = epochTime;
                                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] , m );     -- removing the alt
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end
            end
        end
        -- Remove the alt name from the current focus
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11][i][1] == altName then
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][37] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11][i] ) -- Adding the alt to removed alts list
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][37][ #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][37] ][6] = epochTime;
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11] , i );
                break;
            end
        end
        -- Resetting the alt's list
        if isRemoveMain then 
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex1][10] = false;
        end
        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex1][11] = nil;
        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex1][11] = {};
        -- Insta update the frames!
        if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
            local altFound = false;
            if #GRM_AddonGlobals.selectedAltList > 0 then
                for m = 1 , #GRM_AddonGlobals.selectedAltList do
                    if GRM_AddonGlobals.selectedAltList[m][1] == GuildMemberDetailName:GetText() then
                        -- Alt is found! Let's update the alt frames!
                        altFound = true;
                        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                                -- woot! Now have the index of the alt and can successfully populate the alt frames.
                                GRM.PopulateAltFrames ( i );
                            end
                        end
                        break;
                    end
                end
            end
            -- If it is just the player's same frame, then update it!
            if not altFound and playerName == GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) then
                GRM.PopulateAltFrames ( index1 );
            end
        end
    else
        print ( GRM.SlimName ( playerName ) .. " cannot remove themselves from alts." );
    end
end

-- Method:          GRM.RemovePlayerFromRemovedAltTable( string )
-- What it Does:    When a player removes an alt, it stores that removal in a special table for syncing purposes.
--                  If the alt is re-added, it removes the player from the removed list
-- Purpose:         Syncing data needs timestamps and thus needs good table management of the metadata of add/remove alts lists.
GRM.RemovePlayerFromRemovedAltTable = function ( name , index )
    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37] > 0 then
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37] do
            if name == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37][i][1] then
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37] , i );
                break;
            end
        end
    end
end
    
-- Method:          GRM.AddAlt (string,string,string,boolean,int)
-- What it Does:    Tags toon to a player's set of alts. It will tag them not just to the given player, but reverse tag itself to all of the alts.
-- Purpose:         Organizing a player and their alts.
GRM.AddAlt = function ( playerName , altName , guildName , isSync , syncTimeStamp )
    if playerName ~= altName then
        -- First, let's identify player index, then identify the classColor of the alt
        local index2;
        local altIndex2;
        local count = 0;
        local classAlt = "";
        local classMain = "";
        local classColorsAlt , classColorsMain , classColorsTemp;
        local isMain = false;
        local timeEpochAdd;
        if isSync then
            timeEpochAdd = syncTimeStamp;
        else
            timeEpochAdd = time();
        end

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index2 = j;
                classMain = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9];
            end
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex2 = j;
                -- Need to preserve the list, in the case of syncing to live update the frames if they are on the alt of the alt.
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                    GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                end
                classAlt = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9];
            end
            if count == 2 then
                break;
            end
        end

        -- NEED TO VERIFY IT IS NOT AN ALT FIRST!!! it is removing and re-adding if it is same person.
        local isFound = false;
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 then
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11];
            
            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                if listOfAlts[m][1] == playerName then
                    print ( GRM.SlimName ( altName ) .. " is Already Listed as an Alt." );
                    isFound = true;
                    break;
                end
            end
        end
        -- If player is trying to add this toon to a list that is already on a list then it adds it in reverse
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 and #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] > 0 and not isFound then  -- Oh my! Both players have current lists!!! Remove the alt from his list, add to this new one.
            GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][1] , guildName , isSync , syncTimeStamp );
        end
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 then

            if isFound ~= true then
                GRM.AddAlt ( altName , playerName , guildName , isSync , syncTimeStamp );
            end
            
        else
            -- add altName to each of the previously
            local isFound2 = false;
            classColorsAlt = GRM.GetClassColorRGB ( classAlt );
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11];
            if #listOfAlts > 0 then                                                                 -- There is more than 1 alt for new alt to be added to
                for i = 1 , #listOfAlts do                                                          -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                             -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then       -- name on current focus altList found in the metadata!
                            -- Now, make sure it is not a repeat add!
                            
                            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                                if listOfAlts[m][1] == altName then
                                    print( GRM.SlimName ( altName ) .. " is Already Listed as an Alt." );
                                    isFound2 = true;
                                    break;
                                end
                            end
                            if isFound2 ~= true then
                                classColorsTemp = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9] );
                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] , timeEpochAdd } ); -- altName is added to a currentFocus previously added alt.
                                GRM.RemovePlayerFromRemovedAltTable ( altName , j );
                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , classColorsTemp[1] , classColorsTemp[2] , classColorsTemp[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] , timeEpochAdd } );
                                GRM.RemovePlayerFromRemovedAltTable ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , altIndex2 );
                            end
                            break;
                        end
                    end
                    if isFound2 then
                        break;
                    end
                end
            end

            if isFound2 ~= true then
                -- Add all of the CurrentFocus player's alts to the new alt
                -- then add the currentFocus player as well
                classColorsMain = GRM.GetClassColorRGB ( classMain );
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] , 1 , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] , timeEpochAdd } );
                else
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] , timeEpochAdd } );
                end
                GRM.RemovePlayerFromRemovedAltTable ( playerName , altIndex2 );
                -- Finally, let's add the alt to the player's currentFocus.
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] , timeEpochAdd } );
                GRM.RemovePlayerFromRemovedAltTable ( altName , index2 );
            end
            -- Insta update the frames!
            if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
                -- For use with syncing UI LIVE
                local altFound = false;
                if #GRM_AddonGlobals.selectedAltList > 0 then
                    for m = 1 , #GRM_AddonGlobals.selectedAltList do
                        if GRM_AddonGlobals.selectedAltList[m][1] == GuildMemberDetailName:GetText() then
                            -- Alt is found! Let's update the alt frames!
                            altFound = true;
                            for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                                    -- woot! Now have the index of the alt and can successfully populate the alt frames.
                                    GRM.PopulateAltFrames ( i );
                                end
                            end
                            break;
                        end
                    end
                end

                if not altFound then
                    local frameName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
                    if playerName == frameName then 
                        GRM.PopulateAltFrames ( index2 );
                    elseif altName == frameName then
                        GRM.PopulateAltFrames ( altIndex2 );
                    end
                end
            end
        end
    else
        print ( GRM.SlimName ( playerName ) .. " cannot become their own alt!" );
    end
end


-- Method:              GRM.SortMainToTop (string , int , int , string)
-- What it Does:        Sorts the alts list and sets the main to the top.
-- Purpose:             To keep the main as the first name in the list of alts.
GRM.SortMainToTop = function ( playerName , index2 )
    local tempList;
    -- Ok, now, let's grab the list and do some sorting!
    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] ~= true then                               -- no need to attempt sorting if they are all alts, none are the main.
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do                           -- scanning through the list of alts
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i][5] then                         -- if one of them equals the main!
                tempList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i];                    -- Saving main's info to temp holder
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] , i );             -- removing
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] , 1 , tempList );  -- Re-adding it to the front and done!
                break
            end
        end
    end
end

-- Method:              GRM.SetMain (string,string,string , boolean , int )
-- What it Does:        Sets the player as main, as well as updates that status among the alt grouping.
-- Purpose:             Main/alt management control.
GRM.SetMain = function ( playerName , mainName , guildName , isSync , syncTimeStamp )
    local index2;
    local altIndex2;
    local count = 0;
    local timeEpochMain;
    if isSync then
        timeEpochMain = syncTimeStamp;
    else
        timeEpochMain = time();
    end

    -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested,difficult to follow, and bloated.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
            index2 = j;
            -- Establishing list of alts...
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
            end
            if playerName == mainName then                               -- no need to identify an alt if there is none.
                break;
            else
                count = count + 1;
            end
        end
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then           -- Pull mainName to attach class on Color
            count = count + 1;
            altIndex2 = j;
        end
        if count == 2 then
            break;
        end
    end

    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then                -- this alt is the main!
                        if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = true;                       -- Setting toon as main!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = timeEpochMain;                  -- Setting timeStampOfChange!
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- making sure all their alts are listed as notMain
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;
                        end
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = false;                      -- ensure alt is not listed as main
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = timeEpochMain;
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- identifying who is to be tagged as main
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] == mainName then
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = true;
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    GRM.SortMainToTop ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , j );
                    break
                end
            end            
        end
        -- Do one last pass to set your own alts list proper.
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i][5] = false;
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = timeEpochMain;
        end
        if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] = true;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][39] = timeEpochMain;
        end
        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do               -- identifying who is to be tagged as main
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][1] == mainName then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = true;
            else
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        GRM.SortMainToTop ( playerName , index2 );
    else
        if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = true;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = timeEpochMain;
        end
    end
    -- Insta update the frames!
    if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
        local altFound = false;
        if #GRM_AddonGlobals.selectedAltList > 0 then
            for m = 1 , #GRM_AddonGlobals.selectedAltList do
                if GRM_AddonGlobals.selectedAltList[m][1] == GuildMemberDetailName:GetText() then
                    -- Alt is found! Let's update the alt frames!
                    altFound = true;
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                            -- woot! Now have the index of the alt and can successfully populate the alt frames.
                            GRM.PopulateAltFrames ( i );
                        end
                    end
                    break;
                end
            end
        end
        
        if not altFound then
            local frameName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
            if playerName == frameName then
                GRM.PopulateAltFrames ( index2 );
            elseif mainName == frameName then
                GRM.PopulateAltFrames ( altIndex2 );
            end
        end
    end
end

-- Method:          GRM.PlayerHasMain( string , int , int )
-- What it Does:    Returns true if either the player has a main or is a main themselves
-- Purpose:         Better alt management logic.
GRM.PlayerHasMain = function ( playerName , index2 )
    local hasMain = false;

    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
        hasMain = true;
    else
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i][5] then
                hasMain = true;
                break;
            end
        end
    end
    return hasMain;
end

-- Method:          GRM.GetCoreFontStringClicked()
-- What it Does:    Returns a table with the name of the player, the altName, and the guild.
-- Puspose:         To easily pass the info on without having to use a global variable, and set one function to all 12 alt frames.
GRM.GetCoreFontStringClicked = function()
    local altName;
    local focusName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
    local isMain = false;
    local isAlt1 = false;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == focusName then
    
            if GRM_AltName1:IsVisible() and GRM_AltName1:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][1][1];
                isAlt1 = true;
            elseif GRM_AltName2:IsVisible() and GRM_AltName2:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][2][1];
            elseif GRM_AltName3:IsVisible() and GRM_AltName3:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][3][1];
            elseif GRM_AltName4:IsVisible() and GRM_AltName4:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][4][1];
            elseif GRM_AltName5:IsVisible() and GRM_AltName5:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][5][1];
            elseif GRM_AltName6:IsVisible() and GRM_AltName6:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][6][1];
            elseif GRM_AltName7:IsVisible() and GRM_AltName7:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][7][1];
            elseif GRM_AltName8:IsVisible() and GRM_AltName8:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][8][1];
            elseif GRM_AltName9:IsVisible() and GRM_AltName9:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][9][1];
            elseif GRM_AltName10:IsVisible() and GRM_AltName10:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][10][1];
            elseif GRM_AltName11:IsVisible() and GRM_AltName11:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][11][1];
            elseif GRM_AltName12:IsVisible() and GRM_AltName12:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][12][1];
            elseif ( GRM_MemberDetailRankDateTxt:IsVisible() and GRM_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GRM_JoinDateText:IsVisible() and GRM_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GRM_MemberDetailPlayerStatus:IsVisible() and GRM_MemberDetailPlayerStatus:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then -- Covers both promo date and join date focus.
                altName = focusName;
            else
                -- MOUSE WAS NOT OVER, EVEN ON A RIGHT CLICK OF THE FRAME!!!
                focusName = nil;
                altName = nil;
            end
            break;
        end
    end
    if ( isAlt1 and altName ~= nil and string.find ( GRM_AltName1:GetText() , "(main)" ) ~= nil ) then        -- This is the main! Let's parse main out of the name!
        isMain = true;
    elseif altName == focusName and GRM_MemberDetailMainText:IsVisible() then
        isMain = true;
    end
    return { focusName , altName , GRM_AddonGlobals.guildName , isMain };
end


-- Method:              GRM.DemoteFromMain ( string , string , string )
-- What it Does:        If the player is "main" then it removes the main tag to false
-- Purpose:             User Experience (UX) and alt management!
GRM.DemoteFromMain = function ( playerName , mainName , guildName , isSync , syncTimeStamp )
    local index2;
    local altIndex2;
    local count = 0;
    local RMVtimeEpochMain;
    if isSync then
        RMVtimeEpochMain = syncTimeStamp;
    else
        RMVtimeEpochMain = time();
    end
    
    -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested,difficult to follow, and bloated.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then   -- Identify position of player
            index2 = j;
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
            end
            if playerName == mainName then                                                                          -- no need to identify an alt if there is none.
                break;
            else
                count = count + 1;
            end
        end
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then     -- Pull mainName to attach class on Color
            count = count + 1;
            altIndex2 = j;
        end
        if count == 2 then
            break;
        end
    end

    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then                -- this alt is the main!
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = false;                       -- Demoting the toon from main!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = RMVtimeEpochMain;
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- making sure all their alts are listed as notMain
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;
                        end
                    else
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- identifying who is to be tagged as main
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] == mainName then
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    GRM.SortMainToTop ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , j );
                    break
                end
            end            
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = RMVtimeEpochMain;
        end
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][39] = RMVtimeEpochMain;
        end
        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do               -- identifying who is to be tagged as main
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][1] == mainName then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = false;
            else
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        GRM.SortMainToTop ( playerName , index2 );
    else
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = RMVtimeEpochMain;
        end
    end
    -- Insta update the LIVE frames for sync, if player is on a diff. frame.
    if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
        local altFound = false;
        if #GRM_AddonGlobals.selectedAltList > 0 then
            for m = 1 , #GRM_AddonGlobals.selectedAltList do
                if GRM_AddonGlobals.selectedAltList[m][1] == GuildMemberDetailName:GetText() then
                    -- Alt is found! Let's update the alt frames!
                    altFound = true;
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                            -- woot! Now have the index of the alt and can successfully populate the alt frames.
                            GRM.PopulateAltFrames ( i );
                        end
                    end
                    break;
                end
            end
        end

        if not altFound then
            local frameName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
            if playerName == frameName then
                GRM.PopulateAltFrames ( index2 );
            elseif mainName == frameName then
                GRM.PopulateAltFrames ( altIndex2 );
            end
        end
    end
end

-- Method:          GRM.ResetAltButtonHighlights();
-- What it Does:    Just resets the highlight of the tab/alt-tab highlight for a better user-experience to default position
-- Purpose:         UX
GRM.ResetAltButtonHighlights = function()
    GRM_AddAltNameButton1:LockHighlight();
    GRM_AddAltNameButton2:UnlockHighlight();
    GRM_AddAltNameButton3:UnlockHighlight();
    GRM_AddAltNameButton4:UnlockHighlight();
    GRM_AddAltNameButton5:UnlockHighlight();
    GRM_AddAltNameButton6:UnlockHighlight();
    GRM_AddonGlobals.currentHighlightIndex = 1;
end


-- Method:          GRM.AddAltAutoComplete()
-- What it Does:    Takes the entire list of guildies, then sorts them as player types to be added to alts list
-- Purpose:         Eliminates the possibility of a person entering a fake name of a player no longer in the guild.
GRM.AddAltAutoComplete = function()
    local partName = GRM_AddAltEditBox:GetText();
    GRM_AddonGlobals.listOfGuildies = nil;
    GRM_AddonGlobals.listOfGuildies = {};
    local numButtons = 6;

    for i = 1 , GRM.GetNumGuildies() do
        local name = GetGuildRosterInfo( i );
        if name ~= GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) then   -- no need to go through player's own window
            table.insert ( GRM_AddonGlobals.listOfGuildies , name );
        end
    end
    sort ( GRM_AddonGlobals.listOfGuildies );    -- Alphabetizing it for easier parsing for buttontext updating.
    
    -- Now, let's identify the names that match
    local count = 0;
    local matchingList = {};
    local found = false;
    for i = 1 , #GRM_AddonGlobals.listOfGuildies do
        local innerFound = false;
        if string.lower ( partName ) == string.lower ( string.sub ( GRM_AddonGlobals.listOfGuildies[i] , 1 , #partName ) ) then
            innerFound = true;
            found = true;
            count = count + 1;
            table.insert ( matchingList , GRM_AddonGlobals.listOfGuildies[i] );
        end
        if count > 6 then
            break;
        end
        if innerFound ~= true and found then    -- resource saving
            break;
        end
    end
    
    -- Populate the buttons now...
    if partName ~= nil and partName ~= "" then
        local resultCount = #matchingList;
        GRM.ResetAltButtonHighlights();
        if resultCount > 0 then
            GRM_AddAltEditFrameHelpText:Hide();
            GRM_AddAltEditFrameHelpText2:Hide();
            GRM_AddAltNameButton1Text:SetText ( matchingList[1] );
            GRM_AddAltNameButton1:Enable();
            GRM_AddAltNameButton1:Show();
            GRM_AddAltEditFrameTextBottom:Show();
        else
            if string.lower ( GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) ) == string.lower ( partName ) then
                GRM_AddAltEditFrameHelpText:SetText ( "Player Cannot Add\nThemselves as an Alt" );
            else
                GRM_AddAltEditFrameHelpText:SetText ( "Player Not Found" );
            end
            GRM_AddAltEditFrameHelpText:Show();
            GRM_AddAltEditFrameHelpText2:Show();
            GRM_AddAltNameButton1:Hide();
            GRM_AddAltEditFrameTextBottom:Hide();
        end
        if resultCount > 1 then
            GRM_AddAltNameButton2Text:SetText ( matchingList[2] );
            GRM_AddAltNameButton2:Enable();
            GRM_AddAltNameButton2:Show();
        else
            GRM_AddAltNameButton2:Hide();
        end
        if resultCount > 2 then
            GRM_AddAltNameButton3Text:SetText ( matchingList[3] );
            GRM_AddAltNameButton3:Enable();
            GRM_AddAltNameButton3:Show();
        else
            GRM_AddAltNameButton3:Hide();
        end
        if resultCount > 3 then
            GRM_AddAltNameButton4Text:SetText ( matchingList[4] );
            GRM_AddAltNameButton4:Enable();
            GRM_AddAltNameButton4:Show();
        else
            GRM_AddAltNameButton4:Hide();
        end
        if resultCount > 4 then
            GRM_AddAltNameButton5Text:SetText ( matchingList[5] );
            GRM_AddAltNameButton5:Enable();
            GRM_AddAltNameButton5:Show();
        else
            GRM_AddAltNameButton5:Hide();
        end
        if resultCount > 5 then
            if resultCount == 6 then
                GRM_AddAltNameButton6Text:SetText ( matchingList[6] );
                GRM_AddAltNameButton6:Enable();
            else
                GRM_AddAltNameButton6Text:SetText ( "..." );
                GRM_AddAltNameButton6:Disable();
            end
            GRM_AddAltNameButton6:Show();
        else
            GRM_AddAltNameButton6:Hide();
        end
    else
        GRM_AddAltNameButton1:Hide();
        GRM_AddAltNameButton2:Hide();
        GRM_AddAltNameButton3:Hide();
        GRM_AddAltNameButton4:Hide();
        GRM_AddAltNameButton5:Hide();
        GRM_AddAltNameButton6:Hide();
        GRM.ResetAltButtonHighlights();
        GRM_AddAltEditFrameTextBottom:Hide();
        GRM_AddAltEditFrameHelpText:SetText ( "Please Type the Name\nof the alt" );
        GRM_AddAltEditFrameHelpText:Show();
        GRM_AddAltEditFrameHelpText2:Show();
    end
end

-- Method:              GRM.KickAllAlts ( string , string )
-- What it Does:        Bans and/or kicks all the alts a player has given the status of checekd button on ban window.
-- Purpose:             QoL. Option to ban players' alts as well if they are getting banned.
GRM.KickAllAlts = function ( playerName , guildName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
        -- Ok, let's parse the player's data!
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
            if #listOfAlts > 0 then                                  -- There is at least 1 alt
                for m = 1 , #listOfAlts do                           -- Cycling through the alts
                    if GRM_PopupWindowCheckButton1:GetChecked() then     -- Player wants to BAN the alts confirmed!
                        for s = 1 , #listOfAlts do
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == listOfAlts[s][1] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ~= GRM_AddonGlobals.addonPlayerName then        -- Logic to avoid kicking oneself ( or at least to avoid getting error notification )
                                    -- Set the banned info.
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1] = true;
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][2] = time();
                                    local instructionNote = "Reason Banned? (Press ENTER when done)";
                                    local result = GRM_MemberDetailPopupEditBox:GetText();

                                    if result ~= nil and result ~= instructionNote and result ~= "" then
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                                    elseif result == nil then
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
                                    else
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                                    end

                                    GuildUninvite ( listOfAlts[s][1] );

                                    break;
                                end
                            end
                        end
                        break;
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] ~= GRM_AddonGlobals.addonPlayerName then
                            GuildUninvite ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] );
                        end                       
                    end
                end
            end
            break;
        end
    end
end


------------------------------------
---- END OF ALT MANAGEMENT ---------
------------------------------------



------------------------------------
------ METADATA TRACKING LOGIC -----
--- Reporting, Live Tracking, Etc --
------------------------------------

-- Method:          GRM.AddMemberRecord()
-- What it Does:    Builds Member Record into Guild History with various metadata
-- Purpose:         For reliable guild data tracking.
GRM.AddMemberRecord = function ( memberInfo , isReturningMember , oldMemberInfo , guildName )
    -- Metadata to track on all players.
    -- Basic Info
    local timeSeconds = time();
    local name = memberInfo[1];
    local slim = GRM.SlimName ( name );
    local joinDate = GRM.GetTimestamp();
    local joinDateMeta = timeSeconds;  -- Saved in Seconds since Jan 1, 1970, to be parsed later
    local rank = memberInfo[2];
    local rankInd = memberInfo[3];
    local currentLevel = memberInfo[4];
    local note = memberInfo[5];
    local officerNote = memberInfo[6];
    local class = memberInfo[7]; 
    local isMainToon = false;
    local listOfAltsInGuild = {};
    local dateOfLastPromotion = nil;
    local dateOfLastPromotionMeta = nil;
    local birthday = nil;

    -- Event and Anniversary tracking.
    local eventTrackers = { { slim .. "'s Anniversary!" , nil , false , "" } , { slim .. "'s Birthday!" , nil , false , "" } };  -- Position 1 = anniversary , Position 2 = birthday , 3 = anniversary For Each = { date , needsToNotify , SpecialNotes }
    local customNote = ""; -- Extra note space, for GM to add futher info.

    -- Info nil now, but to be populated on leaving the guild
    local leftGuildDate = {};
    local leftGuildDateMeta = {};
    local bannedFromGuild = { false , 0 , false };  -- { isBanned , timeOfBanInEpoch or unban , isBanRemoved }
    local reasonBanned = "";
    local oldRank = nil;
    local oldJoinDate = {}; -- filled upon player leaving the guild.
    local oldJoinDateMeta = {};

    -- Pieces info that were added on later-- from index 24 of metaData array, so as not to mess with previous code
    local lastOnline = 0;                                                                           -- Stores it in number of HOURS since last online.
    local rankHistory = {};
    local playerLevelOnJoining = currentLevel;
    local recommendToKickReported = false;
    -- More metadata!
    local zone = memberInfo[9];
    local achievementPoints = memberInfo[10];
    local isMobile = memberInfo[11];
    local rep = memberInfo[12];
    local timePlayerEnteredZone = timeSeconds;  -- ( time() - timePlayerEnteredZone ) = seconds passed. If zone changes, player re-timestamps it...
    local isOnline = memberInfo[13];
    local currentStatus = memberInfo[14];       -- AFK, Active, Busy

    -- FOR SYNC PURPOSES!!!
    local joinDateTimestamp = { "" , 0 };
    local promoDateTimestamp = { "" , 0 };
    local listOfRemovedAlts = {};
    local mainStatusChangeTimestamp = {};
    local timeMainStatusAltered = 0;

    -- Returning member info to be carried over.
    if isReturningMember then
        dateOfLastPromotion = oldMemberInfo[12];
        dateOfLastPromotionMeta = oldMemberInfo[13];
        birthday = oldMemberInfo[14];
        leftGuildDate = oldMemberInfo[15];
        leftGuildDateMeta = oldMemberInfo[16];
        bannedFromGuild = oldMemberInfo[17];
        reasonBanned = oldMemberInfo[18];
        oldRank = oldMemberInfo[19];
        oldJoinDate = oldMemberInfo[20];
        table.insert ( oldJoinDate , joinDate );                -- Add the new join date to history
        oldJoinDateMeta = oldMemberInfo[21];
        table.insert ( oldJoinDateMeta , joinDateMeta );        -- likewise, add the meta seconds.
        specialTrackers = oldMemberInfo[22];
        customNote = oldMemberInfo[23];
        rankHistory = oldMemberInfo[25];
        playerLevelOnJoining = oldMemberInfo[26];
        joinDateTimestamp[1] = joinDate;
        joinDateTimestamp[2] = timeSeconds;
    end

    -- For both returning players and new adds
    table.insert ( rankHistory , { rank , string.sub ( joinDate , 1 , string.find ( joinDate , "'" ) + 2 ) , joinDateMeta } );

    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , { name , joinDate , joinDateMeta , rank , rankInd , currentLevel , note , officerNote , class , isMainToon ,
        listOfAltsInGuild , dateOfLastPromotion , dateOfLastPromotionMeta , birthday , leftGuildDate , leftGuildDateMeta , bannedFromGuild , reasonBanned , oldRank ,
            oldJoinDate , oldJoinDateMeta , eventTrackers , customNote , lastOnline , rankHistory , playerLevelOnJoining , recommendToKickReported , zone , achievementPoints ,
                isMobile , rep , timePlayerEnteredZone , isOnline , memberStatus , joinDateTimestamp , promoDateTimestamp , listOfRemovedAlts , mainStatusChangeTimestamp , timeMainStatusAltered } );  -- 39 so far. (35-39 = sync stamps)
end

-- Method:          GRM.GetGuildEventString ( int , string )
-- What it Does:    Gets more exact info from the actual Guild Event Log ( can only be queried once per 10 seconds) as a string
-- Purpose:         This parses more exact info, like "who" did the kicking, or "who" invited who, and so on.
GRM.GetGuildEventString = function ( index , playerName )
    -- index 1 = demote , 2 = promote , 3 = remove/quit , 4 = invite/join
    local result = "";
    local eventType = { "demote" , "promote" , "invite" , "join" , "quit" , "remove" };
    QueryGuildEventLog();

    if index == 1 or index == 2 then
        for i = GetNumGuildEvents() , 1 , -1 do
            local type , p1, p2 = GetGuildEventInfo ( i );
            if p1 ~= nil then                                                 ---or eventType [ 2 ] == type ) and ( p2 ~= nil and p2 == playerName ) and p1 ~= nil then
                if index == 1 and eventType [ 1 ] == type and p2 ~= nil and p2 == playerName then
                    result = ( p1 .. " DEMOTED " .. p2 );
                    break;
                elseif index == 2 and eventType [ 2 ] == type and p2 ~= nil and p2 == playerName then
                    result = ( p1 .. " PROMOTED " .. p2 );
                    break;
                end
            end
        end
   elseif index == 3 then
        local notFound = true;
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 = GetGuildEventInfo ( i );
            if p1 ~= nil then 
                if eventType [ 5 ] == type or eventType [ 6 ] == type then   -- Quit or Remove
                    if eventType [ 6 ] == type and p2 ~= nil and p2 == playerName then
                        result = ( p1 .. " KICKED " .. p2 .. " from the guild!" );
                        notFound = false;
                    elseif eventType [ 5 ] == type and p1 == playerName then
                        -- FOUND!
                        result = ( p1 .. " has Left the guild" );
                        notFound = false;
                    end
                    if notFound ~= true then
                        break;
                    end
                end
            end
        end
    elseif index == 4 then
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 = GetGuildEventInfo ( i );
            if eventType [ 3 ] == type and p1 ~= nil and p2 ~= nil and p2 == playerName then   -- invite
                result = ( p1 .. " INVITED " .. p2 .. " to the guild." );
                break;
            end
        end
    end

    return result;
end

-- Method:          GRM.GetMessageRGB( int )
-- What it Does:    Returns the 3 RGB colors colors based on the given index on a 1.0 scale
-- Purpose:         Save on code when need color call. I also did this as a 3 argument return, rather than a single array, just as a proof of concept
--                  since this whole project was also a bit of a Lua learning moment.
GRM.GetNMessageRGB = function ( index )
    local r = 0;
    local g = 0;
    local b = 0;

    if index == 1 then      -- Promotion 
        r = 1.0;
        g = 0.914;
        b = 0.0;
    elseif index == 2 then  -- Demotion
        r = 0.91;
        g = 0.388;
        b = 0.047;
    elseif index == 3 then  -- Leveled
        r = 0;
        g = 0.44;
        b = 0.87;
    elseif index == 4 then  -- Note
        r = 1.0;
        g = 0.6;
        b = 1.0;
    elseif index == 5 then  -- OfficerNote
        r = 1.0;
        g = 0.094;
        b = 0.93;
    elseif index == 6 then  -- Rank Rename
        r = 0.64;
        g = 0.102;
        b = 0.102;
    elseif index == 7 or index == 8 then  -- Join/Rejoin
        r = 0.5;
        g = 1.0;
        b = 0;
    elseif index == 9 then  -- Banned Player
        r = 1.0;
        g = 0;
        b = 0;
    elseif index == 10 then -- Left Guild
        r = 0.5;
        g = 0.5;
        b = 0.5;
    elseif index == 11 then -- NameChange
        r = 0.90;
        g = 0.82;
        b = 0.62;
    elseif index == 12 then -- WhiteText
        r = 1.0;
        g = 1.0;
        b = 1.0;
    elseif index == 13 then -- Rejoining Player Warning (RED)
        r = 0.4;
        g = 0.71;
        b = 0.9;
    elseif index == 14 then -- Return from inactivity
        r = 0;
        g = 1.0;
        b = 0.87;
    elseif index == 15 then -- Event Announcement
        r = 0;
        g = 0.8;
        b = 1.0;
    elseif index == 16 then -- Recommendations
        r = 0.39;
        g = 0.0;
        b = 0.69;
    elseif index == 17 then -- Ban 
        r = 1.0;
        g = 0.0;
        b = 0.0;
    elseif index == 18 then  -- Ban Reason - White txt
        r = 1.0;
        g = 1.0;
        b = 1.0;
    end

    return r , g , b;
end

-- Method:          GRM.AddLog(int , string)
-- What it Does:    Adds a simple array to the Logreport that includes the indexcode for color, and the included changes as a string
-- Purpose:         For ease in adding to the core log.
GRM.AddLog = function ( indexCode , logEntry )
    table.insert ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] , { indexCode , logEntry } );
end

-- Method:          GRM.PrintLog(index)
-- What it Does:    Sets the color of the string to be reported to the frame (typically chat frame, or to the Log Report frame)
-- Purpose:         Color coding log and chat frame reporting.
GRM.PrintLog = function ( index , logReport , LoggingIt ) -- 2D array index and logReport ?? 
    -- index of what kind of report, thus determining color
    if ( index == 1 ) then -- Promoted
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage( logReport , 1.0 , 0.914 , 0.0 );
        end
    elseif ( index == 2 ) then -- Demoted
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage( logReport , 0.91 , 0.388 , 0.047 );
        end
    elseif ( index == 3 ) then -- Leveled
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage( logReport , 0.0 , 0.44 , 0.87 );
        end
    elseif ( index == 4 ) then -- Note
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 1.0 , 0.6 , 1.0 );
        end
    elseif ( index == 5 ) then -- Officer Note
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 1.0 , 0.094 , 0.93 );
        end
    elseif ( index == 6 ) then -- Rank Renamed
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 0.64 , 0.102 , 0.102 );
        end
    elseif ( index == 7 ) or ( index == 8 ) then -- Join and Rejoin!
        if LoggingIt then
            
        else
            chat:AddMessage( logReport, 0.5, 1.0, 0 );
        end
    elseif ( index == 9 ) then -- WARNING BANNED PLAYER REJOIN!
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 1.0 , 0.0 , 0.0 );
        end
    elseif ( index == 10 ) then -- Left the guild
        if LoggingIt then
            
        else
            chat:AddMessage( logReport, 0.5, 0.5, 0.5 );
        end
    elseif ( index == 11 ) then -- Namechanged
        if LoggingIt then
            
        else
            chat:AddMessage( logReport, 0.9 , 0.82 , 0.62 );
        end
    elseif ( index == 12 ) then -- WHITE TEXT IGNORE RGB COLORING
        if LoggingIt then

        else
            chat:AddMessage( logReport , 1.0 , 1.0 , 1.0 );
        end
    elseif ( index == 13 ) then -- Rejoining PLayer Custom Note Report
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0.4 , 0.71 , 0.9 )
        end
    elseif ( index == 14 ) then -- Player has returned from inactivity
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0 , 1.0 , 0.87 );
        end
    elseif ( index == 15 ) then -- For event notifications like upcoming anniversaries.
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0 , 0.8 , 1.0 );
        end
    elseif ( index == 16 ) then -- For Recommendations
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0.39 , 0.0 , 0.69 );
        end
    elseif ( index == 17 ) then -- For Banning
        if LoggingIt then

        else
            chat:AddMessage( logReport , 1.0 , 0.0 , 0.0 );
        end
    elseif ( index == 18 ) then -- For Banning Reason
        if LoggingIt then

        else
            chat:AddMessage( logReport , 1.0 , 1.0 , 1.0 );
        end
    
    elseif ( index == 99 ) then
        -- Addon Name Report Colors!
    end
end

-- Method:          GRM.Report ( string )
-- What it Does:    Sends to the main chat window messages on various events as deemed necessary to report on by addon creator.
-- Purpose:         To clean up the reporting and have a way to present the information blended into the default system UI
GRM.Report = function ( msg )
    -- chat:AddMessage ( string , R , G , B ) on 1.0 scale
    chat:AddMessage ( msg , 1.0 , 0.84 , 0 );
end

-- Method:          GRM.BuildEventCalendarManagerScrollFrame()
-- What it Does:    This populates properly the event ScrollFrame
-- Purpose:         Scroll Frame management for smoother User Experience
GRM.BuildEventCalendarManagerScrollFrame = function()
    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 220;
    local buffer = 5;

    GRM_AddEventScrollChildFrame.allFrameButtons = GRM_AddEventScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    for i = 1 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 do
        -- if font string is not created, do so.
        if not GRM_AddEventScrollChildFrame.allFrameButtons[i] then
            local tempButton = CreateFrame ( "Button" , "PlayerToAdd" .. i , GRM_AddEventScrollChildFrame ); -- Names each Button 1 increment up
            GRM_AddEventScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "PlayerToAddText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "PlayerToAddTitleText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end

        local EventButtons = GRM_AddEventScrollChildFrame.allFrameButtons[i][1];
        local EventButtonsText = GRM_AddEventScrollChildFrame.allFrameButtons[i][2];
        local EventButtonsText2 = GRM_AddEventScrollChildFrame.allFrameButtons[i][3];
        EventButtons:SetPoint ( "TOP" , GRM_AddEventScrollChildFrame , 7 , -99 );
        EventButtons:SetWidth ( 110 );
        EventButtons:SetHeight ( 19 );
        EventButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        EventButtonsText:SetText ( GRM.SlimName ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][1] ) );
        EventButtonsText:SetWidth ( 105 );
        EventButtonsText:SetWordWrap ( false );
        EventButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
        EventButtonsText:SetPoint ( "LEFT" , EventButtons );
        EventButtonsText:SetJustifyH ( "LEFT" );
        EventButtonsText2:SetText ( GRM.SlimName( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , " " ) - 1 ) ) ) .. string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] ) );
        EventButtonsText2:SetWidth ( 162 );
        EventButtonsText2:SetWordWrap ( false );
        EventButtonsText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
        EventButtonsText2:SetPoint ( "LEFT" , EventButtons , "RIGHT" , 5 , 0 );
        EventButtonsText2:SetJustifyH ( "LEFT" );
        -- Logic
        EventButtons:SetScript ( "OnClick" , function ( _ , button )
            if button == "LeftButton" then
                -- For highlighting purposes
                for j = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
                    if EventButtons ~= GRM_AddEventScrollChildFrame.allFrameButtons[j][1] then
                        GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                    else
                        GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                    end
                end
                GRM_AddEventFrameNameToAddText:SetText ( EventButtonsText2:GetText() );
                GRM_AddEventFrameNameToAddTitleText:SetText ( EventButtonsText: GetText() );

                if GRM_AddEventFrameStatusMessageText:IsVisible() then
                    GRM_AddEventFrameStatusMessageText:Hide();
                    GRM_AddEventFrameNameToAddText:Show();
                end
            end
        end);
        
        -- Now let's pin it!
        if i == 1 then
            EventButtons:SetPoint( "TOPLEFT" , 0 , - 5 );
            scrollHeight = scrollHeight + EventButtons:GetHeight();
        else
            EventButtons:SetPoint( "TOPLEFT" , GRM_AddEventScrollChildFrame.allFrameButtons[i - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
            scrollHeight = scrollHeight + EventButtons:GetHeight() + buffer;
        end
        EventButtons:Show();
    end
    -- Update the size -- it either grows or it shrinks!
    GRM_AddEventScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 145 ) + ( buffer * .5 );
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_AddEventScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_AddEventScrollFrame:EnableMouseWheel( true );
    GRM_AddEventScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
        local current = GRM_AddEventScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_AddEventScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_AddEventScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            GRM_AddEventScrollFrameSlider:SetValue ( current + 20 );
        elseif delta > 0 and current > 1 then
            GRM_AddEventScrollFrameSlider:SetValue ( current - 20 );
        end
    end);
end


-- Method:          GRM.RefreshAddEventFrame();
-- What it Does:    Refreshes the details, in case an event happes WHILE the window is open
-- Purpose:         QOL - Clean user experience. User it not forced to close window and reopen it to trigger updates. This will be used on the fly.
GRM.RefreshAddEventFrame = function()
    -- Clear the buttons first
    if GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
        for i = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
            GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
            GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
        end
    end
    -- Status Notification logic
    if #GRM_CalendarAddQue_Save > 0 then
        GRM_AddEventFrameStatusMessageText:SetText ( "Please Select\na Player" );
        GRM_AddEventFrameStatusMessageText:Show();
        GRM_AddEventFrameNameToAddText:Hide();
    else
        GRM_AddEventFrameStatusMessageText:SetText ( "No Events\nto Add");
        GRM_AddEventFrameStatusMessageText:Show();
        GRM_AddEventFrameNameToAddText:Hide();
    end
    -- Ok Building Frame!
    GRM.BuildEventCalendarManagerScrollFrame();
end

-- Method:          GRM.FinalReport()
-- What it Does:    Organizes flow of final report and send it to chat frame and to the logReport.
-- Purpose:         Clean organization for presentation.
GRM.FinalReport = function()
    local needToReport = false;

    if #GRM_AddonGlobals.TempNewMember > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        for i = 1 , #GRM_AddonGlobals.TempNewMember do
            GRM.PrintLog ( GRM_AddonGlobals.TempNewMember[i][1] , GRM_AddonGlobals.TempNewMember[i][2] , GRM_AddonGlobals.TempNewMember[i][3] );   -- Send to print to chat window
        end
    end
   
    if #GRM_AddonGlobals.TempRejoin > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        for i = 1 , #GRM_AddonGlobals.TempRejoin do
            GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][1] , GRM_AddonGlobals.TempRejoin[i][2] , GRM_AddonGlobals.TempRejoin[i][3] );            -- Same Comments on down
            GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][4] , GRM_AddonGlobals.TempRejoin[i][5] , GRM_AddonGlobals.TempRejoin[i][3] );
            if GRM_AddonGlobals.TempRejoin[i][6] then
                GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][7] , GRM_AddonGlobals.TempRejoin[i][8] );
            end
        end
    end

    if #GRM_AddonGlobals.TempBannedRejoin > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        for i = 1 , #GRM_AddonGlobals.TempBannedRejoin do
            GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][1] , GRM_AddonGlobals.TempBannedRejoin[i][2] , GRM_AddonGlobals.TempBannedRejoin[i][3] );
            GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][4] , GRM_AddonGlobals.TempBannedRejoin[i][5] , GRM_AddonGlobals.TempBannedRejoin[i][3] );
            if GRM_AddonGlobals.TempBannedRejoin[i][6] then
                GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][7] , GRM_AddonGlobals.TempBannedRejoin[i][8] );
            end
        end
    end

    if #GRM_AddonGlobals.TempLeftGuild > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] then
        for i = 1 , #GRM_AddonGlobals.TempLeftGuild do
            GRM.PrintLog ( GRM_AddonGlobals.TempLeftGuild[i][1] , GRM_AddonGlobals.TempLeftGuild[i][2] , GRM_AddonGlobals.TempLeftGuild[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempInactiveReturnedLog > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] then
        for i = 1 , #GRM_AddonGlobals.TempInactiveReturnedLog do
            GRM.PrintLog ( GRM_AddonGlobals.TempInactiveReturnedLog[i][1] , GRM_AddonGlobals.TempInactiveReturnedLog[i][2] , GRM_AddonGlobals.TempInactiveReturnedLog[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempNameChanged > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] then
        for i = 1 , #GRM_AddonGlobals.TempNameChanged do
            GRM.PrintLog ( GRM_AddonGlobals.TempNameChanged[i][1] , GRM_AddonGlobals.TempNameChanged[i][2] , GRM_AddonGlobals.TempNameChanged[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempLogPromotion > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
        for i = 1 , #GRM_AddonGlobals.TempLogPromotion do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogPromotion[i][1] , GRM_AddonGlobals.TempLogPromotion[i][2] , GRM_AddonGlobals.TempLogPromotion[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempLogDemotion > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
        for i = 1 , #GRM_AddonGlobals.TempLogDemotion do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogDemotion[i][1] , GRM_AddonGlobals.TempLogDemotion[i][2] , GRM_AddonGlobals.TempLogDemotion[i][3] );                          
        end
    end

    if #GRM_AddonGlobals.TempRankRename > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] then
        for i = 1 , #GRM_AddonGlobals.TempRankRename do
            GRM.PrintLog ( GRM_AddonGlobals.TempRankRename[i][1] , GRM_AddonGlobals.TempRankRename[i][2] , GRM_AddonGlobals.TempRankRename[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempLogLeveled > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] then
        for i = 1 , #GRM_AddonGlobals.TempLogLeveled do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogLeveled[i][1] , GRM_AddonGlobals.TempLogLeveled[i][2] , GRM_AddonGlobals.TempLogLeveled[i][3] );                  
        end
    end

    if #GRM_AddonGlobals.TempLogNote > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
        for i = 1 , #GRM_AddonGlobals.TempLogNote do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogNote[i][1] , GRM_AddonGlobals.TempLogNote[i][2] , GRM_AddonGlobals.TempLogNote[i][3] );         
        end
    end

    if #GRM_AddonGlobals.TempLogONote > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
        for i = 1 , #GRM_AddonGlobals.TempLogONote do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogONote[i][1] , GRM_AddonGlobals.TempLogONote[i][2] , GRM_AddonGlobals.TempLogONote[i][3] );  
        end
    end

    if #GRM_AddonGlobals.TempEventReport > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] then
        for i = 1 , #GRM_AddonGlobals.TempEventReport do
            GRM.PrintLog ( GRM_AddonGlobals.TempEventReport[i][1] , GRM_AddonGlobals.TempEventReport[i][2] , GRM_AddonGlobals.TempEventReport[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempEventRecommendKickReport > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] then
        for i = 1 , #GRM_AddonGlobals.TempEventRecommendKickReport do
            GRM.PrintLog ( GRM_AddonGlobals.TempEventRecommendKickReport[i][1] , GRM_AddonGlobals.TempEventRecommendKickReport[i][2] , GRM_AddonGlobals.TempEventRecommendKickReport[i][3]); 
        end
    end

    -- OK, NOW LET'S REPORT TO LOG FRAME IN REVERSE ORDER!!!

    if #GRM_AddonGlobals.TempEventRecommendKickReport > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempEventRecommendKickReport do
            GRM.AddLog ( GRM_AddonGlobals.TempEventRecommendKickReport[i][1] , GRM_AddonGlobals.TempEventRecommendKickReport[i][2]);                    
        end
    end

    if #GRM_AddonGlobals.TempEventReport > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempEventReport do
            GRM.AddLog( GRM_AddonGlobals.TempEventReport[i][1] , GRM_AddonGlobals.TempEventReport[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLogONote > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogONote do
            GRM.AddLog ( GRM_AddonGlobals.TempLogONote[i][1] , GRM_AddonGlobals.TempLogONote[i][2] );                    
        end
    end
 
    if #GRM_AddonGlobals.TempLogNote > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogNote do
            GRM.AddLog ( GRM_AddonGlobals.TempLogNote[i][1] , GRM_AddonGlobals.TempLogNote[i][2] );                    
        end
    end

    if #GRM_AddonGlobals.TempLogLeveled > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogLeveled do
            GRM.AddLog ( GRM_AddonGlobals.TempLogLeveled[i][1] , GRM_AddonGlobals.TempLogLeveled[i][2] );                    
        end
    end

    if #GRM_AddonGlobals.TempRankRename > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempRankRename do
            GRM.AddLog ( GRM_AddonGlobals.TempRankRename[i][1] , GRM_AddonGlobals.TempRankRename[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLogDemotion > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogDemotion do
            GRM.AddLog ( GRM_AddonGlobals.TempLogDemotion[i][1] , GRM_AddonGlobals.TempLogDemotion[i][2] );                           
        end
    end

    if #GRM_AddonGlobals.TempLogPromotion > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogPromotion do
            GRM.AddLog ( GRM_AddonGlobals.TempLogPromotion[i][1] , GRM_AddonGlobals.TempLogPromotion[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempNameChanged > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempNameChanged do
            GRM.AddLog ( GRM_AddonGlobals.TempNameChanged[i][1] , GRM_AddonGlobals.TempNameChanged[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempInactiveReturnedLog > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempInactiveReturnedLog do
            GRM.AddLog ( GRM_AddonGlobals.TempInactiveReturnedLog[i][1] , GRM_AddonGlobals.TempInactiveReturnedLog[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLeftGuild > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLeftGuild do
            GRM.AddLog ( GRM_AddonGlobals.TempLeftGuild[i][1] , GRM_AddonGlobals.TempLeftGuild[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempBannedRejoin > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempBannedRejoin do
            if GRM_AddonGlobals.TempBannedRejoin[i][6] then
                GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][7] , GRM_AddonGlobals.TempBannedRejoin[i][8] );
            end
            GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][4] , GRM_AddonGlobals.TempBannedRejoin[i][5] );
            GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][1] , GRM_AddonGlobals.TempBannedRejoin[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempRejoin > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempRejoin do
            if GRM_AddonGlobals.TempRejoin[i][6] then
                GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][7] , GRM_AddonGlobals.TempRejoin[i][8] );
            end
            GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][4] , GRM_AddonGlobals.TempRejoin[i][5] );
            GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][1] , GRM_AddonGlobals.TempRejoin[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempNewMember > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempNewMember do
            GRM.AddLog ( GRM_AddonGlobals.TempNewMember[i][1] , GRM_AddonGlobals.TempNewMember[i][2] );                                           -- Adding to the Log of Events
        end
    end


    -- Update the Add Event Window
    if #GRM_AddonGlobals.TempEventReport > 0 and GRM_AddEventFrame:IsVisible() then
        GRM.RefreshAddEventFrame();
    end

    -- Clear the changes.
    GRM.ResetTempLogs();

    -- Let's update the frames!
    if needToReport and GRM_RosterChangeLogFrame ~= nil and GRM_RosterChangeLogFrame:IsVisible() then
        GRM.BuildLog();
    end
    GRM_AddonGlobals.changeHappenedExitScan = false;
end  

-- Method           GRM.RecordChanges()
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
GRM.RecordChanges = function ( indexOfInfo , memberInfo , memberOldInfo , guildName )
    if GRM_AddonGlobals.changeHappenedExitScan then
        GRM.ResetTempLogs();
        GRM_AddonGlobals.changeHappenedExitScan = false;
        return;
    end
    local logReport = "";
    local simpleName = "";
    if memberInfo[1] == nil then
        simpleName = GRM.SlimName ( memberInfo );
    else
        simpleName = GRM.SlimName ( memberInfo[1] );
    end

    -- 2 = Guild Rank Promotion
    if indexOfInfo == 2 then
        local tempString = GRM.GetGuildEventString ( 2 , simpleName );
        if tempString ~= nil and tempString ~= "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. tempString .. " from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has been PROMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        end
        table.insert ( GRM_AddonGlobals.TempLogPromotion , { 1 , logReport , false } );
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        local tempString = GRM.GetGuildEventString ( 1 , simpleName );
        if tempString ~= nil and tempString ~= "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. tempString .. " from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has been DEMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        end
        table.insert ( GRM_AddonGlobals.TempLogDemotion , { 2 , logReport , false } );
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        if numGained > 1 then
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " levels)" );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " level)" );
        end
        table.insert ( GRM_AddonGlobals.TempLogLeveled , { 3 , logReport , false } );
    -- 5 = note
    elseif indexOfInfo == 5 then
        logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. "'s PUBLIC Note has Changed\nFrom:  " .. memberOldInfo[7] .. "\nTo:       " .. memberInfo[5] );
        table.insert ( GRM_AddonGlobals.TempLogNote , { 4 , logReport , false } );
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. "'s OFFICER Note has Changed\nFrom:  " .. memberOldInfo[8] .. "\nTo:       " .. memberInfo[6] );
        table.insert ( GRM_AddonGlobals.TempLogONote , { 5 , logReport , false } );
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = ( GRM.GetTimestamp() .. " : Guild Rank Renamed from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        table.insert ( GRM_AddonGlobals.TempRankRename , { 6 , logReport , false } );
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        local rejoin = false;
        local tempStringInv = GRM.GetGuildEventString ( 4 , simpleName ); -- For determining who did the invite.
    
            for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] do -- Number of players that have left the guild.
                if memberInfo[1] == GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][1] then
                    -- MATCH FOUND - Player is RETURNING to the guild!
                    -- Now, let's see if the player was banned before!
                    local numTimesInGuild = #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][20];
                    local numTimesString = "";
                    if numTimesInGuild > 1 then
                        numTimesString = ( simpleName .. " has Been in the Guild " .. numTimesInGuild .. " Times Before" );
                    else
                        numTimesString = ( simpleName .. " is Returning for the First Time." );
                    end

                    local timeStamp = GRM.GetTimestamp();
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][17][1] == true then
                        -- Player was banned! WARNING!!!
                        local reasonBanned = GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][18];
                        if reasonBanned == nil or reasonBanned == "" then
                            reasonBanned = "<None Given>";
                        end
                        local warning = "";
                        if tempStringInv ~= nil and tempStringInv ~= "" then
                            warning = ( "     " .. timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. simpleName .. " has REJOINED the guild but was previously BANNED! \nInvited by: " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) );
                        else
                            warning = ( "     " .. timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. simpleName .. " has REJOINED the guild but was previously BANNED!" );
                        end
                        logReport = ("Date of Ban:                       " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15]] .. " (" .. GRM.GetTimePassed ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16]] ) .. " ago)\nReason:                               " .. reasonBanned .. "\nDate Originally Joined:    " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][20][1] .. "\nOld Guild Rank:                 " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][19] .. "\n" .. numTimesString );
                        local custom = "";
                        local toReport = { 9 , warning , false , 12 , logReport , false , 13 , custom };
                        -- Extra Custom Note added for returning players.
                        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23] ~= "" then
                            custom = ( "Notes:     " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23] );
                            toReport[6] = true;
                            toReport[8] = custom;
                        end
                        table.insert ( GRM_AddonGlobals.TempBannedRejoin , toReport );
                    else
                        -- No Ban found, player just returning!
                        if tempStringInv ~= nil and tempStringInv ~= "" then
                            logReport = ( timeStamp .. " : " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) .. " has REINVITED " .. simpleName .. " to the guild (LVL: " .. memberInfo[4] .. ")");
                        else
                            logReport = ( timeStamp .. " : " .. simpleName .. " has REJOINED the guild (LVL: " .. memberInfo[4] .. ")");
                        end
                        local custom = "";
                        local details = ( "Date Left:                           " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15]] .. " (" .. GRM.GetTimePassed(GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16]]) .. " ago)\nDate Originally Joined:    " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][20][1] .. "\nOld Guild Rank:                 " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][19] .. "\n" .. numTimesString );
                        local toReport = { 7 , logReport , false , 12 , details , false , 13 , custom };
                        -- Extra Custom Note added for returning players.
                        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23] ~= "" then
                            custom = ( "Notes:     " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23]) ;
                            toReport[6] = true;
                            toReport[8] = custom;
                        end
                        table.insert ( GRM_AddonGlobals.TempRejoin , toReport );
                    end
                    rejoin = true;
                    -- AddPlayerTo MemberHistory

                    -- Adding timestamp to new Player.
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                        for h = 1 , GRM.GetNumGuildies() do
                            local name ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                            if name == memberInfo[1] and oNote == "" then
                                GuildRosterSetOfficerNote( h , ( "Rejoined: " .. GRM.Trim ( string.sub ( GRM.GetTimestamp() , 1 , 10 ) ) ) );
                                break;
                            end
                        end
                    end
                    -- Do extra query
                    GuildRoster();

                    GRM.AddMemberRecord( memberInfo , true , GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j] , guildName );

                    
                    -- Removing Player from LeftGuild History (Yes, they will be re-added upon leaving the guild.)
                    table.remove ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] , j );
                    break;
                end
            end
                
        if rejoin ~= true then
            -- New Guildie. NOT a rejoin!
            local tempTimeStamp = GRM.GetTimestamp();
            local timeEpoch = time();
            if tempStringInv ~= nil and tempStringInv ~= "" then
                logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has JOINED the guild! (LVL: " .. memberInfo[4] .. ") - Invited By: " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) );
            else
                logReport = ( tempTimeStamp .. " : " .. simpleName .. " has JOINED the guild! (LVL: " .. memberInfo[4] .. ")");
            end
            local finalTStamp = ( "Joined: " .. GRM.Trim ( string.sub ( GRM.GetTimestamp() , 1 , 10 ) ) );

            -- Adding timestamp to new Player.
            local currentOfficerNote = memberInfo[6];
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                for s = 1 , GRM.GetNumGuildies() do
                    local name ,_,_,_,_,_,_, oNote = GetGuildRosterInfo ( s );
                    if name == memberInfo[1] and ( oNote == "" or oNote == nil ) then
                        GuildRosterSetOfficerNote ( s , finalTStamp );
                        break;
                    end
                end
            end
            -- Do extra query
            GuildRoster();

            -- Adding to global saved array, adding to report 
            GRM.AddMemberRecord ( memberInfo , false , nil , guildName );
            table.insert ( GRM_AddonGlobals.TempNewMember , { 8 , logReport , false } );
           
            -- adding join date to history and rank date.
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                     -- Number of players that have left the guild.
                if memberInfo[1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
                    -- Add the tempTimeStamp to officer note... this avoids report spam

                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] = string.sub ( tempTimeStamp , 1 , string.find ( tempTimeStamp , "'" ) + 2 );  -- Date of Last Promotion
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][13] = timeEpoch;                                                       -- Date of Last Promotion Epoch time.
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , tempTimeStamp );
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] , timeEpoch );
                    -- For Event tracking!
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][1][2] = tempTimeStamp;

                    if currentOfficerNote == nil or currentOfficerNote == "" then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] = finalTStamp;
                        -- For SYNC
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][1] = tempTimeStamp;
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][2] = timeEpoch;

                    elseif currentOfficerNote ~= nil and currentOfficerNote ~= "" then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] = currentOfficerNote;
                        -- For SYNC
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][1] = "1 Jan '01 4:20am";  -- Behind the scenes numbers ensuring you are not the person with most current sync info.
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][2] = 978348001;
                    end
                    break;
                end
            end
        end
    -- 11 = Player Left  
    elseif indexOfInfo == 11 then
        local timestamp = GRM.GetTimestamp();
        local tempStringRemove = GRM.GetGuildEventString ( 3 , simpleName ); -- Kicked from the guild.
        if tempStringRemove ~= nil and tempStringRemove ~= "" then
            logReport = ( timestamp .. " : " .. tempStringRemove );
        else
            logReport = ( timestamp .. " : " .. simpleName .. " has Left the guild" );
        end
        -- Finding Player's record for removal of current guild and adding to the Left Guild table.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
            if memberInfo[1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then -- Matching member leaving to guild saved entry
                -- Found!
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15], timestamp );                                  -- leftGuildDate
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16], time() );                                     -- leftGuildDateMeta
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { "|cFFC41F3BLeft Guild" , GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) } );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][19] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4];         -- oldRank on leaving.
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] == 0 then                                                 -- Let it default to date addon was installed if date joined was never given
                    table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] );   -- oldJoinDate
                    table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] );   -- oldJoinDateMeta
                end
                -- Adding to LeftGuild Player history library
                table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j] );
                        
                -- Removing it from the alt list
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                    -- Let's add them to the end of the report
                    local countAlts = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                    for m = 1 , countAlts do
                        if m == 1 then
                            logReport = logReport .. "\n ALTS IN GUILD: " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] );
                        else
                            logReport = logReport .. ", " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] );
                        end

                        -- Just show limited number of alts...
                        if m == 5 and m < countAlts then
                            logReport = logReport .. " (+" .. ( countAlts - m ) .. " More)";
                            break;
                        end
                    end

                    GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] ,GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , guildName , false , 0 );
                end
                -- removing from active member library
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , j );
                break;
            end
        end
        table.insert( GRM_AddonGlobals.TempLeftGuild , { 10 , logReport , false } );
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( memberOldInfo[1] ) .. " has Name-Changed to ".. simpleName );
        table.insert ( GRM_AddonGlobals.TempNameChanged , { 11 , logReport , false } );
    -- 13 = Inactive Members Return!
    elseif indexOfInfo == 13 then
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( memberInfo ) .. " has Come ONLINE after being INACTIVE for " .. GRM.HoursReport ( memberOldInfo ) );
        table.insert( GRM_AddonGlobals.TempInactiveReturnedLog , { 14 , logReport , false } );
    end
end

-- Method:          GRM.ReportLastOnline( string , string , int )
-- What it Does:    Like the "GRM.CheckPlayerChanges()", this one does a one time scan on login or reload of notable changes of players who have returned from being offline for an extended period of time.
-- Purpose:         To inform the guild leader that a guildie who has not logged in in a while has returned!
GRM.ReportLastOnline = function ( name , guildName , index )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                           -- Scanning through roster so can check changes (position 1 is guild name, so no need to rescan)
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then                 -- Player matched.
            local hours = GRM.GetHoursSinceLastOnline ( index );            -- index is location in in-game Guild Roster for lookup to only query server one time, not multiple.
            
            -- Report player return after being inactive!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] > hours then  -- Player has logged in after having been inactive for greater than 2 weeks!
                GRM.RecordChanges ( 13 , name , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] , guildName );      -- Recording the change in hours to log
            end

            -- Recommend to kick offline if player has the power to!
            if CanGuildRemove() then
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] and not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] ) <= hours then
                    -- Player has been offline for longer than the given time... REPORT RECOMMENDATION TO KICK!!!
                    local logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( name ) .. " has been OFFLINE for " .. GRM.HoursReport ( hours ) .. ". Kick Recommended!" );
                    table.insert ( GRM_AddonGlobals.TempEventRecommendKickReport , { 16 , logReport , false } );
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] = true;    -- No need to report more than once.
                elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] ) > hours  then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] = false;
                end
            end
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] = hours;                   -- Set new hours since last login.
            break;
        end
    end
end

-- Method:          GRM.CheckPlayerChanges ( array , string )
-- What it Does:    Scans through guild roster and re-checks for any  (Will only fire if guild is found!)
-- Purpose:         Keep whoever uses the addon in the know instantly of what is going and changing in the guild.
GRM.CheckPlayerChanges = function ( metaData , guildName )
    if GRM_AddonGlobals.changeHappenedExitScan then
        GRM.ResetTempLogs();
        GRM_AddonGlobals.changeHappenedExitScan = false;
        return;
    end
    local newPlayerFound;
    local guildRankIndexIfChanged = -1; -- Rank index must start below zero, as zero is Guild Leader.

    -- new member and leaving members arrays to check at the end
    local newPlayers = {};
    local leavingPlayers = {};

    for j = 1 , #metaData do
        newPlayerFound = true;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do -- Number of members in guild (Position 1 = guild name, so we skip)
            if metaData[j][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] then
                newPlayerFound = false;
                for k = 2 , 14 do
                    
                    if k ~= 3 and k < 7 and metaData[j][k] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][k + 2] then -- CHANGE FOUND! New info and old info are not equal!
                        -- Ranks
                        if k == 2 and metaData[j][3] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] and metaData[j][2] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] then -- This checks to see if guild just changed the name of a rank.
                            -- Promotion Obtained
                            if metaData[j][3] < GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                                GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            -- Demotion Obtained
                            elseif metaData[j][3] > GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                                GRM.RecordChanges ( 9 , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            end
                            local timestamp = GRM.GetTimestamp();
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = metaData[j][2]; -- Saving new rank Info
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] = metaData[j][3]; -- Saving new rank Index Info
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ) -- Time stamping rank change
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = time();

                            -- For SYNC
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13];

                            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] } ); -- New rank, date, metatimestamp
                            
                            -- Update the player index if it is the player themselves that received the change in rank.
                            if metaData[j][1] == GRM_AddonGlobals.addonPlayerName then
                                GRM_AddonGlobals.playerIndex = metaData[j][3];
                            end
                        elseif k == 2 and metaData[j][2] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] and metaData[j][3] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                            -- RANK RENAMED!
                            if guildRankIndexIfChanged ~= metaData[j][3] then -- If alrady been reported, no need to report it again.
                                GRM.RecordChanges ( 8 , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                guildRankIndexIfChanged = metaData[j][3]; -- Avoid repeat reporting for each member of that rank upon a namechange.
                            end
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = metaData[j][2]; -- Saving new Info
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25]][1] = metaData[j][2];   -- Adjusting the historical name if guild rank changes.
                        -- Level
                        elseif k == 4 then
                            GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] = metaData[j][4]; -- Saving new Info
                        -- Note
                        elseif k == 5 then
                            GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] = metaData[j][5];
                        -- Officer Note
                        elseif k == 6 and CanViewOfficerNote() then
                            if metaData[j][k] == nil or GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] == nil then
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] = metaData[j][6];
                            else
                                GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] = metaData[j][6];
                            end
                        end

                        -- Zone Last Spotted
                    elseif k == 9 then
                        if ( metaData[j][13] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= metaData[j][9] ) or GRM_AddonGlobals.OnFirstLoad then     -- If player is currently online and in a different zone! - Also, you need to reset on first load anyway because if player has not zone-changed when you login, you will get crazy long hours and it will be wrong.
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] = time();                                                                          -- Resetting the time on hitting this zone.
                        end
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] = metaData[j][9];
                    -- Player non-account wide achievement points total
                    elseif k == 10 then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][29] = metaData[j][10];
                    -- Player is not online in-game, but is on Mobile armory app for chat
                    elseif k == 11 then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][30] = metaData[j][11];
                    -- GuilD reputation ( 8 = exalted)
                    elseif k == 12 then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][31] = metaData[j][12];
                    elseif k == 13 then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] ~= metaData[j][13] then
                            -- Status has changed!!!
                            -- Let's see if there is a list to check
                            if #GRM_AddonGlobals.ActiveStatusQue > 0 then
                                -- There is! Let's see if player is on notification list to announce if returns from being AFK.
                                if metaData[j][13] then
                                    -- Nice, player is now active and was not before!!! Let's see if they are on the list!
                                    for m = 1 , #GRM_AddonGlobals.ActiveStatusQue do
                                        if metaData[j][1] == GRM_AddonGlobals.ActiveStatusQue[m] then
                                            -- Player Has been found!
                                            chat:AddMessage ( "\n----------------------------------------------------------\n|cffffffffNOTIFICATION: " .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[m] ) .. " is now ONLINE!\n|cffff0000----------------------------------------------------------\n\n" , 1.0 , 0 , 0 );
                                            table.remove ( GRM_AddonGlobals.ActiveStatusQue , m );
                                            break;
                                        end
                                    end
                                else
                                    for m = 1 , #GRM_AddonGlobals.ActiveStatusQue do
                                        if metaData[j][1] == GRM_AddonGlobals.ActiveStatusQue[m] then
                                            -- Player Has been found!
                                            chat:AddMessage ( "\n----------------------------------------------------------\n|cffffffffNOTIFICATION: " .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[m] ) .. " is now OFFLINE!\n|cffff0000----------------------------------------------------------\n\n" , 1.0 , 0 , 0 );
                                            table.remove ( GRM_AddonGlobals.ActiveStatusQue , m );
                                            break;
                                        end
                                    end
                                end
                            end

                            -- Saving new info!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] = metaData[j][13];
                        end
                    elseif k == 14 then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] ~= metaData[j][14] then
                            -- Status has changed!!!
                            -- Let's see if there is a list to check
                            if #GRM_AddonGlobals.ActiveCheckQue > 0 then
                                -- There is! Let's see if player is on notification list to announce if returns from being AFK.
                                if metaData[j][14] == 0 then
                                    -- Nice, player is now active and was not before!!! Let's see if they are on the list!
                                    for m = 1 , #GRM_AddonGlobals.ActiveCheckQue do
                                        if metaData[j][1] == GRM_AddonGlobals.ActiveCheckQue[m] then
                                            -- Player Has been found!
                                            chat:AddMessage ( "\n---------------------------------------------------------------\n|cffffffffNOTIFICATION: " .. GRM.SlimName ( GRM_AddonGlobals.ActiveCheckQue[m] ) .. " is No Longer AFK or Busy!\n|cffff0000---------------------------------------------------------------\n\n" , 1.0 , 0 , 0 );
                                            table.remove ( GRM_AddonGlobals.ActiveCheckQue , m );
                                            break;
                                        end
                                    end
                                end
                            end

                            -- Saving new info!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] = metaData[j][14];
                        end
                    end
                end
                break;
            end
        end
        -- NEW PLAYER FOUND! (Maybe)
        if newPlayerFound then
            newPlayers[#newPlayers + 1] = {};     -- Player "maybe" found. Let's store info to compare notes of players that left guild in case of name change.
            newPlayers[#newPlayers] = metaData[j];
        end
    end
    -- Checking if any players left the guild
    local playerLeftGuild;
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        playerLeftGuild = true;
        for k = 1 , #metaData do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == metaData[k][1] then
                playerLeftGuild = false;
                break;
            end
        end
        -- PLAYER LEFT! (maybe)
        if playerLeftGuild then
            table.insert ( leavingPlayers , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j] );
        end
    end
    -- Final check on players that left the guild to see if they are namechanges.CanViewOfficerNote
    local playerNotMatched = true;
    if #leavingPlayers > 0 and #newPlayers > 0 then
        for k = 1 , #leavingPlayers do
            for j = 1 , #newPlayers do
               if leavingPlayers[k][9] == newPlayers[j][7] -- Class is the sane
                    and leavingPlayers[k][5] == newPlayers[j][3]  -- Guild Rank is the same
                        and ( newPlayers[j][10] >= leavingPlayers[k][29] - 50 and newPlayers[j][10] <= leavingPlayers[k][29] + 100 ) then -- In other words, sometimes patches can remove achievements, so gives negative cushion, but assumes they didn't gain 100 + pts since last you noticed

                    -- PLAYER IS A NAMECHANGE!!!
                    playerNotMatched = false;
                    GRM.RecordChanges ( 12 , newPlayers[j] , leavingPlayers[k] , guildName );
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if leavingPlayers[k][9] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] -- Mathching the Leaving player to historical index so it can be identified and new name stored.
                            and leavingPlayers[k][5] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5]
                                and leavingPlayers[k][29] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][29] then

                            -- Need to remove him from list of alts IF he has a lot of alts...
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11] > 0 then
                                local tempNameToReAddAltTo = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11][1][1];
                                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , guildName , false , 0 );
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] = newPlayers[j][1]; -- Changing the name...
                                -- Now, let's re-add him back.
                                GRM.AddAlt ( tempNameToReAddAltTo , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , guildName , false , 0 );
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] = newPlayers[j][1]; -- Changing the name!
                            end

                            break
                        end
                    end
                    -- since namechange identified, also need to remove name from newPlayers array now.
                    if #newPlayers == 1 then
                        newPlayers = {}; -- Clears the array of the one name.
                    else
                        local tempArray = {};
                        local count = 1;
                        for r = 1 , #newPlayers do -- removing the namechange from newPlayers list.
                            if r ~= j then  -- j = the position of the nameChanged player, so I am SKIPPING the nameChange player when adding to new array.
                                tempArray[count] = {};
                                tempArray[count] = newPlayers[r];
                                count = count + 1;
                            end
                        end
                        newPlayers = {};
                        newPlayers = tempArray;
                    end
                end
            end
            -- Player not matched! For sure this player has left the guild!
            if playerNotMatched then
                GRM.RecordChanges ( 11 , leavingPlayers[k] , leavingPlayers[k] , guildName );
            end
        end
    elseif #leavingPlayers > 0 then
        for k = 1 , #leavingPlayers do
            GRM.RecordChanges ( 11 , leavingPlayers[k] , leavingPlayers[k] , guildName );
        end
    end
    if #newPlayers > 0 then
        for k = 1 , #newPlayers do
            GRM.RecordChanges ( 10 , newPlayers[k] , newPlayers[k] , guildName );
        end
    end
end

-- Method:          GRM.GuildNameChanged()
-- What it Does:    Returns true if the player's guild is the same, it just changed its name
-- Purpose:         Good to know... what a pain it would be if you had to reset all of your settings
GRM.GuildNameChanged = function ( currentGuildName )
    local result = false;
    -- For each guild
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] ~= currentGuildName then
            local numEntries = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ] - 1;     -- Total number of entries, minus 1 since first index is guild name.
            local count = 0;
            -- for each member in that guild
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ] do
                for r = 1 , GRM.GetNumGuildies() do
                    local name = GetGuildRosterInfo ( r );
                    if name == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][j][1] then
                        count = count + 1;
                        break;
                    end
                end

                if j == 10 and count == 0 then
                    break;
                end
            end
            if ( count / numEntries ) >= 0.5 then       -- Default threshold is > 50% matches. I would think it would be higher, but this keeps it so player can be 2 person guild, kick 1 person, change name, and it will stiill stay in threshold.
                -- Player is within the threshold
                result = true;
                local tempGuildName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1];

                -- Changing the name of the guild in the saved data to the new name.
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] = currentGuildName;

                -- Need to change index name of the left player history too.
                for s = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ] do
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][s][1] == tempGuildName then
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][s][1] = currentGuildName;
                        break;
                    end
                end

                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.BuildNewRoster()
-- What it does:    Rebuilds the roster to check against for any changes.
-- Purpose:         To track for guild changes of course!
GRM.BuildNewRoster = function()
    local roster = {};

    -- Checking if Guild Found or Not Found, to pre-check for Guild name tag.
    if GRM_AddonGlobals.faction == "Horde" then
        GRM_AddonGlobals.FID = 1;
    else
        GRM_AddonGlobals.FID = 2;
    end
    local guildNotFound = true;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
            guildNotFound = false;
            break;
        end
    end

    for i = 1 , GRM.GetNumGuildies() do
        local name , rank , rankInd , level , _ , zone , note , officerNote , online , status , class , achievementPoints , _ , isMobile , _ , rep = GetGuildRosterInfo ( i ); 
        roster[i] = {};
        roster[i][1] = name
        roster[i][2] = rank;
        roster[i][3] = rankInd;
        roster[i][4] = level;
        roster[i][5] = note;
        if CanViewOfficerNote() then -- Officer Note permission to view.
            roster[i][6] = officerNote;
        else
            roster[i][6] = nil; -- Set Officer note to nil if needed.
        end

        roster[i][7] = class;
        roster[i][8] = GRM.GetHoursSinceLastOnline ( i ); -- Time since they last logged in in hours.
        roster[i][9] = zone;
        roster[i][10] = achievementPoints;
        roster[i][11] = isMobile;
        roster[i][12] = rep;
        roster[i][13] = online;
        roster[i][14] = status;

        -- Items to check One time check on login
        -- Check players who have not been on a long time only on login or addon reload.
        if guildNotFound ~= true then
            GRM.ReportLastOnline ( name , GRM_AddonGlobals.guildName , i );
        end

    end
        -- Build Roster for the first time if guild not found.
    if #roster > 0 then
        if guildNotFound then
            -- See if it is a Guild NameChange first!
            if GRM.GuildNameChanged ( GRM_AddonGlobals.guildName ) then
                local logEntry = "\n\n-------------------------------------------------------------\n" .. GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. "'s Guild has Name-Changed to \n\"" .. GRM_AddonGlobals.guildName .. "\"\n-------------------------------------------------------------\n\n"
                GRM.PrintLog ( 15 , logEntry , false );   
                GRM.AddLog ( 15 , logEntry ); 
                -- ADD NEW GUILD VALUES
            else
                print ( "\nGUILD ROSTER MANAGER\nAnalyzing guild for the first time...\nBuilding Profiles on ALL \"" .. GRM_AddonGlobals.guildName .. "\" members.\n" );
                -- This reiterates over this, because sometimes it can have a delay. This ensures it is secure.
                if GRM_AddonGlobals.faction == "Horde" then
                    GRM_AddonGlobals.FID = 1;
                else
                    GRM_AddonGlobals.FID = 2;
                end
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                        -- Creating a position in table for Guild Member Data
                table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                    -- Creating a position in Left Player Table for Guild Member Data
                table.insert ( GRM_LogReport_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                                 -- Logreport, let's create an index
                table.insert ( GRM_CalendarAddQue_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                            -- AddQue, let's create an index for the guild

                -- SET THE INDEXES PROPERLY
                for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                    if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] ==  GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.logGID = i;
                        break;
                    end
                end
                for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID] do
                    if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.saveGID = i;
                        break;
                    end
                end
                
                for i = 1 , #roster do
                    -- Add last time logged in initial timestamp.
                    GRM.AddMemberRecord ( roster[i] , false , nil , GRM_AddonGlobals.guildName );
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ]][24] = roster[i][8];   -- Setting Timestamp for the first time only.
                end
            end
        else
            GRM.CheckPlayerChanges ( roster , GRM_AddonGlobals.guildName );
        end
    end
end


--------------------------------------
------ END OF METADATA LOGIC ---------
--------------------------------------


--------------------------------------
------ GROUP METHODS AND LOGIC -------
--------------------------------------

-- Method:          GRM.IsGuildieInSameGroup ( string )  -- proper format of the name should be "PlayerName-ServerName"
-- What it Does:    Returns true if the given guildie is grouped with you.
-- Purpose:         To determine if you are grouped with a guildie!
GRM.IsGuildieInSameGroup = function ( guildMember )
    local result = false;
    for i = 1 , GetNumGroupMembers() do
        local raidPlayer = GetRaidRosterInfo ( i );
        if raidPlayer == GRM.SlimName ( guildMember ) then
            result = true;
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetAllGuildiesOnline()
-- What it Does:    Returns a table of names of all guildies that are currently online in the guild
-- Purpose:         Group management info and reporting. Pretty much some UI features, but possibly will be expanded upon.
GRM.GetAllGuildiesOnline = function()
    local listOfNames = {};
    for i = 1 , GRM.GetNumGuildies() do
        local name , _ , _ , _ , _ , _ , _ , _ , online = GetGuildRosterInfo ( i );
        if online then
            table.insert ( listOfNames , GRM.SlimName ( name) );
        end
    end
    return listOfNames;
end

-- Method:          GRM.GetGroupUnitsOfflineOrAFK()
-- What it Does:    Returns a 2D array of the names of the players (not including server names) that are offline and afk in group
-- Purpose:         Mainly to notify the group leader who is AFK, possibly to make room for others in raid by informing leader of offline members.
GRM.GetGroupUnitsOfflineOrAFK = function()
    local offline = {};
    local afkMembers = {};
    
    for i = 1 , GetNumGroupMembers() do
        local raidPlayer , _ , _ , _ , _ , _ , _ , isOnline = GetRaidRosterInfo ( i );
        if isOnline ~= true then
            table.insert ( offline , raidPlayer );
        end
        if isOnline and UnitIsAFK( raidPlayer ) then
            table.insert ( afkMembers , raidPlayer );
        end        
    end
    local result = { offline , afkMembers };
    return result;
end

-- Method:          GRM.GetNumGuildiesInGroup()
-- What it Does:    Returns the int number of guildies you are grouped with, either in party or raid.
-- Purpose:         To report how many players are grouped with you from the guild. Helps you realize who is grouped with you
GRM.GetNumGuildiesInGroup = function()
    local result = 0;
    local allGuildiesOnline = GRM.GetAllGuildiesOnline();
    for i = 1 , GetNumGroupMembers() do
        local groupMemberName = GetRaidRosterInfo ( i );
        for j = 1 , #allGuildiesOnline do
            if groupMemberName == allGuildiesOnline[j] then
                result = result + 1;
                break;
            end
        end
        if result >= #allGuildiesOnline then
            -- No need to keep scanning, just break out.
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetGuildMemberRankID ( string )
-- What it does:    Returns the rank index of the given player's name, or 0 if unable to find player
-- Purpose:         Rank needs to be known in certain circumstances, like knowing if something was a promotion or a demotion.
GRM.GetGuildMemberRankID = function( name )
    local result = -1;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
            result = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][5];
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetRankPermissions(...)
-- What it Does:    Returns an array of booleans, in string form, of all the permissions of the guild rank tagged
-- Purpose:         Useful to keep track of permissions, such as if player has access to guild chat channel. If restricted, sync will not work.
-- GuildControlSetRank ( rankIndex ) needs to be set before using
GRM.GetRankPermissions = function ( ... ) -- Note, Guild Leader = 1, so next highest rank is index = 2 
    local result = {};
    
    for i = 1 , select ( "#" , ... ) do 
        table.insert ( result , tostring ( select ( i , ... ) ) );
    end
    
    return result;
end

-- Method:          GRM.IsGuildChatEnabled()
-- What it Does:    Returns true of the player has permission to use the guild chat channel.
-- Purpose:         If guild chat channel is restricted then sync cannot be enabled either...
GRM.IsGuildChatEnabled = function()
    GuildControlSetRank ( GRM.GetGuildMemberRankID ( GRM_AddonGlobals.addonPlayerName ) + 1 );
    if GRM.GetRankPermissions (  GuildControlGetRankFlags() )[1] == "true" then
        return true;
    else
        return false;
    end
end

-- Method:          GRM.AddPlayerActiveCheck ( string )
-- What it Does:    Adds the given player to the "Notify when returns to ACTIVE" status.
-- Purpose:         So player can be notified when someone comes back from being AFK!
GRM.AddPlayerActiveCheck = function ( name )
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.ActiveCheckQue do
        if name == GRM_AddonGlobals.ActiveCheckQue[i] then
            isFound = true;
        end
    end
    
    if not isFound then
        table.insert ( GRM_AddonGlobals.ActiveCheckQue , name );
        chat:AddMessage ( "|cffff0000Notification Set: |cffffd600Report When " .. GRM.SlimName  ( name ) .. " is ACTIVE Again!" );
    else
        print ( "Notification Has Already Been Arranged..." );
    end
end

GRM.AddPlayerOnlineStatusCheck = function ( name )
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.ActiveStatusQue do
        if name == GRM_AddonGlobals.ActiveStatusQue[i] then
            isFound = true;
        end
    end
    
    if not isFound then
        table.insert ( GRM_AddonGlobals.ActiveStatusQue , name );
        chat:AddMessage ( "|cffff0000Notification Set: |cffffd600Report When " .. GRM.SlimName  ( name ) .. " Comes Online!" );
    else
        print ( "Notification Has Already Been Arranged..." );
    end
end

GRM.AddPlayerOfflineStatusCheck = function ( name )
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.ActiveStatusQue do
        if name == GRM_AddonGlobals.ActiveStatusQue[i] then
            isFound = true;
        end
    end
    
    if not isFound then
        table.insert ( GRM_AddonGlobals.ActiveStatusQue , name );
        chat:AddMessage ( "|cffff0000Notification Set: |cffffd600Report When " .. GRM.SlimName  ( name ) .. " Goes Offline!" );
    else
        print ( "Notification Has Already Been Arranged..." );
    end
end

----------------------
-- EVENT TRACKING!!!!!
----------------------

-- Method:          GRM.GetEventYear ( string )
-- What it Does:    Returns the year of the given event from timestamp as a string
-- Purpose:         Keep code clutter down, put this block in reusable form.
GRM.GetEventYear = function ( timestamp )
    -- timestamp format = "Day month year hour min"
    local count = 0;
    local result = "";
    if timestamp ~= "" and timestamp ~= nil then
        for i = 1 , #timestamp do
            if string.sub ( timestamp , i , i ) == " " then
                count = count + 1;
            end
            if count == 2 then
                result = result .. "20" .. string.sub ( timestamp , i + 2 , i + 4 );
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.GetEventMonth ( string )
-- What it Does:    Returns the 3 letter string of the name of the month of the event.
-- Purpose:         Again, avoid code cludder. For event tracking, knowing exact date is essential.
GRM.GetEventMonth = function ( timestamp )
    if timestamp == "" or timestamp == nil then
        return "";
    else
        return string.sub ( timestamp , string.find ( timestamp , " " ) + 1 , string.find ( timestamp , " " ) + 3 );
    end
end

-- Method:          GRM.GetEventDay ( string )
-- What it Does:    Returns the number of the day, as a string, based on day of the month for given event timestamp
-- Purpose:         Important to know what day event should happen on.
GRM.GetEventDay = function ( timestamp )
    if timestamp == "" or timestamp == nil then
        return "";
    else
        return string.sub ( timestamp , 1 , string.find ( timestamp , " " ) - 1 );
    end
end

-- Method:          GRM.IsCalendarEventAlreadyAdded ( string , int , int , int )
-- What it Does:    Returns true if the event has already been added to the calendar 
-- Purpose:         If the player wipes his save history, it does not wipe what is added to in-game calendar. This just double-checks to avoid double adding.
GRM.IsCalendarEventAlreadyAdded = function ( eventName , year , month , day )
    eventName = GRM.SlimName( string.sub ( eventName , 0 , ( string.find ( eventName , " " ) - 1 ) ) ) .. string.sub ( eventName , string.find ( eventName , " " ) , #eventName );
    local result = false;
    local monthIndex = 0;
    local m , y;

    for i = 0 , 17 do                       -- Let's get to the right month on the calendar
        m , y = CalendarGetMonth ( i );
        if m == month and y == year then
            monthIndex = i;
            break;
        end
    end
    for i = 1 , CalendarGetNumDayEvents ( monthIndex , day ) do         -- Let's look at all the events on the day of the event
        if eventName == CalendarGetDayEvent ( monthIndex , day, i ) then
            result = true;
            break;
        end
    end
    return result;
end


-- Method:          GRM.IsOnAnnouncementList ( string , string )
-- What it Does:    returns true if the player is in the que to add to the calendar
-- Purpose:         Avoid double adding to que, and basic logic checking.
GRM.IsOnAnnouncementList = function ( name , eventName )
    local result = false;
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
        if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] == name and GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] == eventName then
            result = true;
            break; 
        end
    end
    return result;
end

-- Method:          GRM.RemoveFromCalendarQue ( string , string )
-- What it Does:    Removes the player/event from the global Calendar Add Que table
-- Purpose:         Keep the Que Clean
GRM.RemoveFromCalendarQue = function ( name , eventName )
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
        if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] == name and GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] == eventName then
            table.remove ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , i );
            break;
        end
    end
end

-- Method:          GRM.CalendarQueCheck ()
-- What it Does:    It checks the Add Que list, if the event is already on the calendar, then it removes it from the addque list.
-- Purpose:         In case other players add items to the calendar, this keeps it clean.
GRM.CalendarQueCheck = function ()
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do             -- For each item on the que...3 = month , 4 = day , 5 = year
        if GRM.IsCalendarEventAlreadyAdded ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][5] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][3] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][4] ) then
            table.remove ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , i );
            if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
                GRM.CalendarQueCheck();                                                                 -- Recursively go through again!
            end
            break;
        end
    end
end

-- Method:          GRM.CheckPlayerEvents ( string )
-- What it Does:    Scans through all players'' "events" of the given guild and updates if any are pending
-- Purpose:         Event Management for Anniversaries, Birthdays, and Custom Events
GRM.CheckPlayerEvents = function ( guildName )
    -- including anniversary, birthday , and custom
    local _ , month , day , year = CalendarGetDate()
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        -- Player identified, now let's check his event info!
        for r = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22] do          -- Loop all events!
            local eventMonth = GRM.GetEventMonth ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] );
            local eventMonthIndex = monthEnum [ eventMonth ];
            local eventDay = tonumber ( GRM.GetEventDay ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] ) );
            local eventYear = tonumber ( GRM.GetEventYear ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] ) );
            local isLeapYear = GRM.IsLeapYear ( year );
            local logReport = "";
            --  Quick Leap Year Check
            if ( eventDay == 29 and eventMonthIndex == 2 ) and not isLeapYear then  -- If Event is Feb 29th Leap year, and reporting year is not, then put event in Mar 1st.
                eventMonthIndex = 3;
                eventDay = 1;
            end

            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] ~= true and ( month == eventMonthIndex or month + 1 == eventMonthIndex ) and not ( year == eventYear and month == eventMonthIndex and day == eventDay ) then        -- if it has already been reported, then we are good!
                local daysTil = eventDay - day;
                local daysLeftInMonth = daysInMonth [ tostring ( month ) ] - day;
                if month == 2 and GRM.IsLeapYear ( year ) then
                    daysLeftInMonth = daysLeftInMonth + 1;
                end
                            
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] and ( ( month == eventMonthIndex and daysTil >= 0 and daysTil <= GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) or 
                        ( month + 1 == eventMonthIndex and ( eventDay + daysLeftInMonth <= GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) ) ) then
                    -- SAME MONTH!
                    -- Join Date Anniversary
                    if r == 1 then
                        local numYears = year - eventYear;
                        if numYears == 0 then
                            numYears = 1;
                        end
                        local eventDate;
                        if ( eventDay == 29 and eventMonthIndex == 2 ) and not isLeapYear then    -- If anniversary happened on leap year date, and the current year is NOT a leap year, then put it on 1 Mar.
                            eventDate = "1 Mar";
                        else
                            eventDate = string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] , 0 , string.find ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] , " " ) + 3 );
                        end
                        if numYears == 1 then
                            
                            logReport = ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][1][2] .. " : " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] ) .. " will be celebrating " .. numYears .. " year in the Guild! ( " .. eventDate .. " )"  );
                        else
                            logReport = ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][1][2] .. " : " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] ) .. " will be celebrating " .. numYears .. " years in the Guild! ( " .. eventDate .. " )"  );
                        end
                        table.insert ( GRM_AddonGlobals.TempEventReport , { 15 , logReport , false } );
                    
                    elseif r == 2 then
                    -- BIRTHDAY!

                    else
                    -- MISC EVENT!
                    
                    end

                    -- Now, let's add it to the calendar!
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] and CanEditGuildEvent() then
                        local year = year;
                        if month == 12 and eventMonthIndex == 1 then
                            year = year + 1;
                        end 

                        -- 
                        local isAddedAlready = GRM.IsCalendarEventAlreadyAdded (  GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] , year , eventMonthIndex , eventDay  );
                            if not isAddedAlready and not GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                            table.insert ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] , eventMonthIndex , eventDay , year , string.sub ( logReport , 1 , #logReport - 11 ) } );
                        end
                    end
                    -- This has been reported, save it!
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = true;
                end                  
                
            -- Resetting the event report to false if parameters meet
            elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] then                                                   -- It is still true! Event has been reported! Let's check if time has passed sufficient to wipe it to false
                if ( month == eventMonthIndex and eventDay - day < 0 ) or ( month > eventMonthIndex  ) or ( eventMonthIndex - month > 1 ) then     -- Event is behind us now
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = false;
                    if GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                        GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] );
                    end
                elseif month == eventMonthIndex and eventDay - day > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] then      -- Setting back to false;
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = false;
                    if GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                        GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] );
                    end
                elseif month + 1 == eventMonthIndex then
                    local daysLeftInMonth = daysInMonth [ tostring ( month ) ] - day;
                    if month == 2 and GRM.IsLeapYear ( year ) then
                        daysLeftInMonth = daysLeftInMonth + 1;
                    end
                    if eventDay + daysLeftInMonth > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = false;
                        if GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                            GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] );
                        end
                    end
                end
            end
        end
    end
end

-- Method:          AddAnnouncementToCalendar ( string , int , int , int , string , string )
-- What it Does:    Adds the announcement to the in-game calendar, if player has permissions to do so.
-- Purpose:         CalendarAddEvent() is a protected function thus it needs to be triggered by a player in-game action, so it will
--                  be linked to a button on the "GRM_AddEventFrame" window. Again, this cannot be activated, it WILL NOT WORK without 
--                  in-game action to remove protection on function
GRM.AddAnnouncementToCalendar = function ( name , title , eventMonthIndex , eventDay , year , description )
    CalendarCloseEvent();                           -- Just in case previous event was never closed, either by other addons or by player
    local _, month, day, year = CalendarGetDate()
    local hourServer , minServer = GetGameTime();
    local hour = 0;                                 -- 24hr scale, on when to add it...
    local min = 5;

    if eventMonthIndex == month and eventDay == day then      -- Add current time now!
        hour = hourServer;
        min = minServer;

        local tempMin = min;
        min = min - ( min % 5 ) + 5;    -- To get incrememnt by 5
        if min == 60 then
            if tempMin <= 55 then
                min = 55;
            else
                min = tempMin;
            end
        end
    end

    CalendarNewGuildAnnouncement();
    CalendarEventSetDate ( eventMonthIndex , eventDay , year );
    CalendarEventSetTitle ( title );
    CalendarEventSetDescription ( description ); -- No need to include the date at the end.
    CalendarEventSetTime ( hour , min );    
    CalendarEventSetType ( 5 );     -- 5 = announcement
    CalendarAddEvent();
    CalendarCloseEvent();
end

-- Method:          GRM.BuildLog()
-- What it Does:    Builds the guildLog frame details for the scrollframe
-- Purpose:         You aren't tracking all of that info for nothing!
GRM.BuildLog = function()
    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 220;
    local buffer = 7;

    GRM_RosterChangeLogScrollChildFrame.allFontStrings = GRM_RosterChangeLogScrollChildFrame.allFontStrings or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    local count = 1;
    for i = 1 , #GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] do
        -- if font string is not created, do so.
        local trueString = false;
        
        -- Check buttons
        local index = GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][1];
        if index == 1 and GRM_RosterPromotionChangeCheckButton:GetChecked() then      -- Promotion 
            trueString = true;
        elseif index == 2 and GRM_RosterDemotionChangeCheckButton:GetChecked() then  -- Demotion
            trueString = true;
        elseif index == 3 and GRM_RosterLeveledChangeCheckButton:GetChecked() then  -- Leveled
            trueString = true;
        elseif index == 4 and GRM_RosterNoteChangeCheckButton:GetChecked() then  -- Note
            trueString = true;
        elseif index == 5 and GRM_RosterOfficerNoteChangeCheckButton:GetChecked() then  -- OfficerNote
            trueString = true;
        elseif index == 6 and GRM_RosterRankRenameCheckButton:GetChecked() then  -- OfficerNote
            trueString = true;
        elseif ( index == 7 or index == 8 ) and GRM_RosterJoinedCheckButton:GetChecked() then  -- Join/Rejoin
            trueString = true;
        elseif index == 10 and GRM_RosterLeftGuildCheckButton:GetChecked() then -- Left Guild
            trueString = true;
        elseif index == 11 and GRM_RosterNameChangeCheckButton:GetChecked() then -- NameChange
            trueString = true;
        elseif index == 14 and GRM_RosterInactiveReturnCheckButton:GetChecked() then -- Return from inactivity
            trueString = true;
        elseif index == 15 and GRM_RosterEventCheckButton:GetChecked() then -- Event Announcement
            trueString = true;
        elseif index == 16 and GRM_RosterRecommendationsButton:GetChecked() then -- Event Announcement
            trueString = true;
        elseif index == 17 and GRM_RosterBannedPlayersButton:GetChecked() then  -- ban info
            trueString = true;
        elseif index == 18 and GRM_RosterBannedPlayersButton:GetChecked() then
            trueString = true;
        elseif ( index == 9 or index == 12 or index == 13 ) and GRM_RosterJoinedCheckButton:GetChecked() then
            trueString = true;
        end

        if trueString then
            if not GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] then
                GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] = GRM_RosterChangeLogScrollChildFrame:CreateFontString ( "GRM_LogEntry_" .. count );
            end

            -- coloring
            local r , g , b = GRM.GetNMessageRGB ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][1] );
            local logFontString = GRM_RosterChangeLogScrollChildFrame.allFontStrings[count];
            logFontString:SetPoint ( "TOP" , GRM_RosterChangeLogScrollChildFrame , 7 , -99 );
            logFontString:SetFont ( "Fonts\\FRIZQT__.TTF" , 11 );
            logFontString:SetJustifyH ( "LEFT" );
            logFontString:SetSpacing ( buffer );
            logFontString:SetTextColor ( r , g , b , 1.0 );
            logFontString:SetText ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][2] );
            logFontString:SetWidth ( 588 );
            logFontString:SetWordWrap ( true );
            local stringHeight = logFontString:GetStringHeight();

            -- Now let's pin it!
            if count == 1 then
                logFontString:SetPoint( "TOPLEFT" , 0 , - 5 );
                scrollHeight = scrollHeight + stringHeight;
            else
                logFontString:SetPoint( "TOPLEFT" , GRM_RosterChangeLogScrollChildFrame.allFontStrings[count - 1] , "BOTTOMLEFT" , 0 , - buffer );
                scrollHeight = scrollHeight + stringHeight + buffer;
            end
            count = count + 1;
            logFontString:Show();
        end
    end
            

    -- Hides all the additional buttons... if necessary
    for i = count , #GRM_RosterChangeLogScrollChildFrame.allFontStrings do
        GRM_RosterChangeLogScrollChildFrame.allFontStrings[i]:Hide();
    end 

    -- Update the size -- it either grows or it shrinks!
    GRM_RosterChangeLogScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 397 ) +  ( buffer * .5 );  -- 18 comes from fontSize (11) + buffer (7);
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_RosterChangeLogScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_RosterChangeLogScrollFrame:EnableMouseWheel( true );
    GRM_RosterChangeLogScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
        local current = GRM_RosterChangeLogScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( current + 20 );
        elseif delta > 0 and current > 1 then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( current - 20 );
        end
    end);
end


------------------------------------
---- BEGIN OF FRAME/UI LOGIC -------
---- General Framebuild Methods ----
------------------------------------


-- Method:          GRM.OnDropMenuClickDay()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickDay = function ()
    GRM_AddonGlobals.dayIndex = tonumber ( GRM_DayDropDownMenuSelected.DayText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickMonth()
-- What it Does:    Recalculates the logic of number days to show.
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickMonth = function ()
    GRM_AddonGlobals.monthIndex = monthsFullnameEnum [ GRM_MonthDropDownMenuSelected.MonthText:GetText() ];
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickYear()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for year based drop down menu.
GRM.OnDropMenuClickYear = function ()
    GRM_AddonGlobals.yearIndex = tonumber ( GRM_YearDropDownMenuSelected.YearText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.InitializeDropDownDay ( self , int )
-- What it Does:    Initializes the Drop Down "Day" select window with values based on selected month
-- Purpose:         UI feature for easy date select.
GRM.InitializeDropDownDay = function ()
    local shortMonth = 30;
    local longMonth = 31;
    local febMonth = 28;
    local leapYear = 29;
    local yearDate = 0;

    yearDate = GRM_AddonGlobals.yearIndex;
    local isDateALeapyear = GRM.IsLeapYear(yearDate);
    local numDays;
    
    if GRM_AddonGlobals.monthIndex == 1 or GRM_AddonGlobals.monthIndex == 3 or GRM_AddonGlobals.monthIndex == 5 or GRM_AddonGlobals.monthIndex == 7 or GRM_AddonGlobals.monthIndex == 8 or GRM_AddonGlobals.monthIndex == 10 or GRM_AddonGlobals.monthIndex == 12 then
        numDays = longMonth;
    elseif GRM_AddonGlobals.monthIndex == 2 and isDateALeapyear then
        numDays = leapYear;
    elseif GRM_AddonGlobals.monthIndex == 2 then
        numDays = febMonth;
    else
        numDays = shortMonth;
    end
      
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_DayDropDownMenu.Buttons = GRM_DayDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_DayDropDownMenu.Buttons do
        GRM_DayDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , numDays do
        if not GRM_DayDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "DayOfTheMonth" .. i , GRM_DayDropDownMenu );
            GRM_DayDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "DayOfTheMonthText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local DayButtons = GRM_DayDropDownMenu.Buttons[i][1];
        local DayButtonsText = GRM_DayDropDownMenu.Buttons[i][2];
        DayButtons:SetWidth ( 24 );
        DayButtons:SetHeight ( 10 );
        DayButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        DayButtonsText:SetText ( i );
        DayButtonsText:SetWidth ( 25 );
        DayButtonsText:SetWordWrap ( false );
        DayButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
        DayButtonsText:SetPoint ( "CENTER" , DayButtons );
        DayButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            DayButtons:SetPoint ( "TOP" , GRM_DayDropDownMenu , 0 , -7 );
            height = height + DayButtons:GetHeight();
        else
            DayButtons:SetPoint ( "TOP" , GRM_DayDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + DayButtons:GetHeight() + buffer;
        end

        DayButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_DayDropDownMenuSelected.DayText:SetText ( DayButtonsText:GetText() );
                GRM_DayDropDownMenu:Hide();
                GRM_DayDropDownMenuSelected:Show();
                GRM.OnDropMenuClickDay();
            end
        end); 

        DayButtons:Show();
    end
    GRM_DayDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.InitializeDropDownYear(self,level)
-- What it Does:    Initializes the year select drop-down OnDropMenuClick
-- Purpose:         Easy way to set when player joined the guild.         
GRM.InitializeDropDownYear = function ()
    -- Year Drop Down
    local _,_,_,currentYear = CalendarGetDate();
    local yearStamp = currentYear;

    -- populating the frames!
    local buffer = 2;
    local height = 0;
    GRM_YearDropDownMenu.Buttons = GRM_YearDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_YearDropDownMenu.Buttons do
        GRM_YearDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , currentYear - 2003 do
        if not GRM_YearDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "YearIndexButton" .. i , GRM_YearDropDownMenu );
            GRM_YearDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "YearIndexButtonText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local YearButtons = GRM_YearDropDownMenu.Buttons[i][1];
        local YearButtonsText = GRM_YearDropDownMenu.Buttons[i][2];
        YearButtons:SetWidth ( 40 );
        YearButtons:SetHeight ( 10 );
        YearButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        YearButtonsText:SetText ( yearStamp );
        YearButtonsText:SetWidth ( 32 );
        YearButtonsText:SetWordWrap ( false );
        YearButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
        YearButtonsText:SetPoint ( "CENTER" , YearButtons );
        YearButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            YearButtons:SetPoint ( "TOP" , GRM_YearDropDownMenu , 0 , -7 );
            height = height + YearButtons:GetHeight();
        else
            YearButtons:SetPoint ( "TOP" , GRM_YearDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + YearButtons:GetHeight() + buffer;
        end

        YearButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_YearDropDownMenuSelected.YearText:SetText ( YearButtonsText:GetText() );
                GRM_YearDropDownMenu:Hide();
                GRM_YearDropDownMenuSelected:Show();
                GRM.OnDropMenuClickYear();
            end
        end); 
        yearStamp = yearStamp - 1                       -- Descending the year by 1
        YearButtons:Show();
    end
    GRM_YearDropDownMenu:SetHeight ( height + 15 );

end

-- Method:          GRM.InitializeDropDownMonth(self,level)
-- What it Does:    Initializes month drop select menu
-- Purpose:         Date select for Officer Note "Join Date"
GRM.InitializeDropDownMonth = function ()
    -- Month Drop Down
    local months = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" };
    
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_MonthDropDownMenu.Buttons = GRM_MonthDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_MonthDropDownMenu.Buttons do
        GRM_MonthDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , #months do
        if not GRM_MonthDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "monthIndex" .. i , GRM_MonthDropDownMenu );
            GRM_MonthDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "monthIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local MonthButtons = GRM_MonthDropDownMenu.Buttons[i][1];
        local MonthButtonsText = GRM_MonthDropDownMenu.Buttons[i][2];
        MonthButtons:SetWidth ( 83 );
        MonthButtons:SetHeight ( 10 );
        MonthButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        MonthButtonsText:SetText ( months[i] );
        MonthButtonsText:SetWidth ( 83 );
        MonthButtonsText:SetWordWrap ( false );
        MonthButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
        MonthButtonsText:SetPoint ( "CENTER" , MonthButtons );
        MonthButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            MonthButtons:SetPoint ( "TOP" , GRM_MonthDropDownMenu , 0 , -7 );
            height = height + MonthButtons:GetHeight();
        else
            MonthButtons:SetPoint ( "TOP" , GRM_MonthDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + MonthButtons:GetHeight() + buffer;
        end

        MonthButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_MonthDropDownMenuSelected.MonthText:SetText ( MonthButtonsText:GetText() );
                GRM_MonthDropDownMenu:Hide();
                GRM_MonthDropDownMenuSelected:Show();
                GRM.OnDropMenuClickMonth();
            end
        end); 

        MonthButtons:Show();
    end
    GRM_MonthDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.SetJoinDate ( self , string )
-- What it Does:    Sets the player's join date properly, be it the first time, a modified time, or an edit.
-- Purpose:         For so many uses! Anniversary tracking, for editing the date, and so on...
GRM.SetJoinDate = function ( _ , button )
    local name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
    local dayJoined = tonumber ( GRM_DayDropDownMenuSelected.DayText:GetText() );
    local yearJoined = tonumber ( GRM_YearDropDownMenuSelected.YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );
    local buttonText = GRM_DateSubmitButtonTxt:GetText();

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM_MonthDropDownMenuSelected.MonthText:GetText() ] , yearJoined, IsLeapYearSelected ) then
        local rankButton = false;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then

                local joinDate = ( "Joined: " .. dayJoined .. " " ..  string.sub ( GRM_MonthDropDownMenuSelected.MonthText:GetText() , 1 , 3 ) .. " '" ..  string.sub ( GRM_YearDropDownMenuSelected.YearText:GetText() , 3 ) );
                local finalTStamp = ( string.sub ( joinDate , 9 ) .. " 12:01am" );
                local finalEpochStamp = GRM.TimeStampToEpoch ( joinDate );
                -- For metadata tracking
                if buttonText == "Edit Join Date" then
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] );  -- Removing previous instance to replace
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] );
                end
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , finalTStamp );      -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , finalEpochStamp ) ;    -- oldJoinDateMeta
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][2] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][3] = finalEpochStamp;

                -- For sync
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][1] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][2] = time();

                -- For UI
                GRM_JoinDateText:SetText ( string.sub ( joinDate , 9 ) );
                
                -- Update timestamp to officer note.
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                        if guildieName == name and oNote == "" then
                            GuildRosterSetOfficerNote ( h , joinDate );
                            GRM_noteFontString2:SetText ( joinDate );
                            GRM_PlayerOfficerNoteEditBox:SetText ( joinDate );
                            break;
                        end
                    end
                end

                -- Gotta update the event tracker date too!
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][2] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][1] );
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] == nil then
                    rankButton = true;
                end

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Let's send the changes out as well!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_JD" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp , "GUILD");
                end
                break;
            end
        end

        GRM_DayDropDownMenuSelected:Hide();
        GRM_MonthDropDownMenuSelected:Hide();
        GRM_YearDropDownMenuSelected:Hide();
        GRM_DateSubmitCancelButton:Hide();
        GRM_DateSubmitButton:Hide();
        GRM_JoinDateText:Show();
        if rankButton then
            GRM_SetPromoDateButton:Show();
        else
            GRM_MemberDetailRankDateTxt:Show();
        end
        GRM_AddonGlobals.pause = false;
    end
end

-- Method:          GRM.SetPromoDate ( self , string )
-- What it Does:    Set's the date the player was promoted to the current rank
-- Purpose:         Date tracking and control of rank promotions.
GRM.SetPromoDate = function ( _ , button )
    local name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
    local dayJoined = tonumber ( GRM_DayDropDownMenuSelected.DayText:GetText() );
    local yearJoined = tonumber ( GRM_YearDropDownMenuSelected.YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM_MonthDropDownMenuSelected.MonthText:GetText() ] , yearJoined, IsLeapYearSelected ) then

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then
                local promotionDate = ( "Joined: " .. dayJoined .. " " ..  string.sub ( GRM_MonthDropDownMenuSelected.MonthText:GetText() , 1 , 3 ) .. " '" ..  string.sub ( GRM_YearDropDownMenuSelected.YearText:GetText() , 3 ) );
                
                -- Promo Save Data
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( promotionDate , 9 );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25]][2] = string.sub ( promotionDate , 9 );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = GRM.TimeStampToEpoch ( promotionDate );
                
                -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = time();
                
                if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex then
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -80 ); -- slightly varied positioning due to drop down window or not.
                else
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -68 );
                end
                GRM_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
                GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , 1 , 10) ) );

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Send the details out for others to pickup!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_PD" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. promotionDate .. "?" .. tostring( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] ) , "GUILD");
                end

                break;
            end
        end

        GRM_DayDropDownMenuSelected:Hide();
        GRM_MonthDropDownMenuSelected:Hide();
        GRM_YearDropDownMenuSelected:Hide();
        GRM_DateSubmitCancelButton:Hide();
        GRM_DateSubmitButton:Hide();
        GRM_MemberDetailRankDateTxt:Show();
        GRM_AddonGlobals.pause = false;
    end
end

-- Method:          GRM.DateSubmitCancelResetLogic()
-- What it Does:    Resets the logic on what occurs with the cancel button, since it will have multiple uses.
-- Purpose:         Resource efficiency. No need to make new buttons for everything! This reuses the button, just resets the click logic in join date submit cancel event.
GRM.DateSubmitCancelResetLogic = function()
    GRM_DateSubmitCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local buttonText = GRM_DateSubmitButtonTxt:GetText();
            local joinDateText = "Set Join Date";
            local promoDateText = "Set Promo Date";
            local editDateText = "Edit Promo Date";
            local editJoinText = "Edit Join Date";
            local name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );

            -- Determine which information needs to repopulate.
            if joinDateText == buttonText or editJoinText == buttonText then
                if buttonText == editJoinText then
                    GRM_JoinDateText:Show();
                else
                    GRM_MemberDetailJoinDateButton:Show();
                end
                --RANK PROMO DATE
                if GRM_AddonGlobals.rankDateSet == false then      --- Promotion has never been recorded!
                    GRM_MemberDetailRankDateTxt:Hide();                     
                    GRM_SetPromoDateButton:Show();
                else
                    GRM_MemberDetailRankDateTxt:Show();
                end
            elseif buttonText == promoDateText then
                GRM_SetPromoDateButton:Show();
            elseif buttonText == editDateText then
                GRM_MemberDetailRankDateTxt:Show();
            end
            GRM_AddonGlobals.pause = false;

            -- Need player index to get this info.
            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then

                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                            GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                            GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                        end
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                    end
                    break;
                end
            end

            -- Close the rest
            GRM_MonthDropDownMenuSelected:Hide();
            GRM_YearDropDownMenuSelected:Hide();
            GRM_DayDropDownMenuSelected:Hide();
            GRM_DateSubmitButton:Hide();
            GRM_DateSubmitCancelButton:Hide();

        end
    end);
end

-- Method:          GRM.SetDateSelectFrame( string , frameObject, string )
-- What it Does:    On Clicking the "Set Join Date" button this logic presents itself
-- Purpose:         Handle the event to modify when a player joined the guild. This is useful for anniversary date tracking.
--                  It is also necessary because upon starting the addon, it is unknown a person's true join date. This allows the gleader to set a general join date.
GRM.SetDateSelectFrame = function ( fposition , frame , buttonName )
    local _ , month , day , currentYear = CalendarGetDate();
    local xPosMonth , yPosMonth , xPosDay , yPosDay , xPosYear , yPosYear , xPosSubmit , yPosSubmit , xPosCancel , yPosCancel = 0;        -- Default position.
    local months = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" };
    local joinDateText = "Set Join Date";
    local promoDateText = "Set Promo Date";

    -- Month
    GRM_MonthDropDownMenuSelected.MonthText:SetText ( months [ month ] );
    GRM_MonthDropDownMenuSelected.MonthText:SetPoint ( "CENTER" , GRM_MonthDropDownMenuSelected );
    GRM_MonthDropDownMenuSelected.MonthText:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_MonthDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_MonthDropDownMenu:IsVisible() then
                GRM_MonthDropDownMenu:Hide();
            else
                GRM.InitializeDropDownMonth();
                GRM_MonthDropDownMenu:Show();
                GRM_DayDropDownMenu:Hide();
                GRM_YearDropDownMenu:Hide();
            end
        end
    end);
    GRM_AddonGlobals.monthIndex = month;
    
    -- Year
    GRM_YearDropDownMenuSelected.YearText:SetText ( currentYear );
    GRM_YearDropDownMenuSelected.YearText:SetPoint ( "CENTER" , GRM_YearDropDownMenuSelected );
    GRM_YearDropDownMenuSelected.YearText:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_YearDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_YearDropDownMenu:IsVisible() then
                GRM_YearDropDownMenu:Hide();
            else
                GRM.InitializeDropDownYear();
                GRM_YearDropDownMenu:Show();
                GRM_MonthDropDownMenu:Hide();
                GRM_DayDropDownMenu:Hide();
            end
        end
    end);
    GRM_AddonGlobals.yearIndex = currentYear;
    
    -- Initialize the day choice now.
    GRM_DayDropDownMenuSelected.DayText:SetText ( day );
    GRM_DayDropDownMenuSelected.DayText:SetPoint ( "CENTER" , GRM_DayDropDownMenuSelected );
    GRM_DayDropDownMenuSelected.DayText:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_DayDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_DayDropDownMenu:IsVisible() then
                GRM_DayDropDownMenu:Hide();
            else
                GRM.InitializeDropDownDay();
                GRM_DayDropDownMenu:Show();
                GRM_YearDropDownMenu:Hide();
                GRM_MonthDropDownMenu:Hide();
            end
        end
    end);
    GRM_AddonGlobals.dayIndex = day;
    
    GRM.DateSubmitCancelResetLogic(); 

    if buttonName == "PromoRank" then
        
        -- Change this button
        GRM_DateSubmitButtonTxt:SetText ( promoDateText );
        GRM_DateSubmitButton:SetScript("OnClick" , GRM.SetPromoDate );
        
        xPosDay = 10.5;
        yPosDay = -80;
        xPosMonth = -63.5;
        yPosMonth = -80;
        xPosYear = 69;
        yPosYear = -80
        xPosSubmit = -37;
        yPosSubmit = -106;
        xPosCancel = 37;
        yPosCancel = -106;

    elseif buttonName == "JoinDate" then

        GRM_DateSubmitButtonTxt:SetText ( joinDateText );
        GRM_DateSubmitButton:SetScript("OnClick" , GRM.SetJoinDate );
        
        xPosDay = 10.5;
        yPosDay = -80;
        xPosMonth = -63.5;
        yPosMonth = -80;
        xPosYear = 69;
        yPosYear = -80
        xPosSubmit = -37;
        yPosSubmit = -106;
        xPosCancel = 37;
        yPosCancel = -106;
    end

    GRM_MonthDropDownMenuSelected:SetPoint ( fposition , frame , xPosMonth , yPosMonth );
    GRM_YearDropDownMenuSelected:SetPoint ( fposition , frame , xPosYear , yPosYear );
    GRM_DayDropDownMenuSelected:SetPoint ( fposition , frame , xPosDay , yPosDay );
    GRM_DateSubmitButton:SetPoint ( fposition , frame , xPosSubmit , yPosSubmit );
    GRM_DateSubmitCancelButton:SetPoint ( fposition , frame , xPosCancel , yPosCancel );

    -- Show all Frames
    GRM_MonthDropDownMenuSelected:Show();
    GRM_YearDropDownMenuSelected:Show();
    GRM_DayDropDownMenuSelected:Show();
    GRM_DateSubmitButton:Show();
    GRM_DateSubmitCancelButton:Show();
end

-- Method:          GRM.GetRankIndex(string)
-- What it Does:    Returns the index of the dropdown menu selection
-- Purpose:         Flow control of drop down menus.
GRM.GetRankIndex = function ( rankName , buttons )
    local index = -1;
    for i = 1 , #buttons do
        if buttons[i][2]:GetText() == rankName then
            index = i;
            break;
        end
    end
    return index;
end

-- Method:          GRM.OnRankDropMenuClick ( self )
-- What it Does:    Logic on Rank Drop down select in main frame
-- Purpose:         UI feature and UX
GRM.OnRankDropMenuClick = function ( formerRank , newRank )
    local newRankIndex = GRM.GetRankIndex ( newRank , GRM_RankDropDownMenu.Buttons );
    local formerRankIndex = GRM.GetRankIndex ( formerRank , GRM_RankDropDownMenu.Buttons );

    if ( newRankIndex > formerRankIndex and CanGuildDemote() ) or ( newRankIndex < formerRankIndex and CanGuildPromote() ) then
        local numRanks = GuildControlGetNumRanks();
        local numChoices = ( numRanks - GRM_AddonGlobals.playerIndex - 1 );
        local solution = newRankIndex + numRanks - numChoices;
        local newRankName = GuildControlGetRankName ( solution );

        for i = 1 , GRM.GetNumGuildies() do
            local name = GetGuildRosterInfo ( i );
            
            if name == GRM_AddonGlobals.tempName then
                GRM_AddonGlobals.changeHappenedExitScan = true;

                -- Need to verify promotion is ok... in case of authenticator requirement or other reasons
                local canSetRank , reason = IsGuildRankAssignmentAllowed ( i , solution );
                if canSetRank then
                    SetGuildMemberRank ( i , solution );

                    -- Save the data!
                    local timestamp = GRM.GetTimestamp();
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then
                            local formerRankName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4];                               -- For the reporting string!

                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = newRankName                                         -- rank name
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] = newRankIndex;                                           -- rank index!

                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ) -- Time stamping rank change
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = time();

                            -- For SYNC
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13];
                            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] } ); -- New rank, date, metatimestamp
                            
                            -- Let's update it on the fly!
                            local simpleName = GRM.SlimName ( name );
                            local logReport = "";
                            -- Promotion Obtained
                            if newRankIndex < formerRankIndex and CanGuildPromote() then
                                GRM_guildRankDropDownMenuSelected.RankText:SetText ( newRankName );
                                logReport = ( timestamp .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " PROMOTED " .. simpleName .. " from " .. formerRankName .. " to " .. newRankName );

                                -- report the changes!
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
                                    GRM.PrintLog ( 1 , logReport , false );
                                end
                                GRM.AddLog ( 1 , logReport );

                            -- Demotion Obtained
                            elseif newRankIndex > formerRankIndex and CanGuildDemote() then
                                GRM_guildRankDropDownMenuSelected.RankText:SetText ( newRankName );
                                tempString = GRM.GetGuildEventString ( 1 , simpleName );
                                logReport = ( timestamp .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " DEMOTED " .. simpleName .. " from " .. formerRankName .. " to " .. newRankName );

                                -- reporting the changes!
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
                                    GRM.PrintLog ( 2 , logReport , false );                          
                                end
                                GRM.AddLog ( 2 , logReport );
                            end
                            GRM:BuildLog();
                            break;
                        end
                    end

                    -- Update the player index if it is the player themselves that received the change in rank.
                    if name == GRM_AddonGlobals.addonPlayerName then
                        GRM_AddonGlobals.playerIndex = newRankIndex;
                    end

                    -- Now, let's make the changes immediate for the button date.
                    if GRM_SetPromoDateButton:IsVisible() then
                        GRM_SetPromoDateButton:Hide();
                        GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) );
                        GRM_MemberDetailRankDateTxt:Show();
                    end

                else
                    GRM.Report ( "Player Cannot Be Move to that Rank!!! Reason: " .. reason );
                end

                GRM_AddonGlobals.pause = false;
                break;
            end
        end
    elseif newRankIndex > formerRankIndex and CanGuildDemote() ~= true then
        GRM.Report ( "Player Does Not Have Permission to Demote!" );
    elseif newRankIndex < formerRankIndex and CanGuildPromote() ~= true then
        GRM.Report ( "Player Does Not Have Permission to Promote!" );
    end
end

-- Method:          GRM.PopulateRank ( self , int )
-- What it Does:    Adds all the guild ranks to the drop down menu
-- Purpose:         UI Feature
GRM.PopulateRankDropDown = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_RankDropDownMenu.Buttons = GRM_RankDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_RankDropDownMenu.Buttons do
        GRM_RankDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 2 , ( GuildControlGetNumRanks() - GRM_AddonGlobals.playerIndex ) do
        if not GRM_RankDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_RankDropDownMenu );
            GRM_RankDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_RankDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_RankDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 112 );
        RankButtons:SetHeight ( 10 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count + GRM_AddonGlobals.playerIndex ) );
        RankButtonsText:SetWidth ( 112 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_RankDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_RankDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                local formerRank = GRM_guildRankDropDownMenuSelected.RankText:GetText();
                GRM_RankDropDownMenu:Hide();
                GRM_guildRankDropDownMenuSelected:Show();
                GRM.OnRankDropMenuClick( formerRank , RankButtonsText:GetText() );
            end
        end); 
        RankButtons:Show();
        i = i + 1;
    end
    GRM_RankDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.CreateRankDropDown()
-- What it Does:    Builds the final rank drop down product
-- Purpose:         UI Feature
GRM.CreateRankDropDown = function ()
    GRM.PopulateRankDropDown();
    local numRanks = GuildControlGetNumRanks();
    local numChoices = ( numRanks - GRM_AddonGlobals.playerIndex - 1 );
    local solution = GRM_AddonGlobals.rankIndex - ( numRanks - numChoices ) + 1;   -- Calculating which rank to select based on flexible and scalable rank numbers.

    GRM_guildRankDropDownMenuSelected.RankText:SetText( GRM_RankDropDownMenu.Buttons[ solution ][2]:GetText() );    -- Sets the text to be the rank of the player on mouseover.
    
    GRM_RankDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_RankDropDownMenu:IsVisible() then
                GRM_RankDropDownMenu:Hide();
            else
                GRM.PopulateRankDropDown();
                GRM_RankDropDownMenu:Show();
            end
        end
    end);
    GRM_guildRankDropDownMenuSelected:Show();
end


-- Method:          GRM.PopulateOptionsRankDropDown ()
-- What it Does:    Adds all the guild ranks to the drop down menu
-- Purpose:         UI Feature
GRM.PopulateOptionsRankDropDown = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons do
        GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu );
            GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 110 );
        RankButtons:SetHeight ( 11 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count) );
        RankButtonsText:SetWidth ( 110 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                local formerRank = GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:GetText();
                GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
                GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:Show();
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] = GRM.GetRankIndex ( GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons );
            
                --Let's re-initiate syncing!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing then --and GRM.IsGuildChatEnabled()
                    GRMsync.Initialize();
                end
                
            end
        end); 
        RankButtons:Show();
        i = i + 1;
    end
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.SetGroupInviteButton ( string )
-- What it Does:
-- Purpose:
GRM.SetGroupInviteButton = function ( handle )
    if GetNumGroupMembers() > 0  then                                                               -- If > 0 then player is in either a raid or a party. (1 will show if in an instance by oneself)
        local isGroupLeader = UnitIsGroupLeader ( "PLAYER" );                                       -- Party or Group
        local isInRaidWithAssist = UnitIsGroupAssistant ( "PLAYER" , LE_PARTY_CATEGORY_HOME );      -- Player Has Assist in Raid group

        if GRM.IsGuildieInSameGroup ( handle ) then
            -- Player is already in group!
            GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "In Group" );
            GRM_GroupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    print ( GRM.SlimName ( handle ) .. " is Already in Your Group!" );
                end
            end);
        elseif isGroupLeader or isInRaidWithAssist then                                         -- Player has the ability to invite to group
            GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "Group Invite" );
            GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    if IsInRaid() and GetNumGroupMembers() == 40 then                               -- Helpful reporting to cleanup the raid in case players are offline and no room to invite.
                        local afkList = GRM.GetGroupUnitsOfflineOrAFK();
                        local report = ( "\nROSTER NOTIFICATION!!!\n40 players have already been invited to this Raid!" );
                        if #afkList[1] > 0 then
                            report = ( report .. "\nPlayers Offline: " );
                            for i = 1 , #afkList[1]  do
                                report = ( report .. "" .. afkList[1][i] );
                                if i ~= #afkList[1] then
                                    report = ( report .. ", ");
                                end
                            end
                        end

                        if #afkList[2] > 0 then
                            report = ( report .. "\nPlayers AFK:     " );
                            for i = 1 , #afkList[2]  do
                                report = ( report .. "" .. afkList[2][i] );
                                if i ~= #afkList[2] then
                                    report = ( report .. ", ");
                                end
                            end
                        end
                        print ( report );
                    else
                        InviteUnit ( handle );
                    end
                end
            end);
        else            -- Player is in a group but does not have invite privileges
            GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "No Invite" );
            GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    print ( "Player should try to obtain group invite privileges." );
                end
            end);
        end
    else
        -- Player is not in any group, thus inviting them will create new group.
        GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "Group Invite" );
        GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
            if button == "LeftButton" then
                InviteUnit ( handle );
            end
        end);
    end
end

-- Method:          GRM.CreateOptionsRankDropDown()
-- What it Does:    Builds the final rank drop down product for options panel
-- Purpose:         UI Feature for options to be able to filter who you will accept shared data from.
GRM.CreateOptionsRankDropDown = function ()
    GRM.PopulateOptionsRankDropDown();
    local setRankName = GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] );
    if setRankName == nil or setRankName == "" then
        setRankName = GuildControlGetRankName ( 1 )     -- Default it to guild leader. This scenario could happen if the rank was removed or you change guild but still have old settings.
    end

    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetText( setRankName );
    
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if  GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:IsVisible() then
                 GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
            else
                GRM.PopulateOptionsRankDropDown();
                 GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Show();
            end
        end
    end);
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:Show();
end

-- Method:          GRM.UnBanLeftPlayer ( string )
-- What it Does:    Unbans a listed player in the ban list
-- Purpose:         To be able to control who is banned and not banned in the guild.
GRM.UnBanLeftPlayer = function ( name )
    for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then
            GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17] = nil;
            GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17] = { false , 0 , true };
            GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
            break;
        end
    end
end

-- Method:              GRM.ClearPromoDateHistory ( string )
-- What it Does:        Purges history of promotions as if they had just joined the guild.
-- Purpose:             Editing ability in case of user error.
GRM.ClearPromoDateHistory = function ( name )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] = nil;
            GRM_AddonGlobals.rankDateSet = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] = {};
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4] , string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] , 1 , string.find ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] , "'" ) + 2 ) , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] } );
            if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex and ( CanGuildPromote() or CanGuildDemote() ) then
                GRM_SetPromoDateButton:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -75 ); -- slightly varied positioning due to drop down window or not.
            else
                GRM_SetPromoDateButton:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -67 );
            end
            
            GRM_MemberDetailRankDateTxt:Hide();
            GRM_SetPromoDateButton:Show();
            GRM_altDropDownOptions:Hide();
            break;
        end
    end
end

-- Method:              GRM.ClearJoinDateHistory ( string )
-- What it Does:        Clears the player's history on when they joined/left/rejoined the guild to be as if they were  a new member
-- Purpose:             Micromanagement of toons metadata.
GRM.ClearJoinDateHistory = function ( name )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] = nil;   -- oldJoinDate wiped!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] = GRM.GetTimestamp();
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] = time();
            GRM_JoinDateText:Hide();
            GRM_altDropDownOptions:Hide();
            GRM_MemberDetailJoinDateButton:Show();
            break;
        end
    end
end

-- Method:              GRM.ResetPlayerMetaData ( string , string )
-- What it Does:        Purges all metadata from an alt up to that point and resets them as if they were just added to the guild roster
-- Purpose:             Metadata player management. QoL feature if ever needed.
GRM.ResetPlayerMetaData = function ( playerName , guildName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then
            GRM.Report ( GRM.SlimName ( playerName ) .. "'s saved data has been wiped!" );
            local memberInfo = { playerName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][5] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][6] , 
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][7] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9] , nil , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][28] , 
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][29] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][30] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][31] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][33] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][34] };

            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , playerName , guildName , false , 0 );      -- Removing oneself from his alts list on clearing info so it clears him from them too.
            end
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , j );         -- Remove the player!
            GRM.AddMemberRecord( memberInfo , false , nil , guildName )     -- Re-Add the player!
            GRM_MemberDetailMetaData:Hide();
            
            --Let's re-initiate syncing!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing then -- and GRM.IsGuildChatEnabled()
                chat:AddMessage ( "Re-Syncing " .. GRM.SlimName ( playerName ) .. "'s Player Data... " , 1.0 , 0.84 , 0 );
                GRMsync.Initialize();
            end
            break;
        end
    end
end

-- Method:          GRM.ResetAllSavedData()
-- What it Does:    Purges literally ALL saved data, then rebuilds it from scratch as if addon was just installed.
-- Purpose:         Clear data for any purpose needed.
GRM.ResetAllSavedData = function()
    GRM.Report ( "Wiping all saved Roster data! Rebuilding from scratch..." );

    GRM_GuildMemberHistory_Save = nil;
    GRM_GuildMemberHistory_Save = {};
    table.insert ( GRM_GuildMemberHistory_Save , { "Horde" } );
    table.insert ( GRM_GuildMemberHistory_Save , { "Alliance" } );

    GRM_PlayersThatLeftHistory_Save = nil;
    GRM_PlayersThatLeftHistory_Save = {};
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Horde" } );
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Alliance" } );

    GRM_LogReport_Save = nil;
    GRM_LogReport_Save = {};
    table.insert ( GRM_LogReport_Save , { "Horde" } );
    table.insert ( GRM_LogReport_Save , { "Alliance" } );

    GRM_CalendarAddQue_Save = nil;
    GRM_CalendarAddQue_Save = {};
    table.insert ( GRM_CalendarAddQue_Save , { "Horde" } );
    table.insert ( GRM_CalendarAddQue_Save , { "Alliance" } );

    -- Hide the window frame so it can quickly be reloaded.
    GRM_MemberDetailMetaData:Hide();

    -- Reset the important guild indexes for data tracking.
    GRM_AddonGlobals.saveGID = 0;
    GRM_AddonGlobals.logGID = 0;

    -- Now, let's rebuild...
    if IsInGuild() then
        GRM.BuildNewRoster();
    end
    -- Update the logFrame if it was open at the time too
    if GRM_RosterChangeLogFrame:IsVisible() then
        GRM.BuildLog();
    end
end

-- Method:          GRM.ResetLogReport()
-- What it Does:    Deletes the guild Log
-- Purpose:         In case player wishes to reset guild Log information.
GRM.ResetLogReport = function()
    if #GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] == 1 then
        GRM.Report ( "There are No Log Entries to Delete, silly " .. GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. "!" );
    else
        GRM.Report ( "Guild Log has been RESET!" );
        -- Actually resetting log. Just remove, then add back empty
        table.remove ( GRM_LogReport_Save[GRM_AddonGlobals.FID] , GRM_AddonGlobals.logGID );
        table.insert ( GRM_LogReport_Save[GRM_AddonGlobals.FID] , { GRM_AddonGlobals.guildName } );
        -- Need to reset Guild Index Location
        for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
            if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                GRM_AddonGlobals.logGID = i;
                break;
            end
        end
        if GRM_RosterChangeLogFrame:IsVisible() then    -- if frame is open, let's rebuild it!
            GRM.BuildLog();
        end
    end
end


---------------------------------
------ CLASS INFO ---------------
---------------------------------

GRM.GetClassRoles = function( className )
    local result;
    
    if className == "DEATH KNIGHT" then
        result = { "Blood" , 135770 ,  "Frost" , 135773 , "Unholy" , 135775 };
    elseif className == "DEMON HUNTER" then
        result = { "Havoc" , 1247264 , "Vengeance" , 1247265 , nil , nil };
    elseif className == "DRUID" then
        result = { "Restoration" , 0 , "Guardian" , 0 , "Feral" , 132115 , "Balance" , 0 };
    elseif className == "HUNTER" then

    elseif className == "MAGE" then

    elseif className == "MONK" then

    elseif className == "PALADIN" then

    elseif className == "PRIEST" then

    elseif className == "ROGUE" then

    elseif className == "SHAMAN" then

    elseif className == "WARLOCK" then

    elseif className == "WARRIOR" then

    end
    
    -- return result;
end






-------------------------------
----- UI SCRIPTING LOGIC ------
----- ALL THINGS UX ARE HERE --
-------------------------------

-- Method:          PopulateMemberDetails ( string )
-- What it Does:    Builds the details for the core MemberInfoFrame
-- Purpose:         Iterate on each mouseover... Furthermore, this is being kept in "Local" for even the most infinitesimal cost-saving on resources
--                  by not indexing it in a table. Buried in it will be mostly non-compartmentalized logic, few function calls.
local function PopulateMemberDetails( handle )
    GRM_AddonGlobals.rankDateSet = false;        -- resetting tracker

    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == handle then   --- Player Found in MetaData Logs
            -- Trigger Check for Any Changes
            GuildRoster();

            --- CLASS
            local classColors = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] );
            GRM_MemberDetailNameText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1.0 );
            
            -- PLAYER NAME
            -- Let's scale the name too!
            GRM_MemberDetailNameText:SetText ( GRM.SlimName ( handle ) );
            local nameHeight = 16;
            GRM_MemberDetailNameText:SetFont ( "Fonts\\FRIZQT__.TTF" , nameHeight );        -- Reset size back to 16 just in case previous fontstring was altered 
            while ( GRM_MemberDetailNameText:GetWidth() > 120 ) do
                nameHeight = nameHeight - 0.1;
                GRM_MemberDetailNameText:SetFont ( "Fonts\\FRIZQT__.TTF" , nameHeight );
            end

            -- IS MAIN
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][10] then
                GRM_MemberDetailMainText:Show();
            else
                GRM_MemberDetailMainText:Hide();
            end

            --- LEVEL
            GRM_MemberDetailLevel:SetText ( "Level: " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] );

            -- RANK
            GRM_AddonGlobals.tempName = handle;
            GRM_AddonGlobals.rankIndex = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5];

            -- Possibly a player index issue...
            if GRM_AddonGlobals.playerIndex == -1 then
                GRM_AddonGlobals.playerIndex = GRM.GetGuildMemberRankID ( GRM_AddonGlobals.addonPlayerName );
            end

            local canPromote = CanGuildPromote();
            local canDemote = CanGuildDemote();
            if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex and ( canPromote or canDemote ) then
                GRM_MemberDetailRankTxt:Hide();
                GRM.CreateRankDropDown();
            else
                GRM_guildRankDropDownMenuSelected:Hide();
                GRM_MemberDetailRankTxt:SetText ( "\"" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] .. "\"");
                GRM_MemberDetailRankTxt:Show();
            end

            -- STATUS TEXT
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] or handle == GRM_AddonGlobals.addonPlayerName then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] == 0 then
                    GRM_MemberDetailPlayerStatus:SetTextColor ( 0.12 , 1.0 , 0.0 , 1.0 );
                    GRM_MemberDetailPlayerStatus:SetText ( "( Active )" );
                elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] == 1 then
                    GRM_MemberDetailPlayerStatus:SetTextColor ( 1.0 , 0.96 , 0.41 , 1.0 );
                    GRM_MemberDetailPlayerStatus:SetText ( "( AFK )" );
                else
                    GRM_MemberDetailPlayerStatus:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
                    GRM_MemberDetailPlayerStatus:SetText ( "( Busy )" );
                end
                GRM_MemberDetailPlayerStatus:Show();
            elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][30] then
                GRM_MemberDetailPlayerStatus:SetTextColor ( 0.87 , 0.44 , 0.0 , 1.0 );
                GRM_MemberDetailPlayerStatus:SetText ( "( Mobile )" );
                GRM_MemberDetailPlayerStatus:Show();
            elseif not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                GRM_MemberDetailPlayerStatus:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
                GRM_MemberDetailPlayerStatus:SetText ( "( Offline )" );
                GRM_MemberDetailPlayerStatus:Show();
            else
                GRM_MemberDetailPlayerStatus:Hide();
            end

            -- ZONE INFORMATION
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                end
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
            else
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Hide();
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Hide();
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Hide();
                GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Hide();
            end

            --RANK PROMO DATE
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] == nil then      --- Promotion has never been recorded!
                GRM_MemberDetailRankDateTxt:Hide();
                if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex and ( canPromote or canDemote ) then
                    GRM_SetPromoDateButton:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -75 ); -- slightly varied positioning due to drop down window or not.
                else
                    GRM_SetPromoDateButton:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -67 );
                end
                GRM_SetPromoDateButton:Show();
            else
                GRM_SetPromoDateButton:Hide();
                if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex and ( canPromote or canDemote ) then
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -80 ); -- slightly varied positioning due to drop down window or not.
                else
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -68 );
                end
                GRM_AddonGlobals.rankDateSet = true;
                GRM_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
                GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , 1 , 10) ) );
                GRM_MemberDetailRankDateTxt:Show();
            end

            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] == 0 then
                GRM_JoinDateText:Hide();
                GRM_MemberDetailJoinDateButton:Show();
            else
                GRM_MemberDetailJoinDateButton:Hide();
                GRM_JoinDateText:SetText ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20]] , 1 , 10 ) );
                GRM_JoinDateText:Show();
            end

            -- PLAYER NOTE AND OFFICER NOTE EDIT BOXES
            local finalNote = "Click here to set a Public Note";
            local finalONote = "Click here to set an Officer's Note";
            GRM_PlayerNoteEditBox:Hide();
            GRM_PlayerOfficerNoteEditBox:Hide();

            -- Set Public Note if is One
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] ~= "" then
                finalNote = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7];
            end
            GRM_noteFontString1:SetText ( finalNote );
            if CanEditPublicNote() then
                if finalNote ~= "Click here to set a Public Note" then
                    GRM_PlayerNoteEditBox:SetText( finalNote );
                else
                    GRM_PlayerNoteEditBox:SetText( "" );
                end
            elseif finalNote == "Click here to set a Public Note" then
                GRM_noteFontString1:SetText ( "Unable to Edit Public Note at Rank" );
            end

            -- Set O Note
            if CanViewOfficerNote() == true then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] ~= "" then
                    finalONote = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8];
                end
                if finalONote == "Click here to set an Officer's Note" and CanEditOfficerNote() ~= true then
                    finalONote = "Unable to Add Officer Note at Rank";
                end
                GRM_noteFontString2:SetText ( finalONote );
                if finalONote ~= "Click here to set an Officer's Note" then
                    GRM_PlayerOfficerNoteEditBox:SetText( finalONote );
                else
                    GRM_PlayerOfficerNoteEditBox:SetText( "" );
                end
            else
                GRM_noteFontString2:SetText ( "Unable to View Officer Note at Rank" );
            end
            GRM_noteFontString2:Show();
            GRM_noteFontString1:Show();

            -- Last Online
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                GRM_MemberDetailLastOnlineTxt:SetText ( "Online" );
            else
                GRM_MemberDetailLastOnlineTxt:SetText ( GRM.HoursReport ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] ) );
            end

            -- Group Invite Button -- Setting script here
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] and handle ~= GRM_AddonGlobals.addonPlayerName then
                GRM.SetGroupInviteButton ( handle );
                GRM_GroupInviteButton:Show();
            else
                GRM_GroupInviteButton:Hide();
            end

            -- REMOVE SOMEONE FROM GUILD BUTTON.
            -- No need to show this if the player themselves is the one that is banned.
            if handle ~= GRM_AddonGlobals.addonPlayerName and CanGuildRemove() then
                local isGuildieBanned = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1];
                if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex and CanGuildRemove() then
                    if isGuildieBanned then
                        GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetText ( "Re-Kick" );
                    else
                        GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetText ( "Remove" );
                    end
                    GRM_RemoveGuildieButton:Show();
                else
                    GRM_RemoveGuildieButton:Hide();
                    GRM_MemberDetailBannedText1:Hide();
                    GRM_MemberDetailBannedIgnoreButton:Hide();
                end

                -- Player was previous banned and rejoined logic! This will unban the player.
                if isGuildieBanned then
                    GRM_MemberDetailBannedIgnoreButton:SetScript ( "OnClick" , function ( _ , button ) 
                        if button == "LeftButton" then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17] = nil;
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17] = { false , 0 , false }
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
                            GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetText( "Remove" );
                            GRM_MemberDetailBannedText1:Hide();
                            GRM_MemberDetailBannedIgnoreButton:Hide();
                            GRM_PopupWindow:Hide();
                        end
                    end);
                    
                    GRM_MemberDetailBannedText1:Show();
                    GRM_MemberDetailBannedIgnoreButton:Show();
                else
                    GRM_MemberDetailBannedText1:Hide();
                    GRM_MemberDetailBannedIgnoreButton:Hide();
                end
            else
                GRM_RemoveGuildieButton:Hide();
                GRM_MemberDetailBannedText1:Hide();
                GRM_MemberDetailBannedIgnoreButton:Hide();
            end

            -- ALTS 
            GRM.PopulateAltFrames ( r );

            break;
        end
    end
end

-- Method:          GRM.ClearAllFrames()
-- What it Does:    Ensures frames are properly reset upon frame reload...
-- Purpose:         Logic time-saver for minimal costs... why check status of them all when you can just disable and build anew on each reload?
GRM.ClearAllFrames = function()
    GRM_MemberDetailMetaData:Hide();
    GRM_MonthDropDownMenuSelected:Hide();
    GRM_YearDropDownMenuSelected:Hide();
    GRM_DayDropDownMenuSelected:Hide();
    GRM_guildRankDropDownMenuSelected:Hide();
    GRM_DateSubmitButton:Hide();
    GRM_DateSubmitCancelButton:Hide();
    GRM_PopupWindow:Hide();
    GRM_NoteCount:Hide();
    GRM_CoreAltFrame:Hide();
    GRM_altDropDownOptions:Hide();
    GRM_AddAltButton:Hide();
    GRM_AddAltEditFrame:Hide();
end

-- Method:          GRM.SubFrameCheck()
-- What it Does:    Checks the core main frames, if they are open... and hides them
-- Purpose:         Questionable at this time... I might rewrite it with just 4 lines... It serves its purpose now
GRM.SubFrameCheck = function()
    -- wipe the frames...
    if GRM_DateSubmitCancelButton:IsVisible() then
        GRM_DateSubmitCancelButton:Click();
    end
    if GRM_AddAltEditFrame:IsVisible() then
        GRM_AddAltEditFrame:Hide();
    end
    if GRM_PopupWindow:IsVisible() then
        GRM_PopupWindow:Hide();
    end
    if GRM_NoteCount:IsVisible() then
        GRM_NoteCount:Hide();
    end
end

-- Method:          GRM.GetNumGuildiesOnline()
-- What it Does:    Returns the int number of players currently online.
-- Purpose:         So on mouseover, the index on the roster call can be determined properly as online people are indexed first.
GRM.GetNumGuildiesOnline = function()
    local count = 0;
    for i = 1 , GRM.GetNumGuildies() do 
        local _ , _ , _ , _ , _ , _ , _ , _ , online , _ , _ , _ , _ , isMobile = GetGuildRosterInfo ( i );
        if online or isMobile then
            count = count + 1;
        end
    end
    return count;
end


-- Method:              GR_RosterFrame(self,elapsed)
-- What it Does:        In the main guild window, guild roster screen, rather than having to select a guild member to see the additional window pop update
--                      all the player needs to do is just mousover it.
-- Purpose:             This is for more efficient "glancing" at info for guild leader, with more details.
--                      NOTE: Also going to keep this as a local variable, not in a table, just for purposes of the faster response time, albeit minimally.
local function GR_RosterFrame ( _ , elapsed )
    GRM_AddonGlobals.timer = GRM_AddonGlobals.timer + elapsed;
    if GRM_AddonGlobals.timer >= 0.038 then
        -- Frame button logic for AddEvent
        if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] ~= nil then
            if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] then
                GRM_AddEventLoadFrameButtonText:SetText ( "Calendar Que: " .. #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 );     -- First index will be nil.
                GRM_AddEventLoadFrameButton:Show();
            else
                GRM_AddEventLoadFrameButton:Hide();
            end
            -- control on whether to freeze the scanning.
            if GRM_AddonGlobals.pause and GRM_MemberDetailMetaData:IsVisible() == false then
                GRM_AddonGlobals.pause = false;
            end

            if GRM_AddonGlobals.pause == false and not DropDownList1:IsVisible() and ( GuildRosterViewDropdownText:IsVisible() and GuildRosterViewDropdownText:GetText() ~= "Professions" ) then
                GRM.SubFrameCheck();
                local NotSameWindow = true;
                local mouseNotOver = true;
                local name = "";
                local length = 84;

                if ( GuildRosterContainerButton1:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 1 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton1 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 1;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton2:IsVisible() and GuildRosterContainerButton2:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 2 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton2 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 2;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton3:IsVisible() and GuildRosterContainerButton3:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 3 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton3 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 3;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton4:IsVisible() and GuildRosterContainerButton4:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 4 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton4 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 4;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton5:IsVisible() and GuildRosterContainerButton5:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 5 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton5 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 5;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton6:IsVisible() and GuildRosterContainerButton6:IsMouseOver(1,-1,-1,1) ) then
                    if 6 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton6 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 6;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton7:IsVisible() and GuildRosterContainerButton7:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 7 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton7 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 7;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton8:IsVisible() and GuildRosterContainerButton8:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 8 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton8 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 8;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton9:IsVisible() and GuildRosterContainerButton9:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 9 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton9 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 9;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton10:IsVisible() and GuildRosterContainerButton10:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 10 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton10 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 10;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton11:IsVisible() and GuildRosterContainerButton11:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 11 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton11 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 11;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton12:IsVisible() and GuildRosterContainerButton12:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 12 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton12 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 12;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton13:IsVisible() and GuildRosterContainerButton13:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 13 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton13 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 13;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                elseif ( GuildRosterContainerButton14:IsVisible() and GuildRosterContainerButton14:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                    if 14 ~= GRM_AddonGlobals.position then
                        name = GRM.GetMouseOverName ( GuildRosterContainerButton14 );
                        if name ~= GRM_AddonGlobals.currentName then
                            PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.position = 14;
                            GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                            GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            NotSameWindow = false;
                        end
                    else
                        NotSameWindow = false;
                    end
                    mouseNotOver = false;
                end
                -- Logic on when to make Member Detail window disappear.
                if mouseNotOver and NotSameWindow and GRM_AddonGlobals.pause == false then
                    if ( GuildRosterFrame:IsMouseOver ( 2 , -2 , -2 , 2 ) ~= true and DropDownList1Backdrop:IsMouseOver ( 2 , -2 , -2 , 2 ) ~= true and GRM_MemberDetailMetaData:IsMouseOver ( 2 , -2 , -2 , 2 ) ~= true ) or 
                        ( GRM_MemberDetailMetaData:IsMouseOver ( 2 , -2 , -2 , 2 ) == true and GRM_MemberDetailMetaData:IsVisible() ~= true ) then  -- If player is moused over side window, it will not hide it!
                        GRM_AddonGlobals.position = 0;
                        
                        GRM.ClearAllFrames();
                    end
                end
            end
        end

        if GuildRosterFrame:IsVisible() ~= true or ( GuildRosterViewDropdownText:IsVisible() and GuildRosterViewDropdownText:GetText() == "Professions" ) then
            
            GRM.ClearAllFrames();

        end
        GRM_AddonGlobals.timer = 0;
    end
end

--- FINALLY!!!!!
--- TOOLTIPS ---
----------------

-- Method:          GRM.MemberDetailToolTips ( self , float )
-- What it Does:    Populates the tooltips on the "OnUpdate" check for the core Member Detail frame
-- Purpose:         UI Feature
GRM.MemberDetailToolTips = function ( self , elapsed )
    GRM_AddonGlobals.timer2 = GRM_AddonGlobals.timer2 + elapsed;
    if GRM_AddonGlobals.timer2 >= 0.075 then
        local name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );

        -- Rank Text
        -- Only populate and show tooltip if mouse is over text frame and it is not already visible.
        if GRM_MemberDetailRankToolTip:IsVisible() ~= true and not GRM_RankDropDownMenu:IsVisible() and GRM_MemberDetailRankDateTxt:IsVisible() == true and GRM_altDropDownOptions:IsVisible() ~= true and GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) == true then
            
            GRM_MemberDetailRankToolTip:SetOwner( GRM_MemberDetailRankDateTxt , "ANCHOR_BOTTOMRIGHT" );
            GRM_MemberDetailRankToolTip:AddLine( "|cFFFFFFFFRank History");

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Now, let's build the tooltip
                    for k = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , 1 , -1 do
                        if k == #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] then
                            local timeAtRank = GRM.GetTimePassedUsingStringStamp ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] );
                            GRM_MemberDetailRankToolTip:AddDoubleLine ( "|cFFFF0000Time at Rank: " , timeAtRank[4] );
                            GRM_MemberDetailRankToolTip:AddDoubleLine ( " " , " " );
                        end
                        GRM_MemberDetailRankToolTip:AddDoubleLine( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25][k][1] .. ":" , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25][k][2] , 0.38 , 0.67 , 1.0 );
                    end
                    break;
                end
            end

            GRM_MemberDetailRankToolTip:Show();
        elseif GRM_MemberDetailRankToolTip:IsVisible() == true and GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) ~= true then
            GRM_MemberDetailRankToolTip:Hide();
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- JOIN DATE TEXT
        if GRM_MemberDetailJoinDateToolTip:IsVisible() ~= true and GRM_JoinDateText:IsVisible() == true and GRM_altDropDownOptions:IsVisible() ~= true and GRM_JoinDateText:IsMouseOver(1,-1,-1,1) == true then
           
            GRM_MemberDetailJoinDateToolTip:SetOwner( GRM_JoinDateText , "ANCHOR_BOTTOMRIGHT" );
            GRM_MemberDetailJoinDateToolTip:AddLine( "|cFFFFFFFFMembership History");
            local joinedHeader;

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Ok, let's build the tooltip now.
                    for r = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , 1 , -1 do                                       -- Starting with most recent join which will be at end of array.
                        if r > 1 then
                            joinedHeader = "Rejoined: ";
                        else
                            joinedHeader = "Joined: ";
                        end
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15][r] ~= nil then
                            GRM_MemberDetailJoinDateToolTip:AddDoubleLine( "|CFFC41F3BLeft:    " ,  GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15][r] , 1 , 10 ) ) , 1 , 0 , 0 );
                        end
                        GRM_MemberDetailJoinDateToolTip:AddDoubleLine( joinedHeader , GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20][r] , 1 , 10 ) ) , 0.38 , 0.67 , 1.0 );
                        -- If player once left, then this will add the line for it.
                    end
                break;
                end
            end

            GRM_MemberDetailJoinDateToolTip:Show();
        elseif GRM_JoinDateText:IsMouseOver(1,-1,-1,1) ~= true and ( GRM_MemberDetailJoinDateToolTip:IsVisible() or GRM_MemberDetailServerNameToolTip:IsVisible() ) then
            GRM_MemberDetailJoinDateToolTip:Hide();
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Mouseover name shows full server... useful on merged realms.
        if not GRM_altDropDownOptions:IsVisible() and GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            -- Get Class Color
            local textR, textG, textB = GRM_MemberDetailNameText:GetTextColor();

            -- Build the tooltip
            GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_JoinDateText , "ANCHOR_CURSOR" );
            GRM_MemberDetailServerNameToolTip:AddLine ( name , textR , textG , textB );

            GRM_MemberDetailServerNameToolTip:Show();
        else
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Mouseover on Alt Names
        if GRM_AltName1:IsVisible() or ( GRM_AltAdded1 ~= nil and GRM_AltAdded1:IsVisible() ) then
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];

                        -- for regular frames
                        if #listOfAlts <= 12 then
                            local numAlt = 0;
                            if GRM_AltName1:IsVisible() and GRM_AltName1:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 1;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName1 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName2:IsVisible() and GRM_AltName2:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 2;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName2 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName3:IsVisible() and GRM_AltName3:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 3;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName3 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName4:IsVisible() and GRM_AltName4:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 4;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName4 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName5:IsVisible() and GRM_AltName5:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 5;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName5 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName6:IsVisible() and GRM_AltName6:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 6;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName6 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName7:IsVisible() and GRM_AltName7:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 7;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName7 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName8:IsVisible() and GRM_AltName8:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 8;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName8 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName9:IsVisible() and GRM_AltName9:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 9;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName9 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName10:IsVisible() and GRM_AltName10:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 10;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName10 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName11:IsVisible() and GRM_AltName11:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 11;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName11 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            elseif GRM_AltName12:IsVisible() and GRM_AltName12:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 12;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName12 , "ANCHOR_CURSOR" );
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                            end

                            if numAlt > 0 then
                                GRM_MemberDetailServerNameToolTip:Show();
                            elseif not GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                GRM_MemberDetailServerNameToolTip:Hide();
                            end

                        else
                            local isOver = false;
                            for i = 1 , #GRM_CoreAltScrollChildFrame.allFrameButtons do
                                if GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsVisible() and GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_CoreAltScrollChildFrame.allFrameButtons[i][1] , "ANCHOR_CURSOR" );
                                    GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[i][1] , listOfAlts[i][2] , listOfAlts[i][3] , listOfAlts[i][4] );
                                    isOver = true;
                                    break;
                                end
                            end

                            if isOver and not GRM_altDropDownOptions:IsVisible() then
                                GRM_MemberDetailServerNameToolTip:Show();
                            elseif GRM_altDropDownOptions:IsVisible() and not GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                GRM_MemberDetailServerNameToolTip:Hide();
                            end
                        end

                    break;
                end
            end
        elseif not GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        GRM_AddonGlobals.timer2 = 0;
    end
end


----------------------
--- FRAME VALUES -----
--- AND PARAMETERS ---
----------------------

-- Method:          GRM.LogOptionsFadeIn()
-- What it Does:    Fades in the Options frame and buttons on the guildRoster Log window
-- Purpose:         Really, just aesthetics for User Experience.
GRM.LogOptionsFadeIn = function()

    GRM_RosterCheckBoxSideFrame:SetAlpha ( GRM_RosterCheckBoxSideFrame:GetAlpha() + 0.025 );
    if GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
        GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetAlpha ( GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:GetAlpha() + 0.025 );
    end

    if GRM_RosterCheckBoxSideFrame:GetAlpha() < 1 then
        C_Timer.After ( 0.01 , GRM.LogOptionsFadeIn );
    end
end

-- Method:          GRM.LogOptionsFadeOut()
-- What it Does:    Fades OUT the Options frame and buttons on the guildRoster Log window
-- Purpose:         Really, just aesthetics for User Experience.
GRM.LogOptionsFadeOut = function()
    
    GRM_RosterCheckBoxSideFrame:SetAlpha ( GRM_RosterCheckBoxSideFrame:GetAlpha() - 0.05 );
    if GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
        GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetAlpha ( GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:GetAlpha() - 0.05 );
    end
    if GRM_RosterCheckBoxSideFrame:GetAlpha() > 0 then
        C_Timer.After ( 0.01 , GRM.LogOptionsFadeOut );
    end
end

-- Method:          GRM.LogFrameTransformationOpen()
-- What it Does:    Transforms the frame to be larger, revealing the "options" details
-- Purpose:         Really, just aesthetics for User Experience, but also for a concise framework.
GRM.LogFrameTransformationOpen = function ()
    GRM_RosterChangeLogFrame:SetSize ( 600 , GRM_RosterChangeLogFrame:GetHeight() + 3.5 );          -- reset size, slightly increment it up!
    -- Determine if I need to loop through again.
    local fading = false;
    local height = 522;
    if GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
        height = 542;
    end
    if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) < height then   
        if not fading and math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) > 460 then        -- Trigger fade transition into already moving tile.
            GRM.LogOptionsFadeIn();
            fading = true;
        end
         C_Timer.After ( 0.01 , GRM.LogFrameTransformationOpen );
    else        -- Exit from Recursive Loop for transformation.
        GRM_RosterOptionsButton:Enable();
    end
end

-- Method:          GRM.LogFrameTransformationClose()
-- What it Does:    Transforms the frame back to normal side, hiding the "options" details
-- Purpose:         Really, just aesthetics for User Experience, but also for a concise framework.
GRM.LogFrameTransformationClose = function ()
    GRM_RosterChangeLogFrame:SetSize ( 600 , GRM_RosterChangeLogFrame:GetHeight() - 4.0 );          -- reset size, slightly increment it up!
    -- Determine if I need to loop through again.
    if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) > 440 then
         C_Timer.After ( 0.01 , GRM.LogFrameTransformationClose );
    else        -- Exit from Recursive Loop for transformation.
        GRM_RosterCheckBoxSideFrame:Hide();
        GRM_RosterOptionsButton:Enable();
    end
end

-- Method:          GRM.LogFrameTransformationCloseMinor()
-- What it Does:    Transforms the frame back to hide 1 layer of options
-- Purpose:         Really, just aesthetics for User Experience, but also for a concise framework.
GRM.LogFrameTransformationCloseMinor = function ()
    GRM_RosterChangeLogFrame:SetSize ( 600 , GRM_RosterChangeLogFrame:GetHeight() - 4.0 );          -- reset size, slightly increment it up!
    -- Determine if I need to loop through again.
    if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) > 524 then
         C_Timer.After ( 0.01 , GRM.LogFrameTransformationCloseMinor );
    end
end

-- Method:          GRM.UpdateGuildMemberInRaidStatus()
-- What it Does:    Updates the text frame on number of guild members in a current raid group
-- Purpose:         Update, on the fly, every 3 seconds, number of guildies present.
GRM.UpdateGuildMemberInRaidStatus = function ()
    -- Only trigger once per 3 seconds.
    if IsInGroup() and RaidFrame:IsVisible() and not RaidFrameNotInRaid:IsVisible() then
        local numGuildies = GRM.GetNumGuildiesInGroup();
        if numGuildies > 0 then
            UI_Events.GRM_NumGuildiesText:SetText ( "Guildies: " .. numGuildies );
            UI_Events.GRM_NumGuildiesText:Show();
        else
            UI_Events.GRM_NumGuildiesText:Hide();
        end
        C_Timer.After ( 1 , GRM.UpdateGuildMemberInRaidStatus );              -- Check for updates recursively
    elseif IsInGroup() then
        UI_Events.GRM_NumGuildiesText:Hide();
        C_Timer.After ( 1 , GRM.UpdateGuildMemberInRaidStatus );
    else
        UI_Events.GRM_NumGuildiesText:Hide();
        GRM_AddonGlobals.RaidGCountBeingChecked = false;
    end
end

-- Method:          GRM.ReportGuildJoinApplicants()
-- What it Does:    Returns true if there is a current request to join the guild
-- Purpose:         To remind anyone with guild invite privileges to review if player has requested to join
GRM.ReportGuildJoinApplicants = function()
    if CanGuildInvite() then                    -- No point in checking this if you don't have invite privileges and you can't see the application!
        local numApps = GetNumGuildApplicants();
        if numApps > 0 and numApps > GRM_AddonGlobals.numPlayersRequestingGuildInv then
            GRM_AddonGlobals.numPlayersRequestingGuildInv = numApps;
            chat:AddMessage ( "\n--------------------------------\n--- Guild Invite Request ---\n--------------------------------\n" , 1 , 1 , 1 , 1 );
            for i = 1 , numApps do
                local recruit , level , className , _,_,_,_,_,_,_,_,_,_, comment = GetGuildApplicantInfo ( i );
                if comment == nil or comment == "" then
                    comment = "<None Given>";
                end
                chat:AddMessage ( "Name:   " .. recruit , 0 , 0.77 , 0.95 , 1 );
                chat:AddMessage ( "Level:    " .. level , 0 , 0.77 , 0.95 , 1 );
                chat:AddMessage ( "Class:    " .. className , 0 , 0.77 , 0.95 , 1 );
                chat:AddMessage ( "Reason: " .. comment , 0 , 0.77 , 0.95 , 1 );
                print("\n");
            end
        end
    end
end


-- Method:          GR_MetaDataInitializeUIFirst()
-- What it Does:    Initializes "some of the frames"
-- Purpose:         Should only initialize as needed. Kept as local for speed
GRM.GR_MetaDataInitializeUIFirst = function()
    -- Frame Control
    GRM_MemberDetailMetaData:EnableMouse ( true );
    -- GRM_MemberDetailMetaData:SetMovable ( true );
    -- GRM_MemberDetailMetaData:RegisterForDrag ( "LeftButton" );
    -- GRM_MemberDetailMetaData:SetScript ( "OnDragStart" , GRM_MemberDetailMetaData.StartMoving );
    -- GRM_MemberDetailMetaData:SetScript ( "OnDragStop" , GRM_MemberDetailMetaData.StopMovingOrSizing );
    GRM_MemberDetailMetaData:SetToplevel ( true );

    -- Placement and Dimensions
    GRM_MemberDetailMetaData:SetPoint ( "TOPLEFT" , GuildRosterFrame , "TOPRIGHT" , -4 , 5 );
    GRM_MemberDetailMetaData:SetSize( 300 , 330 );
    GRM_MemberDetailMetaData:SetScript( "OnShow" , function() 
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton:SetPoint( "TOPRIGHT" , GRM_MemberDetailMetaData , 3, 3 ); 
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaDataCloseButton:Show()
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
                GRM_altOptionsDividerText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
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
        end
    end);

    -- Keyboard Control for easy ESC closeButtons
    tinsert( UISpecialFrames, "GRM_MemberDetailMetaData" );

    -- CORE FRAME CHILDREN FEATURES
    -- rank drop down 
    GRM_guildRankDropDownMenuSelected:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -50 );
    GRM_guildRankDropDownMenuSelected:SetSize (  135 , 22 );
    GRM_guildRankDropDownMenuSelected.RankText:SetPoint ( "CENTER" , GRM_guildRankDropDownMenuSelected );
    GRM_guildRankDropDownMenuSelected.RankText:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_RankDropDownMenu:SetPoint ( "TOP" , GRM_guildRankDropDownMenuSelected , "BOTTOM" );
    GRM_RankDropDownMenu:SetWidth ( 135 );
    GRM_RankDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_RankDropDownMenuButton:SetPoint ( "RIGHT" , GRM_guildRankDropDownMenuSelected , 0 , -1 );
    GRM_RankDropDownMenuButton:SetSize ( 20 , 18 );

    GRM_RankDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_RankDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_RankDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_RankDropDownMenu:Hide();
            GRM_guildRankDropDownMenuSelected:Show();
        end
    end);

    GRM_guildRankDropDownMenuSelected:SetScript ( "OnShow" , function() 
        GRM_RankDropDownMenu:Hide();
    end)

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
    GRM_SetPromoDateButton.GRM_SetPromoDateButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GRM_SetPromoDateButton:SetSize ( 90 , 18 );
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
    GRM_DateSubmitCancelButtonTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.9 );
    GRM_DateSubmitCancelButtonTxt:SetText ( "Cancel" );
    GRM_DateSubmitButtonTxt:SetPoint ( "CENTER" , GRM_DateSubmitButton );
    GRM_DateSubmitButtonTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.9 );
    GRM_DateSubmitButton:SetScript ( "OnShow" , function()
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Hide();
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Hide();
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Hide();
        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Hide();
    end);
    
    -- Name Text
    GRM_MemberDetailNameText:SetPoint( "TOP" , 0 , -20 );
    GRM_MemberDetailNameText:SetFont (  "Fonts\\FRIZQT__.TTF" , 16 );

    -- LEVEL Text
    GRM_MemberDetailLevel:SetPoint ( "TOP" , 0 , -38 );
    GRM_MemberDetailLevel:SetFont (  "Fonts\\FRIZQT__.TTF" , 10 );

    -- Rank promotion date text
    GRM_MemberDetailRankTxt:SetPoint ( "TOP" , 0 , -52 );
    GRM_MemberDetailRankTxt:SetFont (  "Fonts\\FRIZQT__.TTF" , 13 );
    GRM_MemberDetailRankTxt:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );

    -- "MEMBER SINCE"
    GRM_JoinDateText:SetPoint ( "TOPRIGHT" , GRM_MemberDetailMetaData , -21 , - 33 );
    GRM_JoinDateText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_JoinDateText:SetWidth ( 55 );
    GRM_JoinDateText:SetJustifyH ( "CENTER" );

    -- "LAST ONLINE" 
    GRM_MemberDetailLastOnlineTitleTxt:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 16 , -22 );
    GRM_MemberDetailLastOnlineTitleTxt:SetText ( "Last Online" );
    GRM_MemberDetailLastOnlineTitleTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 , "THICKOUTLINE" );
    GRM_MemberDetailLastOnlineTxt:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 16 , -32 );
    GRM_MemberDetailLastOnlineTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GRM_MemberDetailLastOnlineTxt:SetWidth ( 65 );
    GRM_MemberDetailLastOnlineTxt:SetJustifyH ( "CENTER" );
    
    -- PLAYER STATUS
    GRM_MemberDetailPlayerStatus:SetPoint ( "TOPLEFT" , GRM_MemberDetailMetaData , 23 , - 52 );
    GRM_MemberDetailPlayerStatus:SetWidth ( 50 );
    GRM_MemberDetailPlayerStatus:SetJustifyH ( "CENTER" );
    GRM_MemberDetailPlayerStatus:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );

    -- ZONE
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetPoint ( "LEFT" , GRM_MemberDetailMetaData , 18 , 60 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 , "THICKOUTLINE" );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:SetText ( "Zone:" );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetPoint ( "LEFT" , GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText , "RIGHT" , 2 , 0 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetPoint ( "TOP" , GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText , "BOTTOM" , 10 , -2 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:SetText ( "Time In: " );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetPoint ( "LEFT" , GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1 , "RIGHT" , 2 , 0 );
    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    
    -- Is Main Note!
    GRM_MemberDetailMainText:SetPoint ( "TOP" , GRM_MemberDetailMetaData , 0 , -12 );
    GRM_MemberDetailMainText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_MemberDetailMainText:SetText ( "( Main )" );
    GRM_MemberDetailMainText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );

    -- Join Date Button Logic for visibility
    GRM_MemberDetailDateJoinedTitleTxt:SetPoint ( "TOPRIGHT" , GRM_MemberDetailMetaData , -14 , -22 );
    GRM_MemberDetailDateJoinedTitleTxt:SetText ( "Date Joined" );
    GRM_MemberDetailDateJoinedTitleTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 , "THICKOUTLINE" );
    GRM_MemberDetailJoinDateButton:SetPoint ( "TOPRIGHT" , GRM_MemberDetailMetaData , -19 , - 32 );
    GRM_MemberDetailJoinDateButton:SetSize ( 60 , 17 );
    GRM_MemberDetailJoinDateButtonText:SetPoint ( "CENTER" , GRM_MemberDetailJoinDateButton );
    GRM_MemberDetailJoinDateButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
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
    GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
        
    -- REMOVE GUILDIE BUTTON
    GRM_RemoveGuildieButton:SetPoint ( "BOTTOMRIGHT" , GRM_MemberDetailMetaData , -15, 13 )
    GRM_RemoveGuildieButton:SetSize ( 88 , 19 );
    GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetPoint ( "CENTER" , GRM_RemoveGuildieButton );
    GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GRM_RemoveGuildieButton:SetScript ( "OnClick" , function ( _ , button )
        -- Inital check is to ensure clean UX - ensuring the next time window is closed on reload, but if already open, no need to close it.
        if button == "LeftButton" then
            GRM_AddonGlobals.pause = true
            local frameName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
            if GRM_PopupWindow:IsVisible() ~= true then
                GRM_MemberDetailEditBoxFrame:Hide();
                GRM_PopupWindowCheckButton1:SetChecked ( false ); -- Ensures it is always unchecked on load.
                GRM_PopupWindowCheckButton2:SetChecked ( false );
            end
            if GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:GetText() == "Re-Kick" then
                GRM_PopupWindowConfirmText:SetText ( "Are you sure you want to Re-Gkick " .. GRM.SlimName ( frameName ) .. "?" );
            else
                GRM_PopupWindowConfirmText:SetText ( "Are you sure you want to Gkick " .. GRM.SlimName ( frameName ) .. "?" );
            end
            if GRM_RemoveGuildieButton.GRM_RemoveGuildieButtonText:GetText() ~= "Re-Kick" then
                GRM_PopupWindowCheckButtonText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
                GRM_PopupWindowCheckButtonText:SetText ( "Ban Player" );
                GRM_PopupWindowCheckButtonText:Show();
                GRM_PopupWindowCheckButton1:Show();
            else
                GRM_PopupWindowCheckButtonText:Hide();
                GRM_PopupWindowCheckButton1:Hide();
            end
            for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == frameName then
                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11] > 0 then
                        GRM_PopupWindowCheckButton2Text:SetTextColor ( 1.0 , 1.0 , 1.0 , 1.0 );
                        GRM_PopupWindowCheckButton2Text:SetText ( "Kick Alts Too!" );
                        GRM_PopupWindowCheckButton2Text:Show();
                        GRM_PopupWindowCheckButton2:Show();
                    else
                        GRM_PopupWindowCheckButton2Text:Hide();
                        GRM_PopupWindowCheckButton2:Hide();
                    end
                    break;
                end
            end
            
            GRM_PopupWindow:Show();
        end
    end);




    -- player note edit box and font string (31 characters)
    GRM_MemberDetailNoteTitle:SetPoint ( "BOTTOMLEFT" , GRM_PlayerNoteWindow , "TOPLEFT" , 5 , 0 );
    GRM_MemberDetailNoteTitle:SetText ( "Note:" );
    GRM_MemberDetailNoteTitle:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

    GRM_MemberDetailONoteTitle:SetPoint ( "BOTTOMLEFT" , GRM_PlayerOfficerNoteWindow , "TOPLEFT" , 5 , 0 );
    GRM_MemberDetailONoteTitle:SetText ( "Officer's Note:" );
    GRM_MemberDetailONoteTitle:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

    -- OFFICER AND PLAYER NOTES
    GRM_PlayerNoteWindow:SetPoint( "LEFT" , GRM_MemberDetailMetaData , 15 , 10 );
    GRM_noteFontString1:SetPoint ( "TOPLEFT" , GRM_PlayerNoteWindow , 9 , -11 );
    GRM_noteFontString1:SetWordWrap ( true );
    GRM_noteFontString1:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
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
    GRM_PlayerNoteEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 9 );
    GRM_PlayerNoteEditBox:EnableMouse( true );
    GRM_PlayerNoteEditBox:SetFrameStrata ( "HIGH" );
    GRM_NoteCount:SetPoint ("TOPRIGHT" , GRM_PlayerNoteWindow , -6 , 8 );
    GRM_NoteCount:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

    -- Officer Note
    GRM_PlayerOfficerNoteWindow:SetPoint( "RIGHT" , GRM_MemberDetailMetaData , -15 , 10 );
    GRM_noteFontString2:SetPoint ( "TOPLEFT" , GRM_PlayerOfficerNoteWindow , 9 , -11 );
    GRM_noteFontString2:SetWordWrap ( true );
    GRM_noteFontString2:SetSpacing ( 1 );
    GRM_noteFontString2:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
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
    GRM_PlayerOfficerNoteEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 9 );
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
        playerDetails.name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
        
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
        playerDetails.name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
        
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
    
end






-- Method:                  GR_MetaDataInitializeUISecond()
-- What it Does:            Initializes "More of the frames values/scripts"
-- Purpose:                 Can only have 60 "up-values" in one function. This splits it up.
GRM.GR_MetaDataInitializeUISecond = function()

    -- CUSTOM POPUP
    GRM_PopupWindow:SetPoint ( "CENTER" , UIParent );
    GRM_PopupWindow:SetSize ( 240 , 120 );
    GRM_PopupWindow:EnableMouse ( true );
    GRM_PopupWindow:EnableKeyboard ( true );
    GRM_PopupWindow:SetToplevel ( true );
    GRM_PopupWindowButton1:SetPoint ( "BOTTOMLEFT" , GRM_PopupWindow , 15 , 14 );
    GRM_PopupWindowButton1:SetSize ( 75 , 25 );
    GRM_PopupWindowButton1.GRM_PopupWindowButton1Text:SetPoint ( "CENTER" , GRM_PopupWindowButton1 );
    GRM_PopupWindowButton1.GRM_PopupWindowButton1Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_PopupWindowButton1.GRM_PopupWindowButton1Text:SetText ( "YES" );
    GRM_PopupWindowButton2:SetPoint ( "BOTTOMRIGHT" , GRM_PopupWindow , -15 , 14 );
    GRM_PopupWindowButton2:SetSize ( 75 , 25 );
    GRM_PopupWindowButton2.GRM_PopupWindowButton2Text:SetPoint ( "CENTER" , GRM_PopupWindowButton2 );
    GRM_PopupWindowButton2.GRM_PopupWindowButton2Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_PopupWindowButton2.GRM_PopupWindowButton2Text:SetText ( "CANCEL" );
    GRM_PopupWindowConfirmText:SetPoint ( "TOP" , GRM_PopupWindow , 0 , -17.5 );
    GRM_PopupWindowConfirmText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_PopupWindowConfirmText:SetWidth ( 185 );
    GRM_PopupWindowConfirmText:SetJustifyH ( "CENTER" );
    GRM_PopupWindowCheckButton1:SetPoint ( "BOTTOMLEFT" , GRM_PopupWindow , 15 , 55 );
    GRM_PopupWindowCheckButtonText:SetPoint ( "RIGHT" , GRM_PopupWindowCheckButton1 , 54 , 0 );
    GRM_PopupWindowCheckButton2:SetPoint ( "BOTTOMLEFT" , GRM_PopupWindow , 15 , 35 );
    GRM_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GRM_PopupWindowCheckButton2 , 70 , 0 );

    GRM_PopupWindowButton1:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            if GRM_PopupWindowCheckButton1:IsVisible() and GRM_PopupWindowCheckButton1:GetChecked() then          -- Box is checked, so YES player should be banned.
                -- Popup edit box
                
                GRM_MemberDetailPopupEditBox:SetText ( "Reason Banned? (Press ENTER when done)" );
                GRM_MemberDetailPopupEditBox:HighlightText ( 0 );
                GRM_MemberDetailEditBoxFrame:Show();
                GRM_MemberDetailPopupEditBox:Show();
            else    -- Kicking the player ( not a ban )
                -- if button 2 is checked, kick the alts too.
                local frameName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
                if GRM_PopupWindowCheckButton2:IsVisible() and GRM_PopupWindowCheckButton2:GetChecked() then
                    GRM.KickAllAlts ( frameName , GRM_AddonGlobals.guildName );
                end
                GRM_PopupWindow:Hide();
                GuildUninvite ( frameName );
                GRM_AddonGlobals.pause = false;
            end
        end
        end);




    GRM_PopupWindowCheckButton1:HookScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if GRM_PopupWindowCheckButton1:GetChecked() ~= true then
                GRM_MemberDetailEditBoxFrame:Hide();                 -- If editframe is up, and you uncheck the box, it hides the editbox too
                GRM_PopupWindowCheckButton2Text:ClearAllPoints();
                GRM_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GRM_PopupWindowCheckButton2 , 70 , 0 );
                GRM_PopupWindowCheckButton2Text:SetTextColor ( 1.0 , 1.0 , 1.0 , 1.0 );
                GRM_PopupWindowCheckButton2Text:SetText ( "Kick Alts Too!" );
                
            else
                GRM_PopupWindowCheckButton2Text:ClearAllPoints();
                GRM_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GRM_PopupWindowCheckButton2 , 112 , 0 );
                GRM_PopupWindowCheckButton2Text:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
                GRM_PopupWindowCheckButton2Text:SetText ( "Kick and Ban Alts too!" );
            end
        end
    end);

    -- Popup logic
    GRM_PopupWindowButton2:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GRM_PopupWindow:Hide();
        end
    end);

    -- Backup logic with Escape key
    GRM_PopupWindow:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_PopupWindow:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_PopupWindow:SetPropagateKeyboardInput ( false );
            GRM_PopupWindow:Hide();
        end
    end);

    GRM_PopupWindow:HookScript ( "OnHide" , function ( self ) 
        GRM_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GRM_PopupWindowCheckButton2 , 70 , 0 );  -- Reset Position
    end);

    -- Popup EDIT BOX
    GRM_MemberDetailEditBoxFrame:SetPoint ( "TOP" , GRM_PopupWindow , "BOTTOM" , 0 , 2 );
    GRM_MemberDetailEditBoxFrame:SetSize ( 240 , 45 );

    GRM_MemberDetailPopupEditBox:SetPoint( "CENTER" , GRM_MemberDetailEditBoxFrame , 0 , 0 );
    GRM_MemberDetailPopupEditBox:SetSize ( 210 , 25 );
    GRM_MemberDetailPopupEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_MemberDetailPopupEditBox:SetMaxLetters ( 155 );
    GRM_MemberDetailPopupEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 9 );
    GRM_MemberDetailPopupEditBox:SetFrameStrata ( "HIGH" );
    GRM_MemberDetailPopupEditBox:EnableMouse( true );

    -- Script handler for General popup editbox.
    GRM_MemberDetailPopupEditBox:SetScript ( "OnEscapePressed" , function ( self )
        GRM_MemberDetailEditBoxFrame:Hide();
    end);

    GRM_MemberDetailPopupEditBox:SetScript ( "OnEnterPressed" , function ( _ )
        -- If kick alts button is checked...
        local frameName = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );
        if GRM_PopupWindowCheckButton2:IsVisible() and GRM_PopupWindowCheckButton2:GetChecked() then
            GRM.KickAllAlts ( frameName , GRM_AddonGlobals.guildName );
        end

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == frameName then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1] = true;      -- This officially tags the player as BANNED!
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][2] = time();
                local result = GRM_MemberDetailPopupEditBox:GetText();
                if result ~= "Reason Banned? (Press ENTER when done)" and result ~= "" and result ~= nil then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                else
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
                    result = "";
                end

                -- Add a log message too if it is a ban!
                local logEntry = "";
                
                if GRM_PopupWindowCheckButton2:IsVisible() and GRM_PopupWindowCheckButton2:GetChecked() then
                    logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " has BANNED " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ) .. " and all linked alts from the guild!!!" );
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] ~= "" then
                        GRM.AddLog ( 18 , "Reason Banned:        " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] );
                    end
                    GRM.AddLog ( 17 , logEntry );
                else
                    logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " has BANNED " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ) .. " from the guild!!!" );
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] ~= "" then
                        GRM.AddLog ( 18 , "Reason Banned:        " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] );
                    end
                    GRM.AddLog ( 17 , logEntry );
                end

                -- Send the message out!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    if result == "" then
                        result = "No Reason Given";
                    end
                    GRMsync.SendMessage ( "GRM_BAN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. frameName .. "?" .. tostring ( GRM_PopupWindowCheckButton2:GetChecked() ) .. "?" .. result , "GUILD" );
                end
                break;
            end
        end
        
        -- Now let's kick the member
        GuildUninvite ( frameName );
        GRM_MemberDetailEditBoxFrame:Hide();
        GRM_AddonGlobals.pause = false;                                                
    end);

    -- Heads-up text if player was previously banned
    GRM_MemberDetailBannedText1:SetPoint ( "CENTER" , GRM_MemberDetailMetaData , -65 , -45.5 );
    GRM_MemberDetailBannedText1:SetWordWrap ( true );
    GRM_MemberDetailBannedText1:SetJustifyH ( "CENTER" );
    GRM_MemberDetailBannedText1:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GRM_MemberDetailBannedText1:SetFont ( "Fonts\\FRIZQT__.TTF" , 8.0 );
    GRM_MemberDetailBannedText1:SetWidth ( 120 );
    GRM_MemberDetailBannedText1:SetText ( "WARNING! WARNING!\nRejoining player was previously banned!" );
    GRM_MemberDetailBannedIgnoreButton:SetPoint ( "CENTER" , GRM_MemberDetailMetaData , -65 , -70.5 );
    GRM_MemberDetailBannedIgnoreButton:SetWidth ( 85 );
    GRM_MemberDetailBannedIgnoreButton:SetHeight ( 19 );
    GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetPoint ( "CENTER" , GRM_MemberDetailBannedIgnoreButton );
    GRM_MemberDetailBannedIgnoreButton.GRM_MemberDetailBannedIgnoreButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
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
    GRM_altFrameTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11 , "THICKOUTLINE" );

    GRM_AddAltButton:SetSize ( 60 , 17 );
    GRM_AddAltButtonText:SetPoint ( "CENTER" , GRM_AddAltButton );
    GRM_AddAltButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltButtonText:SetText( "Add Alt") ; 

    GRM_AddAltButton2:SetSize ( 60 , 17 );
    GRM_AddAltButton2Text:SetPoint ( "CENTER" , GRM_AddAltButton2 );
    GRM_AddAltButton2Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltButton2Text:SetText( "Add Alt") ; 

    GRM_AltName1:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -20 );
    GRM_AltName1:SetWidth ( 60 );
    GRM_AltName1:SetJustifyH ( "CENTER" );
    GRM_AltName1:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName2:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -20 );
    GRM_AltName2:SetWidth ( 60 );
    GRM_AltName2:SetJustifyH ( "CENTER" );
    GRM_AltName2:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName3:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -37 );
    GRM_AltName3:SetWidth ( 60 );
    GRM_AltName3:SetJustifyH ( "CENTER" );
    GRM_AltName3:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName4:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -37 );
    GRM_AltName4:SetWidth ( 60 );
    GRM_AltName4:SetJustifyH ( "CENTER" );
    GRM_AltName4:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName5:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -54 );
    GRM_AltName5:SetWidth ( 60 );
    GRM_AltName5:SetJustifyH ( "CENTER" );
    GRM_AltName5:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName6:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -54 );
    GRM_AltName6:SetWidth ( 60 );
    GRM_AltName6:SetJustifyH ( "CENTER" );
    GRM_AltName6:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName7:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -71 );
    GRM_AltName7:SetWidth ( 60 );
    GRM_AltName7:SetJustifyH ( "CENTER" );
    GRM_AltName7:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName8:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -71 );
    GRM_AltName8:SetWidth ( 60 );
    GRM_AltName8:SetJustifyH ( "CENTER" );
    GRM_AltName8:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName9:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -88 );
    GRM_AltName9:SetWidth ( 60 );
    GRM_AltName9:SetJustifyH ( "CENTER" );
    GRM_AltName9:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName10:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -88 );
    GRM_AltName10:SetWidth ( 60 );
    GRM_AltName10:SetJustifyH ( "CENTER" );
    GRM_AltName10:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName11:SetPoint ( "TOPLEFT" , GRM_CoreAltFrame , 1 , -105 );
    GRM_AltName11:SetWidth ( 60 );
    GRM_AltName11:SetJustifyH ( "CENTER" );
    GRM_AltName11:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GRM_AltName12:SetPoint ( "TOPRIGHT" , GRM_CoreAltFrame , 0 , -105 );
    GRM_AltName12:SetWidth ( 60 );
    GRM_AltName12:SetJustifyH ( "CENTER" );
    GRM_AltName12:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    -- ALT DROPDOWN OPTIONS
    GRM_altDropDownOptions:SetPoint ( "BOTTOMRIGHT" , GRM_MemberDetailMetaData , 15 , 0 );
    GRM_altDropDownOptions:SetBackdrop ( noteBackdrop2 );
    GRM_altDropDownOptions:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_altOptionsText:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -13 );
    GRM_altOptionsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_altOptionsText:SetText ( "Options" );
    GRM_altSetMainButton:SetPoint ("TOPLEFT" , GRM_altDropDownOptions , 7 , -22 );
    GRM_altSetMainButton:SetSize ( 60 , 20 );
    GRM_altSetMainButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_altSetMainButtonText:SetPoint ( "LEFT" , GRM_altSetMainButton );
    GRM_altSetMainButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_altRemoveButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -36 );
    GRM_altRemoveButton:SetSize ( 60 , 20 );
    GRM_altRemoveButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_altRemoveButtonText:SetPoint ( "LEFT" , GRM_altRemoveButton );
    GRM_altRemoveButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_altRemoveButtonText:SetText( "Remove" );
    GRM_altOptionsDividerText:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -55 );
    GRM_altOptionsDividerText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_altOptionsDividerText:SetText ("__");
    GRM_altFrameCancelButton:SetPoint ( "TOPLEFT" , GRM_altDropDownOptions , 7 , -65 );
    GRM_altFrameCancelButton:SetSize ( 60 , 20 );
    GRM_altFrameCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_altFrameCancelButtonText:SetPoint ( "LEFT" , GRM_altFrameCancelButton );
    GRM_altFrameCancelButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_altFrameCancelButtonText:SetText ( "Cancel" );

end

-- Method:                  GR_MetaDataInitializeUIThird()
-- What it Does:            Initializes "More of the frames values/scripts"
-- Purpose:                 Can only have 60 "up-values" in one function. This splits it up.
GRM.GR_MetaDataInitializeUIThird = function()

    --ADD ALT FRAME
    GRM_AddAltEditFrame:SetPoint ( "BOTTOMLEFT" , GRM_MemberDetailMetaData , "BOTTOMRIGHT" ,  -7 , 0 );
    GRM_AddAltEditFrame:SetSize ( 130 + ( #GRM_AddonGlobals.realmName * 3.5 ) , 170 );                -- Slightly wider for larger guild names.
    GRM_AddAltEditFrame:SetToplevel ( true );
    GRM_AddAltTitleText:SetPoint ( "TOP" , GRM_AddAltEditFrame , 0 , - 20 );
    GRM_AddAltTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11 , "THICKOUTLINE" );
    GRM_AddAltTitleText:SetText ( "Choose Alt" );
    GRM_AddAltNameButton1:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -54 );
    GRM_AddAltNameButton1:SetSize ( 100 , 15 );
    GRM_AddAltNameButton1:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton1:Disable();
    GRM_AddAltNameButton1Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltNameButton1Text:SetPoint ( "LEFT" , GRM_AddAltNameButton1 );
    GRM_AddAltNameButton1Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton2:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -69 );
    GRM_AddAltNameButton2:SetSize ( 100 , 15 );
    GRM_AddAltNameButton2:Disable();
    GRM_AddAltNameButton2:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton2Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltNameButton2Text:SetPoint ( "LEFT" , GRM_AddAltNameButton2 );
    GRM_AddAltNameButton2Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton3:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -84 );
    GRM_AddAltNameButton3:SetSize ( 100 , 15 );
    GRM_AddAltNameButton3:Disable();
    GRM_AddAltNameButton3:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton3Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltNameButton3Text:SetPoint ( "LEFT" , GRM_AddAltNameButton3 );
    GRM_AddAltNameButton3Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton4:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -99 );
    GRM_AddAltNameButton4:SetSize ( 100 , 15 );
    GRM_AddAltNameButton4:Disable();
    GRM_AddAltNameButton4:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton4Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltNameButton4Text:SetPoint ( "LEFT" , GRM_AddAltNameButton4 );
    GRM_AddAltNameButton4Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton5:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -114 );
    GRM_AddAltNameButton5:SetSize ( 100 , 15 );
    GRM_AddAltNameButton5:Disable();
    GRM_AddAltNameButton5:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton5Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltNameButton5Text:SetPoint ( "LEFT" , GRM_AddAltNameButton5 );
    GRM_AddAltNameButton5Text:SetJustifyH ( "LEFT" );
    GRM_AddAltNameButton6:SetPoint ( "TOP" , GRM_AddAltEditFrame , 7 , -129 );
    GRM_AddAltNameButton6:SetSize ( 100 , 15 );
    GRM_AddAltNameButton6:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    GRM_AddAltNameButton6:Disable();
    GRM_AddAltNameButton6Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltNameButton6Text:SetPoint ( "LEFT" , GRM_AddAltNameButton6 );
    GRM_AddAltNameButton6Text:SetJustifyH ( "LEFT" );
    GRM_AddAltEditFrameTextBottom:SetPoint ( "TOP" , GRM_AddAltEditFrame , -18 , -146 );
    GRM_AddAltEditFrameTextBottom:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltEditFrameTextBottom:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    GRM_AddAltEditFrameTextBottom:SetText ( "(Press Tab)" );
    GRM_AddAltEditFrameHelpText:SetPoint ( "CENTER" , GRM_AddAltEditFrame );
    GRM_AddAltEditFrameHelpText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltEditFrameHelpText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_AddAltEditFrameHelpText2:SetPoint ( "BOTTOM" , GRM_AddAltEditFrame , 0 , 30 );
    GRM_AddAltEditFrameHelpText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltEditFrameHelpText2:SetText ( "Shift-Click Name\nIn Roster Also Works");
        
    GRM_AddAltEditBox:SetPoint( "TOP" , GRM_AddAltEditFrame , 2.5 , -30 );
    GRM_AddAltEditBox:SetSize ( 95 + ( #GRM_AddonGlobals.realmName * 3.5 ) , 25 );
    GRM_AddAltEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    GRM_AddAltEditBox:SetMaxLetters ( 40 );
    GRM_AddAltEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddAltEditBox:EnableMouse( true );
    GRM_AddAltEditBox:SetAutoFocus( false );

    -- ALT EDIT BOX LOGIC
    GRM_AddAltButton:SetScript ( "OnClick" , function ( _ , button) 
        if button == "LeftButton" then

            -- Let's see if player is at hard cap first!
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
                if GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
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
                if GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
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
                if GRM.SlimName ( GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) ) == GRM_AddAltEditBox:GetText() or GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == GRM_AddAltEditBox:GetText() then
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
                        GRM.AddAlt ( GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) , GRM_AddAltEditBox:GetText() , GRM_AddonGlobals.guildName , false , 0 );

                        -- Communicate the changes!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                            GRMsync.SendMessage ( "GRM_ADDALT" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) .. "?" .. GRM_AddAltEditBox:GetText() .. "?" .. tostring ( time() ) , "GUILD");
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
                        GRMsync.SendMessage ( "GRM_MAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                    end
                else
                    -- No need to set as main yet... let's set player to main here.
                      for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altDetails[1] then
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                                GRM.SetMain ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , altDetails[1] , altDetails[3] , false , 0 );
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_MAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] .. "?" .. altDetails[1] , "GUILD");
                                end
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = true;
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = time();
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_MAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                                end
                            end
                            -- Now send Comm to sync details.
                            
                            GRM_MemberDetailMainText:Show();
                            break;
                        end
                    end
                end
                if GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) ~= altDetails[2] then
                    GRM_MemberDetailMainText:Hide();
                end

                

                GRM.Report ( GRM.SlimName ( altDetails[2] ) .. " is now set as \"main\"" );
            elseif buttonName == "Set as Alt" then
                if altDetails[1] ~= altDetails[2] then
                    GRM.DemoteFromMain ( altDetails[1] , altDetails[2] , altDetails[3] , false , 0 );
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                        GRMsync.SendMessage ( "GRM_RMVMAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");
                    end
                else
                    -- No need to set as main yet... let's set player to main here.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altDetails[1] then
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                                GRM.DemoteFromMain ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , altDetails[1] , altDetails[3] , false , 0 );
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_RMVMAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] .. "?" .. altDetails[1] , "GUILD");
                                end
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = false;
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = time();
                                GRM_AddonGlobals.pause = false;
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                                    GRMsync.SendMessage ( "GRM_RMVMAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] , "GUILD");        -- both alt details will be same name...
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
            elseif buttonName == "Notify When Player Comes Online" then
                GRM.AddPlayerOnlineStatusCheck ( altDetails[1] );
            elseif buttonName == "Notify When Player Goes Offline" then
                GRM.AddPlayerOfflineStatusCheck ( altDetails[1] );
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
                    GRMsync.SendMessage ( "GRM_RMVALT" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. altDetails[1] .. "?" .. altDetails[2] .. "?" .. tostring ( time() ) , "GUILD");
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
    GRM_AddEventFrameTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 16 );
    GRM_AddEventFrameNameTitleText:SetPoint ( "TOPLEFT" , GRM_AddEventScrollBorderFrame , 17 , 8 );
    GRM_AddEventFrameNameTitleText:SetText ( "Name:                 Event:" );
    GRM_AddEventFrameNameTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 14 );
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
    GRM_AddEventLoadFrameButtonText:SetFont( "Fonts\\FRIZQT__.TTF" , 8 );
    GRM_AddEventFrameSetAnnounceButton:SetPoint ( "LEFT" , GRM_AddEventFrame , 25 , -20 );
    GRM_AddEventFrameSetAnnounceButton:SetSize ( 60 , 50 );
    GRM_AddEventFrameSetAnnounceButtonText:SetPoint ( "CENTER" , GRM_AddEventFrameSetAnnounceButton );
    GRM_AddEventFrameSetAnnounceButtonText:SetText ( "Set\nEvent" );
    GRM_AddEventFrameSetAnnounceButtonText:SetFont( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_AddEventFrameIgnoreButton:SetPoint ( "LEFT" , GRM_AddEventFrame , 25 , -80 );
    GRM_AddEventFrameIgnoreButton:SetSize ( 60 , 50 );
    GRM_AddEventFrameIgnoreButtonText:SetPoint ( "CENTER" , GRM_AddEventFrameIgnoreButton );
    GRM_AddEventFrameIgnoreButtonText:SetText ( "Ignore" );
    GRM_AddEventFrameIgnoreButtonText :SetFont( "Fonts\\FRIZQT__.TTF" , 12 );
    -- STATUS TEXT
    GRM_AddEventFrameStatusMessageText:SetPoint ( "LEFT" , GRM_AddEventFrame , 6 , 35 );
    GRM_AddEventFrameStatusMessageText:SetJustifyH ( "CENTER" );
    GRM_AddEventFrameStatusMessageText:SetWidth ( 98 );
    GRM_AddEventFrameStatusMessageText:SetFont ( "Fonts\\FRIZQT__.TTF" , 14 );
    GRM_AddEventFrameStatusMessageText:SetText ( "Please Select\na Player" );
    GRM_AddEventFrameNameToAddText:SetPoint ( "LEFT" , GRM_AddEventFrame , 3 , 48 );
    GRM_AddEventFrameNameToAddText:SetWidth ( 105 );
    GRM_AddEventFrameNameToAddText:SetJustifyH ( "CENTER" );
    GRM_AddEventFrameNameToAddText:SetWordWrap ( true );
    GRM_AddEventFrameNameToAddText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_AddEventFrameNameToAddTitleText:SetText( "" );

    -- BUTTONS
    GRM_LoadLogButton:SetSize ( 90 , 11 );
    GRM_LoadLogButton:SetPoint ( "TOPRIGHT" , GuildRosterFrame , -114 , -16 );
    GRM_LoadLogButton:SetFrameStrata ( "HIGH" );
    GRM_LoadLogButtonText:SetPoint ( "CENTER" , GRM_LoadLogButton );
    GRM_LoadLogButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
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
                                    GRMsync.SendMessage ( "GRM_AC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , "GUILD");
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
                                else
                                    GRM_AddEventFrameStatusMessageText:SetText ( "No Events\nto Add");
                                    GRM_AddEventFrameStatusMessageText:Show();
                                    GRM_AddEventFrameNameToAddText:Hide();
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
                        else
                            GRM_AddEventFrameStatusMessageText:SetText ( "No Events\nto Add");
                            GRM_AddEventFrameStatusMessageText:Show();
                            GRM_AddEventFrameNameToAddText:Hide();
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
        GRM.ClearAllFrames();
    end);

    -- Needs to be initialized AFTER guild frame first logs or it will error, so only making it here now.
    GuildTextEditFrame.GuildMOTDcharCount = GuildTextEditFrame:CreateFontString ( "GuildMOTDcharCount" , "OVERLAY" , "GameFontNormalSmall" );
    GuildTextEditFrame.GuildMOTDcharCount:SetPoint ( "TOPRIGHT" , GuildTextEditBox , 15 , 19 )
    GuildTextEditFrame.GuildMOTDcharCount:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );

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

    -- TOOLTIP INIT
    GRM_MemberDetailRankToolTip:SetScale ( 0.85 );
    GRM_MemberDetailJoinDateToolTip:SetScale ( 0.85 );
    GRM_MemberDetailServerNameToolTip:SetScale ( 0.85 );

end

-- Method:          GRM.PreAddonLoadUI()
-- What it Does:    Initializes the core Log Frame before the addon loads
-- Purpose:         One cannot use methods like "SetUserPlaced" to carry over between sessions sunless the frame is initalized BEFORE "ADDON_LOADED" event fires.
GRM.PreAddonLoadUI = function()
    GRM_RosterChangeLogFrame:SetPoint ( "CENTER" , UIParent );
    GRM_RosterChangeLogFrame:SetFrameStrata ( "HIGH" );
    GRM_RosterChangeLogFrame:SetSize ( 600 , 440 );
    GRM_RosterChangeLogFrame:EnableMouse ( true );
    GRM_RosterChangeLogFrame:SetMovable ( true );
    GRM_RosterChangeLogFrame:SetUserPlaced ( true );
    GRM_RosterChangeLogFrame:SetToplevel ( true );
    GRM_RosterChangeLogFrame:RegisterForDrag ( "LeftButton" );
    GRM_RosterChangeLogFrame:SetScript ( "OnDragStart" , GRM_RosterChangeLogFrame.StartMoving );
    GRM_RosterChangeLogFrame:SetScript ( "OnDragStop" , GRM_RosterChangeLogFrame.StopMovingOrSizing );

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
end

-- Method           GRM.MetaDataInitializeUIrosterLog1()
-- What it Does:    Keeps the log initialization separate and part of the UIParent, so it can load upon logging in
-- Purpose:         Resource control. This loads upon login, but keeps the rest of the addon UI initialization from occuring unless as needed.
--                  In other words, this can be loaded upon logging, but the rest will only load if the guild roster window loads.
GRM.MetaDataInitializeUIrosterLog1 = function()

    -- MAIN GUILD LOG FRAME!!!
    GRM_RosterChangeLogFrameTitleText:SetPoint ( "TOP" , GRM_RosterChangeLogFrame , 0 , - 3.5 );
    GRM_RosterChangeLogFrameTitleText:SetText ( "Guild Roster Event Log" );
    GRM_RosterChangeLogFrameTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 16 );
    GRM_RosterCheckBoxSideFrame:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , "TOPRIGHT" , -3 , 5 );
    GRM_RosterCheckBoxSideFrame:SetSize ( 200 , 390 ); -- 509 is flush height
    GRM_RosterCheckBoxSideFrame:Hide();
    GRM_RosterCheckBoxSideFrame:SetAlpha ( 0.0 );
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
    GRM_RosterOptionsButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11.5 );
    GRM_RosterOptionsButtonText:SetText ( "Options" );

    GRM_RosterOptionsButton:SetScript ( "OnClick" , function ( self , button )
        if button == "LeftButton" then
            if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) >= 500 then -- Since the height is a double, returns it as an int using math.floor
                GRM_RosterOptionsButton:Disable();
                if GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:IsVisible() then
                    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
                    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
                end
                if GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:IsVisible() then
                    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
                    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
                end
                if GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:IsVisible() then
                    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
                    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
                end
                GRM.LogOptionsFadeOut();
                GRM.LogFrameTransformationClose();
            else
                GRM_RosterOptionsButton:Disable();
                GRM_RosterCheckBoxSideFrame:Show();
                GRM.LogFrameTransformationOpen();   
            end
        end
    end);

    -- Clear Log Button
    GRM_RosterClearLogButton:SetSize ( 90 , 16 );
    GRM_RosterClearLogButton:SetPoint ( "TOPRIGHT" , GRM_RosterChangeLogFrame , -30 , -3 );
    GRM_RosterClearLogButton:SetFrameStrata ( "HIGH" );
    GRM_RosterClearLogButtonText:SetPoint ( "CENTER" , GRM_RosterClearLogButton );
    GRM_RosterClearLogButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11.5 );
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

    -- Popup window to confirm!
    GRM_RosterConfirmFrame:Hide();
    GRM_RosterConfirmFrame:SetPoint ( "CENTER" , UIPanel , 0 , 200 );
    GRM_RosterConfirmFrame:SetSize ( 275 , 90 );
    GRM_RosterConfirmFrame:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    GRM_RosterConfirmFrameText:SetPoint ( "CENTER" , GRM_RosterConfirmFrame , 0 , 10 );
    GRM_RosterConfirmFrameText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterConfirmFrameText:SetWidth ( 265 );
    GRM_RosterConfirmFrameText:SetSpacing ( 1 );
    GRM_RosterConfirmFrameText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterConfirmYesButton:SetPoint ( "BOTTOMLEFT" , GRM_RosterConfirmFrame , 15 , 5 );
    GRM_RosterConfirmYesButton:SetSize ( 70 , 35 );
    GRM_RosterConfirmYesButtonText:SetPoint ( "CENTER" , GRM_RosterConfirmYesButton );
    GRM_RosterConfirmYesButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 14 );

    GRM_RosterConfirmCancelButton:SetPoint ( "BOTTOMRIGHT" , GRM_RosterConfirmFrame , -15 , 5 );
    GRM_RosterConfirmCancelButton:SetSize ( 70 , 35 );
    GRM_RosterConfirmCancelButtonText:SetPoint ( "CENTER" , GRM_RosterConfirmCancelButton );
    GRM_RosterConfirmCancelButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 14 );
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
    GRM_RosterCheckBoxSideFrame:SetScript ( "OnHide" , function ( self )
        if GRM_RosterConfirmFrameText:GetText() == "Really Clear the Guild Log?" then
            GRM_RosterConfirmFrame:Hide();
        end
    end);
    


    -- CORE OPTIONS
    GRM_RosterLoadOnLogonCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -22 );
    GRM_RosterLoadOnLogonCheckButtonText:SetPoint ( "LEFT" , GRM_RosterLoadOnLogonCheckButton , 27 , 0 );
    GRM_RosterLoadOnLogonCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterLoadOnLogonCheckButtonText:SetText ( "Show at Logon" );
    GRM_RosterLoadOnLogonCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterLoadOnLogonCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] = false;
        end
    end);
    GRM_RosterAddTimestampCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -42 );
    GRM_RosterAddTimestampCheckButtonText:SetPoint ( "LEFT" , GRM_RosterAddTimestampCheckButton , 27 , 0 );
    GRM_RosterAddTimestampCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterAddTimestampCheckButtonText:SetText ( "Add Join Date to Officer Note   " ); -- Don't ask me why, but this spacing is needed for tabs to line up right in UI. Lua lol'
    GRM_RosterAddTimestampCheckButton:SetScript ( "OnClick", function()              
        if GRM_RosterAddTimestampCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = false;
        end
    end);

    -- Kick Recommendation!
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -62 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton , 27 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetText ( "Kick Inactives Reminder at" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , 32 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetText ( "Months" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] = false;
        end
    end);
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , 1.0 , 0 )
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetSize ( 30 , 22 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetPoint ( "CENTER" , GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText , "RIGHT" , -0.5 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetSize ( 35 , 22 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetTextInsets ( 8 , 9 , 9 , 8 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetMaxLetters ( 2 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetNumeric ( true );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetFont ( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:EnableMouse ( true );

    GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            if GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:IsEnabled() then
                GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Hide();
                GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetText ( "" );
                GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Show()
            end
        end    
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
        GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEnterPressed" , function()
        local numMonths = tonumber ( GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:GetText() );
        if numMonths > 0 and numMonths < 100 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] = numMonths;
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNoteText:SetText ( numMonths );
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
        else
            print ( "Please choose a month between 1 and 99" );
        end      
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
        GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
    end)

    -- Report Inactive Recommendation.
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:SetPoint ( "TOP" , GRM_RosterChangeLogFrame , 14 , -22 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton , 27 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText:SetText ( "Report Inactive Return if Offline" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] = false;
        end
    end);
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , 0.5 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetSize ( 30 , 22 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetPoint ( "CENTER" , GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( math.floor ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] / 24 ) );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetPoint( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , -5 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetSize ( 45 , 22 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetMaxLetters ( 3 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetNumeric ( true );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:EnableMouse( true );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText , "RIGHT" , 32 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButtonText2:SetText ( "Days" );


    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:SetScript ( "OnMouseDown" , function ( self , button )
        if button == "LeftButton" then
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetText ( "" );
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Show();
        end    
    end);

    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
        GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end);

    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEnterPressed" , function()
        local numDays = tonumber ( GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:GetText() );
        if numDays > 0 and numDays < 181 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] = numDays * 24;
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNoteText:SetText ( numDays );
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
        else
            print ( "Please choose between 1 and 180 days!" );
        end      
    end);

    GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
        GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
    end)

    -- Add Event Options on Announcing...
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetPoint ( "TOP" , GRM_RosterChangeLogFrame , 14 , -42 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton , 27 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetText ( "Announce Events" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , 32 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetText ( "Days in Advance" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] = true;
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:Show();
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] = false;
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:Hide();
        end
    end);
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , 0.5 , 0 )
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetBackdrop ( noteBackdrop2 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetFrameStrata ( "HIGH" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetSize ( 30 , 22 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetPoint ( "CENTER" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) ;
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetPoint( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText , "RIGHT" , -0.5 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetSize ( 35 , 22 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetMaxLetters ( 2 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetNumeric ( true );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 10 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:EnableMouse( true );

    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:SetScript ( "OnMouseDown" , function( self , button )
        if button == "LeftButton" then
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetText ( "" );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Show();
        end    
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEscapePressed" , function()
        GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
        GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEnterPressed" , function()
        local numDays = tonumber ( GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:GetText() );
        if numDays > 0 and numDays < 29 then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] = numDays;
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNoteText:SetText ( numDays );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
        else
            print ( "Please choose between 1 and 28 days!" );
        end      
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:SetScript ( "OnEditFocusLost" , function() 
        GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
        GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
    end)


    -- Add Event Options Button to add events to calendar
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:SetPoint ( "TOP" , GRM_RosterChangeLogFrame , 14 , -62 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton , 27 , 0 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButtonText:SetText ( "Add Events to Calendar" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] = false;
        end
    end);

    -- SYNC WITH OTHER PLAYERS!
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -82 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton , 27 , 0)
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText:SetText ( "SYNC Changes With Guildies at Rank " );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton , "RIGHT" , 1.5 , 0)
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText2:SetText ( "or Higher" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = true;
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Show();
            GRM.LogFrameTransformationOpen();
            GRMsync.Initialize();
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = false;
            GRM.LogFrameTransformationCloseMinor();
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Hide();
            GRMsync.MessageTracking:UnregisterAllEvents();
            GRMsync.ResetDefaultValuesOnSyncReEnable();         -- Reset values to default, so that it resyncs if player re-enables.
        end
    end);

    -- GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:GetChecked()
    GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterChangeLogFrame , 14 , -102 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton , 27 , 0)
    GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButtonText:SetText ( "Display SYNC Update Messages" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] = false;
        end
    end);

    -- Rank Drop Down for Options Frame
        -- rank drop down 
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButtonText , "RIGHT" , 1.0 , 1.5 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:SetSize (  130 , 18 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetPoint ( "CENTER" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetWidth ( 130 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetPoint ( "TOP" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "BOTTOM" );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetWidth ( 130 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetFrameStrata ( "HIGH" );

    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton:SetPoint ( "LEFT" , GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected , "RIGHT" , -1 , -0.5 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenuButton:SetSize ( 20 , 17 );

    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetPropagateKeyboardInput ( false );
            GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:Show();
        end
    end);

    GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:SetScript ( "OnShow" , function() 
        GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
    end)
end


-- Method           GRM.MetaDataInitializeUIrosterLog2()
-- What it Does:    Keeps the log initialization separate and part of the UIParent, so it can load upon logging in
-- Purpose:         Resource control. This loads upon login, but keeps the rest of the addon UI initialization from occuring unless as needed.
--                  In other words, this can be loaded upon logging, but the rest will only load if the guild roster window loads.
GRM.MetaDataInitializeUIrosterLog2 = function()
    -- CHECKBUTTONS for Logging Details
    GRM_RosterJoinedCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -45 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -45 );
    GRM_RosterJoinedCheckButtonText:SetPoint ( "LEFT" , GRM_RosterJoinedCheckButton , 27 , 0 );
    GRM_RosterJoinedCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] = false;
        end
    end);

    GRM_RosterLeveledChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -70 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -70 );
    GRM_RosterLeveledChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterLeveledChangeCheckButton , 27 , 0 );
    GRM_RosterLeveledChangeCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] = false;
        end
    end);


    GRM_RosterInactiveReturnCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -95 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -95 );
    GRM_RosterInactiveReturnCheckButtonText:SetPoint ( "LEFT" , GRM_RosterInactiveReturnCheckButton , 27 , 0 );
    GRM_RosterInactiveReturnCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] = false;
        end
    end);

    GRM_RosterPromotionChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -120 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -120 );
    GRM_RosterPromotionChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterPromotionChangeCheckButton , 27 , 0 );
    GRM_RosterPromotionChangeCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] = false;
        end
    end);

    GRM_RosterDemotionChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -145 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -145 );
    GRM_RosterDemotionChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterDemotionChangeCheckButton , 27 , 0 );
    GRM_RosterDemotionChangeCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] = false;
        end
    end);

    GRM_RosterNoteChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -170 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -170 );
    GRM_RosterNoteChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterNoteChangeCheckButton , 27 , 0 );
    GRM_RosterNoteChangeCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] = false;
        end
    end);

    GRM_RosterOfficerNoteChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -195 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -195 );
    GRM_RosterOfficerNoteChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterOfficerNoteChangeCheckButton , 27 , 0 );
    GRM_RosterOfficerNoteChangeCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] = false;
        end
    end);

    GRM_RosterNameChangeCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -220 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -220 );
    GRM_RosterNameChangeCheckButtonText:SetPoint ( "LEFT" , GRM_RosterNameChangeCheckButton , 27 , 0 );
    GRM_RosterNameChangeCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] = false;
        end
    end);

    GRM_RosterRankRenameCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -245 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -245 );
    GRM_RosterRankRenameCheckButtonText:SetPoint ( "LEFT" , GRM_RosterRankRenameCheckButton , 27 , 0 );
    GRM_RosterRankRenameCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] = false;
        end
    end);

    GRM_RosterEventCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -270 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -270 );
    GRM_RosterEventCheckButtonText:SetPoint ( "LEFT" , GRM_RosterEventCheckButton , 27 , 0 );
    GRM_RosterEventCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] = false;
        end
    end);
     
    GRM_RosterLeftGuildCheckButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -295 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -295 );
    GRM_RosterLeftGuildCheckButtonText:SetPoint ( "LEFT" , GRM_RosterLeftGuildCheckButton , 27 , 0 );
    GRM_RosterLeftGuildCheckButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] = false;
        end
    end);

    GRM_RosterRecommendationsButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -320 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -320 );
    GRM_RosterRecommendationsButtonText:SetPoint ( "LEFT" , GRM_RosterRecommendationsButton , 27 , 0 );
    GRM_RosterRecommendationsButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:GetChecked() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] = true;
        else
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] = false;
        end
    end);

    GRM_RosterBannedPlayersButton:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -345 );
    GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -345 );
    GRM_RosterBannedPlayersButtonText:SetPoint ( "LEFT" , GRM_RosterBannedPlayersButton , 27 , 0 );
    GRM_RosterBannedPlayersButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
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
    GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetScript ( "OnClick", function()
        if GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:GetChecked() then
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

    GRM_RosterCheckBoxSideFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        GRM_RosterCheckBoxSideFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" and not GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:HasFocus() then
            GRM_RosterCheckBoxSideFrame:SetPropagateKeyboardInput ( false );
            GRM_RosterOptionsButton:Click();
        end
    end);

    GRM_RosterChangeLogFrame:SetScript ( "OnShow" , function () 
        -- Button Positions
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][1] then
            GRM_RosterJoinedCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterJoinedChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][2] then
            GRM_RosterLeveledChangeCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterLeveledChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][3] then
            GRM_RosterInactiveReturnCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterInactiveReturnChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][4] then
            GRM_RosterPromotionChangeCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterPromotionChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][5] then
            GRM_RosterDemotionChangeCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterDemotionChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][6] then
            GRM_RosterNoteChangeCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterNoteChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][7] then
            GRM_RosterOfficerNoteChangeCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterOfficerNoteChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][8] then
            GRM_RosterNameChangeCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterNameChangeChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][9] then
            GRM_RosterRankRenameCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterRankRenameChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][10] then
            GRM_RosterEventCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterEventChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][11] then
            GRM_RosterLeftGuildCheckButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterLeftGuildChatCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][12] then
            GRM_RosterRecommendationsButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendationsChatButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][3][13] then
            GRM_RosterBannedPlayersButton:SetChecked( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][13] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterBannedPlayersButtonChatButton:SetChecked ( true );
        end
        
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then                                         -- Show at Logon Button
            GRM_RosterLoadOnLogonCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] then                                         -- Add Timestamp to Officer on Join Button
            GRM_RosterAddTimestampCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportAddEventsToCalendarButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportInactiveReturnButton:SetChecked ( true );
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetChecked ( true );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:Show();
        else
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:Hide();
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:SetChecked ( true );
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Show();
        else
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Hide();
        end
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:SetChecked ( true );
        end


        -- Display Information
        if GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:IsVisible() then
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickOverlayNote:Show();
        end
        if GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:IsVisible() then
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnEditBox:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_ReportInactiveReturnOverlayNote:Show();
        end
        if GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:IsVisible() then
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsEditBox:Hide();
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsOverlayNote:Show();
        end
        if GRM_RosterCheckBoxSideFrame.GRM_RosterSyncCheckButton:GetChecked() then
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Show();
        else
            GRM_RosterCheckBoxSideFrame.GRM_RosterNotifyOnChangesCheckButton:Hide();
        end
        -- Permissions... if not, disable button.
        if CanEditOfficerNote() then
            GRM_RosterAddTimestampCheckButton:Enable();
            GRM_RosterAddTimestampCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
        else
            GRM_RosterAddTimestampCheckButton:SetChecked ( false );
            GRM_RosterAddTimestampCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
            GRM_RosterAddTimestampCheckButton:Disable();
        end
        if CanEditGuildEvent() then
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:Enable();
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
        else
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButtonText2:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:SetChecked ( false );
            GRM_RosterCheckBoxSideFrame.GRM_RosterReportUpcomingEventsCheckButton:Disable();
        end
        if CanGuildRemove() then
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:Enable();
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Enable();
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetTextColor( 1.0 , 0.82 , 0.0 , 1.0 );
        else
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButtonText2:SetTextColor( 0.5, 0.5, 0.5 , 1.0 );
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:SetChecked ( false );
            GRM_RosterCheckBoxSideFrame.GRM_RosterRecommendKickCheckButton:Disable();
            GRM_RosterCheckBoxSideFrame.GRM_RosterKickRecommendEditBox:Disable();
        end

        -- Get that Dropdown Menu Populated!
        GRM.CreateOptionsRankDropDown();
        -- Ok rebuild the log after changes!
        GRM.BuildLog();
    end);

    GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetPoint ( "TOP" , GRM_RosterCheckBoxSideFrame , 0 , -12 );
    GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetText ( "Display Changes" );
    GRM_RosterCheckBoxSideFrame.GRM_TitleSideFrameText:SetFont ( "Fonts\\FRIZQT__.TTF" , 12 );
    GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText:SetPoint ( "TOPRIGHT" , GRM_RosterCheckBoxSideFrame , -14 , -28 );
    GRM_RosterCheckBoxSideFrame.GRM_ShowOnChatSideFrameText:SetText ( "To Chat:" );
    GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText:SetPoint ( "TOPLEFT" , GRM_RosterCheckBoxSideFrame , 14 , -28 );
    GRM_RosterCheckBoxSideFrame.GRM_ShowOnLogSideFrameText:SetText ( "To Log:" );


end

-- Method:          GRM.AllRemainingNonDelayFrameInitialization()
-- What it Does:    Initializes general important frames that are not in relations to the guild roster window.
-- Purpose:         By walling this off, it allows far greater resource control rather than needing to initialize entire UI.
GRM.AllRemainingNonDelayFrameInitialization = function()
    
    UI_Events.GRM_NumGuildiesText:SetPoint ( "TOP" , RaidFrame , 0 , -32 );
    UI_Events.GRM_NumGuildiesText:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    UI_Events.GRM_NumGuildiesText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    UI_Events:SetFrameStrata ( "HIGH" );

    UI_Events:RegisterEvent ( "UPDATE_INSTANCE_INFO" );
    UI_Events:RegisterEvent ( "GROUP_ROSTER_UPDATE" );   
    -- UI_Events:RegisterEvent ( "UPDATE_INSTANCE_INFO" );
    UI_Events:HookScript ( "OnEvent" , function( self , event )
        if ( event == "UPDATE_INSTANCE_INFO" or event == "GROUP_ROSTER_UPDATE" ) and not GRM_AddonGlobals.RaidGCountBeingChecked then
            GRM_AddonGlobals.RaidGCountBeingChecked = true;
            GRM.UpdateGuildMemberInRaidStatus();
        end
    end);

    RaidFrame:HookScript ( "OnHide" , function()
        UI_Events.GRM_NumGuildiesText:Hide();
    end);

end

-- Method:              GRM.GR_Roster_Click ( self, string )
-- What it Does:        For logic on mouseover, instead of mouseover, it simulates a click on the item by bringing it to show.
--                      The "pause" is just a call to pause the hiding of the frame in the GR_RosterFrame() function until it finds a new window (to prevent wasteful clicking and resource hogging)
-- Purpose:             Smoother UI interface in the built-in Guild Roster in-game UI default window.
GRM.GR_Roster_Click = function ( self , button )

    if button == "LeftButton" then
        GuildMemberDetailFrame:Hide();
        local time = GetTime();
        local length = 84;
        if GRM_AddonGlobals.timer3 == 0 or time - GRM_AddonGlobals.timer3 > 0.1 then   -- 100ms
            -- We are going to be copying the name if the shift key is down!
            local name = GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() );

            if IsShiftKeyDown() and GetCurrentKeyBoardFocus() ~= nil and not GRM_AddonGlobals.RecursiveStop then

                if GetCurrentKeyBoardFocus():GetName() ~= nil then
                    if "GRM_AddAltEditBox" == GetCurrentKeyBoardFocus():GetName() then
                        GetCurrentKeyBoardFocus():SetText ( name );
                    else
                        GetCurrentKeyBoardFocus():SetText ( name );  
                    end
                end

                -- Now, let's reset it back to position
                GRM_AddonGlobals.RecursiveStop = true;
                -- Visual representation of guildies is critical to get back to proper spot!
                if GRM_AddonGlobals.ShowOfflineChecked then
                    GuildRosterShowOfflineButton:SetChecked( true );
                    SetGuildRosterShowOffline ( true );
                else
                    GuildRosterShowOfflineButton:SetChecked ( false );
                    SetGuildRosterShowOffline ( false );
                end
                -- Next, position the slider in the right place!
                GuildRosterContainerScrollBar:SetValue ( GRM_AddonGlobals.ScrollPosition );

                -- Now, let's re-click the right position!
                if GRM_AddonGlobals.position == 1 then
                    GuildRosterContainerButton1:Click();
                elseif GRM_AddonGlobals.position == 2 then
                    GuildRosterContainerButton2:Click();
                elseif GRM_AddonGlobals.position == 3 then
                    GuildRosterContainerButton3:Click();
                elseif GRM_AddonGlobals.position == 4 then
                    GuildRosterContainerButton4:Click();
                elseif GRM_AddonGlobals.position == 5 then
                    GuildRosterContainerButton5:Click();
                elseif GRM_AddonGlobals.position == 6 then
                    GuildRosterContainerButton6:Click();
                elseif GRM_AddonGlobals.position == 7 then
                    GuildRosterContainerButton7:Click();
                elseif GRM_AddonGlobals.position == 8 then
                    GuildRosterContainerButton8:Click();
                elseif GRM_AddonGlobals.position == 9 then
                    GuildRosterContainerButton9:Click();
                elseif GRM_AddonGlobals.position == 10 then
                    GuildRosterContainerButton10:Click();
                elseif GRM_AddonGlobals.position == 11 then
                    GuildRosterContainerButton11:Click();
                elseif GRM_AddonGlobals.position == 12 then
                    GuildRosterContainerButton12:Click();
                elseif GRM_AddonGlobals.position == 13 then
                    GuildRosterContainerButton13:Click();
                elseif GRM_AddonGlobals.position == 14 then
                    GuildRosterContainerButton14:Click();
                end

                -- For my own custom frames, update the alt window on this condition.

                if GetCurrentKeyBoardFocus() == nil then

                    local errorMessagesGRM = { "Add-Alt Interface Trouble Loading... Try again!" , "Interface error, try shift-clicking Again Please!" , "Huh? Odd interface error... Try again!" , "Ya... Interface error on shift-click. No biggie, try again!" , "Interface might be loading data on back end... try again on shift-click!" };
                    print ( errorMessagesGRM [ math.random ( #errorMessagesGRM ) ] );
                else
                if GetCurrentKeyBoardFocus():GetName() ~= nil and GetCurrentKeyBoardFocus():GetName() == "GRM_AddAltEditBox" then
                    GRM.AddAltAutoComplete();
                    GRM_AddonGlobals.pause = true
                end

                end

            else
                if ( not GRM_AddonGlobals.pause and GRM.SlimName ( name ) == GRM_MemberDetailNameText:GetText() ) or ( GRM_AddonGlobals.pause and GRM.SlimName ( name ) ~= GRM_MemberDetailNameText:GetText() ) then
                    GRM_AddonGlobals.pause = false;
                    GR_RosterFrame ( _ , 0.075 );           -- Activate one time.
                    GRM_AddonGlobals.pause = true;
                end
            end
            GRM_AddonGlobals.timer3 = time;
        end
    end
    GRM_AddonGlobals.RecursiveStop = false;
    -- C_Timer.After ( 2 , function()
        
    -- end);
end

-- SLASH COMMAND LOGIC
SlashCmdList["GRM"] = function ( input )
    -- if input is invalid or is just a blank info... print details on addon.
    if input == nil or input:trim() == "" then    
        if IsInGuild() and GRM_RosterChangeLogFrame ~= nil and not GRM_RosterChangeLogFrame:IsVisible() then
            GRM_RosterChangeLogFrame:Show();
        elseif GRM_RosterChangeLogFrame ~= nil and GRM_RosterChangeLogFrame:IsVisible() then
            GRM_RosterChangeLogFrame:Hide();
        elseif not IsInGuild() then
            print ( GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. " is not currently in a guild. No log to view!" );
        elseif GRM_RosterChangeLogFrame == nil then
            print ( "Please try again momentarily... Updating the Guild Event Log as we speak!" );
        end
    -- Clears all saved data and resets to as if the addon was just installed. The only thing not reset is the default settings.
    elseif string.lower ( input ) == "clearall" then 
        GRM.ResetAllSavedData();
   
    -- List of all the slash commands at player's disposal.
    elseif string.lower ( input ) == "help" then
        print ( "\nGuild Roster Manager\nVer: " .. Version .. "\n\n/roster                     - Opens Guild Log Window\n/roster clearall        - Resets ALL saved data, like it was just installed.\n/roster reset            - Re-centers the Log window to the middle of the screen" );
    
    -- Resets the poisition of the window back to the center.
    elseif string.lower ( input ) == "reset" then
        GRM_RosterChangeLogFrame:ClearAllPoints();
        GRM_RosterChangeLogFrame:SetPoint ( "CENTER" , UIParent );
        GRM_AddEventFrame:ClearAllPoints();
        GRM_AddEventFrame:SetPoint ( "CENTER" , UIParent );
    
    -- FOR FUN!!!
    elseif string.lower ( input ) == "hail" then
        print ( "SUBATOMIC PVP IS THE BEST GUILD OF ALL TIME!\nArkaan is SEXY! Mmmm Arkaan!" );
    -- Invalid slash command.
    else
        print ( "Invalid Command: Please type '/roster help' for More Info!" );
    end
end


-- Method:              GRM.InitiateMemberDetailFrame(self,event,msg)
-- What it Does:        Event Listener, it activates when the Guild Roster window is opened and interface is queried/triggered
--                      "GuildRoster()" needs to fire for this to activate as it creates the following 4 listeners this is looking for: GUILD_NEWS_UPDATE, GUILD_RANKS_UPDATE, GUILD_ROSTER_UPDATE, and GUILD_TRADESKILL_UPDATE
-- Purpose:             Create an Event Listener for the Guild Roster Frame in the guild window ('J' key)
GRM.InitiateMemberDetailFrame = function ()
    if not GRM_AddonGlobals.FramesInitialized and GuildFrame ~= nil then
        -- Member Detail Frame Info
        GRM.GR_MetaDataInitializeUIFirst(); -- Initializing Frames
        GRM.GR_MetaDataInitializeUISecond(); -- To avoid 60 upvalue Lua cap, place them in second list.
        GRM.GR_MetaDataInitializeUIThird(); -- Also, to avoid another 60 upvalues!
        if not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then
            GRM.MetaDataInitializeUIrosterLog1();   -- 60 more upvalues :D
            GRM.MetaDataInitializeUIrosterLog2();   -- Wrapping up!
        end

        -- Roster Positions
        GuildRosterFrame:HookScript ( "OnUpdate" , GR_RosterFrame );
        
        -- For mouseover logic on all these buttons... using /click since there is not "OnMouseover" setscript function... on update (each frame) > if Mouseover > Click
        
        GuildRosterContainerButton1:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton2:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton3:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton4:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton5:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton6:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton7:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton8:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton9:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton10:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton11:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton12:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton13:HookScript ( "OnClick" , GRM.GR_Roster_Click );
        GuildRosterContainerButton14:HookScript ( "OnClick" , GRM.GR_Roster_Click );

        -- One time button placement ( rest will be determined on the OnUpdate for Roster Frame )
        
        GuildRosterFrame:HookScript ( "OnShow" , function( self )
            GRM_LoadLogButton:Show();
        end);
         
        -- Exit loop
        UI_Events:UnregisterEvent ( "GUILD_ROSTER_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_RANKS_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_NEWS_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_TRADESKILL_UPDATE" );
        UI_Events:UnregisterEvent ( "UPDATE_INSTANCE_INFO" );
        GRM_AddonGlobals.FramesInitialized = true;
    end
end



------------------------------------------------
------------------------------------------------
----- INITIALIZATION AND LIVE TRACKING ---------
------------------------------------------------
------------------------------------------------

-- Method:          GRM.TriggerTrackingCheck()
-- What it Does:    Helps regulate some resource and timed efficient server queries, 
-- Purpose:         to keep from spamming or double+ looping functions.
GRM.TriggerTrackingCheck = function()
    GRM_AddonGlobals.trackingTriggered = false;
    QueryGuildEventLog();
    GuildRoster();
end

-- Method:          Tracking()
-- What it Does:    Checks the Roster once in a repeating time interval as long as player is in a guild
-- Purpose:         Constant checking for roster changes. Flexibility in timing changes. Default set to 10 now, could be 30 or 60.
--                  Keeping local
local function Tracking()
    if IsInGuild() and not GRM_AddonGlobals.trackingTriggered then
        GRM_AddonGlobals.trackingTriggered = true;
        local timeCallJustOnce = time();
        if GRM_AddonGlobals.timeDelayValue == 0 or (timeCallJustOnce - GRM_AddonGlobals.timeDelayValue ) > 5 then -- Initial scan is zero.
            GRM_AddonGlobals.currentlyTracking = true;
            GRM_AddonGlobals.guildName = GetGuildInfo ( "PLAYER" );
            GRM_AddonGlobals.timeDelayValue = timeCallJustOnce;

            -- Need to doublecheck Faction Index ID
            if GRM_AddonGlobals.faction == 0 then
                if GRM_AddonGlobals.faction == "Horde" then
                    GRM_AddonGlobals.FID = 1;
                elseif GRM_AddonGlobals.faction == "Alliance" then
                    GRM_AddonGlobals.FID = 2;
                end
            end

            -- Need to doublecheck guild Index ID
            if GRM_AddonGlobals.logGID == 0 then
                for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                    if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.logGID = i;
                        break;
                    end
                end
            end

            -- Need to do the same for save index ID
            if GRM_AddonGlobals.saveGID == 0 then
                for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID] do
                    if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.saveGID = i;
                        break;
                    end
                end
            end

            -- for Settings
            if GRM_AddonGlobals.setPID == 0 then
                for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                        GRM_AddonGlobals.setPID = i;
                        break;
                    end
                end
            end

            -- Checking Roster, tracking changes
            GRM.BuildNewRoster();

            -- Need to check if guild was established!
            local guildNotFound = true;
            for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
                if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
                    guildNotFound = false;
                    break;
                end
            end

            if not guildNotFound then
                -- if GRM_AddonGlobals.logGID ~= 0 and GRM_AddonGlobals.saveGID ~= 0 and 
                -- Seeing if any upcoming notable events, like anniversaries/birthdays
                GRM.CheckPlayerEvents( GRM_AddonGlobals.guildName );
                -- Printing Report, and sending report to log.
                GRM.FinalReport();

                -- Do a quick check on if players requesting to join the guild as well!
                GRM.ReportGuildJoinApplicants();

                -- Prevent from re-scanning changes
                -- On first load, bring up window.
                if GRM_AddonGlobals.OnFirstLoad then
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then
                        GRM.MetaDataInitializeUIrosterLog1();
                        GRM.MetaDataInitializeUIrosterLog2();
                        GRM_RosterChangeLogFrame:Show();
                    end
                    
                    -- Let's quickly refresh the AddEventToCalendar Que, in case others have already added events to the calendar! Only need to check once as once online it live-syncs with other players after first retroactive sync.
                    GRM.CalendarQueCheck();

                    -- Establish Message Sharing as well!
                    GRMsyncGlobals.SyncOK = true;
                    C_Timer.After ( 10 , GRMsync.Initialize ); -- It needs to be minimum 10 seconds as it might take that long to process all changes and add player to database.

                    GRM_AddonGlobals.OnFirstLoad = false;
                    -- MISC frames to be loaded immediately, not on delay
                    GRM.AllRemainingNonDelayFrameInitialization();
                end
            end
        end
        GRM_AddonGlobals.currentlyTracking = false;
        GuildRoster();
        C_Timer.After( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] , GRM.TriggerTrackingCheck ); -- Recursive check every X seconds.
    else
        GRM_AddonGlobals.currentlyTracking = false;
    end
end

-- Method:          GRM.GR_LoadAddon()
-- What it Does:    Enables tracking of when a player joins the guild or leaves the guild. Also fires upon login.
-- Purpose:         Manage tracking guild info. No need if player is not in guild, or to reactivate when player joins guild.
GRM.GR_LoadAddon = function()
    GeneralEventTracking:RegisterEvent ( "PLAYER_GUILD_UPDATE" ); -- If player leaves or joins a guild, this should fire.
    GeneralEventTracking:SetScript ( "OnEvent" , GRM.ManageGuildStatus );

    -- Quick Version Check
    if not GRM_AddonGlobals.VersionCheckRegistered then
        GRM.RegisterVersionCheck();
        SendAddonMessage ( "GRMVER" , Version.. "?" .. tostring ( PatchDay ) , "GUILD" );
        GRM_AddonGlobals.VersionCheckRegistered = true;
    end

    -- The following event registartion is purely for UI registeration and activation... General tracking does not need the UI, but guildFrame should be visible bnefore triggering
    -- Each of the following events might trigger on event update.
    UI_Events:RegisterEvent ( "GUILD_ROSTER_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_RANKS_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_NEWS_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_TRADESKILL_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_EVENT_LOG_UPDATE" );
    UI_Events:SetScript ( "OnEvent" , function ( self , event )
        if event == "GUILD_EVENT_LOG_UPDATE" then
            Tracking();
        elseif event ~= "UPDATE_INSTANCE_INFO" then
            if not GRM_AddonGlobals.FramesInitialized  then
                GRM.InitiateMemberDetailFrame();
            else
                UI_Events:UnregisterEvent ( "GUILD_ROSTER_UPDATE" );
                UI_Events:UnregisterEvent ( "GUILD_RANKS_UPDATE" );
                UI_Events:UnregisterEvent ( "GUILD_NEWS_UPDATE" );
                UI_Events:UnregisterEvent ( "GUILD_TRADESKILL_UPDATE" );
                UI_Events:UnregisterEvent ( "UPDATE_INSTANCE_INFO" );
            end
        end
    end);
    QueryGuildEventLog();
    GuildRoster();
end

-- Method:          GRM.ReactivateAddon ()
-- What it Does:    If addon no longer needs to be enabled due to player not being in a guild, or leaving a guild, this slimmer reactivation protocol
--                  is necessary because it doesn't need to re-register frames like it would on the first activation upon logging in.
-- Purpose:         Resource efficiency.
GRM.ReactivateAddon = function()
     if GRM_AddonGlobals.faction == nil then
        GRM_AddonGlobals.faction = UnitFactionGroup ( "PLAYER" );
    end

    if GRM_AddonGlobals.faction == "Horde" then
        GRM_AddonGlobals.FID = 1;
    else
        GRM_AddonGlobals.FID = 2;
    end

    -- Must get PID immediately after.
    if GRM_AddonGlobals.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                GRM_AddonGlobals.setPID = i;
                break;
            end
        end
    end

    for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
        if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GetGuildInfo ( "PLAYER" ) then
            GRM_AddonGlobals.logGID = i;
            break;
        end
    end

    C_Timer.After ( 2 , GRM.GR_LoadAddon );

    -- GRM.InitiateMemberDetailFrame();
end

-- Method           GRM.ManageGuildStatus()
-- What it Does:    If player leaves or joins the guild, it deactivates/reactivates tracking - as well as re-checks guild to see if rejoining or new guild.    
-- Purpose:         Efficiency in resource use to prevent unnecessary tracking of info if out of the guild.
GRM.ManageGuildStatus = function ( self , event )
    GeneralEventTracking:UnregisterEvent ( "PLAYER_GUILD_UPDATE" );
    if GRM_AddonGlobals.guildStatusChecked ~= true then
       GRM_AddonGlobals.timeDelayValue2 = time(); -- Prevents it from doing "IsInGuild()" too soon by resetting timer as server reaction is slow.
    end
    if GRM_AddonGlobals.timeDelayValue2 == 0 or ( time() - GRM_AddonGlobals.timeDelayValue2 ) >= 2 then -- Let's do a recheck on guild status to prevent unnecessary scanning.
        if IsInGuild() then
            if GRM_AddonGlobals.DelayedAtLeastOnce then
                GRM_AddonGlobals.guildName = GetGuildInfo ( "PLAYER" );
                if not GRM_AddonGlobals.currentlyTracking then                 
                    GRM.ReactivateAddon();
                end
            else
                GRM_AddonGlobals.DelayedAtLeastOnce = true;
                C_Timer.After ( 5 , GRM.ManageGuildStatus );
            end
        else
            -- Reset some values;
            GRMsyncGlobals.SyncOK = false;
            GRM_AddonGlobals.logGID = 0;
            GRM_AddonGlobals.saveGID = 0; 
            GRM_AddonGlobals.setPID = 0;  
            GRM_AddonGlobals.timeDelayValue = 0;
            GRM_AddonGlobals.OnFirstLoad = true;
            GRM_AddonGlobals.guildName = nil;
            GRM_AddonGlobals.trackingTriggered = false;
            GRM_AddonGlobals.DelayedAtLeastOnce = true;                     -- Keeping it true as there does not need to be a delay at this point.
            UI_Events:UnregisterEvent ( "GUILD_EVENT_LOG_UPDATE" );         -- This prevents it from doing an unnecessary tracking call if not in guild.
            if GRMsync.MessageTracking ~= nil then
                GRMsync.MessageTracking:UnregisterAllEvents()
            end
            GRMsync.ResetDefaultValuesOnSyncReEnable();                     -- Need to reset sync algorithm too!
            GRM_RosterChangeLogFrame:Hide();
        end
        GeneralEventTracking:RegisterEvent ( "PLAYER_GUILD_UPDATE" );
        GeneralEventTracking:SetScript ( "OnEvent" , GRM.ManageGuildStatus );
        GRM_AddonGlobals.guildStatusChecked = false;
    else
        GRM_AddonGlobals.guildStatusChecked = true;
        C_Timer.After ( 2 , GRM.ManageGuildStatus ); -- Recursively re-check on guild status trigger.
    end
end

-- Method:          ActivateAddon( self , string , string )
-- What it Does:    First, doesn't trigger to load until all variables of addon fully loaded.
--                  Then, it triggers to delay until player is fully in the world, in that order.
--                  Finally, it delays 5 seconds upon querying server as often initial Roster and Guild Event Log query takes a moment to return info.
-- Purpose:         To ensure the smooth handling and loading of the addon so all information is accurate before attempting to parse guild info.
GRM.ActivateAddon = function ( self , event , addon )
    if event == "ADDON_LOADED" then
    -- initiate addon once all variable are loaded.
        if addon == GRM_AddonGlobals.addonName then
            Initialization:RegisterEvent ( "PLAYER_ENTERING_WORLD" ); -- Ensures this check does not occur until after Addon is fully loaded. By registering, it acts recursively throug hthis method
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Initialize load settings! Don't need to be in a guild for this!
        -- Setting the index of the player's faction.
        if GRM_AddonGlobals.faction == nil then
            GRM_AddonGlobals.faction = UnitFactionGroup ( "PLAYER" );
        end

        if GRM_AddonGlobals.faction == "Horde" then
            GRM_AddonGlobals.FID = 1;
        else
            GRM_AddonGlobals.FID = 2;
        end

        GRM.LoadSettings();
        
        -- Must get PID immediately after.
        if GRM_AddonGlobals.setPID == 0 then
            for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                    GRM_AddonGlobals.setPID = i;
                    break;
                end
            end
        end

        if IsInGuild() then
            Initialization:UnregisterEvent ("PLAYER_ENTERING_WORLD");
            Initialization:UnregisterEvent ("ADDON_LOADED");     -- no need to keep scanning these after full loaded. 
            -- Setting the index of the player's guild         
            for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GetGuildInfo ( "PLAYER" ) then
                    GRM_AddonGlobals.logGID = i;
                    break;
                end
            end
            GuildRoster();                                     -- Initial queries...
            QueryGuildEventLog();
            C_Timer.After ( 2 , GRM.GR_LoadAddon );                 -- Queries do not return info immediately, gives server a 5 second delay.
        else
            GRM.ManageGuildStatus();
        end
    end
end


-- Initialize the first frames as game is being loaded.
GRM.PreAddonLoadUI();
Initialization:RegisterEvent ( "ADDON_LOADED" );
Initialization:SetScript ( "OnEvent" , GRM.ActivateAddon );





    -------------------------------------   
    ----- FEATURES TO BE ADDED NEXT!! ---
    -------------------------------------

    -- Groups! Create groups! Allow people to join RBG teams, Raid groups, Mythic groups, Arena teams, Custom... request info of those teams.
    -- Click on the team, it pops up all members of the team w/misc. stats of team.
    -- Options to invite all of that team into a group...

    -- Request to join a group: List all guild groups available in a display window... scrollable. Description of each group
    -- Create a guild group:    Required Title - Description
    -- They can remove it themselves, or guild leader can.
    -- If they leave the guild, and they were only member, guild group dissolves. If other members, admin with longest time in guild gets lead... so, need to track meta data on time player has been in the group
    -- If no admin, then it goes to person who has been in group the longest.

    -- Groups will have own custom window with text area for scheduling minor details.
    -- On inviting members, just use auto-complete logic too.
    -- Request to join list for admins... Deny w/reason

    -- Opetion to right click zone and notify you when it changes
    -- Notify when player comes back from being AFK
    -- On the guild news, let's start with Guild achievements!
    -- If more than one guildie in a zone, on mouseover detail of player zone and time in zone, it also mentions how many people in the guild are also in the zone ( with mouseover including names of those in zone too ).
    -- Drop down menu on the Log Frame allowing you to choose which log to view, from any character, any faction you have... just the log. (maybe I will include maybe not. Seems mostly useless for high time effort)
    -- Guild achievement and loot NEWS window could be parsed for interesting info
    -- BIRTHDAYS
    -- Custom Reminders
    -- Search of the News Window
    -- GUILD EVENT INFO -- Potential huge feature to add
            -- GUILD EVENT AND RAID GROUP INFO
            -- Mark attendance for all in raid +1
            -- Request Assist Button  -- Requests assist from raid leader auto with press of a button it messages them.
            -- Invite everyone online in guild to party/raid
            -- Add method that increments up by 1 a tracker on num events attended, the date, total events attended, for each person that is in the raid group.
    -- INTERESTING GUILD STATISTICS
        -- Like number of legendaries collected this week
        -- Notable achievements, like Prestige advancements, rare achievements, etc.
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Is it possible to identify player's achievements without being close to them?
        -- Notable high ilvl notifications with adjustable threshold to trigger it, for editable updating for expansion update flexibility
        -- Analysis of close-to-get achievements?
    -- MAGIC TOOL BOX for guild leader ??
        -- useful tools only guild leader can see... Like gkick all, or something.
    -- Ability to export data to useful format.
    -- Ability to choose how you would like your timestamps to look.
    -- Sort guild roster by "Time in guild" - possible in built-in UI? - need to complete "Total time in the guild".


    -------------------------------------
    ----- KNOWN BUGS --------------------
    ------------------------------------

    -- Adding player to the event que, set it to only consider it if the player is a "main"
    -- When promoting a player, if their promotion date is visible, it positions it incorrectly - I can't seem to recreate this one...
    -- Note change spam if you have curse words in note/officer notes and Profanity filter on. Just disable profanity filter for now until I get around to it.
    -- False positive on guild namechange??
    
    -------------------------------------
    ----- BUSY work ---------------
    -------------------------------------

    -- Create Viewable BAN window.
    -- Ban list needs to be created to be sync'd - OR, if a player is banned, and it is a player that was in the guild at a previous time in place, then they need to be added to left players list.
    -- Guild Namechange needs to be tested.
    -- On gkicking alts, if they are a rank above you, not to kick them, right?

    -- if the player using the addon is promoted, do a resync check due to new permissions, refresh entire addon UI... -- In other words, if promotion is found and the player is currently online, do sync check.

    -- If Mature language filter is on
    -- 4 letter word == !@#$ !@#$%^ or ^&*!  
    -------------------------------------
    ----- POTENTIAL FEATURES ------------
    -------------------------------------
    
    
    
    -- What player is currently doing, if online "Raiding" or "PVPing" or whatever..


--- Changelog

