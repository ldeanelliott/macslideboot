-- URL of the Google Slides presentation
set slideURL to "https://docs.google.com/presentation/d/e/2PACX-1vTlIcaxOuheKgb8h2Pqn-UIH6bsmpNIIlpsACUdtD-xS7HafSRZA2LLLxylVFk_3c2xZK9D48fX8sK6/pub?start=true&loop=true&delayms=10000"

-- Set the number of retries and delay between retries
set maxRetries to 5
set delayTime to 10 -- 10 seconds between retries

-- Function to check for internet connectivity
on checkInternetConnection()
    try
        -- Try to ping google.com to check internet access
        do shell script "ping -c 1 google.com"
        return true
    on error
        return false
    end try
end checkInternetConnection

-- Retry mechanism to check internet connection multiple times
on checkConnectionWithRetry(maxRetries, delayTime)
    set retries to 0
    repeat until retries is maxRetries
        if checkInternetConnection() then
            return true
        else
            set retries to retries + 1
            delay delayTime
        end if
    end repeat
    return false
end checkConnectionWithRetry

-- Function to dismiss all notifications
on dismissAllNotifications()
    tell application "System Events"
        tell application process "NotificationCenter"
            set firstWindow to window 1
            set windowChildren to entire contents of firstWindow

            -- Loop through all elements in the notification window
            repeat with anElement in windowChildren
                -- Check if the element is a notification item
                if (class of anElement is UI element) then
                    log "Pressing notification: " & (name of anElement as string)
                    perform action "AXPress" of anElement
                end if
            end repeat
        end tell
    end tell
end dismissAllNotifications


-- Check for internet connection with retry mechanism
if checkConnectionWithRetry(maxRetries, delayTime) then
    display notification "Internet connection available. Opening presentation..."
    
    -- Open Google Chrome and navigate to the slide URL
    tell application "Google Chrome"
        activate
        open location slideURL
        delay 2 -- Give time for the page to load
        tell application "System Events"
            keystroke "f" using {command down, control down} -- Fullscreen Chrome
            delay 1
            keystroke "f" using {command down, shift down} -- Presentation mode (hides interface)
        end tell
    end tell
    
    -- Hide the mouse cursor
    do shell script "defaults write com.apple.universalaccess mouseDriverCursorSize 1; killall Finder"
    
    -- Dismiss all notifications after opening the presentation
    dismissAllNotifications()

else
    -- Notify the user that there is no internet connection after retries
    display dialog "No internet connection available after multiple attempts. Please check your network and try again." buttons {"OK"} default button "OK"
end if

-- To restore the mouse cursor when you're done, run:
-- defaults write com.apple.universalaccess mouseDriverCursorSize 2; killall Finder
