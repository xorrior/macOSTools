// grab the chrome object
var chrome = Application("Google Chrome");

// grab all of the chrome windows
var windows = chrome.windows;

// loop through the chrome windows
for(i = 0; i < windows.length; i++){

  // grab all of the tabs for the window
  var tabs = windows[i].tabs;

  // loop through the tabs
  for(j = 0; j < tabs.length; j++){

    // grab the url for the tab
    var url = tabs[j].url();

    // check to see if the tab url matches "soundcloud.com"
    if(url.match(/soundcloud.com/)){

      // in the tab lets execute some javascript
      tabs[j].execute({

        // select the .playControl div and click it!
        javascript: "document.querySelector('.playControl').click();"
      });
    }
  }
}
