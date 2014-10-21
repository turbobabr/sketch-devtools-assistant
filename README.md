Sketch DevTools Assistant
=========================
> <span style='color: #D0021B;'>Work in progres...</style>

Sketch DevTools Assistant is a helper OSX application that works together with [Sketch DevTools](http://github.com/turbobabr/sketch-devtools) solution and provides protocol handling functionality for `Jumpt To Code` feature of DevTools for the following list of IDEs:
- Atom
- Sublime Text
- WebStorm
- AppCode
- XCode
- MacVim

Without this app installed all the listed editors will not work with the `Jump To Code` feature of DevTool.

## Installation
1. Download an archive [Sketch DevTools Assistant.zip]() with compiled app and unzip it
2. Copy `Sketch DevTools Assistant.app` to the `Applications` folder
3. The compiled application isn't signed because I don't have Mac Developer subscription yet, thus you have to do one extra steps to make it work. Go to the `Applications` folder and right click on the `Sketch DevTools Assistant` app file and click `Open` item form context menu like this:
<img src="https://raw.githubusercontent.com/turbobabr/sketch-devtools-assistant/master/docs/open_app.png" width="500" height="398">
4. Run the application. If everything works fine you will see the app icon in the tray:

<img src="https://raw.githubusercontent.com/turbobabr/sketch-devtools-assistant/master/docs/tray_status.png">

## Compiling

If you don't want to use unsigned binary you can just clone this repo, compile the app, put it into the `Applications` folder and run it.

## Usage

### How and why protocol handling works

> Content goes here...

### Using actions

> Content goes here...

### Using automation to run plugins & scripts

Sketch DevTools Assistant is a scriptable application that provides a convenient way of running plugins and scripts from external applications like [Alfred](http://www.alfredapp.com/) using [AppleScript](http://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html) scripts. 

This technique works greate both with sandboxed and non-sandboxed versions of Sketch App. You have several options of running a script that are listed below:

#### Run script at absolute path

You can run a script file using absolute file path using the following AppleScript code:

```AppleScript
tell application "Sketch DevTools Assistant"
run script at path "~/Library/Application Support/com.bohemiancoding.sketch3/Plugins/MyPlugins/MakeMePretty.sketchplugin"
end tell
```
> WARNING: Be sure that your file is located in Sketch App plugins directory. In case it's located outside of it it won't work with sandboxed version of Sketch App downloaded from AppStore and with Sketch Beta since it's sandboxed now too.

#### Run script with relative file path

If you don't want to mess up with absolute paths, you can use relative paths by puting a `.`(dot) symbol as a first path component instead of plugins root folder. Such path will be automatically resolved and replaced with absolute path depending on what Sketch App version is currently running.

Here is an example of using of relative path in AppleScript:

```AppleScript
tell application "Sketch DevTools Assistant"
  run script at path "./MyPlugins/MakeMePretty.sketchplugin"
end tell
```

#### Passing optional data object to the script

There is a very handy option to pass some arbitrary parameters to you CocoaScript script in run-time. You can pass any JSON string generated on a side of external app to your sccript using optional `with data` parameter.

Take a lot at the following AppleScript. It passes a JSON string that represents an object that contains `color` field:

```AppleScript
tell application "Sketch DevTools Assistant"
	set colorData to "{ \"color\":\"#FF0000\" }"
	run script at path "./MyPlugins/setColor.sketchplugin" with data colorData
end tell
```

Right after script launch the provided JSON string will be available in your CocoaScript as `$data` variable:

```JavaScript
var hexColor=$data.color;
var layer=selection.firstObject();
if(layer) {
    var newColor=MSColor.colorWithHex_alpha(hexColor,1);
    layer.style().fill().color=newColor;
}
```

What happens under the hood is your original script is extended with injected `$data` variable autamatically like this:

```JavaScript
var $data = JSON.parse("{ \"color\":\"#FF0000\" }");
var hexColor=$data.color;
var layer=selection.firstObject();
if(layer) {
    var newColor=MSColor.colorWithHex_alpha(hexColor,1);
    layer.style().fill().color=newColor;
}
```
Then this modified script is saved to a temoprary file and get run.


#### Run script as a string

> TODO: Description.

```AppleScript
tell application "Sketch DevTools Assistant" 
	run script "selection.firstObject().frame().width=250;"
end tell
```

## Version history

> Version history goes here..

## Feedback

If you discover any issue or have any suggestions for improvement of the plugin, please [open an issue](https://github.com/turbobabr/sketch-devtools-assistant/issues) or find me on twitter [@turbobabr](http://twitter.com/turbobabr).

## Credits

Sketch DevTools Assistant uses [CocoaScript](http://github.com/ccgus/CocoaScript) framework by [August Mueller](http://github.com/ccgus) for running Sketch plugins using actions or automation.

The [flat Sketch icon desing](http://dribbble.com/shots/1705797-Sketch-App-Icon-Yosemite-Edition?list=users&offset=0) for the app was shamelessly borrowed from [Mehmet Gozetlik](http://dribbble.com/Antrepo). Thanks you Mehmet for the great work! :)

[NSBundle+OBCodeSigningInfo](http://github.com/ole/NSBundle-OBCodeSigningInfo) category by [Ole Begemann](https://github.com/ole) is used in Sketch DevTools Assistant to detect sandboxed version of Sketch App.

## License

The MIT License (MIT)

Copyright (c) 2014 Andrey Shakhmin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



