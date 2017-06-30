-- For Sync controls!


-- To hold all Sync Methods/Functions
GRMsync = {};


-- Sync Globals
GRMsyncGlobals = {};

GRMsyncGlobals.channelName = "GUILD";
GRMsyncGlobals.DatabaseLoaded = false;
GRMsyncGlobals.RulesSet = false;
GRMsyncGlobals.LeadSyncProcessing = false;

-- Establishing leadership controls.
GRMsyncGlobals.IsLeaderRequested = false;
GRMsyncGlobals.LeadershipEstablished = false;
GRMsyncGlobals.IsElectedLeader = false;
GRMsyncGlobals.DesignatedLeader = "";
GRMsyncGlobals.ElectTimeOnlineTable = {};
GRMsyncGlobals.LeaderShipChanged = false;

-- For players queing to by sync'd to share data!
GRMsyncGlobals.SyncQue = {};

-- Collected Tables of Data when received from the player
GRMsyncGlobals.JDReceivedTemp = {};
GRMsyncGlobals.PDReceivedTemp = {};

-- Tables of the changes -- Leader will collect and store them here from all players before broadcasting the changes out, and then resetting them.
GRMsyncGlobals.JDChanges = {};
GRMsyncGlobals.PDChanges = {};
GRMsyncGlobals.AltAddChanges = {};
GRMsyncGlobals.AltRemoveChanges = {};
GRMsyncGlobals.AltMainChanges = {};
GRMsyncGlobals.BanChanges = {};

-- SYNC START AND STOP CONTROLS
GRMsyncGlobals.ReceivingData = false;
GRMsyncGlobals.NumPlayerDataExpected = 0;

-- SYNC PROCEDURAL ORDERING CONTROLS PER SYNC
GRMsyncGlobals.CurrentSyncPlayer = "";
GRMsyncGlobals.JDSyncComplete = false;


-- For sync control measures on player details, so leader can be determined on who has been online the longest.
GRMsyncGlobals.timeAtLogin = 0;           -- A simple new time() - timeAtLogin will determine the exact amount of time that has passed since login.


-- Prefixes for tagging info as it is sent and picked up across server channel to other players in guild.
GRMsyncGlobals.listOfPrefixes = { 

    -- syncing prefixes for LIVE syncing
    "GRM_JD",               -- Join Date
    "GRM_PD",               -- Recent Promo Date
    "GRM_AC",               -- Added to Calendar (triggers other players to remove from their que);
    "GRM_BAN",              -- For banning players and alts before full kick
    "GRM_ADDALT",           -- If an alt is tagged
    "GRM_RMVALT",           -- alt is removed
    "GRM_MAIN",             -- Player designated as "main"
    "GRM_RMVMAIN",          -- Player demoted from main.
    
    -- Syncing prefixes for retroactive syncing algorithm in establishing leadership chain of command in sync tree
    "GRM_WHOISLEADER",
    "GRM_IAMLEADER",
    "GRM_ELECT",
    "GRM_TIMEONLINE",       
    "GRM_NEWLEADER",

    -- START AND STOP CODES IN MESSAGE RECEIVING DECLARING START AND END OF DATABASE BLOCK
    "GRM_START",
    "GRM_STOP",

    -- With leadership established, Actual sharing algorithms now.
    -- Non leaders request sync to leader as needed
    "GRM_REQUESTSYNC",

    -- Leader confirms request, callsback with confirmation to begin transmission of data across Blizz's server channel for addon sync.
    "GRM_REQJDDATA",
    "GRM_REQPDDATA",
    "GRM_JDSYNC",
    "GRM_PDSYNC",
    "GRM_ALTSYNC",
    "GRM_BANSYNC",

    -- FOR FINAL UPDATE REPORTING - NECESSARY TO SUBMIT CHANGES WITHOUT GETTING SPAMMY WITH CHANGE MESSAGES.
    -- In other words, on this callback, the change is submitted as a "LIVE" change, however it is not broadcast live lest a person get a TON of spam on login sync.
    -- This will be used as tag to silence message spam for sync updates, unlike Live updates where player is given option to enable notification.
    "GRM_JDSYNCUP",
    "GRM_PDSYNCUP"

};

-- Chat/print properties.
local chat = DEFAULT_CHAT_FRAME;


-- Method:          GRMsync.ResetDefaultValuesOnSyncReEnable()
-- What it Does:    Sets values to default, as if just logging back in.
-- Purpose:         For sync to properly work, default startup values need to be set.
GRMsync.ResetDefaultValuesOnSyncReEnable = function()
    GRMsyncGlobals.DatabaseLoaded = false;
    GRMsyncGlobals.RulesSet = false;
    GRMsyncGlobals.IsLeaderRequested = false;
    GRMsyncGlobals.LeadershipEstablished = false;
    GRMsyncGlobals.IsElectedLeader = false;
    GRMsyncGlobals.DesignatedLeader = "";
    GRMsyncGlobals.ElectTimeOnlineTable = nil;
    GRMsyncGlobals.ElectTimeOnlineTable = {};
end

-- Resetting after broadcasting the changes.
GRMsync.ResetReportTables = function()
    GRMsyncGlobals.JDChanges = {};
    GRMsyncGlobals.PDChanges = {};
    GRMsyncGlobals.AltAddChanges = {};
    GRMsyncGlobals.AltRemoveChanges = {};
    GRMsyncGlobals.AltMainChanges = {};
    GRMsyncGlobals.BanChanges = {};
end



--------------------------
----- FUNCTIONS ----------
--------------------------

-- Method:          GRMsync.WaitTilDatabaseLoads()
-- What it Does:    Sets the player's guild ranking by index of rank
-- Purpose:         This is important for addon talk to not get info from ranks too low.
GRMsync.WaitTilDatabaseLoads = function()
    if IsInGuild() and ( GR_AddonGlobals.saveGID == 0 or GR_AddonGlobals.FID == 0 or GR_AddonGlobals.setPID == 0 ) then
        C_Timer.After ( 5 , GRMsync.WaitTilDatabaseLoads );
        return
    else
        GRMsyncGlobals.DatabaseLoaded = true;
    end
    GRMsync.BuildSyncNetwork();
end

-- method:          GRMsync.SlimDate ( string )
-- What it Does:    Returns the string with the hour/min taken off the end.
-- Purpose:         For SYNCing, the only important piece of info on the timestamp is the date, and comparing it is the same. I don't want sync to trigger over and over
--                  Because the hour/min is off on the sync when that is unimportant info, at least in this context.
GRMsync.SlimDate  = function ( date )
    if date == "" then
        return date;
    else
        return string.sub ( date , 1 , string.find( date , " " , -8 ) -1 );
    end
end



-------------------------------
---- MESSAGE SENDING ----------
-------------------------------

-- Method:          GRMsync.SendMessage ( string , string , string , int )
-- What it Does:    Sends an invisible message to a channel that a player cannot see, but an addon can read.
-- Purpose:         Necessary function for cross-talk between players using addon.
GRMsync.SendMessage = function ( prefix , msg , type , typeID )
    SendAddonMessage ( prefix , msg , type , typeID );
end



--------------------------------
---- LIVE MESSAGE SCRIPTS ------
--------------------------------

-- Method:          GRMsync.CheckJoinDataChange ( string )
-- What it Does:    Parses the details of the message to be usable, and then uses that info to see if it is different than current info, and if it is, then enacts changes.
GRMsync.CheckJoinDateChange = function( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_JDSYNCUP" then
        isSyncUpdate = true;
    end

    local playerName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local joinDate = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local finalTStamp = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local finalEpochStamp = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    for r = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        if playerName == GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] then
            -- Let's see if there was a change
            if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][2] ~= finalTStamp then
                -- do a null check... will be same as button text
                if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20][ #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] ] ~= nil then
                    table.remove ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] );  -- Removing previous instance to replace
                    table.remove ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][21] );
                end
                table.insert( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] , finalTStamp );     -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][21] , finalEpochStamp ) ;   -- oldJoinDateMeta
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][2] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][3] = finalEpochStamp;
               
               -- For sync
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][35][1] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][35][2] = time();

                -- Update timestamp to officer note.
                if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                        if guildieName == name and oNote == "" then
                            GuildRosterSetOfficerNote ( h , joinDate );
                            break;
                        end
                    end
                end

                if MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == playerName then
                    GRM_noteFontString2:SetText ( joinDate );
                    GRM_PlayerOfficerNoteEditBox:SetText ( joinDate );
                end
                -- Gotta update the event tracker date too!
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][22][1][2] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][22][1][1] );

                -- Report the updates!
                if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] and not isSyncUpdate then
                    chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( playerName ) .. "'s Join Date." , 1.0 , 0.84 , 0 );
                end
                
                if MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == playerName then
                     GRM_JoinDateText:SetText ( string.sub ( joinDate , 9 ) );
                     if GRM_MemberDetailJoinDateButton:IsVisible() then
                        GRM_MemberDetailJoinDateButton:Hide();                
                    end
                    GRM_JoinDateText:Show();
                end
                
            end
            break;
        end
    end
end

-- Method           GRMsync.CheckPromotionDateChange ( string , string )
-- What it Does:    Checks if received info is different than current, then updates it
-- Purpose:         Data sharing between guildies carrying the addon
GRMsync.CheckPromotionDateChange = function ( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_PDSYNCUP" then
        isSyncUpdate = true;
    end

    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local promotionDate = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    for r = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] == name then
            
            GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][12] = string.sub ( promotionDate , 9 );
            GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][25]][2] = string.sub ( promotionDate , 9 );
            GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][13] = GRM.TimeStampToEpoch ( promotionDate );

            -- For SYNC
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][36][2] = time();
                
            -- Report the updates!
            if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] and not isSyncUpdate then
                chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( name ) .. "'s Promotion Date." , 1.0 , 0.84 , 0 );
            end

            -- If the player is on the same frames, update them too!
            if MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == name then
                if GRM_SetPromoDateButton:IsVisible() then
                    GRM_SetPromoDateButton:Hide();
                end

                if GR_AddonGlobals.rankIndex > GR_AddonGlobals.playerIndex then
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -80 ); -- slightly varied positioning due to drop down window or not.
                else
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -68 );
                end
                GRM_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
                GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][12] , 1 , 10) ) );
                GRM_MemberDetailRankDateTxt:Show();
            end
            break;
        end
    end
end

-- Method:          GRMsync.EventAddedToCalendarCheck ( string , string )
-- What it Does:    Checks to see if player has the event already in que. If it is, then remove it.
-- Purpose:         Cleanliness. If it is removed from one person's list, it is removed from all!
GRMsync.EventAddedToCalendarCheck = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local title = string.sub ( msg , string.find ( msg , "?" ) + 1 );


    if GRM.IsOnAnnouncementList ( name , title ) then
        -- Remove from the list
        GRM.RemoveFromCalendarQue ( name , title );

        -- Refresh the frame!
        GRM.RefreshAddEventFrame();
        chat:AddMessage ( "\"" .. title .. "\" event added to the calendar by " .. GRM.SlimName ( sender ) , 1.0 , 0.84 , 0 );  
    end
end

-------------------------------------------
-------- ALT UPDATE COMMS -----------------
-------------------------------------------


-- Method:          GRMsync.CheckAddAltChange ( string , string )
-- What it Does:    Adds the alt as well to your list, if it is not already added
-- Purpose:         Additional chcecks required to avoid message spamminess, but basically to sync alt lists on adding.
GRMsync.CheckAddAltChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local altName = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    if name ~= altName then         -- To avoid spam message to all players...
       
        -- Verify player is not already on someone else's list...
        local isFound = false;
        local isFound2 = false;
        for s = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][s][1] == altName then
                
                if #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][s][11] > 0 then
                    local listOfAlts = GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][s][11];
            
                    for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                        if listOfAlts[m][1] == name then                              -- Is that supposed to be "altName" ??
                            isFound = true;
                            break;
                        end
                    end
                else
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] == name then
                            local listOfAlts = GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][11];
                            if #listOfAlts > 0 then                                                                 -- There is more than 1 alt for new alt to be added to
                                for i = 1 , #listOfAlts do                                                          -- Cycle through previously known alt names to add new on each, one by one.
                                    for j = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do                             -- Need to now cycle through all toons in the guild to set the alt
                                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] then       -- name on current focus altList found in the metadata!
                                            -- Now, make sure it is not a repeat add!
                                            
                                            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                                                if listOfAlts[m][1] == altName then
                                                    isFound2 = true;
                                                    break;
                                                end
                                            end
                                            break;
                                        end
                                    end
                                    if isFound2 then
                                        break;
                                    end
                                end
                            end

                            break;
                        end
                    end
                end
                break;
            end
        end

        if not isFound and not isFound2 then
            GRM.AddAlt ( name , altName , GR_AddonGlobals.guildName );
        
            if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] then
                chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( name ) .. "'s list of Alts." , 1.0 , 0.84 , 0 );
            end
        end
    end
end


-- Method:          GRMsync.CheckRemoveAltChange ( string , string )
-- What it Does:    Syncs the removal of an alt between all ONLINE players
-- Purpose:         Sync data between online players.
GRMsync.CheckRemoveAltChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local altName = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local count = 0;
    local index = 0;

    -- Checking if alt is to be removed... establishing number of alts.
    for i = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][1] == name then
            count = #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][11];
            index = i;
            break;
        end
    end

    GRM.RemoveAlt ( name , altName , GR_AddonGlobals.guildName );
    
    if MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == altName then       -- If the alt being removed is being dumped from the list of alts, but the Sync person is on that frame...
        -- if main, we will hide this.
        GRM_MemberDetailMainText:Hide();

        -- Now, let's hide all the alts
        for i = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][1] == altName then
                GRM.PopulateAltFrames ( i );
                break;
            end
        end
    end

    -- if alts are ZERO, it implies the person is going 1 to zero and this player was not sync'd with them in count. If
    -- alts are less, then you are ensuring that one was actually removed.
    if count == 0 or count > #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][index][11] then
        if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] then
            chat:AddMessage ( GRM.SlimName ( sender ) .. " removed " .. GRM.SlimName ( altName ) .. " from " .. name .. "'s list of Alts." , 1.0 , 0.84 , 0 );
        end
    end
end


-- Method:          GRMsybc.CheckAltMainChange ( string , string )
-- What it Does:    Syncs Main selection control between players
-- Purpose:         Sync data between players LIVE
GRMsync.CheckAltMainChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local mainName = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    GRM.SetMain ( name , mainName , GR_AddonGlobals.guildName );

    -- Need to ensure "main" tag populates correctly.
    if MemberDetailMetaData:IsVisible() then
        if not GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == mainName then
            GRM_MemberDetailMainText:Show();
        elseif GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) ~= mainName then
            GRM_MemberDetailMainText:Hide();
        end
    end

    if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] then
        chat:AddMessage ( GRM.SlimName ( sender ) .. " set " .. GRM.SlimName ( mainName ) .. " to be 'Main'" , 1.0 , 0.84 , 0 );
    end
end


-- Method:          GRMsync.CheckAltMainToAltChange ( string , string )
-- What it Does:    If a player is demoted from main to alt, it syncs that change with everyone
-- Purpose:         Sync data between players LIVE
GRMsync.CheckAltMainToAltChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local mainName = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    GRM.DemoteFromMain ( name , mainName );

    if MemberDetailMetaData:IsVisible() then
        if GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == mainName then
            GRM_MemberDetailMainText:Hide();
        end
    end
    if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] then
        chat:AddMessage ( GRM.SlimName ( sender ) .. " has changed " .. GRM.SlimName ( mainName ) .. " to be listed as an 'alt'" , 1.0 , 0.84 , 0 );
    end
end


-- Method:          GRMsync.CheckBanListChange ( string , string )
-- What it Does:    If a player is banned, then it broadcasts the bane to the rest of the players, so they can update their info.
-- Purpose:         It is far more useful if more than one person maintains a BAN list...
GRMsync.CheckBanListChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local banAlts = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local reason = string.sub ( msg , string.find ( msg , "?" ) + 1 );


    -- First things first, let's find player!
    for j = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] == name then
            -- The initial ban of the player.
            GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][17] = true;
            GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][18] = reason;

            -- Next thing is IF alts are to be banned, this will ban them all as well!
            if banAlts == "true" then
                local listOfAlts = GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][11];
                if #listOfAlts > 0 then
                    for s = 1 , #listOfAlts do
                        for r = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
                            if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] == listOfAlts[s][1] and GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] ~= GR_AddonGlobals.addonPlayerName then

                                -- Banning the alts one by one in the for loop
                                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][17] = true;
                                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][18] = reason;

                                break;
                            end
                        end
                    end
                end
            end
            break;
        end
    end

    if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] then
        if banAlts == "true" then
            chat:AddMessage ( GRM.SlimName ( sender ) .. " has BANNED " .. GRM.SlimName ( name ) .. " and all linked alts from the guild!!!" , 1.0 , 0 , 0 );
            if reason == "" then
                reason = "< None Stated > ";
            end
            chat:AddMessage ( "Reason Banned: " .. reason , 1.0 , 1.0 , 1.0 );
        else
            chat:AddMessage ( GRM.SlimName ( sender ) .. " has BANNED " .. GRM.SlimName ( name ) .. " from the guild!!!" , 1.0 , 0 , 0 );
            if reason == "" then
                reason = "< None Stated > ";
            end
            chat:AddMessage ( "Reason Banned: " .. reason , 1.0 , 1.0 , 1.0 );
        end
    end
end


--------------------------------
---- Default Mesage Functions --
--------------------------------

-- Method:          GRMsync.RegisterPrefix( string )
-- What it Does:    To do an addon info send over a channel, the prefix first needs to be registered.
-- Purpose:         For player to player addon talk.
GRMsync.RegisterPrefix = function ( prefix )

    -- Prefix can't be more than 16 characters
    if #prefix > 16 then
        error ( "GRM Error: Unable to register prefix > 16 characters, whilst " .. prefix .. " is " .. #prefix .. "!" );
    end
    RegisterAddonMessagePrefix ( prefix );
end

-- Method:          GRMsync.RegisterPrefixes()
-- What it Does:    Registers the tages for all of the messages, so the addon recognizes and knows to pick them up
-- Purpose:         Prefixes need to be registered to the server to be usable for addon to addon talk.
GRMsync.RegisterPrefixes = function( listOfPrefixes )
    for i = 1 , #listOfPrefixes do 
        GRMsync.RegisterPrefix ( listOfPrefixes[i] );
    end
end

-- Method:          GRMsync.IsPrefixVerified ( string )
-- What it Does:    Returns true if received prefix is listed in this addon's
-- Purpose:         Control the spam in case of other prefixes received from other addons in guild channel.
GRMsync.IsPrefixVerified = function( prefix )
    local result = false;
    for i = 1 , #GRMsyncGlobals.listOfPrefixes do
        if GRMsyncGlobals.listOfPrefixes[i] == prefix then
            result = true;
            break;
        end
    end
    return result;
end



-------------------------------
-------------------------------
------ SYNC ALGORITHM ---------
-------------------------------
------ RETROACTIVE SYNC -------
-------------------------------
-------------------------------




-------------------------------
------- NON LEADER FORWARD ----
-------------------------------

GRMsync.SendJDPackets = function()
    print( "GRM: Syncing Guild Roster Data..." );
    -- Initiate Data sending
    GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.

    -- Send all values ( May need to be throttled for massive guilds? Not sure yet! );
    for i = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        GRMsync.SendMessage ( "GRM_JDSYNC" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][1] .. "?" .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][35][2] .. "?" .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][35][1] , GRMsyncGlobals.channelName )               --  "Name" .. "?" .. TimestampOfChange .. "?" .. JoinDate
    end
    
    -- Close the Data stream
    GRMsync.SendMessage ( "GRM_STOP" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. "JD" , GRMsyncGlobals.channelName );
end


GRMsync.SendPDPackets = function()
    -- Initiate Data sending

    GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.

    -- Send all values ( May need to be throttled for massive guilds? Not sure yet! );
    for i = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        GRMsync.SendMessage ( "GRM_PDSYNC" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][1] .. "?" .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][36][2] .. "?" .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][i][36][1] , GRMsyncGlobals.channelName )               --  "Name" .. "?" .. TimestampOfChange .. "?" .. PromoDate
    end
    
    -- Close the Data stream
    GRMsync.SendMessage ( "GRM_STOP" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. "PD" , GRMsyncGlobals.channelName );

end



-------------------------------
----- LEADER COLLECTION -------
----- AND ANALYSIS ------------
-------------------------------

-- Method:          GRMsync.SubmitFinalSyncData()
-- What it Does:    Sends out the mandatory updates to all online
-- Purpose:
GRMsync.SubmitFinalSyncData = function()

    -- Ok send of the Join Date updates!
    if #GRMsyncGlobals.JDChanges > 0 then
        print("Updating Join Dates!")
        for i = 1 , #GRMsyncGlobals.JDChanges do
            local joinDate = ( "Joined: " .. GRMsyncGlobals.JDChanges[i][3] );
            local finalTStamp = ( string.sub ( joinDate , 9 ) .. " 12:01am" );
            local finalEpochStamp = GRM.TimeStampToEpoch ( joinDate );
            -- Send a change to everyone!
            GRMsync.SendMessage ( "GRM_JDSYNCUP" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.JDChanges[i][1] .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp , GRMsyncGlobals.channelName );
            -- Do my own changes too!
            GRMsync.CheckJoinDateChange ( GRMsyncGlobals.JDChanges[i][1] .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp , "" , "GRM_JDSYNCUP" );
        end
    end

    -- Promo date sync!
    if #GRMsyncGlobals.PDChanges > 0 then
        print("Updating Promotion Dates!");
        for i = 1 , #GRMsyncGlobals.PDChanges do
            local promotionDate = ( "Joined: " .. GRMsyncGlobals.PDChanges[i][3] );
            GRMsync.SendMessage ( "GRM_PDSYNCUP" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.PDChanges[i][1] .. "?" .. promotionDate , "GUILD");
            -- Need to change my own data too!
            GRMsync.CheckPromotionDateChange ( GRMsyncGlobals.PDChanges[i][1] .. "?" .. promotionDate , "" , "GRM_PDSYNCUP" );

        end
    end




    -- Ok all done! Reset the tables!
    GRMsync.ResetReportTables();

    -- Do a quick check if anyone else added themselves to the que in the last millisecond, and if so, REPEAT!
    -- Setup repeat here.
end

GRMsync.CollectData = function ( msg , prefix )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local timeStampOfChange = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );


    -- Record Join Data to compare against!
    if prefix == "GRM_JDSYNC" then

        local joinDate = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        table.insert ( GRMsyncGlobals.JDReceivedTemp , { name , timeStampOfChange , GRMsync.SlimDate ( joinDate ) } );
    
    elseif prefix == "GRM_PDSYNC" then
        local promoDate = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        table.insert ( GRMsyncGlobals.PDReceivedTemp , { name , timeStampOfChange , promoDate } );





    end
end


-- Method:          GRMsync.CheckChanges ( string , string )
-- What it Does:    Checks to see if the received data and the leader's data is different and then adds the most recent changes to update que
-- Purpose:         Retroactive Sync Procedure fully defined here in this method. MUCH WORK!
GRMsync.CheckChanges = function ( msg )
    
    -----------------------------
    -- For Join Date checking!
    -----------------------------
    if msg == "JD" then
        if #GRMsyncGlobals.JDReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then
            print ("Join Date Data capture success!");

            local currentTime = time();
            for i = 1 , #GRMsyncGlobals.JDReceivedTemp do
                for j = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.JDReceivedTemp[i][1] then
                        -- Ok player identified, now let's compare data.
                        local parsedDate = GRMsync.SlimDate ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][35][1] );
                        if parsedDate ~= GRMsyncGlobals.JDReceivedTemp[i][3] then
                            -- Player dates don't match! Let's compare timestamps to see how made the most recent change, then sync data to that!
                            
                            local addReceived = false;      -- AM I going to add received data, or my own. One or the other needs to be added for sync
                            if ( currentTime - GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][35][2] ) > ( currentTime - GRMsyncGlobals.JDReceivedTemp[i][2] ) then
                                print("Adding received data, not my own");
                                -- Received Data happened more recently! Need to update change!
                                addReceived = true;         -- In other words, don't add my own data, add the received data.
                            end

                            -- Setting the change data properly.
                            local changeData;
                            -- Adding Received from other player
                            if addReceived then
                                changeData = GRMsyncGlobals.JDReceivedTemp[i];
                            
                            -- Adding my own data, as it is more current
                            else
                                changeData = { GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][35][2] , parsedDate };
                            end

                            -- Need to check if change has not already been added, or if another player added info that is more recent! (Might need review for increased performance)
                            local needToAdd = true;
                            for r = 1 , #GRMsyncGlobals.JDChanges do
                                if changeData[1] == GRMsyncGlobals.JDChanges[r][1] then
                                    -- If dates are the same, no need to change em!
                                    if changeData[2] == GRMsyncGlobals.JDChanges[r][2] then
                                        needToAdd = false;
                                    elseif ( currentTime - changeData[3] ) > ( currentTime - GRMsyncGlobals.JDChanges[3] ) then         -- Change was already found from another player's sync!
                                        print( "Change detected from leader's data, but that change was already found by another player that was more recent!" );
                                        needToAdd = false;
                                    end

                                    -- If needToAdd is still true, then we need to remove the old index.
                                    if needToAdd then
                                        table.remove ( GRMsyncGlobals.JDChanges , r );
                                    end
                                end
                            end

                            -- Now let's add it!
                            if needToAdd then
                                print ( "Change Added: " .. changeData[1] .. " - " .. changeData[3] .. " - " .. changeData[2] );
                                print ( "My Data: " .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] .. " - " .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][35][2] .. " - " .. parsedDate );
                                table.insert ( GRMsyncGlobals.JDChanges , changeData );
                            end
                        end
                        break;
                    end
                end
            end

            -- Wiping the temp file!
            -- From here, request should be sent out for PDSYNC!
            GRMsyncGlobals.JDReceivedTemp = {};
            GRMsync.SendMessage ( "GRM_REQPDDATA" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.CurrentSyncPlayer , GRMsyncGlobals.channelName );
        else
            error("GRMsync.CheckChanges() - Sync failed with designated SYNC Leader: " .. GRMsyncGlobals.DesignatedLeader );
        end

    -----------------------------
    -- For Promo Date checking!
    -----------------------------
    elseif msg == "PD" then
        if #GRMsyncGlobals.PDReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then
            print ("Promo Date Data Capture success!" );
            local currentTime = time();
            for i = 1 , #GRMsyncGlobals.PDReceivedTemp do
                for j = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.PDReceivedTemp[i][1] then
                        if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][36][1] ~= GRMsyncGlobals.PDReceivedTemp[i][3] then

                  
                            local addReceived = false;      -- AM I going to add received data, or my own. One or the other needs to be added for sync
                            if ( currentTime - GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][36][2] ) > ( currentTime - GRMsyncGlobals.PDReceivedTemp[i][2] ) then
                                print("Adding Promotion received data, not my own");
                                -- Received Data happened more recently! Need to update change!
                                addReceived = true;         -- In other words, don't add my own data, add the received data.
                            end

                            -- Setting the change data properly.
                            local changeData;
                            -- Adding Received from other player
                            if addReceived then
                                changeData = GRMsyncGlobals.PDReceivedTemp[i];
                            
                            -- Adding my own data, as it is more current
                            else
                                changeData = { GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][36][2] , GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][36][1] };
                            end

                            -- Need to check if change has not already been added, or if another player added info that is more recent! (Might need review for increased performance)
                            local needToAdd = true;
                            for r = 1 , #GRMsyncGlobals.PDChanges do
                                if changeData[1] == GRMsyncGlobals.PDChanges[r][1] then
                                    -- If dates are the same, no need to change em!
                                    if changeData[2] == GRMsyncGlobals.PDChanges[r][2] then
                                        needToAdd = false;
                                    elseif ( currentTime - changeData[3] ) > ( currentTime - GRMsyncGlobals.PDChanges[3] ) then         -- Change was already found from another player's sync!
                                        print( "Change detected from leader's data, but that change was already found by another player that was more recent!" );
                                        needToAdd = false;
                                    end

                                    -- If needToAdd is still true, then we need to remove the old index.
                                    if needToAdd then
                                        table.remove ( GRMsyncGlobals.PDChanges , r );
                                    end
                                end
                            end

                            -- If needToAdd is still true, then we need to remove the old index.
                            if needToAdd then
                                print ( "Change Added: " .. changeData[1] .. " - " .. changeData[3] .. " - " .. changeData[2] );
                                print ( "My Data: " .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][1] .. " - " .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][36][2] .. " - " .. GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][j][36][1] );
                                table.insert ( GRMsyncGlobals.PDChanges , changeData );
                            end
                        end
                        break;
                    end
                end
            end
        
            -- Wipe the data!
            GRMsyncGlobals.PDReceivedTemp = {};
            -- GRMsync.SendMessage ( "GRM_REQPDDATA" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.CurrentSyncPlayer , GRMsyncGlobals.channelName );
        else
            error("GRMsync.CheckChanges() - Sync failed with designated SYNC Leader: " .. GRMsyncGlobals.DesignatedLeader );
        end

        GRMsync.SubmitFinalSyncData();

    -----------------------------
    -- For Main Change checking!
    -----------------------------
    elseif msg == "Main" then



    --- Now that all changes have been checked and added to the temp tables... Let's process them!

        
    end


end



-- Method:          GRMsync.InitiateDataSync()
-- What it Does:    Begins the sync process going throug hthe sync que
-- Purpose:         To Sync data!
GRMsync.InitiateDataSync = function ()
    GRMsyncGlobals.LeadSyncProcessing = false;
    print("Initializing data sync")
    -- First step, let's check Join Date Changes! Kickstart the fun!   
    if #GRMsyncGlobals.SyncQue > 0 then
        print ( "Syncing data with: " .. GRMsyncGlobals.SyncQue[1] );
        GRMsyncGlobals.CurrentSyncPlayer = GRMsyncGlobals.SyncQue[1];
        GRMsync.SendMessage ( "GRM_REQJDDATA" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.SyncQue[1] , GRMsyncGlobals.channelName );
        table.remove ( GRMsyncGlobals.SyncQue , 1 );
    end
end

-- Method:          GRMsync.InquireLeader()
-- What it Does:    On logon, or activation of sync alg, it requests in the guild channel if a leader is online.
-- Purpose:         Step 1 of sync algorithm in determining leader.
GRMsync.InquireLeader = function()
    GRMsyncGlobals.IsLeaderRequested = true;
    GRMsync.SendMessage ( "GRM_WHOISLEADER" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );

end

-- Method:          GRMsync.SetLeader ( string )
-- What it Does:    If message received, designates the sender as the leader
-- Purpose:         Need to designate a leader!
GRMsync.SetLeader = function ( leader )
    if leader ~= GR_AddonGlobals.addonPlayerName and leader ~= GRMsyncGlobals.DesignatedLeader then
        GRMsyncGlobals.DesignatedLeader = leader;
        GRMsyncGlobals.LeadershipEstablished = true;

        -- Non leader sends request to sync
        GRMsync.SendMessage ( "GRM_REQUESTSYNC" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );

    elseif leader == GR_AddonGlobals.addonPlayerName then
        GRMsyncGlobals.DesignatedLeader = leader;
        GRMsyncGlobals.LeadershipEstablished = true;
        GRMsyncGlobals.IsElectedLeader = true;

        -- Initiate data sync
        -- After time delay to receive responses, intiate sync after vote... 3 sec. delay. Everyone else request to sync.
        C_Timer.After ( 3 , GRMsync.InitiateDataSync );
    end    
end

-- Method:          GRMsync.InquireLeaderRespond ( string )
-- What it Does:    The new leader will respond out "I AM LEADER" and everyone set him as leader. No need to set as leader as it would have already been done at this point.
-- Purpose:         Sync leadership controls.
GRMsync.InquireLeaderRespond = function ( sender )
    GRMsync.SendMessage ( "GRM_IAMLEADER" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );
    C_Timer.After ( 3 , GRMsync.InitiateDataSync );
end

-- Method:          GRMsync.ReviewElectResponses ()
-- What it Does:    Reviews timestamps of all online people with addon, and if there is no leader, it elects a new leader.
-- Purpose:         Leadership needs to be established to ensure clean syncing.
GRMsync.ReviewElectResponses = function()

    if #GRMsyncGlobals.ElectTimeOnlineTable > 1 then
        print("running vote");
        local highestName = GR_AddonGlobals.addonPlayerName;
        local highestTime = GRMsyncGlobals.timeAtLogin;
        local time = time();

        -- Let's determine who has been online the longest.
        for i = 1 , #GRMsyncGlobals.ElectTimeOnlineTable do
            if ( time - GRMsyncGlobals.ElectTimeOnlineTable[i][1] ) > ( time - highestTime ) then
                highestTime = GRMsyncGlobals.ElectTimeOnlineTable[i][1];
                highestName = GRMsyncGlobals.ElectTimeOnlineTable[i][2];
            end
        end

        -- Send Message out
        GRMsync.SendMessage ( "GRM_NEWLEADER" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. highestName , GRMsyncGlobals.channelName );

        -- Establishing leader.
        GRMsync.SetLeader ( highestName );
        

    elseif #GRMsyncGlobals.ElectTimeOnlineTable == 1 then
        print("Only 1 person on to vote against!");
        -- One result will be established as leader. No need to compare.
        -- Identifying new leader!
        GRMsync.SendMessage ( "GRM_NEWLEADER" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.ElectTimeOnlineTable[1][2] , GRMsyncGlobals.channelName );
        -- Sending message out.
        GRMsync.SetLeader ( GRMsyncGlobals.ElectTimeOnlineTable[1][2] );
        

    else
        -- ZERO RESPONSES! No one else online! -- No need to data sync and go further!
        print("I am the leader, no others were online!")
        GRMsync.SetLeader ( GR_AddonGlobals.addonPlayerName );

    end

    -- RESET TABLE!
    GRMsyncGlobals.ElectTimeOnlineTable = nil;
    GRMsyncGlobals.ElectTimeOnlineTable = {};

end


-- Method:          GRMsync.RequestElection()
-- What it Does:    To person who just logged in or reactivated syncing, it sends out a request to elect a leader if no leader identified.
-- Purpose:         Need to get time responses from all players to determine who has been online the longest, which will likely have the best data.
GRMsync.RequestElection = function()
    GRMsync.SendMessage ( "GRM_ELECT" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );

    -- Let's give it a time delay to receive responses. 3 seconds.
    C_Timer.After ( 3 , GRMsync.ReviewElectResponses );
end


-- Method:          GRMsync.SendTimeForElection()
-- What it Does:    Sends the time logged in or addon sync was enabled
-- Purpose:         For voting, to determine who was online the longest.
GRMsync.SendTimeForElection = function()
    GRMsync.SendMessage ( "GRM_TIMEONLINE" , GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] .. "?" .. GR_AddonGlobals.addonPlayerName .. "?" .. tostring ( GRMsyncGlobals.timeAtLogin ) , GRMsyncGlobals.channelName );
end

-- Method:          GRMsync.ResgisterTimeStamps( string )
-- What it Does:    Adds the player's name and timestamp for election
-- Purpose:         Need to aggregate all the player data for voting!
GRMsync.ResgisterTimeStamps = function ( msg )
    -- Adding { timestamp , name } to the list of people giving their time... 3 second response time valid only.
    table.insert ( GRMsyncGlobals.ElectTimeOnlineTable , { tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) ) , string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) } );
end

-- Method:          GRMsync.ElectedLeader ( string )
-- What it Does:    Established the elected leader based on message received.
-- Purpose:         Final step in designating a leader!
GRMsync.ElectedLeader = function ( msg )
    -- Message should just be the name, so no need to parse.
    GRMsync.SetLeader ( msg );
end



-- Method:          GRMsync.EstablishLeader()
-- What it Does:    Controls the algorithm flow for syncing data between players by establishing leader.
-- Purpose:         To have a healthy, lightweight, efficient syncing addon.
GRMsync.EstablishLeader = function()

    -- "Who is the leader?"
    if not GRMsyncGlobals.IsLeaderRequested then
        GRMsync.InquireLeader();
    end

    C_Timer.After ( 5 , function ()
        -- No responses, no leader! Setup an election for the leader!
        if not GRMsyncGlobals.LeadershipEstablished then
            print("No Leader responded! Starting election of leader!");
            GRMsync.RequestElection()
            
        end    
    end);

end



-------------------------------
------ INITIALIZING -----------
-------------------------------

-- Method:          GRMsync.RegisterCommunicationProtocols()
-- What it Does:    Establishes the channel communication rules for sending and receiving
-- Purpose:         Need to make rules to get this to behave properly!
GRMsync.RegisterCommunicationProtocols = function()
    GRMsync.MessageTracking:RegisterEvent ( "CHAT_MSG_ADDON" );
    -- Register used prefixes!
    GRMsync.RegisterPrefixes ( GRMsyncGlobals.listOfPrefixes );

    -- Setup tracking...
    GRMsync.MessageTracking:SetScript ( "OnEvent" , function( self , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and channel == GRMsyncGlobals.channelName and sender ~= GR_AddonGlobals.addonPlayerName then     -- Don't need to register my own sends.

            if GRMsync.IsPrefixVerified ( prefix ) then
                
                -- Let's strip out the rank requirement of the sender, so it avoids syncing with people not of required rank.
                local senderRankRequirement = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
               

                -- Need to do a rank check here to accept the send or not. -- VERIFY PREFIX BEFORE CHECKING!
                if sender ~= GRMsync.DesignatedLeader and ( GRM.GetGuildMemberRankID ( sender ) >= GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][15] or senderRankRequirement <= GRM.GetGuildMemberRankID ( GR_AddonGlobals.addonPlayerName ) ) then        -- If player's rank is below settings threshold, ignore message.
                    return
                end
                
                -- parsing out the rankRequirementOfSender
                msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );

                ------------------------------------------
                ----------- LIVE UPDATE TRACKING ---------
                ------------------------------------------

                -- Varuious Prefix Logic handling now...
                if prefix == "GRM_JD" then
                    GRMsync.CheckJoinDateChange ( msg , sender , prefix );
                
                -- On a Promotion Date Edit
                elseif prefix == "GRM_PD" then
                    GRMsync.CheckPromotionDateChange ( msg , sender , prefix );

                -- If person added to Calendar... this event occurs.
                elseif prefix == "GRM_AC" then
                    GRMsync.EventAddedToCalendarCheck ( msg , sender );
                
                -- For adding an alt!
                elseif prefix == "GRM_ADDALT" then
                    GRMsync.CheckAddAltChange ( msg , sender );
            
                -- For Removing an alt!
                elseif prefix == "GRM_RMVALT" then
                    GRMsync.CheckRemoveAltChange ( msg , sender );
            
                -- For declaring who is to be "main"
                elseif prefix == "GRM_MAIN" then
                    GRMsync.CheckAltMainChange ( msg , sender );
            
                -- For demoting from main -- basically to set as no mains.
                elseif prefix == "GRM_RMVMAIN" then
                    GRMsync.CheckAltMainToAltChange ( msg , sender );
            
                -- For ensuring bans are shared!
                elseif prefix == "GRM_BAN" then
                    GRMsync.CheckBanListChange ( msg , sender );

               
            
                
                --------------------------------------------
                -------- RETROACTIVE SYNC TRACKING ---------
                --------------------------------------------

                -- In response to asking "Who is the leader" then ONLY THE LEADER will respond.
                elseif prefix == "GRM_WHOISLEADER" and GRMsyncGlobals.IsElectedLeader then
                        GRMsync.InquireLeaderRespond( sender );

                -- Updates who is the LEADER to sync with!
                elseif prefix == "GRM_IAMLEADER" then
                    GRMsync.SetLeader ( sender );

                 -- For an election...
                elseif prefix == "GRM_ELECT" then
                    GRMsync.SendTimeForElection ();

                -- For sending timestamps out!
                elseif prefix == "GRM_TIMEONLINE" and not GRMsyncGlobals.LeadershipEstablished then -- Only the person who sent the inquiry will bother reading these... flow control...
                    GRMsync.ResgisterTimeStamps ( msg );
                    
                -- For establishing the new leader after an election
                elseif prefix == "GRM_NEWLEADER" then
                    GRMsync.ElectedLeader ( msg )
                

                -- LEADERSHIP ESTABLISHED, NOW LET'S SYNC COMMS!

                -- Only the leader will hear this message!
                elseif prefix == "GRM_REQUESTSYNC" and GRMsyncGlobals.IsElectedLeader then
                        table.insert ( GRMsyncGlobals.SyncQue , sender );
                
                -- Leader has requesated your Join Date Data!
                elseif prefix == "GRM_REQJDDATA" and msg == GR_AddonGlobals.addonPlayerName then
                    -- Start forwarding Join Date data...
                    GRMsync.SendJDPackets();

                elseif prefix == "GRM_REQPDDATA" and msg == GR_AddonGlobals.addonPlayerName then
                    -- Start forwarding Promo Date data
                    GRMsync.SendPDPackets();
                
                -- Initializes the starting value
                elseif prefix == "GRM_START" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                    GRMsyncGlobals.NumPlayerDataExpected = tonumber ( msg );

                -- Stop collecting, start processing!
                elseif prefix == "GRM_STOP" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                    GRMsync.CheckChanges ( msg );

                -- For Syncing Tags joinDate!
                elseif ( prefix == "GRM_JDSYNC" or prefix == "GRM_PDSYNC" ) and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                    GRMsync.CollectData ( msg , prefix );            


                -- DATA ANALYZED, NOW LET'S SEND THE UPDATES!!!

                -- Sync the Join Dates!
                elseif prefix == "GRM_JDSYNCUP" then 
                    GRMsync.CheckJoinDateChange ( msg , sender , prefix );

                -- Sync the Promo Dates!
                elseif prefix == "GRM_PDSYNCUP" then
                    GRMsync.CheckPromotionDateChange ( msg , sender , prefix );


                end
            end
        end
    end);

    GRMsyncGlobals.RulesSet = true;
end


-- Method:          GRMsync.BuildSyncNetwork()
-- What it Does:    Step by step of my in-house sync algorithm custom built for this addon. Step by step it goes!
-- Purpose:         Control the work-flow of establishing the sync infrastructure. This will not maintain it, just builds the initial rules
--                  and the server-side channel of communication between players using the addon. Furthermore, by compartmentalizing it, it controls the flow of actions
--                  allowing a recursive check over the algorithm for flawless timing, and not moving ahead until the proper parameters are first met.
GRMsync.BuildSyncNetwork = function()  
    -- Rank necessary to be established to keep'
    if IsInGuild() then
        if not GRMsyncGlobals.DatabaseLoaded then
            GRMsync.WaitTilDatabaseLoads();
        end

        -- Let's get the party started! Establishing rules then communication should be good to go!
        if GRMsyncGlobals.DatabaseLoaded and not GRMsyncGlobals.RulesSet then
            GRMsyncGlobals.timeAtLogin = time();                                   -- Timestamp needs to be reset everytime tracking starts. Don't want to
            GRMsync.RegisterCommunicationProtocols();
            chat:AddMessage ( "Sync Fully Registered and Working!" , 1.0 , 0.84 , 0 );
        end

        -- Redundancy in case it fails to load.
        if GRMsyncGlobals.DatabaseLoaded and not GRMsyncGlobals.RulesSet then
            C_Timer.After ( 2 , GRMsync.BuildSyncNetwork );
        end
        
        -- We need to set leadership at this point.
        if GRMsyncGlobals.DatabaseLoaded and GRMsyncGlobals.RulesSet and not GRMsyncGlobals.LeadershipEstablished and not GRMsyncGlobals.LeadSyncProcessing then
            GRMsyncGlobals.LeadSyncProcessing = true;
            GRMsync.EstablishLeader();
        end




    end
end



-- ON LOADING!!!!!!!
-- Event Tracking
GRMsync.Initialize = function()
    if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][14] then
        GRMsync.MessageTracking = GRMsync.MessageTracking or CreateFrame ( "Frame" , "GRMsyncMessageTracking" );
        GRMsync.BuildSyncNetwork();
    end
end




-- Do a receursive check every once in a while on if the DesignatedLeader is still online. If not, retrigger new leader.
-- On leadership changing hands, people will want to re-sync with new leader.
-- If someone logs on and they sync with leader, if the leader must change any of his own data, that change is broadcast FOR ALL (with original sender's name included so sender can avoid spam doublecheck.)

-- ExtraActionButton1

-- SetFocus
-- /run local x=GetHomePartyInfo();for i=1,#x do if UnitIsFriend("player",x[1]) and UnitHealth(x[1])/UnitHealthMax(x[1]) > .5 then ExtraActionButton1:Click();end;end

-- If Mature language filter is on
-- 4 letter word == !@#$  or ^&*!