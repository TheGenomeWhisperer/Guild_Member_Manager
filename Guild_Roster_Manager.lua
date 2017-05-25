-- Author: TheGenomeWhisperer

-- Table that will hold all global functions... (As of yet unnecessary as all my functions only need to be LOCAL)
GR_AddOn = {};

-- Useful Customizations

local CustomizationGlobals = {
    HowOftenToCheck = 10,               -- in Seconds
    TimeOfflineToKick = 6,              -- In months
    InactiveMemberReturnsTimer = 72,     -- How many hours need to pass by for the guild leader to be notified of player coming back (2 weeks is default value)
    AddTimestampOnJoin = true,           -- Timestamps the officer note on joining, if Officer Note privileges.
    DaysInAdvanceForEventNotify = 14,   -- Cannot be higher than 4 weeks ( 28 days );
    AutoSetCalendarEvents = true
}

-- Saved Variables Per Character (They will be in global table)
GR_LogReport_Save = {};                 -- This will be the stored Log of events. It can only be added to, never modified.
GR_GuildMemberHistory_Save = {}         -- Detailed information on each guild player has been a member of w/member info.
GR_PlayersThatLeftHistory_Save = {};    -- Data storage of all players that left the guild, so metadata is stored if they return. Useful for reasoning as to why banned.
GR_CalendarAddQue_Save = {};            -- Since the add to calendar is protected, and requires a player input, this will be qued here.

-- Useful Variables ( kept in table to keep low upvalues count )
local GR_AddonGlobals = {
    addonName = "Guild Roster Manager",
    guildStatusChecked = false,
    PlayerIsCurrentlyInGuild = false,
    LastOnlineNotReported = true,

    -- For Initial and Live tracking
    timeDelayValue = 0,                     -- For time delay traacking. Only update on trigger. To prevent spammyness.

    -- -- Temp logs for final reporting
    TempNewMember = {},
    TempInactiveReturnedLog = {},
    TempLogPromotion = {},
    TempLogDemotion = {},
    TempLogLeveled = {},
    TempLogNote = {},
    TempLogONote = {},
    TempRankRename = {},
    TempRejoin = {},
    TempBannedRejoin = {},
    TempLeftGuild = {},
    TempNameChanged = {},
    TempEventReport = {},
    TempEventCalendarAddList = {},      -- Needs a list because to add to calendar is a protected function, so it needs player to hit 1 key to input.

    -- Useful UI Local Globals
    timer = 0,
    timer2 = 0, 
    timer3 = 0,
    position = 0,
    pause = false,
    rankDateSet = false,
    editPromoDate = false,
    editJoinDate = false,

    -- DropDownMenuPopulateLogic and playerName
    tempName = "",
    rankIndex = 1,
    playerIndex = -1,
    addonPlayerName = GetUnitName ( "PLAYER" , false ),

    -- DropDownMenus
    monthIndex = 1,
    yearIndex = 1,
    dayIndex = 1,

    -- Alt Helpers
    selectedAlt = {},
    currentHighlightIndex = 1,

    -- Guildie info
    listOfGuildies = {}
}

------------------------
------ FRAMES ----------
------------------------
--------------------------------------
---- UI BUILDING COMPLETELY IN LUA ---
---- FRAMES, FONTS, STYLES, ETC. -----
--------------------------------------

-- Live Frames
local Initialization = CreateFrame("Frame");
local GeneralEventTracking = CreateFrame("Frame");
local UI_Events = CreateFrame("Frame");

-- Core Frame
local MemberDetailMetaData = CreateFrame( "Frame" , "GR_MemberDetails" , GuildRosterFrame , "TranslucentFrameTemplate" );
local MemberDetailMetaDataCloseButton = CreateFrame("Button","GR_MemberDetailMetaDataCloseButton",MemberDetailMetaData,"UIPanelCloseButton");
MemberDetailMetaData:Hide();  -- Prevent error where it sometimes auto-loads.

-- Log History Frame
-- local GR_GuildRosterHistory = CreateFrame("ScrollFrame" , "GR_History" , UIParent , "MinimalScrollFrameTemplate" );

-- Guild Member Detail Frame UI and Children
local YearDropDownMenu = CreateFrame("Frame","GR_YearDropDownMenu",MemberDetailMetaData,"UIDropDownMenuTemplate");
local MonthDropDownMenu = CreateFrame("Frame","GR_MonthDropDownMenu",MemberDetailMetaData,"UIDropDownMenuTemplate");
local DayDropDownMenu = CreateFrame("Frame","GR_DayDropDownMenu",MemberDetailMetaData,"UIDropDownMenuTemplate");
local SetPromoDateButton = CreateFrame("Button","GR_SetPromoDateButton",MemberDetailMetaData,"GameMenuButtonTemplate");

-- SUBMIT BUTTONS
local DateSubmitButton = CreateFrame("Button","GR_DateSubmitButton",MemberDetailMetaData,"UIPanelButtonTemplate");
local DateSubmitCancelButton = CreateFrame("Button","GR_DateSubmitCancelButton",MemberDetailMetaData,"UIPanelButtonTemplate");
local GR_DateSubmitButtonTxt = DateSubmitButton:CreateFontString ( "GR_DateSubmitButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );
local GR_DateSubmitCancelButtonTxt = DateSubmitCancelButton:CreateFontString ( "GR_DateSubmitCancelButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );

-- RANK DROPDOWN
local guildRankDropDownMenu = CreateFrame("Frame" , "GR_RankDropDownMenu" , MemberDetailMetaData , "UIDropDownMenuTemplate" );

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


local PlayerNoteWindow = CreateFrame( "Frame" , "GR_PlayerNoteWindow" , MemberDetailMetaData );
local noteFontString1 = PlayerNoteWindow:CreateFontString ( "GR_NoteText" , "OVERLAY" , "GameFontWhiteTiny" );
local PlayerNoteEditBox = CreateFrame( "EditBox" , "GR_PlayerNoteEditBox" , MemberDetailMetaData );
local PlayerOfficerNoteWindow = CreateFrame( "Frame" , "GR_PlayerOfficerNoteWindow" , MemberDetailMetaData );
local noteFontString2 = PlayerOfficerNoteWindow:CreateFontString ( "GR_OfficerNoteText" , "OVERLAY" , "GameFontWhiteTiny" );
local PlayerOfficerNoteEditBox = CreateFrame( "EditBox" , "GR_OfficerPlayerNoteEditBox" , MemberDetailMetaData );
local NoteCount = MemberDetailMetaData:CreateFontString ( "GR_NoteCharCount" , "OVERLAY" , "GameFontWhiteTiny" );
PlayerNoteEditBox:Hide();
PlayerOfficerNoteEditBox:Hide();

-- Populating Frames with FontStrings
local GR_MemberDetailNameText = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailName" , "OVERLAY" , "GameFontNormalLarge" );
local GR_MemberDetailLevel = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLevel" , "OVERLAY" , "GameFontNormalSmall" );
local GR_MemberDetailRankTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailRankTxt" , "OVERLAY" , "GameFontNormal" );
local GR_MemberDetailRankDateTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailRankDateTxt" , "OVERLAY" , "GameFontNormalSmall" );
local GR_MemberDetailNoteTitle = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailNoteTitle" , "OVERLAY" , "GameFontNormalSmall" );

-- Fontstring for MemberRank History 
local MemberDetailJoinDateButton = CreateFrame ( "Button" , "GR_MemberDetailJoinDateButton" , MemberDetailMetaData , "GameMenuButtonTemplate" );
local MemberDetailJoinDateButtonText = MemberDetailJoinDateButton:CreateFontString ( "MemberDetailJoinDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GR_JoinDateText = MemberDetailMetaData:CreateFontString ( "GR_JoinDateText" , "OVERLAY" , "GameFontWhiteTiny" );

-- LAST ONLINE
local GR_MemberDetailLastOnlineTitleTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLastOnlineTitleTxt" , "OVERYALY" , "GameFontNormalSmall" );
local GR_MemberDetailLastOnlineTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLastOnlineTxt" , "OVERYALY" , "GameFontWhiteTiny" );

-- STATUS TEXT
local GR_MemberDetailPlayerStatus = MemberDetailMetaData:CreateFontString (" GR_MemberDetailLastOnlineUnderline" , "OVERYALY" , "GameFontNormalSmall" );

-- GROUP INVITE and REMOVE from Guild BUTTONS
local groupInviteButton = CreateFrame ( "Button" , "GR_GroupInviteButton" , MemberDetailMetaData , "GameMenuButtonTemplate" );
local removeGuildieButton = CreateFrame ( "Button" , "GR_RemoveGuildieButton" , MemberDetailMetaData , "GameMenuButtonTemplate" );

-- Tooltips
local MemberDetailRankToolTip = CreateFrame ( "GameTooltip" , "GR_MemberDetailRankToolTip" , MemberDetailMetaData , "GameTooltipTemplate" );
MemberDetailRankToolTip:Hide();
local MemberDetailJoinDateToolTip = CreateFrame ( "GameTooltip" , "GR_MemberDetailJoinDateToolTip" , MemberDetailMetaData , "GameTooltipTemplate" );
MemberDetailJoinDateToolTip:Hide();

-- CUSTOM POPUPBOX FOR REUSE -- Avoids all possibility of UI Taint by just building my own, for those that use a lot of addons.
local GR_PopupWindow = CreateFrame ( "Frame" , "GR_PopupWindow" , MemberDetailMetaData , "TranslucentFrameTemplate" );
GR_PopupWindow:Hide() -- Prevents it from autopopping up on load like it sometimes will.
local GR_PopupWindowButton1 = CreateFrame ( "Button" , "GR_PopupWindowButton1" , GR_PopupWindow , "UIPanelButtonTemplate" );
local GR_PopupWindowButton2 = CreateFrame ( "Button" , "GR_PopupWindowButton2" , GR_PopupWindow , "UIPanelButtonTemplate" );
local GR_PopupWindowCheckButton1 = CreateFrame ( "CheckButton" , "GR_PopupWindowCheckButton1" , GR_PopupWindow , "OptionsSmallCheckButtonTemplate" );
local GR_PopupWindowCheckButtonText = GR_PopupWindowCheckButton1:CreateFontString ( "GR_PopupWindowCheckButtonText" , "OVERLAY" , "GameFontNormalSmall" );
local GR_PopupWindowCheckButton2 = CreateFrame ( "CheckButton" , "GR_PopupWindowCheckButton2" , GR_PopupWindow , "OptionsSmallCheckButtonTemplate" );
local GR_PopupWindowCheckButton2Text = GR_PopupWindowCheckButton2:CreateFontString ( "GR_PopupWindowCheckButton2Text" , "OVERLAY" , "GameFontNormalSmall" );
local GR_PopupWindowConfirmText = GR_PopupWindow:CreateFontString ( "GR_PopupWindowConfirmText" , "OVERLAY" , "GameFontNormal" );

-- EDIT BOX FOR ANYTHING ( like banned player note );
local GR_MemberDetailEditBoxFrame = CreateFrame ( "Frame" , "GR_MemberDetailEditBoxFrame" , GR_PopupWindow , "TranslucentFrameTemplate" );
GR_MemberDetailEditBoxFrame:Hide();
local MemberDetailPopupEditBox = CreateFrame ( "EditBox" , "GR_PlayerNoteEditBox" , GR_MemberDetailEditBoxFrame );

-- Banned Fontstring and Buttons
local GR_MemberDetailBannedText1 = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailBannedText1" , "OVERLAY" , "GameFontNormalSmall");
local GR_MemberDetailBannedIgnoreButton = CreateFrame ( "Button" , "GR_MemberDetailBannedIgnoreButton" , MemberDetailMetaData , "GameMenuButtonTemplate" );

-- ALT FRAMES!!!
local GR_CoreAltFrame = CreateFrame( "Frame" , "GR_CoreAltFrame" , MemberDetailMetaData );
GR_CoreAltFrame:Hide(); -- No need to show initially. Occasionally on init. it would popup the title text. Just keep hidden with init.
-- ALT HEADER
local altFrameTitleText = GR_CoreAltFrame:CreateFontString ( "altFrameTitleText" , "OVERLAY" , "GameFontNormalSmall" );
-- ALT OPTIONSFRAME
local altDropDownOptions = CreateFrame ( "Frame" , "altDropDownOptions" , MemberDetailMetaData );
altDropDownOptions:Hide();
local altOptionsText = altDropDownOptions:CreateFontString ( "altOptionsText" , "OVERLAY" , "GameFontNormalSmall" );
local altOptionsDividerText = altDropDownOptions:CreateFontString ( "altOptionsDividerText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT BUTTONS
local addAltButton = CreateFrame ( "Button" , "addAltButton" , GR_CoreAltFrame , "GameMenuButtonTemplate" );
local addAltButtonText = addAltButton:CreateFontString ( "addAltButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local altSetMainButton = CreateFrame ( "Button" , "altSetMainButton" , altDropDownOptions  );
local altSetMainButtonText = altSetMainButton:CreateFontString ( "altSetMainButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local altRemoveButton = CreateFrame ( "Button" , "altRemoveButton" , altDropDownOptions );
local altRemoveButtonText = altRemoveButton:CreateFontString ( "altRemoveButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local altFrameCancelButton = CreateFrame ( "Button" , "altFrameCancelButton" , altDropDownOptions );
local altFrameCancelButtonText = altFrameCancelButton:CreateFontString ( "altFrameCancelButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- ALT TOOLTIP
local altFrameToolTip = CreateFrame ( "GameTooltip" , "altFrameToolTip" , MemberDetailMetaData , "GameTooltipTemplate" );
-- ALT NAMES (If I end up running short on FontStrings, I may need to convert to use static buttons.)
local GR_AltName1 = GR_CoreAltFrame:CreateFontString ( "GR_AltName1" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName2 = GR_CoreAltFrame:CreateFontString ( "GR_AltName2" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName3 = GR_CoreAltFrame:CreateFontString ( "GR_AltName3" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName4 = GR_CoreAltFrame:CreateFontString ( "GR_AltName4" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName5 = GR_CoreAltFrame:CreateFontString ( "GR_AltName5" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName6 = GR_CoreAltFrame:CreateFontString ( "GR_AltName6" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName7 = GR_CoreAltFrame:CreateFontString ( "GR_AltName7" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName8 = GR_CoreAltFrame:CreateFontString ( "GR_AltName8" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName9 = GR_CoreAltFrame:CreateFontString ( "GR_AltName9" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName10 = GR_CoreAltFrame:CreateFontString ( "GR_AltName10" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName11 = GR_CoreAltFrame:CreateFontString ( "GR_AltName11" , "OVERLAY" , "GameFontNormalSmall" );
local GR_AltName12 = GR_CoreAltFrame:CreateFontString ( "GR_AltName12" , "OVERLAY" , "GameFontNormalSmall" );
-- ADD ALT EDITBOX Frame
local AddAltEditFrame = CreateFrame ( "Frame" , "AddAltEditFrame" , GR_CoreAltFrame , "TranslucentFrameTemplate" );
AddAltEditFrame:Hide();
local AddAltTitleText = AddAltEditFrame:CreateFontString ( "AddAltTitleText" , "OVERLAY" , "GameFontNormalSmall" );
local AddAltEditBox = CreateFrame ( "EditBox" , "altAddEditBox" , AddAltEditFrame , "InputBoxTemplate" );
local AddAltNameButton1 = CreateFrame ( "Button" , "AddAltNameButton1" , AddAltEditFrame );
local AddAltNameButton2 = CreateFrame ( "Button" , "AddAltNameButton2" , AddAltEditFrame );
local AddAltNameButton3 = CreateFrame ( "Button" , "AddAltNameButton3" , AddAltEditFrame );
local AddAltNameButton4 = CreateFrame ( "Button" , "AddAltNameButton4" , AddAltEditFrame );
local AddAltNameButton5 = CreateFrame ( "Button" , "AddAltNameButton5" , AddAltEditFrame );
local AddAltNameButton6 = CreateFrame ( "Button" , "AddAltNameButton6" , AddAltEditFrame );
local AddAltNameButton1Text = AddAltNameButton1:CreateFontString ( "AddAltNameButton1" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltNameButton2Text = AddAltNameButton2:CreateFontString ( "AddAltNameButton2" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltNameButton3Text = AddAltNameButton3:CreateFontString ( "AddAltNameButton3" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltNameButton4Text = AddAltNameButton4:CreateFontString ( "AddAltNameButton4" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltNameButton5Text = AddAltNameButton5:CreateFontString ( "AddAltNameButton5" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltNameButton6Text = AddAltNameButton6:CreateFontString ( "AddAltNameButton6" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltEditFrameTextBottom = AddAltEditFrame:CreateFontString ( "AddAltEditFrameTextBottom" , "OVERLAY" , "GameFontWhiteTiny" );
local AddAltEditFrameHelpText = AddAltEditFrame:CreateFontString ( "AddAltEditFrameHelpText" , "OVERLAY" , "GameFontNormalSmall" );

-- CALENDAR ADD EVENT WINDOW
-- local AddEventFrame = CreateFrame ( "Frame" , "AddEventFrame" , UIParent , "TranslucentFrameTemplate" );
-- local AddEventFrameCloseButton = CreateFrame ( "Button" , "AddEventFrameCloseButton" , AddEventFrame , "UIPanelCloseButton" );
-- local AddEventFrameTitleText = AddEventFrame:CreateFontString ( "AddEventFrameTitleText" , "OVERLAY" , "GameFontWhiteTiny" );
-- local AddEventFrameNameTitleText = AddEventFrame:CreateFontString ( "AddEventFrameNameTitleText" , "OVERLAY" , "GameFontWhiteTiny" );
-- -- Set and Ignore Buttons
-- local AddEventFrameSetAnnounceButton = CreateFrame ( "Button" , "AddEventFrameSetAnnounceButton" , AddEventFrame , "UIPanelButtonTemplate" );
-- local AddEventFrameSetAnnounceButtonText = AddEventFrameSetAnnounceButton:CreateFontString ( "AddEventFrameSetAnnounceButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- local AddEventFrameIgnoreButton = CreateFrame ( "Button" , "AddEventFrameIgnoreButton" , AddEventFrame , "UIPanelButtonTemplate" );
-- local AddEventFrameIgnoreButtonText = AddEventFrameIgnoreButton:CreateFontString ( "AddEventFrameIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
-- -- SCROLL FRAME
-- local AddEventScrollFrame = CreateFrame ( "ScrollFrame" , "AddEventScrollFrame" );
-- local AddEventScrollBorderFrame = CreateFrame ( "Frame" , "AddEventScrollBorderFrame" , AddEventFrame , "TranslucentFrameTemplate" );
-- -- CONTENT FRAME (Child Frame)
-- local AddEventScrollChildFrame = AddEventScrollChildFrame or CreateFrame ( "Frame" , "AddEventScrollChildFrame" );
-- -- SLIDER
-- local AddEventScrollFrameSlider = AddEventScrollFrameSlider or CreateFrame ( "Slider" , "AddEventScrollFrameSlider" , AddEventScrollFrame , "UIPanelScrollBarTemplate" );

-- -- Parent Window Details
-- AddEventFrame:SetPoint ( "CENTER" , UIParent );
-- AddEventFrame:SetWidth ( 425 );
-- AddEventFrame:SetHeight ( 225 );
-- -- Scroll Frame Details
-- AddEventScrollBorderFrame:SetSize ( 300 , 175 );
-- AddEventScrollBorderFrame:SetPoint ( "Bottom" , AddEventFrame , 30 , 7 );
-- AddEventScrollFrame:SetWidth(210);
-- AddEventScrollFrame:SetHeight(112);
-- AddEventScrollFrame:SetPoint( "RIGHT" , AddEventFrame , -25 , -14 );
-- AddEventScrollFrame:SetFrameStrata("HIGH");
-- AddEventScrollFrame:SetScrollChild( AddEventScrollChildFrame );
-- -- Slider Parameters
-- AddEventScrollFrameSlider:SetOrientation( "VERTICAL" );
-- AddEventScrollFrameSlider:SetSize( 16 , 91 );
-- AddEventScrollFrameSlider:SetPoint( "TOPLEFT" , AddEventScrollFrame , "TOPRIGHT" , 0 , -11 );
-- AddEventScrollFrameSlider:SetValue( 0 );
-- AddEventScrollFrameSlider:SetScript( "OnValueChanged" , function(self)
--       AddEventScrollFrame:SetVerticalScroll( self:GetValue() )
-- end);

-- local scrollHeight = 0;
-- local scrollWidth = 220;


-- local testingScrollTable = { "today" , "tomorrow" , "You" , "Cannot" , "Stop us" , "Ever!" , "We are" , "Going to" , "Be unstoppable!" , "I know it!" , "It is unbelievable!" , "Am I right" , "Or am I right?" };
-- AddEventScrollChildFrame.allFStrings = AddEventScrollChildFrame.allFStrings or {};  -- Create a table for the fontstrings.
--  -- populating the window correctly.
-- for i = 1 , #testingScrollTable do
--     -- if font string is not created, do so.
--     if not AddEventScrollChildFrame.allFStrings[i] then
--         AddEventScrollChildFrame.allFStrings[i] = AddEventScrollChildFrame:CreateFontString ( "PlayerToAdd" .. i , "OVERLAY" , "GameFontWhiteTiny" ); -- Names each fontstring 1 increment up
--     end

--     local EventFontString = AddEventScrollChildFrame.allFStrings[i];
--     EventFontString:SetText ( testingScrollTable[i] );

--     -- Now let's pin it!
--     if i == 1 then
--         EventFontString:SetPoint( "TOPLEFT" );
--         scrollHeight = scrollHeight + EventFontString:GetStringHeight();
--     else
--         EventFontString:SetPoint( "TOPLEFT" , AddEventScrollChildFrame.allFStrings[i - 1] , "BOTTOMLEFT" , 0 , - 5 );
--         scrollHeight = scrollHeight + EventFontString:GetStringHeight() + 5;
--     end
-- end
-- -- Update the size -- it either grows or it shrinks!
-- AddEventScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

-- --Set Slider Parameters ( has to be done after the above details are placed )
-- local scrollMax = scrollHeight - 112;
-- AddEventScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );



-- ------------------------
--- FUNCTIONS ----------
------------------------

-- Method:          SlimName(string)
-- What it Does:    Removes the server name after character name.
-- Purpose:         Server name is not important in a guild since all will be server name.
local function SlimName ( name )
    if string.find ( name , "-" , 1 ) ~= nil then
        return strsub ( name , 1 , string.find ( name ,"-" ) - 1 );
    else
        return name;
    end
end

-- Method:          ParseClass(string) 
-- DEPRECATED for now as a result of custom UI being built
-- What it Does:    Takes a line of text from GuildMemberDetailFrame and parses out the Class
-- Purpose:         While a call can be made to the server after parsing the index number in a built-in API lookup, that is resource hungry.
--                  Since the server has already pulled the info in text form, this saves a lot of resources from querying the server for player class.
local function ParseClass ( class )
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

-- Method:          ParseLevel(string)
-- DEPRECATED for now...
-- What it Does:    Takes the same text line from GuildMemberDetailFrame and parses out the Level
-- Purpose:         To obtain a player's level one needs to query the server. Since the string is already available, this just grabs the string simply.
local function ParseLevel ( level )
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

-- Method           Trim ( string )
-- What it Does:    Removes the white space at front and at tail of string.
-- Purpose:         Cleanup strings for ease of logic control, as needed.
local function Trim ( str )
    return ( str:gsub ( "^%s*(.-)%s*$" , "%1" ) );
end

-- Method:          GetNumGuildies()
-- What it Does:    Returns the int number of total toons within the guild, including main/alts
-- Purpose:         For book-keeping and tracking total guild membership.
--                  Overall, this is mostly redundant as a simple GetNumGuildMembers() call is the same thing, however, this is just a tech Demo
--                  as a coding example of how to pull info and return it in your own function.
--                  A simple "return GetNumGuildMembers()" would result in the same result in less steps. This is just more explicit.
local function GetNumGuildies()
    local numMembers = GetNumGuildMembers();
    return numMembers;
end

-- Method:          ResetTempLogs()
-- What it Does:    Empties the arrays of the reporting logs
-- Purpose:         Logs are used to build changes in the guild and then to cleanly report them in order.
local function ResetTempLogs()
    GR_AddonGlobals [ "TempNewMember" ] = {};
    GR_AddonGlobals [ "TempInactiveReturnedLog" ] = {};
    GR_AddonGlobals [ "TempLogPromotion" ] = {};
    GR_AddonGlobals [ "TempLogDemotion" ] = {};
    GR_AddonGlobals [ "TempLogLeveled" ] = {};
    GR_AddonGlobals [ "TempLogNote" ] = {};
    GR_AddonGlobals [ "TempLogONote" ] = {};
    GR_AddonGlobals [ "TempRankRename" ] = {};
    GR_AddonGlobals [ "TempRejoin" ] = {};
    GR_AddonGlobals [ "TempBannedRejoin" ] = {};
    GR_AddonGlobals [ "TempLeftGuild" ] = {};
    GR_AddonGlobals [ "TempNameChanged" ] = {};
    GR_AddonGlobals [ "TempEventReport" ] = {};
end

-- Method:          ModifyCustomNote(string,string)
-- What it Does:    Adds a new note to the custom notes string
-- Purpose:         For expanded information on players to create in-game notes or tracking.
local function ModifyCustomNote ( newNote , playerName )
    local guildName = GetGuildInfo("player");
    for i = 1 , #GR_GuildMemberHistory_Save do                                  -- scanning through guilds
        if GR_GuildMemberHistory_Save [i][1] == guildName then                  -- guild identified
            for j = 2 , #GR_GuildMemberHistory_Save[i] do                       -- Scanning through guild Roster
                if GR_GuildMemberHistory_Save[i][j][1] == playerName then       -- Player Found
                    GR_GuildMemberHistory_Save[i][j][23] = newNote;             -- Storing new note.
                    break;
                end
            end
            break;
        end
    end
end

------------------------------------
------ TIME TRACKING TOOLS ---------
--- TIMESTAMPS , TIMEPASSED, ETC. --
------------------------------------

-- Useful Lookup Tables for Epoch Time.
local monthEnum = { Jan=1 , Feb=2 , Mar=3 , Apr=4 , May=5 , Jun=6 , Jul=7 , Aug=8 , Sep=9 , Oct=10 , Nov=11 , Dec=12 };
local daysBeforeMonthEnum = { ['1']=0 , ['2']=31 , ['3']=31+28 , ['4']=31+28+31 , ['5']=31+28+31+30 , ['6']=31+28+31+30+31 , ['7']=31+28+31+30+31+30 , 
                                ['8']=31+28+31+30+31+30+31 , ['9']=31+28+31+30+31+30+31+31 , ['10']=31+28+31+30+31+30+31+31+30 ,['11']=31+28+31+30+31+30+31+31+30+31, ['12']=31+28+31+30+31+30+31+31+30+31+30 };
local daysInMonth = { ['1']=31 , ['2']=28 , ['3']=31 , ['4']=30 , ['5']=31 , ['6']=30 , ['7']=31 , ['8']=31 , ['9']=30 , ['10']=31 , ['11']=30 , ['12']=31 };

-- Method:          IsLeapYear(int)
-- What it Does:    Returns true if the given year is a leapYear
-- Purpose:         For this addon, the calendar date selection, allows it to know to produce 29 days on leap year.
local function IsLeapYear ( yearDate )
    if ( ( ( yearDate % 4 == 0 ) and ( yearDate % 100 ~= 0 ) ) or ( yearDate % 400 == 0 ) ) then
        return true;
    else
        return false;
    end
end

-- Method:          GetHoursSinceLastOnline(int)
-- What it Does:    Returns the total numbner of hours since the player last logged in at given index position of guild roster
-- Purpose:         For player management to notify addon user of too much time has passed, for recommendation to kick,
local function GetHoursSinceLastOnline ( index )
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

-- Method:          IsValidSubmitDate ( int , int , boolean )
-- What it Does:    Returns true if the submission date is valid (not an untrue day or in the future)
-- Purpose:         Check to ensure the wrong date is not submitted on accident.
local function IsValidSubmitDate ( dayJoined , monthJoined , yearJoined , isLeapYearSelected )
    local closeButtons = true;
    local timeEnum = date ( "*t" );
    local currentYear = timeEnum [ "year" ];
    local currentMonth = timeEnum [ "month" ];
    local currentDay = timeEnum [ "day" ];
    local numDays;

    if monthJoined == 1 or monthJoined == 3 or monthJoined == 5 or monthJoined == 7 or monthJoined == 8 or monthJoined == 10 or monthJoined == 12 then
        numDays = 31;
    elseif monthJoined == 2 and isLeapYearSelected then
        numDays = 29;
    elseif monthJoined == 2 then
        numDays = 28;
    else
        numDays = 30;
    end
    if dayJoined > numDays then
        closeButtons = false;
    end
    
    if closeButtons then
        if ( currentYear < yearJoined ) or ( currentYear == yearJoined and currentMonth < monthJoined ) or ( currentYear == yearJoined and currentMonth == monthJoined and currentDay < dayJoined ) then
            print ( "Player Does Not Have a Time Machine!" );
            closeButtons = false;
        end
    end

    if closeButtons == false then
        print ( "Please choose a valid DAY" );
    end
    
    return closeButtons;
end

-- Method:          TimeStampToEpoch(timestamp)
-- What it Does:    Converts a given timestamp: "22 Mar '17" into Epoch Seconds time.
-- Purpose:         On adding notes, epoch time is considered when calculating how much time has passed, for exactness and custom dates need to include it.
local function TimeStampToEpoch ( timestamp )
    -- Parsing Timestamp to useful data.
    local year = tonumber ( strsub ( timestamp , string.find ( timestamp , "'" )  + 1 ) ) + 2000;
    local leapYear = IsLeapYear ( year );
    -- Find second index of spaces
    local count = 0;
    local index = 0;
    local dayInd = -1;
    for i = 1,#timestamp do
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
    local hour = 0;
    local minute = 0;
    local seconds = 0;

    -- calculate the number of seconds passed since 1970 based on number of years that have passed.
    local totalSeconds = 0;
    for i = year - 1 , 1970 , -1 do
        if IsLeapYear ( i ) then
            totalSeconds = totalSeconds + ( 366 * 24 * 3600 ); -- leap year = 366 days
        else
            totalSeconds = totalSeconds + ( 365 * 24 * 360 ); -- 365 days in normal year
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


-- Method:          TotalTimeInGuild(string)
-- What it Does:    Returns to combined total time in the guild, based on accumulated seconds from the 1970 clock of only
--                  the time the player was in the guild. It sums ALL times player was in, including times player left the guild, times player returned.
-- Purpose:         Just misc. tracking info to keep track of the "true" value of time players are in the guild.   
local function TotalTimeInGuild ( name )
    -- To be added eventually :D
end

-- Method:          AddLog(int,string)
-- What it Does:    This adds a size 2 array to the Log including an index to be referenced for color coding, and the log entry
-- Purpose:         Building the Log that will be displayed to the Log window that shows a history of all changes in guild since addon was activated.

-- Method:          GetTimestamp()
-- What it Does:    Reports the current moment in time in a much more clear, concise, pretty way. Example: "9 Feb '17 1:36pm" instead of 09/02/2017/13:36
-- Purpose:         Just for cleaner presentation of the results.
local function GetTimestamp()
    -- Time Variables
    local morning = true;
    local timestamp = date( "*t" );
    local months = { "Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" , "Oct" , "Nov" , "Dec" };
    local year , days , minutes , hour , month = 0;
    for x,y in pairs(timestamp) do
        if x == "hour" then
            hour = y;
        elseif x == "min" then
            minutes = y;
            if minutes < 10 then
                minutes = string.format ( "0" .. minutes ); -- Example, if it was 6:09, the minutes would only be "9" not "09" - so this looks better.
            end
        elseif x == "day" then
            days = y;
        elseif x == "month" then
            month = y;
        elseif x == "year" then
            year = string.format ( y );
            year = strsub ( year , 3 );
        end
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
    -- Establishing proper format
    local time = "";
    if morning then
        time = (days .. " " .. months[month] .. " '" .. year .. " " .. hour .. ":" .. minutes .. "am");
    else
        time = (days .. " " .. months[month] .. " '" .. year .. " " .. hour .. ":" .. minutes .. "pm");
    end
    return string.format ( time );
end

-- Method:          GetTimePassed(oldTimestamp)
-- What it Does:    Reports back the elapsed, in English, since the previous given timestamp, based on the 1970 seconds count.
-- Purpose:         Time tracking to keep track of elapsed time since previous action.
local function GetTimePassed ( oldTimestamp )

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
            timestamp = string.format(year .. " " .. yearTag);
        end
        if month > 0 then
            timestamp = string.format(timestamp .. " " .. month .. " " .. monthTag);
        end
        if days > 0 then
            timestamp = string.format(timestamp .. " " .. days .. " " .. dayTag);
        else
            timestamp = string.format(timestamp .. " " .. days .. " " .. "days"); -- exception to put zero days since it seems smoother, aesthetically.
        end
    else
        if hours > 0 or minutes > 0 then
            if hours > 0 then
                timestamp = string.format(timestamp .. " " .. hours .. " " .. hoursTag);
            end
            if minutes > 0 then
                timestamp = string.format(timestamp .. " " .. minutes .. " " .. minutesTag);
            end
        else
            timestamp = string.format(seconds .. " " .. secondsTag);
        end
    end
    return timestamp;
end

-- Method:          HoursReport(int)
-- What it Does:    Reports as a string the time passed since player last logged on.
-- Purpose:         Cleaner reporting to the log, and it just reports the lesser info, no seconds and so on.
local function HoursReport ( hours )
    local result = "";
    -- local _,month,_,currentYear = CalendarGetDate();

    local years = math.floor ( hours / 8766 );
    local months = math.floor ( ( hours % 8766 ) / 730.5 );
    local days = math.floor ( ( hours % 730.5 ) / 24 );

    -- Continue calculations.
    local hours = math.floor(((hours % 8760) % 730) % 24);
    
    
    if (years >= 1) then
        if years > 1 then
            result = result .. "" .. years .. " yrs ";
        else
            result = result .. "" .. years .. " yr ";
        end
    end

    if (months >= 1) then
        if years > 0 then
            result = Trim ( result ) .. ", ";
        end
        if months > 1 then
            result = result .. "" .. months .. " mos ";
        else
            result = result .. "" .. months .. " mo ";
        end
    end

    if (days >= 1) then
        if months > 0 then
            result = Trim ( result ) .. ", ";
        end
        if days > 1 then
            result = result .. "" .. days .. " days ";
        else
            result = result .. "" .. days .. " day ";
        end
    end

    if (hours >= 1 and years < 1 and months < 1 ) then  -- No need to give exact hours on anything over than a month, just the day is good enough.
        if days > 0 then
            result = Trim ( result ) .. ", ";
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

-- Method:          AltButtonPos(int)
-- What it Does:    Returns the horizontal and vertical coordinates for the button position on frame
-- Purpose:         To adjust the position of the AddAlt button based on the number of alts.
local function AltButtonPos ( index )
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

-- Method:          PopulateAltFrames(string, int , int )
-- What it Does:    This generates the alt frames in the main addon metadata detail frame
-- Purpose:         Clean formatting of the alt frames.
local function PopulateAltFrames ( index1 , index2 )
    -- let's start by prepping the frames.
    local listOfAlts = GR_GuildMemberHistory_Save[index1][index2][11];
    local numAlts = #listOfAlts
    local butPos = AltButtonPos ( numAlts );
    addAltButton:SetPoint ( "TOP" , GR_CoreAltFrame , butPos[1] , butPos[2] );
    addAltButton:Show();
    -- now, let's populate them
    if numAlts > 0 then
        local result = listOfAlts[1][1];
        if listOfAlts[1][5] == true then  --- this person is the main!
            result = result .. "\n|cffff0000(main)"
        end
        GR_AltName1:SetText ( result );
        GR_AltName1:SetTextColor ( listOfAlts[1][2] , listOfAlts[1][3] , listOfAlts[1][4] , 1.0 );
        GR_AltName1:Show();
    else
        GR_AltName1:Hide();
    end
    if numAlts > 1 then
        GR_AltName2:SetText ( listOfAlts[2][1] );
        GR_AltName2:SetTextColor ( listOfAlts[2][2] , listOfAlts[2][3] , listOfAlts[2][4] , 1.0 );
        GR_AltName2:Show();
    else
        GR_AltName2:Hide();
    end
    if numAlts > 2 then
        GR_AltName3:SetText ( listOfAlts[3][1] );
        GR_AltName3:SetTextColor ( listOfAlts[3][2] , listOfAlts[3][3] , listOfAlts[3][4] , 1.0 );
        GR_AltName3:Show();
    else
        GR_AltName3:Hide();
    end
    if numAlts > 3 then
        GR_AltName4:SetText ( listOfAlts[4][1] );
        GR_AltName4:SetTextColor ( listOfAlts[4][2] , listOfAlts[4][3] , listOfAlts[4][4] , 1.0 );
        GR_AltName4:Show();
    else
        GR_AltName4:Hide();
    end
    if numAlts > 4 then
        GR_AltName5:SetText ( listOfAlts[5][1] );
        GR_AltName5:SetTextColor ( listOfAlts[5][2] , listOfAlts[5][3] , listOfAlts[5][4] , 1.0 );
        GR_AltName5:Show();
    else
        GR_AltName5:Hide();
    end
    if numAlts > 5 then
        GR_AltName6:SetText ( listOfAlts[6][1] );
        GR_AltName6:SetTextColor ( listOfAlts[6][2] , listOfAlts[6][3] , listOfAlts[6][4] , 1.0 );
        GR_AltName6:Show();
    else
        GR_AltName6:Hide();
    end
    if numAlts > 6 then
        GR_AltName7:SetText ( listOfAlts[7][1] );
        GR_AltName7:SetTextColor ( listOfAlts[7][2] , listOfAlts[7][3] , listOfAlts[7][4] , 1.0 );
        GR_AltName7:Show();
    else
        GR_AltName7:Hide();
    end
    if numAlts > 7 then
        GR_AltName8:SetText ( listOfAlts[8][1] );
        GR_AltName8:SetTextColor ( listOfAlts[8][2] , listOfAlts[8][3] , listOfAlts[8][4] , 1.0 );
        GR_AltName8:Show();
    else
        GR_AltName8:Hide();
    end
    if numAlts > 8 then
        GR_AltName9:SetText ( listOfAlts[9][1] );
        GR_AltName9:SetTextColor ( listOfAlts[9][2] , listOfAlts[9][3] , listOfAlts[9][4] , 1.0 );
        GR_AltName9:Show();
    else
        GR_AltName9:Hide();
    end
    if numAlts > 9 then
        GR_AltName10:SetText ( listOfAlts[10][1] );
        GR_AltName10:SetTextColor ( listOfAlts[10][2] , listOfAlts[10][3] , listOfAlts[10][4] , 1.0 );
        GR_AltName10:Show();
    else
        GR_AltName10:Hide();
    end
    if numAlts > 10 then
        GR_AltName11:SetText ( listOfAlts[11][1] );
        GR_AltName11:SetTextColor ( listOfAlts[11][2] , listOfAlts[11][3] , listOfAlts[11][4] , 1.0 );
        GR_AltName11:Show();
    else
        GR_AltName11:Hide();
    end
    if numAlts > 11 then
        GR_AltName12:SetText ( listOfAlts[12][1] );
        GR_AltName12:SetTextColor ( listOfAlts[12][2] , listOfAlts[12][3] , listOfAlts[12][4] , 1.0 );
        GR_AltName12:Show();
    else
        GR_AltName12:Hide();
    end
    GR_CoreAltFrame:Show();
end

-- Method:          GetClassColorRGB ( string )
-- What it Does:    Returns the 0-1 RGB color scale for the player class
-- Purpose:         Easy class color tagging for UI feature.
local function GetClassColorRGB ( className )
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

-- Method:          RemoveAlt(string , string , string)
-- What it Does:    Detags the given altName to that set of toons.
-- Purpose:         Alt management, so whoever has addon installed can tag player.
local function RemoveAlt ( playerName , altName , guildName)
    local isRemoveMain = false;
    if playerName ~= altName then
        local index1 , index2;
        local altIndex1 , altIndex2;
        local count = 0;

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for i = 1 , #GR_GuildMemberHistory_Save do
            if guildName == GR_GuildMemberHistory_Save[i][1] then
                for j = 2 , #GR_GuildMemberHistory_Save[i] do      
                    if GR_GuildMemberHistory_Save[i][j][1] == playerName then        -- Identify position of player
                        count = count + 1;
                        index1 = i;
                        index2 = j;
                    end
                    if GR_GuildMemberHistory_Save[i][j][1] == altName then           -- Pull altName to attach class on Color
                        count = count + 1;
                        altIndex1 = i;
                        altIndex2 = j;
                        if #GR_GuildMemberHistory_Save[i][j][11] > 1 and GR_GuildMemberHistory_Save[i][j][10] then -- No need to report if the person is removing the last alt. No need to set oneself as main.
                            isRemoveMain = true;
                        end
                    end
                    if count == 2 then
                        break;
                    end
                end
                break;
            end
        end
        -- Removing the alt from all of the player's alts.'
        local listOfAlts = GR_GuildMemberHistory_Save[index1][index2][11];
        if #listOfAlts > 0 then                                                                                                     -- There is more than 1 alt for new alt to be added to
            for i = 1 , #listOfAlts do
                if listOfAlts[i][1] ~= altName then                                                                                 -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GR_GuildMemberHistory_Save[index1] do                                                              -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GR_GuildMemberHistory_Save[index1][j][1] then                                        -- name on current focus altList found in the metadata and is not the alt to be removed.
                            -- Now, we have the list!
                            for m = 1 , #GR_GuildMemberHistory_Save[index1][j][11] do
                                if GR_GuildMemberHistory_Save[index1][j][11][m][1] == altName then
                                    table.remove ( GR_GuildMemberHistory_Save[index1][j][11] , m );     -- removing the alt
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
        for i = 1 , #GR_GuildMemberHistory_Save[index1][index2][11] do
            if GR_GuildMemberHistory_Save[index1][index2][11][i][1] == altName then
                table.remove ( GR_GuildMemberHistory_Save[index1][index2][11] , i );
                break;
            end
        end
        -- Resetting the alt's list
        if isRemoveMain then 
            GR_GuildMemberHistory_Save[altIndex1][altIndex2][10] = false;
        end
        GR_GuildMemberHistory_Save[altIndex1][altIndex2][11] = nil;
        GR_GuildMemberHistory_Save[altIndex1][altIndex2][11] = {};
        -- Insta update the frames!
        PopulateAltFrames ( index1 , index2 );
    else
        print ( playerName .. " cannot remove themselves from alts." );
    end

    -- Warn the player that the toon they removed is the main!
    if isRemoveMain then
        print ( altName .. " was listed as the main! Don't forget to set a new main!");
    end
end

-- Method:          AddAlt (string,string,string)
-- What it Does:    Tags toon to a player's set of alts. It will tag them not just to the given player, but reverse tag itself to all of the alts.
-- Purpose:         Organizing a player and their alts.
local function AddAlt ( playerName , altName , guildName )
    if playerName ~= altName then
        -- First, let's identify player index, then identify the classColor of the alt
        local index1 , index2;
        local altIndex1 , altIndex2;
        local count = 0;
        local classAlt = "";
        local classMain = "";
        local classColorsAlt , classColorsMain , classColorsTemp;
        local isMain = false;

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for i = 1 , #GR_GuildMemberHistory_Save do
            if guildName == GR_GuildMemberHistory_Save[i][1] then
                for j = 2 , #GR_GuildMemberHistory_Save[i] do      
                    if GR_GuildMemberHistory_Save[i][j][1] == playerName then        -- Identify position of player
                        count = count + 1;
                        index1 = i;
                        index2 = j;
                        classMain = GR_GuildMemberHistory_Save[i][j][9];
                    end
                    if GR_GuildMemberHistory_Save[i][j][1] == altName then           -- Pull altName to attach class on Color
                        count = count + 1;
                        altIndex1 = i;
                        altIndex2 = j;
                        classAlt = GR_GuildMemberHistory_Save[i][j][9];
                    end
                    if count == 2 then
                        break;
                    end
                end
                break;
            end
        end

        -- If player is trying to add this toon to a list that is already on a list then it adds it in reverse
        if #GR_GuildMemberHistory_Save[altIndex1][altIndex2][11] > 0 and #GR_GuildMemberHistory_Save[index1][index2][11] > 0 then  -- Oh my! Both players have current lists!!! Remove the alt from his list, add to this new one.
            RemoveAlt ( GR_GuildMemberHistory_Save[altIndex1][altIndex2][11][1][1] , GR_GuildMemberHistory_Save[altIndex1][altIndex2][1] , guildName );
        end
        if #GR_GuildMemberHistory_Save[altIndex1][altIndex2][11] > 0 then
            local listOfAlts = GR_GuildMemberHistory_Save[altIndex1][altIndex2][11];
            local isFound = false;
            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                if listOfAlts[m][1] == playerName then
                    print( altName .. " is Already Listed as an Alt." );
                    isFound = true;
                    break;
                end
            end
            if isFound ~= true then
                AddAlt ( altName , playerName , guildName );
            end
        else
            -- add altName to each of the previously
            local isFound = false;
            classColorsAlt = GetClassColorRGB ( classAlt );
            local listOfAlts = GR_GuildMemberHistory_Save[index1][index2][11];
            if #listOfAlts > 0 then                                                                 -- There is more than 1 alt for new alt to be added to
                for i = 1 , #listOfAlts do                                                          -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GR_GuildMemberHistory_Save[index1] do                              -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GR_GuildMemberHistory_Save[index1][j][1] then        -- name on current focus altList found in the metadata!
                            -- Now, make sure it is not a repeat add!
                            
                            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                                if listOfAlts[m][1] == altName then
                                    print( altName .. " is Already Listed as an Alt." );
                                    isFound = true;
                                    break;
                                end
                            end
                            if isFound ~= true then
                                classColorsTemp = GetClassColorRGB ( GR_GuildMemberHistory_Save[index1][j][9] );
                                table.insert ( GR_GuildMemberHistory_Save[index1][j][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , isMain } ); -- altName is added to a currentFocus previously added alt.
                                table.insert ( GR_GuildMemberHistory_Save[altIndex1][altIndex2][11] , { GR_GuildMemberHistory_Save[index1][j][1] , classColorsTemp[1] , classColorsTemp[2] , classColorsTemp[3] , GR_GuildMemberHistory_Save[index1][j][10] } );
                            end
                            break;
                        end
                    end
                    if isFound then
                        break;
                    end
                end
            end

            if isFound ~= true then
                -- Add all of the CurrentFocus player's alts to the new alt
                -- then add the currentFocus player as well
                classColorsMain = GetClassColorRGB ( classMain );
                table.insert ( GR_GuildMemberHistory_Save[altIndex1][altIndex2][11] , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , isMain } );
                -- Finally, let's add the alt to the player's currentFocus.
                table.insert ( GR_GuildMemberHistory_Save[index1][index2][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , isMain } );
            end
            -- Insta update the frames!
            if GR_GuildMemberHistory_Save[index1][index2][1] == GR_MemberDetailNameText:GetText() then 
                PopulateAltFrames ( index1 , index2 );
            else
                PopulateAltFrames ( altIndex1 , altIndex2 );
            end
        end
    else
        print ( playerName .. " cannot become their own alt!" );
    end
end

-- Need to add protection so player cannot remove themselves. DO I??


-- Method:              SortMainToTo (string , int , int , string)
-- What it Does:        Sorts the alts list and sets the main to the top.
-- Purpose:             To keep the main as the first name in the list of alts.
local function SortMainToTop ( playerName , index1 , index2 )
    local tempList;
    -- Ok, now, let's grab the list and do some sorting!
    if GR_GuildMemberHistory_Save[index1][index2][10] ~= true then                      -- no need to attempt sorting if they are all alts, none are the main.
        for i = 1 , #GR_GuildMemberHistory_Save[index1][index2][11] do                  -- scanning through the list of alts
            if GR_GuildMemberHistory_Save[index1][index2][11][i][5] then                -- if one of them equals the main!
                tempList = GR_GuildMemberHistory_Save[index1][index2][11][i];           -- Saving main's info to temp holder
                table.remove ( GR_GuildMemberHistory_Save[index1][index2][11] , i );    -- removing
                table.insert ( GR_GuildMemberHistory_Save[index1][index2][11] , 1 , tempList );  -- Re-adding it to the front and done!
                break
            end
        end
    end
end

-- Method:              SetMain (string,string,string)
-- What it Does:        Sets the player as main, as well as updates that status among the alt grouping.
-- Purpose:             Main/alt management control.
local function SetMain ( playerName , mainName , guildName )
    local index1 , index2;
    local altIndex1 , altIndex2;
    local count = 0;

    -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested,difficult to follow, and bloated.
    for i = 1 , #GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do      
                if GR_GuildMemberHistory_Save[i][j][1] == playerName then        -- Identify position of player
                    index1 = i;
                    index2 = j;
                    if playerName == mainName then                               -- no need to identify an alt if there is none.
                        break;
                    else
                        count = count + 1;
                    end
                end
                if GR_GuildMemberHistory_Save[i][j][1] == mainName then           -- Pull mainName to attach class on Color
                    count = count + 1;
                    altIndex1 = i;
                    altIndex2 = j;
                end
                if count == 2 then
                    break;
                end
            end
            break;
        end
    end

    local listOfAlts = GR_GuildMemberHistory_Save[index1][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GR_GuildMemberHistory_Save[index1] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GR_GuildMemberHistory_Save[index1][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GR_GuildMemberHistory_Save[index1][j][1] == mainName then                -- this alt is the main!
                        GR_GuildMemberHistory_Save[index1][j][10] = true;                       -- Setting toon as main!
                        for m = 1 , #GR_GuildMemberHistory_Save[index1][j][11] do               -- making sure all their alts are listed as notMain
                            GR_GuildMemberHistory_Save[index1][j][11][m][5] = false;
                        end
                    else
                        GR_GuildMemberHistory_Save[index1][j][10] = false;                      -- ensure alt is not listed as main
                        for m = 1 , #GR_GuildMemberHistory_Save[index1][j][11] do               -- identifying who is to be tagged as main
                            if GR_GuildMemberHistory_Save[index1][j][11][m][1] == mainName then
                                GR_GuildMemberHistory_Save[index1][j][11][m][5] = true;
                            else
                                GR_GuildMemberHistory_Save[index1][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    SortMainToTop ( GR_GuildMemberHistory_Save[index1][j][1] , index1 , j );
                    break
                end
            end            
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        GR_GuildMemberHistory_Save[index1][index2][10] = false;
        GR_GuildMemberHistory_Save[altIndex1][altIndex2][10] = true;
        for m = 1 , #GR_GuildMemberHistory_Save[index1][index2][11] do               -- identifying who is to be tagged as main
            if GR_GuildMemberHistory_Save[index1][index2][11][m][1] == mainName then
                GR_GuildMemberHistory_Save[index1][index2][11][m][5] = true;
            else
                GR_GuildMemberHistory_Save[index1][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        SortMainToTop ( playerName , index1 , index2 );
    else
        GR_GuildMemberHistory_Save[index1][index2][10] = true;
    end
    -- Insta update the frames!
    PopulateAltFrames ( index1 , index2 );
end

-- Method:          PlayerHasMain( string , int , int )
-- What it Does:    Returns true if either the player has a main or is a main themselves
-- Purpose:         Better alt management logic.
local function PlayerHasMain ( playerName , index1 , index2 )
    local hasMain = false;

    if GR_GuildMemberHistory_Save[index1][index2][10] then
        hasMain = true;
    else
        for i = 1 , #GR_GuildMemberHistory_Save[index1][index2][11] do
            if GR_GuildMemberHistory_Save[index1][index2][11][i][5] then
                hasMain = true;
                break;
            end
        end
    end
    return hasMain;
end

-- Method:          GetCoreFontStringClicked()
-- What it Does:    Returns a table with the name of the player, the altName, and the guild.
-- Puspose:         To easily pass the info on without having to use a global variable, and set one function to all 12 alt frames.
local function GetCoreFontStringClicked()
    local altName;
    local focusName = GR_MemberDetailNameText:GetText();
    local guildName = GetGuildInfo("player");
    local isMain = false;

    if GR_AltName1:IsVisible() and GR_AltName1:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName1:GetText();
    elseif GR_AltName2:IsVisible() and GR_AltName2:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName2:GetText();
    elseif GR_AltName3:IsVisible() and GR_AltName3:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName3:GetText();
    elseif GR_AltName4:IsVisible() and GR_AltName4:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName4:GetText();
    elseif GR_AltName5:IsVisible() and GR_AltName5:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName5:GetText();
    elseif GR_AltName6:IsVisible() and GR_AltName6:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName6:GetText();
    elseif GR_AltName7:IsVisible() and GR_AltName7:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName7:GetText();
    elseif GR_AltName8:IsVisible() and GR_AltName8:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName8:GetText();
    elseif GR_AltName9:IsVisible() and GR_AltName9:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName9:GetText();
    elseif GR_AltName10:IsVisible() and GR_AltName10:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName10:GetText();
    elseif GR_AltName11:IsVisible() and GR_AltName11:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName11:GetText();
    elseif GR_AltName12:IsVisible() and GR_AltName12:IsMouseOver( 2 , -2 , -2 , 2 ) then
        altName = GR_AltName12:GetText();
    elseif ( GR_MemberDetailRankDateTxt:IsVisible() and GR_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GR_JoinDateText:IsVisible() and GR_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) ) then -- Covers both promo date and join date focus.
        altName = focusName;
    else
        -- MOUSE WAS NOT OVER, EVEN ON A RIGHT CLICK OF THE FRAME!!!
        focusName = nil;
        altName = nil;
    end
    if altName ~= nil and string.find ( altName , "(main)" ) ~= nil then        -- This is the main! Let's parse main out of the name!
        altName = string.sub ( altName , 1 , string.find ( altName ,"\n" ) - 1 );
        isMain = true;
    end
    return { focusName , altName , guildName , isMain };
end

-->> RIGHT CLICK > "Edit" , "Clear History" , "_" "Cancel"

-- Method:              DemoteFromMain ( string , string , string )
-- What it Does:        If the player is "main" then it removes the main tag to false
-- Purpose:             User Experience (UX) and alt management!
local function DemoteFromMain ( playerName , mainName , guildName )
    local index1 , index2;
    local altIndex1 , altIndex2;
    local count = 0;

    -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested,difficult to follow, and bloated.
    for i = 1 , #GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do      
                if GR_GuildMemberHistory_Save[i][j][1] == playerName then        -- Identify position of player
                    index1 = i;
                    index2 = j;
                    if playerName == mainName then                               -- no need to identify an alt if there is none.
                        break;
                    else
                        count = count + 1;
                    end
                end
                if GR_GuildMemberHistory_Save[i][j][1] == mainName then           -- Pull mainName to attach class on Color
                    count = count + 1;
                    altIndex1 = i;
                    altIndex2 = j;
                end
                if count == 2 then
                    break;
                end
            end
            break;
        end
    end

    local listOfAlts = GR_GuildMemberHistory_Save[index1][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GR_GuildMemberHistory_Save[index1] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GR_GuildMemberHistory_Save[index1][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GR_GuildMemberHistory_Save[index1][j][1] == mainName then                -- this alt is the main!
                        GR_GuildMemberHistory_Save[index1][j][10] = false;                       -- Setting toon as main!
                        for m = 1 , #GR_GuildMemberHistory_Save[index1][j][11] do               -- making sure all their alts are listed as notMain
                            GR_GuildMemberHistory_Save[index1][j][11][m][5] = false;
                        end
                    else
                        GR_GuildMemberHistory_Save[index1][j][10] = false;                      -- ensure alt is not listed as main
                        for m = 1 , #GR_GuildMemberHistory_Save[index1][j][11] do               -- identifying who is to be tagged as main
                            if GR_GuildMemberHistory_Save[index1][j][11][m][1] == mainName then
                                GR_GuildMemberHistory_Save[index1][j][11][m][5] = false;
                            else
                                GR_GuildMemberHistory_Save[index1][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    SortMainToTop ( GR_GuildMemberHistory_Save[index1][j][1] , index1 , j );
                    break
                end
            end            
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        GR_GuildMemberHistory_Save[index1][index2][10] = false;
        GR_GuildMemberHistory_Save[altIndex1][altIndex2][10] = false;
        for m = 1 , #GR_GuildMemberHistory_Save[index1][index2][11] do               -- identifying who is to be tagged as main
            if GR_GuildMemberHistory_Save[index1][index2][11][m][1] == mainName then
                GR_GuildMemberHistory_Save[index1][index2][11][m][5] = false;
            else
                GR_GuildMemberHistory_Save[index1][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        SortMainToTop ( playerName , index1 , index2 );
    else
        GR_GuildMemberHistory_Save[index1][index2][10] = false;
    end
    -- Insta update the frames!
    PopulateAltFrames ( index1 , index2 );
end

-- Method:          ResetAltButtonHighlights();
-- What it Does:    Just resets the highlight of the tab/alt-tab highlight for a better user-experience to default position
-- Purpose:         UX
local function ResetAltButtonHighlights()
    AddAltNameButton1:LockHighlight();
    AddAltNameButton2:UnlockHighlight();
    AddAltNameButton3:UnlockHighlight();
    AddAltNameButton4:UnlockHighlight();
    AddAltNameButton5:UnlockHighlight();
    AddAltNameButton6:UnlockHighlight();
    GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
end


-- Method:          AddAltAutoComplete()
-- What it Does:    Takes the entire list of guildies, then sorts them as player types to be added to alts list
-- Purpose:         Eliminates the possibility of a person entering a fake name of a player no longer in the guild.
local function AddAltAutoComplete()
    local partName = AddAltEditBox:GetText();
    GR_AddonGlobals [ "listOfGuildies" ] = nil;
    GR_AddonGlobals [ "listOfGuildies" ] = {};
    local numButtons = 6;

    for i = 1 , GetNumGuildies() do
        local name = GetGuildRosterInfo( i );
        name = SlimName ( name );
        if name ~= GR_MemberDetailNameText:GetText() then   -- no need to go through player's own window
            table.insert ( GR_AddonGlobals [ "listOfGuildies" ] , name );
        end
    end
    sort ( GR_AddonGlobals [ "listOfGuildies" ] );    -- Alphabetizing it for easier parsing for buttontext updating.
    
    -- Now, let's identify the names that match
    local count = 0;
    local matchingList = {};
    local found = false;
    for i = 1 , #GR_AddonGlobals [ "listOfGuildies" ] do
        local innerFound = false;
        if string.lower ( partName ) == string.lower ( string.sub ( GR_AddonGlobals [ "listOfGuildies" ][i] , 1 , #partName ) ) then
            innerFound = true;
            found = true;
            count = count + 1;
            table.insert ( matchingList , GR_AddonGlobals [ "listOfGuildies" ][i] );
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
        ResetAltButtonHighlights();
        if resultCount > 0 then
            AddAltEditFrameHelpText:Hide();
            AddAltNameButton1Text:SetText ( matchingList[1] );
            AddAltNameButton1:Enable();
            AddAltNameButton1:Show();
            AddAltEditFrameTextBottom:Show();
        else
            AddAltEditFrameHelpText:SetText ( "Player Not Found" );
            AddAltEditFrameHelpText:Show();
            AddAltNameButton1:Hide();
            AddAltEditFrameTextBottom:Hide();
        end
        if resultCount > 1 then
            AddAltNameButton2Text:SetText ( matchingList[2] );
            AddAltNameButton2:Enable();
            AddAltNameButton2:Show();
        else
            AddAltNameButton2:Hide();
        end
        if resultCount > 2 then
            AddAltNameButton3Text:SetText ( matchingList[3] );
            AddAltNameButton3:Enable();
            AddAltNameButton3:Show();
        else
            AddAltNameButton3:Hide();
        end
        if resultCount > 3 then
            AddAltNameButton4Text:SetText ( matchingList[4] );
            AddAltNameButton4:Enable();
            AddAltNameButton4:Show();
        else
            AddAltNameButton4:Hide();
        end
        if resultCount > 4 then
            AddAltNameButton5Text:SetText ( matchingList[5] );
            AddAltNameButton5:Enable();
            AddAltNameButton5:Show();
        else
            AddAltNameButton5:Hide();
        end
        if resultCount > 5 then
            if resultCount == 6 then
                AddAltNameButton6Text:SetText ( matchingList[6] );
                AddAltNameButton6:Enable();
            else
                AddAltNameButton6Text:SetText ( "..." );
                AddAltNameButton6:Disable();
            end
            AddAltNameButton6:Show();
        else
            AddAltNameButton6:Hide();
        end
    else
        AddAltNameButton1:Hide();
        AddAltNameButton2:Hide();
        AddAltNameButton3:Hide();
        AddAltNameButton4:Hide();
        AddAltNameButton5:Hide();
        AddAltNameButton6:Hide();
        ResetAltButtonHighlights();
        AddAltEditFrameTextBottom:Hide();
        AddAltEditFrameHelpText:SetText ( "Please Type the Name\nof the alt" );
        AddAltEditFrameHelpText:Show();  
    end
end

-- Method:              KickAllAlts ( string , string )
-- What it Does:        Bans and/or kicks all the alts a player has given the status of checekd button on ban window.
-- Purpose:             QoL. Option to ban players' alts as well if they are getting banned.
local function KickAllAlts ( playerName , guildName )
    for i = 1 , #GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do      
                if GR_GuildMemberHistory_Save[i][j][1] == playerName then        -- Identify position of player
                -- Ok, let's parse the player's data!
                    local listOfAlts = GR_GuildMemberHistory_Save[i][j][11];
                    if #listOfAlts > 0 then                                  -- There is at least 1 alt
                        for m = 1 , #listOfAlts do                           -- Cycling through the alts
                            if GR_PopupWindowCheckButton1:GetChecked() then     -- Player wants to BAN the alts!
                                for s = 1 , #listOfAlts do
                                    for r = 2 , #GR_GuildMemberHistory_Save[i] do
                                        if GR_GuildMemberHistory_Save[i][r][1] == listOfAlts[s][1] then
                                            -- Set the banned info.
                                            GR_GuildMemberHistory_Save[i][r][17] = true;
                                            local instructionNote = "Reason Banned? (Press ENTER when done)";
                                            local result = MemberDetailPopupEditBox:GetText();
                                            if result ~= instructionNote and result ~= "" and result ~= nil then
                                                GR_GuildMemberHistory_Save[i][r][18] = result;
                                            elseif result == nil then
                                                GR_GuildMemberHistory_Save[i][r][18] = "";
                                            end
                                            GR_GuildMemberHistory_Save[i][r][18] = result;
                                            GuildUninvite ( listOfAlts[s][1] );

                                            break;
                                        end
                                    end
                                end
                                break;
                            else
                                GuildUninvite ( GR_GuildMemberHistory_Save[i][j][11][m][1] );                            
                            end
                        end
                    end
                    break;
                end
            end
            break;
        end
    end
end

-- to do methods.
local function GetAlts ( playerName , guildName )

end

local function GetPlayersWithoutMain ( guildName )

end

local function ClearAllAlts ( playerName , guildName )

end

-- /run AddAlt("Arkaan","Rochester","Is a Subatomic Particle")
-- /run RemoveAlt("Arkaan","Darsceey","Is a Subatomic Particle")
-- /run SetMain("Arkaan","Energite","Is a Subatomic Particle")
------------------------------------
---- END OF ALT MANAGEMENT ---------
------------------------------------



------------------------------------
------ METADATA TRACKING LOGIC -----
--- Reporting, Live Tracking, Etc --
------------------------------------

-- Method:          AddMemberRecord()
-- What it Does:    Builds Member Record into Guild History with various metadata
-- Purpose:         For reliable guild data tracking.
local function AddMemberRecord( memberInfo , isReturningMember , oldMemberInfo , guildName )
    -- Metadata to track on all players.
    -- Basic Info
    local name = memberInfo[1];
    local joinDate = GetTimestamp();
    local joinDateMeta = time();  -- Saved in Seconds since Jan 1, 1970, to be parsed later
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
    local eventTrackers = { { name .. "'s Anniversary!" , nil , false , "" } , { name .. "'s Birthday!" , nil , false , "" } };  -- Position 1 = anniversary , Position 2 = birthday , 3 = anniversary For Each = { date , needsToNotify , SpecialNotes }
    local customNote = ""; -- Extra note space, for GM to add futher info.

    -- Info nil now, but to be populated on leaving the guild
    local leftGuildDate = {};
    local leftGuildDateMeta = {};
    local bannedFromGuild = false;
    local reasonBanned = "";
    local oldRank = nil;
    local oldJoinDate = {}; -- filled upon player leaving the guild.
    local oldJoinDateMeta = {};

    -- Pieces info that were added on later-- from index 24 of metaData array, so as not to mess with previous code
    local lastOnline = 0;                                                                           -- Stores it in number of HOURS since last online.
    local rankHistory = {};
    local playerLevelOnJoining = currentLevel;

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
    end

    -- For both returning players and new adds
    table.insert ( rankHistory , { rank , strsub ( joinDate , 1 , string.find ( joinDate , "'" ) + 2 ) , joinDateMeta } );

    for i = 1 , #GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            table.insert ( GR_GuildMemberHistory_Save[i] , { name , joinDate , joinDateMeta , rank , rankInd , currentLevel , note , officerNote , class , isMainToon ,
                listOfAltsInGuild , dateOfLastPromotion , dateOfLastPromotionMeta , birthday , leftGuildDate , leftGuildDateMeta , bannedFromGuild , reasonBanned , oldRank ,
                    oldJoinDate , oldJoinDateMeta , eventTrackers , customNote , lastOnline , rankHistory , playerLevelOnJoining } );  -- 26 so far.
            break;
        end
    end
end

function GetGuildEventString ( index , playerName )
    -- index 1 = demote , 2 = promote , 3 = remove/quit , 4 = invite/join
    local result = "";
    local eventType = { "demote" , "promote" , "invite" , "join" , "quit" , "remove" };
    local player2 = "";
    
    if index == 1 or index == 2 then
        for i = GetNumGuildEvents() , 1 , -1 do
            local type , p1, p2 , rank = GetGuildEventInfo ( i );
            if eventType [ 1 ] == type or eventType [ 2 ] == type and p2 ~= nil and p2 == playerName then
                if index == 1 and eventType [ 1 ] == type then
                    result = p1 .. " DEMOTED " .. p2;
                    break;
                elseif index == 2 and eventType [ 2 ] == type then
                    result = p1 .. " PROMOTED " .. p2;
                    break;
                end
            end
        end
   elseif index == 3 then
        local notFound = true;
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 , rank = GetGuildEventInfo ( i );
            if eventType [ 5 ] == type or eventType [ 6 ] == type then   -- Quit or Remove
                if eventType [ 6 ] == type and p2 ~= nil and p2 == playerName then
                    result = p1 .. " KICKED " .. p2 .. " from the guild!";
                    notFound = false;
                elseif eventType [ 5 ] == type and p1 == playerName then
                    -- FOUND!
                    result = p1 .. " has Left the guild";
                    notFound = false;
                end
                if notFound ~= true then
                    break;
                end
            end
        end
    elseif index == 4 then
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 , rank = GetGuildEventInfo ( i );
            if eventType [ 3 ] == type and p2 ~= nil and p2 == playerName then   -- Quit or Remove
                result = p1 .. " INVITED " .. p2 .. " to the guild.";
                break;
            end
        end
    end

    return result;
end

-- Method:          AddLog(int , string)
-- What it Does:    Adds a simple array to the Logreport that includes the indexcode for color, and the included changes as a string
-- Purpose:         For ease in adding to the core log.
local function AddLog ( indexCode , logEntry )
  table.insert ( GR_LogReport_Save , { indexCode , logEntry } );
end

-- Method:          PrintLog(index)
-- What it Does:    Sets the color of the string to be reported to the frame (typically chat frame, or to the Log Report frame)
-- Purpose:         Color coding log and chat frame reporting.
local function PrintLog( index , logReport , LoggingIt ) -- 2D array index and logReport ?? 
    -- Which frame to send AddMessage
    local chat = DEFAULT_CHAT_FRAME;
    -- index of what kind of report, thus determining color
    if (index == 1) then -- Promoted
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage(logReport, 1.0, 0.914, 0.0);
        end
    elseif (index == 2) then -- Demoted
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage(logReport, 0.91, 0.388, 0.047);
        end
    elseif (index == 3) then -- Leveled
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage(logReport, 0.0, 0.44, .87);
        end
    elseif (index == 4) then -- Note
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 1.0, 0.6, 1.0);
        end
    elseif (index == 5) then -- Officer Note
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 1.0, 0.094, 0.93);
        end
    elseif (index == 6) then -- Rank Renamed
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 0.82, 0.106, 0.74);
        end
    elseif (index == 7) or (index == 8) then -- Join and Rejoin!
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 0.5, 1.0, 0);
        end
    elseif (index == 9) then -- WARNING BANNED PLAYER REJOIN!
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 1.0, 0, 0);
        end
    elseif (index == 10) then -- Left the guild
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 0.5, 0.5, 0.5);
        end
    elseif (index == 11) then -- Namechanged
        if LoggingIt then
            
        else
            chat:AddMessage(logReport, 0, 0.5, 255);
        end
    elseif (index == 12) then -- WHITE TEXT IGNORE RGB COLORING
        if LoggingIt then

        else
            chat:AddMessage(logReport,1.0,1.0,1.0);
        end
    elseif (index == 13) then -- Rejoining PLayer Custom Note Report
        if LoggingIt then

        else
            chat:AddMessage(logReport,0.4,0.71,0.9)
        end
    elseif (index == 14) then -- Player has returned from inactivity
        if LoggingIt then

        else
            chat:AddMessage(logReport,0,1.0,0.87);
        end
    elseif ( index == 15 ) then -- For event notifications like upcoming anniversaries.
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0 , 0.8 , 1.0 );
        end
    elseif (index == 99) then
        -- Addon Name Report Colors!
        
    end
end

-- Method:          FinalReport()
-- What it Does:    Organizes flow of final report and send it to chat frame and to the logReport.
-- Purpose:         Clean organization for presentation.
local function FinalReport()
    if #GR_AddonGlobals [ "TempNewMember" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempNewMember" ] do
            PrintLog ( GR_AddonGlobals [ "TempNewMember" ][i][1] , GR_AddonGlobals [ "TempNewMember" ][i][2] , GR_AddonGlobals [ "TempNewMember" ][i][3] );   -- Send to print to chat window
            AddLog ( GR_AddonGlobals [ "TempNewMember" ][i][4] , GR_AddonGlobals [ "TempNewMember" ][i][5] );                              -- Adding to the Log of Events
        end
    end

    if #GR_AddonGlobals [ "TempRejoin" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempRejoin" ] do
            PrintLog(GR_AddonGlobals [ "TempRejoin" ][i][1], GR_AddonGlobals [ "TempRejoin" ][i][2], GR_AddonGlobals [ "TempRejoin" ][i][3]);   -- Same Comments on down
            PrintLog(GR_AddonGlobals [ "TempRejoin" ][i][4], GR_AddonGlobals [ "TempRejoin" ][i][5], GR_AddonGlobals [ "TempRejoin" ][i][6]);
            if GR_AddonGlobals [ "TempRejoin" ][i][11] then
                PrintLog(GR_AddonGlobals [ "TempRejoin" ][i][12],GR_AddonGlobals [ "TempRejoin" ][i][13]);
            end
            AddLog(GR_AddonGlobals [ "TempRejoin" ][i][7],GR_AddonGlobals [ "TempRejoin" ][i][8]);
            AddLog(GR_AddonGlobals [ "TempRejoin" ][i][9],GR_AddonGlobals [ "TempRejoin" ][i][10]);
            if GR_AddonGlobals [ "TempRejoin" ][i][11] then
                AddLog(GR_AddonGlobals [ "TempRejoin" ][i][12],GR_AddonGlobals [ "TempRejoin" ][i][13]);
            end
        end
    end

    if #GR_AddonGlobals [ "TempBannedRejoin" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempBannedRejoin" ] do
            PrintLog(GR_AddonGlobals [ "TempBannedRejoin" ][i][1], GR_AddonGlobals [ "TempBannedRejoin" ][i][2], GR_AddonGlobals [ "TempBannedRejoin" ][i][3]);
            PrintLog(GR_AddonGlobals [ "TempBannedRejoin" ][i][4], GR_AddonGlobals [ "TempBannedRejoin" ][i][5], GR_AddonGlobals [ "TempBannedRejoin" ][i][6]);
            if GR_AddonGlobals [ "TempBannedRejoin" ][i][11] then
                PrintLog(GR_AddonGlobals [ "TempBannedRejoin" ][i][12],GR_AddonGlobals [ "TempBannedRejoin" ][i][13]);
            end
            AddLog(GR_AddonGlobals [ "TempBannedRejoin" ][i][7],GR_AddonGlobals [ "TempBannedRejoin" ][i][8]);
            AddLog(GR_AddonGlobals [ "TempBannedRejoin" ][i][9],GR_AddonGlobals [ "TempBannedRejoin" ][i][10]);
            if GR_AddonGlobals [ "TempBannedRejoin" ][i][11] then
                AddLog(GR_AddonGlobals [ "TempBannedRejoin" ][i][12],GR_AddonGlobals [ "TempBannedRejoin" ][i][13]);
            end
        end
    end

    if #GR_AddonGlobals [ "TempLeftGuild" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempLeftGuild" ] do
            PrintLog(GR_AddonGlobals [ "TempLeftGuild" ][i][1], GR_AddonGlobals [ "TempLeftGuild" ][i][2], GR_AddonGlobals [ "TempLeftGuild" ][i][3]); 
            AddLog(GR_AddonGlobals [ "TempLeftGuild" ][i][4],GR_AddonGlobals [ "TempLeftGuild" ][i][5]);                            
        end
    end

    if #GR_AddonGlobals [ "TempInactiveReturnedLog" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempInactiveReturnedLog" ] do
            PrintLog(GR_AddonGlobals [ "TempInactiveReturnedLog" ][i][1], GR_AddonGlobals [ "TempInactiveReturnedLog" ][i][2], GR_AddonGlobals [ "TempInactiveReturnedLog" ][i][3]);   
            AddLog(GR_AddonGlobals [ "TempInactiveReturnedLog" ][i][4],GR_AddonGlobals [ "TempInactiveReturnedLog" ][i][5]);                              
        end
    end

    if #GR_AddonGlobals [ "TempNameChanged" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempNameChanged" ] do
            PrintLog(GR_AddonGlobals [ "TempNameChanged" ][i][1], GR_AddonGlobals [ "TempNameChanged" ][i][2], GR_AddonGlobals [ "TempNameChanged" ][i][3]);   
            AddLog(GR_AddonGlobals [ "TempNameChanged" ][i][4],GR_AddonGlobals [ "TempNameChanged" ][i][5]);                              
        end
    end

    if #GR_AddonGlobals [ "TempLogPromotion" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempLogPromotion" ] do
            PrintLog(GR_AddonGlobals [ "TempLogPromotion" ][i][1], GR_AddonGlobals [ "TempLogPromotion" ][i][2], GR_AddonGlobals [ "TempLogPromotion" ][i][3]);   
            AddLog(GR_AddonGlobals [ "TempLogPromotion" ][i][4],GR_AddonGlobals [ "TempLogPromotion" ][i][5]);                              
        end
    end

    if #GR_AddonGlobals [ "TempLogDemotion" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempLogDemotion" ] do
            PrintLog(GR_AddonGlobals [ "TempLogDemotion" ][i][1], GR_AddonGlobals [ "TempLogDemotion" ][i][2], GR_AddonGlobals [ "TempLogDemotion" ][i][3]);
            AddLog(GR_AddonGlobals [ "TempLogDemotion" ][i][4],GR_AddonGlobals [ "TempLogDemotion" ][i][5]);                           
        end
    end

    if #GR_AddonGlobals [ "TempLogLeveled" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempLogLeveled" ] do
            PrintLog(GR_AddonGlobals [ "TempLogLeveled" ][i][1], GR_AddonGlobals [ "TempLogLeveled" ][i][2], GR_AddonGlobals [ "TempLogLeveled" ][i][3]);  
            AddLog(GR_AddonGlobals [ "TempLogLeveled" ][i][4],GR_AddonGlobals [ "TempLogLeveled" ][i][5]);                    
        end
    end

    if #GR_AddonGlobals [ "TempRankRename" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempRankRename" ] do
            PrintLog(GR_AddonGlobals [ "TempRankRename" ][i][1], GR_AddonGlobals [ "TempRankRename" ][i][2], GR_AddonGlobals [ "TempRankRename" ][i][3]);  
            AddLog(GR_AddonGlobals [ "TempRankRename" ][i][4],GR_AddonGlobals [ "TempRankRename" ][i][5]);                    
        end
    end

    if #GR_AddonGlobals [ "TempLogNote" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempLogNote" ] do
            PrintLog(GR_AddonGlobals [ "TempLogNote" ][i][1], GR_AddonGlobals [ "TempLogNote" ][i][2], GR_AddonGlobals [ "TempLogNote" ][i][3]);  
            AddLog(GR_AddonGlobals [ "TempLogNote" ][i][4],GR_AddonGlobals [ "TempLogNote" ][i][5]);                    
        end
    end

    if #GR_AddonGlobals [ "TempLogONote" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempLogONote" ] do
            PrintLog(GR_AddonGlobals [ "TempLogONote" ][i][1], GR_AddonGlobals [ "TempLogONote" ][i][2], GR_AddonGlobals [ "TempLogONote" ][i][3]);  
            AddLog(GR_AddonGlobals [ "TempLogONote" ][i][4],GR_AddonGlobals [ "TempLogONote" ][i][5]);                    
        end
    end

    if #GR_AddonGlobals [ "TempEventReport" ] > 0 then
        for i = 1,#GR_AddonGlobals [ "TempEventReport" ] do
            PrintLog(GR_AddonGlobals [ "TempEventReport" ][i][1], GR_AddonGlobals [ "TempEventReport" ][i][2], GR_AddonGlobals [ "TempEventReport" ][i][3]);  
            AddLog(GR_AddonGlobals [ "TempEventReport" ][i][4],GR_AddonGlobals [ "TempEventReport" ][i][5]);                    
        end
    end
    ResetTempLogs();
end  

-- Method           RecordChanges()
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
local function RecordChanges(indexOfInfo,memberInfo,memberOldInfo,guildName)
    local logReport = "";
    local tempLog = {};
    local chatframe = DEFAULT_CHAT_FRAME;
    -- 2 = Guild Rank Promotion
    if indexOfInfo == 2 then
        local tempString = GetGuildEventString ( 2 , memberInfo[1] );
        if tempString ~= nil and tempString ~= "" then
            logReport = string.format(GetTimestamp() .. " : " .. tempString .. " from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        else
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been PROMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        end
        table.insert ( GR_AddonGlobals [ "TempLogPromotion" ] , { 1 , logReport , false , indexOfInfo , logReport } );
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        local tempString = GetGuildEventString ( 1 , memberInfo[1] );
        if tempString ~= nil and tempString ~= "" then
            logReport = string.format(GetTimestamp() .. " : " .. tempString .. " from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        else
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been DEMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        end
        table.insert(GR_AddonGlobals [ "TempLogDemotion" ],{2,logReport,false,indexOfInfo,logReport});
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        if numGained > 1 then
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " levels)");
        else
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " level)");
        end
        table.insert(GR_AddonGlobals [ "TempLogLeveled" ],{3,logReport,false,indexOfInfo,logReport});
    -- 5 = note
    elseif indexOfInfo == 5 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s Note has Changed\nFrom:  " .. memberOldInfo[7] .. "\nTo:       " .. memberInfo[5]);
        table.insert(GR_AddonGlobals [ "TempLogNote" ],{4,logReport,false,indexOfInfo,logReport});
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s OFFICER Note has Changed\nFrom:  " .. memberOldInfo[8] .. "\nTo:       " .. memberInfo[6]);
        table.insert(GR_AddonGlobals [ "TempLogONote" ],{5,logReport,false,indexOfInfo,logReport});
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = string.format(GetTimestamp() .. " : Guild Rank Renamed from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        table.insert(GR_AddonGlobals [ "TempRankRename" ],{6,logReport,false,indexOfInfo,logReport});
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        local rejoin = false;
        local tempStringInv = GetGuildEventString ( 4 , memberInfo[1] ); -- For determining who did the invite.
        for i = 1,#GR_PlayersThatLeftHistory_Save do
            if (GR_PlayersThatLeftHistory_Save[i][1] == guildName) then -- guild Identified in position 'i'
                for j = 2,#GR_PlayersThatLeftHistory_Save[i] do -- Number of players that have left the guild.
                    if memberInfo[1] == GR_PlayersThatLeftHistory_Save[i][j][1] then 
                        -- MATCH FOUND - Player is RETURNING to the guild!
                        -- Now, let's see if the player was banned before!
                        local numTimesInGuild = #GR_PlayersThatLeftHistory_Save[i][j][20];
                        local numTimesString = "";
                        if numTimesInGuild > 1 then
                            numTimesString = string.format(memberInfo[1] .. " has Been in the Guild " .. numTimesInGuild .. " Times Before");
                        else
                            numTimesString = string.format(memberInfo[1] .. " is Returning for the First Time.");
                        end

                        local timeStamp = GetTimestamp();
                        if GR_PlayersThatLeftHistory_Save[i][j][17] == true then
                            -- Player was banned! WARNING!!!
                            local reasonBanned = GR_PlayersThatLeftHistory_Save[i][j][18];
                            if reasonBanned == nil or reasonBanned == "" then
                                reasonBanned = "<None Given>";
                            end
                            local warning = "";
                            if tempStringInv ~= nil and tempStringInv ~= "" then
                                warning = string.format( "     " .. timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. memberInfo[1] .. " has REJOINED the guild but was previously BANNED! \nInvited by: " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) );
                            else
                                warning = string.format( "     " .. timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. memberInfo[1] .. " has REJOINED the guild but was previously BANNED!");
                            end
                            logReport = string.format("     Date of Ban:                     " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nReason:                            " .. reasonBanned .. "\nDate Originally Joined:    " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:                " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            local custom = "";
                            local toReport = { 9 , warning , false , 12 , logReport , false , 9 , warning , 12 , logReport , false , 13 , custom };
                            -- Extra Custom Note added for returning players.
                            if GR_PlayersThatLeftHistory_Save[i][j][23] ~= "" then
                                custom = ("Notes:     " .. GR_PlayersThatLeftHistory_Save[i][j][23]);
                                toReport[11] = true;
                                toReport[13] = custom;
                            end
                            table.insert(GR_AddonGlobals [ "TempBannedRejoin" ],toReport);
                        else
                            -- No Ban found, player just returning!
                            if tempStringInv ~= nil and tempStringInv ~= "" then
                                logReport = string.format(timeStamp .. " : " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) .. " has REINVITED " .. memberInfo[1] .. " to the guild (LVL: " .. memberInfo[4] .. ")");
                            else
                                logReport = string.format(timeStamp .. " : " .. memberInfo[1] .. " has REJOINED the guild (LVL: " .. memberInfo[4] .. ")");
                            end
                            local custom = "";
                            local details = ("     Date Left:                        " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nDate Originally Joined:   " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:              " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            local toReport = {7,logReport,false,12,details,false,7,logReport,12,details,false,13,custom}
                            -- Extra Custom Note added for returning players.
                            if GR_PlayersThatLeftHistory_Save[i][j][23] ~= "" then
                                custom = ("Notes:     " .. GR_PlayersThatLeftHistory_Save[i][j][23]);
                                toReport[11] = true;
                                toReport[13] = custom;
                            end
                            table.insert ( GR_AddonGlobals [ "TempRejoin" ] , toReport );
                        end
                        rejoin = true;
                        -- AddPlayerTo MemberHistory
                        AddMemberRecord( memberInfo , true , GR_PlayersThatLeftHistory_Save[i][j] , guildName );

                        -- Adding timestamp to new Player.
                        if CustomizationGlobals [ "AddTimestampOnJoin" ] and CanEditOfficerNote() then
                            for h = 1,GetNumGuildies() do
                                local name,_,_,_,_,_,_,oNote = GetGuildRosterInfo( h );
                                if SlimName(name) == memberInfo[1] and oNote == "" then
                                    GuildRosterSetOfficerNote( h , ("Rejoined: " .. Trim ( strsub( GetTimestamp() , 1 , 10 ) ) ) );
                                    break;
                                end
                            end
                        end
                        -- Removing Player from LeftGuild History (Yes, they will be re-added upon leaving the guild.)
                        table.remove(GR_PlayersThatLeftHistory_Save[i], j);
                        break;
                    end
                end
                break;
            end
        end -- MemberHistory guild search
        if rejoin ~= true then
            -- New Guildie. NOT a rejoin!
            local timestamp = GetTimestamp();
            local timeEpoch = time();
            if tempStringInv ~= nil and tempStringInv ~= "" then
                logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has JOINED the guild! (LVL: " .. memberInfo[4] .. ") - Invited By: " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) );
            else
                logReport = string.format( timestamp .. " : " .. memberInfo[1] .. " has JOINED the guild! (LVL: " .. memberInfo[4] .. ")");
            end

            -- Adding to global saved array, adding to report 
            AddMemberRecord( memberInfo , false , nil , guildName );
            table.insert( GR_AddonGlobals [ "TempNewMember" ] , { 8 , logReport , false , 8 , logReport } );
           
            -- adding join date to history and rank date.
            for i = 1,#GR_GuildMemberHistory_Save do
                if (GR_GuildMemberHistory_Save[i][1] == guildName) then             -- guild Identified in position 'i'
                    for j = 2,#GR_GuildMemberHistory_Save[i] do                     -- Number of players that have left the guild.
                        if memberInfo[1] == GR_GuildMemberHistory_Save[i][j][1] then
                            GR_GuildMemberHistory_Save[i][j][12] = strsub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 );  -- Date of Last Promotion
                            GR_GuildMemberHistory_Save[i][j][13] = timeEpoch;                                                       -- Date of Last Promotion Epoch time.
                            table.insert ( GR_GuildMemberHistory_Save[i][j][20] , timestamp );
                            table.insert ( GR_GuildMemberHistory_Save[i][j][21] , timeEpoch );
                            -- For anniverary tracking!
                            GR_GuildMemberHistory_Save[i][j][22][1][2] = timestamp;
                            break;
                        end
                    end
                    break;
                end
            end

            -- Adding timestamp to new Player.
            if CustomizationGlobals [ "AddTimestampOnJoin" ] and CanEditOfficerNote() then
                for s = 1,GetNumGuildies() do
                    local name,_,_,_,_,_,_,oNote = GetGuildRosterInfo(s);
                    if SlimName(name) == memberInfo[1] and oNote == "" then
                        GuildRosterSetOfficerNote( s , ( "Joined: " .. Trim ( strsub( GetTimestamp() , 1 , 10 ) ) ) );
                        break;
                    end
                end
            end
        end
    -- 11 = Player Left  
    elseif indexOfInfo == 11 then
        local timestamp = GetTimestamp();
        local tempStringRemove = GetGuildEventString ( 3 , memberInfo[1] ); -- Kicked from the guild.
        if tempStringRemove ~= nil and tempStringRemove ~= "" then
            logReport = string.format( timestamp .. " : " .. tempStringRemove );
        else
            logReport = string.format( timestamp .. " : " .. memberInfo[1] .. " has Left the guild" );
        end
        table.insert( GR_AddonGlobals [ "TempLeftGuild" ] , { 10 , logReport , false , 10 , logReport } );
        -- Finding Player's record for removal of current guild and adding to the Left Guild table.
        for i = 1,#GR_GuildMemberHistory_Save do -- Scanning through guilds
            if guildName == GR_GuildMemberHistory_Save[i][1] then  -- Matching guild to index
                for j = 2,#GR_GuildMemberHistory_Save[i] do  -- Scanning through all entries
                    if memberInfo[1] == GR_GuildMemberHistory_Save[i][j][1] then -- Matching member leaving to guild saved entry
                        -- Found!
                        table.insert(GR_GuildMemberHistory_Save[i][j][15], timestamp );                                 -- leftGuildDate
                        table.insert(GR_GuildMemberHistory_Save[i][j][16], time());                                     -- leftGuildDateMeta
                        table.insert( GR_GuildMemberHistory_Save[i][j][25] , { "|CFFC41F3BLeft Guild" , Trim ( strsub ( timestamp , 1 , 10 ) ) } );
                        GR_GuildMemberHistory_Save[i][j][19] = GR_GuildMemberHistory_Save[i][j][4];                     -- oldRank on leaving.
                        if #GR_GuildMemberHistory_Save[i][j][20] == 0 then                                              -- Let it default to date addon was installed if date joined was never given
                            table.insert( GR_GuildMemberHistory_Save[i][j][20] , GR_GuildMemberHistory_Save[i][j][2] );     -- oldJoinDate
                            table.insert( GR_GuildMemberHistory_Save[i][j][21] , GR_GuildMemberHistory_Save[i][j][3]) ;     -- oldJoinDateMeta
                        end
                        -- Adding to LeftGuild Player history library
                        for r = 1, #GR_PlayersThatLeftHistory_Save do
                            if guildName == GR_PlayersThatLeftHistory_Save[r][1] then
                                -- Guild Position Identified.
                                table.insert( GR_PlayersThatLeftHistory_Save[r] , GR_GuildMemberHistory_Save[i][j] );
                                break;
                            end
                        end
                        -- Removing it from the alt list
                        if #GR_GuildMemberHistory_Save[i][j][11] > 0 then
                            RemoveAlt ( GR_GuildMemberHistory_Save[i][j][11][1][1] , GR_GuildMemberHistory_Save[i][j][1] , guildName );
                        end
                        -- removing from active member library
                        table.remove ( GR_GuildMemberHistory_Save[i] , j );
                        break;
                    end
                end
                break;
            end
        end
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        logReport = string.format(GetTimestamp() .. " : " .. memberOldInfo[1] .. " has Name-Changed to ".. memberInfo[1]);
        table.insert(GR_AddonGlobals [ "TempNameChanged" ],{ 11 , logReport , false , 11 , logReport });
    -- 13 = Inactive Members Return!
    elseif indexOfInfo == 13 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo .. " has Come ONLINE after being INACTIVE for " ..  HoursReport(memberOldInfo));
        table.insert(GR_AddonGlobals [ "TempInactiveReturnedLog" ],{14,logReport,false,14,logReport});
    end
end

-- Method:          ReportLastOnline(array)
-- What it Does:    Like the "CheckPlayerChanges()", this one does a one time scan on login or reload of notable changes of players who have returned from being offline for an extended period of time.
-- Purpose:         To inform the guild leader that a guildie who has not logged in in a while has returned!
local function ReportLastOnline(name,guildName,index)
    for i = 1,#GR_GuildMemberHistory_Save do                                    -- Scanning saved guilds
        if GR_GuildMemberHistory_Save[i][1] == guildName then                   -- Saved guild Found!
            for j = 2,#GR_GuildMemberHistory_Save[i] do                         -- Scanning through roster so can check changes (position 1 is guild name, so no need to rescan)
                if GR_GuildMemberHistory_Save[i][j][1] == name then             -- Player matched.
                    local hours = GetHoursSinceLastOnline(index);
                    if GR_GuildMemberHistory_Save[i][j][24] > CustomizationGlobals [ "InactiveMemberReturnsTimer" ] and GR_GuildMemberHistory_Save[i][j][24] > hours then  -- Player has logged in after having been inactive for greater than 2 weeks!
                        RecordChanges(13,name,GR_GuildMemberHistory_Save[i][j][24],guildName);      -- Recording the change in hours to log
                    end
                    GR_GuildMemberHistory_Save[i][j][24] = hours;                                   -- Set new hours since last login.
                    break;
                end
            end
        end
        break;
    end
end

-- Method:          CheckPlayerChanges(metaData)
-- What it Does:    Scans through guild roster and re-checks for any  (Will only fire if guild is found!)
-- Purpose:         Keep whoever uses the addon in the know instantly of what is going and changing in the guild.
local function CheckPlayerChanges(metaData,guildName)
    local newPlayerFound;
    local guildRankIndexIfChanged = -1; -- Rank index must start below zero, as zero is Guild Leader.

    -- new member and leaving members arrays to check at the end
    local newPlayers = {};
    local leavingPlayers = {};

    for i = 1,#GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            for j = 1,#metaData do
                newPlayerFound = true;
                for r = 2,#GR_GuildMemberHistory_Save[i] do -- Number of members in guild (Position 1 = guild name, so we skip)
                    if metaData[j][1] == GR_GuildMemberHistory_Save[i][r][1] then
                        newPlayerFound = false;
                        for k = 2,6 do
                            if (k ~= 3) and (metaData[j][k] ~= GR_GuildMemberHistory_Save[i][r][k+2]) then -- CHANGE FOUND! New info and old info are not equal!
                                -- Ranks
                                if (k == 2) and (metaData[j][3] ~= GR_GuildMemberHistory_Save[i][r][5]) and (metaData[j][2] ~= GR_GuildMemberHistory_Save[i][r][4]) then -- This checks to see if guild just changed the name of a rank.
                                    -- Promotion Obtained
                                    if metaData[j][3] < GR_GuildMemberHistory_Save[i][r][5] then
                                        RecordChanges(k,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                    -- Demotion Obtained
                                    elseif metaData[j][3] > GR_GuildMemberHistory_Save[i][r][5] then
                                        RecordChanges(9,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                    end
                                    
                                    local timestamp = GetTimestamp();
                                    GR_GuildMemberHistory_Save[i][r][4] = metaData[j][2]; -- Saving new rank Info
                                    GR_GuildMemberHistory_Save[i][r][5] = metaData[j][3]; -- Saving new rank Index Info
                                    GR_GuildMemberHistory_Save[i][r][12] = strsub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ) -- Time stamping rank change
                                    GR_GuildMemberHistory_Save[i][r][13] = time();
                                    table.insert ( GR_GuildMemberHistory_Save[i][r][25] , { GR_GuildMemberHistory_Save[i][r][4] , GR_GuildMemberHistory_Save[i][r][12] , GR_GuildMemberHistory_Save[i][r][13] } ); -- New rank, date, metatimestamp
                               
                                elseif (k == 2) and (metaData[j][2] ~= GR_GuildMemberHistory_Save[i][r][4]) and (metaData[j][3] == GR_GuildMemberHistory_Save[i][r][5]) then
                                    -- RANK RENAMED!
                                    if (guildRankIndexIfChanged ~= metaData[j][3]) then -- If alrady been reported, no need to report it again.
                                        RecordChanges(8,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                        guildRankIndexIfChanged = metaData[j][3]; -- Avoid repeat reporting for each member of that rank upon a namechange.
                                    end
                                    GR_GuildMemberHistory_Save[i][r][4] = metaData[j][2]; -- Saving new Info
                                    GR_GuildMemberHistory_Save[i][r][25][#GR_GuildMemberHistory_Save[i][r][25]][1] = metaData[j][2];   -- Adjusting the historical name if guild rank changes.
                                -- Level
                                elseif (k==4) then
                                    RecordChanges(k,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                    GR_GuildMemberHistory_Save[i][r][6] = metaData[j][4]; -- Saving new Info
                                -- Note
                                elseif (k==5) then
                                    RecordChanges(k,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                    GR_GuildMemberHistory_Save[i][r][7] = metaData[j][5];
                                -- Officer Note
                                elseif CanViewOfficerNote() and (k==6) then
                                    RecordChanges(k,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                    GR_GuildMemberHistory_Save[i][r][8] = metaData[j][6];
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
            for j = 2,#GR_GuildMemberHistory_Save[i] do
                playerLeftGuild = true;
                for k = 1,#metaData do
                    if GR_GuildMemberHistory_Save[i][j][1] == metaData[k][1] then
                        playerLeftGuild = false;
                        break;
                    end
                end
                -- PLAYER LEFT! (maybe)
                if playerLeftGuild then
                    leavingPlayers[#leavingPlayers + 1] = {};
                    leavingPlayers[#leavingPlayers] = GR_GuildMemberHistory_Save[i][j];
                end
            end
            -- Final check on players that left the guild to see if they are namechanges.
            local playerNotMatched = true;
            if #leavingPlayers > 0 and #newPlayers > 0 then
                for k = 1,#leavingPlayers do
                    for j = 1,#newPlayers do
                        if (leavingPlayers[k][7] == newPlayers[j][7]) -- Class is the sane
                            and (leavingPlayers[k][3] == newPlayers[j][3])  -- Guild Rank is the same
                                and (leavingPlayers[k][5] == newPlayers[j][5]) -- Player Note is the same
                                    and (leavingPlayers[k][6] == newPlayers[j][6]) then -- Officer Note is the same
                                        -- PLAYER IS A NAMECHANGE!!!
                                        playerNotMatched = false;
                                        RecordChanges(12,newPlayers[j],leavingPlayers[k],guildName);
                                        for r = 2,#GR_GuildMemberHistory_Save[i] do
                                            if (leavingPlayers[k][7] == GR_GuildMemberHistory_Save[i][r][9]) -- Mathching the Leaving player to historical index so it can be identified and new name stored.
                                                and (leavingPlayers[k][3] == GR_GuildMemberHistory_Save[i][r][5])
                                                and (leavingPlayers[k][5] == GR_GuildMemberHistory_Save[i][r][7])
                                                and (leavingPlayers[k][6] == GR_GuildMemberHistory_Save[i][r][8]) then
                                                GR_GuildMemberHistory_Save[i][r][1] = leavingPlayers[k][1];
                                                break
                                            end
                                        end
                                        -- since namechange identified, also need to remove name from newPlayers array now.
                                        if #newPlayers == 1 then
                                            newPlayers = {}; -- Clears the array of the one name.
                                        else
                                            local tempArray = {};
                                            local count = 1;
                                            for r = 1,#newPlayers do -- removing the namechange from newPlayers list.
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
                        RecordChanges(11,leavingPlayers[k],leavingPlayers[k],guildName);

                        for r = 2,#GR_GuildMemberHistory_Save[i] do
                            if GR_GuildMemberHistory_Save[i][r][1] == leavingPlayers[k][1] then -- Player matched to Leaving Players
                                for s = 1, #GR_PlayersThatLeftHistory_Save do                   -- Cycling through the guilds of Left Players.
                                    if GR_GuildMemberHistory_Save[s][1] == guildName then       -- Matching Leaving Player to proper guild table position
                                        table.insert(GR_PlayersThatLeftHistory_Save[s],GR_GuildMemberHistory_Save[i][r]); -- Adding Leaving Player to proper guild Leaving table
                                        break;
                                    end
                                end

                                -- Removing it from the alt list
                                if #GR_GuildMemberHistory_Save[i][r][11] > 0 then
                                    RemoveAlt ( GR_GuildMemberHistory_Save[i][r][11][1][1] , GR_GuildMemberHistory_Save[i][r][1] , guildName );
                                end
                                
                                table.remove(GR_GuildMemberHistory_Save[i],r); -- Removes Player from the Current Guild Roster
                                break;
                            end
                        end
                    end
                end
            elseif #leavingPlayers > 0 then
                for k = 1,#leavingPlayers do
                    RecordChanges(11,leavingPlayers[k],leavingPlayers[k],guildName);
                    for r = 2,#GR_GuildMemberHistory_Save[i] do
                        if GR_GuildMemberHistory_Save[i][r][1] == leavingPlayers[k][1] then -- Player matched to Leaving Players
                            for s = 1, #GR_PlayersThatLeftHistory_Save do                   -- Cycling through the guilds of Left Players.
                                if GR_GuildMemberHistory_Save[s][1] == guildName then       -- Matching Leaving Player to proper guild table position
                                    table.insert(GR_PlayersThatLeftHistory_Save[s],GR_GuildMemberHistory_Save[i][r]); -- Adding Leaving Player to proper guild Leaving table
                                    break;
                                end
                            end

                            -- Removing it from the alt list
                            if #GR_GuildMemberHistory_Save[i][r][11] > 0 then
                                RemoveAlt ( GR_GuildMemberHistory_Save[i][r][11][1][1] , GR_GuildMemberHistory_Save[i][r][1] , guildName );
                            end

                            table.remove(GR_GuildMemberHistory_Save[i],r); -- Removes Player from the Current Guild Roster
                            break;
                        end
                    end
                end
            end
            if #newPlayers > 0 then
                for k = 1,#newPlayers do
                    RecordChanges(10,newPlayers[k],newPlayers[k],guildName);
                end
            end
        end
    end
end

-- Method:          BuildNewRoster()
-- What it does:    Rebuilds the roster to check against for any changes.
-- Purpose:         To track for guild changes of course!
local function BuildNewRoster()
    local roster = {};
    local guildName = GetGuildInfo("player"); -- Guild Name

    -- Checking if Guild Found or Not Found, to pre-check for Guild name tag.
    local guildNotFound = true;
    for i = 1,#GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            guildNotFound = false;
            break;
        end
    end

    for i = 1,GetNumGuildies() do
        local name, rank, rankInd, level, _, _, note, officerNote, _, _, class = GetGuildRosterInfo(i); 
        local slim = SlimName(name);
        roster[i] = {};
        roster[i][1] = slim
        roster[i][2] = rank;
        roster[i][3] = rankInd;
        roster[i][4] = level;
        roster[i][5] = note;
        if CanViewOfficerNote() then -- Officer Note permission to view.
            roster[i][6] = officerNote;
        else
            roster[i][6] = i; -- Set Officer note to unique index position of player in array if unable to view.
        end

        roster[i][7] = class;
        roster[i][8] = GetHoursSinceLastOnline ( i ); -- Time since they last logged in in hours.

        -- Items to check One time check on login
        -- Check players who have not been on a long time only on login or addon reload.
        if guildNotFound ~= true then
            ReportLastOnline ( slim , guildName , i );
        end

    end
    
    -- Build Roster for the first time if guild not found.
    if guildNotFound then
        print("Analyzing guild for the first time");
        table.insert(GR_GuildMemberHistory_Save,{guildName}); -- Creating a position in table for Guild Member Data
        table.insert(GR_PlayersThatLeftHistory_Save,{guildName}); -- Creating a position in Left Player Table for Guild Member Data
        for i = 1,#roster do
            -- Add last time logged in initial timestamp.
            AddMemberRecord(roster[i],false,nil,guildName);
            for r = 1,#GR_GuildMemberHistory_Save do                                                    -- identifying guild
                if GR_GuildMemberHistory_Save[r][1] == guildName then                                   -- Guild found!
                    GR_GuildMemberHistory_Save[r][#GR_GuildMemberHistory_Save[1]][24] = roster[i][8];  -- Setting Timestamp for the first time only.
                end
                break;
            end
        end

    else -- Check over changes!
        CheckPlayerChanges ( roster , guildName );
        -- CheckPlayerEvents ( guildName );
    end
end


--------------------------------------
------ END OF METADATA LOGIC ---------
--------------------------------------


--------------------------------------
------ MISC METHODS AND LOGIC --------
--------------------------------------

-- Method:          IsGuildieInSameGroup ( string )  -- proper format of the name should be "PlayerName-ServerName"
-- What it Does:    Returns true if the given guildie is grouped with you.
-- Purpose:         To determine if you are grouped with a guildie!
local function IsGuildieInSameGroup ( guildMember )
    local result = false;
    for i = 1 , GetNumGroupMembers() do
        local raidPlayer = GetRaidRosterInfo ( i );
        if raidPlayer == guildMember then
            result = true;
            break;
        end
    end
    return result;
end

-- Method:          GetGroupUnitsOfflineOrAFK()
-- What it Does:    Returns a 2D array of the names of the players (not including server names) that are offline and afk in group
-- Purpose:         Mainly to notify the group leader who is AFK, possibly to make room for others in raid by informing leader of offline members.
local function GetGroupUnitsOfflineOrAFK ()
    local offline = {};
    local afkMembers = {};
    
    for i = 1 , GetNumGroupMembers() do
        local raidPlayer , _ , _ , _ , _ , _ , _ , isOnline = GetRaidRosterInfo ( i );
        if isOnline ~= true then
            table.insert ( offline , SlimName ( raidPlayer ) );
        end
        if isOnline and UnitIsAFK( raidPlayer ) then
            table.insert ( afkMembers , SlimName ( raidPlayer ) );
        end        
    end
    local result = { offline , afkMembers };
    return result;
end


-- EVENT TRACKING!!!!!

function GetEventYear ( timestamp )
    -- timestamp format = "Day month year hour min"
    local count = 0;
    local result = "";
    if timestamp ~= "" and timestamp ~= nil then
        for i = 1 , #timestamp do
            if string.sub ( timestamp , i , i ) == " " then
                count = count + 1;
            end
            if count == 2 then
                result = result .. "20" .. string.sub ( timestamp , i + 2 , i + 4);
                break;
            end
        end
    end
    return result;
end

local function GetEventMonth ( timestamp )
    if timestamp == "" or timestamp == nil then
        return "";
    else
        return string.sub ( timestamp , string.find ( timestamp , " " ) + 1 , string.find ( timestamp , " " ) + 3 );
    end
end

local function GetEventDay ( timestamp )
    if timestamp == "" or timestamp == nil then
        return "";
    else
        return string.sub ( timestamp , 1 , string.find ( timestamp , " " ) - 1 );
    end
end

local function IsCalendarEventAlreadyAdded ( eventName , year , month , day )
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

local function IsOnAnnouncementList ( name , title )
    local result = false;
    for i = 1 , #GR_CalendarAddQue_Save do
        if GR_CalendarAddQue_Save[i][1] == name and GR_CalendarAddQue_Save[i][2] == title then
            result = true;
            break;
        end
    end
    return result;
end

local function RemoveFromCalenderQue ( name , title )
    for i = 1 , #GR_CalendarAddQue_Save do
        if GR_CalendarAddQue_Save[i][1] == name and GR_CalendarAddQue_Save[i][2] == title then
            table.remove ( GR_CalendarAddQue_Save , i );
            break;
        end
    end
end

local function CheckPlayerEvents ( guildName )
    -- including anniversary, birthday , and custom
    local time = date("*t");

    for i = 1 , #GR_GuildMemberHistory_Save do
        if GR_GuildMemberHistory_Save[i][1] == guildName then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do
                -- Player identified, now let's check his event info!
                for r = 1 , #GR_GuildMemberHistory_Save[i][j][22] do          -- Loop all events!
                    local eventMonth = GetEventMonth ( GR_GuildMemberHistory_Save[i][j][22][r][2] );
                    local eventMonthIndex = monthEnum [ eventMonth ];
                    local eventDay = tonumber ( GetEventDay ( GR_GuildMemberHistory_Save[i][j][22][r][2] ) );
                    local eventYear = tonumber ( GetEventYear ( GR_GuildMemberHistory_Save[i][j][22][r][2] ) );
                    local logReport = "";
                    
                    if GR_GuildMemberHistory_Save[i][j][22][r][2] ~= nil and GR_GuildMemberHistory_Save[i][j][22][r][3] ~= true and ( time.month == eventMonthIndex or time.month + 1 == eventMonthIndex ) then        -- if it has already been reported, then we are good!
                        local daysTil = eventDay - time.day;
                        local daysLeftInMonth = daysInMonth [ tostring ( time.month ) ] - time.day;
                        if time.month == 2 and IsLeapYear ( time.year ) then
                            daysLeftInMonth = daysLeftInMonth + 1;
                        end
                                  
                        if ( ( time.month == eventMonthIndex and daysTil >= 0 and daysTil <= CustomizationGlobals [ "DaysInAdvanceForEventNotify" ] ) or 
                                ( time.month + 1 == eventMonthIndex and ( eventDay + daysLeftInMonth <= CustomizationGlobals [ "DaysInAdvanceForEventNotify" ] ) ) ) then

                            -- SAME MONTH!
                            -- Join Date Anniversary
                            if r == 1 then
                                local numYears = time.year - eventYear;
                                if numYears == 0 then
                                    numYears = 1;
                                end
                                if numYears == 1 then
                                    logReport = string.format ( GR_GuildMemberHistory_Save[i][j][1] .. " will be celebrating " .. numYears .. " year in the Guild! ( " .. string.sub ( GR_GuildMemberHistory_Save[i][j][22][r][2] , 0 , string.find ( GR_GuildMemberHistory_Save[i][j][22][r][2] , " " ) + 3 ) .. " )"  );
                                else
                                    logReport = string.format ( GR_GuildMemberHistory_Save[i][j][1] .. " will be celebrating " .. numYears .. " years in the Guild! ( " .. string.sub ( GR_GuildMemberHistory_Save[i][j][22][r][2] , 0 , string.find ( GR_GuildMemberHistory_Save[i][j][22][r][2] , " " ) + 3 ) .. " )"  );
                                end
                                table.insert ( GR_AddonGlobals [ "TempEventReport" ] , { 15 , logReport , false , 15 , logReport } );
                            
                            elseif r == 2 then
                            -- BIRTHDAY!

                            else
                            -- MISC EVENT!
                            
                            end

                            -- Now, let's add it to the calendar!
                            
                            if CalendarCanAddEvent() and CustomizationGlobals.AutoSetCalendarEvents then
                                local year = time.year;
                                if time.month == 12 and eventMonthIndex == 1 then
                                    year = year + 1;
                                end 

                                -- 
                                local isAddedAlready = IsCalendarEventAlreadyAdded (  GR_GuildMemberHistory_Save[i][j][22][r][1] , year , eventMonthIndex , eventDay  );
                                   if not isAddedAlready and not IsOnAnnouncementList ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] ) then
                                    table.insert ( GR_CalendarAddQue_Save , { GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] , eventMonthIndex , eventDay , year , string.sub ( logReport , 1 , #logReport - 11 ) } );
                                end
                            end
                            -- This has been reported, save it!
                            GR_GuildMemberHistory_Save[i][j][22][r][3] = true;
                        end                  
                        
                    -- Resetting the event report to false if parameters meet
                    elseif GR_GuildMemberHistory_Save[i][j][22][r][3] then                                                   -- It is still true! Event has been reported! Let's check if time has passed sufficient to wipe it to false
                        if ( time.month == eventMonthIndex and eventDay - time.day < 0 ) or ( time.month > eventMonthIndex  ) or ( eventMonthIndex - time.month > 1 ) then     -- Event is behind us now
                            GR_GuildMemberHistory_Save[i][j][22][r][3] = false;
                            if IsOnAnnouncementList ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] ) then
                                RemoveFromCalenderQue ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] );
                            end
                        elseif time.month == eventMonthIndex and eventDay - time.day > CustomizationGlobals [ "DaysInAdvanceForEventNotify" ] then      -- Setting back to false;
                            GR_GuildMemberHistory_Save[i][j][22][r][3] = false;
                            if IsOnAnnouncementList ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] ) then
                                RemoveFromCalenderQue ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] );
                            end
                        elseif time.month + 1 == eventMonthIndex then
                            local daysLeftInMonth = daysInMonth [ tostring ( time.month ) ] - time.day;
                            if time.month == 2 and IsLeapYear ( time.year ) then
                                daysLeftInMonth = daysLeftInMonth + 1;
                            end
                            if eventDay + daysLeftInMonth > CustomizationGlobals [ "DaysInAdvanceForEventNotify" ] then
                                GR_GuildMemberHistory_Save[i][j][22][r][3] = false;
                                if IsOnAnnouncementList ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] ) then
                                    RemoveFromCalenderQue ( GR_GuildMemberHistory_Save[i][j][1] , GR_GuildMemberHistory_Save[i][j][22][r][1] );
                                end
                            end
                        end
                    end
                end
            end
            break;
        end
    end
end

local function AddAnnouncementToCalendar ( name , eventMonthIndex , eventDay , year , title , description )
    CalendarCloseEvent(); -- Just in case previous event was never closed, either by other addons or by player
    local hour = 0;     -- 24hr scale, on when to add it...
    local min = 5;
    if eventMonthIndex == time.month and eventDay == time.Day then      -- Add current time now!
        hour , min = GetGameTime();
    end

    CalendarNewGuildAnnouncement();
    CalendarEventSetDate ( eventMonthIndex , eventDay , year );
    CalendarEventSetTitle ( title );
    CalendarEventSetDescription ( description ); -- No need to include the date at the end.
    CalendarEventSetTime ( hour , min );    
    CalendarEventSetType ( 5 );
    CalendarAddEvent();
    CalendarCloseEvent();

end

local function GetPlayerJoinAnniversary( playerName , guildName )

end

local function DaysTilJoinAnniiversary( playerName , guildName )

end

local function HasAnniversaryBeenReported( playerName , guildName )

end

local function SetReminder ( eventName , daysRemind )
    -- 1 = "joinData" , 2 == "birthday" , 3 == "Anything"
end

local function CreateCustomReminder ( title , data , daysRemind )

end

local function SetCalendarReminder ( playerName , guildName , eventName )

end

local function RemoveCalendarReminder ( playerName , guildName , eventName )

end

local function CheckUpcomingReminders ( playerName , guildName )

end



------------------------------------
---- BEGIN OF FRAME LOGIC ----------
---- General Framebuild Methods ----
------------------------------------


-- Method:          OnDropMenuClickDay(self)
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
local function OnDropMenuClickDay ( self )
    local index = self:GetID();
    GR_AddonGlobals [ "dayIndex" ] = index;
    UIDropDownMenu_SetSelectedID ( DayDropDownMenu , index );
end

-- Method:          OnDropMenuClicOnDropMenuClickYearkMonth(self)
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for year based drop down menu.
local function OnDropMenuClickYear ( self )
    UIDropDownMenu_SetSelectedID ( YearDropDownMenu , self:GetID() );
    GR_AddonGlobals [ "yearIndex" ] = tonumber(self:GetText());
end

-- Method:          OnDropMenuClickMonth(self)
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
local function OnDropMenuClickMonth ( self )
    local index = self:GetID();
    GR_AddonGlobals [ "monthIndex" ] = index;
    UIDropDownMenu_SetSelectedID ( MonthDropDownMenu , index );
end

local function InitializeDropDownDay ( self , level )
    local shortMonth = 30;
    local longMonth = 31;
    local febMonth = 28;
    local leapYear = 29;
    
    local yearDate = 0;
    yearDate = GR_AddonGlobals [ "yearIndex" ];
    local isDateALeapyear = IsLeapYear(yearDate);
    local numDays;
    
    if GR_AddonGlobals [ "monthIndex" ] == 1 or GR_AddonGlobals [ "monthIndex" ] == 3 or GR_AddonGlobals [ "monthIndex" ] == 5 or GR_AddonGlobals [ "monthIndex" ] == 7 or GR_AddonGlobals [ "monthIndex" ] == 8 or GR_AddonGlobals [ "monthIndex" ] == 10 or GR_AddonGlobals [ "monthIndex" ] == 12 then
        numDays = longMonth;
    elseif GR_AddonGlobals [ "monthIndex" ] == 2 and isDateALeapyear then
        numDays = leapYear;
    elseif GR_AddonGlobals [ "monthIndex" ] == 2 then
        numDays = febMonth;
    else
        numDays = shortMonth;
    end
    
    for i = 1 , numDays do
        local day = UIDropDownMenu_CreateInfo();
        day.text = i;
        day.func = OnDropMenuClickDay;
        if numDays == 29 and i == 29 then
            -- Leap Year!
            day.tooltipTitle = "If player anniversary is on a leap year, March 1st will be normal Anniversary date!";
            day.tooltipOnButton = true;
        else
            day.tooltipTitle = "If day is unknown, just leave at default '1'";
            day.tooltipOnButton = true;
        end
        UIDropDownMenu_AddButton ( day );
    end
end

-- Method:          InitializeDropDownYear(self,level)
-- What it Does:    Initializes the year select drop-down OnDropMenuClick
-- Purpose:         Easy way to set when player joined the guild.         
local function InitializeDropDownYear ( self , level )
    -- Year Drop Down
    local _,_,_,currentYear = CalendarGetDate();
    local yearStamp = currentYear; 
    for i = 1 , ( currentYear - 2003 ) do               -- 2004 is when Warcraft Launched, so this will be earliest possible join year. (2003 is giveb due to index logic + 1)
        local year = UIDropDownMenu_CreateInfo();       -- Creating template to be added
        year.text = yearStamp;                          -- Year Stamp, descending order to be added
        year.func = OnDropMenuClickYear;                    -- Selects the Item and makes it main selection
        year.tooltipTitle = "Select Year";              -- Mouseover Tooltip text
        year.tooltipOnButton = true;                    -- Initializes the tooltip
        UIDropDownMenu_AddButton ( year );              -- Adding the dropdown UI Button to select.
        yearStamp = yearStamp - 1                       -- Descending the year by 1
    end;
end

-- Method:          InitializeDropDownMonth(self,level)
-- What it Does:    Initializes month drop select menu
-- Purpose:         Date select for Officer Note "Join Date"
local function InitializeDropDownMonth ( self , level )
    -- Month Drop Down
    local months = {"January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December"};
    for i = 1 , #months do
        local month = UIDropDownMenu_CreateInfo();
        month.text = months[i];
        month.func = OnDropMenuClickMonth;
        month.tooltipTitle = "Select Month";
        month.tooltipOnButton = true;
        UIDropDownMenu_AddButton ( month );
    end

end

local function SetJoinDate ( _ , button , down )
    local name = GR_MemberDetailName:GetText();
    local dayJoined = UIDropDownMenu_GetSelectedID ( DayDropDownMenu );
    local monthJoined = UIDropDownMenu_GetSelectedID ( MonthDropDownMenu );
    local yearJoined = tonumber( UIDropDownMenu_GetText ( YearDropDownMenu ) );
    local isLeapYearSelected = IsLeapYear ( yearJoined );
    local buttonText = GR_DateSubmitButtonTxt:GetText();

    if IsValidSubmitDate ( dayJoined , monthJoined , yearJoined, isLeapYearSelected ) then
        local guildName = GetGuildInfo("player");
        local rankButton = false;
        for j = 1,#GR_GuildMemberHistory_Save do
            if GR_GuildMemberHistory_Save[j][1] == guildName then
                for r = 2,#GR_GuildMemberHistory_Save[j] do
                    if GR_GuildMemberHistory_Save[j][r][1] == name then

                        local joinDate = ( "Joined: " .. dayJoined .. " " ..  strsub ( UIDropDownMenu_GetText ( MonthDropDownMenu ) , 1 , 3 ) .. " '" ..  strsub ( UIDropDownMenu_GetText ( YearDropDownMenu ) , 3 ) );
                        local finalTimeStamp = ( strsub ( joinDate , 9) .. " 12:01am" );
                        local finalEpochStamp = TimeStampToEpoch ( joinDate );
                        
                        if buttonText == "Edit Join Date" then
                            table.remove ( GR_GuildMemberHistory_Save[j][r][20] , #GR_GuildMemberHistory_Save[j][r][20] );  -- Removing previous instance to replace
                            table.remove ( GR_GuildMemberHistory_Save[j][r][21] , #GR_GuildMemberHistory_Save[j][r][21] );
                        end
                        table.insert( GR_GuildMemberHistory_Save[j][r][20] , finalTimeStamp );     -- oldJoinDate
                        table.insert( GR_GuildMemberHistory_Save[j][r][21] , finalEpochStamp ) ;   -- oldJoinDateMeta
                        GR_GuildMemberHistory_Save[j][r][2] = finalTimeStamp;
                        GR_GuildMemberHistory_Save[j][r][3] = finalEpochStamp;
                        GR_JoinDateText:SetText ( strsub ( joinDate , 9 ) );

                        -- Gotta update the event tracker date too!
                        GR_GuildMemberHistory_Save[j][r][22][1][2] = strsub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                        GR_GuildMemberHistory_Save[j][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!

                        if GR_GuildMemberHistory_Save[j][r][12] == nil then
                            rankButton = true;
                        end
                    break;
                    end
                end
                break;
            end
        end
        DayDropDownMenu:Hide();
        MonthDropDownMenu:Hide();
        YearDropDownMenu:Hide();
        DateSubmitCancelButton:Hide();
        DateSubmitButton:Hide();
        GR_JoinDateText:Show();
        if rankButton then
            SetPromoDateButton:Show();
        else
            GR_MemberDetailRankDateTxt:Show();
        end
    end
    GR_AddonGlobals [ "pause" ] = false;
end

local function SetPromoDate ( _ , button , down )
    local name = GR_MemberDetailName:GetText();
    local dayJoined = UIDropDownMenu_GetSelectedID ( DayDropDownMenu );
    local monthJoined = UIDropDownMenu_GetSelectedID ( MonthDropDownMenu );
    local yearJoined = tonumber( UIDropDownMenu_GetText ( YearDropDownMenu ) );
    local isLeapYearSelected = IsLeapYear ( yearJoined );

    if IsValidSubmitDate ( dayJoined , monthJoined , yearJoined, isLeapYearSelected ) then
        local guildName = GetGuildInfo("player");
        
        for j = 1,#GR_GuildMemberHistory_Save do
            if GR_GuildMemberHistory_Save[j][1] == guildName then
                for r = 2,#GR_GuildMemberHistory_Save[j] do
                    if GR_GuildMemberHistory_Save[j][r][1] == name then
                        local promotionDate = ( "Joined: " .. dayJoined .. " " ..  strsub ( UIDropDownMenu_GetText ( MonthDropDownMenu ) , 1 , 3 ) .. " '" ..  strsub ( UIDropDownMenu_GetText ( YearDropDownMenu ) , 3 ) );
                        
                        GR_GuildMemberHistory_Save[j][r][12] = strsub ( promotionDate , 9 );
                        GR_GuildMemberHistory_Save[j][r][25][#GR_GuildMemberHistory_Save[j][r][25]][2] = strsub ( promotionDate , 9 );
                        GR_GuildMemberHistory_Save[j][r][13] = TimeStampToEpoch ( promotionDate );

                        if GR_AddonGlobals [ "rankIndex" ] > GR_AddonGlobals [ "playerIndex" ] then
                            GR_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -82 ); -- slightly varied positioning due to drop down window or not.
                        else
                            GR_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -70 );
                        end
                        GR_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
                        GR_MemberDetailRankDateTxt:SetText ( "PROMOTED: " .. Trim ( strsub ( GR_GuildMemberHistory_Save[j][r][12] , 1 , 10) ) );
                        break;
                    end
                end
                break;
            end
        end
        DayDropDownMenu:Hide();
        MonthDropDownMenu:Hide();
        YearDropDownMenu:Hide();
        DateSubmitCancelButton:Hide();
        DateSubmitButton:Hide();
        GR_MemberDetailRankDateTxt:Show();
    end
    GR_AddonGlobals [ "pause" ] = false;
end

-- Method:          SetDateSelectFrame( string , frameObject, string )
-- What it Does:    On Clicking the "Set Join Date" button this logic presents itself
-- Purpose:         Handle the event to modify when a player joined the guild. This is useful for anniversary date tracking.
--                  It is also necessary because upon starting the addon, it is unknown a person's true join date. This allows the gleader to set a general join date.
local function SetDateSelectFrame ( fposition, frame, buttonName )
    local _,month,_,currentYear = CalendarGetDate();
    local xPosMonth,yPosMonth,xPosDay,yPosDay,xPosYear,yPosYear,xPosSubmit,yPosSubmit,xPosCancel,yPosCancel = 0;        -- Default position.
    local joinDateText = "Set Join Date";
    local promoDateText = "Set Promo Date";
    local editDateText = "Edit Promo Date";
    local editJoinText = "Edit Join Date";
    local timeEnum = date ( "*t" );
    local currentDay = timeEnum [ "day" ];
    local buttonText = GR_DateSubmitButtonTxt:GetText();

    -- Month
    UIDropDownMenu_Initialize ( MonthDropDownMenu , InitializeDropDownMonth );
    UIDropDownMenu_SetWidth ( MonthDropDownMenu , 83 );
    UIDropDownMenu_SetSelectedID ( MonthDropDownMenu , month )
    GR_AddonGlobals [ "monthIndex" ] = month;
    
    -- Year
    UIDropDownMenu_Initialize ( YearDropDownMenu, InitializeDropDownYear );
    UIDropDownMenu_SetWidth ( YearDropDownMenu , 53 );
    UIDropDownMenu_SetSelectedID ( YearDropDownMenu , 1 );
    GR_AddonGlobals [ "yearIndex" ] = currentYear;
    
    -- Initialize the day choice now.
    UIDropDownMenu_Initialize ( DayDropDownMenu , InitializeDropDownDay );
    UIDropDownMenu_SetWidth ( DayDropDownMenu , 40 );
    UIDropDownMenu_SetSelectedID ( DayDropDownMenu , currentDay );
    GR_AddonGlobals [ "dayIndex" ] = 1;
    
    -- Script Handlers
    local function CancelButtonScript ( _ , button )
        if button == "LeftButton" then
            MonthDropDownMenu:Hide();
            YearDropDownMenu:Hide();
            DayDropDownMenu:Hide();
            DateSubmitButton:Hide();
            DateSubmitCancelButton:Hide();

            -- Determine which information needs to repopulate.
            if joinDateText == buttonText or editJoinText == buttonText then
                if buttonText == editJoinText then
                    GR_JoinDateText:Show();
                else
                    MemberDetailJoinDateButton:Show();
                end
                --RANK PROMO DATE
                if GR_AddonGlobals [ "rankDateSet" ] == false then      --- Promotion has never been recorded!
                    GR_MemberDetailRankDateTxt:Hide();                     
                    SetPromoDateButton:Show();
                else
                    GR_MemberDetailRankDateTxt:Show();
                end
            elseif buttonText == promoDateText then
                SetPromoDateButton:Show();
            elseif buttonText == editDateText then
                GR_MemberDetailRankDateTxt:Show();
            end
            GR_AddonGlobals [ "pause" ] = false;
        end
    end

    DateSubmitCancelButton:SetScript("OnClick" , CancelButtonScript );

    if buttonName == "PromoRank" then
        
        -- Change this button
        GR_DateSubmitButtonTxt:SetText ( promoDateText );
        DateSubmitButton:SetScript("OnClick" , SetPromoDate );
        
        xPosDay = -82;
        yPosDay = -80;
        xPosMonth = -6;
        yPosMonth = -80;
        xPosYear = 77;
        yPosYear = -80
        xPosSubmit = -37;
        yPosSubmit = -106;
        xPosCancel = 37;
        yPosCancel = -106;

    elseif buttonName == "JoinDate" then

        GR_DateSubmitButtonTxt:SetText ( joinDateText );
        DateSubmitButton:SetScript("OnClick" , SetJoinDate );
        
        xPosDay = -82;
        yPosDay = -80;
        xPosMonth = -6;
        yPosMonth = -80;
        xPosYear = 77;
        yPosYear = -80
        xPosSubmit = -37;
        yPosSubmit = -106;
        xPosCancel = 37;
        yPosCancel = -106;
    end

    MonthDropDownMenu:SetPoint ( fposition , frame , xPosMonth , yPosMonth );
    YearDropDownMenu:SetPoint ( fposition , frame , xPosYear , yPosYear );
    DayDropDownMenu:SetPoint ( fposition , frame , xPosDay , yPosDay );
    DateSubmitButton:SetPoint ( fposition , frame , xPosSubmit , yPosSubmit );
    DateSubmitCancelButton:SetPoint ( fposition , frame , xPosCancel , yPosCancel );

    -- Show all Frames
    MonthDropDownMenu:Show();
    YearDropDownMenu:Show();
    DayDropDownMenu:Show();
    DateSubmitButton:Show();
    DateSubmitCancelButton:Show();
end

local function OnRankDropMenuClick ( self )
    local rankIndex2 = self:GetID();
    local currentRankIndex = UIDropDownMenu_GetSelectedID( guildRankDropDownMenu );

    if ( rankIndex2 > currentRankIndex and CanGuildDemote() ) or ( rankIndex2 < currentRankIndex and CanGuildPromote() ) then
        local numRanks = GuildControlGetNumRanks();
        local numChoices = (numRanks - GR_AddonGlobals [ "playerIndex" ] - 1);
        local solution = rankIndex2 + numRanks - numChoices;
        local guildName = GetGuildInfo("player");

        UIDropDownMenu_SetSelectedID ( guildRankDropDownMenu , rankIndex2 );
            
        for i = 1 , GetNumGuildies() do
            local name = GetGuildRosterInfo ( i );
            
            if SlimName ( name ) == GR_AddonGlobals [ "tempName" ] then
                SetGuildMemberRank ( i , solution );
                -- Now, let's make the changes immediate for the button date.
                if SetPromoDateButton:IsVisible() then
                    SetPromoDateButton:Hide();
                    GR_MemberDetailRankDateTxt:SetText ( "PROMOTED: " .. Trim ( strsub(GetTimestamp() , 1 , 10 ) ) );
                    GR_MemberDetailRankDateTxt:Show();
                end
                GR_AddonGlobals [ "pause" ] = false;
                break;
            end
        end
    elseif rankIndex2 > currentRankIndex and CanGuildDemote() ~= true then
        print("Player Does Not Have Permission to Demote!");
    elseif rankIndex2 < currentRankIndex and CanGuildPromote() ~= true then
        print("Player Does Not Have Permission to Promote!");
    end
end

local function PopulateRankDropDown ( self , level )
    for i = 2 , ( GuildControlGetNumRanks() - GR_AddonGlobals [ "playerIndex" ] ) do
        local rank = UIDropDownMenu_CreateInfo();
        rank.text = ("   " .. GuildControlGetRankName ( i + GR_AddonGlobals [ "playerIndex" ] ));  -- Extra spacing is to justify it properly to center in allignment with other text due to dropdown button deformation of pattern.
        rank.func = OnRankDropMenuClick;
        UIDropDownMenu_AddButton ( rank );
    end
end

local function CreateRankDropDown()
    
    UIDropDownMenu_Initialize ( guildRankDropDownMenu , PopulateRankDropDown );
    UIDropDownMenu_SetWidth ( guildRankDropDownMenu , 112 );
    UIDropDownMenu_JustifyText ( guildRankDropDownMenu , "CENTER" );

    local numRanks = GuildControlGetNumRanks();
    local numChoices = (numRanks - GR_AddonGlobals [ "playerIndex" ] - 1);
    local solution = GR_AddonGlobals [ "rankIndex" ] - ( numRanks - numChoices ) + 1;   -- Calculating which rank to select based on flexible and scalable rank numbers.

    UIDropDownMenu_SetSelectedID ( guildRankDropDownMenu , solution );
    guildRankDropDownMenu:Show();
end

-- Method:              ClearPromoDateHistory ( string )
-- What it Does:        Purges history of promotions as if they had just joined the guild.
-- Purpose:             Editing ability in case of user error.
local function ClearPromoDateHistory ( name )
    local guildName = GetGuildInfo ( "player" );
    for i = 1 , #GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do
                if GR_GuildMemberHistory_Save[i][j][1] == name then        -- Player found!
                    -- Ok, let's clear the history now!
                    GR_GuildMemberHistory_Save[i][j][12] = nil;
                    GR_AddonGlobals [ "rankDateSet" ] = false;
                    GR_GuildMemberHistory_Save[i][j][25] = nil;
                    GR_GuildMemberHistory_Save[i][j][25] = {};
                    table.insert ( GR_GuildMemberHistory_Save[i][j][25] , { GR_GuildMemberHistory_Save[i][j][4] , strsub ( GR_GuildMemberHistory_Save[i][j][2] , 1 , string.find ( GR_GuildMemberHistory_Save[i][j][2] , "'" ) + 2 ) , GR_GuildMemberHistory_Save[i][j][3] } );
                    GR_MemberDetailRankDateTxt:Hide();
                    GR_SetPromoDateButton:Show();
                    altDropDownOptions:Hide();
                    break;
                end
            end
            break;
        end
    end
end

-- Method:              ClearJoinDateHistory ( string )
-- What it Does:        Clears the player's history on when they joined/left/rejoined the guild to be as if they were  a new member
-- Purpose:             Micromanagement of toons metadata.
local function ClearJoinDateHistory ( name )
    local guildName = GetGuildInfo ( "player" );
    for i = 1 , #GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do
                if GR_GuildMemberHistory_Save[i][j][1] == name then        -- Player found!
                    -- Ok, let's clear the history now!
                    GR_GuildMemberHistory_Save[i][j][20] = nil;   -- oldJoinDate wiped!
                    GR_GuildMemberHistory_Save[i][j][20] = {};
                    GR_GuildMemberHistory_Save[i][j][21] = nil;
                    GR_GuildMemberHistory_Save[i][j][21] = {};
                    GR_GuildMemberHistory_Save[i][j][15] = nil;
                    GR_GuildMemberHistory_Save[i][j][15] = {};
                    GR_GuildMemberHistory_Save[i][j][16] = nil;
                    GR_GuildMemberHistory_Save[i][j][16] = {};
                    GR_GuildMemberHistory_Save[i][j][2] = GetTimestamp();
                    GR_GuildMemberHistory_Save[i][j][3] = time();
                    
                    GR_JoinDateText:Hide();
                    altDropDownOptions:Hide();
                    GR_MemberDetailJoinDateButton:Show();
                    break;
                end
            end
            break;
        end
    end
end

-- Method:              ResetPlayerMetaData ( string , string )
-- What it Does:        Purges all metadata from an alt up to that point and resets them as if they were just added to the guild roster
-- Purpose:             Metadata player management. QoL feature if ever needed.
local function ResetPlayerMetaData( playerName , guildName )
    for i = 1 , #GR_GuildMemberHistory_Save do
        if GR_GuildMemberHistory_Save[i][1] == guildName then
            for j = 2 , #GR_GuildMemberHistory_Save[i] do
                if GR_GuildMemberHistory_Save[i][j][1] == playerName then
                    print ( playerName .. "'s saved data has been wiped!" );
                    local memberInfo = { playerName , GR_GuildMemberHistory_Save[i][j][4] , GR_GuildMemberHistory_Save[i][j][5] , GR_GuildMemberHistory_Save[i][j][6] , 
                                            GR_GuildMemberHistory_Save[i][j][7] , GR_GuildMemberHistory_Save[i][j][8] , GR_GuildMemberHistory_Save[i][j][9] , nil };
                    if #GR_GuildMemberHistory_Save[i][j][11] > 0 then
                        RemoveAlt ( GR_GuildMemberHistory_Save[i][j][11][1][1] , playerName , guildName );      -- Removing oneself from his alts list on clearing info so it clears him from them too.
                    end
                    table.remove ( GR_GuildMemberHistory_Save[i] , j );         -- Remove the player!
                    AddMemberRecord( memberInfo , false , nil , guildName )     -- Re-Add the player!
                    MemberDetailMetaData:Hide();
                    break;
                end
            end
            break;
        end
    end
end

-- Method:              ResetAllSavedData()
-- What it Does:        Purges literally ALL saved data, then rebuilds it from scratch as if addon was just installed.
-- Purpose:             Clear data for any purpose needed.
function ResetAllSavedData()
    print ( "Wiping all saved Roster data! Time to rebuild from scratch..." );
    GR_LogReport_Save = nil;
    GR_LogReport_Save = {};
    GR_GuildMemberHistory_Save = nil;
    GR_GuildMemberHistory_Save = {};
    GR_PlayersThatLeftHistory_Save = nil;
    GR_PlayersThatLeftHistory_Save = {};
    GR_LogReport_Save = nil;
    GR_LogReport_Save = {};
    GR_CalendarAddQue_Save = nil;
    GR_CalendarAddQue_Save = {};
    MemberDetailMetaData:Hide();
    BuildNewRoster();
end

-------------------------------
----- UI SCRIPTING LOGIC ------
----- ALL THINGS UX ARE HERE --
-------------------------------

local function PopulateMemberDetails( handle )
    local guildName = GetGuildInfo("player");
    GR_AddonGlobals [ "rankDateSet" ] = false;        -- resetting tracker

    for j = 1,#GR_GuildMemberHistory_Save do
        if GR_GuildMemberHistory_Save[j][1] == guildName then
            for r = 2,#GR_GuildMemberHistory_Save[j] do
                if GR_GuildMemberHistory_Save[j][r][1] == handle then   --- Player Found in MetaData Logs
                    -- Trigger Check for Any Changes
                    GuildRoster();
                    QueryGuildEventLog();

                    ------ Populating the UI Window ------
                    local class = GR_GuildMemberHistory_Save[j][r][9];
                    local level = GR_GuildMemberHistory_Save[j][r][6];
                    local isOnlineNow = false;
                    local statusNow = 0;      -- 0 = active, 1 = Away, 2 = DND (busy)

                    --- CLASS
                    local classColors = GetClassColorRGB ( class );
                    GR_MemberDetailNameText:SetPoint( "TOP" , 0 , -20 );
                    GR_MemberDetailNameText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1.0 );
                    
                    -- PLAYER NAME
                    GR_MemberDetailNameText:SetText ( handle );

                    --- LEVEL
                    GR_MemberDetailLevel:SetPoint ( "TOP" , 0 , -38 );
                    GR_MemberDetailLevel:SetText ( "Level: " .. level );

                    -- RANK
                    GR_AddonGlobals [ "tempName" ] = handle;
                    GR_AddonGlobals [ "rankIndex" ] = GR_GuildMemberHistory_Save[j][r][5];
                    -- Getting live server status info of player.
                    local count = 0;
                    for i = 1 , GetNumGuildies() do
                        local name,_,indexOfRank,_,_,_,_,_,isOnline,status = GetGuildRosterInfo ( i );
                        
                        if count < 2 then
                            name = SlimName ( name );
                            if addonPlayerName == name then
                                GR_AddonGlobals [ "playerIndex" ] = indexOfRank;
                                count = count + 1;
                            end
                            if handle == name then
                                if isOnline then
                                    isOnlineNow = true;
                                end
                                if ( status ~= nil or handle == GR_AddonGlobals [ "addonPlayerName" ] ) and ( status == 1 or status == 2) then
                                    statusNow = status;
                                end
                                count = count + 1;
                            end
                            if count == 2 then
                                break;
                            end
                        end
                    end
                    
                    local canPromote = CanGuildPromote();
                    local canDemote = CanGuildDemote();
                    if GR_AddonGlobals [ "rankIndex" ] > GR_AddonGlobals [ "playerIndex" ] and ( canPromote or canDemote ) then
                        GR_MemberDetailRankTxt:Hide();
                        CreateRankDropDown();
                    else
                        guildRankDropDownMenu:Hide();
                        GR_MemberDetailRankTxt:SetText ( "\"" .. GR_GuildMemberHistory_Save[j][r][4] .. "\"");
                        GR_MemberDetailRankTxt:Show();
                    end

                    -- STATUS TEXT
                    if isOnlineNow or handle == GR_AddonGlobals [ "addonPlayerName" ] then
                        if statusNow == 0 then
                            GR_MemberDetailPlayerStatus:SetTextColor ( 0.12 , 1.0 , 0.0 , 1.0 );
                            GR_MemberDetailPlayerStatus:SetText ( "( Active )" );
                        elseif statusNow == 1 then
                            GR_MemberDetailPlayerStatus:SetTextColor ( 1.0 , 0.96 , 0.41 , 1.0 );
                            GR_MemberDetailPlayerStatus:SetText ( "( AFK )" );
                        else
                            GR_MemberDetailPlayerStatus:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
                            GR_MemberDetailPlayerStatus:SetText ( "( Busy )" );
                        end
                        GR_MemberDetailPlayerStatus:Show();
                    else
                        GR_MemberDetailPlayerStatus:Hide();
                    end

                    --RANK PROMO DATE
                    if GR_GuildMemberHistory_Save[j][r][12] == nil then      --- Promotion has never been recorded!
                        GR_MemberDetailRankDateTxt:Hide();
                        if GR_AddonGlobals [ "rankIndex" ] > GR_AddonGlobals [ "playerIndex" ] and ( canPromote or canDemote ) then
                            SetPromoDateButton:SetPoint ( "TOP" , MemberDetailMetaData , 0 , -80 ); -- slightly varied positioning due to drop down window or not.
                        else
                            SetPromoDateButton:SetPoint ( "TOP" , MemberDetailMetaData , 0 , -67 );
                        end
                        SetPromoDateButton:Show();
                    else
                        SetPromoDateButton:Hide();
                        if GR_AddonGlobals [ "rankIndex" ] > GR_AddonGlobals [ "playerIndex" ] and ( canPromote or canDemote ) then
                            GR_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -82 ); -- slightly varied positioning due to drop down window or not.
                        else
                            GR_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -70 );
                        end
                        GR_AddonGlobals [ "rankDateSet" ] = true;
                        GR_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
                        GR_MemberDetailRankDateTxt:SetText ( "PROMOTED: " .. Trim ( strsub ( GR_GuildMemberHistory_Save[j][r][12] , 1 , 10) ) );
                        GR_MemberDetailRankDateTxt:Show();
                    end

                    if #GR_GuildMemberHistory_Save[j][r][20] == 0 then
                        GR_JoinDateText:Hide();
                        MemberDetailJoinDateButton:Show();
                    else
                        MemberDetailJoinDateButton:Hide();
                        GR_JoinDateText:SetText ( strsub ( GR_GuildMemberHistory_Save[j][r][20][#GR_GuildMemberHistory_Save[j][r][20]] , 1 , 10 ) );
                        GR_JoinDateText:Show();
                    end

                    -- PLAYER NOTE AND OFFICER NOTE EDIT BOXES
                    local finalNote = "Click here to set a Public Note";
                    local finalONote = "Click here to set an Officer's Note";
                    PlayerNoteEditBox:Hide();
                    PlayerOfficerNoteEditBox:Hide();

                    -- Set Public Note if is One
                    if GR_GuildMemberHistory_Save[j][r][7] ~= nil and GR_GuildMemberHistory_Save[j][r][7] ~= "" then
                        finalNote = GR_GuildMemberHistory_Save[j][r][7];
                    end
                    noteFontString1:SetText ( finalNote );
                    if CanEditPublicNote() then
                        if finalNote ~= "Click here to set a Public Note" then
                            PlayerNoteEditBox:SetText( finalNote );
                        else
                            PlayerNoteEditBox:SetText( "" );
                        end
                    elseif finalNote == "Click here to set a Public Note" then
                        noteFontString1:SetText ( "Unable to Edit Public Note at Rank" );
                    end

                    -- Set O Note
                    if CanViewOfficerNote() == true then
                        if GR_GuildMemberHistory_Save[j][r][8] ~= nil and GR_GuildMemberHistory_Save[j][r][8] ~= "" then
                            finalONote = GR_GuildMemberHistory_Save[j][r][8];
                        end
                        if finalONote == "Click here to set an Officer's Note" and CanEditOfficerNote() ~= true then
                            finalONote = "Unable to Add Officer Note at Rank";
                        end
                        noteFontString2:SetText ( finalONote );
                        if finalONote ~= "Click here to set an Officer's Note" then
                            PlayerOfficerNoteEditBox:SetText( finalONote );
                        else
                            PlayerOfficerNoteEditBox:SetText( "" );
                        end
                    else
                        noteFontString2:SetText ( "Unable to View Officer Note at Rank" );
                    end
                    noteFontString2:Show();
                    noteFontString1:Show();

                    -- Last Online
                    if isOnlineNow then
                        GR_MemberDetailLastOnlineTxt:SetText ( "Online" );
                    else
                        GR_MemberDetailLastOnlineTxt:SetText ( HoursReport ( GR_GuildMemberHistory_Save[j][r][24] ) );
                    end

                    -- Group Invite Button -- Setting script here
                    if isOnlineNow and handle ~= GR_AddonGlobals [ "addonPlayerName" ] then
                        if GetNumGroupMembers() > 0  then            -- If > 0 then player is in either a raid or a party. (1 will show if in an instance by oneself)
                            local isGroupLeader = UnitIsGroupLeader ( "PLAYER" );                                       -- Party or Group
                            local isInRaidWithAssist = UnitIsGroupAssistant ( "PLAYER" , LE_PARTY_CATEGORY_HOME );      -- Player Has Assist in Raid group

                            if IsGuildieInSameGroup ( handle ) then
                                -- Player is already in group!
                                GR_GroupInviteButtonText:SetText ( "In Group" );
                                groupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                                    if button == "LeftButton" then
                                        print ( handle .. " is Already in Your Group!" );
                                    end
                                end);
                            elseif isGroupLeader or isInRaidWithAssist then                                         -- Player has the ability to invite to group
                                GR_GroupInviteButtonText:SetText ( "Group Invite" );
                                groupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                                    if button == "LeftButton" then
                                        if IsInRaid() and GetNumGroupMembers() == 40 then                               -- Helpful reporting to cleanup the raid in case players are offline and no room to invite.
                                            local afkList = GetGroupUnitsOfflineOrAFK();
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
                                groupInviteButton:SetText ( "No Invite" );
                                groupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                                    if button == "LeftButton" then
                                        print ( "Player must obtain group invite privileges." );
                                    end
                                end);
                            end
                        else
                            -- Player is not in any group, thus inviting them will create new group.
                            groupInviteButton:SetText ( "Group Invite" );
                            groupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                                if button == "LeftButton" then
                                    InviteUnit ( handle );
                                end
                            end);
                        end

                        groupInviteButton:Show();
                    else
                        groupInviteButton:Hide();
                    end

                    -- REMOVE SOMEONE FROM GUILD BUTTON.
                    local isGuildieBanned = GR_GuildMemberHistory_Save[j][r][17];
                    if handle ~= GR_AddonGlobals [ "addonPlayerName" ] and GR_AddonGlobals [ "rankIndex" ] > GR_AddonGlobals [ "playerIndex" ] and CanGuildRemove() then
                        local isGuildieBanned = GR_GuildMemberHistory_Save[j][r][17];
                        if isGuildieBanned then
                            removeGuildieButton:SetText ( "Re-Kick" );
                        else
                            removeGuildieButton:SetText ( "Remove" );
                        end
                        removeGuildieButton:Show();
                        GR_RemoveGuildieButton:SetScript ( "OnClick" , function ( _ , button )
                            -- Inital check is to ensure clean UX - ensuring the next time window is closed on reload, but if already open, no need to close it.
                            if button == "LeftButton" then
                                GR_AddonGlobals [ "pause" ] = true
                                if GR_PopupWindow:IsVisible() ~= true then
                                    GR_MemberDetailEditBoxFrame:Hide();
                                    GR_PopupWindowCheckButton1:SetChecked ( false ); -- Ensures it is always unchecked on load.
                                end
                                if removeGuildieButton:GetText() == "Re-Kick" then
                                    GR_PopupWindowConfirmText:SetText ( "Are you sure you want to Re-Gkick " .. handle .. "?" );
                                else
                                    GR_PopupWindowConfirmText:SetText ( "Are you sure you want to Gkick " .. handle .. "?" );
                                end
                                if removeGuildieButton:GetText() ~= "Re-Kick" then
                                    GR_PopupWindowCheckButtonText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
                                    GR_PopupWindowCheckButtonText:SetText ( "Ban Player" );
                                    GR_PopupWindowCheckButtonText:Show();
                                    GR_PopupWindowCheckButton1:Show();
                                else
                                    GR_PopupWindowCheckButtonText:Hide();
                                    GR_PopupWindowCheckButton1:Hide();
                                end
                                if #GR_GuildMemberHistory_Save[j][r][11] > 0 then
                                    GR_PopupWindowCheckButton2Text:SetTextColor ( 1.0 , 1.0 , 1.0 , 1.0 );
                                    GR_PopupWindowCheckButton2Text:SetText ( "Kick Alts Too!" );
                                    GR_PopupWindowCheckButton2Text:Show();
                                    GR_PopupWindowCheckButton2:Show();
                                else
                                    GR_PopupWindowCheckButton2Text:Hide();
                                    GR_PopupWindowCheckButton2:Hide();
                                end
                                GR_PopupWindow:Show();

                                -- Create Button Logic
                                GR_PopupWindowButton1:SetScript ( "OnClick" , function( _ , button )
                                    if button == "LeftButton" then
                                        if GR_PopupWindowCheckButton1:IsVisible() and GR_PopupWindowCheckButton1:GetChecked() then          -- Box is checked, so YES player should be banned.
                                            -- Popup edit box
                                            local instructionNote = "Reason Banned? (Press ENTER when done)"
                                            MemberDetailPopupEditBox:SetText ( instructionNote );
                                            MemberDetailPopupEditBox:HighlightText ( 0 );
                                            MemberDetailPopupEditBox:SetScript ( "OnEnterPressed" , function ( _ ) 
                                                -- If kick alts button is checked...
                                                if GR_PopupWindowCheckButton2:IsVisible() and GR_PopupWindowCheckButton2:GetChecked() then
                                                    KickAllAlts ( handle , guildName );
                                                end
                                                GR_GuildMemberHistory_Save[j][r][17] = true;      -- Banning Player.
                                                local result = MemberDetailPopupEditBox:GetText();
                                                if result ~= instructionNote and result ~= "" and result ~= nil then
                                                    GR_GuildMemberHistory_Save[j][r][18] = result;
                                                elseif result == nil then
                                                    GR_GuildMemberHistory_Save[j][r][18] = "";
                                                end
                                                -- Now let's kick the member
                                                GuildUninvite ( handle );
                                                GR_MemberDetailEditBoxFrame:Hide();
                                                GR_AddonGlobals [ "pause" ] = false;                                                
                                            end);

                                            GR_MemberDetailEditBoxFrame:Show();

                                        else    -- Kicking the player ( not a ban )
                                            -- if button 2 is checked, kick the alts too.
                                            if GR_PopupWindowCheckButton2:IsVisible() and GR_PopupWindowCheckButton2:GetChecked() then
                                                KickAllAlts ( handle , guildName );
                                            end
                                            GR_PopupWindow:Hide();
                                            GuildUninvite ( handle );
                                            GR_AddonGlobals [ "pause" ] = false;
                                        end
                                    end
                                end);
                            end
                        end);
                    else
                        removeGuildieButton:Hide();
                    end

                    -- Player was previous banned and rejoined logic! This will unban the player.
                    if isGuildieBanned then
                        GR_MemberDetailBannedIgnoreButton:SetScript ( "OnClick" , function ( _ , button ) 
                            if button == "LeftButton" then
                                GR_GuildMemberHistory_Save[j][r][17] = false;
                                GR_GuildMemberHistory_Save[j][r][18] = "";
                                removeGuildieButton:SetText( "Remove" );
                                GR_MemberDetailBannedText1:Hide();
                                GR_MemberDetailBannedIgnoreButton:Hide();
                                GR_PopupWindow:Hide();
                            end
                        end);
                        
                        GR_MemberDetailBannedText1:Show();
                        GR_MemberDetailBannedIgnoreButton:Show();
                    else
                        GR_MemberDetailBannedText1:Hide();
                        GR_MemberDetailBannedIgnoreButton:Hide();
                    end

                    -- ALTS 
                    PopulateAltFrames (  j , r );


                    break;
                end
            end
            break;
        end
    end
end

local function ClearAllFrames()
    MemberDetailMetaData:Hide();
    MonthDropDownMenu:Hide();
    YearDropDownMenu:Hide();
    DayDropDownMenu:Hide();
    guildRankDropDownMenu:Hide();
    DateSubmitButton:Hide();
    DateSubmitCancelButton:Hide();
    GR_PopupWindow:Hide();
    NoteCount:Hide();
    GR_CoreAltFrame:Hide();
    altDropDownOptions:Hide();
    addAltButton:Hide();
    AddAltEditFrame:Hide();
end

local function SubFrameCheck()
    -- wipe the frames...
    if DateSubmitCancelButton:IsVisible() then
        DateSubmitCancelButton:Click();
    end
    if AddAltEditFrame:IsVisible() then
        AddAltEditFrame:Hide();
    end
    if GR_PopupWindow:IsVisible() then
        GR_PopupWindow:Hide();
    end
    if NoteCount:IsVisible() then
        NoteCount:Hide();
    end
end

-- Method:              GR_RosterFrame(self,elapsed)
-- What it Does:        In the main guild window, guild roster screen, rather than having to select a guild member to see the additional window pop update
--                      all the player needs to do is just mousover it.
-- Purpose:             This is for more efficient "glancing" at info for guild leader, with more details.
local function GR_RosterFrame ( _ , elapsed )
    GR_AddonGlobals [ "timer" ] = GR_AddonGlobals [ "timer" ] + elapsed;
    if GR_AddonGlobals [ "timer" ] >= 0.075 then
        -- control on whether to freeze the scanning.
        if GR_AddonGlobals [ "pause" ] and MemberDetailMetaData:IsVisible() == false then
            GR_AddonGlobals [ "pause" ] = false;
        end
        local NotSameWindow = true;
        local mouseNotOver = true;
        local name = "";
        local MobileIconCheck = "";

        if GR_AddonGlobals [ "pause" ] == false and DropDownList1:IsVisible() ~= true then
            SubFrameCheck();
            local length = 84;
            if (GuildRosterContainerButton1:IsMouseOver(1,-1,-1,1)) then
                if 1 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton1String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton1String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton1String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton1String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton1String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 1;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif(GuildRosterContainerButton2:IsVisible() and GuildRosterContainerButton2:IsMouseOver(1,-1,-1,1)) then
                if 2 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton2String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton2String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton2String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton2String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton2String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 2;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton3:IsVisible() and GuildRosterContainerButton3:IsMouseOver(1,-1,-1,1)) then
                if 3 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton3String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton3String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton3String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton3String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton3String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 3;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton4:IsVisible() and GuildRosterContainerButton4:IsMouseOver(1,-1,-1,1)) then
                if 4 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton4String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton4String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton4String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton4String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton4String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 4;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton5:IsVisible() and GuildRosterContainerButton5:IsMouseOver(1,-1,-1,1)) then
                if 5 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton5String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton5String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton5String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton5String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton5String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 5;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton6:IsVisible() and GuildRosterContainerButton6:IsMouseOver(1,-1,-1,1)) then
                if 6 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton6String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton6String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton6String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton6String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton6String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 6;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton7:IsVisible() and GuildRosterContainerButton7:IsMouseOver(1,-1,-1,1)) then
                if 7 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton7String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton7String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton7String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton7String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton7String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 7;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton8:IsVisible() and GuildRosterContainerButton8:IsMouseOver(1,-1,-1,1)) then
                if 8 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton8String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton8String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton8String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton8String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton8String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 8;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton9:IsVisible() and GuildRosterContainerButton9:IsMouseOver(1,-1,-1,1)) then
                if 9 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton9String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton9String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton9String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton9String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton9String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 9;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton10:IsVisible() and GuildRosterContainerButton10:IsMouseOver(1,-1,-1,1)) then
                if 10 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton10String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton10String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton10String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton10String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton10String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 10;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton11:IsVisible() and GuildRosterContainerButton11:IsMouseOver(1,-1,-1,1)) then
                if 11 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton11String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton11String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton11String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton11String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton11String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 11;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton12:IsVisible() and GuildRosterContainerButton12:IsMouseOver(1,-1,-1,1)) then
                if 12 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton12String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton12String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton12String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton12String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton12String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 12;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton13:IsVisible() and GuildRosterContainerButton13:IsMouseOver(1,-1,-1,1)) then
                if 13 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton13String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton13String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton13String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton13String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton13String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 13;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton14:IsVisible() and GuildRosterContainerButton14:IsMouseOver(1,-1,-1,1)) then
                if 14 ~= GR_AddonGlobals [ "position" ] then
                    name = GuildRosterContainerButton14String1:GetText();
                    if tonumber ( name ) ~= nil then
                        MobileIconCheck = "\"" .. GuildRosterContainerButton14String2:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton14String2:GetText();
                        end
                    else
                        MobileIconCheck = "\"" .. GuildRosterContainerButton14String1:GetText() .. "\"";
                        if #MobileIconCheck > 50 then
                            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                                length = 85
                            end
                            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                        else
                            name = GuildRosterContainerButton14String1:GetText();
                        end
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    GR_AddonGlobals [ "position" ] = 14;
                    GR_AddonGlobals [ "pause" ] = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            end
            -- Logic on when to make Member Detail window disappear.
            if mouseNotOver and NotSameWindow and GR_AddonGlobals [ "pause" ] == false then
                if ( GuildRosterFrame:IsMouseOver(2,-2,-2,2) ~= true and DropDownList1Backdrop:IsMouseOver(2,-2,-2,2) ~= true and GR_MemberDetails:IsMouseOver(2,-2,-2,2) ~= true ) or 
                    ( GR_MemberDetails:IsMouseOver(2,-2,-2,2) == true and GR_MemberDetails:IsVisible() ~= true ) then  -- If player is moused over side window, it will not hide it!
                    GR_AddonGlobals [ "position" ] = 0;
                    
                    ClearAllFrames();
                end
            end
        end
        if GuildRosterFrame:IsVisible() ~= true then
            
            ClearAllFrames();

        end
        GR_AddonGlobals [ "timer" ] = 0;
    end
end


local function OpenMemberDetailFrame( self , button , down)
    if button == "LeftButton" then
        if MemberDetailMetaData:IsVisible() then
            MemberDetailMetaData:Hide();            -- Hitting the button again hides the frame, exactly like closing.
        else
            if MemberDetailMetaData:IsVisible() ~= true then
                MemberDetailMetaData:Show();
            end
        end
    end
end

local function SetCloseBoolean( self , button , down )
    if button == "LeftButton" then
        MemberDetailMetaData:Hide();
    end
end

-- tooltipLogic
local function MemberDetailToolTips ( self , elapsed )
    GR_AddonGlobals [ "timer2" ] = GR_AddonGlobals [ "timer2" ] + elapsed;
    if GR_AddonGlobals [ "timer2" ] >= 0.075 then
        local name = GR_MemberDetailName:GetText();
        local guildName = GetGuildInfo("player");

        -- Rank Text
        -- Only populate and show tooltip if mouse is over text frame and it is not already visible.
        if MemberDetailRankToolTip:IsVisible() ~= true and GR_MemberDetailRankDateTxt:IsVisible() == true and altDropDownOptions:IsVisible() ~= true and GR_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) == true then
            
            MemberDetailRankToolTip:SetOwner( GR_MemberDetailRankDateTxt , "ANCHOR_CURSOR" );
            MemberDetailRankToolTip:AddLine( "|cFFFFFFFF Rank History");
            for i = 1 , #GR_GuildMemberHistory_Save do
                if GR_GuildMemberHistory_Save[i][1] == guildName then
                    for j = 2,#GR_GuildMemberHistory_Save[i] do
                        if GR_GuildMemberHistory_Save[i][j][1] == name then   --- Player Found in MetaData Logs
                            -- Now, let's build the tooltip
                            for k = #GR_GuildMemberHistory_Save[i][j][25] , 1 , -1 do
                                MemberDetailRankToolTip:AddDoubleLine( GR_GuildMemberHistory_Save[i][j][25][k][1] .. ":" , GR_GuildMemberHistory_Save[i][j][25][k][2] , 0.38 , 0.67 , 1.0 );
                            end
                        break;
                        end
                    end
                    break;
                end
            end
            MemberDetailRankToolTip:Show();
        elseif MemberDetailRankToolTip:IsVisible() == true and GR_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) ~= true then
            MemberDetailRankToolTip:Hide();
        end

        -- JOIN DATE TEXT
        if MemberDetailJoinDateToolTip:IsVisible() ~= true and GR_JoinDateText:IsVisible() == true and altDropDownOptions:IsVisible() ~= true and GR_JoinDateText:IsMouseOver(1,-1,-1,1) == true then
           
            MemberDetailJoinDateToolTip:SetOwner( GR_JoinDateText , "ANCHOR_CURSOR" );
            MemberDetailJoinDateToolTip:AddLine( "|cFFFFFFFF Membership History");
            local joinedHeader;

            for i = 1 , #GR_GuildMemberHistory_Save do
                if GR_GuildMemberHistory_Save[i][1] == guildName then
                    for j = 2,#GR_GuildMemberHistory_Save[i] do
                        if GR_GuildMemberHistory_Save[i][j][1] == name then   --- Player Found in MetaData Logs
                            -- Ok, let's build the tooltip now.
                            for r = #GR_GuildMemberHistory_Save[i][j][20] , 1 , -1 do                                       -- Starting with most recent join which will be at end of array.
                                if r > 1 then
                                    joinedHeader = "Rejoined: ";
                                else
                                    joinedHeader = "Joined: ";
                                end
                                if GR_GuildMemberHistory_Save[i][j][15][r] ~= nil then
                                    MemberDetailJoinDateToolTip:AddDoubleLine( "|CFFC41F3BLeft:    " ,  Trim ( strsub ( GR_GuildMemberHistory_Save[i][j][15][r] , 1 , 10 ) ) , 1 , 0 , 0 );
                                end
                                MemberDetailJoinDateToolTip:AddDoubleLine( joinedHeader , Trim ( strsub ( GR_GuildMemberHistory_Save[i][j][20][r] , 1 , 10 ) ) , 0.38 , 0.67 , 1.0 );
                                -- If player once left, then this will add the line for it.
                            end
                        break;
                        end
                    end
                    break;
                end
            end
            MemberDetailJoinDateToolTip:Show();
        elseif MemberDetailJoinDateToolTip:IsVisible() == true and GR_JoinDateText:IsMouseOver(1,-1,-1,1) ~= true then
            MemberDetailJoinDateToolTip:Hide();
        end

        -- ALT FRAMES 

        GR_AddonGlobals [ "timer2" ] = 0;
    end
end


----------------------
--- FRAME VALUES -----
--- AND PARAMETERS ---
----------------------

-- Method:              UnlockRosterHighligts()
-- What it Does:        Used as hookscript to remove highlight on window close.
-- Purpose:             Smoother UX
local function UnlockRosterHighligts()
     GuildRosterContainerButton1:UnlockHighlight();
     GuildRosterContainerButton2:UnlockHighlight();
     GuildRosterContainerButton3:UnlockHighlight();
     GuildRosterContainerButton4:UnlockHighlight();
     GuildRosterContainerButton5:UnlockHighlight();
     GuildRosterContainerButton6:UnlockHighlight();
     GuildRosterContainerButton7:UnlockHighlight();
     GuildRosterContainerButton8:UnlockHighlight();
     GuildRosterContainerButton9:UnlockHighlight();
     GuildRosterContainerButton10:UnlockHighlight();
     GuildRosterContainerButton11:UnlockHighlight();
     GuildRosterContainerButton12:UnlockHighlight();
     GuildRosterContainerButton13:UnlockHighlight();
end

-- Method:                  GR_MetaDataInitializeUIFirst()
-- What it Does:            Initializes "some of the frames"
-- Purpose:                 Should only initialize as needed.
local function GR_MetaDataInitializeUIFirst()
    -- Frame Control
    MemberDetailMetaData:EnableMouse(true);
    MemberDetailMetaData:SetMovable(true);
    MemberDetailMetaData:RegisterForDrag("LeftButton");
    MemberDetailMetaData:SetScript("OnDragStart", MemberDetailMetaData.StartMoving);
    MemberDetailMetaData:SetScript("OnDragStop", MemberDetailMetaData.StopMovingOrSizing);
    MemberDetailMetaData:SetClampedToScreen ( true );

    -- Placement and Dimensions
    MemberDetailMetaData:SetPoint("TOPLEFT", GuildRosterFrame, "TOPRIGHT" , -4 , 5 );
    MemberDetailMetaData:SetHeight(330);
    MemberDetailMetaData:SetWidth(285);
    MemberDetailMetaData:SetScript( "OnShow", function() MemberDetailMetaDataCloseButton:SetPoint("TOPRIGHT" , MemberDetailMetaData , 3, 3 ); MemberDetailMetaDataCloseButton:Show() end );
    MemberDetailMetaData:SetScript ( "OnUpdate" , MemberDetailToolTips );

    -- Logic handling: If pause is set, this unpauses it. If it is not paused, this will then hide the window.
    MemberDetailMetaData:SetScript ( "OnKeyDown" , function ( _ , key )
        MemberDetailMetaData:SetPropagateKeyboardInput ( true );
        if key == "ESCAPE" then
            MemberDetailMetaData:SetPropagateKeyboardInput ( false );
            if GR_AddonGlobals [ "pause" ] then
                GR_AddonGlobals [ "pause" ] = false;
            else
                MemberDetailMetaData:Hide();
            end
        end
    end);

    -- For Fontstring logic handling, particularly of the alts.
    MemberDetailMetaData:SetScript ( "OnMouseDown" , function ( _ , button ) 
        if button == "RightButton" then
            GR_AddonGlobals [ "selectedAlt" ] = GetCoreFontStringClicked(); -- Setting to global the alt name chosen.
            if GR_AddonGlobals [ "selectedAlt" ][1] ~= nil then
                GR_AddonGlobals [ "pause" ] = true;
                local cursorX , cursorY = GetCursorPosition();
                altDropDownOptions:ClearAllPoints();
                altDropDownOptions:SetPoint( "TOPLEFT" , UIParent , "BOTTOMLEFT" , cursorX , cursorY );

                altDropDownOptions:SetWidth ( 65 );
                altDropDownOptions:SetHeight ( 92 );
                altDropDownOptions:Show();
                altOptionsText:SetText ( GR_AddonGlobals [ "selectedAlt" ][2] );

                if GR_AddonGlobals [ "selectedAlt" ][1] == GR_AddonGlobals [ "selectedAlt" ][2] then -- Not clicking an alt frame
                    if GR_MemberDetailRankDateTxt:IsVisible() and GR_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                        GR_AddonGlobals [ "editPromoDate" ] = true;
                        GR_AddonGlobals [ "editJoinDate" ] = false;
                    elseif GR_JoinDateText:IsVisible() and GR_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                        GR_AddonGlobals [ "editJoinDate" ] = true;
                        GR_AddonGlobals [ "editPromoDate" ] = false;
                    end
                    MemberDetailRankToolTip:Hide();
                    MemberDetailJoinDateToolTip:Hide();
                    altSetMainButtonText:SetText ( "Edit Date" );
                    altRemoveButtonText:SetText ( "Clear History" );
                else
                    if GR_AddonGlobals [ "selectedAlt" ][4] ~= true then    -- player is not the main.
                        altSetMainButtonText:SetText ( "Set as Main" );
                    else -- player IS the main... place option to Demote From Main rahter than set as main.
                        altSetMainButtonText:SetText ( "Set as Alt" );
                    end
                    altRemoveButtonText:SetText ( "Remove" );
                end
            end
        end
    end);

    -- Keyboard Control for easy ESC closeButtons
    tinsert(UISpecialFrames, "GR_MemberDetails");

    -- CORE FRAME CHILDREN FEATURES
    -- rank drop down 
    guildRankDropDownMenu:SetPoint( "TOP" , MemberDetailMetaData , 0 , -50 );

    --Rank Drop down submit and cancel
    SetPromoDateButton:SetText ("Date Promoted?");
    SetPromoDateButton:SetHeight ( 18 );
    SetPromoDateButton:SetWidth ( 110 );
    SetPromoDateButton:SetScript( "OnClick" , function( self , button , down ) 
        if button == "LeftButton" then
            SetPromoDateButton:Hide();
            SetDateSelectFrame ( "TOP" , MemberDetailMetaData , "PromoRank" );  -- Position, Frame, ButtonName
            GR_AddonGlobals [ "pause" ] = true;
        end
    end);

    DateSubmitButton:SetWidth( 74 );
    DateSubmitCancelButton:SetWidth( 74 );
    GR_DateSubmitCancelButtonTxt:SetPoint ( "CENTER" , DateSubmitCancelButton );
    GR_DateSubmitCancelButtonTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.9 );
    GR_DateSubmitCancelButtonTxt:SetText ( "Cancel" );
    GR_DateSubmitButtonTxt:SetPoint ( "CENTER" , DateSubmitButton );
    GR_DateSubmitButtonTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.9 );

    -- Rank promotion date text
    GR_MemberDetailRankTxt:SetPoint ( "TOP" , 0 , -52 );
    GR_MemberDetailRankTxt:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );

    -- "MEMBER SINCE"
    GR_JoinDateText:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -21 , - 33 );
    GR_JoinDateText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GR_JoinDateText:SetWidth ( 55 );
    GR_JoinDateText:SetJustifyH ( "CENTER" );

    -- "LAST ONLINE" 
    GR_MemberDetailLastOnlineTitleTxt:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 16 , -22 );
    GR_MemberDetailLastOnlineTitleTxt:SetText ( "Last Online                                 Date Joined" );
    GR_MemberDetailLastOnlineTitleTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 , "THICKOUTLINE" );
    GR_MemberDetailLastOnlineTxt:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 16 , -32 );
    GR_MemberDetailLastOnlineTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GR_MemberDetailLastOnlineTxt:SetWidth ( 65 );
    GR_MemberDetailLastOnlineTxt:SetJustifyH ( "CENTER" );
    
    -- PLAYER STATUS
    GR_MemberDetailPlayerStatus:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 23 , - 48 );
    GR_MemberDetailPlayerStatus:SetWidth ( 50 );
    GR_MemberDetailPlayerStatus:SetJustifyH ( "CENTER" );
    GR_MemberDetailPlayerStatus:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );

    -- Join Date Button Logic for visibility
    MemberDetailJoinDateButton:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -20 , - 32 );
    MemberDetailJoinDateButton:SetWidth ( 60 );
    MemberDetailJoinDateButton:SetHeight ( 17 );
    MemberDetailJoinDateButtonText:SetPoint ( "CENTER" , MemberDetailJoinDateButton );
    MemberDetailJoinDateButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    MemberDetailJoinDateButtonText:SetText ( "Join Date?" )
    MemberDetailJoinDateButton:SetScript ( "OnClick" , function ( self , button , down )
        if button == "LeftButton" then
            MemberDetailJoinDateButton:Hide();
            if GR_MemberDetailRankDateTxt:IsVisible() then
                GR_MemberDetailRankDateTxt:Hide();
            elseif SetPromoDateButton:IsVisible() then
                SetPromoDateButton:Hide();
            end
            SetDateSelectFrame ( "TOP" , MemberDetailMetaData , "JoinDate" );  -- Position, Frame, ButtonName
            GR_AddonGlobals [ "pause" ] = true;
        end
    end);

    -- GROUP INVITE BUTTON
    groupInviteButton:SetPoint ( "BOTTOMLEFT" , MemberDetailMetaData , 16, 13 )
    groupInviteButton:SetWidth ( 88 );
    groupInviteButton:SetHeight ( 19 );
        
    -- REMOVE GUILDIE BUTTON
    removeGuildieButton:SetPoint ( "BOTTOMRIGHT" , MemberDetailMetaData , -15, 13 )
    removeGuildieButton:SetWidth ( 88 );
    removeGuildieButton:SetHeight ( 19 );

    -- player note edit box and font string (31 characters)
    GR_MemberDetailNoteTitle:SetPoint ( "LEFT" , MemberDetailMetaData , 21 , 32 );
    GR_MemberDetailNoteTitle:SetText ( "Note:                                               Officer's Note:" );
    GR_MemberDetailNoteTitle:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

    -- OFFICER AND PLAYER NOTES
    PlayerNoteWindow:SetPoint( "LEFT" , MemberDetailMetaData , 15 , 10 );
    noteFontString1:SetPoint ( "TOPLEFT" , PlayerNoteWindow , 9 , -11 );
    noteFontString1:SetWordWrap ( true );
    noteFontString1:SetWidth ( 108 );
    noteFontString1:SetJustifyH ( "LEFT" );

    PlayerNoteWindow:SetBackdrop ( noteBackdrop );
    PlayerNoteWindow:SetWidth ( 125 );
    PlayerNoteWindow:SetHeight ( 40 );
    
    PlayerNoteEditBox:SetBackdrop ( noteBackdrop );
    PlayerNoteEditBox:SetPoint( "LEFT" , MemberDetailMetaData , 15 , 10 );
    PlayerNoteEditBox:SetWidth ( 125 );
    PlayerNoteEditBox:SetHeight ( 40 );
    PlayerNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    PlayerNoteEditBox:SetMaxLetters ( 31 );
    PlayerNoteEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 10 );
    PlayerNoteEditBox:EnableMouse( true );
    PlayerNoteEditBox:SetFrameStrata ( "HIGH" );
    NoteCount:SetPoint ("TOPRIGHT" , PlayerNoteEditBox , -6 , 8 );
    NoteCount:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

    -- Officer Note
    PlayerOfficerNoteWindow:SetPoint( "RIGHT" , MemberDetailMetaData , -15 , 10 );
    noteFontString2:SetPoint ( "TOPLEFT" , PlayerOfficerNoteWindow , 9 , -11 );
    noteFontString2:SetWordWrap ( true );
    noteFontString2:SetWidth ( 108 );
    noteFontString2:SetJustifyH ( "LEFT" );

    PlayerOfficerNoteWindow:SetBackdrop ( noteBackdrop );
    PlayerOfficerNoteWindow:SetWidth ( 125 );
    PlayerOfficerNoteWindow:SetHeight ( 40 );
    
    PlayerOfficerNoteEditBox:SetBackdrop ( noteBackdrop );
    PlayerOfficerNoteEditBox:SetPoint( "RIGHT" , MemberDetailMetaData , -15 , 10 );
    PlayerOfficerNoteEditBox:SetWidth ( 125 );
    PlayerOfficerNoteEditBox:SetHeight ( 40 );
    PlayerOfficerNoteEditBox:SetTextInsets( 8 , 9 , 9 , 8 );
    PlayerOfficerNoteEditBox:SetMaxLetters ( 31 );
    PlayerOfficerNoteEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 10 );
    PlayerOfficerNoteEditBox:EnableMouse( true );
    PlayerOfficerNoteEditBox:SetFrameStrata ( "HIGH" );

    -- CUSTOM POPUP
    GR_PopupWindow:SetPoint ( "CENTER" , UIParent );
    GR_PopupWindow:SetWidth ( 240 );
    GR_PopupWindow:SetHeight ( 120 );
    GR_PopupWindow:SetFrameStrata ( HIGH );
    GR_PopupWindow:EnableKeyboard ( true );
    GR_PopupWindowButton1:SetPoint ( "BOTTOMLEFT" , GR_PopupWindow , 15 , 14 );
    GR_PopupWindowButton1:SetWidth ( 75 );
    GR_PopupWindowButton1:SetHeight ( 25 );
    GR_PopupWindowButton1:SetText ( "YES" );
    GR_PopupWindowButton2:SetPoint ( "BOTTOMRIGHT" , GR_PopupWindow , -15 , 14 );
    GR_PopupWindowButton2:SetWidth ( 75 );
    GR_PopupWindowButton2:SetHeight ( 25 );
    GR_PopupWindowButton2:SetText ( "CANCEL" );
    GR_PopupWindowConfirmText:SetPoint ( "TOP" , GR_PopupWindow , 0 , -17.5 );
    GR_PopupWindowConfirmText:SetWidth ( 185 );
    GR_PopupWindowConfirmText:SetJustifyH ( "CENTER" );
    GR_PopupWindowCheckButton1:SetPoint ( "BOTTOMLEFT" , GR_PopupWindow , 15 , 55 );
    GR_PopupWindowCheckButtonText:SetPoint ( "RIGHT" , GR_PopupWindowCheckButton1 , 54 , 0 );
    GR_PopupWindowCheckButton2:SetPoint ( "BOTTOMLEFT" , GR_PopupWindow , 15 , 35 );
    GR_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GR_PopupWindowCheckButton2 , 70 , 0 );

    GR_PopupWindowCheckButton1:HookScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if GR_PopupWindowCheckButton1:GetChecked() ~= true then
                GR_MemberDetailEditBoxFrame:Hide();                 -- If editframe is up, and you uncheck the box, it hides the editbox too
                GR_PopupWindowCheckButton2Text:ClearAllPoints();
                GR_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GR_PopupWindowCheckButton2 , 70 , 0 );
                GR_PopupWindowCheckButton2Text:SetTextColor ( 1.0 , 1.0 , 1.0 , 1.0 );
                GR_PopupWindowCheckButton2Text:SetText ( "Kick Alts Too!" );
                
            else
                GR_PopupWindowCheckButton2Text:ClearAllPoints();
                GR_PopupWindowCheckButton2Text:SetPoint ( "RIGHT" , GR_PopupWindowCheckButton2 , 112 , 0 );
                GR_PopupWindowCheckButton2Text:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
                GR_PopupWindowCheckButton2Text:SetText ( "Kick and Ban Alts too!" );
            end
        end
    end);

    -- Popup logic
    GR_PopupWindowButton2:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            GR_PopupWindow:Hide();
        end
    end);

    -- Backup logic with Escape key
    GR_PopupWindow:SetScript ( "OnKeyDown" , function ( _ , key )
        GR_PopupWindow:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            GR_PopupWindow:SetPropagateKeyboardInput ( false );
            GR_PopupWindow:Hide();
        end
    end);

    -- Popup EDIT BOX
    GR_MemberDetailEditBoxFrame:SetPoint ( "TOP" , GR_PopupWindow , "BOTTOM" , 0 , 2 );
    GR_MemberDetailEditBoxFrame:SetWidth ( 240 );
    GR_MemberDetailEditBoxFrame:SetHeight ( 45 );

    MemberDetailPopupEditBox:SetPoint( "CENTER" , GR_MemberDetailEditBoxFrame , 0 , 0 );
    MemberDetailPopupEditBox:SetWidth ( 210 );
    MemberDetailPopupEditBox:SetHeight ( 25 );
    MemberDetailPopupEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    MemberDetailPopupEditBox:SetMaxLetters ( 155 );
    MemberDetailPopupEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 9 );
    MemberDetailPopupEditBox:EnableMouse( true );

    -- Script handler for General popup editbox.
    MemberDetailPopupEditBox:SetScript ( "OnEscapePressed" , function ( _ )
        GR_MemberDetailEditBoxFrame:Hide();
    end);

    -- Heads-up text if player was previously banned
    GR_MemberDetailBannedText1:SetPoint ( "CENTER" , MemberDetailMetaData , -65 , -45.5 );
    GR_MemberDetailBannedText1:SetWordWrap ( true );
    GR_MemberDetailBannedText1:SetJustifyH ( "CENTER" );
    GR_MemberDetailBannedText1:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GR_MemberDetailBannedText1:SetFont( "Fonts\\FRIZQT__.TTF" , 8.0 );
    GR_MemberDetailBannedText1:SetWidth ( 120 );
    GR_MemberDetailBannedText1:SetText ( "WARNING! WARNING!\nRejoining player was previously banned!" );
    GR_MemberDetailBannedIgnoreButton:SetPoint ( "CENTER" , MemberDetailMetaData , -65 , -70.5 );
    GR_MemberDetailBannedIgnoreButton:SetWidth ( 85 );
    GR_MemberDetailBannedIgnoreButton:SetHeight ( 19 );
    GR_MemberDetailBannedIgnoreButton:SetText ( "Ignore Ban" );
    
    -- Script handlers on Note Edit Boxes
    local defaultNote = "Click here to set a Public Note";
    local defaultONote = "Click here to set an Officer's Note";
    local tempNote = "";
    local finalNote = "";

    -- Script handlers on Note Frames
    PlayerNoteWindow:SetScript ( "OnMouseDown" , function( self , button ) 
        if button == "LeftButton" and CanEditPublicNote() then 
            NoteCount:SetPoint ("TOPRIGHT" , PlayerNoteEditBox , -6 , 8 );
            GR_AddonGlobals [ "pause" ] = true;
            noteFontString1:Hide();
            PlayerOfficerNoteEditBox:Hide();
            NoteCount:Hide();
            tempNote = noteFontString2:GetText();
            if tempNote ~= defaultONote and tempNote ~= "" then
                finalNote = tempNote;
            else
                finalNote = "";
            end
            PlayerOfficerNoteEditBox:SetText( finalNote );
            noteFontString2:Show();

            local charCount = #PlayerNoteEditBox:GetText();
            NoteCount:SetText( charCount .. "/31");
            PlayerNoteEditBox:Show();
            NoteCount:Show();
        end 
    end);

    PlayerOfficerNoteWindow:SetScript ( "OnMouseDown" , function( self , button ) 
        if button == "LeftButton" and CanEditOfficerNote() then
            NoteCount:SetPoint ("TOPRIGHT" , PlayerOfficerNoteEditBox , -6 , 8 );
            GR_AddonGlobals [ "pause" ] = true;
            noteFontString2:Hide();
            PlayerNoteEditBox:Hide();
            tempNote = noteFontString1:GetText();
            if tempNote ~= defaultNote and tempNote ~= "" then
                finalNote = tempNote;
            else
                finalNote = "";
            end
            PlayerNoteEditBox:SetText( finalNote );
            noteFontString1:Show();

            local charCount = #PlayerOfficerNoteEditBox:GetText();      -- How many characters initially
            NoteCount:SetText( charCount .. "/31");
            PlayerOfficerNoteEditBox:Show();
            NoteCount:Show();
        end 
    end);


    -- Cancels editing in Note editbox
    PlayerNoteEditBox:SetScript ( "OnEscapePressed" , function ( self ) 
        PlayerNoteEditBox:Hide();
        NoteCount:Hide();
        tempNote = noteFontString1:GetText();
        if tempNote ~= defaultNote and tempNote ~= "" then
            finalNote = tempNote;
        else
            finalNote = "";
        end
        PlayerNoteEditBox:SetText( finalNote );
        noteFontString1:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GR_AddonGlobals [ "pause" ] = false;
        end
    end);

    -- Updates char count as player types.
    PlayerNoteEditBox:SetScript ( "OnChar" , function ( self , text ) 
        local charCount = #PlayerNoteEditBox:GetText();
        charCount = charCount;
        NoteCount:SetText( charCount .. "/31");
    end);

    -- Update on backspace changes too
    PlayerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
        if text == "BACKSPACE" then
            local charCount = #PlayerNoteEditBox:GetText();
            charCount = charCount - 1;
            if charCount == -1 then
                charCount = 0;
            end
            NoteCount:SetText( charCount .. "/31");
        end
    end);

    -- Updating the new information to Public Note
    PlayerNoteEditBox:SetScript ( "OnEnterPressed" , function ( self ) 
        local newNote = PlayerNoteEditBox:GetText();
        local name = GR_MemberDetailName:GetText();
        local guildName = GetGuildInfo("player");
        
        for i = 1 , #GR_GuildMemberHistory_Save do
            if GR_GuildMemberHistory_Save[i][1] == guildName then
                for j = 2 , #GR_GuildMemberHistory_Save[i] do
                    if GR_GuildMemberHistory_Save[i][j][1] == name then         -- Player Found and Located.
                        -- -- First, let's add the change to the official server-sde note
                        for h = 1,GetNumGuildies() do
                            local playerName,_,_,_,_,_,publicNote = GetGuildRosterInfo( h );
                            if SlimName(playerName) == name and publicNote ~= newNote and CanEditPublicNote() then      -- No need to update old note if it is the same.
                                GuildRosterSetPublicNote ( h , newNote );
                                -- To metadata save
                                RecordChanges ( 5 , { name , nil , nil , nil , newNote } , GR_GuildMemberHistory_Save[i][j] , guildName );
                                GR_GuildMemberHistory_Save[i][j][7] = newNote;
                                if #newNote == 0 then
                                    noteFontString1:SetText ( defaultNote );
                                else
                                    noteFontString1:SetText ( newNote );
                                end
                                PlayerNoteEditBox:SetText( newNote );
                                break;
                            end
                        end
                        break;
                    end
                end            
                break;
            end
        end
        PlayerNoteEditBox:Hide();
        NoteCount:Hide();
        noteFontString1:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GR_AddonGlobals [ "pause" ] = false;
        end
    end);

    PlayerOfficerNoteEditBox:SetScript ( "OnEscapePressed" , function ( self ) 
        PlayerOfficerNoteEditBox:Hide();
        NoteCount:Hide();
        tempNote = noteFontString2:GetText();
        if tempNote ~= defaultONote and tempNote ~= "" then
            finalNote = tempNote;
        else
            finalNote = "";
        end
        PlayerOfficerNoteEditBox:SetText( finalNote );
        noteFontString2:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GR_AddonGlobals [ "pause" ] = false;
        end
    end);

    -- Updates char count as player types.
    PlayerOfficerNoteEditBox:SetScript ( "OnChar" , function ( self , text ) 
        local charCount = #PlayerOfficerNoteEditBox:GetText();
        charCount = charCount;
        NoteCount:SetText( charCount .. "/31");
    end);

    -- Update on backspace changes too
    PlayerOfficerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
        if text == "BACKSPACE" then
            local charCount = #PlayerOfficerNoteEditBox:GetText();
            charCount = charCount - 1;
            if charCount == -1 then
                charCount = 0;
            end
            NoteCount:SetText( charCount .. "/31");
        end
    end);

     -- Updating the new information to Public Note
    PlayerOfficerNoteEditBox:SetScript ( "OnEnterPressed" , function ( self ) 
        local newNote = PlayerOfficerNoteEditBox:GetText();
        local name = GR_MemberDetailName:GetText();
        local guildName = GetGuildInfo("player");
        
        for i = 1 , #GR_GuildMemberHistory_Save do
            if GR_GuildMemberHistory_Save[i][1] == guildName then
                for j = 2 , #GR_GuildMemberHistory_Save[i] do
                    if GR_GuildMemberHistory_Save[i][j][1] == name then         -- Player Found and Located.
                        -- -- First, let's add the change to the official server-sde note
                        for h = 1,GetNumGuildies() do
                            local playerName,_,_,_,_,_,_,officerNote = GetGuildRosterInfo( h );
                            if SlimName(playerName) == name and officerNote ~= newNote and CanEditOfficerNote() then      -- No need to update old note if it is the same.
                                GuildRosterSetOfficerNote ( h , newNote );
                                -- To metadata save
                                RecordChanges ( 6 , { name , nil , nil , nil , nil , newNote } , GR_GuildMemberHistory_Save[i][j] , guildName );
                                GR_GuildMemberHistory_Save[i][j][8] = newNote;
                                if #newNote == 0 then
                                    noteFontString2:SetText ( defaultONote );
                                else
                                    noteFontString2:SetText ( newNote );
                                end
                                PlayerOfficerNoteEditBox:SetText( newNote );
                                break;
                            end
                        end
                        break;
                    end
                end            
                break;
            end
        end
        PlayerOfficerNoteEditBox:Hide();
        NoteCount:Hide();
        noteFontString2:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            GR_AddonGlobals [ "pause" ] = false;
        end
    end);
end


local function GR_MetaDataInitializeUISecond()
        -- ALT FRAME DETAILS!!!
    GR_CoreAltFrame:SetPoint ( "BOTTOMRIGHT" , MemberDetailMetaData , -13.5 , 16 );
    GR_CoreAltFrame:SetWidth ( 128 );
    GR_CoreAltFrame:SetHeight ( 140);
    GR_CoreAltFrame:SetParent ( MemberDetailMetaData );
    altFrameTitleText:SetPoint ( "TOP" , GR_CoreAltFrame , 3 , -4 );
    altFrameTitleText:SetText ( "Player Alts" );    
    altFrameTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11 , "THICKOUTLINE" );

    addAltButton:SetWidth ( 60 );
    addAltButton:SetHeight ( 17 );
    addAltButtonText:SetPoint ( "CENTER" , addAltButton );
    addAltButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    addAltButtonText:SetText( "Add Alt") ; 

    GR_AltName1:SetPoint ( "TOPLEFT" , GR_CoreAltFrame , 1 , -20 );
    GR_AltName1:SetWidth ( 60 );
    GR_AltName1:SetJustifyH ( "CENTER" );
    GR_AltName1:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName2:SetPoint ( "TOPRIGHT" , GR_CoreAltFrame , 0 , -20 );
    GR_AltName2:SetWidth ( 60 );
    GR_AltName2:SetJustifyH ( "CENTER" );
    GR_AltName2:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName3:SetPoint ( "TOPLEFT" , GR_CoreAltFrame , 1 , -37 );
    GR_AltName3:SetWidth ( 60 );
    GR_AltName3:SetJustifyH ( "CENTER" );
    GR_AltName3:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName4:SetPoint ( "TOPRIGHT" , GR_CoreAltFrame , 0 , -37 );
    GR_AltName4:SetWidth ( 60 );
    GR_AltName4:SetJustifyH ( "CENTER" );
    GR_AltName4:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName5:SetPoint ( "TOPLEFT" , GR_CoreAltFrame , 1 , -54 );
    GR_AltName5:SetWidth ( 60 );
    GR_AltName5:SetJustifyH ( "CENTER" );
    GR_AltName5:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName6:SetPoint ( "TOPRIGHT" , GR_CoreAltFrame , 0 , -54 );
    GR_AltName6:SetWidth ( 60 );
    GR_AltName6:SetJustifyH ( "CENTER" );
    GR_AltName6:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName7:SetPoint ( "TOPLEFT" , GR_CoreAltFrame , 1 , -71 );
    GR_AltName7:SetWidth ( 60 );
    GR_AltName7:SetJustifyH ( "CENTER" );
    GR_AltName7:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName8:SetPoint ( "TOPRIGHT" , GR_CoreAltFrame , 0 , -71 );
    GR_AltName8:SetWidth ( 60 );
    GR_AltName8:SetJustifyH ( "CENTER" );
    GR_AltName8:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName9:SetPoint ( "TOPLEFT" , GR_CoreAltFrame , 1 , -88 );
    GR_AltName9:SetWidth ( 60 );
    GR_AltName9:SetJustifyH ( "CENTER" );
    GR_AltName9:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName10:SetPoint ( "TOPRIGHT" , GR_CoreAltFrame , 0 , -88 );
    GR_AltName10:SetWidth ( 60 );
    GR_AltName10:SetJustifyH ( "CENTER" );
    GR_AltName10:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName11:SetPoint ( "TOPLEFT" , GR_CoreAltFrame , 1 , -105 );
    GR_AltName11:SetWidth ( 60 );
    GR_AltName11:SetJustifyH ( "CENTER" );
    GR_AltName11:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    GR_AltName12:SetPoint ( "TOPRIGHT" , GR_CoreAltFrame , 0 , -105 );
    GR_AltName12:SetWidth ( 60 );
    GR_AltName12:SetJustifyH ( "CENTER" );
    GR_AltName12:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.5 );

    -- ALT DROPDOWN OPTIONS
    altDropDownOptions:SetPoint ( "BOTTOMRIGHT" , MemberDetailMetaData , 15 , 0 );
    altDropDownOptions:SetWidth ( 65 );
    altDropDownOptions:SetHeight ( 92 );
    altDropDownOptions:SetBackdrop ( noteBackdrop2 );
    altDropDownOptions:SetFrameStrata ( "FULLSCREEN_DIALOG" );
    altOptionsText:SetPoint ( "TOPLEFT" , altDropDownOptions , 7 , -13 );
    altOptionsText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    altOptionsText:SetText ( "Options" );
    altSetMainButton:SetPoint ("TOPLEFT" , altDropDownOptions , 7 , -22 );
    altSetMainButton:SetWidth ( 60 );
    altSetMainButton:SetHeight ( 20 );
    altSetMainButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    altSetMainButtonText:SetPoint ( "LEFT" , altSetMainButton );
    altSetMainButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    altRemoveButton:SetPoint ( "TOPLEFT" , altDropDownOptions , 7 , -36 );
    altRemoveButton:SetWidth ( 60 );
    altRemoveButton:SetHeight ( 20 );
    altRemoveButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    altRemoveButtonText:SetPoint ( "LEFT" , altRemoveButton );
    altRemoveButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    altRemoveButtonText:SetText( "Remove" );
    altOptionsDividerText:SetPoint ( "TOPLEFT" , altDropDownOptions , 7 , -55 );
    altOptionsDividerText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    altOptionsDividerText:SetText ("__");
    altFrameCancelButton:SetPoint ( "TOPLEFT" , altDropDownOptions , 7 , -65 );
    altFrameCancelButton:SetWidth ( 60 );
    altFrameCancelButton:SetHeight ( 20 );
    altFrameCancelButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    altFrameCancelButtonText:SetPoint ( "LEFT" , altFrameCancelButton );
    altFrameCancelButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    altFrameCancelButtonText:SetText ( "Cancel" );
  
    --ADD ALT FRAME
    AddAltEditFrame:SetPoint ( "BOTTOMLEFT" , MemberDetailMetaData , "BOTTOMRIGHT" ,  -7 , 0 );
    AddAltEditFrame:SetWidth ( 130 );
    AddAltEditFrame:SetHeight ( 170 );
    AddAltTitleText:SetPoint ( "TOP" , AddAltEditFrame , 0 , - 20 );
    AddAltTitleText:SetFont ( "Fonts\\FRIZQT__.TTF" , 11 , "THICKOUTLINE" );
    AddAltTitleText:SetText ( "Choose Alt" );
    AddAltNameButton1:SetPoint ( "TOP" , AddAltEditFrame , 7 , -54 );
    AddAltNameButton1:SetWidth ( 100 );
    AddAltNameButton1:SetHeight ( 15 );
    AddAltNameButton1:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    AddAltNameButton1:Disable();
    AddAltNameButton1Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltNameButton1Text:SetPoint ( "LEFT" , AddAltNameButton1 );
    AddAltNameButton1Text:SetJustifyH ( "LEFT" );
    AddAltNameButton2:SetPoint ( "TOP" , AddAltEditFrame , 7 , -69 );
    AddAltNameButton2:SetWidth ( 100 );
    AddAltNameButton2:SetHeight ( 15 );
    AddAltNameButton2:Disable();
    AddAltNameButton2:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    AddAltNameButton2Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltNameButton2Text:SetPoint ( "LEFT" , AddAltNameButton2 );
    AddAltNameButton2Text:SetJustifyH ( "LEFT" );
    AddAltNameButton3:SetPoint ( "TOP" , AddAltEditFrame , 7 , -84 );
    AddAltNameButton3:SetWidth ( 100 );
    AddAltNameButton3:SetHeight ( 15 );
    AddAltNameButton3:Disable();
    AddAltNameButton3:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    AddAltNameButton3Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltNameButton3Text:SetPoint ( "LEFT" , AddAltNameButton3 );
    AddAltNameButton3Text:SetJustifyH ( "LEFT" );
    AddAltNameButton4:SetPoint ( "TOP" , AddAltEditFrame , 7 , -99 );
    AddAltNameButton4:SetWidth ( 100 );
    AddAltNameButton4:SetHeight ( 15 );
    AddAltNameButton4:Disable();
    AddAltNameButton4:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    AddAltNameButton4Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltNameButton4Text:SetPoint ( "LEFT" , AddAltNameButton4 );
    AddAltNameButton4Text:SetJustifyH ( "LEFT" );
    AddAltNameButton5:SetPoint ( "TOP" , AddAltEditFrame , 7 , -114 );
    AddAltNameButton5:SetWidth ( 100 );
    AddAltNameButton5:SetHeight ( 15 );
    AddAltNameButton5:Disable();
    AddAltNameButton5:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    AddAltNameButton5Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltNameButton5Text:SetPoint ( "LEFT" , AddAltNameButton5 );
    AddAltNameButton5Text:SetJustifyH ( "LEFT" );
    AddAltNameButton6:SetPoint ( "TOP" , AddAltEditFrame , 7 , -129 );
    AddAltNameButton6:SetWidth ( 100 );
    AddAltNameButton6:SetHeight ( 15 );
    AddAltNameButton6:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
    AddAltNameButton6:Disable();
    AddAltNameButton6Text:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltNameButton6Text:SetPoint ( "LEFT" , AddAltNameButton6 );
    AddAltNameButton6Text:SetJustifyH ( "LEFT" );
    AddAltEditFrameTextBottom:SetPoint ( "TOP" , AddAltEditFrame , -18 , -146 );
    AddAltEditFrameTextBottom:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltEditFrameTextBottom:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
    AddAltEditFrameTextBottom:SetText ( "(Press Tab)" );
    AddAltEditFrameHelpText:SetPoint ( "CENTER" , AddAltEditFrame )
    AddAltEditFrameHelpText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltEditFrameHelpText:SetTextColor ( 1.0 , 0 , 0 , 1.0 );
    
    AddAltEditBox:SetPoint( "TOP" , AddAltEditFrame , 2.5 , -30 );
    AddAltEditBox:SetWidth ( 95 );
    AddAltEditBox:SetHeight ( 25 );
    AddAltEditBox:SetTextInsets( 2 , 3 , 3 , 2 );
    AddAltEditBox:SetMaxLetters ( 12 );
    AddAltEditBox:SetFont( "Fonts\\FRIZQT__.TTF" , 8 );
    AddAltEditBox:EnableMouse( true );
    AddAltEditBox:SetAutoFocus( false );

    -- ALT EDIT BOX LOGIC
    addAltButton:SetScript ( "OnClick" , function ( _ , button) 
        if button == "LeftButton" then
            GR_AddonGlobals [ "pause" ] = true;
            AddAltEditBox:SetAutoFocus( true );
            AddAltEditBox:SetText( "" );
            AddAltAutoComplete();
            AddAltEditFrame:Show();
            AddAltEditBox:SetAutoFocus( false );
            
        end
    end)


    AddAltEditBox:SetScript ( "OnEscapePressed" , function( _ )
        AddAltEditBox:ClearFocus();    
    end);

    AddAltEditBox:SetScript ( "OnEnterPressed" , function( _ )
        if AddAltEditBox:HasFocus() then
            local currentText = AddAltEditBox:GetText();
            if currentText ~= nil and currentText ~= "" then
                local notFound = true;
                if GR_AddonGlobals[ "currentHighlightIndex" ] == 1 and AddAltNameButton1Text:GetText() ~= currentText then
                    AddAltEditBox:SetText ( AddAltNameButton1Text:GetText() );
                    notFound = false;
                elseif notFound and GR_AddonGlobals[ "currentHighlightIndex" ] == 2 and AddAltNameButton2Text:GetText() ~= currentText then
                    AddAltEditBox:SetText ( AddAltNameButton2Text:GetText() );
                    notFound = false;
                elseif notFound and GR_AddonGlobals[ "currentHighlightIndex" ] == 3 and AddAltNameButton3Text:GetText() ~= currentText then
                    AddAltEditBox:SetText ( AddAltNameButton3Text:GetText() );
                    notFound = false;
                elseif notFound and GR_AddonGlobals[ "currentHighlightIndex" ] == 4 and AddAltNameButton4Text:GetText() ~= currentText then
                    AddAltEditBox:SetText ( AddAltNameButton4Text:GetText() );
                    notFound = false;
                elseif notFound and GR_AddonGlobals[ "currentHighlightIndex" ] == 5 and AddAltNameButton5Text:GetText() ~= currentText then
                    AddAltEditBox:SetText ( AddAltNameButton5Text:GetText() );
                    notFound = false;
                elseif notFound and GR_AddonGlobals[ "currentHighlightIndex" ] == 6 and AddAltNameButton6Text:GetText() ~= currentText then
                    AddAltEditBox:SetText ( AddAltNameButton6Text:GetText() );
                    notFound = false;
                end

                if notFound then
                    -- Add the alt here, Hide the frame
                    local guildName = GetGuildInfo("player");
                    AddAlt ( GR_MemberDetailNameText:GetText() , AddAltEditBox:GetText() , guildName );
                    AddAltEditBox:ClearFocus();
                    AddAltEditFrame:Hide();
                end
            else
                print ( "Please choose a character to set as alt." );
            end
        end
    end);

    AddAltNameButton1:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            AddAltEditBox:SetText ( AddAltNameButton1Text:GetText() );
            AddAltAutoComplete();
        end
    end);
    AddAltNameButton2:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            AddAltEditBox:SetText ( AddAltNameButton2Text:GetText() );
            AddAltAutoComplete();
        end
    end);
    AddAltNameButton3:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            AddAltEditBox:SetText ( AddAltNameButton3Text:GetText() );
            AddAltAutoComplete();
        end
    end);
    AddAltNameButton4:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            AddAltEditBox:SetText ( AddAltNameButton4Text:GetText() );
            AddAltAutoComplete();
        end
    end);
    AddAltNameButton5:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            AddAltEditBox:SetText ( AddAltNameButton5Text:GetText() );
            AddAltAutoComplete();
        end
    end);
    AddAltNameButton6:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            AddAltEditBox:SetText ( AddAltNameButton6Text:GetText() );
            AddAltAutoComplete();
        end
    end);

    -- Updating with each character typed
    AddAltEditBox:SetScript ( "OnChar" , function ( _ , text ) 
        AddAltAutoComplete();
    end);

    -- When pressing backspace.
    AddAltEditBox:SetScript ( "OnKeyDown" , function ( _ , key)
        if key == "BACKSPACE" then
            local text = AddAltEditBox:GetText();
            if text ~= nil and #text > 0 then
                AddAltEditBox:SetText ( string.sub ( text , 0 , #text - 1 ) ); -- Bring it down by 1 for function, then return to normal.
            end
            AddAltAutoComplete();
            AddAltEditBox:SetText( text ); -- set back to normal for normal Backspace upkey function... if I do not do this, it will delete 2 characters.
        end
    end);

    AddAltEditBox:SetScript ( "OnTabPressed" , function ( _ )
        local notSet = true;
        if IsShiftKeyDown() ~= true then
            if GR_AddonGlobals[ "currentHighlightIndex" ] == 1 and notSet then
                if AddAltNameButton2:IsVisible() then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 2;
                    AddAltNameButton1:UnlockHighlight();
                    AddAltNameButton2:LockHighlight();
                    notSet = false;
                end
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 2 and notSet then
                if AddAltNameButton3:IsVisible() then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 3;
                    AddAltNameButton2:UnlockHighlight();
                    AddAltNameButton3:LockHighlight();
                    notSet = false;
                else
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
                    AddAltNameButton2:UnlockHighlight();
                    AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 3 and notSet then
                if AddAltNameButton4:IsVisible() then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 4;
                    AddAltNameButton3:UnlockHighlight();
                    AddAltNameButton4:LockHighlight();
                    notSet = false;
                else
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
                    AddAltNameButton3:UnlockHighlight();
                    AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 4 and notSet then
                if  AddAltNameButton5:IsVisible() then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 5;
                    AddAltNameButton4:UnlockHighlight();
                    AddAltNameButton5:LockHighlight();
                    notSet = false;
                else
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
                    AddAltNameButton4:UnlockHighlight();
                    AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 5 and notSet then
                if AddAltNameButton6:IsVisible() and AddAltNameButton6Text:GetText() ~= "..." then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 6;
                    AddAltNameButton5:UnlockHighlight();
                    AddAltNameButton6:LockHighlight();
                    notSet = false;
                elseif ( AddAltNameButton6:IsVisible() and AddAltNameButton6Text:GetText() == "..." ) or AddAltNameButton6:IsVisible() ~= true then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
                    AddAltNameButton5:UnlockHighlight();
                    AddAltNameButton1:LockHighlight();
                    notSet = false;
                end
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 6 then
                GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
                AddAltNameButton6:UnlockHighlight();
                AddAltNameButton1:LockHighlight();
                notSet = false;
            end
        else
            -- if at position 1... shift-tab goes back to any position.
            if GR_AddonGlobals[ "currentHighlightIndex" ] == 1 and notSet then
                if AddAltNameButton6:IsVisible() and AddAltNameButton6Text:GetText() ~= "..."  and notSet then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 6;
                    AddAltNameButton1:UnlockHighlight();
                    AddAltNameButton6:LockHighlight();
                    notSet = false;
                elseif ( ( AddAltNameButton6:IsVisible() and AddAltNameButton6Text:GetText() == "..." ) or ( AddAltNameButton5:IsVisible() ) ) and notSet then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 5;
                    AddAltNameButton1:UnlockHighlight();
                    AddAltNameButton5:LockHighlight();
                    notSet = false;
                elseif AddAltNameButton4:IsVisible() and notSet then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 4;
                    AddAltNameButton1:UnlockHighlight();
                    AddAltNameButton4:LockHighlight();
                    notSet = false;
                elseif AddAltNameButton3:IsVisible() and notSet then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 3;
                    AddAltNameButton1:UnlockHighlight();
                    AddAltNameButton3:LockHighlight();
                    notSet = false;
                elseif AddAltNameButton2:IsVisible() and notSet then
                    GR_AddonGlobals[ "currentHighlightIndex" ] = 2;
                    AddAltNameButton1:UnlockHighlight();
                    AddAltNameButton2:LockHighlight();
                    notSet = false;
                end
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 2 and notSet then
                GR_AddonGlobals[ "currentHighlightIndex" ] = 1;
                AddAltNameButton2:UnlockHighlight();
                AddAltNameButton1:LockHighlight();
                notSet = false;
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 3 and notSet then
                GR_AddonGlobals[ "currentHighlightIndex" ] = 2;
                AddAltNameButton3:UnlockHighlight();
                AddAltNameButton2:LockHighlight();
                notSet = false;
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 4 and notSet then
                GR_AddonGlobals[ "currentHighlightIndex" ] = 3;
                AddAltNameButton4:UnlockHighlight();
                AddAltNameButton3:LockHighlight();
                notSet = false;
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 5 and notSet then
                GR_AddonGlobals[ "currentHighlightIndex" ] = 4;
                AddAltNameButton5:UnlockHighlight();
                AddAltNameButton4:LockHighlight();
                notSet = false;
            elseif GR_AddonGlobals[ "currentHighlightIndex" ] == 6 and notSet then
                GR_AddonGlobals[ "currentHighlightIndex" ] = 5;
                AddAltNameButton6:UnlockHighlight();
                AddAltNameButton5:LockHighlight();
                notSet = false;
            end
        end
    end);
    
    AddAltEditFrame:SetScript ( "OnKeyDown" , function ( _ , key )
        AddAltEditFrame:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            AddAltEditFrame:SetPropagateKeyboardInput ( false );
            AddAltEditFrame:Hide();
        end
    end);

    -- ALT FRAME LOGIC
    altSetMainButton:SetScript ( "OnClick" , function ( _ , button )
        
        if button == "LeftButton" then
            local altDetails = GR_AddonGlobals [ "selectedAlt" ];
            if altSetMainButtonText:GetText() == "Set as Main" then
                SetMain ( altDetails[1] , altDetails[2] , altDetails[3] );
                print ( altDetails[2] .. " is now set as \"main\"" );
            elseif altSetMainButtonText:GetText() == "Set as Alt" then
                DemoteFromMain ( altDetails[1] , altDetails[2] , altDetails[3] );
                print ( altDetails[2] .. " is no longer set as \"main\"" );
            elseif altSetMainButtonText:GetText() == "Edit Date" then
                GR_MemberDetailRankDateTxt:Hide();
                if GR_AddonGlobals [ "editPromoDate" ] then
                    SetPromoDateButton:Click();
                    GR_DateSubmitButtonTxt:SetText ( "Edit Promo Date" );
                elseif GR_AddonGlobals [ "editJoinDate" ] then
                    GR_JoinDateText:Hide();
                    MemberDetailJoinDateButton:Click();
                    GR_DateSubmitButtonTxt:SetText ( "Edit Join Date" );
                end
            end
            altDropDownOptions:Hide();
        end    
    end);

    -- Also functions to clear history...
    altRemoveButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local buttonName = altRemoveButtonText:GetText();
            local altDetails = GR_AddonGlobals [ "selectedAlt" ];
            if buttonName == "Remove" then
                RemoveAlt ( altDetails[1] , altDetails[2] , altDetails[3] );
                altDropDownOptions:Hide();
            elseif buttonName == "Clear History" then
                if GR_AddonGlobals [ "editPromoDate" ] then
                    ClearPromoDateHistory ( altDetails[1] );
                elseif GR_AddonGlobals [ "editJoinDate" ] then
                    ClearJoinDateHistory ( altDetails[1] );
                end
            end
        end
    end);

    altFrameCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            altDropDownOptions:Hide();
            GR_AddonGlobals [ "pause" ] = false;
        end
    end);

    altDropDownOptions:SetScript ( "OnKeyDown" , function ( _ , key )
        altDropDownOptions:SetPropagateKeyboardInput ( true );      -- Ensures keyboard access will default to the main chat window on / or Enter. UX feature.
        if key == "ESCAPE" then
            altDropDownOptions:SetPropagateKeyboardInput ( false );
            altDropDownOptions:Hide();
        end
    end);

end



-- Method:              GR_Roster_Click ( self, string )
-- What it Does:        For logic on mouseover, instead of mouseover, it simulates a click on the item by bringing it to show.
--                      The "pause" is just a call to pause the hiding of the frame in the GR_RosterFrame() function until it finds a new window (to prevent wasteful clicking and resource hogging)
-- Purpose:             Smoother UI interface in the built-in Guild Roster in-game UI default window.
local function GR_Roster_Click  ( _ , button )

    if button == "LeftButton" then
        GuildMemberDetailFrame:Hide();
        local time = GetTime();
        local length = 84;
        if GR_AddonGlobals [ "timer3" ] == 0 or time - GR_AddonGlobals[ "timer3" ] > 0.1 then   -- 100ms
            local name = "";        -- Copy Player Name - Just UX and QoL features!
            local MobileIconCheck = "";
            if GuildRosterContainerButton1:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton1String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton1String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton1String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton1String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton1String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton2:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton2String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton2String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton2String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton2String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton2String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton3:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton3String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton3String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton3String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton3String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton3String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton4:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton4String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton4String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton4String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton4String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton4String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton5:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton5String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton5String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton5String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton5String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton5String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton6:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton6String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton6String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton6String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton6String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton6String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton7:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton7String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton7String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton7String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton7String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton7String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton8:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton8String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton8String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton8String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton8String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton8String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton9:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton9String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton9String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton9String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton9String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton9String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton10:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton10String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton10String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton10String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton10String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton10String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton11:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton11String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton11String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton11String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton11String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton11String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton12:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton12String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton12String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton12String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton12String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton12String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton13:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton13String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton13String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton13String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton13String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton13String1:GetText();
                    end
                end
            elseif GuildRosterContainerButton14:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                name = GuildRosterContainerButton14String1:GetText();
                if tonumber ( name ) ~= nil then
                    MobileIconCheck = "\"" .. GuildRosterContainerButton14String2:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton14String2:GetText();
                    end
                else
                    MobileIconCheck = "\"" .. GuildRosterContainerButton14String1:GetText() .. "\"";
                    if #MobileIconCheck > 50 then
                        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                            length = 85
                        end
                        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
                    else
                        name = GuildRosterContainerButton14String1:GetText();
                    end
                end
            end

            -- We are going to be copying the name if the shift key is down!
            if IsShiftKeyDown() then                        
                if ( AddAltEditFrame:IsVisible() and AddAltEditBox:HasFocus() ) or ( ChatFrame1EditBox:IsVisible() and ChatFrame1EditBox:HasFocus() ) then
                    
                    if ChatFrame1EditBox:HasFocus() then                -- Default Message Chat Frame!
                        ChatFrame1EditBox:SetText ( name );
                    elseif AddAltEditBox:HasFocus() then                -- No No! Send to the altadd frame!
                        if name == GR_MemberDetailNameText:GetText() then
                            print (name .. " cannot add themselves to alt list!" );  
                        else
                            AddAltEditBox:SetText ( name );
                            AddAltAutoComplete();
                        end
                    end                
                end
            else
                if GR_AddonGlobals [ "pause" ] and name ~= GR_MemberDetailNameText:GetText() then
                    GR_AddonGlobals [ "pause" ] = false;
                    GR_RosterFrame ( _ , 0.075 );           -- Activate one time.
                    GR_AddonGlobals [ "pause" ] = true;
                else
                    GR_AddonGlobals [ "pause" ] = true;
                end
            end
            GR_AddonGlobals [ "timer3" ] = time;
        end
    end
end

-- if no main, then in the popup window, have focus' name popup with options to set as main as well.


-- Method:              InitiateMemberDetailFrame(self,event,msg)
-- What it Does:        Event Listener, it activates when the Guild Roster window is opened and interface is queried/triggered
--                      "GuildRoster()" needs to fire for this to activate as it creates the following 4 listeners this is looking for: GUILD_NEWS_UPDATE, GUILD_RANKS_UPDATE, GUILD_ROSTER_UPDATE, and GUILD_TRADESKILL_UPDATE
-- Purpose:             Create an Event Listener for the Guild Roster Frame in the guild window ('J' key)
local function InitiateMemberDetailFrame(self,event,msg)

    if GuildRosterFrame ~= nil and GuildRosterFrame:IsVisible() then
        -- Member Detail Frame Info
        GR_MetaDataInitializeUIFirst(); -- Initializing Frames
        GR_MetaDataInitializeUISecond(); -- To avoid 60 upvalue Lua cap, place them in second list.
       
        -- Roster Positions
        GuildRosterFrame:HookScript ( "OnUpdate" , GR_RosterFrame );
        GuildFrameCloseButton:HookScript ( "OnClick" , function ( _ , button ) 
            MemberDetailMetaData:Hide();
        end);
        
        GuildRosterContainerButton1:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton2:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton3:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton4:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton5:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton6:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton7:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton8:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton9:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton10:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton11:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton12:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton13:HookScript ( "OnClick" , GR_Roster_Click );
        GuildRosterContainerButton14:HookScript ( "OnClick" , GR_Roster_Click );
    end
end




------------------------------------------------
------------------------------------------------
----- INITIALIZATION AND LIVE TRACKING ---------
------------------------------------------------
------------------------------------------------








-- Method:          Tracking()
-- What it Does:    Checks the Roster once in a repeating time interval as long as player is in a guild
-- Purpose:         Constant checking for roster changes. Flexibility in timing changes. Default set to 10 now, could be 30 or 60.
local function Tracking()
    if IsInGuild() then
        local timeCallJustOnce = time();
        if GR_AddonGlobals [ "timeDelayValue" ] == 0 or (timeCallJustOnce - GR_AddonGlobals [ "timeDelayValue" ] ) > 5 then -- Initial scan is zero.
            local guildName = GetGuildInfo("player");
            GR_AddonGlobals [ "timeDelayValue" ] = timeCallJustOnce;
            BuildNewRoster();
            CheckPlayerEvents( guildName );
            FinalReport();

            -- Prevent from re-scanning changes
           GR_AddonGlobals [ "LastOnlineNotReported" ] = false;
        end
        C_Timer.After( CustomizationGlobals [ "HowOftenToCheck" ] , Tracking); -- Recursive check every 10 seconds.
    end
end

-- Method:          GR_LoadAddon()
-- What it Does:    Enables tracking of when a player joins the guild or leaves the guild. Also fires upon login.
-- Purpose:         Manage tracking guild info. No need if player is not in guild, or to reactivate when player joins guild.
local function GR_LoadAddon()
    GeneralEventTracking:RegisterEvent("PLAYER_GUILD_UPDATE"); -- If player leaves or joins a guild, this should fire.
    GeneralEventTracking:SetScript("OnEvent", ManageGuildStatus);
    UI_Events:RegisterEvent("GUILD_ROSTER_UPDATE");
    UI_Events:RegisterEvent("GUILD_RANKS_UPDATE");
    UI_Events:RegisterEvent("GUILD_NEWS_UPDATE");
    UI_Events:RegisterEvent("GUILD_TRADESKILL_UPDATE");
    UI_Events:SetScript("OnEvent",InitiateMemberDetailFrame)
    Tracking();
end

-- Method           ManageGuildStatus()
-- What it Does:    If player leaves or joins the guild, it deactivates/reactivates tracking - as well as re-checks guild to see if rejoining or new guild.    
-- Purpose:         Efficiency in resource use to prevent unnecessary tracking of info if out of the guild.
function ManageGuildStatus(self,event,msg)
    if GR_AddonGlobals [ "guildStatusChecked" ] ~= true then
       GR_AddonGlobals [ "timeDelayValue" ] = time(); -- Prevents it from doing "IsInGuild()" too soon by resetting timer as server reaction is slow.
    end

    if GR_AddonGlobals [ "timeDelayValue" ] == 0 or (time() - GR_AddonGlobals [ "timeDelayValue" ] ) > 3 then -- Let's do a recheck on guild status to prevent unnecessary scanning.
        if IsInGuild() then

            local guildName = GetGuildInfo("player");
            print("Player is in guild SUCCESS!");
            print("Reactivating Tracking");
            GR_AddonGlobals [ "PlayerIsCurrentlyInGuild" ] = true;
            Tracking();
        else
            print("player no longer in guild confirmed!"); -- Store the data.
            GR_AddonGlobals [ "PlayerIsCurrentlyInGuild" ] = false;
            GR_LoadAddon();
        end
       GR_AddonGlobals [ "guildStatusChecked" ] = false;
    else
        GR_AddonGlobals [ "guildStatusChecked" ] = true;
        C_Timer.After(4,ManageGuildStatus); -- Recursively re-check on guild status trigger.
    end
end

-- Method:          ActivateAddon(self,event,addonName)
-- What it Does:    First, doesn't trigger to load until all variables of addon fully loaded.
--                  Then, it triggers to delay until player is fully in the world, in that order.
--                  Finally, it delays 5 seconds upon querying server as often initial Roster and Guild Event Log query takes a moment to return info.
-- Purpose:         To ensure the smooth handling and loading of the addon so all information is accurate before attempting to parse guild info.
function ActivateAddon(self,event,addon)
    if event == "ADDON_LOADED" then
    -- initiate addon once all variable are loaded.
        if addon == "Guild_Roster_Manager" then
            Initialization:RegisterEvent("PLAYER_ENTERING_WORLD"); -- Ensures this check does not occur until after Addon is fully loaded.
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if IsInGuild() then
            Initialization:UnregisterEvent("PLAYER_ENTERING_WORLD");
            Initialization:UnregisterEvent("ADDON_LOADED");     -- no need to keep scanning these after full loaded.
            GuildRoster();                                      -- Initial queries...
            QueryGuildEventLog();
            C_Timer.After(5,GR_LoadAddon);                      -- Queries do not return info immediately, gives server a 5 second delay.
        else
            ManageGuildStatus();
        end
    end
end

Initialization:RegisterEvent("ADDON_LOADED");
Initialization:SetScript("OnEvent",ActivateAddon);



-- Long Term goals
    -- Guild Recognition
    -- Auto-adding guild events like anniversary dates of players

    -- Interesting stat reporting with weekly updates
        -- Like number of legendaries collected this weekly
        -- Notable achievements, like Prestige advancements
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Notable high ilvl notifications with adjustable threshold to trigger it

    -- Anniversary and Birthday tracking, or other notable events "Custom data to track for reminder"

    -- >>>>>>>>>>>>>>>>>>>>> NEXT ONE TO CHECK RIGHT HERE!
    -- check data since last online.
    -- Give this update upon login.
    -- >>>>>>>>>>>>>>>>>>>>> REPORTING INFO RIGHT HERE!!!

    -- Professions... if they cap them... notable important recipes learned... If they change them.

    -- if player is currently in a guild or not in a guild "updateGuildStatusToSaveFile()" at very end tag true/false if in it?
    -- Logentry, if player joins a new guild it breaks a couple of spaces in the entry, reports guild nameChange, with NEW guild name in center, then breaks a few more spaces. #Aesthetics

    -- Add Reminders (Promotion Reminders) - Slash command or button to create reminder to promote someone (off schedule).
    -- GUILD REMINDERS!!!!!!!!!!!!!!!!!!!!!!!!! Create in-game reminders for yourself or related to the guild!

    -- Sort guild roster by "Time in guild" - possible in built-in UI? - need to complete "Total time in the guild".

    -- WorldFrame > GuildMemberDetailFrame

    -- /roster will be the slash comman

    -- Notable dates in History!

    -- Longest period of time player was inactive.
    -- Add slash command to ban player, which simultaneously gkicks them.
    -- # times signed up for event. (attended?)
    -- Search of the History Window
    -- Filters
    -- Export to PDF
    -- Export to TXT
    -- Export to Excel?

    -- Remaining Characters Count on Message of the Day).

    -- Check for Guild Name Change

    -- Review how to check if it is a namechange by checking metadata.
       
    -- Customize notifications for guild promotions!

    -- Options to only track some features, not all...

    
    -- Fix logic on returning to old guild it refreshes data.


    -- UI ADDITIONS TO BE ADDED
    -- SLASH COMMANDS!!!!!
    -- /ban "PlayerName"   >>> gkick player if they are still in the guild. Immediately bring up popup box to enter reason why.
    --          If player hits ignore it wipes the "PreviouslyBanned" boolean to false and clears the banned reason note
    -- Add tooltip to level hover "Leveling Milestones while in Guild!"  -- GUILD FIRSTS FOR EXPANSION LEVELS? First 3!
    -- Add Professions info and their levels.

    -- Click on alt name and it brings up their screen.

    -- GUILD EVENT AND RAID GROUP INFO
    -- Mark attendance for all in raid +1
    -- Raid window - Number of guildies in current group
    -- Request Assist Button  -- Requests assist from raid leader 
    -- Invite everyone online to guild group
    -- On rank promotion, change the text right away!

    -- POTENTIAL FEATURES
    -- if player is listed as an alt, but there are designated "alt ranks" and the player is not in it... report it?
    -- Add method that increments up by 1 a tracker on num events attended, the date, total events attended, for each person that is in the raid 100group.

    -- LIST OF FEATURES!!!
            -- Will be long!

    -- PROFESSIONS ADDING
    -- ANNIVERSARY REMINDERS
    -- BIRTHDAY
    -- When mousing over guild profession screen, metadata window should not pop.
    -- Mouseover - player level on joining.
    -- On changing anniversary date, or changing "Join Date" , player should check to see if [22][1][2] == true, and if so, then the anniversary date was placed in the calendar and should be removed and [22][1][2] should be reset to false;
    -- Method that cleans and purgers anniversary dates after they expire after a given set of time from the calendar? (probably not needed, but maybe optional feature)
    -- instead of ~= true, I should write "not" before the boolean