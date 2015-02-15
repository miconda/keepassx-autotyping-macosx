on open location localURL
	-- kpx://proto?username:password:address:port/path
	-- * kpx://ssh?alice:xyz:wonderland.com:22022
	-- * kpx://https?alice:xyz:wonderland.com:40443/home
	-- kpx-proto://username:password@address:port/path
	-- * kpx-ssh://alice:xyz@wonderland.com:22022
	-- * kpx-https://alice:xyz@wonderland.com:40443/home	
	
	set myTerm to "iTerm2"
	
	-- display dialog "URL: " & localURL
	
	if (text 1 thru 4 of localURL) is "kpx:" then
		set thePath to text 7 thru -1 of localURL
		if (text 1 thru 4 of thePath) is "ssh?" then
			-- ssh?
			set theProto to "ssh"
			set theData to text 5 thru -1 of thePath
		else
			if (text 1 thru 6 of thePath) is "https?" then
				-- https?
				set theProto to "https"
				set theData to text 7 thru -1 of thePath
			else
				if (text 1 thru 5 of thePath) is "http?" then
					-- http?
					set theProto to "http"
					set theData to text 6 thru -1 of thePath
				else
					-- assume http
					set theProto to "http"
					set theData to thePath
				end if
			end if
		end if
	else
		set thePath to text 5 thru -1 of localURL
		if (text 1 thru 4 of thePath) is "ssh:" then
			-- ssh:
			set theProto to "ssh"
			set theData to text 7 thru -1 of thePath
		else
			if (text 1 thru 6 of thePath) is "https:" then
				-- https:
				set theProto to "https"
				set theData to text 9 thru -1 of thePath
			else
				if (text 1 thru 5 of thePath) is "http:" then
					-- http:
					set theProto to "http"
					set theData to text 8 thru -1 of thePath
				else
					-- assume http
					set theProto to "http"
					set theData to thePath
				end if
			end if
		end if
	end if
	
	set theCLPos to offset of ":" in theData
	if theCLPos = 0 then
		display dialog "INVALID URL - NO USER"
		return
	end if
	set theUser to text 1 thru (theCLPos - 1) of theData
	set theData1 to text (theCLPos + 1) thru -1 of theData
	set theData to theData1
	set theCLPos to offset of "@" in theData
	if theCLPos = 0 then
		set theCLPos to offset of ":" in theData
		if theCLPos = 0 then
			display dialog "INVALID URL - NO PASSWORD"
			return
		end if
	end if
	
	set thePass to text 1 thru (theCLPos - 1) of theData
	set theAddr to text (theCLPos + 1) thru -1 of theData
	
	-- display dialog "URL: " & theProto & "://" & theUser & ":xyz@" & theAddr
	
	if theProto is "ssh" then
		set theCLPos to offset of ":" in theAddr
		if theCLPos = 0 then
			set theSSHUrl to "ssh " & theUser & "@" & theAddr
		else
			set theHost to text 1 thru (theCLPos - 1) of theAddr
			set thePort to text (theCLPos + 1) thru -1 of theAddr
			set theSSHUrl to "ssh -p " & thePort & " " & theUser & "@" & theHost
		end if
		if myTerm is "Terminal" then
			-- display dialog "Terminal"
			
			tell application "Terminal"
				activate
				delay 1
				do script with command theSSHUrl
				delay 1
				set theButton to button returned of (display dialog "Auto type? (" & theAddr & ")" buttons {"No", "Yes"} default button "Yes")
				if theButton is "Yes" then
					tell application "System Events"
						keystroke thePass
						key code 52
					end tell
				end if
			end tell
		else
			-- display dialog "iTerm2"
			
			tell application "System Events"
				set isRunning to (exists (processes where name is "iTerm"))
			end tell
			tell application "iTerm"
				activate
				delay 1
				set termCount to count of terminals
				
				if termCount is 0 then
					set crtTerm to (make new terminal)
				else
					set crtTerm to the last terminal
				end if
				
				tell crtTerm
					if not isRunning and termCount is not 0 then
						set crtSession to current session
					else
						set crtSession to (launch session "Default")
					end if
					tell crtSession to write text "clear; " & theSSHUrl & "\n"
					delay 1
					set theButton to button returned of (display dialog "Auto type? (" & theAddr & ")" buttons {"No", "Yes"} default button "Yes")
					if theButton is "Yes" then
						tell i term application "System Events"
							keystroke thePass
							key code 52
						end tell
					end if
				end tell
			end tell
			
		end if
	else
		set theHTTPUrl to theProto & "://" & theAddr
		tell application "Safari"
			activate
			delay 1
			tell window 1 of application "Safari" to make new tab
			tell front window of application "Safari" to set current tab to last tab
			set the URL of document 1 to theHTTPUrl
			set theButton to button returned of (display dialog "Auto type? (" & theAddr & ")" buttons {"No", "Yes"} default button "Yes")
			if theButton is "Yes" then
				tell application "System Events"
					keystroke theUser
					keystroke " "
					keystroke thePass
					key code 52
				end tell
			end if
		end tell
	end if
	
end open location

