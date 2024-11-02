-- Configurable Variables
set slideURL to "https://docs.google.com/presentation/d/e/"CHANGEME"/pub?start=true&loop=true&delayms=10000"
set maxRetries to 5 -- Maximum number of attempts to check for an internet connection
set delayTime to 10 -- Delay (in seconds) between each retry attempt

-- Function to check for internet connectivity
-- This function tries to ping google.com to confirm internet access.
on checkInternetConnection()
    try
        -- Ping google.com once (-c 1). If successful, return true, indicating internet is available.
        do shell script "ping -c 1 google.com"
        return true
    on error
        -- If ping fails, an error is thrown, and we return false, indicating no internet connection.
        return false
    end try
end checkInternetConnection

-- Function to retry internet connection check multiple times
-- This function will retry `checkInternetConnection` up to the specified maxRetries
-- and delay a certain time (delayTime) between each retry attempt.
on checkConnectionWithRetry(maxRetries, delayTime)
    set retries to 0 -- Initialize retry counter
    repeat until retries is maxRetries -- Repeat until retries reach maxRetries
        if checkInternetConnection() then
            -- If internet connection is available, return true
            return true
        else
            -- If not, increment retry counter and delay before the next attempt
            set retries to retries + 1
            delay delayTime
        end if
    end repeat
    -- If all retries are exhausted without a connection, return false
    return false
end checkConnectionWithRetry

-- Main process: Check for internet connection with retry mechanism
if checkConnectionWithRetry(maxRetries, delayTime) then
    -- Notify user that the internet is available and presentation will open
    display notification "Internet connection available. Opening presentation..."
    
    -- Open Google Chrome and navigate to the Google Slides presentation
    tell application "Google Chrome"
        activate -- Bring Chrome to the foreground
        open location slideURL -- Open the Google Slides URL in Chrome
        delay 2 -- Allow time for the page to load before entering fullscreen
        
        -- Enable fullscreen mode and presentation mode in Chrome
        tell application "System Events"
            -- Command+Control+F to enter fullscreen mode
            keystroke "f" using {command down, control down} 
            delay 1 -- Brief delay to ensure fullscreen mode is enabled
            -- Command+Shift+F to enter presentation mode (hides browser interface)
            keystroke "f" using {command down, shift down} 
        end tell
    end tell
    
    -- Hide the mouse cursor to remove distractions on the presentation screen
    do shell script "defaults write com.apple.universalaccess mouseDriverCursorSize 1; killall Finder"
else
    -- If internet connection is not available after all retries, notify the user
    display dialog "No internet connection available after multiple attempts. Please check your network and try again." buttons {"OK"} default button "OK"
end if

-- Restore mouse cursor size to default when done:
-- Run this line manually to bring back the cursor size:
-- defaults write com.apple.universalaccess mouseDriverCursorSize 2; killall Finder
