-- Author: TheGenomeWhisperer

-- SLASH_GMM1 = '/gmm';
-- SLASH_GMM2 = '/GMM';
-- SLASH_GMM3 = '/roster';
-- SLASH_GMM4 = '/Roster';

-- Saved Variables
GMM_Roster_Save = {}; -- 2D array - Saves history of the current guild roster upon login, and updates it live while online.
GMM_LogReport_Save = {}; -- This will be the stored Log of events. It can only be added to, never modified.
GMM_MemberHistory_Save = {} -- 2D array of Member history - including time since last promotion, time in the guild, etc...
GMM_LeftGuildHistory_Save = {} -- Data storage of all players that left the guild, so metadata is stored if they return. Useful for reasoning as to why banned.

-- Useful Global Variables
local numGuildMembers;
local numOnlineGuildMembers;
local numAlts;
local numUniqueAccounts;
local numMobile;

-- Temp logs for compiling before report
local tempLogPromotion = {};
local tempLogDemotion = {};
local tempLogLevel = {};
local tempLogNote = {};
local tempLogOfficerNote = {};
local tempLogJoin = {};
local tempLogLeave = {};
local tempLogNamechange = {};
local tempLogRankNameChange = {};
local tempLogRejoin = {};
local tempLogJoinButPreviousBan = {};

-- For Live Tracking
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

local function UpdateMemberHistory()

end

local function AchievementTracking()

end

local function EditMetaData()

end

local function GetTimePassed(oldTimestamp)
    local totalSeconds = time() - oldTimestamp;
    local year = math.floor(totalSeconds/31536000); -- seconds in a year
    local yearTag = "year";
    local month = math.floor((totalSeconds % 31536000)/2592000); -- etc. 
    local monthTag = "month";
    local days = math.floor(((totalSeconds % 31536000) % 2592000) / 86400);
    local dayTag = "day";
    local hours = math.floor((((totalSeconds % 31536000) % 2592000) % 86400) / 3600);
    local hoursTag = "hour";
    local minutes = math.floor(((((totalSeconds % 31536000) % 2592000) % 86400) % 3600) / 60);
    local minutesTag = "minute";
    local seconds = math.floor((((((totalSeconds % 31536000) % 2592000) % 86400) % 3600) % 60) / 1);
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

-- Method:          "TotalTimeInGuild(string)"
-- What it Does:    Returns to combined total time in the guild, based on accumulated seconds from the 1970 clock of only
--                  the time the player was in the guild. It sums ALL times player was in, including times player left the guild, times player returned.
-- Purpose:         Just misc. tracking info to keep track of the "true" value of time players are in the guild.   
local function TotalTimeInGuild(name)

end

local function GetTimestamp()
    -- Time Variables
    local morning = true;
    local timestamp = date("*t");
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    local year,days,minutes,hour,month = 0;
    for x,y in pairs(timestamp) do
        if x == "hour" then
            hour = y;
        elseif x == "min" then
            minutes = y;
            if minutes < 10 then
                minutes = string.format("0" .. minutes); -- Example, if it was 6:09, the minutes would only be "9" not "09" - so this looks better.
            end
        elseif x == "day" then
            days = y;
        elseif x == "month" then
            month = y;
        elseif x == "year" then
            year = string.format(y);
            year = strsub(year,3);
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
    return string.format(time);
end


local function AddMemberRecord(memberInfo,isReturningMember,oldMemberInfo)
    -- Metadata to track on all players.
    -- Basic Info
    local name = memberInfo[1];
    local joinDate = GetTimestamp();
    local joinDateMeta = time();  -- Saved in Seconds since Jan 1, 1970, to be parsed later
    local rank = memberInfo[2];
    local playerLevelOnJoining = memberInfo[4];  
    local isMainToon = nil;
    local listOfAltsInGuild = nil;
    local dateOfLastPromotion = GetTimestamp();
    local dateOfLastPromotionMeta = time();
    local birthday = nil;

    --Custom Tracking
    local privateNotes = nil;
    local custom = {}; -- special tagline for certain things, like data tracking <date> "" or achievement <achiev> "" etc setCustomTracker()

    -- Info nil now, but to be populated on leaving the guild
    local leftGuildDate = nil;
    local leftGuildDateMeta = nil;
    local bannedFromGuild = nil;
    local reasonBanned = nil;
    local oldRank = nil;
    local oldJoinDate = nil; -- filled upon player leaving the guild.
    local oldJoinDateMeta = nil;

    if isReturningMember then
        leftGuildDate = oldMemberInfo[11];
        leftGuildDateMeta = oldMemberInfo[12];
        bannedFromGuild = oldMemberInfo[13];
        reasonBanned = oldMemberInfo[14];
        oldRank = oldMemberInfo[15];
        oldJoinDate = oldMemberInfo[16];
        oldJoinDateMeta = oldMemberInfo[17];
    end
    table.insert(GMM_MemberHistory_Save,{name,joinDate,joinDateMeta,rank,playerLevelOnJoining,isMainToon,listOfAltsInGuild,dateOfLastPromotion,dateOfLastPromotionMeta,birthday,leftGuildDate,leftGuildDateMeta,bannedFromGuild,reasonBanned,oldRank,oldJoinDate,oldJoinDateMeta,privateNotes,custom});
end

-- Method           RecordChanges()
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
local function RecordChanges(indexOfInfo,memberInfo,memberOldInfo)
    local logReport = "";
    -- 2 = Guild Rank Promotion
    if indexOfInfo == 2 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been PROMOTED from " .. memberOldInfo[2] .. " to " .. memberInfo[2]);
        table.insert(tempLogPromotion,logReport);
        print(logReport);
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been DEMOTED from " .. memberOldInfo[2] .. " to " .. memberInfo[2]);
        table.insert(tempLogDemotion,logReport);
        print(logReport);
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[4];
        if numGained > 1 then
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " levels)");
        else
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " level)");
        end
        table.insert(tempLogLevel,logReport);
        print(logReport);
    -- 5 = note
    elseif indexOfInfo == 5 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s Note has Changed\nFrom:  " .. memberOldInfo[5] .. "\nTo:       " .. memberInfo[5]);
        table.insert(tempLogNote,logReport);
        print(logReport);
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s OFFICER Note has Changed\nFrom:  " .. memberOldInfo[6] .. "\nTo:       " .. memberInfo[6]);
        table.insert(tempLogOfficerNote,logReport);
        print(logReport);
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = string.format(GetTimestamp() .. " : Guild Rank Renamed from " .. memberOldInfo[2] .. " to " .. memberInfo[2]);
        table.insert(tempLogRankNameChange,logReport);
        print(logReport);
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        local rejoin = false;
        for i = 1,#GMM_LeftGuildHistory_Save do
            if memberInfo[1] == GMM_LeftGuildHistory_Save[i][1] then
                -- Match found!
                -- Now, let's see if the player was banned before!
                local numTimesInGuild = #GMM_LeftGuildHistory_Save[i][16];
                local numTimesString = "";
                if numTimesInGuild > 1 then
                    numTimesString = string.format(memberInfo[1] .. " has Been in the Guild " .. numTimesInGuild .. " Times Before");
                else
                    numTimesString = string.format(memberInfo[1] .. " is Returning for the First Time.");
                end
                if GMM_LeftGuildHistory_Save[i][10] == true then
                    -- Player was banned! WARNING!!!
                    logReport = string.format(GetTimestamp() .. " : ---- WARNING! WARNING! WARNING! ----\n" .. memberInfo[1] .. " has REJOINED the guild but was previously BANNED!\nDate of Ban: " .. GMM_LeftGuildHistory_Save[i][11] .. " (" .. GetTimePassed(GMM_LeftGuildHistory_Save[i][12]) .. " ago)\nReason:      " .. GMM_LeftGuildHistory_Save[i][13] .. "\n" .. numTimesString);
                    table.insert(tempLogJoinButPreviousBan,logReport);
                    print(logReport);
                else
                    -- No Ban found, player just returning!
                    logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has REJOINED the guild\nDate Left:           " .. GMM_LeftGuildHistory_Save[i][11] .. " (" .. GetTimePassed(GMM_LeftGuildHistory_Save[i][12]) .. " ago)\nDate Originally Joined: " .. GMM_LeftGuildHistory_Save[2] .. "\nOld Guild Rank:          " .. GMM_LeftGuildHistory_Save[i][15]);
                    table.insert(tempLogRejoin, logReport);
                    print(logReport);
                end
                rejoin = true;
                break;
            end
        end
        if rejoin ~= true then
            logReport = string.format(memberInfo[1] .. " has Joined the guild!");
            table.insert(tempLogJoin,logReport);
            print(logReport);
        end
    -- 11 = Player Left
    elseif indexOfInfo == 11 then
        logReport = string.format(memberInfo[1] .. " has Left the guild");
        table.insert(tempLogLeave,logReport);
        print(logReport);
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        logReport = string.format(memberOldInfo[1] .. " has Name-Changed to ".. memberInfo[1]);
        table.insert(tempLogNamechange,logReport);
        print(logReport);
    end
end

local function CheckPlayerChanges(metaData)
    local newPlayerFound;
    local guildRankIndexIfChanged = -1; -- Rank index must start below zero, as zero is Guild Leader.

    -- new player and leaving player arrays to check at the end
    local newPlayers = {};
    local leavingPlayers = {};

    -- Checking changes (class not checked = 7)
    for i = 1,#metaData do
        newPlayerFound = true;
        for j = 1,#GMM_Roster_Save-1 do
            if metaData[i][1] == GMM_Roster_Save[j][1] then
                -- Checking for changes now.
                newPlayerFound = false;
                for k = 2,7 do
                    if (metaData[i][k] ~= GMM_Roster_Save[j][k]) and (k ~= 3) then -- no need to check rank Index unless checking against rank.
                        
                        -- Ranks
                        if (k == 2) and (metaData[i][3] ~= GMM_Roster_Save[j][3]) then -- This checks to see if guild just changed the name of a rank.
                            -- Promotion Obtained
                            if metaData[i][3] < GMM_Roster_Save[j][3] then
                                RecordChanges(k,metaData[i],GMM_Roster_Save[j]);
                            -- Demotion Obtained
                            elseif metaData[i][3] > GMM_Roster_Save[j][3] then
                                RecordChanges(9,metaData[i],GMM_Roster_Save[j]);
                            end
                        elseif (k == 2) and (metaData[i][3] == GMM_Roster_Save[j][3]) and (guildRankIndexIfChanged ~= metaData[i][3]) then
                            -- RANK RENAMED!
                            RecordChanges(8,metaData[i],GMM_Roster_Save[j]);
                            guildRankIndexIfChanged = metaData[i][3];
                        
                        -- Level
                        elseif (k==4) then
                            RecordChanges(k,metaData[i],GMM_Roster_Save[j]);
                        -- Note
                        elseif (k==5) then
                            RecordChanges(k,metaData[i],GMM_Roster_Save[j]);
                        -- Officer Note
                        elseif CanViewOfficerNote() and (k==6) then
                            RecordChanges(k,metaData[i],GMM_Roster_Save[j]);
                        end
                    end
                end
            end
        end
        -- NEW PLAYER FOUND! (maybe)
        if newPlayerFound then
            newPlayers[#newPlayers + 1] = {};     -- Player "maybe" found. Let's store info to compare notes of players that left guild in case of name change.
            newPlayers[#newPlayers] = metaData[i];
        end
    end
    -- Checking if any players left the guild
    local playerLeftGuild;
    for i = 1,#GMM_Roster_Save-1 do
        playerLeftGuild = true;
        for j = 1,#metaData do
            if GMM_Roster_Save[i][1] == metaData[j][1] then
                playerLeftGuild = false;
                break;
            end
        end
        -- PLAYER LEFT! (maybe)
        if playerLeftGuild then
            leavingPlayers[#leavingPlayers + 1] = {};
            leavingPlayers[#leavingPlayers] = GMM_Roster_Save[i];
        end
    end
    -- Final check on players that left the guild to see if they are namechanges.
    local playerNotMatched = true;
    if #leavingPlayers > 0 and #newPlayers > 0 then
        for i = 1,#leavingPlayers do
            for j = 1,#newPlayers do
                if (leavingPlayers[i][7] == newPlayers[j][7]) -- Class is the sane
                    and (leavingPlayers[i][3] == newPlayers[j][3])  -- Guild Rank is the same
                        and (leavingPlayers[i][5] == newPlayers[j][5]) -- Player Note is the same
                            and (leavingPlayers[i][6] == newPlayers[j][6]) then -- Officer Note is the same
                                -- PLAYER IS A NAMECHANGE!!!
                                playerNotMatched = false;
                                RecordChanges(12,newPlayers[j],leavingPlayers[i]);
                                 -- since namechange identified, also need to remove name from newPlayers array now.
                                if #newPlayers == 1 then
                                    newPlayers = {}; -- Clears the array of the one name.
                                else
                                    local tempArray = {};
                                    local count = 1;
                                    for k = 1,#newPlayers do -- removing the namechange from newPlayers list.
                                        if k ~= j then
                                            tempArray[count] = {};
                                            tempArray[count] = newPlayers[k];
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
                RecordChanges(11,leavingPlayers[i],leavingPlayers[i]);
            end
        end
    elseif #leavingPlayers > 0 then
        for i = 1,#leavingPlayers do
            RecordChanges(11,leavingPlayers[i],leavingPlayers[i]);
        end
    end
    if #newPlayers > 0 then
        for i = 1,#newPlayers do
            RecordChanges(10,newPlayers[i],newPlayers[i]);
        end
    end
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
        if CanViewOfficerNote() then -- Officer Note permission to view.
            roster[i][6] = officerNote;
        else
            roster[i][6] = i; -- Set Officer note to unique index position of player in array if unable to view.
        end
        roster[i][7] = class;
    end

    -- Now checking for first time
    if GMM_Roster_Save[1] == nil then
        print("Analyzing Guild Roster For the First Time... ");
        GMM_Roster_Save = roster;
        table.insert(GMM_Roster_Save,GetTimestamp()); -- Timestamp added at end   
    else
        print("test");
        CheckPlayerChanges(roster); -- Ok, let's process changes!
        GMM_Roster_Save = roster;
        table.insert(GMM_Roster_Save,GetTimestamp()); -- Timestamp added at end   
        print("Success!");
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
    -- GetGuildRosterLastOnline - Check how long since they logged on
    -- GetGuildNewsInfo
    -- check data since last online.
    -- History should include array of join/leave dates... calculate total time in the guild by metaData seconds LeaveDate - JoinDate - keep adding the time in the guild each time they rejoin.

