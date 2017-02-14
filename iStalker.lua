-- Author: TheGenomeWhisperer

-- SLASH_GMM1 = '/gmm';
-- SLASH_GMM2 = '/GMM';
-- SLASH_GMM3 = '/roster';
-- SLASH_GMM4 = '/Roster';

-- Saved Variables
GMM_Roster_Save = {}; -- 2D array
GMM_ChangeReport_Save = {}; -- Each index of array will be a line for output

local numGuildMembers;
local numOnlineGuildMembers;
local numAlts;
local numUniqueAccounts;
local numMobile;

local LogEvent = CreateFrame("Frame");

-- Method           Initialize()
-- What it does:    Re-initializes the addon on startup and/or on joining a guild
-- Purpose:         Efficiency to cut on unnecessary process power use
local function Initialize()

end


-- Method:          SlimName(string)
-- What it does:    Removes the server name after character name.
-- Purpose:         Server name is not important in a guild since all will be server name.
local function SlimName(name)
    return strsub(name,1,string.find(name,"-")-1);
end

-- Method:          GetNumGuildies()
-- What it does:    Returns the int number of total toons within the guild, including main/alts
-- Purpose:         For book-keeping and tracking total guild membership.
local function GetNumGuildies()
    local numMembers = GetNumGuildMembers();
    return numMembers;
end

-- Method:          GetNumUniqueAccounts()
-- What it does:    Returns the int number of Unique accounts in the guild, so main and alts counts as ONE
-- Purpose:         To know the true number of real people playing in the guild
local function GetNumUniqueAccounts()

end

-- Method           RecordChanges()
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
local function RecordChanges()

end

local function CheckPlayerChanges(metaData)
    -- Checking changes
    local newPlayerFound;
    for i,#metaData do
        newPlayerFound = true;
        for j,#GMM_Roster_Save do
            if metaData[i][1] == GMM_Roster_Save[j][1] then
                -- Checking for changes now.
                for k = 2,7 do
                    if metaData[i][k] ~= GMM_Roster_Save[j][k] then
                        -- recordChange()
                        newPlayerFound = false;
                    end
                end
            end
        end
        -- NEW PLAYER FOUND!
        if newPlayerFound then
            -- recordChange(), Add the new player - or check if it was a name change
        end
    end
    -- Checking if any players left the guild
    local playerLeftGuild;
    for i,#GMM_Roster_Save do
         playerLeftGuild = true;
        for j,#metaData do
            if GMM_Roster_Save[i][1] == metaData[j][1] then
                playerLeftGuild = false;
                break;
            end
        end
        -- PLAYER LEFT THE GUILD_EVENT_LOG_UPDATE
        if playerLeftGuild then
            -- recordChange(), Remove the player - or check if it was a namechange.
        end
    end
end

local function GetTimestamp()
    -- Time Variables
    local morning = true;
    local timestamp = date("*t");
    local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
    local year,days,minutes,hour,month = 0;
    for x,y in pairs(timestamp) do
        if x == "hour" then
            hour = y;
        elseif x == "min" then
            minutes = y;
        elseif x == "day" then
            days = y;
        elseif x == "month" then
            month = y;
        elseif x == "year" then
            year = y;
        end
    end
    
    -- Swap from military time
    if hour > 12 then
        hour = hour - 12;
        morning = false;
    elseif hour == 0 then
        hour = 12;
    end
    -- Establishing proper format
    local time = "";
    if morning then
        time = (months[month] .. " " .. days .. ", " .. year .. " " .. hour .. ":" .. minutes .. "am");
    else
        time = (months[month] .. " " .. days .. ", " .. year .. " " .. hour .. ":" .. minutes .. "pm");
    end
    return string.format(time);
end


-- Method:          BuildNewRoster()
-- What it does:    Rebuilds the roster to check against for any changes.
-- Purpose:         To avoid unnecessary reprocessing of the entire guild and to only do this the first time.
function BuildNewRoster()
    local roster = {};
    for i = 1,GetNumGuildies() do
        local name, rank, rankIndex, level, _, _, note, officerNote, _, _, class = GetGuildRosterInfo(i);
        roster[i] = {};
        roster[i][1] = SlimName(name);
        roster[i][2] = rank;
        roster[i][3] = rankIndex;
        roster[i][4] = level;
        roster[i][5] = note;
        roster[i][6] = officerNote;
        roster[i][7] = class;
    end

    -- Now checking for first time
    if GMM_Roster_Save[1] == nil then
        GMM_Roster_Save = roster;
        GMM_Roster_Save[#GMM_Roster_Save+1] = "";
        GMM_Roster_Save[#GMM_Roster_Save] = GetTimestamp(); -- Timestamp added at end
        print("Analyzing Guild Roster For the First Time... " .. GMM_Roster_Save[#GMM_Roster_Save]);
    end
end



-- Guild Log Analysis

-- Method           UpdateChanges();
-- What it does:    If Guild Log is refreshed, indicating a change, this updates the info of the change
-- Purpose:         Real-time monitoring of the guild log when you are playing!
local function UpdateChanges(self,event,msg)


end

local function GMM_LoadAddon()
    GuildRoster();
    QueryGuildEventLog();
    print("test");
end

----------------------------------
-- Events Needed to Observe
----------------------------------
-- Log refreshing, but only if in a guild
-- Player leaving a guild
-- Player joining a guild

local function Tracking()
    if IsInGuild() then
        self:RegisterEvent("ADDON_LOADED");
        self:SetScript("OnEvent", GMM_LoadAddon);
        LogEvent:RegisterEvent("GUILD_EVENT_LOG_UPDATE")
        LogEvent:SetScript("OnEvent", UpdateChanges);
    end
end


GMM_LoadAddon();








-- Long Term goals
    -- Guild Recognition
    -- Auto-adding guild events like anniversary dates of players
    -- Being able to manually change guild join dates
    -- Export to excel or other formats, like PDF changes
    -- Interesting stat recording with weekly updates
        -- Like number of legendaries collected this weekly
        -- Notable achievements, like Prestige advancements
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Notable high ilvl notifications with adjustable threshold to trigger it
    -- Linking alts to mains easily
    -- Data scanning of the note to create a date, and on failure or no note, to push result for user to update formats
    -- Auto setting officer note or player note for alts
    -- Anniversary and Birthday tracking, or other notable events "Custom data to track for reminder"
    -- Guild Bank log tracking as well

