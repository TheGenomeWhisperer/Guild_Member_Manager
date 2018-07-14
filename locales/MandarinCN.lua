
-- INSTRUCTIONS FOR LOCALIZATION

-- 1 ) Please avoid the "SYSTEM MESSAGES" as those are necessary for the addon code to properly identify and parse them. those are already complete.
-- 2 ) Any statement that "= true" needs to still be translated. Just remove the 'true' and replace it with the proper translation, in quotations 
--     Please include the {name} for where the player names should appear, as well as the few instances {num} needs to be included (referring to number)
-- 3 ) If appropriate, in the context of the sentence, please keep the spacing properly.
-- 4 ) Report any issues to Arkaan on CurseForge or Discord. -- You can also find me Battle.net @  DNADissector#1958   (US)
-- 5 ) THANK YOU SO MUCH FOR ADDING THIS TRANSLATION WORK!!! I will ensure you are mentioned in the release notes and at the top of this header for your contribution

-- Data insert points:
--  {name} and {name2}
--  {num}
--  {custom1} and {custom2}

    -- EXAMPLE NOTATION (English to Spanish)

    -- GRM_L["{name}'s Anniversary!"] = "Aniversario de {name}"

    ---------------------------------
    -- BEGIN TRANSLATION WORK HERE --
    ---------------------------------

GRML.MandarinCN = function()

    GRM_L["Guild"] = true

    -- PLAYER MAIN ROSTER DETAILS WINDOW
    GRM_L["Level: "] = "等级"
    GRM_L["Level"] = "等级"
    GRM_L["Note:"] = "备注："
    GRM_L["Note"] = "备注"
    GRM_L["Officer's Note:"] = "官员备注:"
    GRM_L["Officer's Note"] = "官员备注"
    GRM_L["Zone:"] = "地区："
    GRM_L["(main)"] = true
    GRM_L["( Main )"] = true                                -- Context: This one is used on player data window, the other is smaller used in the alts list...
    GRM_L["Set as Main"] = true
    GRM_L["Set as Alt"] = true
    GRM_L["Remove"] = true
    GRM_L["Please Type the Name of the alt"] = true
    GRM_L["Promoted:"] = true
    GRM_L["Unknown"] = true                                                                 -- Context: The date of their promotion is "Unknown"
    GRM_L["Click here to set a Public Note"] = true
    GRM_L["Unable to Edit Public Note at Rank"] = true
    GRM_L["Click here to set an Officer's Note"] = true
    GRM_L["Unable to Edit Officer Note at Rank"] = true
    GRM_L["Unable to View Officer Note at Rank"] = true
    GRM_L["Online"] = true
    GRM_L["( Active )"] = true                       -- I included the parentheses here as I am not sure if any languages abstain from them, or use other notation. Feel free to remove if necessary
    GRM_L["( AFK )"] = true
    GRM_L["( Busy )"] = true
    GRM_L["( Mobile )"] = true
    GRM_L["( Offline )"] = true
    GRM_L["Set Join Date"] = true
    GRM_L["Edit Promo Date"] = true
    GRM_L["Edit Join Date"] = true
    GRM_L["Set Promo Date"] = true
    GRM_L["In Group"] = true                            -- Context: "Player is already In Group with you"
    GRM_L["Group Invite"] = true
    GRM_L["No Invite"] = true
    GRM_L["Group Invite"] = true
    GRM_L["Date Promoted?"] = true
    GRM_L["Last Online"] = true
    GRM_L["Time In:"] = true                            -- Context: "Time In" the current zone...
    GRM_L["Date Joined"] = true
    GRM_L["Join Date?"] = true
    GRM_L["Player Was Previously Banned!"] = true
    GRM_L["Ignore Ban"] = true
    GRM_L["Player Alts"] = true
    GRM_L["Add Alt"] = true
    GRM_L["Choose Alt"] = true
    GRM_L["(Press Tab)"] = true
    GRM_L["Shift-Mouseover Name On Roster Also Works"] = true
    GRM_L["Guild Log"] = true

    -- TOOLTIPS
    GRM_L["Rank History"] = true 
    GRM_L["Time at Rank:"] = true
    GRM_L["Right-Click to Edit"] = true
    GRM_L["Left Guild"] = true
    GRM_L["Membership History"] = true
    GRM_L["Joined:"] = true                             -- as in "Joined" the guild
    GRM_L["Joined"] = true
    GRM_L["Left:"] = true                               -- as in, "Left" the guild
    GRM_L["Rejoined:"] = true                           -- as in, "Rejoined" the guild
    GRM_L["Reset Data!"] = true
    GRM_L["Notify When Player is Active"] = true
    GRM_L["Notify When Player Goes Offline"] = true
    GRM_L["Notify When Player Comes Online"] = true
    GRM_L["Edit Date"] = true
    GRM_L["Clear History"] = true
    GRM_L["Options"] = true
    GRM_L["Cancel"] = true
            
    -- LOG
    GRM_L["LOG"] = true                                                     -- Context - The guild Log shorthand for the tab
    GRM_L["Guild Roster Event Log"] = true
    GRM_L["Clear Log"] = true
    GRM_L["Really Clear the Guild Log?"] = true
    GRM_L["{name} DEMOTED {name2}"] = true
    GRM_L["{name} PROMOTED {name2}"] = true
    GRM_L["{name} KICKED {name2} from the Guild!"] = true
    GRM_L["kicked"] = true
    GRM_L["{name} has Left the guild"] = true
    GRM_L["{name} INVITED {name2} to the guild."] = true
    GRM_L["{name} has BANNED {name2} and all linked alts from the guild!"] = true
    GRM_L["{name} has BANNED {name2} from the guild!"] = true
    GRM_L["Reason Banned:"] = true
    GRM_L["has Left the guild"] = true                                      -- Context: PlayerName "has left the guild"
    GRM_L["ALTS IN GUILD:"] = true                                          -- Context: This appears If a person leaves the guild and there are still alts in the guild. It is like - "ALTS IN GUILD: Arkaan, Chris, Matt, and 4 others.""
    GRM_L["Player no longer on Server"] = true
    GRM_L["{name} PROMOTED {name2} from {custom1} to {custom2}"] = true
    GRM_L["{name} has been PROMOTED from {custom1} to {custom2}"] = true
    GRM_L["{name} DEMOTED {name2} from {custom1} to {custom2}"] = true
    GRM_L["{name} has been DEMOTED from {custom1} to {custom2}"] = true
    GRM_L["(+ {num} More)"] = true                                          -- Context: Referencing num of alts if player leaves guild, that are stil in it. Example "ALTS IN GUILD: Christ, Matt, Sarah (and 4 more)"
    GRM_L["{name} has Been in the Guild {num} Times Before"] = true
    GRM_L["{name} is Returning for the First Time."] = true
    GRM_L["None Given"] = true                                              -- Context: No reason given for player ban. This is displayed when a player was banned, but the addon users did not input a reason why.
    GRM_L["WARNING!"] = true                                                -- Context: WARNING - banned player rejoined the guild!
    GRM_L["{name} REJOINED the guild but was previously BANNED!"] = true
    GRM_L["(Invited by: {name})"] = true
    GRM_L["Invited By: {name}"] = true
    GRM_L["Date of Ban:"] = true
    GRM_L["Date Originally Joined:"] = true
    GRM_L["Old Guild Rank:"] = true
    GRM_L["Reason:"] = true
    GRM_L["Additional Notes:"] = true
    GRM_L["{name} has REINVITED {name2} to the guild"] = true
    GRM_L["(LVL: {num})"] = true                                            -- Context: LVL means Player Level - so Ex: (LVL: 110)
    GRM_L["{name} has REJOINED the guild"] = true
    GRM_L["{name} has JOINED the guild!"] = true
    GRM_L["Date Left:"] = true
    GRM_L["{name} has Leveled to {num}"] = true
    GRM_L["Leveled to"] = true                                             -- For parsing the message, please include the string found in previous "has leveled to" message
    GRM_L["(+{num} levels)"] = true                                         -- Context: Person gained more than one level, hence the plural
    GRM_L["(+{num} level)"] = true                                          -- Context: Person gains a level, just one level.
    GRM_L["{name}'s PUBLIC Note: \"{custom1}\" was Added"] = true           -- Of note, the \" in the text here will just appear as " in-game. The \" notation is telling the program not to end the string, but to include quotation
    GRM_L["{name}'s PUBLIC Note: \"{custom1}\" was Removed"] = true
    GRM_L["{name}'s PUBLIC Note: \"{custom1}\" to \"{custom2}\""] = true    -- Context: "Arkaan's PUBLIC Note: "ilvl 920" to "Beast Mode ilvl 960""  -- Changing of the note. custom1 = old note, custom2 = new note
    GRM_L["{name}'s OFFICER Note: \"{custom1}\" was Added"] = true
    GRM_L["{name}'s OFFICER Note: \"{custom1}\" was Removed"] = true
    GRM_L["{name}'s OFFICER Note: \"{custom1}\" to \"{custom2}\""] = true
    GRM_L["Guild Rank Renamed from {custom1} to {custom2}"] = true
    GRM_L["{name} has Name-Changed to {name2}"] = true
    GRM_L["{name} has Come ONLINE after being INACTIVE for {num}"] = true
    GRM_L["{name } Seems to Have Name-Changed, but their New Name was Hard to Determine"] = true
    GRM_L["It Could Be One of the Following:"] = true
    GRM_L["{name} has been OFFLINE for {num}. Kick Recommended!"] = true
    GRM_L["({num} ago)"] = true                                             -- Context: (5 minutes ago) or (5 months 24 days ago) -- the {num} will automatically include the time-passed date.
    GRM_L["{name}'s Guild has Name-Changed to \"{name2}\""] = true
    GRM_L["{name} will be celebrating {num} year in the Guild! ( {custom1} )"] = true            -- {custom1} will reference the DATE. Ex: "Arkaan will be celebrating 1 year in the Guild! ( 1 May )" - SINGULAR
    GRM_L["{name} will be celebrating {num} years in the Guild! ( {custom1} )"] = true           -- Same thing but PLURAL - "years" in stead of "year"
    GRM_L["Promotions"] = true
    GRM_L["Demotions"] = true

    -- EVENTS WINDOW
    GRM_L["EVENTS"] = true                                          -- Events tab
    GRM_L["{name}'s Anniversary!"] = true
    GRM_L["{name}'s Birthday!"] = true
    GRM_L["Please Select Event to Add to Calendar"] = true
    GRM_L["No Calendar Events to Add"] = true
    GRM_L["Event Calendar Manager"] = true
    GRM_L["Event:"] = true
    GRM_L["Description:"] = true
    GRM_L["Add to\nCalendar"] = true
    GRM_L["Ignore Event"] = true
    GRM_L["No Player Event Has Been Selected"] = true
    GRM_L["Event Added to Calendar: {custom1}"] = true              -- Custom1 = the title of the event, like "Arkaan's Anniversary"
    GRM_L["Please Select Event to Add to Calendar"] = true
    GRM_L["No Calendar Events to Add"] = true
    GRM_L["{name}'s event has already been added to the calendar!"] = true
    GRM_L["Please wait {num} more seconds to Add Event to the Calendar!"] = true
    GRM_L["{name}'s Event Removed From the Que!"] = true
    GRM_L["Full Description:"] = true

    -- BAN WINDOW
    GRM_L["BAN LIST"] = true                                        -- Ban List Tab
    GRM_L["Reason Banned?"] = true
    GRM_L["Click \"YES\" When Done"] = true                         -- Of note, the \" is how you notate for quotations to actually appear. Adjust as needed
    GRM_L["Select a Player"] = true
    GRM_L["Player Selected"] = true
    GRM_L["{name}(Still in Guild)"] = true
    GRM_L["No Ban Reason Given"] = true
    GRM_L["Reason:"] = true                                         -- Context: As in, "Reason Banned"
    GRM_L["Total Banned:"] = true
    GRM_L["Rank"] = true
    GRM_L["Ban Date"] = true
    GRM_L["No Players Have Been Banned from Your Guild"] = true
    GRM_L["Remove Ban"] = true
    GRM_L["Add Player to Ban List"] = true
    GRM_L["Server:"] = true
    GRM_L["Class:"] = true
    GRM_L["Reason:"] = true
    GRM_L["It is CRITICAL the player's name and server are spelled correctly for accurate tracking and notifications."] = true
    GRM_L["Submit Ban"] = true
    GRM_L["Confirm"] = true
    GRM_L["Cancel"] = true
    GRM_L["Add"] = true                                         -- Context: "Add" player to ban list
    GRM_L["Confirm Ban for the Following Player?"] = true
    GRM_L["Please Enter a Valid Player Name"] = true            -- Player Name
    GRM_L["Please Enter a Valid Server Name"] = true            -- Server Name
    GRM_L["Please Select a Player to Unban!"] = true
    GRM_L["{name} - Ban List"] = true                           -- Context: "GuildName - Ban List"
    GRM_L["No Reason Given"] = true

    -- ADDON USERS WINDOW
    GRM_L["SYNC USERS"] = true
    GRM_L["Ok!"] = true
    GRM_L["Their Rank too Low"] = true
    GRM_L["Your Rank too Low"] = true
    GRM_L["Outdated Version"] = true
    GRM_L["You Need Updated Version"] = true
    GRM_L["Player Sync Disabled"] = true
    GRM_L["No Guildie Online With Addon."] = true
    GRM_L["ONE Person is Online. Recommend It!"] = true
    GRM_L["{num} others are Online! Recommend It!"] = true
    GRM_L["GRM Sync Info"] = true
    GRM_L["Ver: {custom1}"] = true                                  -- Context:  Ver: R1.125  - Ver is short for Version
    GRM_L["Name:"] = true
    GRM_L["Version"] = true
    GRM_L["Sync"] = true
    GRM_L["Your Sync is Currently Disabled"] = true

    -- OPTIONS WINDOW
    GRM_L["Add Join Date to:  |cffff0000Officer Note|r"] = true         -- Context: Please keep |cffff0000 for color coding of the text, and the |r to signify the end of color change
    GRM_L["Add Join Date to:  Officer Note"] = true
    GRM_L["Public Note"] = true
    GRM_L["Scanning Roster:"] = true
    GRM_L["Guild Rank Restricted:"] = true
    GRM_L["Sync:"] = true
    -- Options window -- of note, these are very concise statements. They may need to be adjusted properly in the Options window for proper spacing, so verify they look ok after translating.
    GRM_L["Slash Commands"] = true
    GRM_L["Trigger scan for changes manually"] = true
    GRM_L["Trigger sync one time manually"] = true
    GRM_L["Centers all Windows"] = true
    GRM_L["Slash command info"] = true
    GRM_L["Resets ALL data"] = true
    GRM_L["Report addon ver"] = true                                    -- Ver is short for Version
    GRM_L["Resets Guild data"] = true
    GRM_L["Show at Logon"] = true
    GRM_L["Only Show if Log Changes"] = true
    
    -- This do need to be translated still
    GRM_L["Before Scan Timer"] = "Scan for Changes Every"                  -- Context: "Scan for Changes Every 10 Seconds" -- There will be a number added here and may require custom positioning, so please provide full statement and Arkaan will allign
    GRM_L["After Scan Timer"] = "Seconds"
    GRM_L["Before Inactive Timer"] = "Report Inactive Return if Player Offline"
    GRM_L["After Inactive Timer"] = "Days"

    GRM_L["Reactivating SCAN for Guild Member Changes..."] = true
    GRM_L["Deactivating SCAN of Guild Member Changes..."] = true
    GRM_L["Due to server data restrictions, a scan interval must be at least 10 seconds or more!"] = true
    GRM_L["Please choose an scan interval 10 seconds or higher!"] = true
    GRM_L["{num} is too Low!"] = true
    GRM_L["The Current Lvl Cap is {num}."] = true
    GRM_L["Kick Inactive Player Reminder at"] = true        -- Context: "Kick Inactive Player Reminder at X Months" - Again, allignment will need to be adjusted for options UI, so please post
    GRM_L["Please choose a month between 1 and 99"] = true
    GRM_L["Sync BAN List With Guildies at Rank"] = true     -- Context: "Sync Ban List with Guildies at Rank [DROPDOWNMENU OF RANKS] or Higher" - Please show where dropdown menu should be pinned
    GRM_L["or Higher"] = true                               -- Context: Look at the above statement. Show where this needs to go in regards to dropdown menu of rank selection in Options
    GRM_L["Restore Defaults"] = true
    GRM_L["Please choose between 1 and 180 days!"] = true
    GRM_L["Announce Events"] = true                         -- Context: "Announce Events X number of days in advance" -- the X is the editbox to modify number of days. Please include the location of where to pin that.
    GRM_L["Days in Advance"] = true
    GRM_L["Please choose between 1 and 28 days!"] = true
    GRM_L["Add Events to Calendar"] = true
    GRM_L["SYNC Changes With Guildies at Rank"] = true      -- Context: at Rank [DROPDOWNRANKSELECTION] or Higher. - Please note where to place dropdown box in the position of the sentence.
    GRM_L["Reactivating Data SYNC with Guildies..."] = true
    GRM_L["Deactivating Data SYNC with Guildies..."] = true
    GRM_L["Display Sync Update Messages"] = true
    GRM_L["Only Sync With Up-to-Date Addon Users"] = true
    GRM_L["Only Announce Anniversaries if Listed as 'Main'"] = true
    GRM_L["Leveled"] = true
    GRM_L["Min:"] = true                                    -- Context: As in, the Minimum level to report or announce when player levels up
    GRM_L["Inactive Return"] = true
    GRM_L["resetall"] = true
    GRM_L["resetguild"] = true
    GRM_L["Notify When Players Request to Join the Guild"] = true
    --Side chat/log controls - Of note, limited spacing
    GRM_L["Name Change"] = true
    GRM_L["Rank Renamed"] = true
    GRM_L["Event Announce"] = true
    GRM_L["Left"] = true                        -- Context: As in, "Left" the guild...
    GRM_L["Recommendations"] = true
    GRM_L["Banned"] = true
    GRM_L["To Chat:"] = true                    -- Context: "To Chat Message frame -- in regards to announcing events like when a player leveled"
    GRM_L["To Log:"] = true                     -- Context: To show it in the guild log.
    GRM_L["Display Changes"] = true
    GRM_L["Syncing too fast may cause disconnects!"] = true
    GRM_L["Speed:"] = true                      -- Context: Speed that the sync takes place.
    GRM_L["Show 'Main' Name in Chat"] = true

    -- AUDIT WINDOW
    GRM_L["AUDIT"] = true                                               -- Audit Tab name
    GRM_L["No Date Set"] = true
    GRM_L["Main"] = true
    GRM_L["Main or Alt?"] = true
    GRM_L["Alt"] = true
    GRM_L["Total Incomplete: {num} / {custom1}"] = true                 -- Context: Total Incomeplete: 50 / 100    (50 out of 100)
    GRM_L["Mains: {num}"] = true                                        -- Context: Number of "main" toons
    GRM_L["Unique Accounts: {num}"] = true
    GRM_L["All Complete"] = true                                        -- Context: All dates have been added and are known, thus it states it is "All Complete"
    GRM_L["Set Incomplete to Unknown"] = true                           -- Context: Implied to set ALL incomplete to unknown
    GRM_L["Clear All Unknown"] = true
    GRM_L["Please Wait {num} more Seconds"] = true
    GRM_L["Guild Data Audit"] = true
    GRM_L["Name"] = true
    GRM_L["Join Date"] = true
    GRM_L["Promo Date"] = true
    GRM_L["Main/Alt"] = true
    GRM_L["Click Player to Edit"] = true
    GRM_L["Only Show Incomplete Guildies"] = true

    -- ADDON SYSTEM MESSAGES
    GRM_L["Guild Roster Manager"] = true
    GRM_L["GRM:"] = true                                                                -- Abbreviation for "Guild Roster Manager"
    GRM_L["(Ver:"] = true                                                               -- Ver: is short for Version:
    GRM_L["GRM Updated:"] = true
    GRM_L["Configuring Guild Roster Manager for {name} for the first time."] = true
    GRM_L["Reactivating Auto SCAN for Guild Member Changes..."] = true
    GRM_L["Reactivating Data Sync..."] = true
    GRM_L["Notification Set:"] = true
    GRM_L["Report When {name} is ACTIVE Again!"] = true
    GRM_L["Report When {name} Comes Online!"] = true
    GRM_L["Report When {name} Goes Offline!"] = true
    GRM_L["A new version of Guild Roster Manager is Available!"] = true
    GRM_L["Please Upgrade!"] = true
    GRM_L["Player Does Not Have a Time Machine!"] = true
    GRM_L["Please choose a valid DAY"] = true
    GRM_L["{name} has been Removed from the Ban List."] = true
    GRM_L["{num} Players Have Requested to Join the Guild."] = true
    GRM_L["A Player Has Requested to Join the Guild."] = true
    GRM_L["Click Link to Open Recruiting Window:"] = true
    GRM_L["Guild Recruits"] = true
    GRM_L["Scanning for Guild Changes Now. One Moment..."] = true
    GRM_L["Breaking current Sync with {name}."] = true
    GRM_L["Breaking current Sync with the Guild..."] = true
    GRM_L["Initializing Sync Action. One Moment..."] = true
    GRM_L["No Players Currently Online to Sync With..."] = true
    GRM_L["No Addon Users Currently Compatible for FULL Sync."] = true
    GRM_L["SYNC is currently not possible! Unable to Sync with guildies when guild chat is restricted."] = true
    GRM_L["There are No Current Applicants Requesting to Join the Guild."] = true
    GRM_L["The Applicant List is Unavailable Without Having Invite Privileges."] = true
    GRM_L["Manual Scan Complete"] = true
    GRM_L["Analyzing guild for the first time..."] = true
    GRM_L["Building Profiles on ALL \"{name}\" members"] = true                 -- {name} will be the Guild Name, for context
    GRM_L["NOTIFICATION:"] = true                                               -- Context:  "Notification: Player is no longer AFK"
    GRM_L["{name} is now ONLINE!"] = true
    GRM_L["{name} is now OFFLINE!"] = true
    GRM_L["{name} is No Longer AFK or Busy!"] = true
    GRM_L["{name} is No Longer AFK or Busy, but they Went OFFLINE!"] = true
    GRM_L["{name} is Already in Your Group!"] = true
    GRM_L["GROUP NOTIFICATION:"] = true
    GRM_L["Players Offline:"] = true
    GRM_L["Players AFK:"] = true
    GRM_L["40 players have already been invited to this Raid!"] = true
    GRM_L["Player should try to obtain group invite privileges."] = true
    GRM_L["{name}'s saved data has been wiped!"] = true
    GRM_L["Re-Syncing {name}'s Guild Data..."] = true
    GRM_L["Wiping all Saved Roster Data Account Wide! Rebuilding from Scratch..."] = true
    GRM_L["Wiping all saved Guild data! Rebuilding from scratch..."] = true
    GRM_L["There are No Log Entries to Delete, silly {name}!"] = true
    GRM_L["Guild Log has been RESET!"] = true
    GRM_L["{name} is now set as \"main\""] = true
    GRM_L["{name} is no longer set as \"main\""] = true
    GRM_L["Reset All of {name}'s Data?"] = true
    
    -- /grm help
    GRM_L["Opens Guild Log Window"] = true
    GRM_L["Resets ALL saved data"] = true
    GRM_L["Resets saved data only for current guild"] = true
    GRM_L["Re-centers the Log window"] = true
    GRM_L["Triggers manual re-sync if sync is enabled"] = true
    GRM_L["Does a one-time manual scan for changes"] = true
    GRM_L["Displays current Addon version"] = true
    GRM_L["Opens Guild Recruitment Window"] = true
    GRM_L["WARNING! complete hard wipe, including settings, as if addon was just installed."] = true;

    -- General Misc UI
    GRM_L["Really Clear All Account-Wide Saved Data?"] = true
    GRM_L["Really Clear All Guild Saved Data?"] = true
    GRM_L["Yes!"] = true
    GRM_L["<M>"] = true                             -- <M> appears for "Main"
    GRM_L["Ban Player?"] = true
    GRM_L["Ban the Player's {num} alts too?"] = true      -- Plural number of alts
    GRM_L["Ban the Player's {num} alt too?"] = true     -- Singular number of alts, just 1
    GRM_L["Please Click \"Yes\" to Ban the Player!"] = true

    -- Sync Messages
    GRM_L["{name} updated {name2}'s Join Date."] = true
    GRM_L["{name} updated {name2}'s Promotion Date."] = true
    GRM_L["\"{custom1}\" event added to the calendar by {name}"] = true
    GRM_L["{name} updated {name2}'s list of Alts."] = true
    GRM_L["{name} removed {name2}'s from {custom1}'s list of Alts."] = true
    GRM_L["{name} set {name2} to be 'Main'"] = true
    GRM_L["{name} has changed {name2} to be listed as an 'alt'"] = true
    GRM_L["{name} has Removed {name2} from the Ban List."] = true
    GRM_L["{name} has been BANNED from the guild!"] = true
    GRM_L["{name} has been UN-BANNED from the guild!"] = true
    GRM_L["Initiating Sync with {name} Instead!"] = true
    GRM_L["Sync Failed with {name}..."] = true
    GRM_L["The Player Appears to Be Offline."] = true
    GRM_L["There Might be a Problem With Their Sync"] = true
    GRM_L["While not ideal, Ask Them to /reload to Fix It and Please Report the Issue to Addon Creator"] = true
    GRM_L["Manually Syncing Data With Guildies Now... One Time Only."] = true
    GRM_L["Syncing Data With Guildies Now..."] = true
    GRM_L["(Loading screens may cause sync to fail)"] = true
    GRM_L["Sync With Guildies Complete..."] = true
    GRM_L["Manual Sync With Guildies Complete..."] = true
    GRM_L["No Players Currently Online to Sync With. Re-Disabling Sync..."] = true
    GRM_L["{name} tried to Sync with you, but their addon is outdated."] = true
    GRM_L["Remind them to update!"] = true

    
    -- ERROR MESSAGES
    GRM_L["Notification Has Already Been Arranged..."] = true
    GRM_L["Failed to add alt for unknown reason. Try closing Roster window and retrying!"] = true
    GRM_L["{name} is Already Listed as an Alt."] = true
    GRM_L["{name} cannot become their own alt!"] = true
    GRM_L["Player Cannot Add Themselves as an Alt"] = true
    GRM_L["Player Not Found"] = true
    GRM_L["Please try again momentarily... Updating the Guild Event Log as we speak!"] = true
    GRM_L["Invalid Command: Please type '/grm help' for More Info!"] = true
    GRM_L["{name} is not currently in a guild. Unable to Proceed!"] = true
    GRM_L["Addon does not currently support more than 75 alts!"] = true
    GRM_L["Please choose a VALID character to set as an Alt"] = true
    GRM_L["Please choose a character to set as alt."] = true
    GRM_L["GRM ERROR:"] = true
    GRM_L["Com Message too large for server"] = true                    -- Context: "Com message" is short-hand for "Communications message" - this is a technical error on syncing data.
    GRM_L["Prefix:"] = true
    GRM_L["Msg:"] = true                                                -- Context: Msg is short for Message
    GRM_L["Unable to register prefix > 16 characters: {name}"] = true   -- Context: The {name} is the string code for the prefix. This is for debugging.


    --SLASH COMMANDS
    -- These are generally written in general shorthand. The original commands will ALWAYS work, but if there is one that makes more sense in your language, please feel free to modify
    GRM_L["clearall"] = true                        -- Context: In regards, "Clear All" saved data account wide 
    GRM_L["clearguild"] = true                      -- Context: In regards, "Clear All" saved data from ONLY the current guild.
    GRM_L["hardreset"] = true                       -- Context: In regards, "Hard Reset" ALL data account wide, including wiping player settings
    GRM_L["help"] = true                            -- Context: "help" with info on the how to use addon
    GRM_L["version"] = true                         -- Context: "version" of the addon
    GRM_L["center"] = true                          -- Context: "center" the movable addon window back to center of screen
    GRM_L["sync"] = true                            -- Context: "sync" the data between players one time now.
    GRM_L["scan"] = true                            -- Context: "scan" for guild roster changes one time now.
    GRM_L["clearall"] = true                        -- Context: In regards, "Clear All" saved data
    GRM_L["recruit"] = true                         -- Context: Open the roster "recruit" window where people request to join guild

    -- CLASSES
    GRM_L["Deathknight"] = "死亡骑士"
    GRM_L["Demonhunter"] = "恶魔猎手"
    GRM_L["Druid"] = "德鲁伊"
    GRM_L["Hunter"] = "猎人"
    GRM_L["Mage"] = "法师"
    GRM_L["Monk"] = "武僧"
    GRM_L["Paladin"] = "圣骑士"
    GRM_L["Priest"] = "牧师"
    GRM_L["Rogue"] = "潜行者"
    GRM_L["Shaman"] = "萨满祭司"
    GRM_L["Warlock"] = "术士"
    GRM_L["Warrior"] = "战士"

    -- TIME AND DATES
    GRM_L["1 Mar"] = "3月1日"                           -- This date is used in a specific circumstance. If someone's anniversary/bday landed on a leap year (Feb 29th), it defaults to the 1st of March on non-leap year
    -- Full Month Name
    GRM_L["January"] = "一 月"
    GRM_L["February"] = "二 月"
    GRM_L["March"] = "三 月"
    GRM_L["April"] = "四 月"
    GRM_L["May"] = "五 月"
    GRM_L["June"] = "六 月"
    GRM_L["July"] = "七 月"
    GRM_L["August"] = "八 月"
    GRM_L["September"] = "九 月"
    GRM_L["October"] = "十 月"
    GRM_L["November"] = "十一 月"
    GRM_L["December"] = "十二 月"
    -- Shorthand Month
    GRM_L["Jan"] = "一 月"
    GRM_L["Feb"] = "二 月"
    GRM_L["Mar"] = "三 月"
    GRM_L["Apr"] = "四 月"
    GRM_L["May"] = "五 月"
    GRM_L["Jun"] = "六 月"
    GRM_L["Jul"] = "七 月"
    GRM_L["Aug"] = "八 月"
    GRM_L["Sep"] = "九 月"
    GRM_L["Oct"] = "十 月"
    GRM_L["Nov"] = "十一 月"
    GRM_L["Dec"] = "十二 月"
    -- Time Notifcation
    GRM_L["Seconds"] = true
    GRM_L["Second"] = true
    GRM_L["Minutes"] = true
    GRM_L["Minute"] = true
    GRM_L["Hours"] = true
    GRM_L["Hour"] = true
    GRM_L["Days"] = true
    GRM_L["Day"] = true
    GRM_L["Months"] = true
    GRM_L["Month"] = true
    GRM_L["Years"] = true
    GRM_L["Year"] = true
    GRM_L["HourBreak"] = ":"            -- Context, in English, and many languages, 11am = 11:00 -- or in French, 11h00   - the hour break is the ":" or the "h" 

    GRM_L["am"] = true
    GRM_L["pm"] = true
    GRM_L["24HR_Notation"] = "";        -- if someone is using 24hr time notation in your country, instead of 12hr, how do you notate it? In English, there is no am/pm (though "hours" is technically right, but unnecessary)

    GRM_L["{num} year"] = true
    GRM_L["{num} years"] = true
    GRM_L["{num} month"] = true
    GRM_L["{num} months"] = true
    GRM_L["{num} day"] = true
    GRM_L["{num} days"] = true
    GRM_L["< 1 day"] = true

    GRM_L["{num} yr"] = true
    GRM_L["{num} yrs"] = true
    GRM_L["{num} mo"] = true
    GRM_L["{num} mos"] = true
    GRM_L["{num} hr"] = true
    GRM_L["{num} hrs"] = true
    GRM_L["< 1 hour"] = true
    GRM_L["{num} {custom1}"] = true     -- Context: This is a placeholder for ANY generic time data -- Ex:  "1 year" or "15 months" - The translation is set this is just to set the orientation of the number properly.

    -- MISC Punctuation
    GRM_L[","] = true                               -- I know in some Asia languages, a comma is not used, but something similar, for example.

    -- Updates 1.126
    GRM_L["General"] = true
    GRM_L["General:"] = true
    GRM_L["Scan"] = true
    GRM_L["Help"] = true
    GRM_L["UI"] = true                              -- UI for User Interface. Abbreviation for changing custom UI featuers, like coloring of <M> main
    GRM_L["Officer"] = true                         -- as in, "Officer" rank
    GRM_L["Open Addon Window"] = true
    GRM_L["Sync Addon Settings on All Alts in Same Guild"] = true
    GRM_L["Show Minimap Button"] = true
    GRM_L["Player is Not Currently in a Guild"] = true
    -- tooltips
    GRM_L["|CFFE6CC7FClick|r to open GRM"] = true                           -- Please maintain the color coding
    GRM_L["|CFFE6CC7FRight-Click|r and drag to move this button."] = true   -- Likewise, maintain color coding
    GRM_L["|CFFE6CC7FRight-Click|r to Reset to 100%"] = true                -- for the Options slider tooltip
    GRM_L["|CFFE6CC7FRight-Click|r to Sync Join Date with Alts"] = true
    GRM_L["|CFFE6CC7FRight-Click|r to Set Notification of Status Change"] = true
    -- tooltip end
    GRM_L["GRM"] = true
    GRM_L["<A>"] = true                                                     -- This is the "Alt" tag on the Add Alt side window.
    GRM_L["Include Unknown as Incomplete"] = true                           -- Context: Unknown in the Audit Tab will be hidden if filtering out complete players
    GRM_L["You Do Not Have Permission to Add Events to Calendar"] = true
    GRM_L["Please Select Which Join Date to Sync"] = true
    GRM_L["Sync All Alts to {name}'s Join Date"] = true
    GRM_L["Sync All Alts to the Earliest Join Date: {name}"] = true
    GRM_L["Sync All Alts to {name}'s |cffff0000(main)|r Join Date"] = true  -- The coloring ensures that "(main)" maintains the RED color. Please keep it consistent if relevant to your language.
    GRM_L["Join Date of All Alts is Currently Synced"] = true

    -- Update 1.130
    GRM_L["|CFFE6CC7FCtrl-Shift-Click|r to Hide this Button."] = true
    GRM_L["Invited By:"] = true
    GRM_L["To avoid storage bloat, a maximum of 2 save points is currently possible. Please remove one before Continuing."] = true
    GRM_L["Error: Guild Not Found..."] = true
    GRM_L["Debugger Start"] = true;

    -- Update 1.136
    GRM_L["To avoid storage bloat, a maximum of 2 guild save points is currently possible. Please remove one before continuing"] = true
    GRM_L["Backup Point Removed for Guild \"{name}\""] = true
    GRM_L["Backup Point Restored for Guild \"{name}\""] = true
    GRM_L["Backup Point Set for Guild \"{name}\""] = true
    GRM_L["Backup"] = true
    GRM_L["Horde"] = true
    GRM_L["Alliance"] = true
    GRM_L["Creation Date"] = true
    GRM_L["Members"] = true
    GRM_L["Backup {num}:"] = true           -- As in, the number of backups... so "Backup 1:"
    GRM_L["None"] = true
    GRM_L["Restore"] = true
    GRM_L["Set Backup"] = true
    GRM_L["Memory Usage: {num} MB"] = true          -- MB references the number of MegaBytes of memory used.

    -- Update 1.137
    GRM_L["GRM: Unable to Create Backup for a Guild With Unknown Creation Date! Log into that guild on any alt to update old database."] = true
    GRM_L["Enable Auto-Backup Once Every"] = true
    GRM_L["Auto {num}:"] = true
    GRM_L["Please Choose a Time Interval Between 1 and 99 Days!"] = true
    GRM_L["Really restore {name} Backup Point?"] = true
    GRM_L["Check All"] = true

    -- Update 1.139
    GRM_L["Right-Click for options to remove this guild from the addon database completely"] = true
    GRM_L["Player Cannot Purge the Guild Data they are Currently In!!!"] = true
    GRM_L["To reset your current guild data type '/grm clearguild'"] = true
    GRM_L["Click Here to Remove all traces of this guild, or hit ESC"] = true
    GRM_L["{name} has been removed from the database."] = true              -- The Guild Name has been removed from the database

    -- update 1.141
    GRM_L["You will still share your data with the guild, but you are currently only accepting incoming changes from rank \"{name}\" or higher"] = true    -- Reminder, the backslash before a quotation denotes the string NOT to close, but to include the quotation in display txt
    GRM_L["Only Restrict Incoming Player Data to Rank Threshold, not Outgoing"] = true
    GRM_L["Total Entries: {num}"] = true
    GRM_L["Search Filter"] = true

    -- update 1.142
    GRM_L["Choose Color:"] = true
    GRM_L["Format:"] = true
    GRM_L["M"] = true           -- Of note, the "M" is short for "Main" and this is the reference to the main tag on alts in guild chat.
    GRM_L["RGB Values Must be Between 1 and 255."] = true

    -- Update 1.143
    GRM_L["The Log is Currently Empty for This Guild"] = true
    GRM_L["Building Log for Export..."] = true
    GRM_L["Open Log Tools"] = true
    GRM_L["Hide Log Tools"] = true
    GRM_L["Numbered Lines"] = true
    GRM_L["Export Log"] = true
    GRM_L["Clear Lines:"] = true
    GRM_L["Enable Ctrl-Shift-Click Line Removal"] = true
    GRM_L["To"] = true                                      -- Clear Lines:  50 To 100     -- It stands between 2 edit boxes as its own fontstring, so work with that.
    GRM_L["Confirm Clear"] = true
    GRM_L["Please Select Range of Lines from the Log You Wish to Remove"] = true
    GRM_L["Please put the lowest number in the first box"] = true
    GRM_L["Line selection is not valid"] = true
    GRM_L["Really Clear lines {custom1} to {custom2}?"] = true
    GRM_L["Enabling Line Numbers... Please choose within the given range"] = true
    GRM_L["Ctrl-C to Copy <> Ctrl-P to Paste <> Ctrl-A to Select All"] = true
    GRM_L["Language Selection:"] = true
    GRM_L["{num} phrases still need translation to {name}"] = true                  -- Ex: 300 phrases still need translation to German

    -- update 1.145
    GRM_L["You currently are at {num} non-Battletag friends. To fully take advantage of all of GRM features, please consider clearing some room."] = true
    GRM_L["Clear Space on Friends List to Find Online Status"] = true
    GRM_L["Offline"] = true
    GRM_L["{name} has requested to join the guild and is currently ONLINE!"] = true

    -- Update 1.146
    GRM_L["Really Clear line {num}?"] = true
    GRM_L["Font has been Reset to DEFAULT."] = true
    GRM_L["Font Selection:"] = true
    GRM_L["Font Scale:"] = true
    GRM_L["Example"] = true
    GRM_L["Right-Click to Reset to 100%"] = true

    -- Update 1.147
    GRM_L["|CFFE6CC7FClick|r to open Player Window"] = true
    GRM_L["|CFFE6CC7FCtrl-Shift-Click|r to Search the Log for Player"] = true

    -- Update 1.1480
    GRM_L["Custom Notes:"] = true
    GRM_L["GRM Debugging Enabled."] = true
    GRM_L["GRM Debugging Disabled."] = true
    GRM_L["Please type \"/grm debug 10\" to report 10 events (or any number)"] = true        -- Please keep the \"/grm debug 10)\" in-tact for slash command to work
    GRM_L["Format: \"/grm debug 10\""] = true                                                                  -- "" Likewise
    GRM_L["Error: Debug Command not recognized."] = true
    GRM_L["You may want to temporarily disable SYNC in the options if you are debugging another feature."] = true
    GRM_L["Sync Custom Notes"] = true
    GRM_L["Default Custom Note Rank Minimum"] = true
    GRM_L["Reset Default Custom Note Restrictions for ALL Guildies"] = true
    GRM_L["Reset to Default"] = true
    GRM_L["Reset"] = true
    GRM_L["|CFF00CCFFDefault Selection For All Players"] = true
    GRM_L["Each Guildie Can Still be Manually Configured"] = true
    GRM_L["Does NOT apply to Ban List or Custom Note"] = true
    GRM_L["Custom note Rank reset to default \"{name}\" (or higher)"] = true
    GRM_L["If sync was manually disabled for specific guildies, this does NOT enabled it."] = true
    GRM_L["Custom note default settings for Rank and Sync have been reset."] = true
    GRM_L["Custom note Sync has been reset to default"] = true
    GRM_L["Click here to set Custom Notes"] = true
    GRM_L["|CFF00CCFFCustom Note Defaults:"] = true
    GRM_L["|CFFE6CC7FLeft-Click|r to ONLY reset all to default rank"] = true
    GRM_L["|CFFE6CC7FCtrl-Shift-Click|r to reset BOTH sync and rank defaults"] = true
    GRM_L["|CFFE6CC7FCtrl-Left-Click|r to re-enable custom note sync for all"] = true
    GRM_L["Custom Note Sync Disabled in Settings"] = true
    GRM_L["{name} modified {name2}'s CUSTOM Note: \"{custom1}\" was Added"] = true
    GRM_L["{name} modified {name2}'s CUSTOM Note: \"{custom1}\" was Removed"] = true
    GRM_L["{name} modified {name2}'s CUSTOM Note: \"{custom1}\" to \"{custom2}\""] = true
    GRM_L["Custom Note"] = true
    GRM_L["Syncing Outgoing Data."] = true
    GRM_L["|CFFE6CC7FClick|r to Change Rank Restriction"] = true
    GRM_L["|CFFE6CC7FClick|r to Change Day"] = true
    GRM_L["|CFFE6CC7FClick|r to Change Month"] = true;
    GRM_L["|CFFE6CC7FClick|r to Change Year"] = true;
    GRM_L["Edited by {name}"] = true
    GRM_L["Note Removed by {name}"] = true
    GRM_L["|CFFFF0000Player No Longer in Guild"] = true
    GRM_L["|CFF00CCFFMinimum Rank to Sync: Player Data, Custom Notes, Ban List"] = true
    GRM_L["Warning! Ban List rank threshold is below the overall sync rank. Changing from \"{name}\" to \"{name2}\""] = true
    GRM_L["Warning! Custom Note rank threshold is below the overall sync rank. Changing default from \"{name}\" to \"{name2}\""] = true
    GRM_L["Custom Note Default Rank is Also Being Set to \"{name}\""] = true
    GRM_L["|CFF00CCFFSync filter can be set tighter for the Ban List"] = true
    GRM_L["Warning! Unable to select a Ban List rank below \"{name}\""] = true
    GRM_L["Warning! Custom Note rank filter must be below \"{name}\""] = true
    GRM_L["Setting to match core filter rank"] = true
    GRM_L["Warning! \"{name}\" is the lowest rank that can receive this custom note.\nCheck the options menu to adjust overall settings."] = true

    -- R1.1482
    GRM_L["Shift-Click Name On Roster Also Works"] = true
    GRM_L["Tooltip Scale:"] = true
    GRM_L["|CFFE6CC7FLeft-Click|r to Change the Language"] = true
    GRM_L["|CFFE6CC7FLeft-Click|r to Change Display Format"] = true
    GRM_L["|CFFE6CC7FLeft-Click|r to Change the Font"] = true
    GRM_L["Unfortunately each player's data will need to be manually reconfigured."] = true
    GRM_L["{num} custom {custom1} removed that matched text:"] = true                           -- custom1 = "note" or the plural "notes"
    GRM_L["notes"] = true
    GRM_L["Please add specific text, in quotations, to match"] = true

    -- R1.1490
    GRM_L["You will still share some outgoing data with the guild"] = true
    GRM_L["Unable to properly locate guild for backup"] = true

    -- R1.1500
    GRM_L["It's almost time to celebrate {name}'s Birthday! ( {custom1} )"] = true          -- Custom1 is the actual date.  Like "1 Mar '18"
    GRM_L["Unique accounts pull from the server is known to faulty"] = true
    GRM_L["Use only as an estimate. Hopefully Blizz fixes this soon"] = true
    GRM_L["{name}'s Anniversary!"] = true
    GRM_L["{name}'s Birthday!"] = true
    GRM_L["Guild member for over {num} year"] = true
    GRM_L["Guild member for over {num} years"] = true   -- the plural version!
    GRM_L["Add Upcoming Events to the Calendar"] = true
    GRM_L["Player rank unable to add events to calendar"] = true
    GRM_L["Anniversaries, Birthdays, and Other Events can be added with permission"] = true

    -- R1.1510
    GRM_L["Check the \"Sync Users\" tab to find out why!"] = true
    GRM_L["Time as Member:"] = true
    GRM_L["|CFFE6CC7FClick|r to select player event"] = true
    GRM_L["|CFFE6CC7FClick Again|r to open Player Window"] = true
    GRM_L["Timestamp Format:"] = true
    GRM_L["Hour Format:"] = true
    GRM_L["24 Hour"] = true
    GRM_L["12 Hour (am/pm)"] = true
    GRM_L["Enable Fade on Tab Change"] = true
    GRM_L["Confirm Custom Note"] = true

    -- R1.1520
    GRM_L["A new rank has been added to the guild!"] = true
    GRM_L["{num} new ranks have been added to the guild!"] = true
    GRM_L["The guild has removed a rank!"] = true
    GRM_L["{num} guild ranks have been removed!" ] = true
    GRM_L["Edit Ban"] = true
    GRM_L["Please Select a Player to Edit their Ban!"] = true
    GRM_L["Update Ban"] = true
    GRM_L["{name}'s Ban Info has Been Updated!"] = true

    -- R1.1530
    GRM_L["{name} plays the {custom1} class, not {custom2}."] = true             -- Example: Arkaan plays the Hunter class, not Paladin.
    GRM_L["Don't Remembert their class?"] = true
    GRM_L["{num} Items Updated"] = true
    GRM_L["You Currently Have Disabled Adding Events to Calendar"] = true

    -- R1.20
    GRM_L["|CFFE6CC7FHold Shift|r to view more alt details."] = true                -- "Hold Shift to view more alt details" is the phrase, but the |CFF|r is the text coloring hex code. Please keep it in there on the keyboard command coloring
    GRM_L["|CFFE6CC7FShift-Click|r to keep alt details open."] = true               -- The same can be said here. ^^
    GRM_L["|CFFE6CC7FClick|r to flip player name ordering"] = true                  -- and the reset...
    GRM_L["|CFFE6CC7FClick|r to sort Join Dates by Newest"] = true
    GRM_L["|CFFE6CC7FClick|r to sort Join Dates by Oldest"] = true
    GRM_L["|CFFE6CC7FClick|r to sort Promotion Dates by Newest"] = true
    GRM_L["|CFFE6CC7FClick|r to sort Promotion Dates by Oldest"] = true
    GRM_L["|CFFE6CC7FClick|r to sort all Mains first"] = true
    GRM_L["|CFFE6CC7FClick|r to sort all Alts first."] = true
    
end

-- BuildLog() - might have some extra work, conditionally based on localization as it will now have a mix of languages saved to the log, since log is not retroactively changed.
-- The options panel might need some handcrafted care for allignment.