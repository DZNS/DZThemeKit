#DZThemeKit

DZThemeKit is a simple implementation for managing multiple User Interface themes in your app. For the moment, only UIKit is being targeted. Categories for WatchOS and AppKit will be added soon.

### Installation
You can add the project's source to your Project or Workspace directly. However, carthage is the preferred method:
```
github "dzns/DZThemeKit"
```

### Usage
To start using ThemeKit, all you have to do is simply add the following line, preferrably in your AppDelegate file.
```objc
#import <DZThemeKit/DZThemeKit.h>
```

This loads up ThemeKit and makes the `MyThemeKit` singleton available for you. ThemeKit comes with a few sane defaults with the exception of  `customColor`.  That's just a sample to demonstrate you can add your own colors easily.
This however does not make everything automatic for you.

Here is a sample implementation of how a basic ViewController implementation may look like:

```objc
- (void)themeView {
    self.titleBlock.backgroundColor   = [MyThemeKit valueForKey:@"titleColor"];
    self.textBlock.backgroundColor    = [MyThemeKit valueForKey:@"textColor"];
    self.subtextBlock.backgroundColor = [MyThemeKit valueForKey:@"subtextColor"];
    self.borderBlock.backgroundColor  = [MyThemeKit valueForKey:@"borderColor"];
    self.tintBlock.backgroundColor    = [MyThemeKit valueForKey:@"tintColor"];
    self.customBlock.backgroundColor  = [MyThemeKit valueForKey:@"customColor"];
}
```

You can call the above method from your `-[viewDidLoad]` in your view controller or `-[awakeFromNib]` or similar from inside your view.

### Theme Updates

DZThemeKit comes with Dark UI support out of the box. If you're loading a theme called `aqua.json`, DZThemeKit will automatically look for a `aqua-dark.json` in the same directory. If the file is found, it is loaded automatically for you.

From there, you can set `autoUpdatingTheme` to `YES` on `MyThemeKit` or your own instance and it'll fire a `ThemeNeedsUpdateNotification` notification when the display update's it's brightness for accomodating ambient light.

The `ThemeNeedsUpdateNotification` is fired once when the instance is first loaded into the memory and loads the default `colours.json`. If you load your own theme later, it'll be fired again.

### Categories
A few categories are available. These are basic at the moment and more advanced implementations will be made available soon. If you have any ideas, please feel free to open an issue with them.

```objc
- [UIView tk_updateBackgroundColor];
- [UILabel tk_updateTitleColorForTheme];
- [UILabel tk_updateTextColorForTheme];
- [UILabel tk_updateSubtextColorForTheme];
- [UITextField tk_setTextColor];
- [UITextField tk_setPlaceholderColor];
- [UITextView tk_setTextColor];
```

Whenever querying any of the color values from `ThemeKit`
- you have either set the value of `useDark` or the framework has updated it for you
- a dark theme configuration was found and loaded successfully
the framework will automatically return a value from either the normal or dark variant based on the boolean value of `isDark`.

### Colours
You can setup your colours using a simple JSON structure. You can view the default file <a href="https://github.com/DZNS/DZThemeKit/blob/master/DZThemeKit/colours.json" target="_blank">here</a>.

Notable features include:
- All colours are implemented using the sRGB colour space.
- You can optionally tell the framework to auto-extract the **DCI-P3** value for a colour by creating a dictionary value like so:
```json
{
  "rgb": "#2979FF",
  "p3": true
}
```

If you don't want a DCI-P3 value, you can set it to false which is the default behavior.

- Or you can provide the P3 value yourself if you have fine tuned it in your graphics program like so:
```json
{
  "rgb": "#2979FF",
  "p3": "#0631FF" // you can totally use this value :)
}
```

The framework also supports colour values like the following:
```
#33350    // 333333 at 0.5 alpha
#E00      // EE0000 at 1.0 alpha
#2979FF50 // 2979FF at 0.5 alpha
```

### LICENSE
DZThemeKit is available under the MIT License. Please see the LICENSE file for more information. 
