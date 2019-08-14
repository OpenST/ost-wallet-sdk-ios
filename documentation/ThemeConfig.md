# Theme Config
## Config Structure
* First level of json is `component name`
* Values for `component name` are properties which applies on the respective component.
```json
{
    COMPONENT_NAME: {
        PROPERTY: <VALUE>
    }
}
```
> **important**
> 1. Application navigation bar logo image should be added in `assets` folder for iOS/android.
> 2. Value for `nav_bar_logo_image -> asset_name` should be updated with *asset_name* else OST placehoder image will be applied.
> 3. Incase of missing properties, default values will be applied to the respective component.

## Components

OstWalletUI containts 4 kind of UI components. 

 ### Label
 Label is categorized as :
 * H1
 * H2
 * H3
 * H4
 * C1
 * C2

 **Customizable Properties**<br/>
 &nbsp;_size: Label size_<br/>
 &nbsp;_font: Font for label_<br/>
 &nbsp;_color: Color of label_<br/>
 &nbsp;_alignment: Alignment for label_<br/>
 &nbsp;_system_font_weight: Weight of system font. Fallback incase value for `font` unable to extaract or not found._<br/>
 
 ### Button
 
 Button is categorized as :
 * B1
 * B2
 * B3
 * B4
 
 **Customizable Properties**<br/>
 &nbsp;_size: Button text size_<br/>
 &nbsp;_font: Font for button text_<br/>
 &nbsp;_color: Title color of button_<br/>
 &nbsp;_background_color: Button background color_<br/>
 &nbsp;_system_font_weight: Weight of system font. Fallback incase value for `font` unable to extaract or not found._<br/>
 
 ### Navigation Bar
 
 **Customizable Properties**<br/>
 * Navigation bar logo:
 Set value for key `nav_bar_logo_image -> asset_name` 
 * Navigation bar tint color:
 Set value for key `navigation_bar -> tint_color`
 *  Close icon tint color:
 Set value for key `icons -> close -> tint_color` 
 * Back icon tint color:
 Set value for key `icons -> back -> tint_color`
 
 ### Pin Input
 
 Style for pin input can be modified by updating values for key `pin_input`.
 
 **Customizable Properties**<br/>
 &nbsp;_empty_color: Empty dot color_<br/>
 &nbsp;_filled_color: Filled dot color_<br/>
    
## Theme JSON
```json
{
    "nav_bar_logo_image": {
        "asset_name": "ost_nav_bar_logo"
    },

    "h1": {
        "size": 20,
        "color": "#438bad",
        "system_font_weight": "semi_bold",
        "alignment": "center"
    },

    "h2": {
        "size": 17,
        "color": "#666666",
        "system_font_weight": "medium",
        "alignment": "center"
    },

    "h3": {
        "size": 15,
        "color": "#888888",
        "system_font_weight": "regular",
        "alignment": "center"
    },

    "h4": {
        "size": 12,
        "color": "#888888",
        "system_font_weight": "regular",
        "alignment": "center"
    },

    "c1": {
        "size": 14,
        "color": "#484848",
        "system_font_weight": "bold",
        "alignment": "left"
    },

    "c2": {
        "size": 12,
        "color": "#6F6F6F",
        "system_font_weight": "regular",
        "alignment": "left"
    },

    "b1": {
        "size": 17,
        "color": "#ffffff",
        "background_color": "#438bad",
        "system_font_weight": "medium"
    },

    "b2": {
        "size": 17,
        "color": "#438bad",
        "background_color": "#f8f8f8",
        "system_font_weight": "semi_bold"
    },

    "b3": {
        "size": 12,
        "color": "#ffffff",
        "background_color": "#438bad",
        "system_font_weight": "medium"
    }, 

    "b4": {
        "size": 12,
        "color": "#438bad",
        "background_color": "#ffffff",
        "system_font_weight": "medium"
    },

    "navigation_bar": {
        "tint_color": "#ffffff"
    },

    "icons": {
        "close": {
            "tint_color": "#438bad"
        },
        "back":{
            "tint_color": "#438bad"
        }
    },

    "pin_input": {
        "empty_color": "#c7c7cc",
        "filled_color": "#438bad"
    }
}
```
