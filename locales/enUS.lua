local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("YACalendar", "enUS", true)
if not L then return end

L["monday"] = true
L["tuesday"] = true
L["wednesday"] = true
L["thursday"] = true
L["friday"] = true
L["saturday"] = true
L["sunday"] = true

L["january"] = true
L["february"] = true
L["march"] = true
L["april"] = true
L["may"] = true
L["june"] = true
L["july"] = true
L["august"] = true
L["september"] = true
L["october"] = true
L["november"] = true
L["december"] = true

L["completeDate"] = "$7n, $8n $3n, $1n"
L["tinyDateTime"] = "$2n/$3n $4n:$5n"
L["eventDateTime"] = "$7n, $8n $3n, $1n $4n:$5n"

L["duration"] = "Duration: "
L["Created by:"] = true
L["Last update:"] = true
L["Comment:"] = true

L["coming"] = "Coming"
L["notcoming"] = "Not coming"
L["uncertain"] = "Uncertain"
L["comingcolon"] = "Coming:"
L["notcomingcolon"] = "Not coming:"
L["uncertaincolon"] = "Uncertain:"
L["participant"] = "participant"
L["participants"] = "participants"
L["participantsdetail"] = "$1n $2n ($3n, $4n, $5n)"

L["addevent"] = "Add event"
L["delete"] = "Delete"

L["addeventwindowtitle"] = "Add a new event"
L["eventname"] = "Name"
L["eventdate"] = "Date\n\n(year, month, day)"
L["eventhourminute"] = "Hour/minute"
L["eventduration"] = "Duration"
L["eventcomment"] = "Comment"
L["eventraid"] = "Adventure/Dungeon/Raid event"
L["eventplayers"] = "Players"
L["eventtank"] = "Tanks"
L["eventheal"] = "Healers"
L["eventdd"] = "Damage dealers"
L["add"] = "Add"
L["close"] = "Close"
L["baddate"] = "There is an error in the date"
L["mustbeafternow"] = "The date/time must be after now"
L["namenotgood"] = "The name have not a good length or contains bad char"
L["dateintegererror"] = "An error is in date field"

L["configuration"] = "Configuration"
L["titleconfig"] = "Configuration of Yet Another Calendar"
L["calendarname"] = "Calendar name"
L["calendarsalt"] = "ID key"
L["save"] = "Save"
L["okdeletecalendar"] = "Are you sure to delete calendar \"$1n\"?"
L["badnamesalt"] = "Incorrect char in calendar name/id, or empty, or too long (max 30 characters)"
