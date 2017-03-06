-- Author: TheGenomeWhisperer

-- Table that will hold all global functions... (As of yet unnecessary as all my functions only need to be LOCAL)
GR_AddOn = {};

-- Useful Customizations
local HowOftenToCheck = 10;             -- in seconds
local TimeOfflineToKick = 6;            -- In months
local InactiveMemberReturnsTimer = 1;   -- How many hours need to pass by for the guild leader to be notified of player coming back (2 weeks is default value)
local AddTimestampOnJoin = true;        -- Timestamps the officer note on joining, if Officer Note privileges.

-- Saved Variables Per Character
GR_LogReport_Save = {};                 -- This will be the stored Log of events. It can only be added to, never modified.
GR_GuildMemberHistory_Save = {}         -- Detailed information on each guild player has been a member of w/member info.
GR_PlayersThatLeftHistory_Save = {};    -- Data storage of all players that left the guild, so metadata is stored if they return. Useful for reasoning as to why banned.

-- Useful Variables
local addonName = "Guild Roster Manager";
local guildStatusChecked = false;
local PlayerIsCurrentlyInGuild = false;
local LastOnlineNotReported = true;

-- For Initial and Live tracking
local Initialization = CreateFrame("Frame");
local GeneralEventTracking = CreateFrame("Frame");
local UI_Events = CreateFrame("Frame");
local timeDelayValue = 0;                            -- For time delay tracking. Only update on trigger. To prevent spammyness.

-- Temp logs for final reporting
local TempNewMember = {};
local TempInactiveReturnedLog = {};
local TempLogPromotion = {};
local TempLogDemotion = {};
local TempLogLeveled = {};
local TempLogNote = {};
local TempLogONote = {};
local TempRankRename = {};
local TempRejoin = {};
local TempBannedRejoin = {};
local TempLeftGuild = {};
local TempNameChanged = {};

------------------------
--- FUNCTIONS ----------
------------------------

-- Method:          SlimName(string)
-- What it Does:    Removes the server name after character name.
-- Purpose:         Server name is not important in a guild since all will be server name.
local function SlimName(name)

    return strsub(name,1,string.find(name,"-")-1);

end

-- Method:          GetNumGuildies()
-- What it Does:    Returns the int number of total toons within the guild, including main/alts
-- Purpose:         For book-keeping and tracking total guild membership.
local function GetNumGuildies()
    local numMembers = GetNumGuildMembers();
    return numMembers;
end

local function ResetTempLogs()
    TempNewMember = {};
    TempInactiveReturnedLog = {};
    TempLogPromotion = {};
    TempLogDemotion = {};
    TempLogLeveled = {};
    TempLogNote = {};
    TempLogONote = {};
    TempRankRename = {};
    TempRejoin = {};
    TempBannedRejoin = {};
    TempLeftGuild = {};
    TempNameChanged = {};
end

-- Method:          ModifyCustomNote(string,string)
-- What it Does:    Adds a new note to the custom notes string
-- Purpose:         For expanded information on players to create in-game notes or tracking.
local function ModifyCustomNote(newNote,playerName)
    local guildName = GetGuildInfo("player");
    for i = 1,#GR_GuildMemberHistory_Save do                                 -- scanning through guilds
        if GR_GuildMemberHistory_Save[i][1] == guildName then                -- guild identified
            for j = 2,#GR_GuildMemberHistory_Save[i] do                      -- Scanning through guild Roster
                if GR_GuildMemberHistory_Save[i][j][1] == playerName then    -- Player Found
                    GR_GuildMemberHistory_Save[i][j][23] = newNote;          -- Storing new note.
                    break;
                end
            end
            break;
        end
    end
end

-- Method:          GetLastOnline(int)
-- What it Does:    Returns the total numbner of hours since the player last logged in at given index position of guild roster
-- Purpose:         For player management to notify addon user of too much time has passed, for recommendation to kick,
local function GetLastOnline(index)
    local years, months, days, hours = GetGuildRosterLastOnline(index);
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
    if (years == 0) and (months == 0) and (days == 0) then
        if hours == 0 then
            hours = 0.5;    -- This can be any value less than 1, but must be between 0 and 1, to just make the point that total number of hrs since last login is < 1
        end
    end
    local totalHours = (years * 8760) + (months * 730) + (days * 24) + hours;
    return totalHours;
end

-- Method:          GetTimePassed(oldTimestamp)
-- What it Does:    Reports back the elapsed, in English, since the previous given timestamp, based on the 1970 seconds count.
-- Purpose:         Time tracking to keep track of elapsed time since previous action.
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
    print(timestamp);
    return timestamp;
end

-- Method:          TotalTimeInGuild(string)
-- What it Does:    Returns to combined total time in the guild, based on accumulated seconds from the 1970 clock of only
--                  the time the player was in the guild. It sums ALL times player was in, including times player left the guild, times player returned.
-- Purpose:         Just misc. tracking info to keep track of the "true" value of time players are in the guild.   
local function TotalTimeInGuild(name)

end

-- Method:          AddLog(int,string)
-- What it Does:    This adds a size 2 array to the Log including an index to be referenced for color coding, and the log entry
-- Purpose:         Building the Log that will be displayed to the Log window that shows a history of all changes in guild since addon was activated.
function AddLog(indexCode, logEntry)
  local entry = {indexCode, logEntry}
  table.insert(GR_LogReport_Save, entry);
end

-- Method:          GetTimestamp()
-- What it Does:    Reports the current moment in time in a much more clear, concise, pretty way. Example: "9 Feb '17 1:36pm" instead of 09/02/2017/13:36
-- Purpose:         Just for cleaner presentation of the results.
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

-- Method:          HoursReport(int)
-- What it Does:    Reports as a string the time passed since player last logged on.
-- Purpose:         Cleaner reporting to the log.
local function HoursReport(hours)
    local result = "";

    local years = math.floor(hours / 8760);
    local months = math.floor((hours % 8760) / 730);
    local days = math.floor(((hours % 8760) % 730) / 24);
    local hours = math.floor(((hours % 8760) % 730) % 24);

    if (years >= 1) then
        if years > 1 then
            result = result .. "" .. years .. " years ";
        else
            result = result .. "" .. years .. " year ";
        end
    end

    if (months >= 1) then
        if months > 1 then
            result = result .. "" .. months .. " months ";
        else
            result = result .. "" .. months .. " month ";
        end
    end

    if (days >= 1) then
        if days > 1 then
            result = result .. "" .. days .. " days ";
        else
            result = result .. "" .. days .. " day ";
        end
    end

    if (hours >= 1) then
        if hours > 1 then
            result = result .. "" .. hours .. " hours.";
        else
            result = result .. "" .. hours .. " hour.";
        end
    end

    return result;
end

-- Method:          AddMemberRecord()
-- What it Does:    Builds Member Record into Guild History with various metadata
-- Purpose:         For reliable guild data tracking.
local function AddMemberRecord(memberInfo,isReturningMember,oldMemberInfo,guildName)
    -- Metadata to track on all players.
    -- Basic Info
    local name = memberInfo[1];
    local joinDate = GetTimestamp();
    local joinDateMeta = time();  -- Saved in Seconds since Jan 1, 1970, to be parsed later
    local rank = memberInfo[2];
    local rankIndex = memberInfo[3];
    local playerLevelOnJoining = memberInfo[4];
    local note = memberInfo[5];
    local officerNote = memberInfo[6];
    local class = memberInfo[7]; 
    local isMainToon = nil;
    local listOfAltsInGuild = nil;
    local dateOfLastPromotion = nil;
    local dateOfLastPromotionMeta = nil;
    local birthday = nil;

    --Custom Tracking + private
    local privateNotes = {};
    local custom = ""; -- special tagline for certain things, like data tracking <date> "" or achievement <achiev> "" etc setCustomTracker()

    -- Info nil now, but to be populated on leaving the guild
    local leftGuildDate = {};
    local leftGuildDateMeta = {};
    local bannedFromGuild = false;
    local reasonBanned = "<None Given>";
    local oldRank = nil;
    local oldJoinDate = {}; -- filled upon player leaving the guild.
    local oldJoinDateMeta = {};

    -- Pieces info that were added on later-- from index 24 of metaData array, so as not to mess with previous code
    local lastOnline = 0; -- Stores it in number of HOURS since last online.

    if isReturningMember then
        birthday = oldMemberInfo[14];
        leftGuildDate = oldMemberInfo[15];
        leftGuildDateMeta = oldMemberInfo[16];
        bannedFromGuild = oldMemberInfo[17];
        reasonBanned = oldMemberInfo[18];
        oldRank = oldMemberInfo[19];
        oldJoinDate = oldMemberInfo[20];
        oldJoinDateMeta = oldMemberInfo[21];
        privateNotes = oldMemberInfo[22];
        custom = oldMemberInfo[23];
    end

    for i = 1,#GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            table.insert(GR_GuildMemberHistory_Save[i],{name,joinDate,joinDateMeta,rank,rankIndex,playerLevelOnJoining,note,officerNote,class,isMainToon,listOfAltsInGuild,dateOfLastPromotion,dateOfLastPromotionMeta,birthday,leftGuildDate,leftGuildDateMeta,bannedFromGuild,reasonBanned,oldRank,oldJoinDate,oldJoinDateMeta,privateNotes,custom,lastOnline});
            break;
        end
    end
end

-- Method:          PrintLog(index)
-- What it Does:    Sets the color of the string to be reported to the frame (typically chat frame, or to the Log Report frame)
-- Purpose:         Color coding log and chat frame reporting.
local function PrintLog(index,logReport,LoggingIt) -- 2D array index and logReport ?? 
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
    elseif (index == 99) then
        -- Addon Name Report Colors!
        
    end
end

-- Method:          FinalReport()
-- What it Does:    Organizes flow of final report and send it to chat frame and to the logReport.
-- Purpose:         Clean organization for presentation.
local function FinalReport()
    print("Final Report!")
    if #TempNewMember > 0 then
        for i = 1,#TempNewMember do
            PrintLog(TempNewMember[i][1], TempNewMember[i][2], TempNewMember[i][3]);   -- Send to print to chat window
            AddLog(TempNewMember[i][4],TempNewMember[i][5]);                              -- Adding to the Log of Events
        end
    end

    if #TempRejoin > 0 then
        for i = 1,#TempRejoin do
            PrintLog(TempRejoin[i][1], TempRejoin[i][2], TempRejoin[i][3]);   -- Same Comments on down
            PrintLog(TempRejoin[i][4], TempRejoin[i][5], TempRejoin[i][6]);
            if TempRejoin[i][11] then
                PrintLog(TempRejoin[i][12],TempRejoin[i][13]);
            end
            AddLog(TempRejoin[i][7],TempRejoin[i][8]);
            AddLog(TempRejoin[i][9],TempRejoin[i][10]);
            if TempRejoin[i][11] then
                AddLog(TempRejoin[i][12],TempRejoin[i][13]);
            end
        end
    end

    if #TempBannedRejoin > 0 then
        for i = 1,#TempBannedRejoin do
            PrintLog(TempBannedRejoin[i][1], TempBannedRejoin[i][2], TempBannedRejoin[i][3]);
            PrintLog(TempBannedRejoin[i][4], TempBannedRejoin[i][5], TempBannedRejoin[i][6]);
            if TempBannedRejoin[i][11] then
                PrintLog(TempBannedRejoin[i][12],TempBannedRejoin[i][13]);
            end
            AddLog(TempBannedRejoin[i][7],TempBannedRejoin[i][8]);
            AddLog(TempBannedRejoin[i][9],TempBannedRejoin[i][10]);
            if TempBannedRejoin[i][11] then
                AddLog(TempBannedRejoin[i][12],TempBannedRejoin[i][13]);
            end
        end
    end

    if #TempLeftGuild > 0 then
        for i = 1,#TempLeftGuild do
            PrintLog(TempLeftGuild[i][1], TempLeftGuild[i][2], TempLeftGuild[i][3]); 
            AddLog(TempLeftGuild[i][4],TempLeftGuild[i][5]);                            
        end
    end

    if #TempInactiveReturnedLog > 0 then
        for i = 1,#TempInactiveReturnedLog do
            PrintLog(TempInactiveReturnedLog[i][1], TempInactiveReturnedLog[i][2], TempInactiveReturnedLog[i][3]);   
            AddLog(TempInactiveReturnedLog[i][4],TempInactiveReturnedLog[i][5]);                              
        end
    end

    if #TempNameChanged > 0 then
        for i = 1,#TempNameChanged do
            PrintLog(TempNameChanged[i][1], TempNameChanged[i][2], TempNameChanged[i][3]);   
            AddLog(TempNameChanged[i][4],TempNameChanged[i][5]);                              
        end
    end

    if #TempLogPromotion > 0 then
        for i = 1,#TempLogPromotion do
            PrintLog(TempLogPromotion[i][1], TempLogPromotion[i][2], TempLogPromotion[i][3]);   
            AddLog(TempLogPromotion[i][4],TempLogPromotion[i][5]);                              
        end
    end

    if #TempLogDemotion > 0 then
        for i = 1,#TempLogDemotion do
            PrintLog(TempLogDemotion[i][1], TempLogDemotion[i][2], TempLogDemotion[i][3]);
            AddLog(TempLogDemotion[i][4],TempLogDemotion[i][5]);                           
        end
    end

    if #TempLogLeveled > 0 then
        for i = 1,#TempLogLeveled do
            PrintLog(TempLogLeveled[i][1], TempLogLeveled[i][2], TempLogLeveled[i][3]);  
            AddLog(TempLogLeveled[i][4],TempLogLeveled[i][5]);                    
        end
    end

    if #TempRankRename > 0 then
        for i = 1,#TempRankRename do
            PrintLog(TempRankRename[i][1], TempRankRename[i][2], TempRankRename[i][3]);  
            AddLog(TempRankRename[i][4],TempRankRename[i][5]);                    
        end
    end

    if #TempLogNote > 0 then
        for i = 1,#TempLogNote do
            PrintLog(TempLogNote[i][1], TempLogNote[i][2], TempLogNote[i][3]);  
            AddLog(TempLogNote[i][4],TempLogNote[i][5]);                    
        end
    end

    if #TempLogONote > 0 then
        for i = 1,#TempLogONote do
            PrintLog(TempLogONote[i][1], TempLogONote[i][2], TempLogONote[i][3]);  
            AddLog(TempLogONote[i][4],TempLogONote[i][5]);                    
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
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been PROMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        table.insert(TempLogPromotion,{1,logReport,false,indexOfInfo,logReport});
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been DEMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        table.insert(TempLogDemotion,{2,logReport,false,indexOfInfo,logReport});
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        if numGained > 1 then
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " levels)");
        else
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " level)");
        end
        table.insert(TempLogLeveled,{3,logReport,false,indexOfInfo,logReport});
    -- 5 = note
    elseif indexOfInfo == 5 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s Note has Changed\nFrom:  " .. memberOldInfo[7] .. "\nTo:       " .. memberInfo[5]);
        table.insert(TempLogNote,{4,logReport,false,indexOfInfo,logReport});
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s OFFICER Note has Changed\nFrom:  " .. memberOldInfo[8] .. "\nTo:       " .. memberInfo[6]);
        table.insert(TempLogONote,{5,logReport,false,indexOfInfo,logReport});
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = string.format(GetTimestamp() .. " : Guild Rank Renamed from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        table.insert(TempRankRename,{6,logReport,false,indexOfInfo,logReport});
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        local rejoin = false;
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
                        if GR_PlayersThatLeftHistory_Save[i][j][17] == true then
                            -- Player was banned! WARNING!!!
                            local warning = string.format(GetTimestamp() .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. memberInfo[1] .. " has REJOINED the guild but was previously BANNED!");
                            logReport = string.format("     Date of Ban:                     " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nReason:                           " .. GR_PlayersThatLeftHistory_Save[i][j][18] .. "\nDate Originally Joined:    " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:               " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            local custom = "";
                            local toReport = {9,warning,false,12,logReport,false,9,warning,12,logReport,false,13,custom}
                            -- Extra Custom Note added for returning players.
                            if GR_PlayersThatLeftHistory_Save[i][j][23] ~= "" then
                                custom = ("Notes:     " .. GR_PlayersThatLeftHistory_Save[i][j][23]);
                                toReport[11] = true;
                                toReport[13] = custom;
                            end
                            table.insert(TempBannedRejoin,toReport);
                        else
                            -- No Ban found, player just returning!
                            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has REJOINED the guild (LVL: " .. memberInfo[4] .. ")");
                            local custom = "";
                            local details = ("     Date Left:                        " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nDate Originally Joined:   " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:              " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            local toReport = {7,logReport,false,12,details,false,7,logReport,12,details,false,13,custom}
                            -- Extra Custom Note added for returning players.
                            if GR_PlayersThatLeftHistory_Save[i][j][23] ~= "" then
                                custom = ("Notes:     " .. GR_PlayersThatLeftHistory_Save[i][j][23]);
                                toReport[11] = true;
                                toReport[13] = custom;
                            end
                            table.insert(TempRejoin,toReport);
                        end
                        rejoin = true;
                        -- AddPlayerTo MemberHistory
                        AddMemberRecord(memberInfo,true,GR_PlayersThatLeftHistory_Save[i][j],guildName);

                        -- Adding timestamp to new Player.
                        if AddTimestampOnJoin and CanEditOfficerNote() then
                            for h = 1,GetNumGuildies() do
                                local name = GetGuildRosterInfo(h);
                                if SlimName(name) == memberInfo[1] then
                                    GuildRosterSetOfficerNote(h,("Rejoined: " .. strsub(GetTimestamp(),1,10)));
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
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Joined the guild! (LVL: " .. memberInfo[4] .. ")");
            AddMemberRecord(memberInfo,false,nil,guildName);
            table.insert(TempNewMember,{8,logReport,false,8,logReport});
            -- Adding timestamp to new Player.
            if AddTimestampOnJoin and CanEditOfficerNote() then
                for s = 1,GetNumGuildies() do
                    local name = GetGuildRosterInfo(s);
                    if SlimName(name) == memberInfo[1] then
                        GuildRosterSetOfficerNote(s,("Joined: " .. strsub(GetTimestamp(),1,10)));
                        break;
                    end
                end
            end
        end
    -- 11 = Player Left
    elseif indexOfInfo == 11 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Left the guild");
        table.insert(TempLeftGuild,{10,logReport,false,10,logReport});
        -- Finding Player's record for removal of current guild and adding to the Left Guild table.
        for i = 1,#GR_GuildMemberHistory_Save do -- Scanning through guilds
            if guildName == GR_GuildMemberHistory_Save[i][1] then  -- Matching guild to index
                for j = 2,#GR_GuildMemberHistory_Save[i] do  -- Scanning through all entries
                    if memberInfo[1] == GR_GuildMemberHistory_Save[i][j][1] then -- Matching member leaving to guild saved entry
                        -- Found!
                        table.insert(GR_GuildMemberHistory_Save[i][j][15],GetTimestamp());   -- leftGuildDate
                        table.insert(GR_GuildMemberHistory_Save[i][j][16],time());           -- leftGuildDateMeta
                        GR_GuildMemberHistory_Save[i][j][19] = GR_GuildMemberHistory_Save[i][j][4];                -- oldRank on leaving.
                        table.insert(GR_GuildMemberHistory_Save[i][j][20],GR_GuildMemberHistory_Save[i][j][2]);    -- oldJoinDate
                        table.insert(GR_GuildMemberHistory_Save[i][j][21],GR_GuildMemberHistory_Save[i][j][3]);    -- oldJoinDateMeta
                        
                        -- Adding to LeftGuild Player history library
                        for r = 1, #GR_PlayersThatLeftHistory_Save do
                            if guildName == GR_PlayersThatLeftHistory_Save[r][1] then
                                -- Guild Position Identified.
                                table.insert(GR_PlayersThatLeftHistory_Save[r],GR_GuildMemberHistory_Save[i][j]);
                                break;
                            end
                        end
                        
                        -- removing from active member library
                        table.remove(GR_GuildMemberHistory_Save[i],j);
                        break;
                    end
                end
                break;
            end
        end

    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        logReport = string.format(GetTimestamp() .. " : " .. memberOldInfo[1] .. " has Name-Changed to ".. memberInfo[1]);
        table.insert(TempNameChanged,{11,logReport,false,11,logReport});
    -- 13 = Inactive Members Return!
    elseif indexOfInfo == 13 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo .. " has Come ONLINE after being INACTIVE for " ..  HoursReport(memberOldInfo));
        table.insert(TempInactiveReturnedLog,{14,logReport,false,14,logReport});
    end
end

-- Method:          ReportLastOnline(array)
-- What it Does:    Like the "CheckPlayerChanges()", this one does a one time scan on login or reload of notable changes of players who have returned from being offline for an extended period of time.
-- Purpose:         To inform the guild leader that a guildie who has not logged in in a while has returned!
local function ReportLastOnline(name,guildName,index)
    for i = 1,#GR_GuildMemberHistory_Save do                                    -- Scanning saved guilds
        if GR_GuildMemberHistory_Save[i][1] == guildName then                   -- Saved guild Found!
            for j = 2,#GR_GuildMemberHistory_Save[1] do                         -- Scanning through roster so can check changes (position 1 is guild name, so no need to rescan)
                if GR_GuildMemberHistory_Save[i][j][1] == name then             -- Player matched.
                    local hours = GetLastOnline(index);
                    if GR_GuildMemberHistory_Save[i][j][24] > InactiveMemberReturnsTimer and GR_GuildMemberHistory_Save[i][j][24] > hours then  -- Player has logged in after having been inactive for greater than 2 weeks!
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
                for r = 2,#GR_GuildMemberHistory_Save[1] do -- Number of members in guild (Position 1 = guild name, so we skip)
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
                                    GR_GuildMemberHistory_Save[i][r][4] = metaData[j][2]; -- Saving new rank Info
                                    GR_GuildMemberHistory_Save[i][r][5] = metaData[j][3]; -- Saving new rank Index Info
                                    GR_GuildMemberHistory_Save[i][r][12] = GetTimestamp(); -- Time stamping rank change
                                    GR_GuildMemberHistory_Save[i][r][13] = time();
                                elseif (k == 2) and (metaData[j][2] ~= GR_GuildMemberHistory_Save[i][r][4]) and (metaData[j][3] == GR_GuildMemberHistory_Save[i][r][5]) then
                                    -- RANK RENAMED!
                                    if (guildRankIndexIfChanged ~= metaData[j][3]) then -- If alrady been reported, no need to report it again.
                                        RecordChanges(8,metaData[j],GR_GuildMemberHistory_Save[i][r],guildName);
                                        guildRankIndexIfChanged = metaData[j][3]; -- Avoid repeat reporting for each member of that rank upon a namechange.
                                    end
                                    GR_GuildMemberHistory_Save[i][r][4] = metaData[j][2]; -- Saving new Info
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
    print("Building Roster");
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
        local name, rank, rankIndex, level, _, _, note, officerNote, _, _, class = GetGuildRosterInfo(i);
        local slim = SlimName(name);
        roster[i] = {};
        roster[i][1] = slim
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
        roster[i][8] = GetLastOnline(i); -- Time since they last logged in in hours.

        -- Items to check One time check on login
        -- Check players who have not been on a long time only on login or addon reload.
        if guildNotFound ~= true then
            ReportLastOnline(slim,guildName,i);
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
        CheckPlayerChanges(roster,guildName);
    end
end

--- UI FEATURES

local timer = 0;
local position = 0;
local pause = false;
local mouseClick = true;
function GR_RosterFrame(self,elapsed)
    timer = timer + elapsed;
    if timer >= 0.075 then
        -- control on whether to freeze the scanning.
        if pause and GuildMemberDetailFrame:IsVisible() == false then
            pause = false;
        end

        local NotSameWindow = true;
        local mouseNotOver = true;
        if pause == false then
            if (GuildRosterContainerButton1:IsMouseOver(1,-1,-1,1)) then -- GuildRosterContainerScrollBar   GuildMemberDetailFrame  GuildRosterContainerScrollBarScrollUpButton GuildRosterFrame GuildRosterContainerScrollChild
                if 1 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton1:Click();
                    mouseClick = true;
                    position = 1;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif(GuildRosterContainerButton2:IsVisible() and GuildRosterContainerButton2:IsMouseOver(1,-1,-1,1)) then
                if 2 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton2:Click();
                    mouseClick = true;
                    position = 2;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton3:IsVisible() and GuildRosterContainerButton3:IsMouseOver(1,-1,-1,1)) then
                if 3 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton3:Click();
                    mouseClick = true;
                    position = 3;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton4:IsVisible() and GuildRosterContainerButton4:IsMouseOver(1,-1,-1,1)) then
                if 4 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton4:Click();
                    mouseClick = true;
                    position = 4;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton5:IsVisible() and GuildRosterContainerButton5:IsMouseOver(1,-1,-1,1)) then
                if 5 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton5:Click();
                    mouseClick = true;
                    position = 5;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton6:IsVisible() and GuildRosterContainerButton6:IsMouseOver(1,-1,-1,1)) then
                if 6 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton6:Click();
                    mouseClick = true;
                    position = 6;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton7:IsVisible() and GuildRosterContainerButton7:IsMouseOver(1,-1,-1,1)) then
                if 7 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton7:Click();
                    mouseClick = true;
                    position = 7;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton8:IsVisible() and GuildRosterContainerButton8:IsMouseOver(1,-1,-1,1)) then
                if 8 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton8:Click();
                    mouseClick = true;
                    position = 8;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton9:IsVisible() and GuildRosterContainerButton9:IsMouseOver(1,-1,-1,1)) then
                if 9 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton9:Click();
                    mouseClick = true;
                    position = 9;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton10:IsVisible() and GuildRosterContainerButton10:IsMouseOver(1,-1,-1,1)) then
                if 10 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton10:Click();
                    mouseClick = true;
                    position = 10;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton11:IsVisible() and GuildRosterContainerButton11:IsMouseOver(1,-1,-1,1)) then
                if 11 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton11:Click();
                    mouseClick = true;
                    position = 11;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton12:IsVisible() and GuildRosterContainerButton12:IsMouseOver(1,-1,-1,1)) then
                if 12 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton12:Click();
                    mouseClick = true;
                    position = 12;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton13:IsVisible() and GuildRosterContainerButton13:IsMouseOver(1,-1,-1,1)) then
                if 13 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton13:Click();
                    mouseClick = true;
                    position = 13;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton14:IsVisible() and GuildRosterContainerButton14:IsMouseOver(1,-1,-1,1)) then
                if 14 ~= position then
                    mouseClick = false;
                    GuildRosterContainerButton14:Click();
                    mouseClick = true;
                    position = 14;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            end
            -- Logic on when to make Member Detail,not,rank window disappear.
            if mouseNotOver and NotSameWindow and pause == false then
                if GuildRosterFrame:IsMouseOver(2,-2,-2,2) ~= true and GuildMemberDetailFrame:IsMouseOver(2,-2,-2,2) ~= true then  -- If player is moused over side window, it will not hide it!
                    position = 0;    
                    GuildMemberDetailFrame:Hide();
                end
            end
        end
        timer = 0;
    end
end

local function GR_Roster_Click(self,button,down)
    if mouseClick then 
        GuildMemberDetailFrame:Show();
        pause = true;
    end
end

local function SetRosterTooltip(self,event,msg)
    -- So when you click the lower Roster Tab
    if GuildFrame:IsVisible() and GuildRosterFrame:IsVisible() ~= true then
        -- Do nothing... Query is all it needs to  check.
    end
    if GuildRosterFrame:IsVisible() then
        GuildRosterFrame:HookScript("OnUpdate",GR_RosterFrame);
        GuildRosterContainerButton1:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton2:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton3:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton4:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton5:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton6:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton7:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton8:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton9:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton10:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton11:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton12:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton13:HookScript("OnClick",GR_Roster_Click)
        GuildRosterContainerButton14:HookScript("OnClick",GR_Roster_Click)
    end
end

-- Method:          Tracking()
-- What it Does:    Checks the Roster once in a repeating time interval as long as player is in a guild
-- Purpose:         Constant checking for roster changes. Flexibility in timing changes. Default set to 10 now, could be 30 or 60.
local function Tracking()
    if IsInGuild() then
        local timeCallJustOnce = time();
        if timeDelayValue == 0 or (timeCallJustOnce - timeDelayValue) > 5 then -- Initial scan is zero.
            timeDelayValue = timeCallJustOnce;
            BuildNewRoster();
            FinalReport();

            -- Prevent from re-scanning changes
            LastOnlineNotReported = false;
        end
        C_Timer.After(HowOftenToCheck,Tracking); -- Recursive check every 10 seconds.
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
    UI_Events:SetScript("OnEvent",SetRosterTooltip)
    Tracking();
end

-- Method           ManageGuildStatus()
-- What it Does:    If player leaves or joins the guild, it deactivates/reactivates tracking - as well as re-checks guild to see if rejoining or new guild.    
-- Purpose:         Efficiency in resource use to prevent unnecessary tracking of info if out of the guild.
function ManageGuildStatus(self,event,msg)
    print("GUILD STATUS TEST");
    if guildStatusChecked ~= true then
       timeDelayValue = time(); -- Prevents it from doing "IsInGuild()" too soon by resetting timer as server reaction is slow.
    end

    if timeDelayValue == 0 or (time() - timeDelayValue) > 3 then -- Let's do a recheck on guild status to prevent unnecessary scanning.
        if IsInGuild() then

            local guildName = GetGuildInfo("player");
            print("Player is in guild SUCCESS!");
            print("Reactivating Tracking");
            PlayerIsCurrentlyInGuild = true;
            Tracking();
        else
            print("player no longer in guild confirmed!"); -- Store the data.
            PlayerIsCurrentlyInGuild = false;
            GR_LoadAddon();
        end
        guildStatusChecked = false;
    else
        guildStatusChecked = true;
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
    -- Being able to manually change guild join dates
    -- Export to excel or other formats, like PDF changes
    -- Interesting stat recording with weekly updates
        -- Like number of legendaries collected this weekly
        -- Notable achievements, like Prestige advancements
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Notable high ilvl notifications with adjustable threshold to trigger it
    -- Linking alts to mains  - MAYBE 
    -- Data scanning of the note to create a date, and on failure or no note, to push result for user to update formats
    -- Auto setting officer note or player note for alts
    -- Anniversary and Birthday tracking, or other notable events "Custom data to track for reminder"
    -- Guild Bank log tracking as well -- Maybe, gbank log is SO SLOW!
    -- GetGuildNewsInfo
    -- >>>>>>>>>>>>>>>>>>>>> NEXT ONE TO CHECK RIGHT HERE!
    -- check data since last online.
    -- Give this update upon login.
    -- >>>>>>>>>>>>>>>>>>>>> REPORTING INFO RIGHT HERE!!!
    -- Professions... if they cap them... notable important recipes learned... If they change them.
    -- if player is currently in a guild or not in a guild "updateGuildStatusToSaveFile()" at very end tag true/false if in it?
    -- Logentry, if player joins a new guild it breaks a couple of spaces in the entry, reports guild nameChange, with NEW guild name in center, then breaks a few more spaces. #Aesthetics
    -- Popup window on player leaving the guild asking if you wish to leave some notes, with 2 options "Don't Ask Again this Session" or "Don't ask again EVER!" Option to check box if player was banned.
    -- Add Reminders (Promotion Reminders) - Slash command or button to create reminder to promote someone (off schedule).
    -- GUILD REMINDERS!!!!!!!!!!!!!!!!!!!!!!!!! Create in-game reminders for yourself or related to the guild!
    -- If Banned from guild -- popup box Warning... Option to remove ban RemoveBan(player)
    -- "Change" option next to custom UI printout on guild member sheet.
    -- Sort guild roster by "Time in guild" - possible in built-in UI?
    -- Any ranks to ignore if they return from being online after a while? -- Probably won't include, but maybe
    -- WorldFrame > GuildMemberDetailFrame

    -- FEATURES ADDED

    -------- UI MODIFICATIONS ----------
    