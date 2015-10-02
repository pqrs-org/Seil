try
    display dialog "Are you sure you want to remove Seil?" buttons {"Cancel", "OK"}
    if the button returned of the result is "OK" then
        try
            do shell script "test -f '/Library/Application Support/org.pqrs/Seil/uninstall.sh'"
            try
                do shell script "sh '/Library/Application Support/org.pqrs/Seil/uninstall.sh'" with administrator privileges
                display alert "Seil has been uninstalled. Please restart OS X."
            on error
                display alert "Failed to uninstall Seil."
            end try
        on error
            display alert "Seil is not installed."
        end try
    end if
on error
    display alert "Seil uninstallation was canceled."
end try
