-- Author: TheGenomeWhisperer


-- Useful Customizations
local HowOftenToCheck = 10; -- in seconds
local TimeOfflineToKick = 6; -- In months

-- Saved Variables Per Character
GR_LogReport_Save = {}; -- This will be the stored Log of events. It can only be added to, never modified.
GR_GuildMemberHistory_Save = {} -- Detailed information on each guild player has been a member of w/member info.
GR_PlayersThatLeftHistory_Save = {}; -- Data storage of all players that left the guild, so metadata is stored if they return. Useful for reasoning as to why banned.

-- Useful Variables
local addonName = "Guild Roster Manager";
local guildStatusChecked = false;
local PlayerIsCurrentlyInGuild = false;

-- For Initial and Live tracking
local Initialization = CreateFrame("Frame");
local GeneralEventTracking = CreateFrame("Frame");
local TrackingHappenedLive = false; -- Boolean to also print out to player chat window for live tracking updates w/o needing to open whole log
                                    -- but also will not push chat updates on initial login or reload scanning. JUST LIVE TRACKING PRINTING!
local timeDelayValue = 0; -- For time delay tracking. Only update on trigger. To prevent spammyness.

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

-- Method:          GetLastOnline(string)
-- What it Does:    Returns the total numbner of hours since the player last logged in.
-- Purpose:         For player management to notify addon user of too much time has passed, for recommendation to kick,
local function GetLastOnline(name)
    local years, months, days, hours = 0;
    for i =1,GetNumGuildies() do
        local rosterName = GetGuildRosterInfo(i);
        if SlimName(rosterName) == name then
            years, months, days, hours = GetGuildRosterLastOnline(i);
        end
        break;
    end
    local totalHours = (years * 8736) + (months * 720) + (days * 24) + hours;
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
            table.insert(GR_GuildMemberHistory_Save[i],{name,joinDate,joinDateMeta,rank,rankIndex,playerLevelOnJoining,note,officerNote,class,isMainToon,listOfAltsInGuild,dateOfLastPromotion,dateOfLastPromotionMeta,birthday,leftGuildDate,leftGuildDateMeta,bannedFromGuild,reasonBanned,oldRank,oldJoinDate,oldJoinDateMeta,privateNotes,custom});
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
            chat:AddMessage(logReport, 0.176, 0.420, 1.0);
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
    elseif (index == 13) then
        if LoggingIt then

        else
            chat:AddMessage(logReport,0.4,0.71,0.9)
        end
    elseif (index == 99) then
        -- Addon Name Report Colors!
        
    end
end

-- Method           RecordChanges()
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
local function RecordChanges(indexOfInfo,memberInfo,memberOldInfo,guildName)
    print("RecordChanges");
    local logReport = "";
    local chatframe = DEFAULT_CHAT_FRAME;
    -- 2 = Guild Rank Promotion
    if indexOfInfo == 2 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been PROMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        PrintLog(1, logReport, false); -- Send to print to chat window
        AddLog(indexOfInfo,logReport); -- Adding to the Log of Events
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has been DEMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        PrintLog(2, logReport, false);
        AddLog(indexOfInfo,logReport); -- Adding to the Log of Events - and so on for the rest...
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        if numGained > 1 then
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " levels)");
        else
            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " level)");
        end
        PrintLog(3, logReport, false);
        AddLog(indexOfInfo,logReport);
    -- 5 = note
    elseif indexOfInfo == 5 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s Note has Changed\nFrom:  " .. memberOldInfo[7] .. "\nTo:       " .. memberInfo[5]);
        PrintLog(4, logReport, false);
        AddLog(indexOfInfo,logReport);
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. "'s OFFICER Note has Changed\nFrom:  " .. memberOldInfo[8] .. "\nTo:       " .. memberInfo[6]);
        PrintLog(5, logReport, false);
        AddLog(indexOfInfo,logReport);
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = string.format(GetTimestamp() .. " : Guild Rank Renamed from " .. memberOldInfo[4] .. " to " .. memberInfo[2]);
        PrintLog(6, logReport, false);
        AddLog(indexOfInfo,logReport);
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
                            print("player was banned!");
                            -- Player was banned! WARNING!!!
                            local warning = string.format(GetTimestamp() .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. memberInfo[1] .. " has REJOINED the guild but was previously BANNED!");
                            logReport = string.format("     Date of Ban:                     " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nReason:                           " .. GR_PlayersThatLeftHistory_Save[i][j][18] .. "\nDate Originally Joined:    " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:               " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            
                            PrintLog(9, warning, false);
                            PrintLog(12, logReport, false);
                            AddLog(9,warning);
                            AddLog(12,logReport);
                            -- Extra Custom Note added for returning players.
                            if GR_PlayersThatLeftHistory_Save[i][j][23] ~= "" then
                                local custom = ("Notes:     " .. GR_PlayersThatLeftHistory_Save[i][j][23]);
                                PrintLog(13,custom);
                                AddLog(13,custom);
                            end
                        else
                            -- No Ban found, player just returning!
                            logReport = string.format(GetTimestamp() .. " : " .. memberInfo[1] .. " has REJOINED the guild (LVL: " .. memberInfo[4] .. ")");
                            local details = ("     Date Left:                        " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nDate Originally Joined:   " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:              " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            
                            PrintLog(7, logReport, false);
                            PrintLog(12, details, false);
                            AddLog(7,logReport);
                            AddLog(12,details);
                        end
                        rejoin = true;
                        -- AddPlayerTo MemberHistory
                        AddMemberRecord(memberInfo,true,GR_PlayersThatLeftHistory_Save[i][j],guildName);
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
            print("not a rejoin!");
            logReport = string.format(memberInfo[1] .. " has Joined the guild! (LVL: " .. memberInfo[4] .. ")");
            AddMemberRecord(memberInfo,false,nil,guildName);
            PrintLog(8, logReport, false);
            AddLog(8,logReport);
        end
    -- 11 = Player Left
    elseif indexOfInfo == 11 then
        logReport = string.format(memberInfo[1] .. " has Left the guild");
        PrintLog(10,logReport);
        AddLog(10,logReport);
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

        -- PrintLog(10, logReport, false);
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        logReport = string.format(memberOldInfo[1] .. " has Name-Changed to ".. memberInfo[1]);
        PrintLog(11, logReport, false);
        AddLog(11,logReport);
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
                    -- table.insert(GR_PlayersThatLeftHistory_Save,GR_GuildMemberHistory_Save[i][r]);
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

    -- Checking if Guild Found or Not Found, to pre-check for Guild name tag.
    local guildNotFound = true;
    for i = 1,#GR_GuildMemberHistory_Save do
        if guildName == GR_GuildMemberHistory_Save[i][1] then
            guildNotFound = false;
            break;
        end
    end

    -- Build Roster for the first time if guild not found.
    if guildNotFound then
        print("Analyzing guild for the first time");
        table.insert(GR_GuildMemberHistory_Save,{guildName}); -- Creating a position in table for Guild Member Data
        table.insert(GR_PlayersThatLeftHistory_Save,{guildName}); -- Creating a position in Left Player Table for Guild Member Data
        for i = 1,#roster do
            AddMemberRecord(roster[i],false,nil,guildName);
        end
    else -- Check over changes!
        CheckPlayerChanges(roster,guildName);

    end
    
end

-- Method:          Tracking()
-- What it Does:    Checks the Roster once in a repeating time interval as long as player is in a guild
-- Purpose:         Constant checking for roster changes. Flexibility in timing changes. Default set to 10 now, could be 30 or 60.
local function Tracking()
    if IsInGuild() then
        local timeCallJustOnce = time();
        if timeDelayValue == 0 or (timeCallJustOnce - timeDelayValue) > 3 then -- Initial scan is zero.
            timeDelayValue = timeCallJustOnce;
            TrackingHappenedLive = true;
            BuildNewRoster();
            TrackingHappenedLive = false;
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
            PlayerIsCurrentlyInGuild = status;
            Tracking();
        else
            print("player no longer in guild confirmed!"); -- Store the data.
            PlayerIsCurrentlyInGuild = status;
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
            Initialization:UnregisterEvent("ADDON_LOADED"); -- no need to keep scanning these after full loaded.
            GuildRoster(); -- Initial queries...
            QueryGuildEventLog();
            C_Timer.After(5,GR_LoadAddon); -- Queries do not return info immediately, gives server a 5 second delay.
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
    -- GetGuildRosterLastOnline - Check how long since they logged on
    -- GetGuildNewsInfo
    -- >>>>>>>>>>>>>>>>>>>>> NEXT ONE TO CHECK RIGHT HERE!
    -- check data since last online.
    -- Give this update upon login.
    -- >>>>>>>>>>>>>>>>>>>>> REPORTING INFO RIGHT HERE!!!
    -- Professions... if they cap them... notable important recipes learned... If they change them.
    -- Auto add join date in Officer note for new members
    -- if player is currently in a guild or not in a guild "updateGuildStatusToSaveFile()" at very end tag true/false if in it?
    -- Logentry, if player joins a new guild it breaks a couple of spaces in the entry, reports guild nameChange, with NEW guild name in center, then breaks a few more spaces. #Aesthetics
    -- Popup window on player leaving the guild asking if you wish to leave some notes, with 2 options "Don't Ask Again this Session" or "Don't ask again EVER!" Option to check box if player was banned.
    -- Add Reminders (Promotion Reminders) - Slash command or button to create reminder to promote someone (off schedule).
    -- GUILD REMINDERS!!!!!!!!!!!!!!!!!!!!!!!!! Create in-game reminders for yourself or related to the guild!
    -- If Banned from guild -- popup box Warning... Option to remove ban RemoveBan(player)
    -- Add Timestamp to Officer Note upon Joining Guild. Or, "Change" option next to custom UI printout on guild member sheet.
    -- Sort guild roster by "Time in guild" - possible in built-in UI?