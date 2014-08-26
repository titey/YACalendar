-----------------------------------------------------------------------------------------------
-- Client Lua Script for YACalendar
-- a shared calendar addon
-- License: GPLv3
-- Author:  TiTeY`
-- Copyright (c) TiTeY`
-----------------------------------------------------------------------------------------------
-- vim: ts=4 sts=4 sw=4 expandtab

require "Apollo"
require "GameLib"
require "GuildLib"
require "ICCommLib"
require "Window"



-- Upvalues
local type, tostring, tonumber, pairs, ipairs, next, unpack = type, tostring, tonumber, pairs, ipairs, next, unpack
local setmetatable, getmetatable, xpcall, assert = setmetatable, getmetatable, xpcall, assert
local ostime, osdate = os.time, os.date
local tconcat, tinsert, tremove, tsort = table.concat, table.insert, table.remove, table.sort
local strformat, strlen, strfind, strmatch, strupper, strgfind, strsub, strlower = string.format, string.len, string.find, string.match, string.upper, string.gfind, string.sub, string.lower



-----------------------------------------------------------------------------------------------
-- YACalendar Module Definition
-----------------------------------------------------------------------------------------------
local YACalendar = {}



-----------------------------------------------------------------------------------------------
-- global vars (for YACalendar)
-----------------------------------------------------------------------------------------------



---
-- #object gemini:logging 
local glog = nil



---
-- #object md5 hasher
local md5 = nil



---
-- #object rover addon
local rover = nil



---
-- #object i18n
local L = nil



---
-- #object libdialog
local DLG = nil



---
-- #object JSON encoder/decoder
local JSON = nil



-----------------------------------------------------------------------------------------------
-- conf vars
-----------------------------------------------------------------------------------------------



---
-- #table contains all calendars data
-- data sample
-- calendarData = { #table all calendars, non-ordered
-- 	{
-- 		name = #string the name of calendar, must be unique on all calendars
-- 		salt = #string the "salt" for the unique channel name generation
-- 		isGuild = #boolean true if the calendar is a _guild_ calendar
-- 		events = { #table all calendars, non-ordered
-- 			{
-- 				uniqueId = #string a unique id for the event
-- 				eventName = #string the event name
-- 				eventDateTime = #string the event date/time in SQL format
-- 				eventDuration = #string the event duration, format "HH:MM"
-- 				updateDate = #string the event last update in SQL format
-- 				eventCreator = #string the event creator (player name)
-- 				isDeleted = #boolean the event is deleted ?
-- 				options = { #table optionals informations, but must be a table
-- 					comment = #string (optional) an event comment
-- 					type = #string (optional) can be "raid" to unlock the raid mode, linked to option "raidRole"
-- 					
-- 				}
-- 				participants = { #table all event participants, non-ordered
-- 					{
-- 						playerName = #string participant player name
-- 						playerDateTime = #string the participant last update in SQL format
-- 						playerStatus = #string participant status, must be "present", "discard" or "maybe"
-- 						options = { #table optionals informations, but must be a table
-- 							raidRole = { #table player role in a raid/dungeon/adventure, must contain a value if event type="raid"
-- 								"tank",
-- 								"heal",
-- 								"dps"
-- 							}
-- 						}
-- 					}
-- 				}
-- 			}
-- 		}
-- 	}
-- }
local calendarData = {}



---
-- #table contains development calendar data
local calDatDEVDATA = {
	{
		name = "NewTestCalendar", --must be unique
		salt = "j546gfd3",
		isGuild = false,
		events =	{
						{
							uniqueId = "OMG a MD5 sign 1",
							eventName = "event name 1",
							eventDateTime = "2014-08-03 20:30:00",
							eventDuration = "01:00",
							updateDate = "2014-08-03 16:18:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player8",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player6",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												},
												{
													playerName = "player4",
													playerDateTime = "2014-08-04 20:30:42",
													playerStatus = "maybe"
												},
												{
													playerName = "player5",
													playerDateTime = "2014-08-04 20:01:42",
													playerStatus = "maybe"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:02:42",
													playerStatus = "decline"
												},
												{
													playerName = "player7",
													playerDateTime = "2014-08-04 20:03:42",
													playerStatus = "maybe"
												},
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:04:42",
													playerStatus = "present"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 2",
							eventName = "event name 2",
							eventDateTime = "2014-08-25 12:42:00",
							eventDuration = "02:00",
							updateDate = "2014-08-24 11:03:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 3",
							eventName = "event name 3",
							eventDateTime = "2014-08-30 16:00:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 4",
							eventName = "event name 4",
							eventDateTime = "2014-08-03 17:00:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 5",
							eventName = "event name 5",
							eventDateTime = "2014-08-03 18:00:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 6",
							eventName = "event name 6",
							eventDateTime = "2014-08-03 19:00:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 7",
							eventName = "event name 7",
							eventDateTime = "2014-08-03 19:30:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 8",
							eventName = "event name 8",
							eventDateTime = "2014-08-03 20:00:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = false,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						},
						{
							uniqueId = "OMG a MD5 sign 9",
							eventName = "event name 9",
							eventDateTime = "2014-08-05 20:00:00",
							eventDuration = "03:00",
							updateDate = "2014-08-27 09:50:42",
							eventCreator = "The Best One",
							isDeleted = true,
							participants =	{
												{
													playerName = "player1",
													playerDateTime = "2014-08-04 20:24:42",
													playerStatus = "present"
												},
												{
													playerName = "player2",
													playerDateTime = "2014-08-04 20:25:42",
													playerStatus = "decline"
												},
												{
													playerName = "player3",
													playerDateTime = "2014-08-04 20:26:42",
													playerStatus = "maybe"
												}
											}
						}
					}
	},
	{
		name = "New Empty Calendar", --must be unique
		salt = "DSFefsR",
		isGuild = false,
		events = {}
	}
}



---
--#table default configuration
local defaults = {
	["cal"] = {},
	["compatibility"] = 1, -- set the settings compatibility version
	["currentCalendar"] = ""
}



---
-- #table sync channels to update shared calendar
local channels = {}



---
-- #table input from channel
local receivedSyncData = {}



---
-- #table output to channel
local sendSyncData = {}



-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------



---
-- #boolean development mode
local DEVMODE = false -- can delete all calendar data and load tests data (WARNING: destroy backup)



---
-- #string string package version
local VERSION = "0.1"



-----------------------------------------------------------------------------------------------
-- basic functions
-----------------------------------------------------------------------------------------------



---
-- get current datetime
-- @return #string a string date in SQL format
local function getDateTimeNow()
	glog:debug("in getDateTimeNow()")
	return osdate("%Y-%m-%d %H:%M:%S")
end



---
-- get a random unique id (md5)
-- @param #string salt string
-- @return #string a unique id
local function getRandomUniqueId(salt)
	if salt == nil then
		glog:error("getRandomUniqueId: no salt in param")
		return false
	end
	
	glog:debug("in getRandomUniqueId(" .. salt .. ")")
	
	local seed = ostime()
	glog:debug("seed=" .. seed)
	math.randomseed(seed)
	local rnd = math.random()
	local uniqStr = rnd .. ", 42, because I can, " .. salt
	glog:debug("uniqStr=" .. uniqStr)
	local md5 = md5:hash(uniqStr)
	glog:debug("return: md5=" .. md5)
	return md5
end



---
-- return a datetime, based on params
-- @param #number yr a year
-- @param #number mt a month
-- @param #number d a day
-- @param #number h an hour
-- @param #number mn a minute
-- @param #number s a second
-- @return #string empty string on error, or a date in SQL format
local function getDateTimeFrom(yr, mt, d, h, mn, s)
	if yr == nil or mt == nil or d == nil or h == nil or mn == nil or s == nil then
		glog:error("getDateTimeFrom: params are nil")
		return ""
	elseif yr < 1970 or mt < 1 or mt > 12 or d < 1 or d > 31 or h < 0 or h > 23 or mn < 0 or mn > 59 or s < 0 or s > 61 then
		glog:error("getDateTimeFrom: params are not in correct bounds")
		return ""
	end
	
	glog:debug("in getDateTimeFrom(" .. yr .. ", " .. mt .. ", " .. d .. ", " .. h .. ", " .. mn .. ", " .. s .. ")")
	
	return osdate("%Y-%m-%d %H:%M:%S", ostime{year=yr, month=mt, day=d, hour=h, min=mn, sec=s})
end



---
-- test a datetime string, check if is in SQL format
-- @param #string strDT a SQL datetime string
-- @return #boolean true if strDT is a date in SQL format
local function testDateTime(strDT)
	if strDT == nil then
		return false
	elseif strlen(strDT) ~= 19 then
		return false
	end
	
	local osef1, osef2, yr, mt, d, h, mn, s = strfind(strDT, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	if yr == nil or mt == nil or d == nil or h == nil or mn == nil or s == nil then
		return false
	elseif tonumber(yr) < 1970 or tonumber(mt) < 1 or tonumber(mt) > 12 or tonumber(d) < 1 or tonumber(d) > 31 or tonumber(h) < 0 or tonumber(h) > 23 or tonumber(mn) < 0 or tonumber(mn) > 59 or tonumber(s) < 0 or tonumber(s) > 61 then
		return false
	else
		return true
	end
end



---
-- parse datetime
-- @param #string strDT a SQL datetime string
-- @return #table table of datetime, false on error
local function parseDateTime(strDT)
	if strDT == nil then
		return false
	elseif strlen(strDT) ~= 19 then
		return false
	end
	
	local osef1, osef2, yr, mt, d, h, mn, s = strfind(strDT, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	if yr == nil or mt == nil or d == nil or h == nil or mn == nil or s == nil then
		return false
	elseif tonumber(yr) < 1970 or tonumber(mt) < 1 or tonumber(mt) > 12 or tonumber(d) < 1 or tonumber(d) > 31 or tonumber(h) < 0 or tonumber(h) > 23 or tonumber(mn) < 0 or tonumber(mn) > 59 or tonumber(s) < 0 or tonumber(s) > 61 then
		return false
	else
		return {year = tonumber(yr), month = tonumber(mt), day = tonumber(d), hour = tonumber(h), minute = tonumber(mn), second = tonumber(s)}
	end
end



---
-- test a duration string
-- @param #string str a duration string
-- @return #boolean true if str is a duration string
local function testDuration(str)
	if str == nil then
		return false
	elseif strlen(str) == 0 then
		return false
	end
	
	local osef1, osef2, h, mn = strfind(str, "(%d+):(%d+)")
	if h == nil or mn == nil then
		return false
	elseif strlen(str) ~= 5 then
		return false
	elseif tonumber(h) < 0 or tonumber(h) > 23 or tonumber(mn) < 0 or tonumber(mn) > 59 then
		return false
	else
		return true
	end
end



---
-- deep copy a variable
-- @param #mixed orig a variable to deep copy
-- @return #mixed a deep copy
local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end



---
-- first char to uppercase
-- @param #string str a string to uppercase the first char
-- @return #string a string with first char uppercase
local function firstToUpper(str)
    return (str:gsub("^%l", strupper))
end



---
-- get number of days in a month
-- @param #number mnth an integer month
-- @param #number yr an integer year
-- @return #number an integer of days in month
local function getDaysInMonth(mnth, yr)
	return osdate('*t',ostime{year=yr,month=mnth+1,day=0})['day']
end



---
-- get day of week
-- @param #number dd the day
-- @param #number mm the month
-- @param #number yy the year
-- @return #number integer
local function getDayOfWeek(dd, mm, yy)
	return osdate('*t',ostime{year=yy,month=mm,day=dd})['wday']
end



---
-- test if a string value is in table
-- @param #table t the table
-- @param #mixed v string/number the value
-- @return #boolean true if v is on t, false if not
local function inTable(t, v)
	if t == nil or v == nil then
		glog:error("inTable: params is nil")
		return false
	elseif type(t) ~= "table" or (type(v) ~= "number" and type(v) ~= "string" and type(v) ~= "boolean") then
		glog:error("inTable: bad params type")
		return false
	end
	
	for tableKey,tableValue in pairs(t) do
		if tableValue == v then
			return true
		end
	end
	
	return false
end



---
-- split a string and return table
-- @param #string str the string to split
-- @param #string pat the pattern to use to split the string
-- @return #table split string in table, false on error
local function split(str, pat)
	if str == nil or pat == nil then
		glog:error("split: params are nil")
		return false
	elseif type(str) == 0 or type(pat) == 0 then
		glog:error("split: params are bad type")
		return false
	elseif strlen(str) == 0 or strlen(pat) == 0 then
		glog:error("split: params are empty")
		return false
	end
	local t = {}
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			tinsert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		tinsert(t, cap)
	end
	return t
end



---
-- add 1 or N days to a date
-- @param #number year a year
-- @param #number month a month
-- @param #number day a day
-- @param #number step (optional) days added to date, by default equal to 1
-- @return #table table of a day, return false on error
local function addDaysDate(year, month, day, step)
	if year == nil or month == nil or day == nil then
		glog:error("addDaysDate: params are nil")
		return false
	end
	if step == nil then
		step = 1
	end
	if type(year) ~= "number" or type(month) ~= "number" or type(day) ~= "number" or type(step) ~= "number" then
		glog:error("addDaysDate: params are not numbers")
		return false
	end
	
	for i = 1,step do
		day = day + 1
		if day > getDaysInMonth(month, year) then -- the current day is greater than the number of month days ?
			month = month + 1
			day = 1
		end
		if month > 12 then
			year = year + 1
			month = 1
			day = 1
		end
	end
	
	return {["year"] = year, ["month"] = month, ["day"] = day}
end



---
-- substract 1 or N days to a date
-- @param #number year a year
-- @param #number month a month
-- @param #number day a day
-- @param #number step (optional) days substracted to date, by default equal to 1
-- @return #table table of a day, return false on error
local function subDaysDate(year, month, day, step)
	if year == nil or month == nil or day == nil then
		glog:error("subDaysDate: params are nil")
		return false
	end
	if step == nil then
		step = 1
	end
	if type(year) ~= "number" or type(month) ~= "number" or type(day) ~= "number" or type(step) ~= "number" then
		glog:error("subDaysDate: params are not numbers")
		return false
	end
	
	for i = 1,step do
		day = day - 1
		if day == 0 then
			month = month - 1
			if month == 0 then
				year = year - 1
				month = 12
			end
			day = getDaysInMonth(month, year)
		end
	end
	
	return {["year"] = year, ["month"] = month, ["day"] = day}
end



---
-- Strip accents from a string
-- @param #string str
-- @return #string without accents
local function strStripAccents(str)
	local tA = {}
	tA["à"] = "a"
	tA["á"] = "a"
	tA["â"] = "a"
	tA["ã"] = "a"
	tA["ä"] = "a"
	tA["ç"] = "c"
	tA["è"] = "e"
	tA["é"] = "e"
	tA["ê"] = "e"
	tA["ë"] = "e"
	tA["ì"] = "i"
	tA["í"] = "i"
	tA["î"] = "i"
	tA["ï"] = "i"
	tA["ñ"] = "n"
	tA["ò"] = "o"
	tA["ó"] = "o"
	tA["ô"] = "o"
	tA["õ"] = "o"
	tA["ö"] = "o"
	tA["ù"] = "u"
	tA["ú"] = "u"
	tA["û"] = "u"
	tA["ü"] = "u"
	tA["ý"] = "y"
	tA["ÿ"] = "y"
	tA["À"] = "A"
	tA["Á"] = "A"
	tA["Â"] = "A"
	tA["Ã"] = "A"
	tA["Ä"] = "A"
	tA["Ç"] = "C"
	tA["È"] = "E"
	tA["É"] = "E"
	tA["Ê"] = "E"
	tA["Ë"] = "E"
	tA["Ì"] = "I"
	tA["Í"] = "I"
	tA["Î"] = "I"
	tA["Ï"] = "I"
	tA["Ñ"] = "N"
	tA["Ò"] = "O"
	tA["Ó"] = "O"
	tA["Ô"] = "O"
	tA["Õ"] = "O"
	tA["Ö"] = "O"
	tA["Ù"] = "U"
	tA["Ú"] = "U"
	tA["Û"] = "U"
	tA["Ü"] = "U"
	tA["Ý"] = "Y"
	
	local normalizedString = ""
	for strChar in strgfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do
		if tA[strChar] ~= nil then
			normalizedString = normalizedString..tA[strChar]
		else
			normalizedString = normalizedString..strChar
		end
	end
	return normalizedString
end



---
-- generate a channel name
-- @param #string name name of calendar
-- @param #string salt salt of calendar
-- return string the channel name
local function generateChannelName(name, salt)
	return "YAC" .. md5:hash(name .. salt)
end



-----------------------------------------------------------------------------------------------
-- calendarData accessor
-----------------------------------------------------------------------------------------------



---
-- test if a calendar id exists
-- @param #number id an integer id
-- @return #boolean true if calendar exists
local function testCalendarId(id)
	if id == nil then
		glog:error("testCalendarId: no id in param")
		return false
	elseif id <= 0 then
		glog:error("testCalendarId: id in param is lower or equal to zero")
		return false
	end
	
	-- glog:debug("in testCalendarId(" .. id .. ")")
	
	if calendarData[id] == nil then
		return false
	elseif next(calendarData[id]) == nil then
		return false
	end
	return true
end



---
-- test if a calendar name exists
-- @param #string calname a calendar name to test
-- @return #boolean true if exists, false if not
local function testCalendarName(calname)
	if calname == nil then
		glog:error("testCalendarName: no calname in param")
		return false
	elseif strlen(calname) == 0 then
		glog:error("testCalendarName: empty string calname in param")
		return false
	end
	
	-- glog:debug("in testCalendarName(" .. calname .. ")")
	
	for key,value in pairs(calendarData) do -- return first calendar with the right name
		if value.name == calname then
			return true
		end
	end
	
	return false
end



---
-- get a calendar by his id
-- @param #number id an integer id
-- @return #table a calendar, or false on error
local function getCalendarById(id)
	if id == nil then
		glog:error("getCalendarById: no id in param")
		return false
	elseif id <= 0 then
		glog:error("getCalendarById: id in param is lower or equal to zero")
		return false
	end
	
	if testCalendarId(id) == false then
		glog:error("no calendar with id " .. id)
		return false
	end
	return deepcopy(calendarData[id])
end



---
-- get a calendar by his name
-- @param #string calname a calendar name
-- @return #table a calendar, or false on error
local function getCalendarByName(calname)
	if calname == nil then
		glog:error("getCalendarByName: no calname in param")
		return false
	elseif strlen(calname) == 0 then
		glog:error("getCalendarByName: empty string calname in param")
		return false
	end
	
	for key,value in pairs(calendarData) do -- return first calendar with the right name
		if value.name == calname then
			return deepcopy(value)
		end
	end
	
	return false
end



---
-- get id of a calendar by his name
-- @param #string calname a calendar name
-- @return #number a calendar id, or false on error
local function getCalendarIdByName(calname)
	if calname == nil then
		glog:error("getCalendarIdByName: no calname in param")
		return false
	elseif strlen(calname) == 0 then
		glog:error("getCalendarIdByName: empty string calname in param")
		return false
	end
	
	for key,value in pairs(calendarData) do -- return first calendar with the right name
		if value.name == calname then
			return deepcopy(key)
		end
	end
	
	return false
end



---
-- set a calendar name
-- @param #number id an integer calendar id
-- @param #string newname a new calendar name
-- @return boolean
local function setCalendarName(id, newname)
	if id == nil or newname == nil then
		glog:error("setCalendarName: a param is nil")
		return false
	elseif id <= 0 or strlen(newname) == 0 then
		glog:error("setCalendarName: empty string in param")
		return false
	end
	
	glog:debug("in setCalendarName(" .. id .. ", " .. newname .. ")")
	
	if testCalendarId(id) == false then
		glog:error("no calendar with id " .. id)
		return false
	end
	calendarData[id].name = newname
	return true
end



---
-- set a calendar salt
-- @param #number id an integer calendar id
-- @param #string newsalt a new calendar salt
-- @return boolean
local function setCalendarSalt(id, newsalt)
	if id == nil or newsalt == nil then
		glog:error("setCalendarSalt: a param is nil")
		return false
	elseif id <= 0 or strlen(newsalt) == 0 then
		glog:error("setCalendarSalt: empty string in param")
		return false
	end
	
	glog:debug("in setCalendarSalt(" .. id .. ", " .. newsalt .. ")")
	
	if testCalendarId(id) == false then
		glog:error("no calendar with id " .. id)
		return false
	end
	calendarData[id].salt = newsalt
	return true
end



---
-- add a calendar
-- @param #string calendarName a calendar name
-- @param string calendarSalt a calendar salt
-- @param #boolean calendarGuild (optional) this is a guild calendar
-- @return #boolean true on success
local function addCalendar(calendarName, calendarSalt, calendarGuild)
	if calendarName == nil or calendarSalt == nil then
		glog:error("addCalendar: a param is nil")
		return false
	elseif strlen(calendarName) == 0 or strlen(calendarSalt) == 0 then
		glog:error("addCalendar: empty string in param")
		return false
	end
	
	if calendarGuild == nil then
		calendarGuild = false
	elseif calendarGuild ~= false and calendarGuild ~= true then
		glog:error("addCalendar: param calendarGuild is not a boolean")
		return false
	end
	
	glog:debug("in addCalendar(" .. calendarName .. ", " .. calendarSalt .. ")")
	
	local newCal = {
		name = calendarName,
		salt = calendarSalt,
		isGuild = calendarGuild,
		events = {}
	}
	tinsert(calendarData, newCal)
	return true
end



---
-- delete a calendar
-- @param #number id an integer calendar id
-- @return #boolean true on success
local function deleteCalendar(id)
	if id == nil then
		glog:error("deleteCalendar: no id in param")
		return false
	elseif id <= 0 then
		glog:error("deleteCalendar: id in param is lower or equal to zero")
		return false
	end
	
	glog:debug("in deleteCalendar(" .. id .. ")")
	
	if testCalendarId(id) == false then
		glog:error("no calendar with id " .. id)
		return false
	end
	tremove(calendarData, id)
	return true
end



---
-- test if param is an event
-- @param #table ev an pseudo event
-- @param #boolean dontTestAllData (optional) dont test all data
-- @return #boolean return true if param is a valid event
local function testEvent(ev, dontTestAllData)
	if dontTestAllData == nil then
		dontTestAllData = false
	end
	
	if ev == nil then
		glog:debug("testEvent: first param is nil")
		return false
	elseif type(ev) ~= "table" then
		glog:debug("testEvent: first param is not a table")
		return false
	elseif ev.eventName == nil or ev.eventCreator == nil or ev.eventDateTime == nil or ev.eventDuration == nil or ev.updateDate == nil or ev.isDeleted == nil or ev.options == nil then
		glog:debug("testEvent: param contain nil value")
		return false
	elseif type(ev.eventName) ~= "string" or type(ev.eventCreator) ~= "string" or type(ev.eventDateTime) ~= "string" or type(ev.eventDuration) ~= "string" or type(ev.updateDate) ~= "string" or type(ev.isDeleted) ~= "boolean" or type(ev.options) ~= "table" then
		glog:debug("testEvent: params are not good type")
		return false
	elseif strlen(ev.eventName) == 0 or strlen(ev.eventCreator) == 0 or testDateTime(ev.eventDateTime) == false or testDuration(ev.eventDuration) == false or testDateTime(ev.updateDate) == false or inTable({true, false}, ev.isDeleted) == false then
		glog:debug("testEvent: param does not contain a valid data")
		return false
	end
	
	if dontTestAllData == false then
		if ev.participants == nil or ev.uniqueId == nil then
			glog:debug("testEvent: event contains nil value")
			return false
		elseif type(ev.participants) ~= "table" or type(ev.uniqueId) ~= "string" then
			glog:debug("testEvent: participants or uniqueId are not in good type")
			return false
		elseif strlen(ev.uniqueId) == 0 then -- participants can be an empty table
			glog:debug("testEvent: uniqueId is empty")
			return false
		end
	end
	
	return true
end



---
-- test if param is a participant
-- @param #table part an pseudo participant
-- @return #boolean return true if param is a valid participant
local function testParticipant(part)
	if part == nil then
		glog:debug("testParticipant: first param is nil")
		return false
	elseif type(part) ~= "table" then
		glog:debug("testParticipant: first param is not a table")
		return false
	elseif part.playerName == nil or part.playerDateTime == nil or part.playerStatus == nil then
		glog:debug("testParticipant: param contain nil value")
		return false
	elseif type(part.playerName) ~= "string" or type(part.playerDateTime) ~= "string" or type(part.playerStatus) ~= "string" then
		glog:debug("testParticipant: params are not good type")
		return false
	elseif strlen(part.playerName) == 0 or testDateTime(part.playerDateTime) == false or inTable({"present", "maybe", "discard"}, part.playerStatus) == false then
		glog:debug("testParticipant: param does not contain a valid data")
		return false
	end
	-- TODO: add test options
	return true
end



---
-- add an event in a calendar
-- @param #number calId an integer calendar id
-- @param #string evName an event name
-- @param #string evDT a SQL datetime
-- @param #string evDur a duration
-- @param #string evCreator event creator
-- @param #string evUpdateDT (optional) event update datetime
-- @param #boolean evIsDeleted (optional) event is deleted
-- @param #string evForceUniqueId (optional) force an event uniqueId
-- @param #table evOptions (optional) event options
-- @return #string the event unique id, false on error
local function addCalendarEvent(calId, evName, evDT, evDur, evCreator, evUpdateDT, evIsDeleted, evForceUniqueId, evOptions)
	if calId == nil or evName == nil or evDT == nil or evDur == nil or evCreator == nil then
		glog:error("addCalendarEvent: params are nil")
		return false
	elseif type(calId) ~= "number" or type(evName) ~= "string" or type(evDT) ~= "string" or type(evDur) ~= "string" or type(evCreator) ~= "string" then
		glog:error("addCalendarEvent: bad params type")
		return false
	elseif calId <= 0 or strlen(evName) == 0 or strlen(evDT) == 0 or strlen(evDur) == 0 or strlen(evCreator) == 0 then
		glog:error("addCalendarEvent: params are not in correct bounds")
		return false
	elseif testCalendarId(calId) == false then
		glog:error("addCalendarEvent: no calendar with id " .. calId)
		return false
	elseif testDateTime(evDT) == false then
		glog:error("addCalendarEvent: bad event datetime")
		return false
	elseif testDuration(evDur) == false then
		glog:error("addCalendarEvent: bad event duration")
		return false
	end
	
	glog:debug("in addCalendarEvent(" .. tostring(calId) .. "," .. evName .. "," .. evDT .. "," .. evDur .. "," .. evCreator .. "," .. tostring(evUpdateDT) .. "," .. tostring(evIsDeleted) .. "," .. tostring(evForceUniqueId) .. ")")
	
	
	
	-- evUpdateDT is optional
	if evUpdateDT == nil then
		evUpdateDT = getDateTimeNow() -- if not in param, set it to now()
	end
	
	-- evIsDeleted is optional
	if evIsDeleted == nil then
		evIsDeleted = false -- always not deleted...
	end
	
	-- evForceUniqueId is optional
	local uniqueId = "BUG"
	if evForceUniqueId ~= nil then
		if type(evForceUniqueId) ~= "string" then
			glog:error("addCalendarEvent: evForceUniqueId is not a string")
			return false
		elseif strlen(evForceUniqueId) == 0 then
			glog:error("addCalendarEvent: evForceUniqueId is empty")
			return false
		end
		uniqueId = deepcopy(evForceUniqueId)
	else
		uniqueId = getRandomUniqueId(evName) -- set a random unique event id
	end
	
	-- evOptions is optional
	local addOptions = {}
	if evOptions ~= nil then
		if type(evOptions) ~= "table" then
			glog:error("addCalendarEvent: evOptions is not a table")
			return false
		end
		addOptions = deepcopy(evOptions)
	end
	
	-- check optional params
	if testDateTime(evUpdateDT) == false then
		glog:error("addCalendarEvent: bad event update datetime")
		return false
	elseif inTable({true, false}, evIsDeleted) == false then
		glog:error("addCalendarEvent: bad event is deleted status")
		return false
	end

	local newEvent =	{
							uniqueId = uniqueId,
							eventName = evName,
							eventDateTime = evDT,
							eventDuration = evDur,
							updateDate = evUpdateDT,
							isDeleted = evIsDeleted,
							eventCreator = evCreator,
							options = deepcopy(addOptions),
							participants =	{}
						}
	tinsert(calendarData[calId].events, newEvent)
	return uniqueId
end



---
-- add an event in a calendar by his name
-- @param #string calstr a calendar name
-- @param #string evName an event name
-- @param #string evDT a SQL datetime
-- @param #string evDur a duration
-- @param #string evCreator event creator
-- @param #string evUpdateDT (optional) event update datetime
-- @param #boolean evIsDeleted (optional) event is deleted
-- @param #string evForceUniqueId (optional) force an event uniqueId
-- @param #table evOptions (optional) event options
-- @return #string the event unique id
local function addCalendarEventByCalendarName(calstr, evName, evDT, evDur, evCreator, evUpdateDT, evIsDeleted, evForceUniqueId, evOptions)
	if calstr == nil or evName == nil or evDT == nil or evDur == nil or evCreator == nil then
		glog:error("addCalendarEventByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(evName) ~= "string" or type(evDT) ~= "string" or type(evDur) ~= "string" or type(evCreator) ~= "string" then
		glog:error("addCalendarEventByCalendarName: bad params type")
		return false
	elseif strlen(calstr) == 0 or strlen(evName) == 0 or strlen(evDT) == 0 or strlen(evDur) == 0 or strlen(evCreator) == 0 then
		glog:error("addCalendarEventByCalendarName: params are not in correct bounds")
		return false
	end

	glog:debug("in addCalendarEventByCalendarName(" .. calstr .. "," .. evName .. "," .. evDT .. "," .. evDur .. ")")
	
	local calid = getCalendarIdByName(calstr)
	if type(calid) == "number" then
		return addCalendarEvent(calid, evName, evDT, evDur, evCreator, evUpdateDT, evIsDeleted, evForceUniqueId, evOptions)
	else
		glog:error("addCalendarEventByCalendarName: cant get calendar id by name " .. calstr)
		return false
	end

end






--- get all events for a day in a specific calendar
-- @param #number calId calendar id
-- @param #number year year
-- @param #number month month
-- @param #number day day
-- @return #table table of all events, empty table if no event
local function getAllEventsDate(calId, year, month, day)
	if calId == nil or year == nil or month == nil or day == nil then
		glog:error("getAllEventsDate: params are nil")
		return false
	elseif type(calId) ~= "number" or type(year) ~= "number" or type(month) ~= "number" or type(day) ~= "number" then
		glog:error("getAllEventsDate: bad params type")
		return false
	elseif calId <= 0 or year < 1970 or month < 1 or month > 12 or day < 1 or day > 31 then
		glog:error("getAllEventsDate: params are not in correct bounds")
		return false
	end

	local returnData = {}
	
	-- select the calendar
	local calendar = getCalendarById(calId)
	if type(calendar) ~= "table" then
		glog:error("getAllEventsDate: cant get calendar id " .. tostring(calId))
		return false
	elseif calendar.events == nil then
		-- glog:info("getAllEventsDate: no calendar event")
		return returnData
	end
	
	-- get events from calendar
	local events = calendar.events
	if #events == 0 then
		return returnData
	end
	
	-- year-month formatting
	local dtStr = tostring(year) .. "-" .. strformat("%02d", month) .. "-" .. strformat("%02d", day)
	
	-- loop on all events
	for key,ev in pairs(events) do
		local evDate = strsub(ev.eventDateTime, 1, 10)
		
		-- catch all event for day wanted
		if evDate == dtStr then
			tinsert(returnData, deepcopy(ev))
		end
	end
	
	return returnData
end



--- get all events for a day by calendar name
-- @param #string calstr a calendar name
-- @param #number year year
-- @param #number month month
-- @param #number day day
-- @return #table table of all events, empty table if no event
local function getAllEventsDateByCalendarName(calstr, year, month, day)
	if calstr == nil or year == nil or month == nil or day == nil then
		glog:error("getAllEventsDateByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(year) ~= "number" or type(month) ~= "number" or type(day) ~= "number" then
		glog:error("getAllEventsDateByCalendarName: bad params type")
		return false
	end
	
	local calid = getCalendarIdByName(calstr)
	if type(calid) == "number" then
		return getAllEventsDate(calid, year, month, day)
	else
		glog:error("getAllEventsDateByCalendarName: cant get calendar id by name " .. calstr)
		return false
	end
end



--- get event by uniqueId, and calendar name
-- @param #string calstr calendar name
-- @param #string uniqueid uniq event id
-- @return #table table of all events, empty table if no event
local function getEventUniqueIdByCalendarName(calstr, uniqueid)
	if calstr == nil or uniqueid == nil then
		glog:error("getEventUniqueIdByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(uniqueid) ~= "string" then
		glog:error("getEventUniqueIdByCalendarName: bad params type")
		return false
	end
	
	local cal = getCalendarByName(calstr)
	if type(cal) == "table" then
		local events = cal.events
		for i=1,#events do
			if events[i].uniqueId == uniqueid then
				return deepcopy(events[i])
			end
		end
		glog:debug("getEventUniqueIdByCalendarName: cant find any event with uniqueId=" .. uniqueid)
		return false
	else
		glog:error("getEventUniqueIdByCalendarName: cant get calendar name " .. calstr)
		return false
	end
end



--- add (or replace) an event by uniqueid and calendar id. WARNING: "participants" table is ignored and eventCreator on replace !
-- @param #number calid calendar id
-- @param #string uniqueid the unique event id
-- @param #table event the event to add or replace
-- @return #boolean true if success, false on error
local function addReplaceEvent(calid, uniqueid, event)
	glog:debug("in addReplaceEvent")
	if calid == nil or uniqueid == nil or event == nil then
		glog:error("addReplaceEvent: params are nil")
		return false
	elseif type(calid) ~= "number" or type(uniqueid) ~= "string" or type(event) ~= "table" then
		glog:error("addReplaceEvent: bad params type")
		return false
	elseif testCalendarId(calid) == false or strlen(uniqueid) == 0 or testEvent(event, true) == false then
		glog:error("addReplaceEvent: bad params content")
		return false
	end
	
	local found = false
	for evKey,evData in ipairs(calendarData[calid].events) do -- loop on all events
	
		if evData.uniqueId == uniqueid then
			glog:debug("addReplaceEvent: event uniqueid found, replace event")
			calendarData[calid].events[evKey].eventName = event.eventName
			calendarData[calid].events[evKey].eventDateTime = event.eventDateTime
			calendarData[calid].events[evKey].eventDuration = event.eventDuration
			calendarData[calid].events[evKey].updateDate = event.updateDate
			calendarData[calid].events[evKey].isDeleted = event.isDeleted
			calendarData[calid].events[evKey].options = event.options
			return true
		end
	end
	
	-- cant found the event, add it
	glog:debug("addReplaceEvent: cant found uniqueid, add event")
	return addCalendarEvent(calid, event.eventName, event.eventDateTime, event.eventDuration, event.eventCreator, event.updateDate, event.isDeleted, uniqueid, event.options)
end



--- add (or replace) an event by uniqueid and calendar name. WARNING: "participants" table is ignored and eventCreator on replace !
-- @param #string calstr calendar name
-- @param #string uniqueid the unique event id
-- @param #table event the event to add or replace
-- @return #boolean true if success, false on error
local function addReplaceEventByCalendarName(calstr, uniqueid, event)
	-- TODO: add options param
	if calstr == nil or uniqueid == nil or event == nil then
		glog:error("addReplaceEventByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(uniqueid) ~= "string" or type(event) ~= "table" then
		glog:error("addReplaceEventByCalendarName: bad params type")
		return false
	end
	
	local calid = getCalendarIdByName(calstr)
	if type(calid) == "number" then
		return addReplaceEvent(calid, uniqueid, event)
	else
		glog:error("addReplaceEventByCalendarName: cant get calendar id by name " .. calstr)
		return false
	end
end



--- add (or replace) a participant status for an event (uniqueid) and calendar id
-- @param #number calid calendar id
-- @param #string uniqueid  the unique event id
-- @param #string playername player name
-- @param #string status status of the player
-- @param #string dt update datetime
-- @return #boolean true if success, false on error
local function addReplaceParticipant(calid, uniqueid, playername, status, dt)
	-- TODO: add options param
	glog:debug("in AddReplaceParticipant")
	if calid == nil or uniqueid == nil or playername == nil or status == nil then
		glog:error("AddReplaceParticipant: params are nil")
		return false
	elseif type(calid) ~= "number" or type(uniqueid) ~= "string" or type(playername) ~= "string" or type(status) ~= "string" then
		glog:error("AddReplaceParticipant: bad params type")
		return false
	elseif testCalendarId(calid) == false or strlen(uniqueid) == 0 or strlen(playername) == 0 then
		glog:error("AddReplaceParticipant: bad params content")
		return false
	elseif inTable({"present", "maybe", "discard"}, status) == false then
		glog:error("AddReplaceParticipant: bad status param")
		return false
	end
	
	local playerDateTime = getDateTimeNow()
	if dt ~= nil then
		if type(dt) ~= "string" then
			glog:error("AddReplaceParticipant: bad dt type")
			return false
		elseif testDateTime(dt) == false then
			glog:error("AddReplaceParticipant: dt is not a SQL datetime")
			return false
		end
		playerDateTime = dt
	end
	
	for evKey,evData in pairs(calendarData[calid].events) do
		if evData.uniqueId == uniqueid then
		
			-- looking for an participant entry
			for partKey,partData in pairs(calendarData[calid].events[evKey].participants) do
				if partData.playerName == playername then
					calendarData[calid].events[evKey].participants[partKey].playerStatus = status
					calendarData[calid].events[evKey].participants[partKey].playerDateTime = playerDateTime
					glog:debug("AddReplaceParticipant: found a participant entry(" .. tostring(partKey) .. "), update it")
					return true
				end
			end
			
			-- ok, not found, add a participant entry
			tinsert(calendarData[calid].events[evKey].participants, {playerName = playername, playerStatus = status, playerDateTime = playerDateTime})
			glog:debug("AddReplaceParticipant: not found the participant entry (" .. playername .. "), add it")
			return true
		end
	end
	
	glog:error("AddReplaceParticipant: cant add or replace participant, cant match event by uniqueid")
	return false
end



--- add (or replace) a participant status for an event (uniqueid) and calendar name
-- @param #string calstr calendar name
-- @param #string uniqueid the unique event id
-- @param #string playername player name
-- @param #string status status of the player
-- @param #string dt update datetime
-- @return #boolean true if success, false on error
local function addReplaceParticipantByCalendarName(calstr, uniqueid, playername, status, dt)
	-- TODO: add options param
	if calstr == nil or uniqueid == nil or playername == nil or status == nil then
		glog:error("addReplaceParticipantByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(uniqueid) ~= "string" or type(playername) ~= "string" or type(status) ~= "string" then
		glog:error("addReplaceParticipantByCalendarName: bad params type")
		return false
	end
	
	local calid = getCalendarIdByName(calstr)
	if type(calid) == "number" then
		return addReplaceParticipant(calid, uniqueid, playername, status, dt)
	else
		glog:error("addReplaceParticipantByCalendarName: cant get calendar id by name " .. calstr)
		return false
	end
end



--- get a participant by event uniqueid, calendar id and player name
-- @param #number calid calendar id
-- @param #string uniqueid the unique event id
-- @param #string playername player name
-- @return #table a participant, false on error
local function getParticipant(calid, uniqueid, playername)
	if calid == nil or uniqueid == nil or playername == nil then
		glog:error("getParticipant: params are nil")
		return false
	elseif type(calid) ~= "number" or type(uniqueid) ~= "string" or type(playername) ~= "string" then
		glog:error("getParticipant: bad params type")
		return false
	elseif testCalendarId(calid) == false or strlen(uniqueid) == 0 or strlen(playername) == 0 then
		glog:error("getParticipant: bad params content")
		return false
	end
	
	-- select the calendar
	local calendar = getCalendarById(calid)
	if type(calendar) ~= "table" then
		glog:error("getParticipant: cant get calendar id " .. tostring(calid))
		return false
	elseif calendar.events == nil then
		glog:info("getParticipant: no calendar event")
		return false
	end
	
	for evKey,evData in pairs(calendar.events) do
		if evData.uniqueId == uniqueid then
			local participants = evData.participants
			
			for partKey,partData in pairs(participants) do
				if partData.playerName == playername then
					return deepcopy(partData)
				end
			end
		end
	end
	
	glog:debug("getParticipant: cant find participant")
	return false
end



--- get a participant by event uniqueid, calendar name and player name
-- @param #string calstr calendar name
-- @param #string uniqueid the unique event id
-- @param #string playername player name
-- @return #table a participant, false on error
local function getParticipantByCalendarName(calstr, uniqueid, playername)
	if calstr == nil or uniqueid == nil or playername == nil then
		glog:error("getParticipantByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(uniqueid) ~= "string" or type(playername) ~= "string" then
		glog:error("getParticipantByCalendarName: bad params type")
		return false
	end
		
	local calid = getCalendarIdByName(calstr)
	if type(calid) == "number" then
		return getParticipant(calid, uniqueid, playername)
	else
		glog:error("getParticipant: cant get calendar id by name " .. calstr)
		return false
	end
end



--- test if a participant (playername+status) is registered in an event (uniqueid) and calendar id
-- @param #number calid calendar id
-- @param #string uniqueid the unique event id
-- @param #string playername player name
-- @param #string status status of the player
-- @return #boolean true if success, false on error
local function testParticipantNameStatus(calid, uniqueid, playername, status)
	if calid == nil or uniqueid == nil or playername == nil or status == nil then
		glog:error("testParticipantNameStatus: params are nil")
		return false
	elseif type(calid) ~= "number" or type(uniqueid) ~= "string" or type(playername) ~= "string" or type(status) ~= "string" then
		glog:error("testParticipantNameStatus: bad params type")
		return false
	elseif testCalendarId(calid) == false or strlen(uniqueid) == 0 or strlen(playername) == 0 then
		glog:error("testParticipantNameStatus: bad params content")
		return false
	elseif inTable({"present", "maybe", "discard"}, status) == false then
		glog:error("testParticipantNameStatus: bad status param")
		return false
	end
	
	-- select the calendar
	local calendar = getCalendarById(calid)
	if type(calendar) ~= "table" then
		glog:error("testParticipantNameStatus: cant get calendar id " .. tostring(calid))
		return false
	elseif calendar.events == nil then
		glog:info("testParticipantNameStatus: no calendar event")
		return false
	end
	
	for evKey,evData in pairs(calendar.events) do
		if evData.uniqueId == uniqueid then
			local participants = evData.participants
			
			for partKey,partData in pairs(participants) do
				if partData.playerName == playername and partData.playerStatus == status then
					glog:debug("testParticipantNameStatus: found participant playername+status")
					return true
				end
			end
		end
	end
	
	glog:debug("testParticipantNameStatus: cant find playername+status")
	return false
end



--- test if a participant (playername+status) is registered in an event (uniqueid) and calendar name
-- @param #string calstr calendar name
-- @param #string uniqueid the unique event id
-- @param #string playername player name
-- @param #string status status of the player
-- @return #boolean true if success, false on error
local function testParticipantNameStatusByCalendarName(calstr, uniqueid, playername, status)
	if calstr == nil or uniqueid == nil or playername == nil or status == nil then
		glog:error("testParticipantNameStatusByCalendarName: params are nil")
		return false
	elseif type(calstr) ~= "string" or type(uniqueid) ~= "string" or type(playername) ~= "string" or type(status) ~= "string" then
		glog:error("testParticipantNameStatusByCalendarName: bad params type")
		return false
	end
		
	local calid = getCalendarIdByName(calstr)
	if type(calid) == "number" then
		return testParticipantNameStatus(calid, uniqueid, playername, status)
	else
		glog:error("testParticipantNameStatusByCalendarName: cant get calendar id by name " .. calstr)
		return false
	end
end



---
-- get the offset days to show a month in 35 cells
-- @param #number year an integer year
-- @param #number month an integer month
-- @return a table of year, month, day
local function getOffsetDays(year, month)
	glog:debug("in getOffsetDays")
	local firstMonthDayWeekDay = getDayOfWeek(1, month, year) -- 1 = sunday, 7 = saturday
	if firstMonthDayWeekDay == 1 then -- flip day
		firstMonthDayWeekDay = 7
	elseif firstMonthDayWeekDay >= 2 then -- flip day
		firstMonthDayWeekDay = firstMonthDayWeekDay - 1
	end
	local incrementDay = subDaysDate(year, month, 1, firstMonthDayWeekDay - 1)
	return incrementDay
end



---
-- test if an integer "date" param is in bound
-- @param #number intValue must be an integer
-- @param #string mode mode
-- @return #boolean true if intValue is OK
local function testIntegerDate(intValue, mode)
	if mode == "year" then
		if intValue >= 1970 then return true end
	elseif mode == "month" then
		if intValue >= 1 and intValue <= 12 then return true end
	elseif mode == "day" then
		if intValue >= 1 and intValue <= 31 then return true end
	elseif mode == "hour" then
		if intValue >= 0 and intValue <= 23 then return true end
	elseif mode == "minute" then
		if intValue >= 0 and intValue <= 59 then return true end
	elseif mode == "second" then
		if intValue >= 0 and intValue <= 60 then return true end -- leap second...
	elseif mode == "durationhour" then
		if intValue >= 0 and intValue <= 12 then return true end
	elseif mode == "durationminute" then
		if intValue >= 0 and intValue <= 59 then return true end
	else
		glog:error("testIntegerDate: cant match any mode")
		return false
	end
	return false
end



---
-- convert a string datetime to epoch
-- @param #string strdt datetime to convert
-- @return #number an epoch value if success, false on error
local function convertStrDateTimeToEpoch(strdt)
	if strdt == nil then
		glog:error("convertStrDateTimeToEpoch: params are nil")
		return false
	elseif type(strdt) ~= "string" then
		glog:error("convertStrDateTimeToEpoch: bad params type")
		return false
	elseif testDateTime(strdt) == false then
		glog:error("convertStrDateTimeToEpoch: bad datetime format")
		return false
	end
	
	local runyear, runmonth, runday, runhour, runminute, runseconds = strmatch(strdt, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	if runyear == nil or runmonth == nil or runday == nil or runhour == nil or runminute == nil or runseconds == nil then
		glog:error("convertStrDateTimeToEpoch: cant parse datetime")
		return false
	end
	
	return ostime({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
end



---
-- compare 2 datetime
-- @param #string strdt1 a string date
-- @param #string strdt2 a string date
-- @return #number if return 1 => strdt1 > strdt2, if return -1 => strdt1 < strdt2, if return 0 => strdt1 == strdt2, return false on error
local function compareStrDateTime(strdt1, strdt2)
	if strdt1 == nil or strdt2 == nil then
		glog:error("compareStrDateTime: params are nil")
		return false
	elseif type(strdt1) ~= "string" or type(strdt2) ~= "string" then
		glog:error("compareStrDateTime: bad params type")
		return false
	elseif testDateTime(strdt1) == false or testDateTime(strdt2) == false then
		glog:error("compareStrDateTime: bad datetime format")
		return false
	end
	
	local epochStrDT1 = convertStrDateTimeToEpoch(strdt1)
	local epochStrDT2 = convertStrDateTimeToEpoch(strdt2)
	
	if type(epochStrDT1) ~= "number" or type(epochStrDT2) ~= "number" then
		glog:error("compareStrDateTime: bad parse in epoch")
		return false
	end
	
	if epochStrDT1 > epochStrDT2 then
		return 1
	elseif epochStrDT1 < epochStrDT2 then
		return -1
	else
		return 0
	end
end



---
-- serialize a message from table
-- @param #table dataTable data to serialize
-- @return #string a message to send, or false on error
local function serializeMessage(dataTable)
	if dataTable == nil then
		glog:error("serializeMessage: params are nil")
		return false
	elseif type(dataTable) ~= "table" then
		glog:error("serializeMessage: bad params type")
		return false
	elseif dataTable.calendarname == nil or dataTable.command == nil or dataTable.eventuid == nil or dataTable.data == nil then
		glog:error("serializeMessage: contents dataTable are nil")
		return false
	elseif type(dataTable.calendarname) ~= "string" or type(dataTable.command) ~= "string" or type(dataTable.eventuid) ~= "string" or type(dataTable.data) ~= "table" then
		glog:error("serializeMessage: contents dataTable bad types")
		return false
	end
	
	if DEVMODE == true and rover ~= nil then rover:AddWatch("serializeMessage: dataTable.data", dataTable.data) end
	local jsonData = JSON.encode(dataTable.data)
	if DEVMODE == true and rover ~= nil then rover:AddWatch("serializeMessage: jsonData", jsonData) end
	
	local ret = dataTable.calendarname .. "," .. dataTable.command .. "," .. dataTable.eventuid .. ",JSON:" .. jsonData
	glog:debug("serializeMessage: return " .. ret)
	return ret
end



---
-- unserialize a message from a string and convert it to table
-- @param #string serializedDataString a serialized table data
-- @return #table a message table, or false on error
local function unserializeMessage(serializedDataString)
	if serializedDataString == nil then
		glog:error("unserializeMessage: params are nil")
		return false
	elseif type(serializedDataString) ~= "string" then
		glog:error("unserializeMessage: bad params type")
		return false
	end
	
	if DEVMODE == true and rover ~= nil then rover:AddWatch("unserializeMessage: serializedDataString", serializedDataString) end
	
	local calendarnameStr, commandStr, eventuidStr, dataStr = strmatch(serializedDataString, "([^,]+),([^,]+),([^,]+),JSON:(.*)")
	if calendarnameStr == nil or commandStr == nil or eventuidStr == nil or dataStr == nil then
		glog:error("unserializeMessage: parsed string are nil")
		return false
	elseif strlen(calendarnameStr) == 0 or strlen(commandStr) == 0 or strlen(eventuidStr) == 0 then
		glog:error("unserializeMessage: parsed string are empty")
		return false
	end
	
	
	local data = JSON.decode(dataStr)
	if DEVMODE == true and rover ~= nil then rover:AddWatch("unserializeMessage: data", data) end
	if data == nil then
		glog:error("unserializeMessage: bad data format")
		return false
	elseif type(data) ~= "table" then
		glog:error("unserializeMessage: data is not a table")
		return false
	end
	
	local ret =	{
					calendarname = calendarnameStr,
					command = commandStr,
					eventuid = eventuidStr,
					data = data
				}
	if DEVMODE == true and rover ~= nil then rover:AddWatch("unserializeMessage: ret", ret) end
	return ret
end



---
-- generate a table message for an updateEvent message
-- @param #string channel the channel to send the message
-- @param #string calendarname the calendar name
-- @param #table event the event update to send
local function generateUpdateEventTableMessage(channel, calendarname, event)
	if channel == nil or calendarname == nil or event == nil then
		glog:error("generateUpdateEventTableMessage: params are nil")
		return false
	elseif type(channel) ~= "string" or type(calendarname) ~= "string" or type(event) ~= "table" then
		glog:error("generateUpdateEventTableMessage: bad params type")
		return false
	elseif strlen(channel) == 0 or strlen(calendarname) == 0 or testEvent(event, true) == false then
		glog:error("generateUpdateEventTableMessage: empty data")
		return false
	elseif (event.uniqueId) == nil then
		glog:error("generateUpdateEventTableMessage: uniqueId is nil")
		return false
	elseif type(event.uniqueId) ~= "string" then
		glog:error("generateUpdateEventTableMessage: uniqueId type is not string")
		return false
	elseif strlen(event.uniqueId) == 0 then
		glog:error("generateUpdateEventTableMessage: empty uniqueId")
		return false
	end
	
	local event = deepcopy(event)
	
	event.participants = nil -- osef
	local eventuid = event.uniqueId -- externalized
	event.uniqueId = nil -- osef
	
	return {channel = channel, calendarname = calendarname, command = "updateEvent", eventuid = eventuid, data = event}
	
end



---
-- generate a table message for an updateParticipant message
-- @param #string channel the channel to send the message
-- @param #string calendarname the calendar name
-- @param #string eventUniqueId event unique id
-- @param #table participant the participant update to send
local function generateUpdateParticipantTableMessage(channel, calendarname, eventUniqueId, participant)
	if channel == nil or calendarname == nil or eventUniqueId == nil or participant == nil then
		glog:error("generateUpdateParticipantTableMessage: params are nil")
		return false
	elseif type(channel) ~= "string" or type(calendarname) ~= "string" or type(eventUniqueId) ~= "string" or type(participant) ~= "table" then
		glog:error("generateUpdateParticipantTableMessage: bad params type")
		return false
	elseif strlen(channel) == 0 or strlen(calendarname) == 0 or strlen(eventUniqueId) == 0 or testParticipant(participant) == false then
		glog:error("generateUpdateParticipantTableMessage: empty data")
		return false
	end
	return {channel = channel, calendarname = calendarname, command = "updateParticipant", eventuid = eventUniqueId, data = deepcopy(participant)}
end


-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------



---
-- a new object YACalendar
-- @param #object o a variable
-- @return #object an YACalendar instance
function YACalendar:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
    -- init vars
	o.bDocLoaded = false -- boolean main xml doc is loaded
	o.bRestored = false -- boolean backup data is restored
	o.tRestoreData = nil -- table backup data
	o.xmlDoc = nil -- object XmlDoc object
	o.CONFIG = {} -- table current config
	o.wndMain = nil -- form main window
	o.wndCalEv = nil -- form show calendar events
	o.wndPartEv = nil -- form show calendar events
	o.wndConfig = nil -- form show config
	o.currentYearShown = nil -- number contain the current year show
	o.currentMonthShown = nil -- number contain the current month show
	o.currentDaySelected = nil -- table current day selected
	o.calEventsWindows = {} -- table all events shown in DayCalEvForm
	o.oldEditBoxContentAddEvForm = {} -- table all EditText content in AddEvForm
	
	return o
end



---
-- init the object
function YACalendar:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end



---
-- YACalendar OnLoad
function YACalendar:OnLoad()
	
	-- if DEVMODE is activated, push message in GeminiConsole
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
	if DEVMODE == true then
		glog = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender = "GeminiConsole"
		})
	else
		glog = GeminiLogging:GetLogger({
			level = GeminiLogging.ERROR,
			pattern = "%c %l - %m",
			appender = ""
		})
	end

	md5 = Apollo.GetPackage("LibMd5-1").tPackage
	rover = Apollo.GetAddon("Rover")
	DLG = Apollo.GetPackage("Gemini:LibDialog-1.0").tPackage
	JSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage
	
    -- load form file
	self.xmlDoc = XmlDoc.CreateFromFile("YACalendar.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	
end



---
-- event OnDocLoaded
function YACalendar:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "YACalendarMainForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
		self.wndCalEv = Apollo.LoadForm(self.xmlDoc, "YACalendarDayCalEvForm", nil, self)
		if self.wndCalEv == nil then
			Apollo.AddAddonErrorText(self, "Could not load the calendar events window for some reason.")
			return
		end
		
		self.wndPartEv = Apollo.LoadForm(self.xmlDoc, "YACalendarParticipateEvForm", nil, self)
		if self.wndPartEv == nil then
			Apollo.AddAddonErrorText(self, "Could not load the calendar participate event window for some reason.")
			return
		end
		
		self.wndAddEv = Apollo.LoadForm(self.xmlDoc, "YACalendarAddEvForm", nil, self)
		if self.wndAddEv == nil then
			Apollo.AddAddonErrorText(self, "Could not load the calendar add event window for some reason.")
			return
		end
		
		self.wndConfig = Apollo.LoadForm(self.xmlDoc, "YACalendarConfigForm", nil, self)
		if self.wndConfig == nil then
			Apollo.AddAddonErrorText(self, "Could not load the config window for some reason.")
			return
		end
		
		
		-- do not show any form
		self.wndMain:Show(false) -- main window
		self.wndCalEv:Show(false) -- events list for current day
		self.wndPartEv:Show(false) -- participants for current event
		self.wndAddEv:Show(false) -- create a new event
		self.wndConfig:Show(false) -- config window
		
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("yac", "mainFormToggle", self)
		
		
		-- timer for message queue management
		self.timer = ApolloTimer.Create(0.5, true, "OnTimer", self)
		
		
		-- DEBUG
		Apollo.RegisterSlashCommand("yacDEVMODE", "toggleDEVMODE", self)
		
		
		-- load config
		if self.bRestored == false and self.tRestoreData ~= nil then
			glog:info("config is not restored, restoring it")
			self:loadConfig(self.tRestoreData)
		end
		
		
		-- i18n
		local GeminiLocale = Apollo.GetPackage("Gemini:Locale-1.0").tPackage
		L = GeminiLocale:GetLocale("YACalendar", true)
		
		
		-- TODO: some tests to check for global objects (md5, DLG, JSON, L...)
		
		
		
		-- i18n: translate all window
		GeminiLocale:TranslateWindow(L, self.wndMain)
		GeminiLocale:TranslateWindow(L, self.wndCalEv)
		GeminiLocale:TranslateWindow(L, self.wndPartEv)
		GeminiLocale:TranslateWindow(L, self.wndAddEv)
		GeminiLocale:TranslateWindow(L, self.wndConfig)
		
		
		-- uppercase first char for all days textbox
		self.wndMain:FindChild("TextBoxMonday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxMonday"):GetText()))
		self.wndMain:FindChild("TextBoxTuesday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxTuesday"):GetText()))
		self.wndMain:FindChild("TextBoxWednesday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxWednesday"):GetText()))
		self.wndMain:FindChild("TextBoxThursday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxThursday"):GetText()))
		self.wndMain:FindChild("TextBoxFriday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxFriday"):GetText()))
		self.wndMain:FindChild("TextBoxSaturday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxSaturday"):GetText()))
		self.wndMain:FindChild("TextBoxSunday"):SetText(firstToUpper(self.wndMain:FindChild("TextBoxSunday"):GetText()))
		
		
		if self.currentYearShown == nil then
			self.currentYearShown = tonumber(osdate("%Y"))
		end
		if self.currentMonthShown == nil then
			self.currentMonthShown = tonumber(osdate("%m"))
		end
		
		
		-- hide debug button
		if DEVMODE == false then
			self.wndMain:FindChild("EchoButton"):Show(false)
			self.wndMain:FindChild("Action1Button"):Show(false)
			self.wndMain:FindChild("TestTimerButton"):Show(false)
			self.wndMain:FindChild("Act2Button"):Show(false)
			self.wndMain:FindChild("Title"):SetText("YACalendar")
		else
			self.wndMain:FindChild("Title"):SetText("YACalendar - DEVMODE")
		end
		
		
		-- loading dialog
		DLG:Register("JustAMessage",	{
											buttons = {
												{
													text = Apollo.GetString("CRB_Ok")
												},
											},
											OnShow =	function(settings, data)
															settings:SetText(data.text)
														end,
											text = "Error: no message passed",
											noCloseButton = true,
											hideOnEscape = true,
											showWhileDead = true,
											isExclusive = true,
										}
		)
		
		DLG:Register("OkDeleteCalendar", {
			buttons = {
				{
					text = Apollo.GetString("CRB_Yes"),
					OnClick = function(settings, data, reason)
						YACalendar:deleteCalendarYesButtonConfigForm(data.target, data.calIdDelete)
					end,
				},
				{
					color = "Red",
					text = Apollo.GetString("CRB_No")
				},
			},
			OnShow = function(settings, data)
				if data.text ~= nil and strlen(data.text) > 0 then
					settings:SetText(data.text)
				end
			end,
			text = "this is empty, this is a bug",
			noCloseButton = true,
			hideOnEscape = true,
			showWhileDead = true,
			isExclusive = true,
		})
		
		
		-- chan connect
		self:connectToChannels()
		
		self:createDelayedGetUpdateTimer()
		
		
		self.bDocLoaded = true -- used to be sure the addon is loaded
	end
end



-----------------------------------------------------------------------------------------------
-- YACalendar Functions
-----------------------------------------------------------------------------------------------



---
-- on event timer, queue management
function YACalendar:OnTimer()
	if #sendSyncData == 0 and #receivedSyncData == 0 then return false end
	glog:debug("in OnTimer()")
	
	
	-- get a data to send into a channel
	local sendData = tremove(sendSyncData, 1)
	
	if sendData ~= nil then -- data to send ?
		if channels[sendData.channel] ~= nil then
			local msg = serializeMessage(deepcopy(sendData))
			if type(msg) == "string" then
				glog:debug("OnTimer: send message: " .. msg)
				local retSendMessage = channels[sendData.channel]:SendMessage({strDeliver = msg})
				if retSendMessage == true then
					glog:info("OnTimer: message \"" .. msg .. "\" sent")
				else
					glog:warn("OnTimer: channel not ready, add message at the end")
					tinsert(sendSyncData, sendData)
				end
			else
				glog:error("OnTimer: cant serialize message")
			end
		else
			glog:error("OnTimer: message channel " .. tostring(sendData.channel) .. " is not available")
		end
	-- else
	-- 	glog:debug("OnTimer: sendSyncData is empty")
	end
	
	
	-- working with a copy of receivedSyncData
	local calendarModified = false
	local copyOfReceivedSyncData = deepcopy(receivedSyncData)
	receivedSyncData = {}
	
	for keyRSD, valueRSD in ipairs(copyOfReceivedSyncData) do
	
		-- get target-calendar
		local cal = getCalendarByName(valueRSD.calendarname)
		if type(cal) == "table" then
			
			-- getUpdate
			if valueRSD.command == "getUpdate" then
				glog:debug("OnTimer: exec a getUpdate")
				
				if #cal.events > 0 then
					for keyEv, valueEv in ipairs(cal.events) do
						
						
						-- push an updateEvent
						local messageEv = generateUpdateEventTableMessage(valueRSD.channel, valueRSD.calendarname, valueEv)
						if type(messageEv) == "table" then
							glog:debug("OnTimer: add an updateEvent message in sendSyncData")
							tinsert(sendSyncData, messageEv)
						else
							glog:error("OnTimer: cant generate updateEvent message, this is a bug, report it")
						end
						
						-- push all participants
						for keyvaluePart, valuePart in ipairs(valueEv.participants) do
							local messagePart = generateUpdateParticipantTableMessage(valueRSD.channel, valueRSD.calendarname, valueEv.uniqueId, valuePart)
							if type(messagePart) == "table" then
								glog:debug("OnTimer: add an updateParticipant message in sendSyncData")
								tinsert(sendSyncData, messagePart)
							else
								glog:error("OnTimer: cant generate updateParticipant message, this is a bug, report it")
							end
						end
					end
				else
					glog:debug("OnTimer: no event to send")
				end
				
			-- updateEvent
			elseif valueRSD.command == "updateEvent" then
				glog:debug("OnTimer: exec a updateEvent")
				
				local newEvent = deepcopy(valueRSD.data)
				local currentEvent = getEventUniqueIdByCalendarName(cal.name, valueRSD.eventuid)
				local okAddReplace = false
				
				if type(currentEvent) ~= "table" then
					glog:debug("OnTimer: cant find event unique id=" .. valueRSD.eventuid)
					okAddReplace = true
				elseif compareStrDateTime(newEvent.updateDate, currentEvent.updateDate) == 1 then -- if newDate > currentDate
					glog:debug("OnTimer: need to update event " .. currentEvent.eventName .. " " .. currentEvent.eventDateTime)
					okAddReplace = true
				else
					glog:debug("OnTimer: dont need to update event " .. currentEvent.eventName .. " " .. currentEvent.eventDateTime)
				end
				
				if okAddReplace == true then -- ok, we can update or add the event
					local addEvStatus = addReplaceEventByCalendarName(cal.name, valueRSD.eventuid, newEvent)
					if addEvStatus == false then
						glog:error("OnTimer: cant add/replace event")
					else
						glog:debug("OnTimer: event integrated (" .. newEvent.eventName .. ")")
						calendarModified = true
					end
				end
			
			-- updateParticipant
			elseif valueRSD.command == "updateParticipant" then
				glog:debug("OnTimer: exec a updateParticipant")
				
				local newParticipant = deepcopy(valueRSD.data)
				local currentParticipant = getParticipantByCalendarName(cal.name ,valueRSD.eventuid, newParticipant.playerName)
				local okAddReplace = false
				
				if type(currentParticipant) ~= "table" then
					glog:debug("OnTimer: cant find participant uniqueId=" .. valueRSD.eventuid .. " playername=" .. newParticipant.playerName)
					okAddReplace = true
				elseif compareStrDateTime(newParticipant.playerDateTime, currentParticipant.playerDateTime) == 1 then -- if newDate > currentDate
					glog:debug("OnTimer: need to update participant " .. currentParticipant.playerName .. " " .. currentParticipant.playerStatus)
					okAddReplace = true
				else
					glog:debug("OnTimer: dont need to update participant " .. currentParticipant.playerName .. " " .. currentParticipant.playerStatus)
				end
				
				if okAddReplace == true then -- ok, we can update or add the event
					local addPartStatus = addReplaceParticipantByCalendarName(cal.name, valueRSD.eventuid, newParticipant.playerName, newParticipant.playerStatus, newParticipant.playerDateTime)
					if addPartStatus == false then
						glog:error("OnTimer: cant add/replace participant")
					else
						glog:debug("OnTimer: participant integrated (" .. newParticipant.playerName .. ")")
						calendarModified = true
					end
				end
			else
				glog:error("OnTimer: unknown command, skip it (this is a bug, report it)")
			end
			
		else
			glog:error("OnTimer: calendar " .. valueRSD.calendarname .. " does not exist, this is a bug. report it.")
		end
		
	end
	
	if calendarModified == true then
		glog:debug("OnTimer: calendar modified, reload main window")
		self:loadCurrentCalendarWindow()
	end
	
end



---
-- format a datetime to his string equivalent
-- @param #string strFormat i18n tag
-- @param #table tDT datetime table
-- @return #string
function YACalendar:formatDateTime(strFormat, tDT)
	if strFormat == nil or tDT == nil then
		glog:error("formatDateTime: params are nil")
		return false
	elseif type(strFormat) ~= "string" or type(tDT) ~= "table" then
		glog:error("formatDateTime: params are bad type")
		return false
	elseif strlen(strFormat) == 0 then
		glog:error("formatDateTime: params are not ok")
		return false
	elseif tDT.year < 1970 or tDT.month < 1 or tDT.month > 12 or tDT.day < 1 or tDT.day > 31 then
		glog:error("formatDateTime: tDT, bad date values")
		return false
	end
	
	if tDT.hour == nil then
		tDT.hour = 0
	end
	if tDT.minute == nil then
		tDT.minute = 0
	end
	if tDT.second == nil then
		tDT.second = 0
	end
	
	local tWeekday = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"} -- these tag is in i18n
	local weekdayid = getDayOfWeek(tDT.day, tDT.month, tDT.year) -- 1 = sunday, 7 = saturday
	local weekdayStr = L[tWeekday[weekdayid]]
	
	local tMonth = {"january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"} -- these tag is in i18n
	local monthStr = tostring(L[tMonth[tDT.month]])
	
	local hourStr = tostring(tDT.hour)
	if tDT.hour <= 9 then
		hourStr = "0" .. tostring(tDT.hour)
	end
	
	local minuteStr = tostring(tDT.minute)
	if tDT.minute <= 9 then
		minuteStr = "0" .. tostring(tDT.minute)
	end
	
	local secondStr = tostring(tDT.second)
	if tDT.second <= 9 then
		secondStr = "0" .. tostring(tDT.second)
	end
	
	return String_GetWeaselString(L[strFormat], tostring(tDT.year), tostring(tDT.month), tostring(tDT.day), hourStr, minuteStr, secondStr, weekdayStr, monthStr)
end



-----------------------------------------------------------------------------------------------
-- YACalendarForm Functions
-----------------------------------------------------------------------------------------------



-- enable/disable DEVMODE
function YACalendar:toggleDEVMODE()
	if DEVMODE == false then
		DEVMODE = true
		Print "YAC DEVMODE enabled, you need to /reloadui"
	else
		DEVMODE = false
		Print "YAC DEVMODE disabled, you need to /reloadui"
	end
	
end



---
-- on SlashCommand "/yac", or hiding with close button
function YACalendar:mainFormToggle()
	if self.wndMain:IsShown() then
		self.wndMain:Show(false,true)
		self.wndCalEv:Close()
		self.wndPartEv:Close()
		self.wndAddEv:Close()
	else
		self.wndMain:Show(true,true)
	end
	
end



---
-- create a delayed getUpdate message on all channels
function YACalendar:createDelayedGetUpdateTimer()
	glog:debug("in getUpdateAllCalendar")
	self.getUpdateDelayTimer = ApolloTimer.Create(3.0, false, "getUpdateAllCalendar", self)
end



---
-- send a getUpdate on all channels
function YACalendar:getUpdateAllCalendar()
	glog:debug("in getUpdateAllCalendar")

	for calKey, calValue in ipairs(calendarData) do
		local d =	{
						channel			= generateChannelName(calValue.name, calValue.salt),
						calendarname 	= calValue.name,
						command			= "getUpdate",
						eventuid		= "osef",
						data			= {}
					}
		tinsert(sendSyncData, d)
	end
end



---
-- test method
function YACalendar:OnClickACT2Button(wndHandler, wndControl, eMouseButton)
	glog:debug("in OnClickACT2Button()")
	
	local cal = getCalendarByName(self.CONFIG.currentCalendar)
	local d =	{
					channel			= generateChannelName(cal.name, cal.salt),
					calendarname 	= cal.name,
					command			= "getUpdate",
					eventuid		= "dfsdf5345sdfsdfs",
					data			= {}
				}
	
	tinsert(sendSyncData, d)
	
	if DEVMODE == true and rover ~= nil then rover:AddWatch("OnClickACT2Button: sendSyncData", sendSyncData) end
	if DEVMODE == true and rover ~= nil then rover:AddWatch("OnClickACT2Button: receivedSyncData", receivedSyncData) end
	
end



---
-- tests method
function YACalendar:Action1()

	-- calendar flip, load dev data
	local TMPCAL = deepcopy(calendarData)
	calendarData = deepcopy(calDatDEVDATA)
	

	glog:info("TEST TEST")
	-- ChatSystemLib:JoinChannel("testOMG")
	
	local test = "omg wtf bbq"
	glog:info("md5: " .. md5:hash(test))

	local tmpCalendar1 = getCalendarById(1)
	rover:AddWatch("tmpCalendar1", tmpCalendar1)
	local tmpCalendar2 = getCalendarById(0)
	rover:AddWatch("tmpCalendar2", tmpCalendar2)
	local tmpCalendar3 = getCalendarByName("")
	rover:AddWatch("tmpCalendar3", tmpCalendar3)
	local tmpCalendar4 = getCalendarByName("a calendar name")
	rover:AddWatch("tmpCalendar4", tmpCalendar4)

	setCalendarName(1, "the is a new name")
	setCalendarSalt(1, "the is a new saaaaaalt")
	
	addCalendar("a new calendar 42", "salt 42")
	addCalendar("a new calendar 43", "salt 43")
	deleteCalendar(3)
	
	local aVar = getRandomUniqueId("omfg")
	Print(aVar)
	aVar = getRandomUniqueId("omfg")
	Print(aVar)
	aVar = getRandomUniqueId("bla")
	Print(aVar)
	
	local dtnow = getDateTimeNow()
	glog:debug("dtnow=" .. dtnow)
	
	local dt = getDateTimeFrom(1982, 8, 25, 12, 50, 42)
	glog:debug("dt=" .. dt)
	
	dt = getDateTimeFrom(1941, 8, 25, 12, 50, 42)
	glog:debug("dt=" .. dt)
	
	dt = getDateTimeFrom(1982, 0, 25, 12, 50, 42)
	glog:debug("dt=" .. dt)
	
	dt = getDateTimeFrom(1982, 8, 0, 12, 50, 42)
	glog:debug("dt=" .. dt)
	
	dt = getDateTimeFrom(1982, 8, 25, 24, 50, 42)
	glog:debug("dt=" .. dt)
	
	dt = getDateTimeFrom(1982, 8, 25, 12, 61, 42)
	glog:debug("dt=" .. dt)
	
	dt = getDateTimeFrom(1982, 8, 25, 12, 50, 62)
	glog:debug("dt=" .. dt)
	
	local dtTestResult1 = testDateTime("2014-08-25 12:50:42")
	local dtTestResult2 = testDateTime("2sdqsdsq014-08-25 12:50:42")
	local dtTestResult3 = testDateTime("2014-08-25 12::42")
	rover:AddWatch("dtTestResult1", dtTestResult1)
	rover:AddWatch("dtTestResult2", dtTestResult2)
	rover:AddWatch("dtTestResult3", dtTestResult3)
	
	local durTestResult1 = testDuration("01:42")
	local durTestResult2 = testDuration("0dd1:42")
	local durTestResult3 = testDuration(":42")
	rover:AddWatch("durTestResult1", durTestResult1)
	rover:AddWatch("durTestResult2", durTestResult2)
	rover:AddWatch("durTestResult3", durTestResult3)
	
	addCalendarEvent(1, "event truc", "2014-08-25 12:50:42", "02:00")
	
	
	local testAddDay1 = addDaysDate(2014, 8)
	local testAddDay2 = addDaysDate(2014, 8, "bla")
	local testAddDay3 = addDaysDate(2014, 8, 25)
	local testAddDay4 = addDaysDate(2014, 8, 25, 10)
	local testAddDay5 = addDaysDate(2000, 2, 28)
	local testAddDay6 = addDaysDate(2000, 2, 28, 2)
	local testAddDay7 = addDaysDate(2014, 12, 31)
	rover:AddWatch("testAddDay1", testAddDay1)
	rover:AddWatch("testAddDay2", testAddDay2)
	rover:AddWatch("testAddDay3", testAddDay3)
	rover:AddWatch("testAddDay4", testAddDay4)
	rover:AddWatch("testAddDay5", testAddDay5)
	rover:AddWatch("testAddDay6", testAddDay6)
	rover:AddWatch("testAddDay7", testAddDay7)
	
	
	local testSubDay1 = subDaysDate(2014, 8)
	local testSubDay2 = subDaysDate(2014, 8, "bla")
	local testSubDay3 = subDaysDate(2014, 8, 25)
	local testSubDay4 = subDaysDate(2014, 8, 25, 25)
	local testSubDay5 = subDaysDate(2000, 3, 1)
	local testSubDay6 = subDaysDate(2000, 3, 1, 3)
	local testSubDay7 = subDaysDate(2014, 1, 1)
	rover:AddWatch("testSubDay1", testSubDay1)
	rover:AddWatch("testSubDay2", testSubDay2)
	rover:AddWatch("testSubDay3", testSubDay3)
	rover:AddWatch("testSubDay4", testSubDay4)
	rover:AddWatch("testSubDay5", testSubDay5)
	rover:AddWatch("testSubDay6", testSubDay6)
	rover:AddWatch("testSubDay7", testSubDay7)
	
	
	
	local testGetAllEventsDate1 = getAllEventsDate(0)
	local testGetAllEventsDate2 = getAllEventsDate("1", 2014, 8, 25)
	local testGetAllEventsDate3 = getAllEventsDate(1, "2014", 8, 25)
	local testGetAllEventsDate4 = getAllEventsDate(1, 2014, "8", 25)
	local testGetAllEventsDate5 = getAllEventsDate(1, 2014, 8, "25")
	local testGetAllEventsDate6 = getAllEventsDate(1, 2014, 8, 25)
	local testGetAllEventsDate7 = getAllEventsDate(1, 2014, 8, 24)
	local testGetAllEventsDate8 = getAllEventsDate(2, 2014, 8, 24)
	rover:AddWatch("testGetAllEventsDate1", testGetAllEventsDate1)
	rover:AddWatch("testGetAllEventsDate2", testGetAllEventsDate2)
	rover:AddWatch("testGetAllEventsDate3", testGetAllEventsDate3)
	rover:AddWatch("testGetAllEventsDate4", testGetAllEventsDate4)
	rover:AddWatch("testGetAllEventsDate5", testGetAllEventsDate5)
	rover:AddWatch("testGetAllEventsDate6", testGetAllEventsDate6)
	rover:AddWatch("testGetAllEventsDate7", testGetAllEventsDate7)
	rover:AddWatch("testGetAllEventsDate8", testGetAllEventsDate8)
	
	
	
	local testGetAllEventsDateByCalendarName1 = getAllEventsDateByCalendarName("phoque", 2014, 8, 25)
	local testGetAllEventsDateByCalendarName2 = getAllEventsDateByCalendarName("the is a new name", 2014, 8, 25)
	local testGetAllEventsDateByCalendarName3 = getAllEventsDateByCalendarName("an empty calendar name", 2014, 8, 25)
	rover:AddWatch("testGetAllEventsDateByCalendarName1", testGetAllEventsDateByCalendarName1)
	rover:AddWatch("testGetAllEventsDateByCalendarName2", testGetAllEventsDateByCalendarName2)
	rover:AddWatch("testGetAllEventsDateByCalendarName3", testGetAllEventsDateByCalendarName3)
	
	
	
	local testInTable1 = inTable()
	local testInTable2 = inTable("bla", "erf")
	local testInTable3 = inTable({}, {})
	local testInTable4 = inTable({}, "test")
	local testInTable5 = inTable({}, 42)
	local testInTable6 = inTable({"truc", "bla", "pouet", "test"}, "test")
	local testInTable7 = inTable({1, 2, 3, 4, 42, 84}, 42)
	local testInTable8 = inTable({1, 2, 3, 4, 42, 84}, "42")
	local testInTable9 = inTable({true, false}, true)
	local testInTable10 = inTable({true, false}, "42")
	rover:AddWatch("testInTable1", testInTable1)
	rover:AddWatch("testInTable2", testInTable2)
	rover:AddWatch("testInTable3", testInTable3)
	rover:AddWatch("testInTable4", testInTable4)
	rover:AddWatch("testInTable5", testInTable5)
	rover:AddWatch("testInTable6", testInTable6)
	rover:AddWatch("testInTable7", testInTable7)
	rover:AddWatch("testInTable8", testInTable8)
	rover:AddWatch("testInTable9", testInTable9)
	rover:AddWatch("testInTable10", testInTable10)
	
	
	
	local testAddReplaceParticipant1 = addReplaceParticipant()
	local testAddReplaceParticipant2 = addReplaceParticipant("", "bla", "erf", "present")
	local testAddReplaceParticipant3 = addReplaceParticipant(1, 4, "erf", "present")
	local testAddReplaceParticipant4 = addReplaceParticipant(1, "bla", 2, "present")
	local testAddReplaceParticipant5 = addReplaceParticipant(1, "bla", 2, 1)
	local testAddReplaceParticipant6 = addReplaceParticipant(1, "bla", "erf", "pouet")
	local testAddReplaceParticipant7 = addReplaceParticipant(1, "OMG a MD5 sign 2", "player42", "discard")
	local testAddReplaceParticipant8 = addReplaceParticipant(1, "OMG a MD5 sign 2", "player3", "present")
	rover:AddWatch("testAddReplaceParticipant1", testAddReplaceParticipant1)
	rover:AddWatch("testAddReplaceParticipant2", testAddReplaceParticipant2)
	rover:AddWatch("testAddReplaceParticipant3", testAddReplaceParticipant3)
	rover:AddWatch("testAddReplaceParticipant4", testAddReplaceParticipant4)
	rover:AddWatch("testAddReplaceParticipant5", testAddReplaceParticipant5)
	rover:AddWatch("testAddReplaceParticipant6", testAddReplaceParticipant6)
	rover:AddWatch("testAddReplaceParticipant7", testAddReplaceParticipant7)
	rover:AddWatch("testAddReplaceParticipant8", testAddReplaceParticipant8)
	
	
	
	local testTestParticipantNameStatus1 = testParticipantNameStatus()
	local testTestParticipantNameStatus2 = testParticipantNameStatus("", "bla", "erf", "present")
	local testTestParticipantNameStatus3 = testParticipantNameStatus(1, 4, "erf", "present")
	local testTestParticipantNameStatus4 = testParticipantNameStatus(1, "bla", 2, "present")
	local testTestParticipantNameStatus5 = testParticipantNameStatus(1, "bla", 2, 1)
	local testTestParticipantNameStatus6 = testParticipantNameStatus(1, "bla", "erf", "pouet")
	local testTestParticipantNameStatus7 = testParticipantNameStatus(1, "OMG a MD5 sign 2", "player42", "discard")
	local testTestParticipantNameStatus8 = testParticipantNameStatus(1, "OMG a MD5 sign 2", "player42", "present")
	rover:AddWatch("testTestParticipantNameStatus1", testTestParticipantNameStatus1)
	rover:AddWatch("testTestParticipantNameStatus2", testTestParticipantNameStatus2)
	rover:AddWatch("testTestParticipantNameStatus3", testTestParticipantNameStatus3)
	rover:AddWatch("testTestParticipantNameStatus4", testTestParticipantNameStatus4)
	rover:AddWatch("testTestParticipantNameStatus5", testTestParticipantNameStatus5)
	rover:AddWatch("testTestParticipantNameStatus6", testTestParticipantNameStatus6)
	rover:AddWatch("testTestParticipantNameStatus7", testTestParticipantNameStatus7)
	rover:AddWatch("testTestParticipantNameStatus8", testTestParticipantNameStatus8)
	
	
	
	local testConvertStrDateTimeToEpoch1 = convertStrDateTimeToEpoch()
	local testConvertStrDateTimeToEpoch2 = convertStrDateTimeToEpoch(42)
	local testConvertStrDateTimeToEpoch3 = convertStrDateTimeToEpoch("42-42")
	local testConvertStrDateTimeToEpoch4 = convertStrDateTimeToEpoch("1969-08-25 10:10:42")
	local testConvertStrDateTimeToEpoch5 = convertStrDateTimeToEpoch("2014-08-25 10:10:42")
	rover:AddWatch("testConvertStrDateTimeToEpoch1", testConvertStrDateTimeToEpoch1)
	rover:AddWatch("testConvertStrDateTimeToEpoch2", testConvertStrDateTimeToEpoch2)
	rover:AddWatch("testConvertStrDateTimeToEpoch3", testConvertStrDateTimeToEpoch3)
	rover:AddWatch("testConvertStrDateTimeToEpoch4", testConvertStrDateTimeToEpoch4)
	rover:AddWatch("testConvertStrDateTimeToEpoch5", testConvertStrDateTimeToEpoch5)
	
	
	
	local testCompareStrDateTime1 = compareStrDateTime()
	local testCompareStrDateTime2 = compareStrDateTime(42, "2014-08-25 10:10:42")
	local testCompareStrDateTime3 = compareStrDateTime("2014-08-24 10:10:42", 42)
	local testCompareStrDateTime4 = compareStrDateTime("1969-08-25 10:10:42", "1969-08-25 10:10:42")
	local testCompareStrDateTime5 = compareStrDateTime("2014-08-25 10:10:43", "2014-08-25 10:10:42")
	local testCompareStrDateTime6 = compareStrDateTime("2014-08-25 10:10:42", "2014-08-25 10:10:43")
	local testCompareStrDateTime7 = compareStrDateTime("2014-08-25 10:10:42", "2014-08-25 10:10:42")
	rover:AddWatch("testCompareStrDateTime1", testCompareStrDateTime1)
	rover:AddWatch("testCompareStrDateTime2", testCompareStrDateTime2)
	rover:AddWatch("testCompareStrDateTime3", testCompareStrDateTime3)
	rover:AddWatch("testCompareStrDateTime4", testCompareStrDateTime4)
	rover:AddWatch("testCompareStrDateTime5", testCompareStrDateTime5)
	rover:AddWatch("testCompareStrDateTime6", testCompareStrDateTime6)
	rover:AddWatch("testCompareStrDateTime7", testCompareStrDateTime7)
	
	
	
	local testTestEvent1 = testEvent()
	local testTestEvent2 = testEvent({})
	local testTestEvent3 = testEvent({ uniqueId = nil, eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent4 = testEvent({ uniqueId = "erferf", eventName = nil, eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent5 = testEvent({ uniqueId = "erferf", eventName = "blabla", eventDateTime = nil, eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent6 = testEvent({ uniqueId = "erferf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = nil, updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent7 = testEvent({ uniqueId = "erferf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = nil, isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent8 = testEvent({ uniqueId = "erferf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = nil, eventCreator = "bla", participants = {} })
	local testTestEvent9 = testEvent({ uniqueId = "erferf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = nil, participants = {} })
	local testTestEvent10 = testEvent({ uniqueId = "erferf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = nil })
	local testTestEvent11 = testEvent({ uniqueId = 0, eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent12 = testEvent({ uniqueId = "erf", eventName = 0, eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent13 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = 0, eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent14 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = 0, updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent15 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = 0, isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent16 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = 0, eventCreator = "bla", participants = {} })
	local testTestEvent17 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = 0, participants = {} })
	local testTestEvent18 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = 0 })
	local testTestEvent19 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testTestEvent20 = testEvent({ uniqueId = 424242, eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} }, true)
	local testTestEvent21 = testEvent({ uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = "DFDSFDSF" }, true)
	rover:AddWatch("testTestEvent1", testTestEvent1)
	rover:AddWatch("testTestEvent2", testTestEvent2)
	rover:AddWatch("testTestEvent3", testTestEvent3)
	rover:AddWatch("testTestEvent4", testTestEvent4)
	rover:AddWatch("testTestEvent5", testTestEvent5)
	rover:AddWatch("testTestEvent6", testTestEvent6)
	rover:AddWatch("testTestEvent7", testTestEvent7)
	rover:AddWatch("testTestEvent8", testTestEvent8)
	rover:AddWatch("testTestEvent9", testTestEvent9)
	rover:AddWatch("testTestEvent10", testTestEvent10)
	rover:AddWatch("testTestEvent11", testTestEvent11)
	rover:AddWatch("testTestEvent12", testTestEvent12)
	rover:AddWatch("testTestEvent13", testTestEvent13)
	rover:AddWatch("testTestEvent14", testTestEvent14)
	rover:AddWatch("testTestEvent15", testTestEvent15)
	rover:AddWatch("testTestEvent16", testTestEvent16)
	rover:AddWatch("testTestEvent17", testTestEvent17)
	rover:AddWatch("testTestEvent18", testTestEvent18)
	rover:AddWatch("testTestEvent19", testTestEvent19)
	rover:AddWatch("testTestEvent20", testTestEvent20)
	rover:AddWatch("testTestEvent21", testTestEvent21)
	
	
	
	local testSerializeMessage1 = serializeMessage()
	local testSerializeMessage2 = serializeMessage({})
	local testSerializeMessage3 = serializeMessage({ calendarname = 0, command = "truc", eventuid = "dfsf", data = { truc = "bla" } })
	local testSerializeMessage4 = serializeMessage({ calendarname = "bla", command = 0, eventuid = "dfsf", data = { truc = "bla" } })
	local testSerializeMessage5 = serializeMessage({ calendarname = "bla", command = "truc", eventuid = 0, data = { truc = "bla" } })
	local testSerializeMessage6 = serializeMessage({ calendarname = "bla", command = "truc", eventuid = "dfsf", data = 0 })
	local testSerializeMessage7 = serializeMessage({ calendarname = "bla", command = "truc", eventuid = "dfsf", data = { truc = "bla" } })
	rover:AddWatch("testSerializeMessage1", testSerializeMessage1)
	rover:AddWatch("testSerializeMessage2", testSerializeMessage2)
	rover:AddWatch("testSerializeMessage3", testSerializeMessage3)
	rover:AddWatch("testSerializeMessage4", testSerializeMessage4)
	rover:AddWatch("testSerializeMessage5", testSerializeMessage5)
	rover:AddWatch("testSerializeMessage6", testSerializeMessage6)
	rover:AddWatch("testSerializeMessage7", testSerializeMessage7)
	
	
	
	local testSplit1 = split()
	local testSplit2 = split(nil, ",")
	local testSplit3 = split("bla", nil)
	local testSplit4 = split("", "")
	local testSplit5 = split("erf,truc,bla", ",")
	local testSplit6 = split("erf|truc|bla", "|")
	rover:AddWatch("testSplit1", testSplit1)
	rover:AddWatch("testSplit2", testSplit2)
	rover:AddWatch("testSplit3", testSplit3)
	rover:AddWatch("testSplit4", testSplit4)
	rover:AddWatch("testSplit5", testSplit5)
	rover:AddWatch("testSplit6", testSplit6)
	
	
	
	local testUnserializeMessage1 = unserializeMessage()
	local testUnserializeMessage2 = unserializeMessage("")
	local testUnserializeMessage3 = unserializeMessage(",,,")
	local testUnserializeMessage4 = unserializeMessage("bla,truc,dfsf,truc=bla|erf=bzz")
	rover:AddWatch("testUnserializeMessage1", testUnserializeMessage1)
	rover:AddWatch("testUnserializeMessage2", testUnserializeMessage2)
	rover:AddWatch("testUnserializeMessage3", testUnserializeMessage3)
	rover:AddWatch("testUnserializeMessage4", testUnserializeMessage4)
	
	
	
	local testGenerateUpdateEventTableMessage1 = generateUpdateEventTableMessage()
	local testGenerateUpdateEventTableMessage2 = generateUpdateEventTableMessage(0, "calendarname", { uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testGenerateUpdateEventTableMessage3 = generateUpdateEventTableMessage("channel", 0, { uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testGenerateUpdateEventTableMessage4 = generateUpdateEventTableMessage("channel", "calendarname", 0)
	local testGenerateUpdateEventTableMessage5 = generateUpdateEventTableMessage("channel", "calendarname", { uniqueId = "erf", eventName = 0, eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	local testGenerateUpdateEventTableMessage6 = generateUpdateEventTableMessage("channel", "calendarname", { uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = 0 })
	local testGenerateUpdateEventTableMessage7 = generateUpdateEventTableMessage("channel", "calendarname", { uniqueId = "erf", eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla", participants = {} })
	rover:AddWatch("testGenerateUpdateEventTableMessage1", testGenerateUpdateEventTableMessage1)
	rover:AddWatch("testGenerateUpdateEventTableMessage2", testGenerateUpdateEventTableMessage2)
	rover:AddWatch("testGenerateUpdateEventTableMessage3", testGenerateUpdateEventTableMessage3)
	rover:AddWatch("testGenerateUpdateEventTableMessage4", testGenerateUpdateEventTableMessage4)
	rover:AddWatch("testGenerateUpdateEventTableMessage5", testGenerateUpdateEventTableMessage5)
	rover:AddWatch("testGenerateUpdateEventTableMessage6", testGenerateUpdateEventTableMessage6)
	rover:AddWatch("testGenerateUpdateEventTableMessage7", testGenerateUpdateEventTableMessage7)
	
	
	
	local testAddReplaceEvent1 = addReplaceEvent()
	local testAddReplaceEvent2 = addReplaceEvent("", "OMG a MD5 sign 2", { eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla" })
	local testAddReplaceEvent3 = addReplaceEvent(1, 0, { eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla" })
	local testAddReplaceEvent4 = addReplaceEvent(1, "OMG a MD5 sign 2", { eventName = 0, eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla" })
	local testAddReplaceEvent5 = addReplaceEvent(1, "OMG a MD5 sign 2", { eventName = "blabla", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla" })
	local testAddReplaceEvent6 = addReplaceEvent(1, "DSQDSQSDSDQS", { eventName = "ERFERF", eventDateTime = "2014-08-25 10:10:42", eventDuration = "02:00", updateDate = "2014-08-25 10:10:42", isDeleted = false, eventCreator = "bla" })
	rover:AddWatch("testAddReplaceEvent1", testAddReplaceEvent1)
	rover:AddWatch("testAddReplaceEvent2", testAddReplaceEvent2)
	rover:AddWatch("testAddReplaceEvent3", testAddReplaceEvent3)
	rover:AddWatch("testAddReplaceEvent4", testAddReplaceEvent4)
	rover:AddWatch("testAddReplaceEvent5", testAddReplaceEvent5)
	rover:AddWatch("testAddReplaceEvent6", testAddReplaceEvent6)
	
	
	
	local testTestParticipant1 = testParticipant()
	local testTestParticipant2 = testParticipant({})
	local testTestParticipant3 = testParticipant({playerName = 0, playerDateTime = "2014-08-25 10:10:42", playerStatus = "maybe"})
	local testTestParticipant4 = testParticipant({playerName = "a player name", playerDateTime = 0, playerStatus = "maybe"})
	local testTestParticipant5 = testParticipant({playerName = "a player name", playerDateTime = "2014-08-25 10:10:42", playerStatus = 0})
	local testTestParticipant6 = testParticipant({playerName = "a player name", playerDateTime = "2014-08-25 10:10:42", playerStatus = "pouet"})
	local testTestParticipant7 = testParticipant({playerName = "a player name", playerDateTime = "2014-08-25 10:10:42", playerStatus = "maybe"})
	rover:AddWatch("testTestParticipant1", testTestParticipant1)
	rover:AddWatch("testTestParticipant2", testTestParticipant2)
	rover:AddWatch("testTestParticipant3", testTestParticipant3)
	rover:AddWatch("testTestParticipant4", testTestParticipant4)
	rover:AddWatch("testTestParticipant5", testTestParticipant5)
	rover:AddWatch("testTestParticipant6", testTestParticipant6)
	rover:AddWatch("testTestParticipant7", testTestParticipant7)
	
	
	local testGetParticipant1 = getParticipant()
	local testGetParticipant2 = getParticipant("", "OMG a MD5 sign 2", "player42")
	local testGetParticipant3 = getParticipant(1, 0, "player42")
	local testGetParticipant4 = getParticipant(1, "OMG a MD5 sign 2", 0)
	local testGetParticipant5 = getParticipant(1, "OMG a MD5 sign 2", "player42")
	rover:AddWatch("testGetParticipant1", testGetParticipant1)
	rover:AddWatch("testGetParticipant2", testGetParticipant2)
	rover:AddWatch("testGetParticipant3", testGetParticipant3)
	rover:AddWatch("testGetParticipant4", testGetParticipant4)
	rover:AddWatch("testGetParticipant5", testGetParticipant5)
	
	
	
	
	local guilds = GuildLib.GetGuilds()
	rover:AddWatch("guilds", guilds)
	
	local guildType = GuildLib.GuildType_Guild
	
	
	rover:AddWatch("calendarData", calendarData)
	rover:AddWatch("Action1: self", self)
	rover:AddWatch("Action1: self.CONFIG", self.CONFIG)
	
	
	-- restore backup calendarData
	calendarData = deepcopy(TMPCAL)

end



---
-- 
function YACalendar:EchoActionButtonClick()
	if (self.echoChannel == false) then
		self.echoChannel = true
		glog:info("channel echo activated")
	else
		self.echoChannel = false
		glog:info("channel echo disabled")
	end
end



---
-- for debug
function YACalendar:OnMyMsg(strCommand, strArg)
	glog:info(strformat("[MyChannel] Sending: %s", strArg))
	self.channel:SendMessage({strDeliver = strArg})
end



---
-- connect to all calendar channels
function YACalendar:connectToChannels()
	glog:debug("in connectToChannels")
	

	-- loop on all calendar and connect to all channel
	local goodChannels = {}
	for calId,calValue in pairs(calendarData) do
		local channelName = generateChannelName(calValue.name, calValue.salt)
		tinsert(goodChannels, channelName)
		if channels[channelName] == nil then
		
			-- set a named wrapper for msgReceived()
			local wrapperName = "WrapperMsgReceived" .. channelName
			self[wrapperName] = function(osef, channel, tMsg, strSender) return YACalendar.msgReceived(channel, tMsg, strSender, channelName) end
			
			-- join to channel and connect him to the wrapper
			channels[channelName] = ICCommLib.JoinChannel(channelName, wrapperName, self)
			glog:info("connected to channel: \"" .. channelName .. "\" name=" .. calValue.name .. " salt=" .. calValue.salt)
		else
			glog:debug("already connected to channel " .. channelName .. " (for calendar " .. calValue.name .. ")")
		end
	end
	
	-- delete other channel
	for channelName,channelContent in pairs(channels) do
		if inTable(goodChannels, channelName) == false then
			glog:debug("deleting channel " .. channelName)
			channels[channelName] = nil
		end
	end
	
end



---
-- on message received from a channel, this function needs to be wrapped
-- @param #object channel
-- @param #table tMsg
-- @param #string strSender the message sender
-- @param #string channelStr the channel name
function YACalendar.msgReceived(channel, tMsg, strSender, channelStr)
	if channel == nil or tMsg == nil or strSender == nil or channelStr == nil then
		glog:debug("msgReceived: params are nil")
		return false
	elseif type(channel) ~= "userdata" or type(tMsg) ~= "table" or type(strSender) ~= "string" or type(channelStr) ~= "string" then
		glog:debug("msgReceived: bad type params")
		return false
	elseif strlen(strSender) == 0 or strlen(channelStr) == 0 then
		glog:debug("msgReceived: channelStr is empty")
		return false
	elseif tMsg.strDeliver == nil then
		glog:debug("msgReceived: no message")
		return false
	elseif type(tMsg.strDeliver) ~= "string" then
		glog:debug("msgReceived: message is not a string")
		return false
	elseif strlen(tMsg.strDeliver) == 0 then
		glog:debug("msgReceived: message is an empty string")
		return false
	end
	
	glog:debug(strformat("msgReceived: Received message: %s", tMsg.strDeliver))
	
	local d = unserializeMessage(deepcopy(tMsg.strDeliver))
	if type(d) ~= "table" then
		glog:error("msgReceived: cant parse message: " .. tMsg.strDeliver)
		return false
	end
	
	-- {
	-- 	channel						= "YACazeazeaz2312eazeaze"
	-- 	calendarname				= "testcal"
	-- 	command						= "getUpdate" or "updateEvent" or "updateParticipant"
	-- 	eventuid					= "dfsdf5345sdfsdfs"
	-- 	data (getUpdate)			= {}
	-- 	data (updateEvent)			= {eventName = "...", eventDateTime = "2014-08-03 20:30:00", eventDuration = "01:00", updateDate = "2014-08-03 16:18:42", isDeleted = true or false}
	-- 	data (updateParticipant)	= {playerName = "...", playerDateTime = "2014-08-04 20:25:42", playerStatus = "present" or "decline" or "maybe"}
	-- }

	-- check calendarname
	if testCalendarName(d.calendarname) == false then
		glog:error("msgReceived: calendar \"" .. d.calendarname .. "\" does not exist")
		return false
	end
	
	-- check if calendar sign => USELESS!
	-- local cal = getCalendarByName(d.calendarname)
	-- if generateChannelName(cal.name, cal.salt) ~= channelStr then
	-- 	glog:error("msgReceived: bad calendar sign")
	-- 	return false
	-- else
	-- 	glog:debug("msgReceived: sign is OK") -- TODO: delete this "else" because useless
	-- end
	
	-- check event uniq id
	if strlen(d.eventuid) == 0 then
		glog:error("msgReceived: eventuid is empty")
		return false
	end
	
	-- check command
	if d.command == "getUpdate" then
		-- no specific check...
		
	elseif d.command == "updateEvent" then
	
		-- check data for command updateEvent
		if testEvent(d.data, true) == false then
			glog:error("msgReceived: bad data values")
			return false
		end
		
	elseif d.command == "updateParticipant" then
		
		-- check data for command updateParticipant
		if testParticipant(d.data) == false then
			glog:error("msgReceived: bad data values")
			return false
		end
		
	else
		glog:error("msgReceived: command \"" .. d.command .. "\" does not exist")
		return false
	end
	glog:debug("msgReceived: this is a " .. d.command .. " command")
	
	
	-- add sender to received data
	d.sender = strSender
	
	-- add channel to received data
	d.channel = channelStr
	
	-- add data to received queue
	tinsert(receivedSyncData, d)
	
end



-----------------------------------------------------------------------------------------------
-- daycal cells management
-----------------------------------------------------------------------------------------------



---
-- load the current calendar into window
-- @return #boolean false on error, true on success
function YACalendar:loadCurrentCalendarWindow()
	glog:debug("in loadCurrentCalendarWindow()")
	
	if DEVMODE == true and rover ~= nil then rover:AddWatch("loadCurrentCalendarWindow: calendarData", calendarData) end
	
	
	
	-- connect to all cal chan
	self:connectToChannels()
	
	
	-- test if current calendar is ok
	if self.CONFIG.currentCalendar == nil or strlen(self.CONFIG.currentCalendar) == 0 or testCalendarName(self.CONFIG.currentCalendar) == false then
		if calendarData ~= nil and #calendarData >= 1 then
			self.CONFIG.currentCalendar = calendarData[1].name
			glog:debug("loadCurrentCalendarWindow: set currentCalendar to \"" .. self.CONFIG.currentCalendar .. "\"")
		else
			glog:error("loadCurrentCalendarWindow: there is no calendar to load")
			-- TODO: clear all day
			return false
		end
	end
	glog:info("loadCurrentCalendarWindow: currentCalendar \"" .. self.CONFIG.currentCalendar .. "\"")
	
	
	-- update calendar name in main window
	self.wndMain:FindChild("CalendarName"):SetText(self.CONFIG.currentCalendar)
	
	
	-- reset daycal cells
	local ret = self:resetDayCalCells()
	if ret == false then
		glog:error("loadCurrentCalendarWindow: major error, cant reset cells")
		return false
	end
	
	
	-- color applied if current cell contains events
	local eventBGColor = ApolloColor.new(1, 1, 1, 1)
	local eventTextColor = ApolloColor.new(1, 0, 0, 1)
	
	local incrementDay = getOffsetDays(self.currentYearShown, self.currentMonthShown)
	
	
	-- loop for all daycal cells
	for i=1,35 do
		local daybox = self.wndMain:FindChild("DayCal" .. i)
		if daybox == nil then
			glog:error("loadCurrentCalendarWindow: cant find cell")
			return false
		end
		
		local eventsDay = getAllEventsDateByCalendarName(self.CONFIG.currentCalendar, incrementDay.year, incrementDay.month, incrementDay.day)
		
		if eventsDay ~= nil and type(eventsDay) == "table" and #eventsDay > 0 then
		
			-- is there any visible events ? (isDeleted == false)
			local visibleEvents = 0
			for j=1,#eventsDay do
				if eventsDay[j].isDeleted == false then
					visibleEvents = visibleEvents + 1
				end
			end
			
			if visibleEvents > 0 then
				--glog:debug("loadCurrentCalendarWindow: FOUND EVENT ! " .. ev.eventName .. " " .. ev.eventDateTime .. " " .. ev.uniqueId)
				daybox:ChangeArt("BK3:UI_BK3_Holo_Snippet")
				daybox:SetBGColor(eventBGColor)
				daybox:SetNormalTextColor(eventTextColor)
				daybox:SetDisabledTextColor(eventTextColor)
			end
		end
		
		incrementDay = addDaysDate(incrementDay.year, incrementDay.month, incrementDay.day)
	end
	
	return true
end



---
-- load the current calendar into window
-- @return #boolean false on error, true on success
function YACalendar:resetDayCalCells()
	glog:debug("in resetDayCalCells")
	
	local currentYearShownStr = tostring(self.currentYearShown)
	local currentMonthShownStrNumber = tostring(self.currentMonthShown)
	if self.currentMonthShown <= 9 then
		currentMonthShownStrNumber = "0" .. tostring(self.currentMonthShown)
	end
	local currentMonthShownStr = strlower(osdate("%B", ostime{year=self.currentYearShown, month=self.currentMonthShown, day=1}))
	
	
	-- show current year-month text
	self.wndMain:FindChild("YearMonthWindow"):SetText(firstToUpper(L[currentMonthShownStr]) .. " " .. currentYearShownStr)
	
	
	-- color of cells
	local defaultBGColorDark = ApolloColor.new(0.2, 0.2, 0.2, 1)
	local defaultBGColorLight = ApolloColor.new(0.5, 0.5, 0.5, 1)
	local defaultTextColorDark = ApolloColor.new(0.2, 0.2, 0.2, 1)
	local defaultTextColorLight = ApolloColor.new(0.6, 0.6, 0.6, 1)
	
	
	local incrementDay = getOffsetDays(self.currentYearShown, self.currentMonthShown)
	
	
	-- for each daycal cells
	for i=1,35 do
		local daybox = self.wndMain:FindChild("DayCal" .. i)
		if daybox == nil then
			glog:error("resetDayCalCells: cant find cell")
			return false
		end
		
		
		-- reset current cell
		daybox:SetText(tostring(incrementDay.day))
		if incrementDay.month == self.currentMonthShown then
			daybox:SetBGColor(defaultBGColorLight)
			daybox:SetNormalTextColor(defaultTextColorLight)
			daybox:SetDisabledTextColor(defaultTextColorLight)
		else
			daybox:SetBGColor(defaultBGColorDark)
			daybox:SetNormalTextColor(defaultTextColorDark)
			daybox:SetDisabledTextColor(defaultTextColorDark)
		end
		daybox:ChangeArt("AbilitiesSprites:spr_StatBlueVertProg")
		
		incrementDay = addDaysDate(incrementDay.year, incrementDay.month, incrementDay.day)
	end
	
end



-----------------------------------------------------------------------------------------------
-- Button YM events
-----------------------------------------------------------------------------------------------



function YACalendar:OnClickYMNext()
	self.currentMonthShown = self.currentMonthShown + 1
	if self.currentMonthShown > 12 then
		self.currentYearShown = self.currentYearShown + 1
		self.currentMonthShown = 1
	end
	self:loadCurrentCalendarWindow()
end



function YACalendar:OnClickYMBack()
	self.currentMonthShown = self.currentMonthShown - 1
	if self.currentMonthShown == 0 then
		self.currentYearShown = self.currentYearShown - 1
		self.currentMonthShown = 12
	end
	self:loadCurrentCalendarWindow()
end



-----------------------------------------------------------------------------------------------
-- Config/Settings management
-----------------------------------------------------------------------------------------------



---
-- set settings to his default value
function YACalendar:DefaultSettings()
	glog:debug("in DefaultSettings")
	if #self.CONFIG == 0 then
		glog:debug("DefaultSettings: loading default settings")
		self.CONFIG = deepcopy(defaults)
	else
		glog:warn("DefaultSettings: self.CONFIG is not nil, cant delete content")
		
	end
end



---
-- save settings
-- @param #number eType level of save operation
-- @return #table settings to save
function YACalendar:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	self.CONFIG.cal = deepcopy(calendarData)

	-- main window position
	local mainAnchorPoints = {self.wndMain:GetAnchorPoints()}
	local mainAnchorOffsets = {self.wndMain:GetAnchorOffsets()}
	self.CONFIG.mainAnchorPoints = deepcopy(mainAnchorPoints)
	self.CONFIG.mainAnchorOffsets = deepcopy(mainAnchorOffsets)
	
	-- participate window position
	local partAnchorPoints = {self.wndPartEv:GetAnchorPoints()}
	local partAnchorOffsets = {self.wndPartEv:GetAnchorOffsets()}
	self.CONFIG.partAnchorPoints = deepcopy(partAnchorPoints)
	self.CONFIG.partAnchorOffsets = deepcopy(partAnchorOffsets)
	
	-- hack to force backup the right "setting compatibility version"
	if self.CONFIG.compatibility == nil then
		self.CONFIG.compatibility = defaults.compatibility
	end
	
	if DEVMODE == true then
		self.CONFIG.DEVMODE = true
	else
		self.CONFIG.DEVMODE = false
	end
	
	
	return deepcopy(self.CONFIG)
end



---
-- @param #number eType level of save operation
-- @param #table t data to restore in context
-- @return #mixed return nil if this is not the good level
function YACalendar:OnRestore(eType, t)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	-- glog:debug("in OnRestore")

	if self.bDocLoaded then
		-- glog:debug("call loadConfig")
		self:loadConfig(deepcopy(t))
	else
		-- glog:debug("set t in tRestoreData")
		self.tRestoreData = deepcopy(t)
	end

end



---
-- @param #table t load the configuration in current context
function YACalendar:loadConfig(t)
	glog:debug("in loadConfig")

	
	if t ~= nil and type(t) == "table" then
		self.CONFIG = deepcopy(t)
		
		local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage -- debug ?
		if self.CONFIG.DEVMODE == true then
			DEVMODE = true
			glog = GeminiLogging:GetLogger({
				level = GeminiLogging.DEBUG,
				pattern = "%d %n %c %l - %m",
				appender = "GeminiConsole"
			})
		else
			DEVMODE = false
			glog = GeminiLogging:GetLogger({
				level = GeminiLogging.ERROR,
				pattern = "%c %l - %m",
				appender = ""
			})
		end
		
		if self.CONFIG.compatibility ~= defaults.compatibility then
			glog:warn("loadConfig: not compatible configuration, reset settings")
			self:DefaultSettings()
		end
		
		-- if self.CONFIG.mainAnchorPoints ~= nil and type(self.CONFIG.mainAnchorPoints) == "table" then
		-- 	self.wndMain:SetAnchorPoints(unpack(self.CONFIG.mainAnchorPoints))
		-- 	glog:debug("loadConfig: loaded mainAnchorPoints")
		-- end
		
		-- left, top, right, bottom
		if self.CONFIG.mainAnchorOffsets ~= nil and type(self.CONFIG.mainAnchorOffsets) == "table" then
			local leftNew, topNew, osef1, osef2 = unpack(self.CONFIG.mainAnchorOffsets)
			local leftOld, topOld, rightOld, bottomOld = self.wndMain:GetAnchorOffsets()
			self.wndMain:SetAnchorOffsets(leftNew, topNew, leftNew+(rightOld-leftOld), topNew+(bottomOld-topOld))
			glog:debug("loadConfig: loaded mainAnchorOffsets")
		end
		
		-- if self.CONFIG.partAnchorPoints ~= nil and type(self.CONFIG.partAnchorPoints) == "table" then
		-- 	self.wndPartEv:SetAnchorPoints(unpack(self.CONFIG.partAnchorPoints))
		-- 	glog:debug("loadConfig: loaded partAnchorPoints")
		-- end
		
		if self.CONFIG.partAnchorOffsets ~= nil and type(self.CONFIG.partAnchorOffsets) == "table" then
			local leftNew, topNew, osef1, osef2 = unpack(self.CONFIG.partAnchorOffsets)
			local leftOld, topOld, rightOld, bottomOld = self.wndPartEv:GetAnchorOffsets()
			self.wndPartEv:SetAnchorOffsets(leftNew, topNew, leftNew+(rightOld-leftOld), topNew+(bottomOld-topOld))
			glog:debug("loadConfig: loaded partAnchorOffsets")
		end
		
		-- all calendar data
		calendarData = deepcopy(t.cal)
		
		
		-- get player guild
		local playerGuildName = ""
		local playerGuilds = GuildLib.GetGuilds()
		for key,guild in pairs(playerGuilds) do
			if guild:GetType() == GuildLib.GuildType_Guild then
				playerGuildName = guild:GetName()
			end
		end
		
		glog:debug("loadConfig: playerGuildName=" .. playerGuildName)
		
		local foundGuildCalendar = false
		
		-- delete all guild calendar if player is not guilded
		for key,cal in pairs(calendarData) do
			if cal.isGuild == true then
				if strlen(playerGuildName) > 0 and cal.name == playerGuildName then
					foundGuildCalendar = true
					glog:debug("loadConfig: found guild calendar \"" .. cal.name .. "\", id=" .. tostring(key))
				else
					glog:info("loadConfig: delete calendar \"" .. cal.name .. "\", you are not in this guild")
					deleteCalendar(key)
				end
			end
		end
		
		
		-- add guild calendar if not found
		if strlen(playerGuildName) > 0 and foundGuildCalendar == false then
			glog:info("loadConfig: auto add guild calendar")
			-- TODO: need to get salt in the guild "more info"
			local salt = getRandomUniqueId("raf")
			salt = salt:sub(1, 8) -- get 8 chars, it's enough
			addCalendar(playerGuildName, salt, true)
		end
		
	else
		glog:debug("loadConfig: t is nil or not a table, loading default settings")
		self:DefaultSettings()
	end
	
	
	-- delete all calendar data, and push development data
	-- if DEVMODE == true then -- DEBUG
	-- 	calendarData = deepcopy(calDatDEVDATA)
	-- end
	
	self.bRestored = true
end



---------------------------------------------------------------------------------------------------
-- YACalendarMainForm Functions
---------------------------------------------------------------------------------------------------



---
-- event on show the main form
-- @param #object wndHandler handler
-- @param #object wndControl control
function YACalendar:OnShowMainForm(wndHandler, wndControl)
	glog:debug("in OnShowMainForm: wndHandler=" .. wndHandler:GetName() .. " wndControl=" .. wndControl:GetName())
	if wndControl:GetName() == "YACalendarMainForm" then
		self:loadCurrentCalendarWindow()
	end
end



---
-- event on click in daycal cells
-- @param #object wndHandler handler
-- @param #object wndControl control
function YACalendar:OnClickDayCal(wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation)
	-- Print("Click on " .. wndHandler:GetName())
	
	local osef1, osef2, dayCalId = strfind(wndHandler:GetName(), "^DayCal(%d+)$")
	if dayCalId == nil then
		glog:error("OnClickDayCal: cant match DayCal cell id")
		return false
	end
	
	dayCalId = tonumber(dayCalId)
	if dayCalId < 1 or dayCalId > 35 then
		glog:error("OnClickDayCal: bad DayCal cell id")
		return false
	end
	
	glog:info("OnClickDayCal: DayCal cell id=" .. tostring(dayCalId))
	
	local selectedDay = getOffsetDays(self.currentYearShown, self.currentMonthShown)
	if type(selectedDay) ~= "table" then
		glog:error("OnClickDayCal: cant get offset")
		return false
	end
	selectedDay = addDaysDate(selectedDay.year, selectedDay.month, selectedDay.day, dayCalId-1)
	if type(selectedDay) ~= "table" then
		glog:error("OnClickDayCal: failed to add days on offset")
		return false
	end
	self.currentDaySelected = deepcopy(selectedDay)
	self.wndCalEv:Show(true, true)
	self.wndCalEv:ToFront()
	
	self.wndPartEv:Show(false)
	
end



function YACalendar:OnClickConfigButtonMainForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "ConfigButton" then
		return false
	end
	glog:debug("in OnClickConfigButtonMainForm()")
	self.wndConfig:Show(true)
end



function YACalendar:OnClickCalendarBackNextButtonMainForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "CalendarBackButton" and wndControl:GetName() ~= "CalendarNextButton" then
		return false
	end
	glog:debug("in OnClickCalendarBackNextButtonMainForm()")
	
	local way = ""
	
	if strfind(wndControl:GetName(), "Back") ~= nil then
		way = "back"
	elseif strfind(wndControl:GetName(), "Next") ~= nil then
		way = "next"
	else
		glog:error("OnClickCalendarBackNextButtonMainForm: cant get way")
		return false
	end
	
	if self.CONFIG.currentCalendar == nil then
		glog:error("OnClickCalendarBackNextButtonMainForm: no current calendar")
		return false
	end
	
	local calid = getCalendarIdByName(self.CONFIG.currentCalendar)
	
	if way == "next" then
		calid = calid + 1
		if calid > #calendarData then
			calid = 1
		end
	else
		calid = calid - 1
		if calid == 0 then
			calid = #calendarData
		end
	end
	
	local calendar = getCalendarById(calid)
	if calendar == nil then
		glog:error("OnClickCalendarBackNextButtonMainForm: cant get calendar " .. tostring(calid))
		return false
	elseif type(calendar) ~= "table" then
		glog:error("OnClickCalendarBackNextButtonMainForm: calendar " .. tostring(calid) .. " is not a table")
		return false
	end
	
	glog:info("OnClickCalendarBackNextButtonMainForm: set current calendar to " .. calendar.name)
	self.CONFIG.currentCalendar = deepcopy(calendar.name)
	
	self:loadCurrentCalendarWindow()
	
end



---------------------------------------------------------------------------------------------------
-- YACalendarDayCalEvForm Functions
---------------------------------------------------------------------------------------------------



---
-- event on show the main form
-- @param #object wndHandler handler
-- @param #object wndControl control
function YACalendar:OnShowDayCalEvForm(wndHandler, wndControl)
	if wndControl:GetName() ~= "YACalendarDayCalEvForm" then
		return false
	end
	glog:debug("in OnShowDayCalEvForm: " .. wndHandler:GetName())
	
	if self.CONFIG.currentCalendar == nil then
		glog:error("OnShowDayCalEvForm: currentCalendar is nil")
		return false
	elseif type(self.CONFIG.currentCalendar) ~= "string" then
		glog:error("OnShowDayCalEvForm: currentCalendar is not a string")
		return false
	elseif strlen(self.CONFIG.currentCalendar) == 0 then
		glog:error("OnShowDayCalEvForm: currentCalendar is an empty string")
		return false
	end
	
	if self.currentDaySelected == nil then
		glog:error("OnShowDayCalEvForm: self.currentDaySelected is nil")
		return false
	elseif type(self.currentDaySelected) ~= "table" then
		glog:error("OnShowDayCalEvForm: self.currentDaySelected is not a table")
		return false
	end
	
	local titleText = firstToUpper(self:formatDateTime("completeDate", self.currentDaySelected))
	
	wndHandler:FindChild("Title"):SetText(titleText)

	-- move DayCalEv form near main window
	local oMain1, oMain2, oMain3, oMain4 = self.wndMain:GetAnchorOffsets()
	self.wndCalEv:SetAnchorOffsets(oMain3-4, oMain2, oMain3+400, oMain2+600)
	
	self:refreshAllEventsDay()
end



function YACalendar:refreshAllEventsDay()
	glog:debug("in refreshAllEventsDay")
	
	if self.wndCalEv:IsVisible() == false then
		glog:debug("wndCalEv is not visible, no need to refresh")
		return false
	end
	
	-- hide all boxes
	self:hideAllEventsDayCalEvForm()
	
	-- loop on all events for current day and update boxes
	local eventsDay = getAllEventsDateByCalendarName(self.CONFIG.currentCalendar, self.currentDaySelected.year, self.currentDaySelected.month, self.currentDaySelected.day)
	if type(eventsDay) ~= "table" then
		glog:error("refreshAllEventsDay: bad type of eventsDay")
		return false
	end
	
	
	-- get all events date and sort it
	if DEVMODE == true and rover ~= nil then rover:AddWatch("refreshAllEventsDay: eventsDay before", eventsDay) end
	tsort(eventsDay, 
		function(a,b)
			local aEpoch = convertStrDateTimeToEpoch(a.eventDateTime)
			local bEpoch = convertStrDateTimeToEpoch(b.eventDateTime)
			return aEpoch < bEpoch
		end
	)
	if rover ~= nil then rover:AddWatch("refreshAllEventsDay: eventsDay after", eventsDay) end
	
	
	-- loop on all events and show only not deleted
	for i=1,#eventsDay do
		if eventsDay[i].isDeleted == false then
			self:updateEventDayCalEvForm(i, eventsDay[i])
		end
	end
end



---
-- update and show an event in DayCalEvForm
-- @param #number evPos position in event list
-- @param #table evData event data to show
-- @return #boolean false on error
function YACalendar:updateEventDayCalEvForm(evPos, evData)
	glog:debug("in updateEventDayCalEvForm(" .. evPos .. ", data..)")
	
	if evPos == nil or evData == nil then
		glog:error("updateEventDayCalEvForm: 1 or more params are nil")
		return false
	elseif type(evPos) ~= "number" or type(evData) ~= "table" then
		glog:error("updateEventDayCalEvForm: bad param type")
		return false
	end
	
	-- get EventList window
	local evList = self.wndCalEv:FindChild("EventList")
	if evList == nil then
		glog:error("cant find window child EventList")
		return false
	end
	
	
	if self.calEventsWindows == nil then -- init self.calEventsWindows if nil
		self.calEventsWindows = {}
	end
	
	
	-- if current slot/position is empty, creating it
	if self.calEventsWindows[evPos] == nil then
		local eventWindow = Apollo.LoadForm(self.xmlDoc, "EventFrameTpl", evList, self)
		if eventWindow == nil then
			glog:error("updateEventDayCalEvForm: cant load form EventFrameTpl")
			return false
		end
		self.calEventsWindows[evPos] = eventWindow
	end
	
	local evDT = parseDateTime(evData.eventDateTime)
	
	self.calEventsWindows[evPos]:FindChild("EventTitle"):SetText(strformat("%02d", evDT.hour) .. ":" .. strformat("%02d", evDT.minute) .. " - ".. evData.eventName)
	self.calEventsWindows[evPos]:FindChild("ParticipateButton"):SetData(evData.uniqueId)
	
	-- reset participant icon
	self.calEventsWindows[evPos]:FindChild("PlayerStatusIcon"):SetSprite("")
	
	-- get participants informations
	local presentCounter = 0
	local discardCounter = 0
	local maybeCounter = 0
	local playerStatus = "" -- player participate status ?
	for partKey, partValue in ipairs(evData.participants) do
	
		-- test if player is participating to this event
		if partValue.playerName == GameLib.GetPlayerUnit():GetName() then
			if partValue.playerStatus == "present" then
				self.calEventsWindows[evPos]:FindChild("PlayerStatusIcon"):SetSprite("ClientSprites:QuestJewel_Complete_Green")
			elseif partValue.playerStatus == "maybe" then
				self.calEventsWindows[evPos]:FindChild("PlayerStatusIcon"):SetSprite("CRB_QuestTrackerSprites:btnQT_QuestLogNormal") -- ClientSprites:QuestJewel_Incomplete_Green
			else
				self.calEventsWindows[evPos]:FindChild("PlayerStatusIcon"):SetSprite("ClientSprites:QuestJewel_Decline")
			end
		end
	
		if partValue.playerStatus == "present" then
			presentCounter = presentCounter + 1
		elseif partValue.playerStatus == "discard" then
			discardCounter = discardCounter + 1
		else
			maybeCounter = maybeCounter + 1
		end
	end
	
	
	
	
	-- update participants detail frame
	local partStr = L["participant"]
	if #evData.participants >= 2 then
		partStr = L["participants"]
	end
	local participantsDetailStr = String_GetWeaselString(L["participantsdetail"], tostring(#evData.participants), partStr, L["comingcolon"] .. " " .. tostring(presentCounter), L["notcomingcolon"] .. " " .. tostring(discardCounter), L["uncertaincolon"] .. " " .. tostring(maybeCounter))
	self.calEventsWindows[evPos]:FindChild("PartDetail"):SetText(participantsDetailStr)
	
	-- show the window
	self.calEventsWindows[evPos]:Show(true)
	
	-- vertically align the list
	evList:ArrangeChildrenVert()
	
	return true
end



---
-- hide all events in DayCalEvForm
-- @return #boolean false on error
function YACalendar:hideAllEventsDayCalEvForm(daycalForm)
	--glog:debug("in hideAllEventsDayCalEvForm(" .. daycalForm:GetName() .. ")")
	glog:debug("in hideAllEventsDayCalEvForm()")
	
	
	if self.calEventsWindows == nil then -- init self.calEventsWindows if nil, and return (no event windows...)
		self.calEventsWindows = {}
		return true
	end
	
	-- get EventList window
	local evList = self.wndCalEv:FindChild("EventList")
	if evList == nil then
		glog:error("cant find window child EventList")
		return false
	end
	
	local children = evList:GetChildren()
	for key,child in pairs(children) do
		child:Show(false)
	end
	
	evList:ArrangeChildrenVert()
	
	return true
end



function YACalendar:OnClickDayCalEvClose(wndHandler, wndControl, eMouseButton)
	glog:debug("in OnClickDayCalEvClose()")
	self.wndCalEv:Close() -- hide the window
end



function YACalendar:OnHideDayCalEvForm(wndHandler, wndControl)
	if wndControl:GetName() ~= "YACalendarDayCalEvForm" then
		return false
	end
	glog:debug("in OnHideDayCalEvForm()")
end



function YACalendar:OnClickAddEventDayCalEvForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "AddEventButton" then
		return false
	end
	glog:debug("in OnClickAddEventDayCalEvForm()")
	self.wndCalEv:Close()
	self.wndAddEv:Show(true)
	self.wndAddEv:ToFront()
end



---------------------------------------------------------------------------------------------------
-- YACalendarParticipateEvForm Functions
---------------------------------------------------------------------------------------------------


---
-- on event ButtonSignal in button "close" in ParticipateEvForm form
function YACalendar:OnClickParticipateEvClose(wndHandler, wndControl, eMouseButton)
	glog:debug("in OnClickParticipateEvClose()")
	self.wndPartEv:Close() -- hide the window
end



---
-- on event WindowShow of ParticipateEvForm form
function YACalendar:OnShowPartEvForm(wndHandler, wndControl)
	if wndControl:GetName() ~= "YACalendarParticipateEvForm" then
		return false
	end

	if strlen(wndControl:GetData()) == 0 then
		glog:error("OnShowPartEvForm: no uniqueId, bug?")
		return false
	end
	
	if wndControl:GetName() ~= "YACalendarParticipateEvForm" then
		return false
	end
	glog:debug("in OnShowPartEvForm()")
	
	
	local uniqueIdEvent = wndControl:GetData()
	
	local event = getEventUniqueIdByCalendarName(self.CONFIG.currentCalendar, uniqueIdEvent)
	if type(event) ~= "table" then
		glog:error("OnShowPartEvForm: cant get event by uniqueId " .. uniqueIdEvent)
		return false
	end
	-- headers
	wndControl:FindChild("EventName"):SetText(event.eventName)
	
	local evDT = parseDateTime(event.eventDateTime)
	if type(evDT) ~= "table" then
		glog:error("OnShowPartEvForm: cant parse event datetime")
		return false
	end
	local evDTStr = self:formatDateTime("eventDateTime", evDT)
	if type(evDTStr) ~= "string" then
		glog:error("OnShowPartEvForm: cant format event datetime")
		return false
	end
	wndControl:FindChild("EventDate"):SetText(firstToUpper(evDTStr))
	
	wndControl:FindChild("EventDuration"):SetText(L["duration"] .. " " .. event.eventDuration)
	wndControl:FindChild("EventCreator"):SetText(L["Created by:"] .. " " .. event.eventCreator)
	
	local comment = ""
	if event.options.comment ~= nil and type(event.options.comment) == "string" and strlen(event.options.comment) > 0 then
		comment = event.options.comment
	end
	wndControl:FindChild("EventComment"):SetText(L["Comment:"] .. "\n" .. comment)
	
	
	-- disable button for old event
	if compareStrDateTime(event.eventDateTime, getDateTimeNow()) == -1 then
		wndControl:FindChild("ButtonComing"):Enable(false)
		wndControl:FindChild("ButtonNotComing"):Enable(false)
		wndControl:FindChild("ButtonUncertain"):Enable(false)
	else
		wndControl:FindChild("ButtonComing"):Enable(true)
		wndControl:FindChild("ButtonNotComing"):Enable(true)
		wndControl:FindChild("ButtonUncertain"):Enable(true)
	end
	
	
	-- show button delete ?
	local buttonDelete = wndControl:FindChild("ButtonDelete")
	if event.eventCreator == GameLib:GetPlayerUnit():GetName() then
		buttonDelete:Show(true)
	else
		buttonDelete:Show(false)
	end
	
	self:refreshParticipantsList()

end



---
-- refresh the participants list
function YACalendar:refreshParticipantsList()

	local uniqueIdEvent = self.wndPartEv:GetData()

	local event = getEventUniqueIdByCalendarName(self.CONFIG.currentCalendar, uniqueIdEvent)
	if type(event) ~= "table" then
		glog:error("OnShowPartEvForm: cant get event by uniqueId " .. uniqueIdEvent)
		return false
	end

	local participants = event.participants -- event participants
	

	local partList = self.wndPartEv:FindChild("ParticipantsList") -- the participants list
	
	-- clear the list
	local children = partList:GetChildren()
	for i=1,#children do
		children[i]:Destroy()
	end
	
	tsort(participants, function(a,b) return a.playerName<b.playerName end) -- sort participants
	
	for id,playerInfo in pairs(participants) do

		local partWindow = Apollo.LoadForm(self.xmlDoc, "ParticipantFrameTpl", partList, self)
		if partWindow == nil then
			glog:error("OnShowPartEvForm: cant load form ParticipantFrameTpl")
			return false
		end
		partWindow:FindChild("PlayerName"):SetText(playerInfo.playerName)
		
		local dt = parseDateTime(playerInfo.playerDateTime)
		if type(dt) ~= "table" then
			glog:error("OnShowPartEvForm: cant parse player datetime")
		end
		
		local dtStr = self:formatDateTime("tinyDateTime", dt)
		if type(dtStr) ~= "string" then
			glog:error("OnShowPartEvForm: cant format player datetime")
			return false
		end
		
		partWindow:FindChild("PlayerDateTime"):SetText(L["Last update:"] .. " " .. dtStr)
		
		if playerInfo.playerStatus == "present" then
			partWindow:FindChild("PlayerStatus"):SetSprite("ClientSprites:QuestJewel_Complete_Green")
		elseif playerInfo.playerStatus == "maybe" then
			partWindow:FindChild("PlayerStatus"):SetSprite("CRB_QuestTrackerSprites:btnQT_QuestLogNormal") -- ClientSprites:QuestJewel_Incomplete_Green
		else
			partWindow:FindChild("PlayerStatus"):SetSprite("ClientSprites:QuestJewel_Decline")
		end
	end
	
	partList:ArrangeChildrenVert()

end



---
-- on event WindowHide of ParticipateEvFormParticipateEvForm form
function YACalendar:OnHidePartEvForm(wndHandler, wndControl)
	
end



---
-- on event ButtonSignal of button here (coming, notcoming, uncertain) in ParticipateEvFormParticipateEvForm form
function YACalendar:OnClickButtonHerePartEvForm(wndHandler, wndControl, eMouseButton)
	local clickOn = ""

	if wndControl:GetName() == "ButtonComing" then
		clickOn = "present"
	elseif wndControl:GetName() == "ButtonNotComing" then
		clickOn = "discard"
	elseif wndControl:GetName() == "ButtonUncertain" then
		clickOn = "maybe"
	else
		glog:error("OnClickButtonHerePartEvForm: bad event target")
		return false
	end
	
	glog:debug("in OnClickButtonHerePartEvForm(" .. clickOn .. ")")
	
	if GameLib.GetPlayerUnit() == nil or GameLib.GetPlayerUnit():GetName() == nil then
		glog:error("OnClickButtonHerePartEvForm: cant get player name")
		return false
	end
	local playername = GameLib:GetPlayerUnit():GetName()
	
	
	if strlen(self.CONFIG.currentCalendar) == 0 then
		glog:error("OnClickButtonHerePartEvForm: no current calendar, this is a bug, report it")
		return false
	end
	
	local uniqueIdEvent = self.wndPartEv:GetData()
	local event = getEventUniqueIdByCalendarName(self.CONFIG.currentCalendar, uniqueIdEvent)
	if type(event) ~= "table" then
		glog:error("OnClickButtonHerePartEvForm: cant get event by uniqueId " .. uniqueIdEvent)
		return false
	end
	
	if testParticipantNameStatusByCalendarName(self.CONFIG.currentCalendar, uniqueIdEvent, playername, clickOn) == true then
		glog:info("OnClickButtonHerePartEvForm: add/update useless, same status")
		return false
	end
	
	local result = addReplaceParticipantByCalendarName(self.CONFIG.currentCalendar, uniqueIdEvent, playername, clickOn)
	if result == false then
		glog:error("OnClickButtonHerePartEvForm: cant add/replace participant")
		return false
	end
	
	-- TODO: rework this code, put it in a function
	local cal = getCalendarByName(self.CONFIG.currentCalendar)
	local channel = generateChannelName(cal.name, cal.salt)
	local participant = getParticipantByCalendarName(self.CONFIG.currentCalendar, uniqueIdEvent, playername)
	local messagePart = generateUpdateParticipantTableMessage(channel, self.CONFIG.currentCalendar, uniqueIdEvent, participant)
	if type(messagePart) == "table" then
		glog:debug("OnClickButtonHerePartEvForm: add an updateParticipant message in sendSyncData")
		tinsert(sendSyncData, messagePart)
	else
		glog:error("OnClickButtonHerePartEvForm: cant generate updateParticipant message, this is a bug, report it")
	end
	
	

	
	self:refreshParticipantsList()
	self:refreshAllEventsDay()
	
end



function YACalendar:OnClickDeleteButtonPartEvForm(wndHandler, wndControl, eMouseButton)
	
end



---------------------------------------------------------------------------------------------------
-- EventFrameTpl Functions
---------------------------------------------------------------------------------------------------



---
-- on event ButtonSignal in button "participate" in DayCalEv form
function YACalendar:OnClickParticipateButton(wndHandler, wndControl, eMouseButton)
	glog:debug("in OnClickParticipateButton()")
	self.wndPartEv:SetData(wndControl:GetData()) -- copy the event uniqueId
	self.wndPartEv:Close()
	self.wndPartEv:Show(true)
	self.wndPartEv:ToFront()
end



---------------------------------------------------------------------------------------------------
-- YACalendarAddEvForm Functions
---------------------------------------------------------------------------------------------------


---
-- get all EditBox for form AddEv in 1 shot
-- @return a table
function YACalendar:getAllEditBoxAddEvForm()
	
	local evName = self.wndAddEv:FindChild("EventNameTextBox")
	if evName == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventNameTextBox")
	end
	
	local evDateYear = self.wndAddEv:FindChild("EventDateYearTextBox")
	if evDateYear == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventDateYearTextBox")
	end
	
	local evDateMonth = self.wndAddEv:FindChild("EventDateMonthTextBox")
	if evDateMonth == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventDateMonthTextBox")
	end
	
	local evDateDay = self.wndAddEv:FindChild("EventDateDayTextBox")
	if evDateDay == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventDateDayTextBox")
	end
	
	local evDateHour = self.wndAddEv:FindChild("EventHMHourTextBox")
	if evDateHour == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventHMHourTextBox")
	end
	
	local evDateMinute = self.wndAddEv:FindChild("EventHMMinuteTextBox")
	if evDateMinute == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventHMMinuteTextBox")
	end
	
	local evDurationHour = self.wndAddEv:FindChild("EventDurationHourTextBox")
	if evDurationHour == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventDurationHourTextBox")
	end
	
	local evDurationMinute = self.wndAddEv:FindChild("EventDurationMinuteTextBox")
	if evDurationMinute == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventDurationMinuteTextBox")
	end
	
	local evComment = self.wndAddEv:FindChild("EventCommentTextBox")
	if evComment == nil then
		glog:error("getAllEditBoxAddEvForm: cant find child EventCommentTextBox")
	end
	
	return {evName, evDateYear, evDateMonth, evDateDay, evDateHour, evDateMinute, evDurationHour, evDurationMinute, evComment}
end



---
-- on event WindowShow in AddEv form (add a new event)
function YACalendar:OnShowAddEvForm(wndHandler, wndControl)
	if wndControl:GetName() ~= "YACalendarAddEvForm" then
		return false
	end
	glog:debug("in OnShowAddEvForm()")
	
	local evName, evDateYear, evDateMonth, evDateDay, evDateHour, evDateMinute, evDurationHour, evDurationMinute, evComment = unpack(self:getAllEditBoxAddEvForm())
	if evName == nil or evDateYear == nil or evDateMonth == nil or evDateDay == nil or evDateHour == nil or evDateMinute == nil or evDurationHour == nil or evDurationMinute == nil or evComment == nil then
		return false
	end
	
	
	local useDate = osdate('*t')
	if type(self.currentDaySelected) == "table" then
		glog:debug("OnShowAddEvForm: use currentDaySelected")
		useDate = deepcopy(self.currentDaySelected)
	else
		glog:warn("OnShowAddEvForm: cant get currentDaySelected")
	end
	
	if useDate.min ~= nil then
		glog:debug("OnShowAddEvForm: correct minute")
		useDate.minute = useDate.min
	end
	
	-- using current time ?
	if useDate.hour == nil or useDate.minute == nil or useDate.hour == 0 or useDate.minute == 0 then
		glog:debug("OnShowAddEvForm: get current hour/min")
		useDate.hour = osdate('*t')["hour"]
		useDate.minute = osdate('*t')["min"]
	end
	
	-- push date+duration in EditBox
	evDateYear:SetText(tostring(useDate.year))
	evDateMonth:SetText(strformat("%02d", useDate.month))
	evDateDay:SetText(strformat("%02d", useDate.day))
	evDateHour:SetText(strformat("%02d", useDate.hour))
	evDateMinute:SetText(strformat("%02d", useDate.minute))
	
	
	-- init old content of all EditBox
	self.oldEditBoxContentAddEvForm =	{
											name = evName:GetText(),
											dateYear = evDateYear:GetText(),
											dateMonth = evDateMonth:GetText(),
											dateDay = evDateDay:GetText(),
											dateHour = evDateHour:GetText(),
											dateMinute = evDateMinute:GetText(),
											durationHour = evDurationHour:GetText(),
											durationMinute = evDurationMinute:GetText()
										}
	
	evComment:SetText("")
	
	
	self:refreshWeekdayAddEvForm()
	
	evName:SetFocus()
end



function YACalendar:OnClickButtonAddEvForm(wndHandler, wndControl, eMouseButton)
	local ctrlName = wndControl:GetName()
	
	if strfind(ctrlName, "Button") == nil then
		glog:error("OnClickButtonAddEvForm: you're not a button, you are not suppose to be here")
		return false
	end
	
	glog:debug("in OnClickButtonAddEvForm()")
	
	local direction = ""
	local target = ""
	local part = ""
	
	-- increment (down), decrement (up)
	if strfind(ctrlName, "Up") ~= nil then
		direction = "up"
	elseif strfind(ctrlName, "Down") ~= nil then
		direction = "down"
	else
		glog:error("OnClickButtonAddEvForm: cant match direction")
		return false
	end
	
	-- date or duration
	if strfind(ctrlName, "Date") ~= nil then
		target = "date"
	elseif strfind(ctrlName, "Duration") ~= nil then
		target = "duration"
	else
		glog:error("OnClickButtonAddEvForm: cant match target")
		return false
	end
	
	if strfind(ctrlName, "Year") ~= nil then
		part = "year"
	elseif strfind(ctrlName, "Month") ~= nil then
		part = "month"
	elseif strfind(ctrlName, "Day") ~= nil then
		part = "day"
	elseif strfind(ctrlName, "DateHour") ~= nil then
		part = "hour"
	elseif strfind(ctrlName, "DateMinute") ~= nil then
		part = "minute"
	elseif strfind(ctrlName, "DurationHour") ~= nil then
		part = "durationhour"
	elseif strfind(ctrlName, "DurationMinute") ~= nil then
		part = "durationminute"
	else
		glog:error("OnClickButtonAddEvForm: cant match part")
		return false
	end
	
	local evName, evDateYear, evDateMonth, evDateDay, evDateHour, evDateMinute, evDurationHour, evDurationMinute = unpack(self:getAllEditBoxAddEvForm())
	if evName == nil or evDateYear == nil or evDateMonth == nil or evDateDay == nil or evDateHour == nil or evDateMinute == nil or evDurationHour == nil or evDurationMinute == nil then
		return false
	end
	
	local year = evDateYear:GetText()
	year = tonumber(year)
	local month = evDateMonth:GetText()
	month = tonumber(month)
	local day = evDateDay:GetText()
	day = tonumber(day)
	local hour = evDateHour:GetText()
	hour = tonumber(hour)
	local minute = evDateMinute:GetText()
	minute = tonumber(minute)
	local durationhour = evDurationHour:GetText()
	durationhour = tonumber(durationhour)
	local durationminute = evDurationMinute:GetText()
	durationminute = tonumber(durationminute)
	
	
	-- all EditBox content is an integer ?
	if year == nil or month == nil or day == nil or hour == nil or minute == nil or durationhour == nil or durationminute == nil then
		glog:error("OnClickButtonAddEvForm: cant parse textbox")
		return false
	end

	-- year management
	if part == "year" then
		if direction == "up" then
			year = year + 1
		else
			year = year - 1
		end
		evDateYear:SetFocus()
	
	-- month management
	elseif part == "month" then
		if direction == "up" then
			month = month + 1
		else
			month = month - 1
		end
		
		if month >= 13 then
			year = year - 1
			month = 12
		elseif month == 0 then
			year = year + 1
			month = 1
		end
		evDateMonth:SetFocus()
		
	-- day management
	elseif part == "day" then
		if direction == "up" then
			day = day + 1
		else
			day = day - 1
		end
		
		local monthDay = getDaysInMonth(month, year)
		local ret = nil
		if day > monthDay then
			glog:debug("OnClickButtonAddEvForm: day is upper than monthDay, add 1 day in date")
			ret = addDaysDate(year, month, day - 1)
		elseif day == 0 then
			glog:debug("OnClickButtonAddEvForm: day is equal to zero, remove 1 day in date")
			ret = subDaysDate(year, month, day + 1)
		end
		if type(ret) == "table" then
			year = ret.year
			month = ret.month
			day = ret.day
		end
		evDateDay:SetFocus()
		
	-- date hour management
	elseif part == "hour" then
		if direction == "up" then
			hour = hour + 1
		else
			hour = hour - 1
		end
		evDateHour:SetFocus()
		
	-- date minute management
	elseif part == "minute" then
		if direction == "up" then
			minute = minute + 1
		else
			minute = minute - 1
		end
		evDateMinute:SetFocus()
		
	-- duration hour management
	elseif part == "durationhour" then
		if direction == "up" then
			durationhour = durationhour + 1
		else
			durationhour = durationhour - 1
		end
		evDurationHour:SetFocus()
		
	-- duration minute management
	elseif part == "durationminute" then
		if direction == "up" then
			durationminute = durationminute + 1
		else
			durationminute = durationminute - 1
		end
		evDurationMinute:SetFocus()
	else
		glog:error("OnClickButtonAddEvForm: cant match any part")
		return false
	end
	
	-- check bounds
	if testIntegerDate(year, "year") == false then
		glog:debug("OnClickButtonAddEvForm: year out of bounds, exiting")
		return false
	end
	if testIntegerDate(month, "month") == false then
		glog:debug("OnClickButtonAddEvForm: month out of bounds, exiting")
		return false
	end
	if testIntegerDate(day, "day") == false then
		glog:debug("OnClickButtonAddEvForm: day out of bounds, exiting")
		return false
	end
	if testIntegerDate(hour, "hour") == false then
		glog:debug("OnClickButtonAddEvForm: hour out of bounds, exiting")
		return false
	end
	if testIntegerDate(minute, "minute") == false then
		glog:debug("OnClickButtonAddEvForm: minute out of bounds, exiting")
		return false
	end
	if testIntegerDate(durationhour, "durationhour") == false then
		glog:debug("OnClickButtonAddEvForm: durationhour out of bounds, exiting")
		return false
	end
	if testIntegerDate(durationminute, "durationminute") == false then
		glog:debug("OnClickButtonAddEvForm: durationminute out of bounds, exiting")
		return false
	end
	
	-- show new values in EditBox
	evDateYear:SetText(tostring(year))
	evDateMonth:SetText(strformat("%02d", month))
	evDateDay:SetText(strformat("%02d", day))
	evDateHour:SetText(strformat("%02d", hour))
	evDateMinute:SetText(strformat("%02d", minute))
	evDurationHour:SetText(strformat("%02d", durationhour))
	evDurationMinute:SetText(strformat("%02d", durationminute))
	
	-- set week day
	self:refreshWeekdayAddEvForm()
	
	glog:debug("OnClickButtonAddEvForm: new values sets")
end



---
-- each time a textbox is changing
function YACalendar:OnEditBoxChangedAddEvForm(wndHandler, wndControl, strNewText)
	
	glog:debug("in OnEditBoxChangedAddEvForm()")
	
	if wndControl:GetName() == "EventNameTextBox" then
		-- check alphanumeric string
	
		local cleanNewText = strStripAccents(strNewText)
		local testStr = strmatch(cleanNewText, "^[a-zA-Z0-9 :,?!_-]+$")
		if strlen(cleanNewText) > 30 then
			glog:warn("OnEditBoxChangedAddEvForm: max str length")
			self:resetEditBoxAddEvForm(wndControl)
		elseif testStr == nil and strNewText ~= "" then
			glog:warn("OnEditBoxChangedAddEvForm: bad chars in event name")
			self:resetEditBoxAddEvForm(wndControl)
		else
			glog:debug("OnEditBoxChangedAddEvForm: text ok")
			self:setOldValueEditBoxAddEvForm(wndControl, strNewText)
		end
	elseif wndControl:GetName() == "EventDateYearTextBox" or wndControl:GetName() == "EventDateMonthTextBox" or wndControl:GetName() == "EventDateDayTextBox" or wndControl:GetName() == "EventHMHourTextBox" or wndControl:GetName() == "EventHMMinuteTextBox"  or wndControl:GetName() == "EventDurationHourTextBox" or wndControl:GetName() == "EventDurationMinuteTextBox" then
		-- check only integer string
		
		local intStrNewText = tonumber(strNewText)
		
		if strlen(strNewText) == 0 then
			glog:debug("OnEditBoxChangedAddEvForm: empty EditBox (for integer)")
			self:setOldValueEditBoxAddEvForm(wndControl, strNewText)
		elseif intStrNewText == nil then
			glog:warn("OnEditBoxChangedAddEvForm: not an integer")
			self:resetEditBoxAddEvForm(wndControl)
		else
			local mode = ""
			if wndControl:GetName() == "EventDateYearTextBox" then
				mode = "year"
			elseif wndControl:GetName() == "EventDateMonthTextBox" then
				mode = "month"
			elseif wndControl:GetName() == "EventDateDayTextBox" then
				mode = "day"
			elseif wndControl:GetName() == "EventHMHourTextBox" or wndControl:GetName() == "EventDurationHourTextBox" then
				mode = "hour"
			elseif wndControl:GetName() == "EventHMMinuteTextBox" or wndControl:GetName() == "EventDurationMinuteTextBox" then
				mode = "minute"
			end
			if testIntegerDate(intStrNewText, mode) == false then
				glog:warn("OnEditBoxChangedAddEvForm: bad integer bound")
				self:resetEditBoxAddEvForm(wndControl)
			else
				glog:debug("OnEditBoxChangedAddEvForm: integer ok")
				self:setOldValueEditBoxAddEvForm(wndControl, strNewText)
				
				-- if mode ~= "year" then
				-- 	wndControl:SetText(strformat("%02d", tonumber(wndControl:GetText())))
				-- end
				
			end
			
		end
		
	else
		glog:error("OnEditBoxChangedAddEvForm: cant match any control")
		return false
	end
	
	self:refreshWeekdayAddEvForm()
	
end


function YACalendar:refreshWeekdayAddEvForm()
	local evName, evDateYear, evDateMonth, evDateDay, evDateHour, evDateMinute, evDurationHour, evDurationMinute = unpack(self:getAllEditBoxAddEvForm())
	if evDateYear == nil or evDateMonth == nil or evDateDay == nil then
		self.wndAddEv:FindChild("EventDateWeekday"):SetText("")
		return false
	elseif strlen(evDateYear:GetText()) == 0 or strlen(evDateMonth:GetText()) == 0 or strlen(evDateDay:GetText()) == 0 then
		self.wndAddEv:FindChild("EventDateWeekday"):SetText("")
		return false
	end
	
	local year = evDateYear:GetText()
	year = tonumber(year)
	local month = evDateMonth:GetText()
	month = tonumber(month)
	local day = evDateDay:GetText()
	day = tonumber(day)

	-- set week day
	local tWeekday = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"} -- these tag is in i18n
	local weekdayid = getDayOfWeek(day, month, year) -- 1 = sunday, 7 = saturday
	self.wndAddEv:FindChild("EventDateWeekday"):SetText(L[tWeekday[weekdayid]])

end



---
-- reset a text to his old value
function YACalendar:resetEditBoxAddEvForm(wndControl)
	glog:debug("in resetEditBoxAddEvForm()")
	
	local target
	if wndControl:GetName() == "EventNameTextBox" then
		target = self.oldEditBoxContentAddEvForm.name
	elseif wndControl:GetName() == "EventDateYearTextBox" then
		target = self.oldEditBoxContentAddEvForm.dateYear
	elseif wndControl:GetName() == "EventDateMonthTextBox" then
		target = self.oldEditBoxContentAddEvForm.dateMonth
	elseif wndControl:GetName() == "EventDateDayTextBox" then
		target = self.oldEditBoxContentAddEvForm.dateDay
	elseif wndControl:GetName() == "EventHMHourTextBox" then
		target = self.oldEditBoxContentAddEvForm.dateHour
	elseif wndControl:GetName() == "EventHMMinuteTextBox" then
		target = self.oldEditBoxContentAddEvForm.dateMinute
	elseif wndControl:GetName() == "EventDurationHourTextBox" then
		target = self.oldEditBoxContentAddEvForm.durationHour
	elseif wndControl:GetName() == "EventDurationMinuteTextBox" then
		target = self.oldEditBoxContentAddEvForm.durationMinute
	else
		glog:error("resetEditBoxAddEvForm: cant match any control")
		return false
	end
	
	if target ~= nil then
		wndControl:SetText(target)
	else
		wndControl:SetText("")
	end
	wndControl:SetSel(strlen(wndControl:GetText()))
	return true
end



---
-- set new text in buffer
function YACalendar:setOldValueEditBoxAddEvForm(wndControl, strNewText)
	glog:debug("in setOldValueEditBoxAddEvForm()")
	if wndControl:GetName() == "EventNameTextBox" then
		self.oldEditBoxContentAddEvForm.name = strNewText
	elseif wndControl:GetName() == "EventDateYearTextBox" then
		self.oldEditBoxContentAddEvForm.dateYear = strNewText
	elseif wndControl:GetName() == "EventDateMonthTextBox" then
		self.oldEditBoxContentAddEvForm.dateMonth = strNewText
	elseif wndControl:GetName() == "EventDateDayTextBox" then
		self.oldEditBoxContentAddEvForm.dateDay = strNewText
	elseif wndControl:GetName() == "EventHMHourTextBox" then
		self.oldEditBoxContentAddEvForm.dateHour = strNewText
	elseif wndControl:GetName() == "EventHMMinuteTextBox" then
		self.oldEditBoxContentAddEvForm.dateMinute = strNewText
	elseif wndControl:GetName() == "EventDurationHourTextBox" then
		self.oldEditBoxContentAddEvForm.durationHour = strNewText
	elseif wndControl:GetName() == "EventDurationMinuteTextBox" then
		self.oldEditBoxContentAddEvForm.durationMinute = strNewText
	else
		glog:error("setOldValueEditBoxAddEvForm: cant match any control")
		return false
	end
	return true
end



---
-- on event ButtonSignal in button "add" in AddEv form
function YACalendar:OnClickAddButtonAddEvForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "AddButton" then
		return false
	end
	glog:debug("in OnClickAddButtonAddEvForm()")
	
	local evName, evDateYear, evDateMonth, evDateDay, evDateHour, evDateMinute, evDurationHour, evDurationMinute, evComment = unpack(self:getAllEditBoxAddEvForm())
	if evName == nil or evDateYear == nil or evDateMonth == nil or evDateDay == nil or evDateHour == nil or evDateMinute == nil or evDurationHour == nil or evDurationMinute == nil or evComment == nil then
		return false
	end
	
	-- get all EditBox content
	local year = tonumber(evDateYear:GetText())
	local month = tonumber(evDateMonth:GetText())
	local day = tonumber(evDateDay:GetText())
	local hour = tonumber(evDateHour:GetText())
	local minute = tonumber(evDateMinute:GetText())
	local durationhour = tonumber(evDurationHour:GetText())
	local durationminute = tonumber(evDurationMinute:GetText())
	
	DLG:Dismiss("JustAMessage") -- clear all message box
	
	-- check bounds
	if testIntegerDate(year, "year") == false then
		glog:debug("OnClickAddButtonAddEvForm: year out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	if testIntegerDate(month, "month") == false then
		glog:debug("OnClickAddButtonAddEvForm: month out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	if testIntegerDate(day, "day") == false then
		glog:debug("OnClickAddButtonAddEvForm: day out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	if testIntegerDate(hour, "hour") == false then
		glog:debug("OnClickAddButtonAddEvForm: hour out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	if testIntegerDate(minute, "minute") == false then
		glog:debug("OnClickAddButtonAddEvForm: minute out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	if testIntegerDate(durationhour, "durationhour") == false then
		glog:debug("OnClickAddButtonAddEvForm: durationhour out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	if testIntegerDate(durationminute, "durationminute") == false then
		glog:debug("OnClickAddButtonAddEvForm: durationminute out of bounds, exiting")
		DLG:Spawn("JustAMessage", {text = L["dateintegererror"]})
		return false
	end
	
	-- check event name
	local cleanEvNameStr = strStripAccents(evName:GetText())
	local testEvNameStr = strmatch(cleanEvNameStr, "^[a-zA-Z0-9 :,?!_-]+$")
	if strlen(cleanEvNameStr) == 0 or strlen(cleanEvNameStr) > 30 then
		glog:error("OnClickAddButtonAddEvForm: not right event name length")
		DLG:Spawn("JustAMessage", {text = L["namenotgood"]})
		evName:SetFocus()
		return false
	elseif testEvNameStr == nil then
		glog:warn("OnClickAddButtonAddEvForm: bad chars in event name")
		DLG:Spawn("JustAMessage", {text = L["namenotgood"]})
		return false
	end
	
	-- check event date
	local dtStr = tostring(year) .. "-" .. strformat("%02d", month) .. "-" .. strformat("%02d", day) .. " " .. strformat("%02d", hour) .. ":" .. strformat("%02d", minute) .. ":" .. "00"
	if testDateTime(dtStr) == false then
		glog:error("OnClickAddButtonAddEvForm: bad date")
		DLG:Spawn("JustAMessage", {text = L["baddate"]})
		return false
	elseif compareStrDateTime(dtStr, getDateTimeNow()) == -1 then
		glog:error("OnClickAddButtonAddEvForm: date must be over datetimenow")
		DLG:Spawn("JustAMessage", {text = L["mustbeafternow"]})
		return false
	end
	
	if strlen(self.CONFIG.currentCalendar) == 0 then
		glog:error("OnClickAddButtonAddEvForm: no current calendar, this is a bug, report it")
		return false
	end
	
	local duration = strformat("%02d:%02d", durationhour, durationminute)
	
	
	-- options data
	local optionalData = {}
	
	if strlen(evComment:GetText()) > 0 then
		optionalData.comment = evComment:GetText()
	end
	
	local evUniqueId = addCalendarEventByCalendarName(self.CONFIG.currentCalendar, evName:GetText(), dtStr, duration, GameLib:GetPlayerUnit():GetName(), nil, nil, nil, optionalData)
	if evUniqueId == false then
		glog:error("OnClickAddButtonAddEvForm: cant add event")
		return false
	end
	glog:debug("OnClickAddButtonAddEvForm: event unique id=" .. evUniqueId)
	
	-- TODO: rework this code, put it in a function
	local cal = getCalendarByName(self.CONFIG.currentCalendar)
	local channel = generateChannelName(cal.name, cal.salt)
	local ev = getEventUniqueIdByCalendarName(self.CONFIG.currentCalendar ,evUniqueId)
	local messageEv = generateUpdateEventTableMessage(channel, self.CONFIG.currentCalendar, ev)
	if type(messageEv) == "table" then
		glog:debug("OnClickAddButtonAddEvForm: add an updateEvent message in sendSyncData")
		tinsert(sendSyncData, messageEv)
	else
		glog:error("OnClickAddButtonAddEvForm: cant generate updateEvent message, this is a bug, report it")
	end

	
	self:loadCurrentCalendarWindow() -- reload the main window
	
	self.wndAddEv:Close() -- close add event window
	
end



---
-- on event ButtonSignal in button "close" in AddEv form
function YACalendar:OnClickAddEvClose(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "CloseButton" and wndControl:GetName() ~= "CloseButtonBottom" then
		return false
	end
	glog:debug("in OnClickAddEvClose()")
	
	self.wndAddEv:Close()
end



---------------------------------------------------------------------------------------------------
-- YACalendarConfigForm Functions
---------------------------------------------------------------------------------------------------



function YACalendar:OnClickCalendarConfigForm(wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation)
	if strsub(wndControl:GetName(), 1, 14) ~= "elementCalList" and wndControl:GetName() ~= "calName" then
		return false
	end
	glog:debug("in OnClickCalendarConfigForm()")
	
	local target = wndControl
	if wndControl:GetName() == "calName" then
		target = wndControl:GetParent()
	end
	local currentCalId = target:GetData()
	
	-- get calendar list
	local calList = self.wndConfig:FindChild("CalendarList")
	if calList == nil then
		glog:error("OnClickCalendarConfigForm: cant find child CalendarList")
		return false
	end
	
	-- reset all calendar element in silver
	local childrenCalList = calList:GetChildren()
	for k,child in pairs(childrenCalList) do
		child:SetSprite("CRB_Tooltips:sprTooltip_SquareFrame_Silver")
	end
	
	-- set green sprite to current target
	target:SetSprite("CRB_Tooltips:sprTooltip_SquareFrame_Green")
	
	calList:SetData(currentCalId) -- change selected calendar
	
	local cal = getCalendarById(currentCalId)
	if cal == nil then
		glog:error("OnClickCalendarConfigForm: cant get calendar id " .. tostring(currentCalId))
		return false
	end
	
	self.wndConfig:FindChild("NameTextBox"):SetText(cal.name)
	self.wndConfig:FindChild("SaltTextBox"):SetText(cal.salt)
	
	self.wndConfig:FindChild("DeleteButton"):Enable(true)

end



---
-- refresh the calendar list in config form
function YACalendar:refreshCalListConfigForm()
	glog:debug("in refreshCalListConfigForm()")

	local calList = self.wndConfig:FindChild("CalendarList")
	if calList == nil then
		glog:error("refreshCalListConfigForm: cant find child CalendarList")
		return false
	end
	
	calList:SetData(0) -- unselect
	
	local childrenCalList = calList:GetChildren()
	for k,child in pairs(childrenCalList) do
		child:Destroy()
	end
	
	for calKey,calValue in pairs(calendarData) do
		local calWindow = Apollo.LoadForm(self.xmlDoc, "CalendarFrameConfigTpl", calList, self)
		if calWindow == nil then
			glog:error("refreshCalListConfigForm: cant load form CalendarFrameConfigTpl")
			return false
		end
		calWindow:FindChild("calName"):SetText(calValue.name)
		calWindow:SetSprite("CRB_Tooltips:sprTooltip_SquareFrame_Silver")
		calWindow:SetData(calKey)
		calWindow:SetName("elementCalList" .. tostring(calKey))
	end
	
	calList:ArrangeChildrenVert()
	
	-- reset all window
	self.wndConfig:FindChild("DeleteButton"):Enable(false)
	self.wndConfig:FindChild("AddButton"):Enable(true)
	self.wndConfig:FindChild("SaveButton"):Enable(false)
	self.wndConfig:FindChild("NameTextBox"):SetText("")
	self.wndConfig:FindChild("SaltTextBox"):SetText("")
	
end



function YACalendar:OnShowConfigForm(wndHandler, wndControl)
	if wndControl:GetName() ~= "YACalendarConfigForm" then
		return false
	end
	glog:debug("in OnShowConfigForm()")
	
	self:refreshCalListConfigForm()
	
	
	self.wndCalEv:Show(false)
	self.wndPartEv:Show(false)
	self.wndAddEv:Show(false)

	
end



function YACalendar:OnClickCloseButtonConfigForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "CloseButton" and wndControl:GetName() ~= "CloseButtonBottom" then
		return false
	end
	glog:debug("in OnClickCloseButtonConfigForm()")
	self:loadCurrentCalendarWindow()
	self.wndConfig:Close()
end



function YACalendar:OnClickDeleteCalendarButtonConfigForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "DeleteButton" then
		return false
	end
	glog:debug("in OnClickDeleteCalendarButtonConfigForm()")
	
	local calList = self.wndConfig:FindChild("CalendarList")
	if calList == nil then
		glog:error("OnClickDeleteCalendarButtonConfigForm: cant find child CalendarList")
		return false
	end
	
	local currentCalId = calList:GetData()
	
	if type(currentCalId) ~= "number" or currentCalId <= 0 then
		glog:error("OnClickDeleteCalendarButtonConfigForm: no calendar selected")
		return false
	end
	
	local cal = getCalendarById(currentCalId)
	if cal == nil then
		glog:error("OnClickDeleteCalendarButtonConfigForm: cant get calendar id " .. tostring(currentCalId))
		return false
	end
	
	
	DLG:Dismiss("OkDeleteCalendar")
	local data =	{
						text = String_GetWeaselString(L["okdeletecalendar"], cal.name),
						calIdDelete = currentCalId,
						target = self
					}
	DLG:Spawn("OkDeleteCalendar", data)
	
	glog:debug("OnClickDeleteCalendarButtonConfigForm: dafuq?!")

end



---
-- click on "yes" in dialog: sure delete calendar?
-- @param #object target target
-- @param #number calid integer of calendar id
function YACalendar:deleteCalendarYesButtonConfigForm(target, calid)
	glog:debug("in deleteCalendarYesButtonConfigForm()")
	
	if target == nil or calid == nil then
		glog:error("deleteCalendarYesButtonConfigForm: no target, this is a bug -_-'")
		return false
	elseif type(calid) ~= "number" then
		glog:error("deleteCalendarYesButtonConfigForm: calid bad type")
		return false
	end
	
	glog:debug("deleteCalendarYesButtonConfigForm: delete calendar " .. tostring(calid))
	
	local ret = deleteCalendar(calid)
	if ret == false then
		glog:error("deleteCalendarYesButtonConfigForm: cant delete calendar")
		return false
	end
	
	target:refreshCalListConfigForm()
	
end



function YACalendar:OnClickAddCalendarButtonConfigForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "AddButton" then
		return false
	end
	glog:debug("in OnClickAddCalendarButtonConfigForm()")
	
	self:refreshCalListConfigForm()
	
end



function YACalendar:OnClickSaveButtonConfigForm(wndHandler, wndControl, eMouseButton)
	if wndControl:GetName() ~= "SaveButton" then
		return false
	end
	glog:debug("in OnClickSaveButtonConfigForm()")
	
	local calendarName = self.wndConfig:FindChild("NameTextBox"):GetText()
	local calendarSalt = self.wndConfig:FindChild("SaltTextBox"):GetText()
	
	local calendarNameStripped = strStripAccents(calendarName)
	
	if strlen(calendarName) == 0 and strlen(calendarSalt) == 0 then
		glog:debug("OnClickSaveButtonConfigForm: empty string")
		DLG:Spawn("JustAMessage", {text = L["badnamesalt"]})
		return false
	elseif strlen(calendarName) > 30 or strlen(calendarSalt) > 30 then
		glog:debug("OnClickSaveButtonConfigForm: too long string")
		DLG:Spawn("JustAMessage", {text = L["badnamesalt"]})
		return false
	elseif strmatch(calendarNameStripped, "^[a-zA-Z0-9 :,?!_-]+$") == nil or strmatch(calendarSalt, "^[a-zA-Z0-9]+$") == nil then
		glog:debug("OnClickSaveButtonConfigForm: bad chars")
		DLG:Spawn("JustAMessage", {text = L["badnamesalt"]})
		return false
	end
	
	local calList = self.wndConfig:FindChild("CalendarList")
	if calList == nil then
		glog:error("OnClickDeleteCalendarButtonConfigForm: cant find child CalendarList")
		return false
	end
	local currentCalId = calList:GetData()
	
	if currentCalId ~= nil and type(currentCalId) == "number" and currentCalId > 0 then
		local calendar = getCalendarById(currentCalId)
		if calendar == nil then
			glog:error("OnClickSaveButtonConfigForm: cant get calendar")
			return false
		elseif type(calendar) ~= "table" then
			glog:error("OnClickSaveButtonConfigForm: calendar is not a table")
			return false
		end
		
		if calendar.name ~= calendarName then
			glog:debug("OnClickSaveButtonConfigForm: update calendar name")
			local ret = setCalendarName(currentCalId, calendarName)
			if ret == false then
				glog:error("OnClickSaveButtonConfigForm: cant update calendar name")
			end
		end
		
		if calendar.salt ~= calendarSalt then
			glog:debug("OnClickSaveButtonConfigForm: update calendar salt")
			local ret = setCalendarSalt(currentCalId, calendarSalt)
			if ret == false then
				glog:error("OnClickSaveButtonConfigForm: cant update calendar salt")
			end
		end
		
	else
		addCalendar(calendarName, calendarSalt, false)
	end
	self:refreshCalListConfigForm()
end



function YACalendar:OnEditBoxChangedConfigForm(wndHandler, wndControl, strText)
	if wndControl:GetName() ~= "NameTextBox" and wndControl:GetName() ~= "SaltTextBox" then
		return false
	end
	glog:debug("in OnEditBoxChangedConfigForm()")
	
	local saveButton = self.wndConfig:FindChild("SaveButton")
	if saveButton == nil then
		glog:error("OnEditBoxChangedConfigForm: cant find child SaveButton")
		return false
	end
	
	local calendarName = self.wndConfig:FindChild("NameTextBox"):GetText()
	local calendarSalt = self.wndConfig:FindChild("SaltTextBox"):GetText()

	if strlen(calendarName) > 0 and strlen(calendarSalt) > 0 then
		saveButton:Enable(true)
	else
		saveButton:Enable(false)
	end

end



-----------------------------------------------------------------------------------------------
-- YACalendar Instance
-----------------------------------------------------------------------------------------------
local YACalendarInst = YACalendar:new()
YACalendarInst:Init()


