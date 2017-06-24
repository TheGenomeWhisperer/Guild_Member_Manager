-- For Sync controls!


-- To hold all Sync Methods/Functions
GRMsync = {};


-- Sync Globals
local GRMsyncGlobals = {};

GRMsyncGlobals.channelName = "GUILD";
GRMsync.DatabaseLoaded = false;
GRMsync.RulesSet = false;

-- Prefixes for tagging info as it is sent and picked up across server channel to other players in guild.
GRMsync.listOfPrefixes = { 

    "GRM_JD",               -- Join Date
    "GRM_PD",               -- Recent Promo Date
    "GRM_AC"                -- Added to Calendar (triggers other players to remove from their que);

};

-- Chat/print properties.
local chat = DEFAULT_CHAT_FRAME;





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
        GRMsync.DatabaseLoaded = true;
    end
    GRMsync.BuildSyncNetwork();
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
---- MESSAGE ACTION ------------
--------------------------------

-- Method:          GRMsync.CheckJoinDataChange ( string )
-- What it Does:    Parses the details of the message to be usable, and then uses that info to see if it is different than current info, and if it is, then enacts changes.
GRMsync.CheckJoinDateChange = function( msg , sender )
    local playerName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local joinDate = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local finalTimeStamp = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local finalEpochStamp = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );


    for r = 2 , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ] do
        if playerName == GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] then
            -- Let's see if there was a change
            if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][2] ~= finalTimeStamp then
                -- do a null check... will be same as button text
                if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] ~= nil then
                    table.remove ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] );  -- Removing previous instance to replace
                    table.remove ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][21] );
                end
                table.insert( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][20] , finalTimeStamp );     -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][21] , finalEpochStamp ) ;   -- oldJoinDateMeta
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][2] = finalTimeStamp;
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][3] = finalEpochStamp;
                GR_JoinDateText:SetText ( strsub ( joinDate , 9 ) );
                
                -- Update timestamp to officer note.
                if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                        if guildieName == name and oNote == "" then
                            GuildRosterSetOfficerNote ( h , joinDate );
                            noteFontString2:SetText ( joinDate );
                            PlayerOfficerNoteEditBox:SetText ( joinDate );
                            break;
                        end
                    end
                end

                -- Gotta update the event tracker date too!
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][22][1][2] = strsub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][22][1][1] );
                if GRM_GuildMemberHistory_Save[ GR_AddonGlobals.FID ][ GR_AddonGlobals.saveGID ][r][12] == nil then
                    rankButton = true;
                end

                if GRM_AddonSettings_Save[GR_AddonGlobals.FID][GR_AddonGlobals.setPID][2][16] then
                    chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( playerName ) .. "'s Join Date." , 1.0 , 0.84 , 0 );
                end
                break;
            end
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

-------------------------------
------ INITIALIZING -----------
-------------------------------

-- Method:          GRMsync.RegisterCommunicationProtocols()
-- What it Does:    Establishes the channel communication rules for sending and receiving
-- Purpose:         Need to make rules to get this to behave properly!
GRMsync.RegisterCommunicationProtocols = function()
    GRMsync.MessageTracking:RegisterEvent ( "CHAT_MSG_ADDON" );
    -- Register used prefixes!
    GRMsync.RegisterPrefixes ( GRMsync.listOfPrefixes );

    -- Setup tracking...
    GRMsync.MessageTracking:SetScript ( "OnEvent" , function( self , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and channel == GRMsyncGlobals.channelName and sender ~= GR_AddonGlobals.addonPlayerName then     -- Don't need to register my own sends.

            -- Need to do a rank check here to accept the send or not.
            -- GRM.GetGuildMemberRankID ( sender )
            
            -- Varuious Prefix Logic handling now...
            if prefix == "GRM_JD" then
                GRMsync.CheckJoinDateChange ( msg , sender );
                
            elseif prefix == "GRM_PD" then

            -- If person added to Calendar... this event occurs.
            elseif prefix == "GRM_AC" then
                GRMsync.EventAddedToCalendarCheck ( msg , sender );
            end
        end
    end);

    GRMsync.RulesSet = true;
end


-- Method:          GRMsync.BuildSyncNetwork()
-- What it Does:    Step by step of my in-house sync algorithm custom built for this addon. Step by step it goes!
-- Purpose:         Control the work-flow of establishing the sync infrastructure. This will not maintain it, just builds the initial rules
--                  and the server-side channel of communication between players using the addon. Furthermore, by compartmentalizing it, it controls the flow of actions
--                  allowing a recursive check over the algorithm for flawless timing, and not moving ahead until the proper parameters are first met.
GRMsync.BuildSyncNetwork = function()  
    -- Rank necessary to be established to keep'
    if IsInGuild() then
        if not GRMsync.DatabaseLoaded then
            GRMsync.WaitTilDatabaseLoads();
        end

        -- Let's get the party started! Establishing rules then communication should be good to go!
        if GRMsync.DatabaseLoaded and not GRMsync.RulesSet then
            GRMsync.RegisterCommunicationProtocols();
            chat:AddMessage ( "Sync Fully Registered and Working!" , 1.0 , 0.84 , 0 );
        end
    end
end



-- ON LOADING!!!!!!!
-- Event Tracking
GRMsync.MessageTracking = GRMsync.MessageTracking or CreateFrame ( "Frame" , "GRMsyncMessageTracking" );
GRMsync.BuildSyncNetwork();
