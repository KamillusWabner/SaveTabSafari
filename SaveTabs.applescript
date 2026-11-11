-- SaveTabs
-- Remembers the tabs of one Safari window per profile and restores them
-- when you open a new window of that profile.
--
-- How it works:
--   * Safari puts the profile name in front of the window title,
--     e.g. "Work — Page title". That is how SaveTabs knows the profile.
--   * Every profile is set to open new windows with "Empty Page".
--     A newly appearing window whose last tab is empty (pinned tabs in
--     front of it are fine) is a freshly opened window and gets filled
--     with the saved tabs of its profile.
--   * One window per profile is watched; its tabs are saved continuously
--     to ~/Library/SaveTabs/tabs-<Profile>.txt.
--
-- License: MIT (see LICENSE)

property pollSeconds : 1
property debugLog : false -- true writes events (no URLs) to ~/Library/SaveTabs/log.txt
property sep : " — "

global dataFolder, seenIDs, profNames, profIDs, profLists, startIDs

on run
	set dataFolder to (POSIX path of (path to library folder from user domain)) & "SaveTabs/"
	do shell script "mkdir -p " & quoted form of dataFolder
	set seenIDs to {}
	-- windows that are already open when SaveTabs starts are never overwritten
	set startIDs to {}
	try
		if application "Safari" is running then
			tell application "Safari" to set startIDs to id of every window
		end if
	end try
	set profNames to {}
	set profIDs to {}
	set profLists to {}
	my logLine("started")
end run

on idle
	try
		if application "Safari" is running then my tick()
	on error e
		my logLine("error: " & e)
	end try
	return pollSeconds
end idle

-- index of a profile; creates it on first use and loads its saved tabs
on profileIndex(n)
	repeat with i from 1 to count of profNames
		if item i of profNames is n then return i
	end repeat
	set end of profNames to n
	set end of profIDs to missing value
	set end of profLists to my loadList(n)
	my logLine(n & ": " & (count of item -1 of profLists) & " tabs saved")
	return count of profNames
end profileIndex

on tick()
	tell application "Safari"
		set allIDs to {}
		set allNames to {}
		try
			set allIDs to id of every window
			set allNames to name of every window
		end try
	end tell
	-- real windows only: Safari keeps closed windows around, invisible and without tabs
	set winIDs to {}
	set winNames to {}
	set winURLs to {}
	repeat with k from 1 to count of allIDs
		set urls to my urlsOfWindow(item k of allIDs)
		if urls is not missing value and urls is not {} then
			set end of winIDs to item k of allIDs
			set end of winNames to item k of allNames
			set end of winURLs to urls
		end if
	end repeat
	-- forget closed windows (their saved list stays)
	repeat with i from 1 to count of profIDs
		if item i of profIDs is not missing value and winIDs does not contain (item i of profIDs) then
			set item i of profIDs to missing value
			my logLine(item i of profNames & ": window closed, " & (count of item i of profLists) & " tabs saved")
		end if
	end repeat

	repeat with k from 1 to count of winIDs
		set wid to item k of winIDs
		set urls to item k of winURLs
		set n to my profileOf(item k of winNames)
		if n is not missing value then
			set isNew to seenIDs does not contain wid
			if isNew then set end of seenIDs to wid
			set p to my profileIndex(n)
			if item p of profIDs is wid then
				-- watched window: save its tabs
				set clean to my cleanList(urls)
				if clean is not {} and clean is not (item p of profLists) then
					set item p of profLists to clean
					my saveList(n, clean)
				end if
			else if item p of profIDs is missing value then
				if isNew and startIDs does not contain wid and my isFreshWindow(urls) then
					set item p of profIDs to wid
					my logLine(n & ": new empty window, restoring " & (count of item p of profLists) & " tabs")
					my restoreInto(wid, item p of profLists)
				else if (item p of profLists) is {} or startIDs does not contain wid or my sameTabs(my cleanList(urls), item p of profLists) then
					-- window that appeared later (e.g. reopened via ⇧⌘T) or one holding the saved tabs
					set item p of profIDs to wid
					my logLine(n & ": watching existing window")
				end if
				-- otherwise: a different window that was open at startup -> never overwrite the saved list
			end if
		end if
	end repeat
end tick

on sameTabs(a, b)
	if a is {} or b is {} then return false
	set hits to 0
	repeat with u in a
		if b contains (contents of u) then set hits to hits + 1
	end repeat
	-- redirects sometimes change single URLs, so half is enough
	return hits * 2 ≥ (count of b) and hits * 2 ≥ (count of a)
end sameTabs

-- "Work — Page title" -> "Work"
on profileOf(winName)
	try
		if winName is missing value or winName does not contain sep then return missing value
		set AppleScript's text item delimiters to sep
		set n to text item 1 of winName
		set AppleScript's text item delimiters to ""
		if n is "" then return missing value
		return n
	on error
		set AppleScript's text item delimiters to ""
		return missing value
	end try
end profileOf

-- URLs of all tabs; empty tabs as ""
on urlsOfWindow(wid)
	try
		tell application "Safari"
			set raw to URL of every tab of (first window whose id is wid)
		end tell
	on error
		return missing value
	end try
	set out to {}
	repeat with u in raw
		set u to contents of u
		if u is missing value then
			set end of out to ""
		else
			set end of out to (u as text)
		end if
	end repeat
	return out
end urlsOfWindow

-- freshly opened window: the last tab is empty, at most pinned tabs before it
on isFreshWindow(urls)
	if urls is {} then return false
	set blanks to 0
	repeat with u in urls
		if my isBlank(contents of u) then set blanks to blanks + 1
	end repeat
	return blanks is 1 and my isBlank(item -1 of urls)
end isFreshWindow

on isBlank(u)
	return u is "" or u starts with "about:" or u starts with "favorites:"
end isBlank

on cleanList(urls)
	set out to {}
	repeat with u in urls
		set u to contents of u
		if not my isBlank(u) then set end of out to u
	end repeat
	return out
end cleanList

on restoreInto(wid, lst)
	if lst is {} then return -- nothing saved yet
	-- skip URLs that are already open (e.g. pinned tabs)
	set present to my urlsOfWindow(wid)
	set todo to {}
	repeat with u in lst
		if present does not contain (contents of u) then set end of todo to (contents of u)
	end repeat
	if todo is {} then return
	tell application "Safari"
		set w to (first window whose id is wid)
		set n to count of tabs of w
		-- the empty last tab gets the first URL, the rest go after it
		set URL of tab n of w to item 1 of todo
		repeat with i from 2 to count of todo
			tell w to make new tab at end of tabs with properties {URL:item i of todo}
		end repeat
		set current tab of w to tab n of w
	end tell
end restoreInto

on fileFor(n)
	set safe to do shell script "printf '%s' " & quoted form of n & " | tr -c 'A-Za-z0-9_-' '_'"
	return dataFolder & "tabs-" & safe & ".txt"
end fileFor

on saveList(n, urls)
	set AppleScript's text item delimiters to linefeed
	set txt to urls as text
	set AppleScript's text item delimiters to ""
	set f to open for access (POSIX file (my fileFor(n))) with write permission
	try
		set eof of f to 0
		write txt to f as «class utf8»
	end try
	close access f
end saveList

on loadList(n)
	try
		set txt to read (POSIX file (my fileFor(n))) as «class utf8»
	on error
		return {}
	end try
	set out to {}
	repeat with p in paragraphs of txt
		if (contents of p) is not "" then set end of out to (contents of p)
	end repeat
	return out
end loadList

-- event log: profile names and counts only, never URLs
on logLine(t)
	if not debugLog then return
	try
		do shell script "printf '%s %s\\n' \"$(date '+%F %T')\" " & quoted form of t & " >> " & quoted form of (dataFolder & "log.txt")
	end try
end logLine
