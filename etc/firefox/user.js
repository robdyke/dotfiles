// https://wiki.mozilla.org/Electrolysis/Accessibility
// prevent "accessibility support is partially disabled" prompt
user_pref("accessibility.loadedInLastSession", false);
user_pref("accessibility.lastLoadDate",0);
user_pref("accessibility.force_disabled", 1);

// Stop Firefox going into Offline Mode if server is not available
user_pref("network.manage-offline-status", false);

// Disable all data upload (Telemetry and FHR)
user_pref("datareporting.policy.dataSubmissionEnabled", false);

user_pref("browser.disableResetPrompt", true);

// specifically for the go-fullscreen animation
user_pref("toolkit.cosmeticAnimations.enabled", false);

// feels sluggish when on, Mac not affected by this
user_pref("general.smoothScroll", false);

user_pref("app.shield.optoutstudies.enabled", true);

// enable auto add-on installation (requires signed extension from AMO)
// https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Alternative_distribution_options/Add-ons_in_the_enterprise#Controlling_automatic_installation
user_pref("extensions.autoDisableScopes", 0);

user_pref("lightweightThemes.selectedThemeID", "firefox-compact-dark@mozilla.org");
user_pref("devtools.theme", "dark");

// highlight all matches when finding
user_pref("findbar.highlightAll", true);

user_pref("layout.spellcheckDefault", 2);

// don't remember passwords
user_pref("signon.rememberSignons", false);

// enable U2F auth (see https://www.yubico.com/2017/11/how-to-navigate-fido-u2f-in-firefox-quantum/ -- things will change)
user_pref("security.webauth.u2f");

// don't ask google (or whoever) for search suggestions (which appear above historic pages!)
user_pref("browser.search.suggest.enabled", "false");

// tabs get an annoying rolodex/scroller when there are too many. This makes having too many tabs open worse. Disable it.
user_pref("browser.tabs.tabMinWidth", 0);
