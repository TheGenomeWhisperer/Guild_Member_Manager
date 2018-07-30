
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

GRML.Italian = function()

    GRM_L["Guild"] = "Gilda"

    -- PLAYER MAIN ROSTER DETAILS WINDOW
		GRM_L["Level: "] = "Livello: "
		GRM_L["Level"] = "Livello"
	    GRM_L["Note:"] = "Nota:"
	    GRM_L["Note"] = "Nota"
	    GRM_L["Officer's Note:"] = "Nota degli ufficiali:"
	    GRM_L["Officer's Note"] = "Nota degli ufficiali"
	    GRM_L["Zone:"] = "Zona:"
	    GRM_L["(main)"] = "(main)"
	    GRM_L["( Main )"] = "( Main )"                               -- Context: This one is used on player data window, the other is smaller used in the alts list...
	    GRM_L["Set as Main"] = "Imposta come Main"
	    GRM_L["Set as Alt"] = "Imposta come Alt"
	    GRM_L["Remove"] = "Rimuovi"
	    GRM_L["Please Type the Name of the alt"] = "Per favore, scrivi il nome dell'Alt"
	    GRM_L["Promoted:"] = "Promosso il:"
	    GRM_L["Unknown"] = "Sconosciuta"                                                                 -- Context: The date of their promotion is "Unknown"
	    GRM_L["Click here to set a Public Note"] = "Clicca per impostare una Nota Pubblica"
	    GRM_L["Unable to Edit Public Note at Rank"] = "Grado troppo basso per modificare una Nota Pubblica"
	    GRM_L["Click here to set an Officer's Note"] = "Clicca per impostare una Nota Ufficiali"
	    GRM_L["Unable to Edit Officer Note at Rank"] = "Grado troppo basso per modificare una Nota degli Ufficiali"
	    GRM_L["Unable to View Officer Note at Rank"] = "Grado troppo basso per visualizzare una Nota degli Ufficiali"
	    GRM_L["Online"] = "Online"
	    GRM_L["( Active )"] = "( Attivo )"                       -- I included the parentheses here as I am not sure if any languages abstain from them, or use other notation. Feel free to remove if necessary
	    GRM_L["( AFK )"] = "( AFK )"
	    GRM_L["( Busy )"] = "( Occupato )"
	    GRM_L["( Mobile )"] = "( Chat Remota )"
	    GRM_L["( Offline )"] = "( Offline )"
	    GRM_L["Set Join Date"] = "Imposta data di entrata"
	    GRM_L["Edit Promo Date"] = "Imposta data promozione"
	    GRM_L["Edit Join Date"] = "Modifica data di entrata"
	    GRM_L["Set Promo Date"] = "Modifica data promozione"
	    GRM_L["In Group"] = "In gruppo"                            -- Context: "Player is already In Group with you"
	    GRM_L["Group Invite"] = "Invita in gruppo"
	    GRM_L["No Invite"] = "Nessun invito"
	    GRM_L["Group Invite"] = "Invita in gruppo"
	    GRM_L["Date Promoted?"] = "Data promozione?"
	    GRM_L["Last Online"] = "Ultimo accesso"
	    GRM_L["Time In:"] = "Da:"                            -- Context: "Time In" the current zone...
	    GRM_L["Date Joined"] = "Data entrata"
	    GRM_L["Join Date?"] = "Data di entrata?"
	    GRM_L["Player Was Previously Banned!"] = "Giocatore Bannato precedentemente!" --WIP
	    GRM_L["Ignore Ban"] = "Ignora Ban"
	    GRM_L["Player Alts"] = "Alt del Giocatore"
	    GRM_L["Add Alt"] = "Aggiungi Alt"
	    GRM_L["Choose Alt"] = "Scegli Alt"
	    GRM_L["(Press Tab)"] = "(Premi Tab)"
	    GRM_L["Shift-Mouseover Name On Roster Also Works"] = "Puoi anche usare Shift-Mouseover sul nome nell'elenco" --WIP
	    GRM_L["Guild Log"] = "Registro di Gilda"
    --

    -- TOOLTIPS
	    GRM_L["Rank History"] = "Cronologia Gradi" 
	    GRM_L["Time at Rank:"] = "Questo Grado da:" --WIP
	    GRM_L["Right-Click to Edit"] = "Click destro per modificare"
	    GRM_L["Left Guild"] = "Ha lasciato la Gilda"
	    GRM_L["Membership History"] = "Cronologia del giocatore"
	    GRM_L["Joined:"] = "Joined:"                             -- as in "Joined" the guild      --WIP
	    GRM_L["Joined"] = "È Entrato"
	    GRM_L["Left:"] = "Ha Lasciato:"                               -- as in, "Left" the guild
	    GRM_L["Rejoined:"] = "È Rientrato:"                           -- as in, "Rejoined" the guild
	    GRM_L["Reset Data!"] = "Resetta Dati!"
	    GRM_L["Notify When Player is Active"] = "Notifica quando il giocatore è attivo"
	    GRM_L["Notify When Player Goes Offline"] = "Notifica quando il giocare diventa Offline"
	    GRM_L["Notify When Player Comes Online"] = "Notifica quando il giocatore diventa Online"
	    GRM_L["Edit Date"] = "Data Modifica" -- Or "Mofidica Data"? Like in "Edit this date" or in "this date have been edited Mar 20"
	    GRM_L["Clear History"] = "Cancella Cronologia"
	    GRM_L["Options"] = "Opzioni" --"Impostazioni"
	    GRM_L["Cancel"] = "Annulla"
    -- 

    -- LOG
	    GRM_L["LOG"] = "REGISTRO"                                                     -- Context - The guild Log shorthand for the tab
	    GRM_L["Guild Roster Event Log"] = "Registro Eventi"
	    GRM_L["Clear Log"] = "Pulisci Registro" -- Maybe "Cancella registro" is better?
	    GRM_L["Really Clear the Guild Log?"] = "Vuoi davvero cancellare il Registro di Gilda?"
	    GRM_L["{name} DEMOTED {name2}"] = "{name} RETROCESSO a {name2}"
	    GRM_L["{name} PROMOTED {name2}"] = "{name} PROMOSSO a {name2}"
	    GRM_L["{name} KICKED {name2} from the Guild!"] = "{name} ha RIMOSSO {name2} dalla Gilda!"
	    GRM_L["kicked"] = "rimosso"
	    GRM_L["{name} has Left the guild"] = "{name} ha lasciato la Gilda"
	    GRM_L["{name} INVITED {name2} to the guild."] = "{name} ha invitato {name2} nella Gilda"
	    GRM_L["{name} has BANNED {name2} and all linked alts from the guild!"] = "{name} ha bannato {name2} e tutti gli Alt collegati dalla Gilda!"
	    GRM_L["{name} has BANNED {name2} from the guild!"] = "{name} ha bannato {name2} dalla gilda!"
	    GRM_L["Reason Banned:"] = "Bannato per:"
	    GRM_L["has Left the guild"] = "ha lasciato la gilda"                                      -- Context: PlayerName "has left the guild"
	    GRM_L["ALTS IN GUILD:"] = "ALT IN GILDA"                                          -- Context: This appears If a person leaves the guild and there are still alts in the guild. It is like - "ALTS IN GUILD: Arkaan, Chris, Matt, and 4 others.""
	    GRM_L["Player no longer on Server"] = "Giocatore non più sul server"
	    GRM_L["{name} PROMOTED {name2} from {custom1} to {custom2}"] = "{name} ha PROMOSSO {name2} da {custom1} a {custom2}"
	    GRM_L["{name} has been PROMOTED from {custom1} to {custom2}"] = "{name}è stato PROMOSSO da {custom1} a {custom2}"
	    GRM_L["{name} DEMOTED {name2} from {custom1} to {custom2}"] = "{name} ha RETROCESSO {name2} da {custom1} a {custom2}"
	    GRM_L["{name} has been DEMOTED from {custom1} to {custom2}"] = "{name}è stato RETROCESSO da {custom1} a {custom2}"
	    GRM_L["(+ {num} More)"] = "e altri {num}"                                          -- Context: Referencing num of alts if player leaves guild, that are stil in it. Example "ALTS IN GUILD: Christ, Matt, Sarah (and 4 more)"
	    GRM_L["{name} has Been in the Guild {num} Times Before"] = "{name} è stato in gilda {num} volte"
	    GRM_L["{name} is Returning for the First Time."] = "{name} è rientrato in gilda per la prima volta"
	    GRM_L["None Given"] = "Nessuna"                                              -- Context: No reason given for player ban. This is displayed when a player was banned, but the addon users did not input a reason why.
	    GRM_L["WARNING!"] = "ATTENZIONE!"                                                -- Context: WARNING - banned player rejoined the guild!
	    GRM_L["{name} REJOINED the guild but was previously BANNED!"] = "{name} è rientrato in gilda dopo essere stato bannato!"
	    GRM_L["(Invited by: {name})"] = "(Invitato da: {name})"
	    GRM_L["Invited By: {name}"] = "Invitato da: {name}"
	    GRM_L["Date of Ban:"] = "Bannato il:"
	    GRM_L["Date Originally Joined:"] = "Data Originale di entrata" 
	    GRM_L["Old Guild Rank:"] = "Vecchio Grado:"
	    GRM_L["Reason:"] = "Motivo:"
	    GRM_L["Additional Notes:"] = "Note aggiuntive:"
	    GRM_L["{name} has REINVITED {name2} to the guild"] = "{name} ha reinvitato {name2} in gilda"
	    GRM_L["(LVL: {num})"] = "(LVL: {num})"						                                     -- Context: LVL means Player Level - so Ex: (LVL: 110)
	    GRM_L["{name} has REJOINED the guild"] = "{name} è rientrato in gilda"
	    GRM_L["{name} has JOINED the guild!"] = "{name} si è unito alla gilda!"
	    GRM_L["Date Left:"] = "Data di uscita:"
	    GRM_L["{name} has Leveled to {num}"] = "{name} è salito al {num}"
	    GRM_L["Leveled to"] = "Salito al"                                             -- For parsing the message, please include the string found in previous "has leveled to" message
	    GRM_L["(+{num} levels)"] = "(+{num} livelli)"                                        -- Context: Person gained more than one level, hence the plural
	    GRM_L["(+{num} level)"] = "(+{num} livello)"                                          -- Context: Person gains a level, just one level.
	    GRM_L["{name}'s PUBLIC Note: \"{custom1}\" was Added"] = "Nota Pubblica \"{custom1}\" per {name} aggiunta"          -- Of note, the \" in the text here will just appear as " in-game. The \" notation is telling the program not to end the string, but to include quotation
	    GRM_L["{name}'s PUBLIC Note: \"{custom1}\" was Removed"] = "Nota Pubblica \"{custom1}\" di {name} rimossa"
	    GRM_L["{name}'s PUBLIC Note: \"{custom1}\" to \"{custom2}\""] = "Nota Pubblica di {name} cambiata da \"{custom1}\" a \"{custom2}\""   -- Context: "Arkaan's PUBLIC Note: "ilvl 920" to "Beast Mode ilvl 960""  -- Changing of the note. custom1 = old note, custom2 = new note
	    GRM_L["{name}'s OFFICER Note: \"{custom1}\" was Added"] = "Nota degli Ufficiali \"{custom1}\" per {name} aggiunta"
	    GRM_L["{name}'s OFFICER Note: \"{custom1}\" was Removed"] = "Nota degli Ufficiali \"{custom1}\" di {name} rimossa"
	    GRM_L["{name}'s OFFICER Note: \"{custom1}\" to \"{custom2}\""] = "Nota degli Ufficiali di {name} cambiata da \"{custom1}\" a \"{custom2}\"" 
	    GRM_L["Guild Rank Renamed from {custom1} to {custom2}"] = "Grado di gilda rinominato da {custom1} a {custom2}"
	    GRM_L["{name} has Name-Changed to {name2}"] = "{name} ha cambiato nome in {name2}"
	    GRM_L["{name} has Come ONLINE after being INACTIVE for {num}"] = "{name} è tornato Online dopo essere stato Inattivo per {num}"
	    GRM_L["{name } Seems to Have Name-Changed, but their New Name was Hard to Determine"] = "Sembra che {name} abbia cambiato nome, ma il nuovo nome è difficile da determinare"
	    GRM_L["It Could Be One of the Following:"] = "Potrebbe essere uno/a dei/delle seguenti:"
	    GRM_L["{name} has been OFFLINE for {num}. Kick Recommended!"] = "{name} è Offline da {num}. Consigliata Rimozione dalla Gilda"
	    GRM_L["({num} ago)"] = "({num} fa)"                                              -- Context: (5 minutes ago) or (5 months 24 days ago) -- the {num} will automatically include the time-passed date.
	    GRM_L["{name}'s Guild has Name-Changed to \"{name2}\""] = "Il nome della Gilda è stato cambiato da {name} a \"{name2}\""
	    GRM_L["{name} will be celebrating {num} year in the Guild! ( {custom1} )"] = "{name} celebrerà {num} anno in Gilda! ( {custom1} )"            -- {custom1} will reference the DATE. Ex: "Arkaan will be celebrating 1 year in the Guild! ( 1 May )" - SINGULAR
	    GRM_L["{name} will be celebrating {num} years in the Guild! ( {custom1} )"] = "{name} celebrerà {num} anni in Gilda! ( {custom1} )"           -- Same thing but PLURAL - "years" in stead of "year"
	    GRM_L["Promotions"] = "Promozioni"
	    GRM_L["Demotions"] = "Retrocessioni"
    --

    -- EVENTS WINDOW
	    GRM_L["EVENTS"] = "EVENTI"                                         -- Events tab
	    GRM_L["{name}'s Anniversary!"] = "Anneversario di {name}!"
	    GRM_L["{name}'s Birthday!"] = "Compleanno di {name}!"
	    GRM_L["Please Select Event to Add to Calendar"] = "Per favore seleziona un Evento da aggiungere al Calendario"
	    GRM_L["No Calendar Events to Add"] = "Nessun Evento da aggiungere"
	    GRM_L["Event Calendar Manager"] = "Gestore del Calendario"
	    GRM_L["Event:"] = "Evento:"
	    GRM_L["Description:"] = "Descrizione:"
	    GRM_L["Add to\nCalendar"] = "Aggiungi al\nCalendario"
	    GRM_L["Ignore Event"] = "Ignora\nEvento"
	    GRM_L["No Player Event Has Been Selected"] = "Nessun evento relativo a un giocatore è stato selezionato"  --WIP
	    GRM_L["Event Added to Calendar: {custom1}"] = "Evento aggiunto al Calendario: {custom1}"              -- Custom1 = the title of the event, like "Arkaan's Anniversary"
	    GRM_L["Please Select Event to Add to Calendar"] = "Per favore, seleziona un Evento da aggiungere al Calendario"
	    GRM_L["No Calendar Events to Add"] = "Nessun Evento da aggiungere"
	    GRM_L["{name}'s event has already been added to the calendar!"] = "L'evento di {name} è già stato aggiunto al Calendario!"
	    GRM_L["Please wait {num} more seconds to Add Event to the Calendar!"] = "Per favore, aspetta altri {num} per aggiungere l'Evento al Calendario"
	    GRM_L["{name}'s Event Removed From the Que!"] = "Evento di {name} rimosso dall'elenco"
	    GRM_L["Full Description:"] = "Descirzione Completa"
    --

    -- BAN WINDOW
	    GRM_L["BAN LIST"] = "LISTA BAN"                                        -- Ban List Tab
	    GRM_L["Reason Banned?"] = "Bannato per?:"
	    GRM_L["Click \"YES\" When Done"] = "Clicca \"SÌ\" quando hai fatto"                         -- Of note, the \" is how you notate for quotations to actually appear. Adjust as needed
	    GRM_L["Select a Player"] = "Seleziona un Giocatore"
	    GRM_L["Player Selected"] = "Giocatore selezionato"
	    GRM_L["{name}(Still in Guild)"] = "{name}(è ancora in Gilda)"
	    GRM_L["No Ban Reason Given"] = "Nessuna motivazione data per il Ban"
	    GRM_L["Reason:"] = "Motivo:"                                         -- Context: As in, "Reason Banned"
	    GRM_L["Total Banned:"] = "Totale Bannati:"
	    GRM_L["Rank"] = "Grado"
	    GRM_L["Ban Date"] = "Data Ban"
	    GRM_L["No Players Have Been Banned from Your Guild"] = "Nessun giocatore è stato Bannato dalla Gilda"
	    GRM_L["Remove Ban"] = "Rimuovi Ban"
	    GRM_L["Add Player to Ban List"] = "Aggiungi il giocatore alla Lista Ban"
	    GRM_L["Server:"] = "Reame:"    -- CONTROLLARE
	    GRM_L["Class:"] = "Classe:"
	    GRM_L["Reason:"] = "Motivo:"
	    GRM_L["It is CRITICAL the player's name and server are spelled correctly for accurate tracking and notifications."] = "È CRUCIALE che il nome del giocatore e del server siano scritti correttamente per un tracciamento accurato e per le notifiche."
	    GRM_L["Submit Ban"] = "Conferma Ban"
	    GRM_L["Confirm"] = "Conferma"
	    GRM_L["Cancel"] = "Annulla"
	    GRM_L["Add"] = "Aggiungi"                                         -- Context: "Add" player to ban list
	    GRM_L["Confirm Ban for the Following Player?"] = "Confermi il Ban per il seguente Giocatore?"
	    GRM_L["Please Enter a Valid Player Name"] = "Per favore, inserisci un nome giocatore valido"            -- Player Name
	    GRM_L["Please Enter a Valid Server Name"] = "Per favore, inserisci un nome di un server valido"            -- Server Name
	    GRM_L["Please Select a Player to Unban!"] = "Per favore, seleziona il giocatore da sbannare"
	    GRM_L["{name} - Ban List"] = "{name} - Lista Ban"                          -- Context: "GuildName - Ban List"
	    GRM_L["No Reason Given"] = "Nessuna motivazione"
    --

    -- ADDON USERS WINDOW
	    GRM_L["SYNC USERS"] = "SINCRONIZZA"
	    GRM_L["Ok!"] = "Ok!"
	    GRM_L["Their Rank too Low"] = "Ha un Grado troppo basso"
	    GRM_L["Your Rank too Low"] = "Il tuo Grado è troppo basso"
	    GRM_L["Outdated Version"] = "Versione troppo vecchia"
	    GRM_L["You Need Updated Version"] = "Hai bisogno di una versione aggiornata"
	    GRM_L["Player Sync Disabled"] = "Sincronizzazione con gli altri giocatori disabilitata"
	    GRM_L["No Guildie Online With Addon."] = "Nessun gildano Online ha questo Add-on"
	    GRM_L["ONE Person is Online. Recommend It!"] = "UNA persona è Online. Raccomandalo!"
	    GRM_L["{num} others are Online! Recommend It!"] = "{num} persone sono Online. Consiglia di installare questo add-on!"
	    GRM_L["GRM Sync Info"] = "Informazioni di Sincronizzazione"
	    GRM_L["Ver: {custom1}"] = "Ver: {custom1}"                                  -- Context:  Ver: R1.125  - Ver is short for Version
	    GRM_L["Name:"] = "Nome:"
	    GRM_L["Version"] = "Versione:"
	    GRM_L["Sync"] = "Sincronizzazione"	
	    GRM_L["Your Sync is Currently Disabled"] = "La Sincronizzazione è disabilitata"
    --

    -- OPTIONS WINDOW
	    GRM_L["Add Join Date to:  |cffff0000Officer Note|r"] = "Aggiungi la data di entrata a:  |cffff0000Nota Ufficiali|r"         -- Context: Please keep |cffff0000 for color coding of the text, and the |r to signify the end of color change
	    GRM_L["Add Join Date to:  Officer Note"] = "Aggiungi la data di entrata a: Nota Ufficiali"
	    GRM_L["Public Note"] = "Nota Pubblica"
	    GRM_L["Scanning Roster:"] = "Scansione Elenco:"
	    GRM_L["Guild Rank Restricted:"] = "Impostazioni limitate dal grado:" --WIP
	    GRM_L["Sync:"] = "Sincronizzazione:"
	    -- Options window -- of note, these are very concise statements. They may need to be adjusted properly in the Options window for proper spacing, so verify they look ok after translating.
	    GRM_L["Slash Commands"] = "Comandi da chat"
	    GRM_L["Trigger scan for changes manually"] = "Attiva manualmente la scansione per trovare cambiamenti"
	    GRM_L["Trigger sync one time manually"] = "Attiva manualmente una singola sincronizzazione"
	    GRM_L["Centers all Windows"] = "Centra tutte le finestre"
	    GRM_L["Slash command info"] = "Informazioni sui comandi da chat"
	    GRM_L["Resets ALL data"] = "Resetta tutti i dati"
	    GRM_L["Report addon ver"] = "Riporta la versione dell'add-on"                                    -- Ver is short for Version
	    GRM_L["Resets Guild data"] = "Resetta i dati della Gilda"
	    GRM_L["Show at Logon"] = "Mostra all'avvio"
	    GRM_L["Only Show if Log Changes"] = "Mostra Solo se ci sono cambiamenti nel Registro"

    	-- This do need to be translated still
	    GRM_L["Before Scan Timer"] = "Controlla cambiamenti ogni"     -- Context: "Scan for Changes Every 10 Seconds" -- There will be a number added here and may require custom positioning, so please provide full statement and Arkaan will allign
	    GRM_L["After Scan Timer"] = "Secondi"    --"Seconds"
	    GRM_L["Before Inactive Timer"] = "Notifica il ritorno di un Inattivo se è stato Offline per almeno"--"Report Inactive Return if Player Offline"
	    GRM_L["After Inactive Timer"] = "Giorni"  --"Days"

	    GRM_L["Reactivating SCAN for Guild Member Changes..."] = "Riattivazione Scannerizzazione dei cambiamenti nei membri di gilda"	--WIP
	    GRM_L["Deactivating SCAN of Guild Member Changes..."] = "Disattivazione Scannerizzazione dei cambiamenti nei membri di gilda"	--WIP
	    GRM_L["Due to server data restrictions, a scan interval must be at least 10 seconds or more!"] = "A causa di restrizioni del server, l'intervallo di scannerizzazione deve essere almeno 10 secondi!"
	    GRM_L["Please choose an scan interval 10 seconds or higher!"] = "Per favore, scegli un intervallo di 10 secondi o più!"
	    GRM_L["{num} is too Low!"] = "{num} è troppo basso!"
	    GRM_L["The Current Lvl Cap is {num}."] = "L'attuale livello massimo è {num}"
	    GRM_L["Kick Inactive Player Reminder at"] = "Promemoria rimozione giocatori inattivi dopo"        -- Context: "Kick Inactive Player Reminder at X Months" - Again, allignment will need to be adjusted for options UI, so please post
	    GRM_L["Please choose a month between 1 and 99"] = "Per favore scegli un mese tra 1 e 99" 
	    GRM_L["Sync BAN List With Guildies at Rank"] = "Sincronizza la Lista Ban solo con gildani"     -- Context: "Sync Ban List with Guildies at Rank [DROPDOWNMENU OF RANKS] or Higher" - Please show where dropdown menu should be pinned
	    GRM_L["or Higher"] = "o più alto"                               -- Context: Look at the above statement. Show where this needs to go in regards to dropdown menu of rank selection in Options
	    GRM_L["Restore Defaults"] = "Predefinito"
	    GRM_L["Please choose between 1 and 180 days!"] = "Per favore, scegli tra 1 e 180 giorni!"
	    GRM_L["Announce Events"] = "Annuncia gli Eventi con"                         -- Context: "Announce Events X number of days in advance" -- the X is the editbox to modify number of days. Please include the location of where to pin that.
	    GRM_L["Days in Advance"] = "Giorni in anticipo"
	    GRM_L["Please choose between 1 and 28 days!"] = "Per favore, scegli tra 1 e 28 giorni!"
	    GRM_L["Add Events to Calendar"] = "Aggiungi Eventi al Calendario"
	    GRM_L["SYNC Changes With Guildies at Rank"] = "Sincronizza i cambiamenti solo con gildani"     -- Context: at Rank [DROPDOWNRANKSELECTION] or Higher. - Please note where to place dropdown box in the position of the sentence.
	    GRM_L["Reactivating Data SYNC with Guildies..."] = "Riattivazione Sincronizzazione con i gildani"
	    GRM_L["Deactivating Data SYNC with Guildies..."] = "Disattivazione Sincronizzazione con i gildani"
	    GRM_L["Display Sync Update Messages"] = "Visualizza i messaggi di aggiornamento della Sincronizzazione"
	    GRM_L["Only Sync With Up-to-Date Addon Users"] = "Sincronizza solo con utenti che hanno l'Add-on aggiornato"
	    GRM_L["Only Announce Anniversaries if Listed as 'Main'"] = "Annuncia solo gli anniversari dei \"Main\""
	    GRM_L["Leveled"] = "Salito di"
	    GRM_L["Min:"] = "Min:"                                    -- Context: As in, the Minimum level to report or announce when player levels up
	    GRM_L["Inactive Return"] = "Ritorno Inattivi"
	    GRM_L["resetall"] = "resetta tutto"
	    GRM_L["resetguild"] = "resetta gilda"
	    GRM_L["Notify When Players Request to Join the Guild"] = "Notifica quando dei giocatori chiedono di unirsi alla Gilda"
    	--Side chat/log controls - Of note, limited spacing
		    GRM_L["Name Change"] = "Cambio nome"
		    GRM_L["Rank Renamed"] = "Grado rinominato"
		    GRM_L["Event Announce"] = "Annuncio Evento"
		    GRM_L["Left"] = "Ha lasciato"                        -- Context: As in, "Left" the guild...
		    GRM_L["Recommendations"] = "Raccomandazioni"
		    GRM_L["Banned"] = "Bannato"
		    GRM_L["To Chat:"] = "In Chat:"                    -- Context: "To Chat Message frame -- in regards to announcing events like when a player leveled"
		    GRM_L["To Log:"] = "Nel Registro:"                     -- Context: To show it in the guild log.
		    GRM_L["Display Changes"] = "Mostra Cambiamenti"
		    GRM_L["Syncing too fast may cause disconnects!"] = "Impostare la sincronizzazione troppo veloce può causare disconessioni!"
		    GRM_L["Speed:"] = "Velocità:"                      -- Context: Speed that the sync takes place.
		    GRM_L["Show 'Main' Name in Chat"] = "Mostra il nome del \"Main\" in chat"
		--
	--

    -- AUDIT WINDOW
	    GRM_L["AUDIT"] = "VERIFICA"                                              -- Audit Tab name
	    GRM_L["No Date Set"] = "Nessuna data"
	    GRM_L["Main"] = "Main"
	    GRM_L["Main or Alt?"] = "Main o Alt?"
	    GRM_L["Alt"] = "Alt"
	    GRM_L["Total Incomplete: {num} / {custom1}"] = "Totale Incompleti: {num} / {custom1}"                 -- Context: Total Incomeplete: 50 / 100    (50 out of 100)
	    GRM_L["Mains: {num}"] = "Main: {num}"                                        -- Context: Number of "main" toons
	    GRM_L["Unique Accounts: {num}"] = "Account Unici: {num}"
	    GRM_L["All Complete"] = "Tutto Completo"                                        -- Context: All dates have been added and are known, thus it states it is "All Complete"
	    GRM_L["Set Incomplete to Unknown"] = "Imposta data come Sconosciuta"                          -- Context: Implied to set ALL incomplete to unknown
	    GRM_L["Clear All Unknown"] = "Cancella tutti gli Sconosciuta"
	    GRM_L["Please Wait {num} more Seconds"] = "Per favore, aspetta altri {num} Secondi"
	    GRM_L["Guild Data Audit"] = "Verifica dei dati di Gilda"
	    GRM_L["Name"] = "Nome"
	    GRM_L["Join Date"] = "Data di Entrata"
	    GRM_L["Promo Date"] = "Data Promozione"
	    GRM_L["Main/Alt"] = "Main/Alt"
	    GRM_L["Click Player to Edit"] = "Clicca un giocatore\nper modificare"
	    GRM_L["Only Show Incomplete Guildies"] = "Mostra solo gildani Incompleti"
	--

    -- ADDON SYSTEM MESSAGES
	    GRM_L["Guild Roster Manager"] = "Guild Roster Manager"
	    GRM_L["GRM:"] = "GRM:"                                                                -- Abbreviation for "Guild Roster Manager"
	    GRM_L["(Ver:"] = "(Ver:"                                                               -- Ver: is short for Version:
	    GRM_L["GRM Updated:"] = "GRM Aggiornato:"
	    GRM_L["Configuring Guild Roster Manager for {name} for the first time."] = "Configurazione di Guild Roster Manager per {name} per la prima volta"
	    GRM_L["Reactivating Auto SCAN for Guild Member Changes..."] = "Riattivazione scansione automatica dei cambiamenti"
	    GRM_L["Reactivating Data Sync..."] = "Riattivazione Sincronizzazione"
	    GRM_L["Notification Set:"] = true
	    GRM_L["Report When {name} is ACTIVE Again!"] = "Notifica quando {name} torna di nuovo ATTIVO"
	    GRM_L["Report When {name} Comes Online!"] = "Notifica quando {name} torna ONLINE"
	    GRM_L["Report When {name} Goes Offline!"] = "Notifica quando {name} diventa OFFLINE"
	    GRM_L["A new version of Guild Roster Manager is Available!"] = "Una nuova Versione del Guild Roster Manager è disponibile!"
	    GRM_L["Please Upgrade!"] = "Per favore, fai l'Aggiornamento!"
	    GRM_L["Player Does Not Have a Time Machine!"] = "I Giocatori non hanno una Macchina del Tempo!"
	    GRM_L["Please choose a valid DAY"] = "Per favore scegli un GIORNO valido"
	    GRM_L["{name} has been Removed from the Ban List."] = "{name} è stato rimosso dalla Lista Ban"
	    GRM_L["{num} Players Have Requested to Join the Guild."] = "{num} giocatori hanno rischiesto di unirsi alla Gilda"
	    GRM_L["A Player Has Requested to Join the Guild."] = "Un Giocatore ha chiesto di unirsi alla Gilda."
	    GRM_L["Click Link to Open Recruiting Window:"] = "Clicca per aprire la finestra di Reclutamento"
	    GRM_L["Guild Recruits"] = "Reclutamento di Gilda"
	    GRM_L["Scanning for Guild Changes Now. One Moment..."] = "Scansione dei cambiamenti in corso. Un momento..."
	    GRM_L["Breaking current Sync with {name}."] = "Interruzione della sincronizzazione con {name}."
	    GRM_L["Breaking current Sync with the Guild..."] = "Interruzione della sincronizzazione con la Gilda..."
	    GRM_L["Initializing Sync Action. One Moment..."] = "Inizializzazione della sincronizzazione. Un momento..."
	    GRM_L["No Players Currently Online to Sync With..."] = "Non ci sono giocatori Online con cui sincronizzarsi"
	    GRM_L["No Addon Users Currently Compatible for FULL Sync."] = "Non ci sono utenti compatibili per una sincronizzazione completa"
	    GRM_L["SYNC is currently not possible! Unable to Sync with guildies when guild chat is restricted."] = "Non è possibile sincronizzare! Impossibile sincronizzare quando la chat di gilda è limitata"
	    GRM_L["There are No Current Applicants Requesting to Join the Guild."] = "Attualmente non ci sono candidati."
	    GRM_L["The Applicant List is Unavailable Without Having Invite Privileges."] = "La lista delle richieste non è visibile senza i permessi di invito."
	    GRM_L["Manual Scan Complete"] = "Scansione Manuale completata"
	    GRM_L["Analyzing guild for the first time..."] = "Prima scansione della gilda..."
	    GRM_L["Building Profiles on ALL \"{name}\" members"] = "Costruzione profili di tutti i membri di \"{name}\""                -- {name} will be the Guild Name, for context
	    GRM_L["NOTIFICATION:"] = "NOTIFICA:"                                               -- Context:  "Notification: Player is no longer AFK"
	    GRM_L["{name} is now ONLINE!"] = "{name} è ONLINE!"
	    GRM_L["{name} is now OFFLINE!"] = "{name} è OFFLINE!"
	    GRM_L["{name} is No Longer AFK or Busy!"] = "{name} è tornato Disponibile!" 
	    GRM_L["{name} is No Longer AFK or Busy, but they Went OFFLINE!"] = "{name} non è più AFK o Occupato, ma è andato OFFLINE!"
	    GRM_L["{name} is Already in Your Group!"] = "{name} è già nel tuo Gruppo!"
	    GRM_L["GROUP NOTIFICATION:"] = "NOTIFICA PER IL GRUPPO"
	    GRM_L["Players Offline:"] = "Giocatori Offline:"
	    GRM_L["Players AFK:"] = "Giocatori AFK:"
	    GRM_L["40 players have already been invited to this Raid!"] = "Sono già stati invitati 40 giocatori nel Gruppo Raid!"
	    GRM_L["Player should try to obtain group invite privileges."] = "Per favore, cerca di ottenere la possibilità di invitare in gruppo"
	    GRM_L["{name}'s saved data has been wiped!"] = "I dati di {name} sono stati cancellati!"
	    GRM_L["Re-Syncing {name}'s Guild Data..."] = "Risincronizzazione con i dati di {name}"
	    GRM_L["Wiping all Saved Roster Data Account Wide! Rebuilding from Scratch..."] = "Cancellazione di tutti i dati dell'account! Ricostruzione da zero..." --WIP
	    GRM_L["Wiping all saved Guild data! Rebuilding from scratch..."] = "Cancellazione di tutti i dati della gilda! Ricostruzione da zero..." --WIP
	    GRM_L["There are No Log Entries to Delete, silly {name}!"] = "Non ci sono Voci del Registro da cancellare"
	    GRM_L["Guild Log has been RESET!"] = "Il Registro di Gilda è stato RESETTATO!"
	    GRM_L["{name} is now set as \"main\""] = "{name} è stato impostato come \"main\""
	    GRM_L["{name} is no longer set as \"main\""] = "{name} non è più impostato come \"main\""
	    GRM_L["Reset All of {name}'s Data?"] = "Vuoi resettare tutti i dati di {name}?"
	--
    
    -- /grm help
	    GRM_L["Opens Guild Log Window"] = "Apre la finestra del Registro di Gilda"
	    GRM_L["Resets ALL saved data"] = "Resetta TUTTI i dati"
	    GRM_L["Resets saved data only for current guild"] = "Resetta i dati per la gilda corrente"
	    GRM_L["Re-centers the Log window"] = "Centra la finestra del Registro"
	    GRM_L["Triggers manual re-sync if sync is enabled"] = "Effettua manualmente la sincronizzazione se è abilitata"
	    GRM_L["Does a one-time manual scan for changes"] = "Effettua una singola scansione dei cambiamenti "
	    GRM_L["Displays current Addon version"] = "Mostra la versione corrente dell'Add-on"
	    GRM_L["Opens Guild Recruitment Window"] = "Apri la finestra di Reclutamento di Gilda"
	    GRM_L["WARNING! complete hard wipe, including settings, as if addon was just installed."] = "ATTENZIONE! Rimozione completa di tutti i dati, comprese le impostazioni, come se l'Add-On fosse stato appena installato";
	--

    -- General Misc UI
	    GRM_L["Really Clear All Account-Wide Saved Data?"] = "Vuoi davvero cancellare tutti i dati dell'account?"
	    GRM_L["Really Clear All Guild Saved Data?"] = "Vuoi davvero cancellare tutti i dati della gilda?"
	    GRM_L["Yes!"] = "Sì!"
	    GRM_L["Ban Player?"] = "Bannare il Giocatore?"
	    GRM_L["Ban the Player's {num} alts too?"] = "Vuoi bannare anche i {num} Alt?"      	-- Plural number of alts
	    GRM_L["Ban the Player's {num} alt too?"] = "Vuoi bannare anche l'Alt?"     			-- Singular number of alts, just 1
	    GRM_L["Please Click \"Yes\" to Ban the Player!"] = "Per favore, Clicca \"Sì\" per Bannare il Giocatore!"
    --

    -- Sync Messages
	    GRM_L["{name} updated {name2}'s Join Date."] = "{name} ha aggiornato la data di entrata di {name2}."
	    GRM_L["{name} updated {name2}'s Promotion Date."] = "{name} ha aggiornato la data di promozione di {name2}."
	    GRM_L["\"{custom1}\" event added to the calendar by {name}"] = "L'evento \"{custom1}\" è stato aggiunto al calendario da {name}"
	    GRM_L["{name} updated {name2}'s list of Alts."] = "{name} ha aggiornato la lista degli Alt di {name2}."
	    GRM_L["{name} removed {name2}'s from {custom1}'s list of Alts."] = "{name} ha rimosso {name2} dalla lista degli Alt di {custom1}."
	    GRM_L["{name} set {name2} to be 'Main'"] = "{name} ha impostato {name2} come \"Main\""
	    GRM_L["{name} has changed {name2} to be listed as an 'alt'"] = "{name} ha impostato {name2} come \"Alt\""
	    GRM_L["{name} has Removed {name2} from the Ban List."] = "{name} ha rimosso {name2} dalla Lista Ban."
	    GRM_L["{name} has been BANNED from the guild!"] = "{name} è stato BANNATO dalla Gilda!"
	    GRM_L["{name} has been UN-BANNED from the guild!"] = "{name} è stato SBANNATO!"
	    GRM_L["Initiating Sync with {name} Instead!"] = "Sincronizzazione con {name} iniziata"
	    GRM_L["Sync Failed with {name}..."] = "Sincronizzazione con {name} fallita..."
	    GRM_L["The Player Appears to Be Offline."] = "Sembra che il giocatore sia Offline" 
	    GRM_L["There Might be a Problem With Their Sync"] = "Potrebbe esserci un problema con la sincronizzazione"
	    GRM_L["While not ideal, Ask Them to /reload to Fix It and Please Report the Issue to Addon Creator"] = "Anche se non è l'ideale, prova a chiedere di fare /ricarica (o /reload) per sistemare. Per favore riporta il problema al creatore dell'add-on"
	    GRM_L["Manually Syncing Data With Guildies Now... One Time Only."] = "Sincronizzazione manuale in corso... Una volta."
	    GRM_L["Syncing Data With Guildies Now..."] = "Sincronizzazione con i gildani in corso..."
	    GRM_L["(Loading screens may cause sync to fail)"] = "(Le schermate di caricamento possono causare il fallimento della sincronizzazione)"
	    GRM_L["Sync With Guildies Complete..."] = "Sincronizzazione con i gildani completa..."
	    GRM_L["Manual Sync With Guildies Complete..."] = "Sincronizzazione manuale con i gildani completa..."
	    GRM_L["No Players Currently Online to Sync With. Re-Disabling Sync..."] = "Nessun giocatore Online con cui effettuare la sincronizzazione. Sincronizzazione disabilitata..." 
	    GRM_L["{name} tried to Sync with you, but their addon is outdated."] = "{name} ha provato a sincronizzarsi con te, ma il suo add-on non è aggiornato."
	    GRM_L["Remind them to update!"] = "Ricordagli di aggiornare!"
	--
    
    -- ERROR MESSAGES
	    GRM_L["Notification Has Already Been Arranged..."] = "Le notifiche sono già state impostate"
	    GRM_L["Failed to add alt for unknown reason. Try closing Roster window and retrying!"] = "Aggiunta dell'Alt fallita per una ragione sconosciuta. Prova a chiudere l'elenco e ripova!"
	    GRM_L["{name} is Already Listed as an Alt."] = "{name} è già impostato come Alt!"
	    GRM_L["{name} cannot become their own alt!"] = "{name} non può essere Alt di se stesso!"
	    GRM_L["Player Cannot Add Themselves as an Alt"] = "I giocatori non possono aggiungersi come Alt"
	    GRM_L["Player Not Found"] = "Giocatore non trovato"
	    GRM_L["Please try again momentarily... Updating the Guild Event Log as we speak!"] = "Per favore riprova tra un momento... sto aggiornando il registro mentra parliamo!"
	    GRM_L["Invalid Command: Please type '/grm help' for More Info!"] = "Comando non valido: per favore, scrivi \"/grm help\" o \"/grm aiuto\" per altre informazioni!"
	    GRM_L["{name} is not currently in a guild. Unable to Proceed!"] = "{name} non è in una gilda. Impossibile procedere!"
	    GRM_L["Addon does not currently support more than 75 alts!"] = "Non è possibile impostare più di 75 Alt!"
	    GRM_L["Please choose a VALID character to set as an Alt"] = "Per favore, scegli un personaggio VALIDO da impostare come Alt"
	    GRM_L["Please choose a character to set as alt."] = "Per favore scegli un personaggio da impostare come Alt"
	    GRM_L["GRM ERROR:"] = "ERRORE DI GRM:"
	    GRM_L["Com Message too large for server"] = "Messaggio troppo grande per il server" --WIP                   -- Context: "Com message" is short-hand for "Communications message" - this is a technical error on syncing data.
	    GRM_L["Prefix:"] = "Prefisso:"
	    GRM_L["Msg:"] = "Msg:"                                                -- Context: Msg is short for Message
	    GRM_L["Unable to register prefix > 16 characters: {name}"] = "Impossibile registrare il prefisso > di 16 caratteri: {name}"   -- Context: The {name} is the string code for the prefix. This is for debugging.
	--

    --SLASH COMMANDS
    -- These are generally written in general shorthand. The original commands will ALWAYS work, but if there is one that makes more sense in your language, please feel free to modify
	    GRM_L["clearall"] = "clearall"                        -- Context: In regards, "Clear All" saved data account wide 
	    GRM_L["clearguild"] = "clearguild"                      -- Context: In regards, "Clear All" saved data from ONLY the current guild.
	    GRM_L["hardreset"] = "hardreset"                       -- Context: In regards, "Hard Reset" ALL data account wide, including wiping player settings
	    GRM_L["help"] = "aiuto"                            -- Context: "help" with info on the how to use addon
	    GRM_L["version"] = "versione"                         -- Context: "version" of the addon
	    GRM_L["center"] = "centra"                          -- Context: "center" the movable addon window back to center of screen
	    GRM_L["sync"] = "sync"                            -- Context: "sync" the data between players one time now.
	    GRM_L["scan"] = "scan"                            -- Context: "scan" for guild roster changes one time now.
	    GRM_L["clearall"] = "clearall"                        -- Context: In regards, "Clear All" saved data
	    GRM_L["recruit"] = "reclute"                         -- Context: Open the roster "recruit" window where people request to join guild
	--

    -- CLASSES
	    GRM_L["Deathknight"] = "Cavaliere della Morte"
	    GRM_L["Demonhunter"] = "Cacciatore di Demoni"
	    GRM_L["Druid"] = "Druido"
	    GRM_L["Hunter"] = "Cacciatore"
	    GRM_L["Mage"] = "Mago"
	    GRM_L["Monk"] = "Monaco"
	    GRM_L["Paladin"] = "Paladino"
	    GRM_L["Priest"] = "Sacerdote"
	    GRM_L["Rogue"] = "Ladro"
	    GRM_L["Shaman"] = "Sciamano"
	    GRM_L["Warlock"] = "Stregone"
	    GRM_L["Warrior"] = "Guerriero"
	--
    -- TIME AND DATES
	    GRM_L["1 Mar"] = "1 Mar"                           -- This date is used in a specific circumstance. If someone's anniversary/bday landed on a leap year (Feb 29th), it defaults to the 1st of March on non-leap year
	    -- Full Month Name
	    GRM_L["January"] = "Gennaio"
	    GRM_L["February"] = "Febbraio"
	    GRM_L["March"] = "Marzo"
	    GRM_L["April"] = "Aprile"
	    GRM_L["May"] = "Maggio"
	    GRM_L["June"] = "Giugno"
	    GRM_L["July"] = "Luglio"
	    GRM_L["August"] = "Agosto"
	    GRM_L["September"] = "Settembre"
	    GRM_L["October"] = "Ottobre"
	    GRM_L["November"] = "Novembre"
	    GRM_L["December"] = "Dicembre"
	    -- Shorthand Month
	    GRM_L["Jan"] = "Gen"
	    GRM_L["Feb"] = "Feb"
	    GRM_L["Mar"] = "Mar"
	    GRM_L["Apr"] = "Apr"
	    GRM_L["May"] = "Mag"
	    GRM_L["Jun"] = "Giu"
	    GRM_L["Jul"] = "Lug"
	    GRM_L["Aug"] = "Ago"
	    GRM_L["Sep"] = "Set"
	    GRM_L["Oct"] = "Ott"
	    GRM_L["Nov"] = "Nov"
	    GRM_L["Dec"] = "Dic"
	    -- Time Notifcation
	    GRM_L["Seconds"] = "Secondi"
	    GRM_L["Second"] = "Secondo"
	    GRM_L["Minutes"] = "Minuti"
	    GRM_L["Minute"] = "Minuto"
	    GRM_L["Hours"] = "Ore"
	    GRM_L["Hour"] = "Ora"
	    GRM_L["Days"] = "Giorni"
	    GRM_L["Day"] = "Giorno"
	    GRM_L["Months"] = "Mesi"
	    GRM_L["Month"] = "Mese"
	    GRM_L["Years"] = "Anni"
	    GRM_L["Year"] = "Anno"
	    GRM_L["HourBreak"] = ":"            -- Context, in English, and many languages, 11am = 11:00 -- or in French, 11h00   - the hour break is the ":" or the "h" 

	    GRM_L["am"] = "am"
	    GRM_L["pm"] = "pm"
	    GRM_L["24HR_Notation"] = "";        -- if someone is using 24hr time notation in your country, instead of 12hr, how do you notate it? In English, there is no am/pm (though "hours" is technically right, but unnecessary)

	    GRM_L["{num} year"] = "{num} anno"
	    GRM_L["{num} years"] = "{num} anni"
	    GRM_L["{num} month"] = "{num} mese"
	    GRM_L["{num} months"] = "{num} mesi"
	    GRM_L["{num} day"] = "{num} giorno"
	    GRM_L["{num} days"] = "{num} giorni"
	    GRM_L["< 1 day"] = "< 1 giorno"

	    GRM_L["{num} yr"] = "{num} anno"
	    GRM_L["{num} yrs"] = "{num} anni"
	    GRM_L["{num} mo"] = "{num} mese"
	    GRM_L["{num} mos"] = "{num} mesi"
	    GRM_L["{num} hr"] = "{num} ora"
	    GRM_L["{num} hrs"] = "{num} ore"
	    GRM_L["< 1 hour"] = "< 1 ora"
	    GRM_L["{num} {custom1}"] = "{num} {custom1}"     -- Context: This is a placeholder for ANY generic time data -- Ex:  "1 year" or "15 months" - The translation is set this is just to set the orientation of the number properly.
	--

	-- MISC Punctuation
    GRM_L[","] = ","                               -- I know in some Asia languages, a comma is not used, but something similar, for example.

    -- Updates 1.126
    GRM_L["General"] = "Generale"
    GRM_L["General:"] = "Generale:"
    GRM_L["Scan"] = "Scansione"
    GRM_L["Help"] = "Aiuto"
    GRM_L["UI"] = "UI"                              -- UI for User Interface. Abbreviation for changing custom UI featuers, like coloring of <M> main
    GRM_L["Officer"] = "Ufficiale"                         -- as in, "Officer" rank
    GRM_L["Open Addon Window"] = "Apri la finestra dell'Add-on"
    GRM_L["Sync Addon Settings on All Alts in Same Guild"] = "Sincronizza le impostazioni dell'Add-on per tutti gli Alt nella stessa gilda"
    GRM_L["Show Minimap Button"] = "Mostra il bottone sulla minimappa"
    GRM_L["Player is Not Currently in a Guild"] = "Il giocatore non è attualmente in una gilda"
    -- tooltips
    GRM_L["|CFFE6CC7FClick|r to open GRM"] = "|CFFE6CC7FClicca|r per aprire GRM"                         -- Please maintain the color coding
    GRM_L["|CFFE6CC7FRight-Click|r and drag to move this button."] = "|CFFE6CC7FClick destro|r e trascina per muovere questo bottone."   -- Likewise, maintain color coding
    GRM_L["|CFFE6CC7FRight-Click|r to Reset to 100%"] = "|CFFE6CC7FClick destro|r per reimpostare al 100%"               -- for the Options slider tooltip
    GRM_L["|CFFE6CC7FRight-Click|r to Sync Join Date with Alts"] = "|CFFE6CC7FCLick destro|r per sincronizzare la data di entrata degli Alt"
    GRM_L["|CFFE6CC7FRight-Click|r to Set Notification of Status Change"] = "|CFFE6CC7Click destro|r per impostare le notifiche del cambio di stato"
    -- tooltip end
    GRM_L["GRM"] = "GRM"
    GRM_L["Include Unknown as Incomplete"] = "Includi Sconosciuto tra gli Incompleti"                          -- Context: Unknown in the Audit Tab will be hidden if filtering out complete players
    GRM_L["You Do Not Have Permission to Add Events to Calendar"] = "Non hai i permessi per aggiungere eventi al calendario"
    GRM_L["Please Select Which Join Date to Sync"] = "Per favore, seleziona con quale data di entrata sincronizzare"
    GRM_L["Sync All Alts to {name}'s Join Date"] = "Sincronizza tutti gli Alt con la data di entrata di {name}"
    GRM_L["Sync All Alts to the Earliest Join Date: {name}"] = "Sincronizza tutti gli Alt alla data meno recente: {name}"
    GRM_L["Sync All Alts to {name}'s |cffff0000(main)|r Join Date"] = "Sincronizza tutti gli Alt alla data di entrata del |cffff0000(main)|r di {name}"  -- The coloring ensures that "(main)" maintains the RED color. Please keep it consistent if relevant to your language.
    GRM_L["Join Date of All Alts is Currently Synced"] = "La data di entrata di tutti gli Alt è sincronizzata"

    -- Update 1.130
    GRM_L["|CFFE6CC7FCtrl-Shift-Click|r to Hide this Button."] = "|CFFE6CC7FCtrl-Shift-Clicca|r per nascondere questo bottone."
    GRM_L["Invited By:"] = "Invitato da:"
    GRM_L["To avoid storage bloat, a maximum of 2 save points is currently possible. Please remove one before Continuing."] = "Per evitare di sprecare troppa memoria, è consentito un massimo di 2 punti di salvataggio. Per favore cancellane uno prima di continuare."
    GRM_L["Error: Guild Not Found..."] = "Errore: Gilda non trovata..."
    GRM_L["Debugger Start"] = "Inizio Debug";

    -- Update 1.136
    GRM_L["To avoid storage bloat, a maximum of 2 guild save points is currently possible. Please remove one before continuing"] = "Per evitare di sprecare troppa memoria, è consentito un massimo di 2 punti di salvataggio. Per favore cancellane uno prima di continuare."
    GRM_L["Backup Point Removed for Guild \"{name}\""] = "Punto di ripristino per la gilda \"{name}\" rimosso"
    GRM_L["Backup Point Restored for Guild \"{name}\""] = "Ripristino effettuato per la gilda \"{name}\""
    GRM_L["Backup Point Set for Guild \"{name}\""] = "Punto di ripristino per la gilda \"{name}\" impostato"
    GRM_L["Backup"] = "Backup"
    GRM_L["Horde"] = "Orda"
    GRM_L["Alliance"] = "Alleanza"
    GRM_L["Creation Date"] = "Data creazione"
    GRM_L["Members"] = "Membri"
    GRM_L["Backup {num}:"] = "Backup {num}:"           -- As in, the number of backups... so "Backup 1:"
    GRM_L["None"] = "Nessuno"
    GRM_L["Restore"] = "Ripristina"
    GRM_L["Set Backup"] = "Imposta Backup"
    GRM_L["Memory Usage: {num} MB"] = "Memoria utilizzata: {num} MB"          -- MB references the number of MegaBytes of memory used.

    -- Update 1.137
    GRM_L["GRM: Unable to Create Backup for a Guild With Unknown Creation Date! Log into that guild on any alt to update old database."] = "GRM: è impossibile creare un Backup senza sapere la data di creazione della Gilda! Entra con un qualsiasi Alt in gilda per aggiornare il database."
    GRM_L["Enable Auto-Backup Once Every"] = "Abilita il Backup automatico una volta ogni"
    GRM_L["Auto {num}:"] = "Auto {num}:"
    GRM_L["Please Choose a Time Interval Between 1 and 99 Days!"] = "Per favore scegli un intervallo di tempo tra 1 e 99 giorni!"
    GRM_L["Really restore {name} Backup Point?"] = "Vuoi davvero tornare al punto di ripristino {name}"
    GRM_L["Check All"] = "Seleziona tutto"

    -- Update 1.139
    GRM_L["Right-Click for options to remove this guild from the addon database completely"] = "Click destro per rimuovere completamente questa gilda dalla memoria dell'dd-on"
    GRM_L["Player Cannot Purge the Guild Data they are Currently In!!!"] = "Un giocatore non può rimuovere i dati della gilda in cui si trova!"
    GRM_L["To reset your current guild data type '/grm clearguild'"] = "Per resettare i dati della gilda corrente, scrivi '/grm clearguild'"
    GRM_L["Click Here to Remove all traces of this guild, or hit ESC"] = "Clicca per rimuovere ogni traccia di questa gilda, oppure premi ESC"
    GRM_L["{name} has been removed from the database."] = "{name} è stato rimosso dalla memoria"              -- The Guild Name has been removed from the database

    -- update 1.141
    GRM_L["You will still share your data with the guild, but you are currently only accepting incoming changes from rank \"{name}\" or higher"] = "Continuerai a condividere i tuoi dati con la gilda, ma stai accettando modifiche solo dal grado \"{name}\" o più alto"    -- Reminder, the backslash before a quotation denotes the string NOT to close, but to include the quotation in display txt
    GRM_L["Only Restrict Incoming Player Data to Rank Threshold, not Outgoing"] = "Limita, in base al grado, solo i dati in ingresso, non in uscita"
    GRM_L["Total Entries: {num}"] = "Voci totali: {num}"
    GRM_L["Search Filter"] = "Cerca nel Registro"

    -- update 1.142
    GRM_L["Choose Color:"] = "Scegli colore"
    GRM_L["Format:"] = "Formato"
    GRM_L["RGB Values Must be Between 1 and 255."] = "I valori RGB devono essere compresi tra 1 e 255."

    -- Update 1.143
    GRM_L["The Log is Currently Empty for This Guild"] = "Il registro di questa gilda è vuoto"
    GRM_L["Building Log for Export..."] = "Creazione Registro da esportare..."
    GRM_L["Open Log Tools"] = "Apri Strumenti Registro"
    GRM_L["Hide Log Tools"] = "Nascondi Strumenti Registro"
    GRM_L["Numbered Lines"] = "Linee numerate"
    GRM_L["Export Log"] = "Esporta Registro"
    GRM_L["Clear Lines:"] = "Elimina righe da"
    GRM_L["Enable Ctrl-Shift-Click Line Removal"] = "Abilita la rimozione con Ctrl-Shift-Click"
    GRM_L["To"] = "a"                                     -- Clear Lines:  50 To 100     -- It stands between 2 edit boxes as its own fontstring, so work with that.
    GRM_L["Confirm Clear"] = "Conferma eliminazione"
    GRM_L["Please Select Range of Lines from the Log You Wish to Remove"] = "Per favore, seleziona l'intervallo di righe che desideri rimuovere"
    GRM_L["Please put the lowest number in the first box"] = "Per favore, inserisci il numero più basso nella prima casella"
    GRM_L["Line selection is not valid"] = "Selezione righe non valida"
    GRM_L["Really Clear lines {custom1} to {custom2}?"] = "Vuoi davvero eliminare le righe da {custom1} a {custom2}? "
    GRM_L["Enabling Line Numbers... Please choose within the given range"] = "Sto abilitando il numero delle righe... Per favore, scegli dei valori nell'intervallo"
    GRM_L["Ctrl-C to Copy <> Ctrl-P to Paste <> Ctrl-A to Select All"] = "Ctrl-C copia <> Ctrl-P incolla <> Ctrl-A seleziona tutto"
    GRM_L["Language Selection:"] = "Seleziona linguaggio:"
    GRM_L["{num} phrases still need translation to {name}"] = "{num} frasi ancora da tradurre in italiano"                  -- Ex: 300 phrases still need translation to German

    -- update 1.145
    GRM_L["You currently are at {num} non-Battletag friends. To fully take advantage of all of GRM features, please consider clearing some room."] = "Attualmente hai {num} amici non Battle-tag. Per sfruttare appieno le funzioni di GRM considera di fare un po' di spazio."
    GRM_L["Clear Space on Friends List to Find Online Status"] = "Fai spazio nella Lista Amici per vedere lo stato" --WIP
    GRM_L["Offline"] = "Offline"
    GRM_L["{name} has requested to join the guild and is currently ONLINE!"] = "{name} ha richiesto di unirsi alla gilda ed è attualmente ONLINE!"

    -- Update 1.146
    GRM_L["Really Clear line {num}?"] = "Vuoi davvero eliminare la riga {num}"
    GRM_L["Font has been Reset to DEFAULT."] = "Il carattere è stato reimpostato a PREDEFINITO"
    GRM_L["Font Selection:"] = "Seleziona carattere:"
    GRM_L["Font Scale:"] = "Dimensione carattere:"
    GRM_L["Example"] = "Esempio"
    GRM_L["Right-Click to Reset to 100%"] = "Click destro per reimpostare al 100%"

    -- Update 1.147
    GRM_L["|CFFE6CC7FClick|r to open Player Window"] = "|CFFE6CC7FClicca|r per aprire la finestra del giocatore"
    GRM_L["|CFFE6CC7FCtrl-Shift-Click|r to Search the Log for Player"] = "|CFFE6CC7FCtrl-Shift-Click|r per cercare il player nel Registro"

    -- Update 1.1480
    GRM_L["Custom Notes:"] = "Nota Personalizzata:"
    GRM_L["GRM Debugging Enabled."] = "Debug GRM abilitato"
    GRM_L["GRM Debugging Disabled."] = "Debug GRM disabilitato"
    GRM_L["Please type \"/grm debug 10\" to report 10 events (or any number)"] = "Per favore, scrivi \"/grm debug 10\" per un rapporto di 10 eventi (o un altro numero)"       -- Please keep the \"/grm debug 10)\" in-tact for slash command to work
    GRM_L["Format: \"/grm debug 10\""] = "Formato: \"/grm debug 10\""                                                                  -- "" Likewise
    GRM_L["Error: Debug Command not recognized."] = "Error: comando di debug non riconosciuto."
    GRM_L["You may want to temporarily disable SYNC in the options if you are debugging another feature."] = "Potresti voler disattivare la sincronizzazione se stai facendo debug di qualcos'altro"
    GRM_L["Sync Custom Notes"] = "Sincronizza le Note Personalizzate"
    GRM_L["Default Custom Note Rank Minimum"] = "Grado minimo Predefinito per sincronizzare"
    GRM_L["Reset Default Custom Note Restrictions for ALL Guildies"] = "Reimposta le restrizioni Predefinite per TUTTI i gildani"
    GRM_L["Reset to Default"] = "Reimposta a Predefinito"
    GRM_L["Reset"] = "Reimposta"
    GRM_L["|CFF00CCFFDefault Selection For All Players"] = "|CFF00CCFFImpostazione predefinita per tutti i giocatori"
    GRM_L["Each Guildie Can Still be Manually Configured"] = "Le impostazioni possono essere configurate manualemnte per ogni gildano"
    GRM_L["Does NOT apply to Ban List or Custom Note"] = "Non si applica alla Lista Ban o alle Note Personalizzate"
    GRM_L["Custom note Rank reset to default \"{name}\" (or higher)"] = "Autorizzazioni reimpostate al grado predefinito \"{name}\" (o più alto)"
    GRM_L["If sync was manually disabled for specific guildies, this does NOT enabled it."] = "Se la Sincronizzazione con alcuni gildani è stata limitata manualmente, questo NON la riabilita"
    GRM_L["Custom note default settings for Rank and Sync have been reset."] = "Le impostazioni per il Grado e per la Sincronizzazione delle Note Personalizzate sono state resettate."
    GRM_L["Custom note Sync has been reset to default"] = "Le impostazioni di Sincronizzazione delle Note Personalizzate sono state resettate"
    GRM_L["Click here to set Custom Notes"] = "Clicca per impostare una Nota Personalizzata"
    GRM_L["|CFF00CCFFCustom Note Defaults:"] = "|CFF00CCFFNota Personalizzata predefinita:"
    GRM_L["|CFFE6CC7FLeft-Click|r to ONLY reset all to default rank"] = "|CFFE6CC7FClicca|r per reimpostare SOLO il Grado a Predefinito"
    GRM_L["|CFFE6CC7FCtrl-Shift-Click|r to reset BOTH sync and rank defaults"] = "|CFFE6CC7FCtrl-Shift-Click|r per reimpostare SIA il Grado che la Sincronizzazione"
    GRM_L["|CFFE6CC7FCtrl-Left-Click|r to re-enable custom note sync for all"] = "|CFFE6CC7FCtrl-Click Sinistro|r per riabilitare la sincronizzazione\ndelle Note Personalizzate per tutti"
    GRM_L["Custom Note Sync Disabled in Settings"] = "La Sincronizzazione delle Note Personalizzate è disabilitata"
    GRM_L["{name} modified {name2}'s CUSTOM Note: \"{custom1}\" was Added"] = "{name} ha modificato la Nota Personalizzata di {name2}: \"{custom1}\" è stato aggiunto"
    GRM_L["{name} modified {name2}'s CUSTOM Note: \"{custom1}\" was Removed"] = "{name} ha modificato la Nota Personalizzata di {name2}: \"{custom1}\" è stato rimosso"
    GRM_L["{name} modified {name2}'s CUSTOM Note: \"{custom1}\" to \"{custom2}\""] = "{name} ha modificato la Nota Personalizzata di {name2} da \"{custom1}\" a \"{custom2}\""
    GRM_L["Custom Note"] = "Nota Personalizzata"
    GRM_L["Syncing Outgoing Data."] = "Sincronizzazione dei Dati in Uscita"
    GRM_L["|CFFE6CC7FClick|r to Change Rank Restriction"] = "|CFFE6CC7FClicca|r per cambiare le restrizioni sul Grado"
    GRM_L["|CFFE6CC7FClick|r to Change Day"] = "|CFFE6CC7FClicca|r per cambiare il Giorno"
    GRM_L["|CFFE6CC7FClick|r to Change Month"] = "|CFFE6CC7FClicca|r per cambiare il Mese";
    GRM_L["|CFFE6CC7FClick|r to Change Year"] = "|CFFE6CC7FClicca|r per cambiare l'Anno";
    GRM_L["Edited by {name}"] = "Modificata da {name}"
    GRM_L["Note Removed by {name}"] = "Nota rimossa da {name}"
    GRM_L["|CFFFF0000Player No Longer in Guild"] = "|CFFFF0000Giocatore non più in Gilda"
    GRM_L["|CFF00CCFFMinimum Rank to Sync: Player Data, Custom Notes, Ban List"] = "|CFF00CCFFGrado Minimo per sincronizzare: Dati Giocatori, Note Personalizzate, Lista Ban"
    GRM_L["Warning! Ban List rank threshold is below the overall sync rank. Changing from \"{name}\" to \"{name2}\""] = "Attenzione! Il grado per modificare la Lista Ban è più basso di quello generale di sincronizzazione. Lo sto cambiando da \"{name}\" a \"{name2}\""
    GRM_L["Warning! Custom Note rank threshold is below the overall sync rank. Changing default from \"{name}\" to \"{name2}\""] = "Attenzione! Il grado per modificare le Note Personalizzate è più basso di quello generale di sincronizzazione. Lo sto cambiando da \"{name}\" a \"{name2}\""
    GRM_L["Custom Note Default Rank is Also Being Set to \"{name}\""] = "Il grado delle Note Personalizzate sta venendo impostata \"{name}\""
    GRM_L["|CFF00CCFFSync filter can be set tighter for the Ban List"] = "|CFF00CCFFI filtri della sincronizzazione possono essere più ristretti per la Lista Ban"
    GRM_L["Warning! Unable to select a Ban List rank below \"{name}\""] = "Attenzione! Impossibile selezionare il grado per la Lista Ban al di sotto di \"{name}\""
    GRM_L["Warning! Custom Note rank filter must be below \"{name}\""] = "Attenzione! Impossibile selezionare il grado per le Note Personalizzate al di sotto di \"{name}\""
    GRM_L["Setting to match core filter rank"] = "Impostata per corrispondere al Grado del filtro principale" --WIP
    GRM_L["Warning! \"{name}\" is the lowest rank that can receive this custom note.\nCheck the options menu to adjust overall settings."] = "Attenzione! \"{name}\" è il grado più basso che può leggere questa nota personalizzata.\nControlla le impostazioni per adeguarle."

    -- R1.1482
    GRM_L["Shift-Click Name On Roster Also Works"] = "Oppure fai Shift-Click sul nome nell'elenco "
    GRM_L["Tooltip Scale:"] = "Dimensione Tooltip:"
    GRM_L["|CFFE6CC7FLeft-Click|r to Change the Language"] = "|CFFE6CC7FClicca|r per cambiare la Lingua"
    GRM_L["|CFFE6CC7FLeft-Click|r to Change Display Format"] = "|CFFE6CC7FClicca|r per cambiare il Formato"
    GRM_L["|CFFE6CC7FLeft-Click|r to Change the Font"] = "|CFFE6CC7FClicca|r per cambiare il Carattere"
    GRM_L["Unfortunately each player's data will need to be manually reconfigured."] = "Sfortunatamente la data di ogni giocatore andrà riconfigurata manualmente"
    GRM_L["{num} custom {custom1} removed that matched text:"] = "{num} {custom1} personalizzata che corrispondeva al testo è stata rimossa:" --Can I have two of this? One for the plural?  WIP                    -- custom1 = "note" or the plural "notes"
    GRM_L["notes"] = "note"
    GRM_L["Please add specific text, in quotations, to match"] = "Per favore, aggiungi tra virgolette il testo specifico da trovare"

    -- R1.1490
    GRM_L["You will still share some outgoing data with the guild"] = "Condividerai comunque alcuni dati con la gilda"
    GRM_L["Unable to properly locate guild for backup"] = "Impossibile trovare una gilda per il backup" --WIP

    -- R1.1500
    GRM_L["It's almost time to celebrate {name}'s Birthday! ( {custom1} )"] = " A breve sarà il Compleanno di {name}! ( {custom1} )"          -- Custom1 is the actual date.  Like "1 Mar '18"
    GRM_L["Unique accounts pull from the server is known to faulty"] = "L'importazione degli account dai server ha dei problemi,"
    GRM_L["Use only as an estimate. Hopefully Blizz fixes this soon"] = "utilizzala solo come stima. Si spera che la Blizzard risolva presto"
    GRM_L["{name}'s Anniversary!"] = "Anniversario di {name}!"
    GRM_L["{name}'s Birthday!"] = "Compleanno di {name}!"
    GRM_L["Guild member for over {num} year"] = "Membro di Gilda da più di un anno"
    GRM_L["Guild member for over {num} years"] = "Membro di Gilda da più di {num} anni"   -- the plural version!
    GRM_L["Add Upcoming Events to the Calendar"] = "Aggiungi gli eventi imminenti al Calendario"
    GRM_L["Player rank unable to add events to calendar"] = "I giocatori con questo grado non possono aggiungere eventi al calendario"
    GRM_L["Anniversaries, Birthdays, and Other Events can be added with permission"] = "Anniversari, Compleanni, ed altri eventi possono essere aggiunti con il permesso" --WIP

    -- R1.1510
    GRM_L["Check the \"Sync Users\" tab to find out why!"] = "Controlla la scheda \"Sincronizza\" per capire perché!"
    GRM_L["Time as Member:"] = "Membro da:"
    GRM_L["|CFFE6CC7FClick|r to select player event"] = "|CFFE6CC7FClicca|r per selezionare un evento"
    GRM_L["|CFFE6CC7FClick Again|r to open Player Window"] = "|CFFE6CC7FClicca di nuovo|r per aprire la finestra del Giocatore"
    GRM_L["Timestamp Format:"] = "Formato Data e Ora"
    GRM_L["Hour Format:"] = "Formato Orario"
    GRM_L["24 Hour"] = "24 Ore"
    GRM_L["12 Hour (am/pm)"] = "12 Ore (am/pm)"
    GRM_L["Enable Fade on Tab Change"] = "Abilita la dissolvenza sul cambio scheda"
    GRM_L["Confirm Custom Note"] = "Conferma Nota Personalizzata"
	
	-- R1.1520
    GRM_L["A new rank has been added to the guild!"] = "Un nuovo grado è stato aggiunto alla gilda!"
    GRM_L["{num} new ranks have been added to the guild!"] = "{num} nuovi gradi sono stati aggiunti alla gilda!"
    GRM_L["The guild has removed a rank!"] = "Un grado è stato rimosso dalla gilda!"
	GRM_L["{num} guild ranks have been removed!" ] = "{num} gradi sono stati rimossi!"
	GRM_L["Edit Ban"] = "Modifica Ban"
	GRM_L["Please Select a Player to Edit their Ban!"] = "Per favore, seleziona un giocatore per modificare il Ban!"
    GRM_L["Update Ban"] = "Aggiorna Ban"
	GRM_L["{name}'s Ban Info has Been Updated!"] = "Le informazioni sul Ban di {name} sono state aggiornate!"
	
	-- R1.1530
    GRM_L["{name} plays the {custom1} class, not {custom2}."] = "{name} gioca un {custom1}, non un {custom2}."             -- Example: Arkaan plays the Hunter class, not Paladin.
    GRM_L["Don't Remembert their class?"] = "Non ricordi la classe?"
    GRM_L["{num} Items Updated"] = "{num} voci sono state aggiornate"
    GRM_L["You Currently Have Disabled Adding Events to Calendar"] = "Attualmente l'aggiunta degli eventi al calendario è disabilitata"

	-- R1.20
    GRM_L["|CFFE6CC7FHold Shift|r to view more alt details."] = "|CFFE6CC7FTieni premuto Shift|r per vedere più dettagli sull'alt."                -- "Hold Shift to view more alt details" is the phrase, but the |CFF|r is the text coloring hex code. Please keep it in there on the keyboard command coloring
    GRM_L["|CFFE6CC7FClick|r to view more alt details."] = "|CFFE6CC7FClicca|r per vedere più dettagli sull'alt."
    GRM_L["|CFFE6CC7FShift-Click|r to keep alt details open."] = "|CFFE6CC7FShift-Click|r per tenere la finestra dei dettagli aperta."               -- The same can be said here. ^^
    GRM_L["|CFFE6CC7FClick|r to flip player name ordering"] = "|CFFE6CC7FClicca|r per ribaltare l'ordine dei nomi" --WIP                 -- and the reset...
    GRM_L["|CFFE6CC7FClick|r to sort Join Dates by Newest"] = "|CFFE6CC7FClicca|r per ordinare le date di entrata dalla più recente"
    GRM_L["|CFFE6CC7FClick|r to sort Join Dates by Oldest"] = "|CFFE6CC7FClicca|r per ordinare le date di entrata dalla più vecchia"
    GRM_L["|CFFE6CC7FClick|r to sort Promotion Dates by Newest"] = "|CFFE6CC7FClicca|r per ordinare le date di promozione dalla più recente"
    GRM_L["|CFFE6CC7FClick|r to sort Promotion Dates by Oldest"] = "|CFFE6CC7FClicca|r per ordinare le date di promozione dalla più vecchia"
    GRM_L["|CFFE6CC7FClick|r to sort all Mains first"] = "|CFFE6CC7FClicca|r per ordinare mettendo prima tutti i Main"
    GRM_L["|CFFE6CC7FClick|r to sort all Alts first."] = "|CFFE6CC7FClicca|r per ordinare mettendo prima tutti gli Alt."
    GRM_L["{name}'s Profile is Being Built. One Moment..."] = "Profilo di {name} in costruzione. Un momento..."
    GRM_L["There are {num} players requesting to join your guild. You only have room for {custom1} more friends. Please consider cleaning up your friend and recruitment lists."] = "Ci sono {num} giocatore che chiedono di unirsi alla gilda. Hai spazio sono per altri {custom1} amici. Per favore prendi in considerazione di pulire la lista amici e la lista del reclutamento.";
    GRM_L["{name}'s Alts"] = "Alt di {Name}"                                   -- Like "Arkaan's Alts"
    GRM_L["Online:  {num}/{custom1}"] = "Online:  {num}/{custom1}"                         -- As in "Online: 3/59"
    GRM_L["Next"] = "Prossimo"                                            -- This means to Advance forward to the "next" one. It is used on recruitment window to move to NEXT online player.
    GRM_L["Previous"] = "Precedente"                                       -- Same context as the "next" except this one goes back to the one before.
    GRM_L["There are currently no ONLINE recruits."] = "Attualmente non ci sono applicanti ONLINE"
    GRM_L["There are currently no more players in that direction."] = "Non ci sono altri giocatori in quella direzione"
    GRM_L["You have reached the end of the list"] = "Hai raggiunto la fine della lista"
    GRM_L["You have reached the top of the list"] = "Hai raggiunto l'inizio della lista"
    GRM_L["Auto Open Window"] = "Apri automaticamente la finestra"
    GRM_L["Only if a player is online and you are not in combat"] = "Solo se un giocatore è online e non sei in combattimento" --Combat o combattimento?
    GRM_L["Recruit window will open when combat ends."] = "La finestra di reclutamento si aprirà alla fine del combattimento"
	GRM_L["GRM window will open when combat ends."] = "La finestra di GRM si aprirà alla fine del combattimento"
	
	-- R1.22
    GRM_L["!note"] = true
    GRM_L["Setting Public Note for {name}"] = true;
    GRM_L["{name}'s Public Note Set"] = true
    GRM_L["New Feature!"] = true
    GRM_L["Type !note in guild chat, and anything you add after it will become your Public Note (if an officer with GRM installed is online)"] = true
    GRM_L["No officer online to set {name}'s note"] = true
    GRM_L["No officer is currently online to update your note"] = true
    GRM_L["Note updated by @{name}"] = true              -- As in "Note updated by @Arkaan"
	GRM_L["Please manually select your guild to view player details"] = true
	
	-- R1.23
    GRM_L["Please manually select the guild roster tab and then the Recruitment button the first time."] = true
	GRM_L["Allow Guild Members to Type \"!note\" to Set Their Own Public Note"] = true
	GRM_L["Your Guild Leader Has Disabled this Feature"] = true
	GRM_L["If you wish to disable this feature, all officers must disable it as well."] = true
	GRM_L["Adding {name} to Guild Leader officer note will disable feature for all ({name2} to force enable)"] = true  -- GL = Guild Leader
	GRM_L["Your Guild Leader Has Required All Officers to Use this Feature"] = true
	GRM_L["Your Officer note tag {name} has disabled this feature guild wide."] = true  -- The name is the note tag -- like "-grm1" or "+grm1"
	GRM_L["Your Officer note tag {name} forces ALL officers to enable feature."] = true
	GRM_L["Remove disable tag {name} from your officer note first"] = true
	GRM_L["Please remove the enable tag {name} from your officer note first"] = true

	-- R1.24
    GRM_L["This also will change the <Alt> format to match"] = true
    GRM_L["M"] = "M"                                           -- Of note, the "M" is short for "Main" and this is the reference to the main tag on alts in guild chat. For use in the Main tagging <M> (M) etc...
    GRM_L["A"] = "A"           
    GRM_L["<M>"] = "<M>"                                         -- <M> appears for "Main"
	GRM_L["<A>"] = "<A>"                                         -- This is the "Alt" tag on the Add Alt side window. For use in the Alt tagging <A> (A) etc...
	
	-- R1.25
    GRM_L["NG"] = true                                          -- Stands for "Non-guildie" and can be in the context of calendar invites... it explains why some might have tags and others not... They might not be in your guild
    GRM_L["When an Officer logs on, they will scan the guild chat history and add it."] = true      -- in reference to using the !note feature to add public notes by officer.
    GRM_L["Guild chat history has been scanned and public notes have been updated"] = true
    GRM_L["Include \"Joined:\" tag with the date."] = true                                          -- the \" is so you include the qutoations in the actual text. You need them or it closes the phrase.
    GRM_L["Joined: {name}"] = true                                                                  -- {name} is actually in reference to the Data Format... So "Joined: 22 May '18"   {name} = "22 May '18"
    GRM_L["GRM Auto-Detect! {name} has joined the guild and will be set as Main"] = true            -- Main auto-detect message
	
end

-- BuildLog() - might have some extra work, conditionally based on localization as it will now have a mix of languages saved to the log, since log is not retroactively changed.
-- The options panel might need some handcrafted care for allignment.
