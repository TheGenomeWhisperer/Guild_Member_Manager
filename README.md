**VERSION 7.3.2R1.110 - DATE: 24 Nov, 2017**

***MAJOR SYNC ISSUE BUG FIX***

*Ok, I won't get into the technical details, but suffice it to say a few updates back I kind of went in and did some behind-the-scenes updates, optimizing the process, improving some speed aspects of the sync, making the process leaner and so on. I also apparently broke it some aspects of it lol. This was not an easy fix. This was pretty gritty actually, largely because of how much extra work I need to do to actually get a dynamic, retroactive sync working, with this much data, within the limits of this API, and within the limits of throttled server comms by Blizz, all while doing it in a way that is seemless and invisible to the addon user. Welp, ya, I broke a few things without realizing it and I believe I have them working now. Yay!*

* *Of note, I have not yet tested this beyond 5 accounts syncing in a large guild, and it seemed fine. I will need people to report back and if there are issues, so we can get them resolved ASAP!!!*

**QUALITY OF LIFE**

* Player's full name-servername appear in the log when they leave or are kicked from the guild (for you xrealm people!)

* Furthermore, the class is now apparent in the log for the leaving player and any remaining alts

* Ability to clear just the guild data with '/roster resetguild' or from the options

* Options slash command buttons are much more obvious.

**BUG FIXES**

* Everyone appeared online in previous update. Silly bug! Status should now display accurately.

* Again, sync issues should hopefully be resolved now. I have not done a lot of testing, but I have done some. I will need reports.

*Final Note: Not a ton of major updates here, though I am working on a large project. My focus was 100% spent on resolving the sync issue for people. Thank you for your support in reporting issues and patience for me getting them fixed!*


**VERSION 7.3.2R1.109 - DATE: 19 Nov, 2017**

* OOPS! Uploaded sync.lua file with the sync helpers still in it (my test version). You would be getting a ton of sync spam as it transmitted data. This is hidden now and should not be scene lol


**VERSION 7.3.2R1.108 - DATE: 18 Nov, 2017**

*Very important Sync bug fix that I broke in a recent update*

* Bug Fix1: Sync would only work with 2 players in any guild larger than 50ish memebrs. If more than 1 person was online with the addon installed, it would fail endlessly and keep retrying. How annoying! Simple fix really, It just made the mistake of testing my new error checks worked properly in a guild that was too small and not a larger guild which faces throttle sync issues across the server.


**VERSION 7.3.2R1.107 - DATE: 15 Nov, 2017**

*I was trying to get another big project finished, but it's just not quite ready. I will have more time this weekend to work on it. So, very minor fix here since this is an annoying bug.*

**BUG FIXES**

* Bug Fix1: If a player had the "Add Join Date" to public/officer note disabled, it would report to the log that the note was changed, but then it would report the note was removed because it would scan the data and show it never actually was. This should no longer do it.


**VERSION 7.3.2R1.106 - DATE: 12 Nov, 2017**

**Minor Feature**

* Ability to add "Join Date" to either the officer OR public note, in the options window. It will auto-default to public note if you use certain addons (like "epgp")

**QUALITY OF LIFE**

* More live updating frames. For example, the zone timer will now update live the time passed.

* New slash command to bring up the ban list:  /roster ban or banlist

* Buttons now more properly alligned in the options window.

**BUG BIXES**

* Bug Fix1: Issue with namechange detection for very rare cases when players have literally all the same information (same class, lvl, achievement pts, guild rank, guiild rep, same notes), this event actually occurred and got reported to me. Now, the addon will detect if more than 1 player matches for namechange and handle it.


**VERSION 7.3.2R1.105 - DATE: 10 Nov, 2017**

**BUG FIX**

* One minor quick fix... if you tried to remove a ban from a player, you'd get a Lua error and frames would not update. FIXED!


**VERSION 7.3.2R1.104 - DATE: 10 Nov, 2017**

**NEW FEATURE**

*Player can now take advantage of manually adding a player to the ban list, not just when gkicking someone. This had a TON of things that needed to happen behind the scenes, so what might seem like such a simple feature on the front end was immensely time-consuming.Huge sub-project really due to the auto-generation of a manually added metadata profile and so on.*

**QUALITY OF LIFE**

* Addon now detects the "EPGP" addon and will automatically disable the adding of join dates to officer notes with the user needing to manually go into the settings. It is an immensely popular addon, so this helps avoid any officer note conflicts.

* Ban List sync tweaked a bit for some more edge cases I discovered.

* Modularized a bit of the UI loading to improve performance. It's already quick, but now it's quicker.


**VERSION 7.3.2R1.103 - DATE: 7 Nov, 2017**

**NEW FEATURE**

*"Ban all alts too" has now returned, sort of. While you no longer can gkick them all with the click of a button, as you could in pre-7.3, you now have the option to ban all of the alts of the player as well, so when you gkick the one player, it also bans all their alts. They immediately show up in the ban list as "still in guild" so you know who to still kick (plus the given reason will all be the same)*

**BUG FIXES**

* Bug Fix1: Sync is working again! I broke it without realizing it for like 90% of guilds out there. Oops lol

* Bug Fix2: Sometimes ban list could erroneously purge a name from it. Well that's not good! This shouldn't happen anymore.

* Bug Fix3: Blizz made another stealth change, so I had to adjust the "click on alt name" feature. It no longer attempts to scroll the roster to position of player.


**VERSION 7.3.2R1.102 - DATE: 5 Nov, 2017**

* Bug Fix1: Server Sync would not work if you had a server name that included a hyphen (like EU "Azjol-Nerub"), as it didn't parse properly. Fixed!

* Bug Fix2: Some even tighter controls on sync, if a player's sync fails (like if a player logs off in the middle), or for any reason, it will re-evaluate the sync leadership structure, as well as the que. It will even determine the cause of sync failure, even notify you if player is offline now, and so on.


**VERSION 7.3.2R1.101 - DATE: 30 Oct, 2017**

**QUALITY OF LIFE**

* QOL 1: SyncInfo window now states a "helper" if you have sync disabled in the options or not.

* QOL 2: Addon will now trigger a re-sync automatically after doing a full reset (/roster clearall), rather than needing to manually

* QOL 3: Sync sometimes could fail in certain occasions. Not a big deal as it would reset itself the next time someone logs with addon installed, or you /reload. However, in some edge cases you could get stuck in sync limbo, never acknowlodging it failed. This could happen say, if a player logged off in the middle of a sync in certain cases. Not always, just some circumstances. The addon is now significantly smarter at how to handle resync on failure, as well as checking things like online status of the players and so on.

* QOL 4: Reset Defaults button is now included in the OPTIONS panel.

**BUG FIXES**

* Bug Fix1: Slight modification to the font system for localization support in a more streamlined, server-side deciding way

* Bug Fix2: Lua error could occur on first login due to guildName loading order for ban list. Minor issue, just needed to load proper order, onshow



**VERSION 7.3.2R1.100 - DATE: 27 Oct, 2017**

***HUGE UPDATE*** *Note: You need to encourage your guildies to upgrade to latest version or else ban list will not sync. I'd even highly recommend in the options restricting sync to only people who have latest version. Some people with really old version might get hit with a Lua error or two as they try to talk to your addon. Again, encourage people to upgrade. It's worth it!*

**NEW FEATURE 1:** *Localization Framework has been built*

* Fonts have all been implemented for ALL languages, including support for Russian, Korean, Mandarin (Both Chinese and Taiwanese). No more "???"

* Some translations have already been implemented that I manually did on my own, just pulling from the built-in scripts. I am not going to focus on the full localization as of yet, this is more quality of life starting.

* This also resolves many issues for people using non-English clients and should provide and overall better user experience.


**NEW FEATURE 2:** *Sync'd Ban List*

* Custom Rank restriction on the Ban List. It seems like it would be prudent to allow widespread sync on general guild info, like alts and so on, but have tighter restrictions on who can modify the ban list. I personally have guild-wide sync, but officer only ban list permissions.

* Full retroactive Ban SYNC. So, new officer? They will be sync'd with up-to-date list, including all people who were banned prior to them even joining the guild, as long as someone with addon stored the info originally and sync'd the data.

* Ban List Custom UI window - shows name, rank when banned, and the date of the ban.

* Ability to remove people from ban list.

* Live frame updates, on both sync and live changes. No need to open and close window to refresh it.

* Note: the "Add" to ban list feature is not quite ready and is significantly more work than one might realize. So, until then... button will not do anything.

* So much is going on behind the scenes to get this all working together properly. A significant amount of effort had to be put into ensuring it is error free and an overall good, simple, user experience.

**QUALITY OF LIFE**

* QOL 1: Options Menu Changed a bit. A little bit cleaner, a little bit more logical, like the display options or clearLog are now always visible

* QOL 2: Buttons added to options menu slash commands that accomplish the same thing.

* QOL 3: Minor Localization progress has been made. Initially it was just down to lay a foundation for future work and to bring in proper fonts.

**BUG FIXES**

* Bug Fix1: Addon should now properly trigger a data sync shortly after joining a guild.

* Bug Fix2: OMG, WTF BLIZZ!!! Blizz just introdued a NEW bug that reintroduced "taint" on the gkick window. I have a feature where you click on an alt name and it not only opens that profile, but it opens the Guild Roster Slider to the correct position as well. Blizz just made it so manipulating the slider in the code will now block you from being able to gkick players again. WTF BLIZZ. I just don't get it. So, I am keeping the clicking on alts feature, but removing the Roster move-to positioning. Silly, silly Blizz for doing this.

* Bug Fix3: Addon will now properly register when a player joins the guild, asap. So, even if you have it set to only do a roster change scan once every 15 min, if a new player joins, the addon will register that update asap, then continue where it left off in the timer.

* Bug Fix4: Lua error could occur on occasion, often shortly after logging, in regards to the "SyncInfo" table it was populating, of all guildies with addon. This "should" be resolved now.

* Bug Fix5: And about a dozen other minor things here and there not worth mentioning...



**VERSION 7.3.0R1.099 - DATE: 10 Oct, 2017**

*Quick Bug Fix patch!!!*

* Bug Fix1: Fixed an issue if there is only 1 player online, the mouseover window will not popup again.

* Bug Fix2: Lua error could occur in certain circumstances in reference to the new guild addon user feature of last patch. Oops! no more...

* Bug Fix3: Lua error could occur in certain circumstances when syncing "alt" information. This was a coding typo. Fixed!

* Bug Fix4: Newer versions now do a better job of filter REALLY old versions of this addon, as if you didn't you could get spammed with Lua errors until guildie updated their addon.


**VERSION 7.3.0R1.098 - DATE: 9 Oct, 2017**

***NEW FEATURE:** New window that gives details on ALL players in guild that have addon installed. It tells you if sync is "ok!" with that player, and if it is not, it gives you the reason as to why, be it they have sync disabled, they are filtering out your rank, or you theirs, or even their addon is outdated and you are restricting sync of players with outdated addons (as per options). It will tell you ALL players in guild if they have addon. Furthermore, it will auto-update itself if opened, on receiving new data, like if a player logs off, it will remove them from the list, or if a player changes their sync settings/restrictions, it will update on the fly to you. All automatic!*

* Feature: Player now has the option to restrict anniversary reporting to only players listed as "main." Avoid getting spammed with all of someone's alt anniversaries too! Completely optional.

* Feature Fix: Finally, after some serious finesse and tedious finagling to try to hammer out my way around how much Blizz broke in 7.3, I finally worked out a solution on the "Shift-Click" to copy a player's name. Also, it will no longer just wipe out the whole text or chat box, it will just insert the name at the cursor. Exception is the "Add Alt" window it will clear and put in the entire name-server representation on shift-mouseover.

* Bug Fix1: Found a bug where the guild could false report that it name-changed.

* Bug Fix2: /roster clearall didn't reset the player alt auto-add feature, so if you wiped everything, it would still no longer re-add yourself and alts to a grouping on login automatically. This is fixed.


**VERSION 7.3.0R1.097 - DATE: 5 Oct, 2017**

* Feature: On mouseover, if you hold shift, it will now copy the player's name to any window the cursor is in, be it chat box, WIM, or even to add the altName rather than type it. Shift-mouseover. Of note, click is not possible due to 7.3 taint issues with anything to do with the Click() API action.

* Bug Fix1: Huge error fixed that "could" hit anyone not using the English client. It didn't in all cases, but if you had the Roster window open, and you had it set to the "Player Status" dropdown, not the "Guild Status" it could error. Fixed!

* Bug Fix2: If 2 players with same name in the guild, but different servers in merged realm, error could occur in some instances I found. This once again resolves them.


**VERSION 7.3.0R1.096 - DATE: 3 Oct, 2017**

***OPTIONS** panel has been largely redone. It's organized a little better. There is some open space, but I do have some additional options planned out to be added so I left room for them. They are just not quite ready for release.

* Feature: Slash command '/roster scan' will now trigger a one-time manual scan, even if the player has scanning disabled.

* Feature: Slash command '/roster sync' will now trigger a one-time manual sync, even if the player has sync disabled.

* Feature: Option to restrict sync only with players who have your version of the addon or higher. 

* QOL: Options menu mostly redone. Makes more sense know. Slash commands included. There is some open space atm, but to be added with future additions I have pending.

* Bug Fix1: '/roster scan' could at times fail to do anything. It should work now, unless there is no one online to sync with...

* Bug Fix2: Adding someone to list of alts could in some cases remove the "main" status of an alt. This now properly preserves alt/main grouping.

* Bug Fix3: Enhanced the code a bit, cleaned it up. Found a few misc. bugs here and there that don't need reporting now.



**VERSION 7.3.0R1.095 - DATE: 28 Sep, 2017**

* Bug Fix1: Sync bug that could cause disconnects is hopefully now resolved. TY @MCFUser175484 for helping me out in your guild to isolate this one.

* Bug Fix2: Which led to other bug fixes, like Sync Queing players was not working properly. If more than one person logged in or reloaded at the same time, it would still attempt to sync with ALL players at same time. This could cause disconnect as well.

* Bug Fix3: If the sync failed, it should retry with next person in que, but in some circumstances it was getting stuck in perpetual loop with players stuck in que not syncing.

* NOTE: Players that are in the middle of syncing that enter a loading screen the sync will fail. There is no API for another player to know that the other player is on loading screen, thus I can't que the data to wait til they are off it when sharing info. For live updating this is not an issue, but in batch sending data, the sync will fail. Just be aware.

* Yes, definitely working on some others major features, but these were just so game-breaking for some players they were necessary to fix. 



**VERSION 7.3.0R1.094 - DATE: 18 Sep, 2017**

* QOL: Mouseover added on the player status part to make it more obvious how to set notifications on status changes.

* Bug Fix1: Sync is working again. I completely broke it somehow like a coding noob! I was optimizing the sync speeds and over-confidently didn't test it apparently. I might've been half asleep.

* Bug Fix2: Promote/demote bug that could occur. It could even error out and false positive claim you changed your rank name lol. Hopefully fixed now :D


**VERSION 7.3.0R1.093 - DATE: 16 Sep, 2017**

***Main Feature:** Players will now auto-add themselves to their own alt list as they login to each of their toons. Note, you need to login to each one at least one time. The game is incapable of knowing who is your alts retroactively. Please login to each one!*

* QOL: When a player joins the guild, even if someone has it set to only scan for changes 10 min+ for example, it will still immediately build a new player profile. Note, Blizz server callback will take 15 seconds or less due to server call restrictions... It depends on when you last called the server.

* QOL: Addon now detects if a player's own rank is changed, triggering a resync if permission allows it, as rank change might open up more sync data. It also will live update your roster frames options permissions without needing to close/reopen the log window to refresh it

* QOL: Ban frames are now much cleaner post 7.3 changes that messed them up. They are closer now than ever to pre-patch 7.3.

* QOL: All UI frames are now updated on the fly for any changes. No need to close and reopen to refresh. This includes sync data received.

* Bug Fix1: Patch 7.3 broke a few things, including the way I can parse and receive data from the server. Very annoying. This reintroduced a merged-realm bug if player's had same name but different servers. This is now resolved :D

* Bug Fix2: Options button "Announce Events" was not funcitoning properly and you could not disable it, it also was not properly hiding the subsequent button to add events to calendar if disabled.

* Bug Fix3: When updating the timing interval to scan for changes, it now should properly update to new time interval immediately, not on 2nd pass.

* Bug Fix4: Code optimized a bit behind the scenes, in a few places...


**VERSION 7.3.0R1.091 - DATE: 10 Sep, 2017**

***NOTE: This sync overhaul is significant enough that you cannot sync retroactively. YOUR GUILDIES MUST UPGRADE TO LATEST VERSION TO SYNC WITH YOU!!! Recommend them to update.***

*Somewhat massive overhaul to sync system for efficiency, allowing slightly faster process. Furthermore, apparently there is a hard-cap on the number of backend server comm "prefixes" that can be used before crashing the account. This would not normally be an issue, but if the player is using a lot of addons that take up the limited use space, you could hit it, like DBM, Mythic key addons, and so on, coupled with this one, it could disconnect you on sync. I have stripped out 35 sync prefixes down to just 1 and buried the keywords as strings, and I just parse them out on receiving the sync message. A little extra processing power, albeit minimally, but will interact with the server and other addons much much better.*

* QOL: '/roster sync' will now trigger sync manually. Though it's pretty good at doing it automatically, but for whoever wants to.

* QOL: Sync start/stop notifications, even interrupted ones, are a bit more obvious now.

* QOL: On the "Add Event" window, for events, or in this case, bdays, the date is now listed in the window when you select it, before adding to the calendar.

* Bug Fix1: OMG, rank promotions/demotions screwed up the player's rank index. I had to rewrite some of the logic in recording the promotion/demotion changes due to 7.3 changes, and I had to collect the data slightly differently. Blizz is inconsistent in how it represents the ranks. Often they are represent as 0 - 9 or 1-10 (with guild leader rank index being 0 or 1). This inconsistency carries over to several API and the server and juggling them all sometimes I forget which is which. Unfortunately, I made the mistake which puts all ranks 1 index off if you change them... /clearall will fix your ranks, just make sure someone has your data to sync with em.

* Bug Fix2: Tigter sync data controls to ensure uncorrupted transfers.



**VERSION 7.3.0R1.09 - DATE: 9 Sep, 2017**

*Promote/Demote/Kick are now protected functions and an addon cannot do anything with them. As such I have integrated the built-in UI to do it. When you wish to kick or promote/demote a player, just click on their actual roster name in the list and it will hide the addon window and show Blizz's frames. Getting the "taint" to go away with patch 7.3 was brutally annoying and I had to do some rather inefficient shenannigans in the code behind the scenes to parse the data as :Click() to force a server call of the data taints the frams, sadly. At least it is working now*

* Bug Fix1: Kicking members from the guild should no longer be a problem. Due to 7.3 restrictions, it will now need to be done manually. Just click on the players and you will be able to remove them. Banning is fixed as well.

* Bug Fix2: Lua error could occur on occasion when clicking on one of the alt names.

* Bug Fix3: Sync issues could occur with players who had ranks in the guild with the exact same name. Rankindex is used in all cases now instead. I honestly didn't even know you could name ranks the exact same title.

* Bug Fix4: Problem with promote/demote I introduced last update. Newer method is more efficient and listens for chat emote event when player changes another's rank, so as not to wait for server update.

* Bug Fix5: In relation, occasionally the addon would say the incorrect person was promoting/demoting/kicking someone. This is now resolved.

* Bug Fix6: If a player was listed as a "main" and they added an alt to their list, but the alt was previously listed as main, then you would have 2xmains in a grouping. This caused interesting errors, though rarely encountered. No more!



**VERSION 7.3.0R1.087 - DATE: 6 Sep, 2017**

* Bug Fix1: I think I finally fully ironed out the gkick/ban issues due to 7.3 changes. Please let me know. I have had all my officers report it as working now, and 2 other guilds I know using it I beta tested first and they said no issues, so I HOPE we are good from here on out lol. 7.3 = #sadface

* Bug Fix2: OOPS!!! I accidentally broke reporting to you and the log if a player leaves or kicks the guild. Minor typo introduced and now fixed...

* Bug Fix3: Accidentally a word and the confirm popup window autohides in last patch! Seriously, you would not even be able to put on a BOE piece of gear. Stupid gamebreaking 1 line typo fixed lol

* Bug Fix4: A couple other misc. bugs fixed. This is a fairly minor patch as I really wanted to get this out there and fixed


**VERSION 7.3.0R1.086 - DATE: 5 Sep, 2017**
*Thank you for many suggestions and bug reporting. Keep em coming! So much to do!*

* **FEATURE:** Names on alt-list, if you click, you will jump to that alt's Roster profile window. I just want to add, this was not a simple feature to add and required a bit more behind the scenes than one would imagine. The code came out efficient and wonderful however. One of the more "fun" side projects to code.

* QOL: Scanning for changes can now be disabled if you so choose (maybe turn it off if you have bad internet connection?) - This was requested feature

* QOL: Scan for changes frequency can now be manually adjusted from the default interval of every 10 seconds.

* Bug Fix1: If adding a Friends' list Note, the roster window would hide it, making it impossible to add friend note if Guild Roster window was open. It no longer hides the note box.

* Bug Fix2: It is now vastly more reliable in stating WHO promoted/demoted/kicked a player.

* Bug Fix3: The database now instantly reports those changes when player does them without the need of waiting for scan. #Efficiency

* Bug Fix4: Fixed an annoying Lua error that could occur at times if player dies. This was a weird edge case I never noticed since I mostly just sit in a city coding than playing lol

* Bug Fix5: If player tried to disable sync before syncframes were initialized, it would error. Fixed!

* Bug Fix6: Tons of UI quality control done. Many many many behind-the-scenes stuff I won't mention here because tedious and too numerous. The point is that there is an evolution of the user experience here and progress continues to be made with this very active project.

*Final Note: I wrote 2 other custom addons I haven't released, but mainly for my own enjoyment, this past week, which distracted me a bit from pushing a new release quicker. Thank you again for all of your support and I hope that I can continue to increase the quality and build the desired features that are not currently missing. I have a HUGE list of things on my "to-do" list. It is no small project though. I am already over 12,000 lines of code for this beast, 100% built from the ground-up by myself, and the features I want to add and are in the pipeling would likely add another 5000-8000 lines more, plus not all lines of code are created equal in the amount of effort to write. Just know it's a lot of work, and since this is not my day job, just a side hobby, I can't put any realistic timetable. Just know I am working on things in a priority chain as of now.*


**VERSION 7.3.0R1.085 - DATE: 31 Aug, 2017**

*WTF!!! Blizz removed SO much more guild API functionality than I realized and broke a ton of things... These workarounds are not easy. Blizz completely broke my gkicking abilities, so I have had to hack around and get one working. This was for more of a pain than you would realize as it was not simple and straightforward like it should be. Blizz REALLY borked some stuff*

* Notice: Mass kicking a toon w/all alts is no longer possible with in-game API. Sadly, you will not be able to one-click remove a player with all their alts. This was a lovely feature, but Blizz removed the ability to use Lua or even macros to remove players. You HAVE to manually remove each one in-game from now on. Super annoying...

* Fixed gkicking and banning. Note, I don't know what Blizz did, but it seems to work like 75% of the time, not 100%. I don't know why. I haven't been able to trace why and I spent 4hrs working on it tonight. Seriously, if you gkick/ban someone, if it doesn't work the first time, try a 2nd time and it should work. It USUALLY works, but for some odd reason, Blizz's removal of API functions, using their own built-in API, it has broken something..


**VERSION 7.3.0R1.081 - DATE: 29 Aug, 2017**

*UPDATED FOR PATCH 7.3 COMPATIBILITY*

* Bug Fix1: Blizz decided to remove some backend API functionality on rank promotion/demotion. This kills many guild leader addons!!! I stitched in Blizz's default rank dropdown into the UI as API is no longer available and is protected function. Player should now be able to promote/demote players again.


**VERSION 7.3.0R1.08 - DATE: 29 Aug, 2017**

*UPDATED FOR PATCH 7.3 COMPATIBILITY*

* Note: Oddly, Blizz changed GuildControlSetRank() API function to now a protected function. Not sure why, but it limits ability to pull info on guild rank restrictions and so on... Minor issue, but could potentially cause issues for guilds who have a rank with guild chat restricted. Prob rare case usage.

* Bug Fix1: Error could occur in some cases when parsing through the guild event log to find out WHO did promotions/demotions and so on if server did not provide full info. 


**VERSION 7.2.5R1.075 - DATE: 27 Aug, 2017**

* Bug Fix1: Sync issue that could cause, in certain cases, sync to indefinitely loop and never complete. You'd get all join/promo sync fine, but it would only sync the first 50 alt changes lol OOPS!


**VERSION 7.2.5R1.071 - DATE: 25 Aug, 2017**

* QoL: Options now greyed out and unchecked if player does not have rank access to them.

* Bug Fix1: If a player did not have access to being able to add events to calendar, it would cause an error.

* Bug Fix2: HUGE issue that would cause certain servers with odd names (like Area52), to not sync properly. Works now!

* Bug Fix3: A couple behind-the-scenes fixes that smooth a couple of reported issues out. Complicated so I won't go into much detail here.



**VERSION 7.2.5R1.062 - DATE: 24 Aug, 2017**

***Note** - This is a quick, minor update to fix something real fast. I have other things I am working on, but this is so annoying I decided I wanted to get it out right away*

* Bug Fix1: Quick fix on shift-click names to add as alts. I typo'd a line and it was previously closing window than adding name



**VERSION 7.2.5R1.06 - DATE: 21 Aug, 2017**

*Note: R1.05 was a very small closed beta with a few people, so will be skipped here*

* FEATURE: Notifications! Player can right-click the "status" of player, like AFK, and set notification when no longer

* FEATURE: Player can set to be notified when players login or logoff (more noticeable than Blizz default one)

* FEATURE: Unlimited number of players can be monitored. Of note, they are wiped on each relog, not permanent.

* QOL: Version Check Incorporated. This is not backwards compatible with older version, but from R1.06 and on, player will receive notification if they have outdated addon if others in guild have newer version

* QOL: All future addon users, SYNC is now on by default (though ranks will need to be opened for more than GL)

* Bug Fix1: Addon now takes into consideration guilds with disciplinary ranks that restrict guild chat. This is critical as it can destroy comms and this will resolve a couple of odd bugs.

* Bug Fix2: On rank changes, the addon now takes into consideration rank pre-reqs, like having authenticator and does not attempt to change rank if server will not yet allow.




**VERSION 7.2.5R1.04 - DATE: 15 Aug, 2017**

* QOL: Players full name w/server now viewable on mouseover

* QOL: Name w/server mouseover on alts lits too!

* QOL: ALT CAP REMOVED!!!

* QOL: Player's with more than 12 alts now will have a scrollable alt window!

* QOL: Sync now states when it completes

* Bug Fix1: REMOVE button no longer shows on players of equal or higher rank

* Bug Fix2: Fixed UI bug where it shows promotion/demotion changes, even if player cannot.

* Bug Fix3: Adding event to calendar, description date previously was showing current date, not event date.

* Bug Fix4: Lua error could occur from other addons sharing guild comm channel. Now filters properly.

* Bug Fix5: Shift-clicking roster name now properly places player name where cursor is, not wiping all.


**VERSION 7.2.5R1.03 - DATE: 6 Aug, 2017**

* Bug Fix1: Shift-clicking roster names was wonky on adding alt. It works properly now.

* Bug Fix2: Mousing over names, then shift click if no editbox was focus would cause a Lua error.

* Bug Fix3: Issue where wrong player being selected invisibly in the background, but UI showed proper, thus

* Bug Fix3: behind the scenes it was pulling mismatched data from server on mouseover player at times. No more!

* Bug Fix4: Join Date could get overwritten on new player joining, thus rewriting join date for SYNC as current date

* Bug Fix4: rather than the date they actually joined, or when another player said they joined. This should sync the

* Bug Fix4: the data properly now and not override the correct info.

* Bug Fix5: On a player joining the guild, you could get this error where it would add an officer note as joined on current date, then it would overwrite

* Bug Fix5: it as it pulled the real officer note and spam the log as if it were a change. This annoyingly did it on all new joins

* Bug Fix5: if the player logged in at any date AFTER the player joined originally, if the officer note was tagged. How annoyingly spammy! Fixed

* Bug Fix6: Fixed a Width issue on the Year date on drop-down select that should no longer be an issue for people using non-widescreen resolutions.

* Bug Fix7: Sync on large guilds will now be a bit slower, but it seems it was spamming and disconnecting people even at the previous throttled rate

* Bug Fix7: The new Throttle rate is literally 25% the speed of the previous sync rate. Fortunately it all happens in the background so its not noticeable, just be 

* Bug Fix7: aware Sync will not update within seconds on LARGE guilds, but actually, a couple of minutes to prevent disconnect due to Blizz comm limits.

* Bug Fix7: Please report back if disconnects are gone. ALL in your guild will need to upgrade to current version to prevent disconnects.


**VERSION 7.2.5R1.02 - DATE: 24 July, 2017**

* Bug Fix1: Dynamic and retroactive sync did not work on any realm that had more than one word in the name, like "Burning Legion" or "Area 52"

* Bug Fix1: Never noticed string handling on comms since I tested on single word realm.

* Bug Fix2: Syncing could crash on MEGA guilds! In my 250+ guild, I never noticed any disconnects, but in larger guilds, too much data would be sent 

* Bug Fix2: across the server and would disconnect the player. Now, based on amount of info/size of guild, data packet is controlled to prevent disconnect.

* Bug Fix2: For some larger guilds, sync may no longer take 2-3 seconds for larger guilds. 500 to 1000 member guilds will take anywhere from 15-40 seconds, depending on 

* Bug Fix2: how much alt data needs to sync too. I want to speed it up, but Blizz has internel limits to prevent server spamming. Don't worry, it all happens in background.

* QOL:	Shift-Click player name in the roster and it will add it to anywhere your cursor has focus. It is universally compatible with any frame or addon.


**VERSION 7.2.5R1.00 - DATE: 21 July, 2017**

* Bug Fix1: If a promotion/Demotion was made, there would be a delay on register, which could cause an error when trying to populate the Rank promotion history

* Bug Fix1: Promotions and Demotions now a registered immediately!

* Bug Fix2: Noticed an issue where you could get double spam on reporting changes of public/officer note. This is resolved.

* QOL: Some minor behind-the-scenes tweaking lowered the fingerprint in a couple places. Extremely minimal.


**VERSION 7.2.5Beta_5_R1 - DATE: 20 July, 2017**

* **FEATURE:** SYNCING!!! Seriously, this addon will not sync the player data on rank, promotions, alts/main, and so on, both live and retroactively

*As a quick side note, this was NOT an easy job. Building a resource sensitive dynamic syncing algorithm in Lua, that could retroactively sync changes with guildies, be them online or not at the time was an enormous job. I actually didn't want to do it at first because I saw the scope of the task at hand and didn't want to do it. But, I did it... I think it was worth it!*

* Tons of updates, fixes, QoL features included, many minor, some big. Since this is a massive huge release, let's just consider it a fresh start from here!



**VERSION 7.2.5b500 - DATE: 19 Jun, 2017**

* **FEATURE:** Player zone is now displayed in playerwindow, along with the time duration they have been in the zone. Of note, the player cannot know how long they were in that zone prior to logging, so the time is reset upon logging, but from there on, any zone changes are automatically swept up with timer started for each online player. I am finding it extremely useful for things like not having to ask a player if they just got into that BG, or shouting out when they are in a long arena match, and so on.

* QOL: Fixed some text scaling issues. Ooo, ugly text on some machines. Normalizes all to same static font. Should not be weird now. Let me know if I missed any!

* QOL: Code Cleaned up a little more in a couple of places, which makes it even leaner with less server calls.

* QOL: Wrote some new methods for checking how much time has elapsed from given event, both from epoch time, and from a string timestamp. Much cleaner reporting now.

* QOL: Rearranged the positioning of the Day/Month dropdown as I think it makes more sense to have the month first.

* Bug Fix1: Issue with "mobile" players using armory app, it would screw up alt management. Text name parsed correctly from mobile icon now.

* Bug Fix2: Addon could fail in some circumstances if a player quit the guild and was linked as an alt. Not anymore!



**VERSION 7.2.5b450 - DATE: 19 Jun, 2017**

*Lots of misc. quality of life fixes here. Went through a few requests and got them added, and also worked a little more on the backend on a few things I am working on in a future update.

* Feature: On Mouseover of promotion date, it now includes "how long" a player has been at the promoted rank.

* QOL: Tooltips are now scaled down a little. They were almost obnoxiously large, imo.

* QOL: Note and officer note boxes are better designed. Word wrapping/spacing/etc... Just better

* Bug Fix1: Serious issue with timestamps I had not noticed, as server time was my local time. Apparently I was pulling local, not server, and not realizing it. This could cause issues with people playing in different time-zones than server time... potentially. Resolved

* Bug Fix2: Some issues related to the timstamp problem had to be resolved.

* Bug FixX: There was actually a LOT of behind-the-scenes labor on this one. Much more than you would realized, but there were just so many "little" things not worth mentioning here, but minor QoL stuff I made sure was taken care of.


**VERSION 7.2.5b410 - DATE: 18 Jun, 2017**

* BUG FIX!!! If a player was returning from inactity, I typo'd a bug, but didn't notice it until I was put under the circumstance of a guildie inactive returning. TY @k1ck3r for poinint this out!


**VERSION 7.2.5b400 - DATE: 17 Jun, 2017**

* TONS of work went into this update, even if on the front end the additions seem minimal. In the long run, it will have been worth it for you guys, but also for me as a developer. I won't get into it more. Just know that the x-realm solution was not as easy as I'd hoped because I had to dig into all of my frames and change the approach to how I pulled data. The good thing is it gave me the opportunity to go back and refactor much of my code and it is significantly more efficient now! One downside is your alt/main data needed to be reset. Sorry!*

* **MAJOR FEATURE:** The addon is now compatible with x-realm guilds and should successfully be able to handle multiple people of the same name in a guild, but of different servers. This was a surprisingly HUGE amount of work, even though the solution seemed rather simple. Please let me know if it is working. You MAY need to do a '/roster clearall' and reset your data if you are in a x-realm guild, but I am hoping the addon just sees it as a new person joining the guild. Please let me know how it works as I have not tested it.

*Additionally...*

* Feature: Chat message filtering options now provided for all events.

* Feature: Example, you can now disable leveling notifications to the chat window.

* QOL: Options Panel now opens and closes in a significantly better, and faster, transition

* QOL: Mousing over the roster at times felt a little "sluggish." I sped it up a little.

* QOL: The position you place the Roster Event Log is now saved between sessions.

* QOL: '/roster reset' will reset the window back to its original, centered position.

* QOL: Some text styling has changed, like "PROMOTED" is now "Promoted" and so on...

* Bug Fix1: Log events tracking now should ONLY trigger when updated from the server.

* Bug Fix1: Before, it could do a check before server returned data, thus you would get generic message rather than full details on who did what.

* Bug Fix2: "Clearing" the Rank Promotion history, the "Date Promoted?" button was not returning to proper position.

* Bug Fix3: "Guild Log" button will now seat properly if frame is dragged over it.

* Bug Fix4: Demoting from Main to alt would bug out due to a code typo I introduced last patch and didn't notice. FIXED


**VERSION 7.2.5b300 - DATE: 15 Jun, 2017**

*There was some confusion that was 100% my fault. This IS a BETA release. I mistakenly set it as release. I apologize for that rather serious distinction. As such, it should be noted that THIS IS A MASSIVE RELEASE! HUGE UPDATES!!! Sadly, due to major overhaul of data management and data merging techniques, far more efficient now, it was not backwards compatible. SO SORRY!*

* **MAJOR FEATURE:** Guild data is now stored per faction, and per guild. Are you in a guild that has the same name on both Alliance and Horde side? This should no longer have any issues... Seemless loading as you hop between toons and guilds and factions.


* Bug fix1: Officer Note Editbox was broken last patch. OOPS! Re-fixed

* Bug fix2: Fixed error that *could* happen if player loads addon not in guild, but then joins one. Caused various weird problems. FIXED

* Bug fix3: Namechange detection could error and report incorrectly under various conditions. Tightened to 100% detection.

* Bug fix4: Officer note change spam fixed! Such an annoying bug! Sorry about that one!

* Bug fix5: No merge merge issues!

* QOL: Slash command '/roster' should now open your Log window Properly

* QOL: Grey out options that do not pertain to player if they do not have permissions.

* QOL: Proper error message if player tries to add invalid alt name.

* QOL: Add Event Frame now updates live if events trigger and window is open

* MISC1: Player now can see if a player is on the mobile chat with "Is Mobile" indication

* MISC2: Add Event Calendar now restricts the player to adding 1 event to calendar per 5 seconds, due to internal Blizz server limit.

* MISC3: Several more things being tracked in the background... to be implemented in future patch 

* MISC4: And several other minor things not worth mentioning...


**VERSION 1.02 - DATE: 13 Jun, 2017**

* Feature1: You can now right click player name in main window for additional options

* Feature2: You can now reset an individual's saved data, if needed.

* Feature3: Better main/alt management - ability to set player as main, even without alts

* Feature3: This allows any subsequent alts added to auto-be tagged as "alt" instad of main. Minor QoL.

* Bug fix1: TAINT issues have been resolved (by building my own Dropdowns) - HUGE JOB

* Buf fix1: You no longer should be unable to enter a BG without disabling addon, for example!

* Bug fix2: Scaling issue (yes, not ALL scaling issues are resolved yet)

**VERSION: 1.01 - DATE: 11 Jun, 2017**

* Bug fix: On player namechange detection, it now changes the name in the alts lists as well!


**VERSION: 1.00 - DATE: 11 Jun, 2017**

* Initial Release