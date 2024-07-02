# My Personal Windows Configuration Script

This script is primarily intended to act as a template for building a larger install script. It is inteded to be run with a mostly fresh windows installation with only some basic applications added, such as an alternative web browser. This script removes some features that I find to be more annoying than useful and provides some browser configuration settings. 

Disclaimer: This script utilizes registry edits which can cause some issues which can cause issues ranging from minor to very severe if the user does not understand what they are changing. For this reason users should try to familiarize themselves with what exactly the script does before running or modifying. All modifications to the web browsers other than where commented out in the script can be changed with the built in browser settings. Other modifications utilizing the registry should be left alone unless the user understands what it is doing and how to change it if needed. Making a restore point for the registry is recommended.

## Removed Features
* Windows "Search the Web": I would very frequently find myself trying to find a setting or a file on my computer and by force of habit hit enter at the end of my search, prompting windows to open Edge and use bing to search for it. The edit made removes this and if nothing is found on your computer then it will state exactly that.

* Widgets: Removed because I don't want advertisements baked into a the software I payed $140-$200 for. 

## Browser Configuration
* Microsoft Edge (Chromium): This script modifies the new Edge that is built into Windows 11. The most major modification is that uBlock Origin Lite will be automatically installed. I would have installed uBlock Origin but with Manifest V3 approaching I decided to prepare. The modifications made are mostly to set my personal preferences that I would otherwise enable in a web browser and set Google as the default search engine. This does include some other settings to disable default browser notifications but read the warning before enabling those.
* Google Chrome: This script does not install Chrome so before uncommenting this block, make sure it is installed first. The settings here are pretty much the same as the ones outlined for Edge. Installs uBlock Origin Lite and makes some prefence modifications.
* Mozilla Firefox: This script does nott install Firefox, so before uncommenting this block, make sure it is installed first. Due to this being my preferred browser, I took the liberty of modifying this one the most. 
    * Installs uBlock Origin
    * Default search egnine changes to DuckDuckGo
    * Disables search suggestions
    * Disables sponsored junk
    * Changes most privacy settings to be stricter
    * Disables other annoying settings

## Updates
* Winget is run to find and isntall all new updates