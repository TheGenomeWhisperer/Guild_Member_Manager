-- Author: TheGenomeWhisperer

-- Table that will hold all global functions... (As of yet unnecessary as all my functions only need to be LOCAL)
GR_AddOn = {};

-- Useful Customizations
local HowOftenToCheck = 10;                     -- in seconds
local TimeOfflineToKick = 6;                    -- In months
local InactiveMemberReturnsTimer = 72;           -- How many hours need to pass by for the guild leader to be notified of player coming back (2 weeks is default value)
local AddTimestampOnJoin = true;                -- Timestamps the officer note on joining, if Officer Note privileges.

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
-- What it Does:    Takes the same text line from GuildmemberDetailFrame and parses out the Level
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
    local dayIndex = -1;
    for i = 1,#timestamp do
        if string.sub( timestamp , i , i ) == " " then
            count = count + 1;
        end
        if count == 1 and dayIndex == -1 then
            dayIndex = i;
        end
        if count == 2 then
            index = i;
            break;
        end
    end
    local month = monthEnum [ string.sub ( timestamp , index + 1 , index + 3) ];
    local day = tonumber ( string.sub ( timestamp , dayIndex + 1 , index - 1 ) );
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
------ METADATA TRACKING LOGIC -----
--- Reporting, Live Tracking, Etc --
------------------------------------

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
    local currentLevel = memberInfo[4];
    local note = memberInfo[5];
    local officerNote = memberInfo[6];
    local class = memberInfo[7]; 
    local isMainToon = nil;
    local listOfAltsInGuild = nil;
    local dateOfLastPromotion = nil;
    local dateOfLastPromotionMeta = nil;
    local birthday = nil;

    --Custom Tracking + private
    local specialTrackers = {};  -- Feature to be built, for custom event trackers or reminders.
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
            table.insert ( GR_GuildMemberHistory_Save[i] , { name , joinDate , joinDateMeta , rank , rankIndex , currentLevel , note , officerNote , class , isMainToon ,
                listOfAltsInGuild , dateOfLastPromotion , dateOfLastPromotionMeta , birthday , leftGuildDate , leftGuildDateMeta , bannedFromGuild , reasonBanned , oldRank ,
                    oldJoinDate , oldJoinDateMeta , specialTrackers , customNote , lastOnline , rankHistory , playerLevelOnJoining } );  -- 26 so far.
            break;
        end
    end
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

                        local timeStamp = GetTimestamp();
                        if GR_PlayersThatLeftHistory_Save[i][j][17] == true then
                            -- Player was banned! WARNING!!!
                            local reasonBanned = GR_PlayersThatLeftHistory_Save[i][j][18];
                            if reasonBanned == nil or reasonBanned == "" then
                                reasonBanned = "<None Given>";
                            end
                            local warning = string.format(timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. memberInfo[1] .. " has REJOINED the guild but was previously BANNED!");
                            logReport = string.format("     Date of Ban:                     " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nReason:                           " .. reasonBanned .. "\nDate Originally Joined:    " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:               " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
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
                            logReport = string.format(timeStamp .. " : " .. memberInfo[1] .. " has REJOINED the guild (LVL: " .. memberInfo[4] .. ")");
                            local custom = "";
                            local details = ("     Date Left:                        " .. GR_PlayersThatLeftHistory_Save[i][j][15][#GR_PlayersThatLeftHistory_Save[i][j][15]] .. " (" .. GetTimePassed(GR_PlayersThatLeftHistory_Save[i][j][16][#GR_PlayersThatLeftHistory_Save[i][j][16]]) .. " ago)\nDate Originally Joined:   " .. GR_PlayersThatLeftHistory_Save[i][j][20][1] .. "\nOld Guild Rank:              " .. GR_PlayersThatLeftHistory_Save[i][j][19] .. "\n" .. numTimesString);
                            local toReport = {7,logReport,false,12,details,false,7,logReport,12,details,false,13,custom}
                            -- Extra Custom Note added for returning players.
                            if GR_PlayersThatLeftHistory_Save[i][j][23] ~= "" then
                                custom = ("Notes:     " .. GR_PlayersThatLeftHistory_Save[i][j][23]);
                                toReport[11] = true;
                                toReport[13] = custom;
                            end
                            table.insert ( TempRejoin , toReport );
                        end
                        rejoin = true;
                        -- AddPlayerTo MemberHistory
                        AddMemberRecord( memberInfo , true , GR_PlayersThatLeftHistory_Save[i][j] , guildName );

                        -- Adding timestamp to new Player.
                        if AddTimestampOnJoin and CanEditOfficerNote() then
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
            logReport = string.format( timestamp .. " : " .. memberInfo[1] .. " has Joined the guild! (LVL: " .. memberInfo[4] .. ")");

            -- Adding to global saved array, adding to report 
            AddMemberRecord( memberInfo , false , nil , guildName );
            table.insert(TempNewMember,{8,logReport,false,8,logReport});
           
            -- adding join date to history and rank date.
            for i = 1,#GR_GuildMemberHistory_Save do
                if (GR_GuildMemberHistory_Save[i][1] == guildName) then             -- guild Identified in position 'i'
                    for j = 2,#GR_GuildMemberHistory_Save[i] do                     -- Number of players that have left the guild.
                        if memberInfo[1] == GR_GuildMemberHistory_Save[i][j][1] then
                            GR_GuildMemberHistory_Save[i][j][12] = strsub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 );  -- Date of Last Promotion
                            GR_GuildMemberHistory_Save[i][j][13] = timeEpoch;                                                       -- Date of Last Promotion Epoch time.
                            table.insert ( GR_GuildMemberHistory_Save[i][j][20] , timestamp );
                            table.insert ( GR_GuildMemberHistory_Save[i][j][21] , timeEpoch );
                            break;
                        end
                    end
                    break;
                end
            end

            -- Adding timestamp to new Player.
            if AddTimestampOnJoin and CanEditOfficerNote() then
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
        logReport = string.format(timestamp .. " : " .. memberInfo[1] .. " has Left the guild");
        table.insert(TempLeftGuild,{10,logReport,false,10,logReport});
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
                    local hours = GetHoursSinceLastOnline(index);
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
        CheckPlayerChanges(roster,guildName);
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

-- Alt Management Functions
local function AddAlt ( playerName , altName )

end

local function RemoveAlt ( playerName , altName )

end

local function SetMain ( playerName , mainName )

end

local function SortToons ( playerName )

end

local function SetRole ( playerName , isMain )

end

--------------------------------------
---- UI BUILDING COMPLETELY IN LUA ---
---- FRAMES, FONTS, STYLES, ETC. -----
--------------------------------------

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
local SetPromoDateButton = CreateFrame("Button","GR_SetPromoDateButton",MemberDetailMetaData,"UIPanelButtonTemplate");

-- SUBMIT BUTTONS
local DateSubmitButton = CreateFrame("Button","GR_DateSubmitButton",MemberDetailMetaData,"UIPanelButtonTemplate");
local DateSubmitCancelButton = CreateFrame("Button","GR_DateSubmitCancelButton",MemberDetailMetaData,"UIPanelButtonTemplate");
local GR_DateSubmitButtonTxt = DateSubmitButton:CreateFontString ( "GR_DateSubmitButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );
local GR_DateSubmitCancelButtonTxt = DateSubmitCancelButton:CreateFontString ( "GR_DateSubmitCancelButtonTxt" , "OVERLAY" , "GameFontWhiteTiny" );

-- RANK DROPDOWN
local guildRankDropDownMenu = CreateFrame("Frame" , "GR_RankDropDownMenu" , MemberDetailMetaData , "UIDropDownMenuTemplate" );

-- NOTE/OFFICER NOTES
local noteBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" ,
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 18,
    insets = { left == 5 , right = 5 , top = 5 , bottom = 5 }
}
local PlayerNoteWindow = CreateFrame( "Frame" , "GR_PlayerNoteWindow" , MemberDetailMetaData );
local noteFontString1 = PlayerNoteWindow:CreateFontString ( "GR_NoteText" , "OVERLAY" , "GameFontWhiteTiny" );
local PlayerNoteEditBox = CreateFrame( "EditBox" , "GR_PlayerNoteEditBox" , MemberDetailMetaData );
local PlayerOfficerNoteWindow = CreateFrame( "Frame" , "GR_PlayerOfficerNoteWindow" , MemberDetailMetaData );
local noteFontString2 = PlayerOfficerNoteWindow:CreateFontString ( "GR_OfficerNoteText" , "OVERLAY" , "GameFontWhiteTiny" );
local PlayerOfficerNoteEditBox = CreateFrame( "EditBox" , "GR_OfficerPlayerNoteEditBox" , MemberDetailMetaData );
local officerNoteCount = PlayerOfficerNoteEditBox:CreateFontString ( "GR_OfficerNoteCharCount" , "OVERLAY" , "GameFontWhiteTiny" );
local NoteCount = PlayerNoteEditBox:CreateFontString ( "GR_NoteCharCount" , "OVERLAY" , "GameFontWhiteTiny" );
PlayerNoteEditBox:Hide();
PlayerOfficerNoteEditBox:Hide();

-- Populating Frames with FontStrings
local GR_MemberDetailNameText = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailName" , "OVERLAY" , "GameFontNormalLarge" );
local GR_MemberDetailLevel = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLevel" , "OVERLAY" , "GameFontNormalSmall" );
local GR_MemberDetailRankTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailRankTxt" , "OVERLAY" , "GameFontNormal" );
local GR_MemberDetailRankDateTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailRankDateTxt" , "OVERLAY" , "GameFontNormalSmall" );
local GR_MemberDetailNoteTitle = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailNoteTitle" , "OVERLAY" , "GameFontNormalSmall" );
local GR_MemberDetailOfficerNoteTitle = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailOfficerNoteTitle" , "OVERLAY" , "GameFontNormalSmall" );

-- Fontstring for MemberRank History Gonna use 3 to create Underline effect.
local GR_MemberDetailJoinTitleTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailJoinTitleTxt" , "OVERYALY" , "GameFontNormalSmall" );
local GR_JoinTitleTxtUnderline = MemberDetailMetaData:CreateFontString ( "GR_JoinTitleTxtUnderline" , "OVERYALY" , "GameFontNormalSmall" );
local GR_MemberDetailJoinTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailJoinTxt" , "OVERYALY" , "GameFontWhiteTiny" );
local MemberDetailJoinDateButton = CreateFrame ( "Button" , "GR_MemberDetailJoinDateButton" , MemberDetailMetaData , "UIPanelButtonTemplate" );
local GR_JoinDateButtonText = MemberDetailJoinDateButton:CreateFontString ( "GR_JoinDateButtonText" , "OVERLAY" , "GameFontWhiteTiny" );
local GR_JoinDateText = MemberDetailMetaData:CreateFontString ( "GR_JoinDateText" , "OVERLAY" , "GameFontWhiteTiny" );

-- LAST ONLINE
local GR_MemberDetailLastOnlineTitleTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLastOnlineTitleTxt" , "OVERYALY" , "GameFontNormalSmall" );
local GR_MemberDetailLastOnlineUnderline = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLastOnlineUnderline" , "OVERYALY" , "GameFontNormalSmall" );
local GR_MemberDetailLastOnlineTxt = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailLastOnlineTxt" , "OVERYALY" , "GameFontWhiteTiny" );

-- STATUS TEXT
local GR_MemberDetailPlayerStatus = MemberDetailMetaData:CreateFontString (" GR_MemberDetailLastOnlineUnderline" , "OVERYALY" , "GameFontNormalSmall" );

-- GROUP INVITE and REMOVE from Guild BUTTONS
local groupInviteButton = CreateFrame ( "Button" , "GR_GroupInviteButton" , MemberDetailMetaData , "UIPanelButtonTemplate" );
local GR_GroupInviteButtonText = groupInviteButton:CreateFontString ("GR_GroupInviteButton" , "OVERLAY" , "GameFontWhiteTiny" );
local removeGuildieButton = CreateFrame ( "Button" , "GR_RemoveGuildieButton" , MemberDetailMetaData , "UIPanelButtonTemplate" );
local GR_RemoveGuildieButtonText = removeGuildieButton:CreateFontString ("GR_RemoveGuildieButtonText" , "OVERLAY" , "GameFontWhiteTiny" );

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
local GR_PopupWindowConfirmText = GR_PopupWindow:CreateFontString ( "GR_PopupWindowConfirmText" , "OVERLAY" , "GameFontNormal" );

-- EDIT BOX FOR ANYTHING ( like banned player note );
local GR_MemberDetailEditBoxFrame = CreateFrame ( "Frame" , "GR_MemberDetailEditBoxFrame" , GR_PopupWindow , "TranslucentFrameTemplate" );
GR_MemberDetailEditBoxFrame:Hide();
local MemberDetailPopupEditBox = CreateFrame ( "EditBox" , "GR_PlayerNoteEditBox" , GR_MemberDetailEditBoxFrame );

-- Banned Fontstring and Buttons
local GR_MemberDetailBannedText1 = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailBannedText1" , "OVERLAY" , "GameFontNormalSmall");
local GR_MemberDetailBannedText2 = MemberDetailMetaData:CreateFontString ( "GR_MemberDetailBannedText2" , "OVERLAY" , "GameFontNormalSmall");
local GR_MemberDetailBannedIgnoreButton = CreateFrame ( "Button" , "GR_MemberDetailBannedIgnoreButton" , MemberDetailMetaData , "UIPanelButtonTemplate" );
local GR_MemberDetailBannedIgnoreButtonText = GR_MemberDetailBannedIgnoreButton:CreateFontString ( "GR_MemberDetailBannedIgnoreButtonText" , "OVERLAY" , "GameFontWhiteTiny");


-- Useful UI Local Globals
local timer = 0;
local timer2 = 0; 
local position = 0;
local pause = false;
local rankDateSet = false;

-- DropDownMenuPopulateLogic
local tempName = "";
local rankIndex = 1;
local playerIndex = -1;
local addonPlayerName = GetUnitName("PLAYER",false);

-- DropDownMenus
local monthIndex;
local yearIndex;
local dayIndex;

------------------------------------
---- BEGIN OF FRAME LOGIC ----------
---- General Framebuild Methods ----
------------------------------------


-- Method:          OnDropMenuClickDay(self)
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
local function OnDropMenuClickDay ( self )
    local index = self:GetID();
    dayIndex = index;
    UIDropDownMenu_SetSelectedID ( DayDropDownMenu , index );
end

-- Method:          OnDropMenuClicOnDropMenuClickYearkMonth(self)
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for year based drop down menu.
local function OnDropMenuClickYear ( self )
    UIDropDownMenu_SetSelectedID ( YearDropDownMenu , self:GetID() );
    yearIndex = tonumber(self:GetText());
end

-- Method:          OnDropMenuClickMonth(self)
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
local function OnDropMenuClickMonth ( self )
    local index = self:GetID();
    monthIndex = index;
    UIDropDownMenu_SetSelectedID ( MonthDropDownMenu , index );
end

local function InitializeDropDownDay ( self , level )
    local shortMonth = 30;
    local longMonth = 31;
    local febMonth = 28;
    local leapYear = 29;
    
    local yearDate = 0;
    yearDate = yearIndex;
    local isDateALeapyear = IsLeapYear(yearDate);
    local numDays;
    
    if monthIndex == 1 or monthIndex == 3 or monthIndex == 5 or monthIndex == 7 or monthIndex == 8 or monthIndex == 10 or monthIndex == 12 then
        numDays = longMonth;
    elseif monthIndex == 2 and isDateALeapyear then
        numDays = leapYear;
    elseif monthIndex == 2 then
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

local function SetJoinDate ( self , button , down )
    local name = GR_MemberDetailName:GetText();
    local dayJoined = UIDropDownMenu_GetSelectedID ( DayDropDownMenu );
    local monthJoined = UIDropDownMenu_GetSelectedID ( MonthDropDownMenu );
    local yearJoined = tonumber( UIDropDownMenu_GetText ( YearDropDownMenu ) );
    local isLeapYearSelected = IsLeapYear ( yearJoined );

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
                        
                        table.insert( GR_GuildMemberHistory_Save[j][r][20] , finalTimeStamp );     -- oldJoinDate
                        table.insert( GR_GuildMemberHistory_Save[j][r][21] , finalEpochStamp ) ;   -- oldJoinDateMeta
                        GR_GuildMemberHistory_Save[j][r][2] = finalTimeStamp;
                        GR_GuildMemberHistory_Save[j][r][3] = finalEpochStamp;
                        GR_JoinDateText:SetText ( strsub ( joinDate , 9 ) );

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
    pause = false;
end

local function SetPromoDate ( self , button , down )
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

                        if rankIndex > playerIndex then
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
    pause = false;
end

-- Method:          SetDateSelectFrame( string , frameObject, string )
-- What it Does:    On Clicking the "Set Join Date" button this logic presents itself
-- Purpose:         Handle the event to modify when a player joined the guild. This is useful for anniversary date tracking.
--                  It is also necessary because upon starting the addon, it is unknown a person's true join date. This allows the gleader to set a general join date.
local function SetDateSelectFrame ( position, frame, buttonName )
    local _,month,_,currentYear = CalendarGetDate();
    local xPosMonth,yPosMonth,xPosDay,yPosDay,xPosYear,yPosYear,xPosSubmit,yPosSubmit,xPosCancel,yPosCancel = 0;        -- Default positions.
    local joinDateText = "Set Join Date";
    local promoDateText = "Set Promo Date"
    local timeEnum = date ( "*t" );
    local currentDay = timeEnum [ "day" ];

    -- Month
    UIDropDownMenu_Initialize ( MonthDropDownMenu , InitializeDropDownMonth );
    UIDropDownMenu_SetWidth ( MonthDropDownMenu , 83 );
    UIDropDownMenu_SetSelectedID ( MonthDropDownMenu , month )
    monthIndex = month;
    
    
    -- Year
    UIDropDownMenu_Initialize ( YearDropDownMenu, InitializeDropDownYear );
    UIDropDownMenu_SetWidth ( YearDropDownMenu , 53 );
    UIDropDownMenu_SetSelectedID ( YearDropDownMenu , 1 );
    yearIndex = currentYear;
    

    -- Initialize the day choice now.
    UIDropDownMenu_Initialize ( DayDropDownMenu , InitializeDropDownDay );
    UIDropDownMenu_SetWidth ( DayDropDownMenu , 40 );
    UIDropDownMenu_SetSelectedID ( DayDropDownMenu , currentDay );
    dayIndex = 1;
    
    -- Script Handlers
    DateSubmitCancelButton:SetScript("OnClick" , function (self , button , down ) 
        
        MonthDropDownMenu:Hide();
        YearDropDownMenu:Hide();
        DayDropDownMenu:Hide();
        DateSubmitButton:Hide();
        DateSubmitCancelButton:Hide();

        -- Determine which information needs to repopulate.
        local buttonText = GR_DateSubmitButtonTxt:GetText()
        if joinDateText == buttonText then
            MemberDetailJoinDateButton:Show();
            --RANK PROMO DATE
            if rankDateSet == false then      --- Promotion has never been recorded!
                GR_MemberDetailRankDateTxt:Hide();                     
                SetPromoDateButton:Show();
            else
                GR_MemberDetailRankDateTxt:Show();
            end
        elseif buttonText == promoDateText then
            SetPromoDateButton:Show();
        end
        pause = false;
    end);

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

    MonthDropDownMenu:SetPoint ( position , frame , xPosMonth , yPosMonth );
    YearDropDownMenu:SetPoint ( position , frame , xPosYear , yPosYear );
    DayDropDownMenu:SetPoint ( position , frame , xPosDay , yPosDay );
    DateSubmitButton:SetPoint ( position , frame , xPosSubmit , yPosSubmit );
    DateSubmitCancelButton:SetPoint ( position , frame , xPosCancel , yPosCancel );

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
        local numChoices = (numRanks - playerIndex - 1);
        local solution = rankIndex2 + numRanks - numChoices;
        local guildName = GetGuildInfo("player");

        UIDropDownMenu_SetSelectedID ( guildRankDropDownMenu , rankIndex2 );
            
        for i = 1 , GetNumGuildies() do
            local name = GetGuildRosterInfo ( i );
            
            if SlimName ( name ) == tempName then
                SetGuildMemberRank ( i , solution );
                -- Now, let's make the changes immediate for the button date.
                if SetPromoDateButton:IsVisible() then
                    SetPromoDateButton:Hide();
                    GR_MemberDetailRankDateTxt:SetText ( "PROMOTED: " .. Trim ( strsub(GetTimestamp() , 1 , 10 ) ) );
                    GR_MemberDetailRankDateTxt:Show();
                end
                pause = false;
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
    for i = 2 , ( GuildControlGetNumRanks() - playerIndex ) do
        local rank = UIDropDownMenu_CreateInfo();
        rank.text = ("   " .. GuildControlGetRankName ( i + playerIndex ));  -- Extra spacing is to justify it properly to center in allignment with other text due to dropdown button deformation of pattern.
        rank.func = OnRankDropMenuClick;
        UIDropDownMenu_AddButton ( rank );
    end
end

local function CreateRankDropDown( self )
    
    UIDropDownMenu_Initialize ( guildRankDropDownMenu , PopulateRankDropDown );
    UIDropDownMenu_SetWidth ( guildRankDropDownMenu , 112 );
    UIDropDownMenu_JustifyText ( guildRankDropDownMenu , "CENTER" );

    local numRanks = GuildControlGetNumRanks();
    local numChoices = (numRanks - playerIndex - 1);
    local solution =  rankIndex - ( numRanks - numChoices ) + 1;   -- Calculating which rank to select based on flexible and scalable rank numbers.

    UIDropDownMenu_SetSelectedID ( guildRankDropDownMenu , solution );
    guildRankDropDownMenu:Show();
end

-------------------------------
----- UI SCRIPTING LOGIC ------
----- ALL THINGS UX ARE HERE --
-------------------------------

local function PopulateMemberDetails( handle )
    local guildName = GetGuildInfo("player");
    rankDateSet = false;        -- resetting tracker

    for j = 1,#GR_GuildMemberHistory_Save do
        if GR_GuildMemberHistory_Save[j][1] == guildName then
            for r = 2,#GR_GuildMemberHistory_Save[j] do
                if GR_GuildMemberHistory_Save[j][r][1] == handle then   --- Player Found in MetaData Logs
                    -- Trigger Check for Any Changes
                    GuildRoster(); 

                    ------ Populating the UI Window ------
                    local class = GR_GuildMemberHistory_Save[j][r][9];
                    local level = GR_GuildMemberHistory_Save[j][r][6];
                    local isOnlineNow = false;
                    local statusNow = 0;      -- 0 = active, 1 = Away, 2 = DND (busy)

                    --- CLASS
                    GR_MemberDetailNameText:SetPoint( "TOP" , 0 , -20 );
                    if class == "DEATH KNIGHT" then
                        GR_MemberDetailNameText:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
                    elseif class == "DEMON HUNTER" then
                        GR_MemberDetailNameText:SetTextColor ( 0.64 , 0.19 , 0.79 , 1.0 );
                    elseif class == "DRUID" then
                        GR_MemberDetailNameText:SetTextColor ( 1.0 , 0.49 , 0.04 , 1.0 );
                    elseif class == "HUNTER" then
                        GR_MemberDetailNameText:SetTextColor ( 0.67 , 0.83 , 0.45 , 1.0 );
                    elseif class == "MAGE" then
                        GR_MemberDetailNameText:SetTextColor ( 0.41 , 0.80 , 0.94 , 1.0 );
                    elseif class == "MONK" then
                        GR_MemberDetailNameText:SetTextColor ( 0.0 , 1.0 , 0.59 , 1.0 );
                    elseif class == "PALADIN" then
                        GR_MemberDetailNameText:SetTextColor ( 0.96 , 0.55 , 0.73 , 1.0 );
                    elseif class == "PRIEST" then
                        GR_MemberDetailNameText:SetTextColor ( 1.0 , 1.0 , 1.0 , 1.0 );
                    elseif class == "ROGUE" then
                        GR_MemberDetailNameText:SetTextColor ( 1.0 , 0.96 , 0.41 , 1.0 );
                    elseif class == "SHAMAN" then
                        GR_MemberDetailNameText:SetTextColor ( 0.0 , 0.44 , 0.87 , 1.0 );
                    elseif class == "WARLOCK" then
                        GR_MemberDetailNameText:SetTextColor ( 0.58 , 0.51 , 0.79 , 1.0 );
                    elseif class == "WARRIOR" then
                        GR_MemberDetailNameText:SetTextColor ( 0.78 , 0.61 , 0.43 , 1.0 );
                    end
                    -- PLAYER NAME
                    GR_MemberDetailNameText:SetText ( handle );

                    --- LEVEL
                    GR_MemberDetailLevel:SetPoint ( "TOP" , 0 , -38 );
                    GR_MemberDetailLevel:SetText ( "Level: " .. level );

                    -- RANK
                    tempName = handle;
                    rankIndex = GR_GuildMemberHistory_Save[j][r][5];
                    -- Getting live server status info of player.
                    local count = 0;
                    for i = 1 , GetNumGuildies() do
                        local name,_,indexOfRank,_,_,_,_,_,isOnline,status = GetGuildRosterInfo ( i );
                        
                        if count < 2 then
                            name = SlimName ( name );
                            if addonPlayerName == name then
                                playerIndex = indexOfRank;
                                count = count + 1;
                            end
                            if handle == name then
                                if isOnline then
                                    isOnlineNow = true;
                                end
                                if ( status ~= nil or handle == addonPlayerName ) and ( status == 1 or status == 2) then
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
                    if rankIndex > playerIndex and ( canPromote or canDemote ) then
                        GR_MemberDetailRankTxt:Hide();
                        CreateRankDropDown();
                    else
                        guildRankDropDownMenu:Hide();
                        GR_MemberDetailRankTxt:SetText ( "\"" .. GR_GuildMemberHistory_Save[j][r][4] .. "\"");
                        GR_MemberDetailRankTxt:Show();
                    end

                    -- STATUS TEXT
                    if isOnlineNow or handle == addonPlayerName then
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
                        if rankIndex > playerIndex and ( canPromote or canDemote ) then
                            SetPromoDateButton:SetPoint ( "TOP" , MemberDetailMetaData , 0 , -80 ); -- slightly varied positioning due to drop down window or not.
                        else
                            SetPromoDateButton:SetPoint ( "TOP" , MemberDetailMetaData , 0 , -67 );
                        end                        
                        SetPromoDateButton:Show();
                    else
                        SetPromoDateButton:Hide();
                        if rankIndex > playerIndex and ( canPromote or canDemote ) then
                            GR_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -82 ); -- slightly varied positioning due to drop down window or not.
                        else
                            GR_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -70 );
                        end
                        rankDateSet = true;
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
                    if finalNote ~= "Click here to set a Public Note" then
                        PlayerNoteEditBox:SetText( finalNote );
                    else
                        PlayerNoteEditBox:SetText( "" );
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
                    if isOnlineNow and handle ~= addonPlayerName then
                        if GetNumGroupMembers() > 0  then            -- If > 0 then player is in either a raid or a party. (1 will show if in an instance by oneself)
                            local isGroupLeader = UnitIsGroupLeader ( "PLAYER" );                                       -- Party or Group
                            local isInRaidWithAssist = UnitIsGroupAssistant ( "PLAYER" , LE_PARTY_CATEGORY_HOME );      -- Player Has Assist in Raid group

                            if IsGuildieInSameGroup ( handle ) then
                                -- Player is already in group!
                                GR_GroupInviteButtonText:SetText ( "In Group" );
                                groupInviteButton:SetScript ("OnClick" , function ( self , button , down )
                                    if button == "LeftButton" then
                                        print ( handle .. " is Already in Your Group!" );
                                    end
                                end);
                            elseif isGroupLeader or isInRaidWithAssist then                                         -- Player has the ability to invite to group
                                GR_GroupInviteButtonText:SetText ( "Group Invite" );
                                groupInviteButton:SetScript ("OnClick" , function ( self , button , down )
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
                                GR_GroupInviteButtonText:SetText ( "No Invite" );
                                groupInviteButton:SetScript ("OnClick" , function ( self , button , down )
                                    if button == "LeftButton" then
                                        print ( "Player must obtain group invite privileges." );
                                    end
                                end);
                            end
                        else
                            -- Player is not in any group, thus inviting them will create new group.
                            GR_GroupInviteButtonText:SetText ( "Group Invite" );
                            groupInviteButton:SetScript ("OnClick" , function ( self , button , down )
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
                    if handle ~= addonPlayerName and rankIndex > playerIndex and CanGuildRemove() then
                        local isGuildieBanned = GR_GuildMemberHistory_Save[j][r][17];
                        if isGuildieBanned then
                            GR_RemoveGuildieButtonText:SetText ( "Re-Kick" );
                        else
                            GR_RemoveGuildieButtonText:SetText ( "Remove" );
                        end
                        removeGuildieButton:Show();
                        GR_RemoveGuildieButton:SetScript ( "OnClick" , function ( _ , button )
                            -- Inital check is to ensure clean UX - ensuring the next time window is closed on reload, but if already open, no need to close it.
                            if button == "LeftButton" then
                                pause = true
                                if GR_PopupWindow:IsVisible() ~= true then
                                    GR_MemberDetailEditBoxFrame:Hide();
                                    GR_PopupWindowCheckButton1:SetChecked ( false ); -- Ensures it is always unchecked on load.
                                end
                                if GR_RemoveGuildieButtonText:GetText() == "Re-Kick" then
                                    GR_PopupWindowConfirmText:SetText ( "Are you sure you want to Re-Gkick " .. handle .. "?" );
                                else
                                    GR_PopupWindowConfirmText:SetText ( "Are you sure you want to Gkick " .. handle .. "?" );
                                end
                                if GR_RemoveGuildieButtonText:GetText() ~= "Re-Kick" then
                                    GR_PopupWindowCheckButtonText:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
                                    GR_PopupWindowCheckButtonText:SetText ( "Ban Player" );
                                    GR_PopupWindowCheckButtonText:Show();
                                    GR_PopupWindowCheckButton1:Show();
                                else
                                    GR_PopupWindowCheckButtonText:Hide();
                                    GR_PopupWindowCheckButton1:Hide();
                                end
                                GR_PopupWindow:Show();

                                -- Create Button Logic
                                GR_PopupWindowButton1:SetScript ( "OnClick" , function( _ , button )
                                    if button == "LeftButton" then
                                        if GR_PopupWindowCheckButton1:IsVisible() and GR_PopupWindowCheckButton1:GetChecked() then          -- Box is checked, so YES player should be banned.
                                            GR_GuildMemberHistory_Save[j][r][17] = true;      -- Banning Player.
                                            -- Popup edit box
                                            local instructionNote = "Reason Banned? (Press ENTER when done)"
                                            MemberDetailPopupEditBox:SetText ( instructionNote );
                                            MemberDetailPopupEditBox:HighlightText ( 0 );
                                            MemberDetailPopupEditBox:SetScript ( "OnEnterPressed" , function ( _ ) 
                                                local result = MemberDetailPopupEditBox:GetText();
                                                if result ~= instructionNote and result ~= "" and result ~= nil then
                                                    GR_GuildMemberHistory_Save[j][r][18] = result;
                                                elseif result == nil then
                                                    GR_GuildMemberHistory_Save[j][r][18] = "";
                                                end
                                                -- Now let's kick the member
                                                GuildUninvite ( handle );
                                                GR_MemberDetailEditBoxFrame:Hide();
                                                pause = false;                                                
                                            end);

                                            GR_MemberDetailEditBoxFrame:Show();

                                        else    -- Kicking the player ( not a ban )
                                            GR_PopupWindow:Hide();
                                            GuildUninvite ( handle );
                                            pause = false;
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
                                GR_RemoveGuildieButtonText:SetText( "Remove" );
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




                    break;
                end
            end
            break;
        end
    end
end

local function ClearFrame()
    MonthDropDownMenu:Hide();
    YearDropDownMenu:Hide();
    DayDropDownMenu:Hide();
    guildRankDropDownMenu:Hide();
    MemberDetailMetaData:Hide();
end

-- Method:              GR_RosterFrame(self,elapsed)
-- What it Does:        In the main guild window, guild roster screen, rather than having to select a guild member to see the additional window pop update
--                      all the player needs to do is just mousover it.
-- Purpose:             This is for more efficient "glancing" at info for guild leader, with more details.
local function GR_RosterFrame(self,elapsed)
    timer = timer + elapsed;
    if timer >= 0.075 then
        -- control on whether to freeze the scanning.
        if pause and MemberDetailMetaData:IsVisible() == false then
            pause = false;
        end

        local NotSameWindow = true;
        local mouseNotOver = true;
        local name = "";
        if pause == false then
            if (GuildRosterContainerButton1:IsMouseOver(1,-1,-1,1)) then
                if 1 ~= position then
                    name = GuildRosterContainerButton1String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton1String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 1;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif(GuildRosterContainerButton2:IsVisible() and GuildRosterContainerButton2:IsMouseOver(1,-1,-1,1)) then
                if 2 ~= position then
                    name = GuildRosterContainerButton2String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton2String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 2;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton3:IsVisible() and GuildRosterContainerButton3:IsMouseOver(1,-1,-1,1)) then
                if 3 ~= position then
                    name = GuildRosterContainerButton3String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton3String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 3;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton4:IsVisible() and GuildRosterContainerButton4:IsMouseOver(1,-1,-1,1)) then
                if 4 ~= position then
                    name = GuildRosterContainerButton4String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton4String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 4;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton5:IsVisible() and GuildRosterContainerButton5:IsMouseOver(1,-1,-1,1)) then
                if 5 ~= position then
                    name = GuildRosterContainerButton5String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton5String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 5;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton6:IsVisible() and GuildRosterContainerButton6:IsMouseOver(1,-1,-1,1)) then
                if 6 ~= position then
                    name = GuildRosterContainerButton6String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton6String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 6;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton7:IsVisible() and GuildRosterContainerButton7:IsMouseOver(1,-1,-1,1)) then
                if 7 ~= position then
                    name = GuildRosterContainerButton7String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton7String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 7;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton8:IsVisible() and GuildRosterContainerButton8:IsMouseOver(1,-1,-1,1)) then
                if 8 ~= position then
                    name = GuildRosterContainerButton8String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton8String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 8;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton9:IsVisible() and GuildRosterContainerButton9:IsMouseOver(1,-1,-1,1)) then
                if 9 ~= position then
                    name = GuildRosterContainerButton9String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton9String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 9;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton10:IsVisible() and GuildRosterContainerButton10:IsMouseOver(1,-1,-1,1)) then
                if 10 ~= position then
                    name = GuildRosterContainerButton10String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton10String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 10;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton11:IsVisible() and GuildRosterContainerButton11:IsMouseOver(1,-1,-1,1)) then
                if 11 ~= position then
                    name = GuildRosterContainerButton11String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton11String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 11;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton12:IsVisible() and GuildRosterContainerButton12:IsMouseOver(1,-1,-1,1)) then
                if 12 ~= position then
                    name = GuildRosterContainerButton12String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton12String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 12;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton13:IsVisible() and GuildRosterContainerButton13:IsMouseOver(1,-1,-1,1)) then
                if 13 ~= position then
                    name = GuildRosterContainerButton13String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton13String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 13;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif (GuildRosterContainerButton14:IsVisible() and GuildRosterContainerButton14:IsMouseOver(1,-1,-1,1)) then
                if 14 ~= position then
                    name = GuildRosterContainerButton14String1:GetText();
                    if tonumber ( name ) ~= nil then
                        name = GuildRosterContainerButton14String2:GetText();
                    end
                    PopulateMemberDetails( name );
                    if MemberDetailMetaData:IsVisible() ~= true then
                        MemberDetailMetaData:Show();
                    end
                    position = 14;
                    pause = false;
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            end
            -- Logic on when to make Member Detail,not,rank window disappear.
            if mouseNotOver and NotSameWindow and pause == false then
                if ( GuildRosterFrame:IsMouseOver(2,-2,-2,2) ~= true and DropDownList1Backdrop:IsMouseOver(2,-2,-2,2) ~= true and GR_MemberDetails:IsMouseOver(2,-2,-2,2) ~= true ) or 
                    ( GR_MemberDetails:IsMouseOver(2,-2,-2,2) == true and GR_MemberDetails:IsVisible() ~= true ) then  -- If player is moused over side window, it will not hide it!
                    position = 0;
                    MonthDropDownMenu:Hide();
                    YearDropDownMenu:Hide();
                    DayDropDownMenu:Hide();
                    guildRankDropDownMenu:Hide();
                    DateSubmitButton:Hide();
                    DateSubmitCancelButton:Hide();
                    GR_PopupWindow:Hide();
                    MemberDetailMetaData:Hide();
                end
            end
        end
        if GuildRosterFrame:IsVisible() ~= true then
            MonthDropDownMenu:Hide();
            YearDropDownMenu:Hide();
            DayDropDownMenu:Hide();
            guildRankDropDownMenu:Hide();
            DateSubmitButton:Hide();
            DateSubmitCancelButton:Hide();
            GR_PopupWindow:Hide();
            MemberDetailMetaData:Hide();
        end
        timer = 0;
    end
end

-- Method:              GR_Roster_Click(self,button,down)
-- What it Does:        For logic on mouseover, instead of mouseover, it simulates a click on the item by bringing it to show.
--                      The "pause" is just a call to pause the hiding of the frame in the GR_RosterFrame() function until it finds a new window (to prevent wasteful clicking and resource hogging)
-- Purpose:             Smoother UI interface in the built-in Guild Roster in-game UI default window.
local function GR_Roster_Click  (self , button , down )
    GuildMemberDetailFrame:Hide();
    if GuildRosterContainerButton1:IsMouseOver(1,-1,-1,1) then
        GuildRosterContainerButton1:UnlockHighlight();
    elseif GuildRosterContainerButton2:IsMouseOver(1,-1,-1,1) then
        GuildRosterContainerButton2:UnlockHighlight();
    end
    pause = true;
end

local function ClearAllRosterButtons ( self , button , down )
    GuildFrame:Hide();
    MonthDropDownMenu:Hide();
    YearDropDownMenu:Hide();
    DayDropDownMenu:Hide();
    guildRankDropDownMenu:Hide();
    MemberDetailMetaData:Hide();
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
    timer2 = timer2 + elapsed;
    if timer2 >= 0.075 then
        local name = GR_MemberDetailName:GetText();
        local guildName = GetGuildInfo("player");

        -- Rank Text
        -- Only populate and show tooltip if mouse is over text frame and it is not already visible.
        if MemberDetailRankToolTip:IsVisible() ~= true and GR_MemberDetailRankDateTxt:IsVisible() == true and GR_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) == true then
            
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
        if MemberDetailJoinDateToolTip:IsVisible() ~= true and GR_JoinDateText:IsVisible() == true and GR_JoinDateText:IsMouseOver(1,-1,-1,1) == true then
           
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

        timer2 = 0;
    end
end

-- Method:                  GR_CreateOfficerNoteButton()
-- What it Does:            Initializes the Officer Button details
-- Purpose:                 Simple positional and UI use logic for button.
local function GR_MetaDataInitializeUI()
    -- Frame Control
    MemberDetailMetaData:EnableMouse(true);
    MemberDetailMetaData:SetMovable(true);
    MemberDetailMetaData:RegisterForDrag("LeftButton");
    MemberDetailMetaData:SetScript("OnDragStart", MemberDetailMetaData.StartMoving);
    MemberDetailMetaData:SetScript("OnDragStop", MemberDetailMetaData.StopMovingOrSizing);

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
            if pause then
                pause = false;
            else
                MemberDetailMetaData:Hide();
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
            pause = true;
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
    GR_MemberDetailJoinTitleTxt:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -18 , -20 );
    GR_MemberDetailJoinTitleTxt:SetText ("Date Joined");
    GR_MemberDetailJoinTitleTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GR_JoinTitleTxtUnderline:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -18 , -22 );
    GR_JoinTitleTxtUnderline:SetText ("__________");
    GR_JoinTitleTxtUnderline:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GR_MemberDetailJoinTxt:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -18 , -27 );
    GR_MemberDetailJoinTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GR_MemberDetailJoinTxt:SetTextColor ( 1.0 , 1.0 , 1.0 , 1.0 );
    GR_JoinDateText:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -20 , - 33 );
    GR_JoinDateText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GR_JoinDateText:SetWidth ( 55 );
    GR_JoinDateText:SetJustifyH ( "CENTER" );

    -- "LAST ONLINE" 
    GR_MemberDetailLastOnlineTitleTxt:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 19 , -20 );
    GR_MemberDetailLastOnlineTitleTxt:SetText ( "Last Online" );
    GR_MemberDetailLastOnlineTitleTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GR_MemberDetailLastOnlineUnderline:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 21, -22 );
    GR_MemberDetailLastOnlineUnderline:SetText ( "__________" );
    GR_MemberDetailLastOnlineUnderline:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GR_MemberDetailLastOnlineTxt:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 14 , -32 );
    GR_MemberDetailLastOnlineTxt:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );
    GR_MemberDetailLastOnlineTxt:SetWidth ( 65 );
    GR_MemberDetailLastOnlineTxt:SetJustifyH ( "CENTER" );
    
    -- PLAYER STATUS
    GR_MemberDetailPlayerStatus:SetPoint ( "TOPLEFT" , MemberDetailMetaData , 21 , - 48 );
    GR_MemberDetailPlayerStatus:SetWidth ( 50 );
    GR_MemberDetailPlayerStatus:SetJustifyH ( "CENTER" );
    GR_MemberDetailPlayerStatus:SetFont ( "Fonts\\FRIZQT__.TTF" , 9 );

    -- Join Date Button Logic for visibility
    MemberDetailJoinDateButton:SetPoint ( "TOPRIGHT" , MemberDetailMetaData , -18 , - 33 );
    MemberDetailJoinDateButton:SetWidth ( 58 );
    MemberDetailJoinDateButton:SetHeight ( 17 );
    GR_JoinDateButtonText:SetText ( "Join Date?" );
    GR_JoinDateButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );
    GR_JoinDateButtonText:SetPoint ( "CENTER" , MemberDetailJoinDateButton , 0 , 0 );
    MemberDetailJoinDateButton:SetScript ( "OnClick" , function ( self , button , down )
        if button == "LeftButton" then
            MemberDetailJoinDateButton:Hide();
            if GR_MemberDetailRankDateTxt:IsVisible() then
                GR_MemberDetailRankDateTxt:Hide();
            elseif SetPromoDateButton:IsVisible() then
                SetPromoDateButton:Hide();
            end
            SetDateSelectFrame ( "TOP" , MemberDetailMetaData , "JoinDate" );  -- Position, Frame, ButtonName
            pause = true;
        end
    end);

    -- GROUP INVITE BUTTON
    groupInviteButton:SetPoint ( "BOTTOMLEFT" , MemberDetailMetaData , 16, 13 )
    groupInviteButton:SetWidth ( 58 );
    groupInviteButton:SetHeight ( 17 );
    GR_GroupInviteButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.8 );
    GR_GroupInviteButtonText:SetPoint ( "CENTER" , groupInviteButton , 0 , 0 );
        
    -- REMOVE GUILDIE BUTTON
    removeGuildieButton:SetPoint ( "BOTTOMRIGHT" , MemberDetailMetaData , -15, 13 )
    removeGuildieButton:SetWidth ( 58 );
    removeGuildieButton:SetHeight ( 17 );
    GR_RemoveGuildieButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 7.8 );
    GR_RemoveGuildieButtonText:SetText ( "Remove" );
    GR_RemoveGuildieButtonText:SetPoint ( "CENTER" , removeGuildieButton , 0 , 0 );

    -- player note edit box and font string (31 characters)
    GR_MemberDetailNoteTitle:SetPoint ( "LEFT" , MemberDetailMetaData , 21 , 32 );
    GR_MemberDetailNoteTitle:SetText ( "Note:" );
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
    NoteCount:SetPoint ("TOPRIGHT" , PlayerNoteEditBox , -6 , 8 );
    NoteCount:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

    -- Officer Note
    GR_MemberDetailOfficerNoteTitle:SetPoint ( "RIGHT" , MemberDetailMetaData , -70 , 32 );
    GR_MemberDetailOfficerNoteTitle:SetText ( "Officer's Note:" );
    GR_MemberDetailOfficerNoteTitle:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

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
    officerNoteCount:SetPoint ("TOPRIGHT" , PlayerOfficerNoteEditBox , -6 , 8 );
    officerNoteCount:SetFont ( "Fonts\\FRIZQT__.TTF" , 8 );

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
    GR_PopupWindowConfirmText:SetPoint ( "TOP" , GR_PopupWindow , 0 , -25 );
    GR_PopupWindowConfirmText:SetWidth ( 185 );
    GR_PopupWindowConfirmText:SetJustifyH ( "CENTER" );
    GR_PopupWindowCheckButton1:SetPoint ( "BOTTOMLEFT" , GR_PopupWindow , 15 , 40 );
    GR_PopupWindowCheckButtonText:SetPoint ( "RIGHT" , GR_PopupWindowCheckButton1 , 54 , 0 );

    GR_PopupWindowCheckButton1:HookScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            if GR_PopupWindowCheckButton1:GetChecked() ~= true then
                GR_MemberDetailEditBoxFrame:Hide();                 -- If editframe is up, and you uncheck the box, it hides the editbox too
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
    GR_MemberDetailBannedText1:SetPoint ( "CENTER" , MemberDetailMetaData , 0 , -15 );
    GR_MemberDetailBannedText1:SetWordWrap ( true );
    GR_MemberDetailBannedText1:SetJustifyH ( "CENTER" );
    GR_MemberDetailBannedText1:SetTextColor ( 1.0 , 0.0 , 0.0 , 1.0 );
    GR_MemberDetailBannedText1:SetFont( "Fonts\\FRIZQT__.TTF" , 8.0 );
    GR_MemberDetailBannedText1:SetText ( "WARNING -Rejoining player previously banned!- WARNING" );
    GR_MemberDetailBannedIgnoreButton:SetPoint ( "CENTER" , MemberDetailMetaData , 0 , -30 );
    GR_MemberDetailBannedIgnoreButton:SetWidth ( 70 );
    GR_MemberDetailBannedIgnoreButton:SetHeight ( 17 );
    GR_MemberDetailBannedIgnoreButtonText:SetPoint ( "CENTER" , GR_MemberDetailBannedIgnoreButton );
    GR_MemberDetailBannedIgnoreButtonText:SetFont ( "Fonts\\FRIZQT__.TTF" , 8.0);
    GR_MemberDetailBannedIgnoreButtonText:SetText ( "Ignore Ban" );
    
    

    -- Script handlers on Note Edit Boxes
    local defaultNote = "Click here to set a Public Note";
    local defaultONote = "Click here to set an Officer's Note";
    local tempNote = "";
    local finalNote = "";

    -- Script handlers on Note Frames
    PlayerNoteWindow:SetScript ( "OnMouseDown" , function( self , button ) 
        if button == "LeftButton" and CanEditPublicNote() then 
            pause = true;
            noteFontString1:Hide();
            PlayerOfficerNoteEditBox:Hide();
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
        end 
    end);

    PlayerOfficerNoteWindow:SetScript ( "OnMouseDown" , function( self , button ) 
        if button == "LeftButton" and CanEditOfficerNote() then 
            pause = true;
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
            officerNoteCount:SetText( charCount .. "/31");
            PlayerOfficerNoteEditBox:Show();
        end 
    end);


    -- Cancels editing in Note editbox
    PlayerNoteEditBox:SetScript ( "OnEscapePressed" , function ( self ) 
        PlayerNoteEditBox:Hide();
        tempNote = noteFontString1:GetText();
        if tempNote ~= defaultNote and tempNote ~= "" then
            finalNote = tempNote;
        else
            finalNote = "";
        end
        PlayerNoteEditBox:SetText( finalNote );
        noteFontString1:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            pause = false;
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
        noteFontString1:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            pause = false;
        end
    end);

    PlayerOfficerNoteEditBox:SetScript ( "OnEscapePressed" , function ( self ) 
        PlayerOfficerNoteEditBox:Hide();
        tempNote = noteFontString2:GetText();
        if tempNote ~= defaultONote and tempNote ~= "" then
            finalNote = tempNote;
        else
            finalNote = "";
        end
        PlayerOfficerNoteEditBox:SetText( finalNote );
        noteFontString2:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            pause = false;
        end
    end);

    -- Updates char count as player types.
    PlayerOfficerNoteEditBox:SetScript ( "OnChar" , function ( self , text ) 
        local charCount = #PlayerOfficerNoteEditBox:GetText();
        charCount = charCount;
        officerNoteCount:SetText( charCount .. "/31");
    end);

    -- Update on backspace changes too
    PlayerOfficerNoteEditBox:SetScript ( "OnKeyDown" , function ( self , text )  -- While technically this one script handler could do all, this is more processor efficient to have 2.
        if text == "BACKSPACE" then
            local charCount = #PlayerOfficerNoteEditBox:GetText();
            charCount = charCount - 1;
            if charCount == -1 then
                charCount = 0;
            end
            officerNoteCount:SetText( charCount .. "/31");
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
        noteFontString2:Show();
        if DateSubmitButton:IsVisible() ~= true then            -- Does not unpause if the date still needs to be selected or canceled.
            pause = false;
        end
    end);




end

-- Method:              InitiateMemberDetailFrame(self,event,msg)
-- What it Does:        Event Listener, it activates when the Guild Roster window is opened and interface is queried/triggered
--                      "GuildRoster()" needs to fire for this to activate as it creates the following 4 listeners this is looking for: GUILD_NEWS_UPDATE, GUILD_RANKS_UPDATE, GUILD_ROSTER_UPDATE, and GUILD_TRADESKILL_UPDATE
-- Purpose:             Create an Event Listener for the Guild Roster Frame in the guild window ('J' key)
local function InitiateMemberDetailFrame(self,event,msg)
    -- So when you click the lower Roster Tab
    if GuildFrame:IsVisible() and GuildRosterFrame:IsVisible() ~= true then
        -- Do nothing... Queryof these frames is all it needs to kickstart internal GuildRoster() query.
    end

    -- To Clear Frames
    -- GuildFrameCloseButton:SetScript("OnClick",ClearAllRosterButtons);

    if GuildRosterFrame:IsVisible() then
        -- Member Detail Frame Info
        GR_MetaDataInitializeUI(); -- Initializing Officer Note Edit Button.  
       
        -- Roster Positions
        GuildRosterFrame:HookScript("OnUpdate",GR_RosterFrame);
        -- GuildRosterContainerButton1:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton2:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton3:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton4:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton5:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton6:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton7:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton8:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton9:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton10:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton11:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton12:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton13:SetScript("OnClick",GR_Roster_Click)
        -- GuildRosterContainerButton14:SetScript("OnClick",GR_Roster_Click)
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
    UI_Events:SetScript("OnEvent",InitiateMemberDetailFrame)
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
    -- Export to excel or other formats, like PDF changes
    -- Interesting stat reporting with weekly updates
        -- Like number of legendaries collected this weekly
        -- Notable achievements, like Prestige advancements
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Notable high ilvl notifications with adjustable threshold to trigger it
    -- Linking alts to mains  - MAYBE 
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
    -- /roster will be the slash command
    -- Notable dates in History!

    -- Longest period of time player was inactive.
    -- Add slash command to ban player, which simultaneously gkicks them.
    -- Fix Player level when joining.
    -- On closeing MetaDetailFrame, unhighlight rosterbuttons if clicked.
    -- # times signed up for event. (attended?)
    -- Search of the History Window
    -- Filters
    -- Export to PDF
    -- Export to TXT
    -- Export to Excel?

    -- Remaining Characters Count on Message of the Day).
    -- Check for Guild Name Change
    -- Create unpause function that removes highlights too.
    -- Public Note cannot edit logic for players without access.
    -- remove weird count up on officer note change if unable to view them.
    -- Add method to wipe a player's metadata 
    -- Add method to wipe all and start over...
    -- Review how to check if it is a namechange by checking metadata.
    -- Roster Screen Dropdown choice for different pages Box cannot select ones if howvering over a button.
    -- Mark attendance for all in raid +1
    -- Invite everyone online to guild group
    -- Customize notifications for guild promotions!
    -- If someone is banned, a reminder is given on their alts still in the guild.
    -- Options to only track some features, not all...
    -- Show the difference between left and kicked from the guild (will have to look at the actual guild log).

    -- Add method that increments up by 1 a tracker on num events attended, the date, total events attended, for each person that is in the raid 100group.
    -- "Click Here to set a public note" should not be an option if player does not have ability to.
    -- On rank promotion, change the text right away!
    -- "Date Promoted?" button does not need to be there when someone joins the guild.
    -- Fix logic on returning to old guild it refreshes data.

    -- UI ADDITIONS TO BE ADDED
    -- /ban "PlayerName"   >>> gkick player if they are still in the guild. Immediately bring up popup box to enter reason why.
    -- if rejoin and player was banned, in Big letters across the bottom  -- >> "BANNED PLAYER HAS REJOINED THE GUILD!" >> Provide detailed metadata > Add Buttons "Ignore?" "Re-Kick"
    --          If player hits ignore it wipes the "PreviouslyBanned" boolean to false and clears the banned reason note
    -- Add tooltip to level hover "Leveling Milestones while in Guild!"  -- GUILD FIRSTS FOR EXPANSION LEVELS? First 3!
    -- Add Professions info and their levels.
    -- Remove / Group Invite Buttons
    
    -- Raid window - Number of guildies in current group
    -- Request Assist Button  -- Requests assist from raid leader 
    -- Shift-click to auto-copy character nam,e
    -- Report if player was banned as well.
    -- Clamp main window metadata to screen
    -- Tooltip for Rejoin warning fontstring?
    -- Change Date promoted as soon as I hit submit





















    -- function timeTest ( seconds )
    --     -- Current Info right now
    --     seconds = time() - seconds;

    --     local timeEnum = date ( "*t" );
    --     local currentYear = timeEnum [ "year" ];
    --     local currentMonth = timeEnum [ "month" ];
    --     local currentDay = timeEnum [ "day" ];
    --     local currentHour = timeEnum [ "hour" ];
    --     local currentMinute = timeEnum [ "min" ];
    --     local currentSec = timeEnum [ "sec" ];
    --     local yday = timeEnum [ "yday" ];
        
    --     -- Useful values, so one does not need to run additional calculations.
    --     local secondsInHour = 3600
    --     local secondsInDay = 86400
    --     local secondsInYear = 31536000
    --     local secondsInLeapYear = 31622400
    --     local monthWith28 = 2419200
    --     local monthWith29 = 2505600
    --     local monthWith30 = 2592000
    --     local monthWith31 = 2678400
    --     local remainingSeconds = seconds;

    --     -- For result reporting.
    --     local yearsFinal = 0;
    --     local monthsFinal = 0;
    --     local hoursFinal = 0;
    --     local daysFinal = 0;
    --     local minutesFinal = 0;
    --     local secondsFinal = 0;

    --     -- First need to calculate how many seconds have passed so far this year.
    --     local totalSeconds = ( yday - 1 ) * secondsInDay;
    --     totalSeconds = totalSeconds + ( currentHour * secondsInHour );
    --     totalSeconds = totalSeconds + ( currentMinute * 60 );
    --     totalSeconds = totalSeconds + currentSec;
        
    --     if seconds - totalSeconds < 0 then
    --         -- Logic to calculate this year.

    --     else
    --             -- Calculating the year exactly
    --         totalSeconds = seconds;
    --         local i = 0;
    --         while ( totalSeconds > 0 ) do
    --             if IsLeapYear( currentYear - 1 - i ) then
    --                 totalSeconds = totalSeconds - secondsInLeapYear; -- leap year = 366 days
    --             else
    --                 totalSeconds = totalSeconds - secondsInYear;     -- 365 days in normal year
    --             end
    --             if totalSeconds > 0 then 
    --                 i = i + 1;
    --                 yearsFinal = yearsFinal + 1;
    --                 seconds = totalSeconds;
    --             end
    --         end
    --     end

    --     -- Calculating the number of months now.
    --     local numDays = daysBeforeMonthEnum [ tostring ( currentMonth ) ];
    --     local secondsInMonthTemp = 0;

    --     if IsLeapYear ( currentYear - yearsFinal ) and currentMonth > 2 then        -- Needed to calculate how many days.
    --         totalSeconds = ( ( currentDay - 1 ) + numDays + 1 ) * secondsInDay;      -- Calculates how many seconds are left in that year. If this number is < seconds, then we will go into next year.
    --     else
    --         totalSeconds = ( ( currentDay - 1 ) + numDays ) * secondsInDay;
    --     end

    --     -- If so, this means that we will need to go into the next year as well.
    --     if seconds > totalSeconds then
    --         seconds = seconds - totalSeconds;
    --         totalSeconds = seconds;
    --         monthsFinal = monthsFinal + ( currentMonth - 1 );

    --         --Now need to isolate the months backwards down the calendar
    --         i = 12;
    --         while ( totalSeconds > 0 ) do
    --             secondsInMonthTemp = secondsInMonth [ tostring ( i ) ];
    --                 if i == 2 and ( IsLeapYear ( currentYear - yearsFinal - 1 ) ) then  -- adding one day for leap year.
    --                 secondsInMonthTemp = secondsInMonthTemp + secondsInDay;
    --             end
                
    --             if secondsInMonthTemp < totalSeconds then                           -- We are not yet at the final month!
    --                 i = i - 1;
    --                 monthsFinal = monthsFinal + 1;
    --                 seconds = totalSeconds - secondsInMonthTemp;
    --             else                                                                -- Final month found!
    --                 local tempDay = math.floor ( ( secondsInMonthTemp - totalSeconds ) / secondsInDay ); 
    --                 local tempSec = seconds - ( ( ( secondsInMonthTemp / secondsInDay ) - currentDay- 1 ) * secondsInDay);
    --                 if tempDay < currentDay then                            -- In other words, if today is Jan 5th. If date elapsed is Dec 4th, then yes, 1 month, if Dec. 6th, it will be false
    --                     monthsFinal = monthsFinal + 1;
    --                     seconds = tempSec;
    --                 elseif tempDay == currentDay then                       -- Need to check the hour, minutes, and seconds -- Hour first!
    --                     local tempHour = math.floor ( seconds % secondsInDay ) / secondsInHour );
    --                     if tempHour < currentHour then                      -- The Hour is less, thus it is the next month!
    --                         monthsFinal = monthsFinal + 1;
    --                         seconds = tempSec;
    --                     elseif tempHour == currentHour then                 -- Since we are in the same hour, we need to check the minutes.
    --                         local tempMin = math.floor ( ( seconds % secondsInHour ) / 60 );
    --                         if tempMin < currentMinute then                 -- The minute is less, thus it is the next month!
    --                             monthsFinal = monthsFinal + 1;
    --                             seconds = tempSec;
    --                         elseif tempMin == currentMinute then            -- minutes are matching on the month
    --                             local tempSeconds = math.floor ( seconds % 60 );
    --                             if tempSeconds <= currentSec then           -- if equal or below, it will be 100% exactly 1 month to the second.
    --                                 monthsFinal = monthsFinal + 1;
    --                                 seconds = tempSec;
    --                             end
    --                         end
    --                     end
    --                 end
    --             end
    --             totalSeconds = totalSeconds - secondsInMonthTemp;
    --         end
    --     else
    --         -- Remaining months will be found
    --         totalSeconds = ( currentDay - 1 ) * secondsInDay;
    --         if seconds > totalSeconds then     -- Moving on to next month
    --             seconds = seconds - totalSeconds;
    --             totalSeconds = seconds;

    --             i = currentMonth - 1;
    --             while ( totalSeconds > 0 ) do
    --                 secondsInMonthTemp = secondsInMonth [ tostring ( i ) ];
    --                 if i == 2 and ( IsLeapYear ( currentYear - yearsFinal - 1 ) ) then  -- adding one day for leap year.
    --                     secondsInMonthTemp = secondsInMonthTemp + secondsInDay;
    --                 end
                    
    --                 if secondsInMonthTemp < totalSeconds then                           -- Checking if month should be added.
    --                     i = i - 1;
    --                     monthsFinal = monthsFinal + 1;
    --                     seconds = totalSeconds - secondsInMonthTemp;
    --                 elseif math.floor ( ( secondsInMonthTemp - seconds ) / secondsInDay ) < currentDay then  -- In other words, if today is Jan 5th. If date elapsed is Dec 4th, then yes, 1 month, if Dec. 6th, it will be false
    --                     monthsFinal = monthsFinal + 1;
    --                     seconds = seconds - ( ( ( secondsInMonthTemp / secondsInDay ) - currentDay - 1 ) * secondsInDay);
    --                 end
    --                 totalSeconds = totalSeconds - secondsInMonthTemp;
    --             end

    --         end
    --     end
    --     -- Must I add deeper days logic?
    --     -- Calculating the Remaining Days
    --     -- The rest is easy from here!
    --     daysFinal = math.floor ( seconds / secondsInDay ) - 1;
    --     hoursFinal = math.floor ( ( seconds % secondsInDay ) / secondsInHour );
    --     minutesFinal = math.floor ( ( seconds % secondsInHour ) / 60 );
    --     secondsFinal = math.floor ( seconds % 60 );
        
    --     --logic cleanup for ease.
    --     if monthsFinal == 12 then
    --         yearsFinal = yearsFinal + 1;
    --         monthsFinal = 0;
    --     end

    --     local result = yearsFinal .. " Years , " .. monthsFinal .. " Months , " .. daysFinal .. " Days , " .. hoursFinal .. " Hours , " .. minutesFinal .. " minutes , " .. secondsFinal .. " seconds.";
    --     print(result);


    -- end