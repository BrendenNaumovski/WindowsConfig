Clear-Host

#region Get Scope
$scope = ""
while (1) {
    try {
        Write-Host "How should these settings be applied?"
        Write-Host "(1) Current User"
        Write-Host "(2) Local Machine"
        $userInput = [int](Read-Host "Enter the number corresponding to your selection")
        if ($userInput -eq 1) {
            $scope = "HKCU:\"
            break
        } elseif ($userInput -eq 2) {
            $scope = "HKLM:\"
            break
        } else {
            Clear-Host
            Write-Host "Not a valid selection" -ForegroundColor Red
        }
    } catch {
        Clear-Host
        Write-Host "Not a valid selection" -ForegroundColor Red
    }
}

#endregion

#region Debloat
# Remove Widgets
Write-Host "Removing Widgets..."
# Remove the installed package for each user
Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*WebExperience*"} | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

# Remove the provisioned package for new users
$AppxRemoval = Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*WebExperience*"} 
ForEach ( $App in $AppxRemoval) {
    Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName 
}

# Remove search bar "search the web" feature"
Write-Host "Removing Windows web search..."
New-Item -Path $scope + "Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
New-ItemProperty -Path $scope + "Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -PropertyType DWORD -Force | Out-Null

#endregion
 
#region Edge Configuration
Invoke-Command -ScriptBlock {
    Write-Host "Configuring Microsoft Edge..."

    $registry = $scope + "Software\Policies\Microsoft\Edge\Recommended"

    # Install uBlock Origin
    New-Item -Path $scope + "Software\Wow6432Node\Microsoft\Edge\Extensions\cimighlppcgcoapaliogpjjdehbnofhn" -Force
    Set-ItemProperty -Path $scope + "Software\Wow6432Node\Microsoft\Edge\Extensions\cimighlppcgcoapaliogpjjdehbnofhn" -Name "update_url" -Value "https://edge.microsoft.com/extensionwebstorebase/v1/crx" -Force

    # Change default search engine
    New-Item -Path $registry -Force
    New-ItemProperty -Path $registry -Name "DefaultSearchProviderEnabled" -Value 1 -PropertyType DWord -Force
    New-ItemProperty -Path $registry -Name "DefaultSearchProviderName" -Value "Google" -PropertyType String -Force
    New-ItemProperty -Path $registry -Name "DefaultSearchProviderSearchURL" -Value "https://google.com/search?q={searchTerms}" -PropertyType String -Force

    # Change homepage behavior
    New-ItemProperty -Path $registry -Name "HomepageLocation" -Value "https://google.com" -PropertyType String -Force
    New-ItemProperty -Path $registry -Name "NewTabPageLocation" -Value "https://google.com" -PropertyType String -Force

    # Change window behavior
    New-ItemProperty -Path $registry -Name "FavoritesBarEnabled" -Value 1 -PropertyType DWord -Force
    New-ItemProperty -Path $registry -Name "ShowHomeButton" -Value 1 -PropertyType DWord -Force

    # Enable HTTPS only mode
    New-ItemProperty -Path $registry -Name "AutomaticHttpsDefault" -Value 2 -PropertyType DWord -Force

    # Disable first run page
    New-Item -Path $scope + "Software\Policies\Microsoft\MicrosoftEdge\Main" -Force
    New-ItemProperty -Path $scope + "Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "PreventFirstRunPage" -Value 1 -PropertyType DWORD -Force

    #region Unmodifiable settings

    # Warning!!! The settings in this region are not modifiable by menus within the application or by standard user settings. Reverting
    # or changing these settings will require use of the registry editor, group policy, powershell or other more advanced means. I do not recommend
    # uncommenting these if you are not comfortable with using one of the listed methods to revert or change them.

    # # Disable tip popups
    # New-ItemProperty -Path $scope + "Software\Policies\Microsoft\Edge" -Name "ShowRecommendationsEnabled" -Value 0 -PropertyType DWord -Force

    # # Disable default browser popups
    # New-ItemProperty -Path $scope + "Software\Policies\Microsoft\Edge" -Name "DefaultBrowserSettingsEnabled" -Value 0 -PropertyType DWord -Force
    # New-ItemProperty -Path $scope + "Software\Policies\Microsoft\Edge" -Name "DefaultBrowserSettingsCampaignEnabled" -Value 0 -PropertyType DWord -Force

    #endregion
    
} | Out-Null

#endregion

#region Chrome Configuration
# Invoke-Command -ScriptBlock {

#     Write-Host "Configuring Chrome..."

#     $registry = $scope + "Software\Policies\Google\Chrome\Recommended"

#     # Install uBlock Origin
#     New-ItemProperty -Path $scope + "Software\Policies\Google\Chrome" -Name "ExtensionSettings" -Value "{""ddkjiahejlhfcafbddmgiahcphecmpfh"":{""installation_mode"": ""normal_installed"",""update_url"": ""https://clients2.google.com/service/update2/crx"",""override_update_url"": true}}" -PropertyType String -Force

#     New-Item -Path $registry -Force

#     # Change homepage behavior
#     New-ItemProperty -Path $registry -Name "HomepageLocation" -Value "https://www.google.com/" -PropertyType String -Force

#     # Change window behavior
#     New-ItemProperty -Path $registry -Name "BookmarkBarEnabled" -Value 1 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry -Name "ShowHomeButton" -Value 1 -PropertyType DWord -Force

#     #region Unmodifiable settings

#     # Warning!!! The settings in this region are not modifiable by menus within the application or by standard user settings. Reverting
#     # or changing these settings will require use of the registry editor, group policy, powershell or other more advanced means. I do not recommend
#     # uncommenting these if you are not comfortable with using one of the listed methods to revert or change them.

#     # # Enable HTTPS only mode and HTTPS upgrades
#     # New-ItemProperty -Path $scope + "Software\Policies\Google\Chrome" -Name "HttpsOnlyMode" -Value "force_enabled" -PropertyType String -Force
#     # New-ItemProperty -Path $scope + "Software\Policies\Google\Chrome" -Name "HttpsUpgradesEnabled" -Value 1 -PropertyType DWord -Force

#     #endregion
    
# } | Out-Null

#endregion

#region Firefox Configuration
# Invoke-Command -ScriptBlock {

#     Write-Host "Configuring Firefox..."

#     $registry = $scope + "Software\Policies\Mozilla\Firefox"

#     # Install uBlock Origin
#     New-Item -Path $registry -Force
#     New-ItemProperty -Path $registry -Name "ExtensionSettings" -Value "{""uBlock0@raymondhill.net"": {""installation_mode"": ""normal_installed"",""install_url"": ""https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi""}}" -PropertyType String -Force

#     # User modifiable settings
#     # Change default search engine
#     New-Item -Path $registry + "\SearchEngines" -Force
#     New-ItemProperty -Path $registry + "\SearchEngines" -Name "Default" -Value "DuckDuckGo" -PropertyType String -Force

#     # Change suggestions behavior
#     New-Item -Path $registry + "\FirefoxSuggest" -Force
#     New-ItemProperty -Path $registry + "\FirefoxSuggest" -Name "SponsoredSuggestions" -Value 0 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxSuggest" -Name "WebSuggestions" -Value 0 -PropertyType DWord -Force

#     # Change window behavior
#     New-ItemProperty -Path $registry -Name "DisablePocket" -Value 1 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry -Name "ShowHomeButton" -Value 1 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry -Name "DisplayBookmarksToolbar" -Value "always" -PropertyType String -Force

#     # Change homepage behavior
#     New-Item -Path $registry + "\Homepage" -Force
#     New-ItemProperty -Path $registry + "\Homepage" -Name "StartPage" -Value "homepage" -PropertyType String -Force
#     New-ItemProperty -Path $registry + "\Homepage" -Name "URL" -Value "https://start.duckduckgo.com/" -PropertyType String -Force
#     New-Item -Path $registry + "\FirefoxHome" -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "Search" -Value 1 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "Highlights" -Value 0 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "Pocket" -Value 0 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "Snippets" -Value 0 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "SponsoredPocket" -Value 0 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "SponsoredTopSites" -Value 0 -PropertyType DWord -Force
#     New-ItemProperty -Path $registry + "\FirefoxHome" -Name "TopSites" -Value 0 -PropertyType DWord -Force

#     # Disable new features popup
#     New-ItemProperty -Path $registry -Name "OverridePostUpdatePage" -PropertyType String -Force

#     # Change privacy settings
#     New-Item -Path $registry + "\PopupBlocking" -Force
#     New-ItemProperty -Path $registry + "\PopupBlocking" -Name "Default" -Value 1 -PropertyType DWord  -Force
#     New-Item -Path $registry + "\EnableTrackingProtection" -Force
#     New-ItemProperty -Path $registry + "\EnableTrackingProtection" -Name "Value" -Value 1 -PropertyType DWord  -Force
#     New-ItemProperty -Path $registry + "\EnableTrackingProtection" -Name "Cryptomining" -Value 1 -PropertyType DWord  -Force
#     New-ItemProperty -Path $registry + "\EnableTrackingProtection" -Name "EmailTracking" -Value 1 -PropertyType DWord  -Force
#     New-ItemProperty -Path $registry + "\EnableTrackingProtection" -Name "Fingerprinting" -Value 1 -PropertyType DWord  -Force
#     New-Item -Path $registry + "\Cookies" -Force
#     New-ItemProperty -Path $registry + "\Cookies" -Name "Behavior" -Value "reject-tracker-and-partition-foreign" -PropertyType String

#     # Enable HTTPS only mode for Firefox
#     # New-ItemProperty -Path $registry -Name "HttpsOnlyMode" -Value "force_enabled" -PropertyType String -Force

# } | Out-Null

#endregion

#region Updates
# Install Microsoft Store Updates
Write-Host "Installing updates..."
winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --disable-interactivity --force | Out-Null

#endregion

#Restart-Computer