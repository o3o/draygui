module draygui.raygui;

/**
*   raygui v2.5 - A simple and easy-to-use immedite-mode-gui library
*
*   raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also possible
*   to be used as a standalone library, as long as input and drawing functions are provided.
*
*   Controls provided:
*
*   # Container/separators Controls
*       - WindowBox
*       - GroupBox
*       - Line
*       - Panel
*
*   # Basic Controls
*       - Label
*       - Button
*       - LabelButton   --> Label
*       - ImageButton   --> Button
*       - ImageButtonEx --> Button
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - TextBoxMulti
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - ScrollBar
*       - ScrollPanel
*       - DummyRec
*       - Grid
*
*   # Advance Controls
*       - ListView      --> ListElement
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Label, Button
*       - TextInputBox  --> Label, TextBox, Button
*
*/

import raylib;

///Current Raygui version.
enum RAYGUI_VERSION = "2.5-dev";
//Following https://github.com/raysan5/raygui/blob/75769bdd6bba6e5ac335ef596dbef9fe8a7e41d0/src/raygui.h

// We are building raygui as a Win32 shared library (.dll).
// We are using raygui as a Win32 shared library (.dll)
// Functions visible from other files (no name mangling of functions in C++) // Functions visible from other files
// Functions just visible to module including this file
// Required for: atoi()

/// Vertical alignment for pixel perfect
auto VALIGN_OFFSET(T)(auto ref T h) {
   return cast(int)h % 2;
}

/// Text edit controls cursor blink timming
enum TEXTEDIT_CURSOR_BLINK_FRAMES = 20;
/// Number of standard controls
enum NUM_CONTROLS = 16;
/// Number of standard properties
enum NUM_PROPS_DEFAULT = 16;
/// Number of extended properties
enum NUM_PROPS_EXTENDED = 8;

// Types and Structures Definition
// NOTE: Some types are required for RAYGUI_STANDALONE usage
// Boolean type
// Vector2 type
// Vector3 type
// Color type, RGBA (32bit)
// Rectangle type
// Texture2D type
// Font type
// Gui text box state data
// Cursor position in text
// Text start position (from where we begin drawing the text)
// Text start index (index inside the text of `start` always in sync)
// Marks position of cursor when selection has started

/// Gui control state
enum GuiControlState {
   GUI_STATE_NORMAL = 0,
   GUI_STATE_FOCUSED = 1,
   GUI_STATE_PRESSED = 2,
   GUI_STATE_DISABLED = 3
}

/// Gui control text alignment
enum GuiTextAlignment {
   GUI_TEXT_ALIGN_LEFT = 0,
   GUI_TEXT_ALIGN_CENTER = 1,
   GUI_TEXT_ALIGN_RIGHT = 2
}

/// Gui controls
enum GuiControl {
   DEFAULT = 0,
   LABEL = 1, // LABELBUTTON
   BUTTON = 2, // IMAGEBUTTON
   TOGGLE = 3, // TOGGLEGROUP
   SLIDER = 4, // SLIDERBAR
   PROGRESSBAR = 5,
   CHECKBOX = 6,
   COMBOBOX = 7,
   DROPDOWNBOX = 8,
   TEXTBOX = 9, // TEXTBOXMULTI
   VALUEBOX = 10,
   SPINNER = 11,
   LISTVIEW = 12,
   COLORPICKER = 13,
   SCROLLBAR = 14,
   RESERVED = 15
}

/// Gui base properties for every control
enum GuiControlProperty {
   BORDER_COLOR_NORMAL = 0,
   BASE_COLOR_NORMAL = 1,
   TEXT_COLOR_NORMAL = 2,
   BORDER_COLOR_FOCUSED = 3,
   BASE_COLOR_FOCUSED = 4,
   TEXT_COLOR_FOCUSED = 5,
   BORDER_COLOR_PRESSED = 6,
   BASE_COLOR_PRESSED = 7,
   TEXT_COLOR_PRESSED = 8,
   BORDER_COLOR_DISABLED = 9,
   BASE_COLOR_DISABLED = 10,
   TEXT_COLOR_DISABLED = 11,
   BORDER_WIDTH = 12,
   INNER_PADDING = 13,
   TEXT_ALIGNMENT = 14,
   RESERVED02 = 15
}

// Gui extended properties depend on control
// NOTE: We reserve a fixed size of additional properties per control
/// DEFAULT properties
enum GuiDefaultProperty {
   TEXT_SIZE = 16,
   TEXT_SPACING = 17,
   LINE_COLOR = 18,
   BACKGROUND_COLOR = 19
}

/// Toggle / ToggleGroup
enum GuiToggleProperty {
   GROUP_PADDING = 16
}

/// Slider / SliderBar
enum GuiSliderProperty {
   SLIDER_WIDTH = 16,
   TEXT_PADDING = 17
}

/// CheckBox
enum GuiCheckBoxProperty {
   CHECK_TEXT_PADDING = 16
}

/// ComboBox
enum GuiComboBoxProperty {
   SELECTOR_WIDTH = 16,
   SELECTOR_PADDING = 17
}

/// DropdownBox
enum GuiDropdownBoxProperty {
   ARROW_RIGHT_PADDING = 16
}

/// TextBox / TextBoxMulti / ValueBox / Spinner
enum GuiTextBoxProperty {
   MULTILINE_PADDING = 16,
   COLOR_SELECTED_FG = 17,
   COLOR_SELECTED_BG = 18
}

enum GuiSpinnerProperty {
   SELECT_BUTTON_WIDTH = 16,
   SELECT_BUTTON_PADDING = 17,
   SELECT_BUTTON_BORDER_WIDTH = 18
}

/// ScrollBar
enum GuiScrollBarProperty {
   ARROWS_SIZE = 16,
   SLIDER_PADDING = 17,
   SLIDER_SIZE = 18,
   SCROLL_SPEED = 19,
   SHOW_SPINNER_BUTTONS = 20
}

/// ScrollBar side
enum GuiScrollBarSide {
   SCROLLBAR_LEFT_SIDE = 0,
   SCROLLBAR_RIGHT_SIDE = 1
}

/// ListView
enum GuiListViewProperty {
   ELEMENTS_HEIGHT = 16,
   ELEMENTS_PADDING = 17,
   SCROLLBAR_WIDTH = 18,
   SCROLLBAR_SIDE = 19 // This property defines vertical scrollbar side (SCROLLBAR_LEFT_SIDE or SCROLLBAR_RIGHT_SIDE)
}

/// ColorPicker
enum GuiColorPickerProperty {
   COLOR_SELECTOR_SIZE = 16,
   BAR_WIDTH = 17, // Lateral bar width
   BAR_PADDING = 18, // Lateral bar separation from panel
   BAR_SELECTOR_HEIGHT = 19, // Lateral bar selector height
   BAR_SELECTOR_PADDING = 20 // Lateral bar selector outer padding
}

/// Place enums into the global space.  Example: Allows usage of both KeyboardKey.KEY_RIGHT and KEY_RIGHT.
private string _enum(E...)() {
   import std.format : formattedWrite;
   import std.traits : EnumMembers;
   import std.array : appender;

   auto writer = appender!string;
   static foreach (T; E) {
      static foreach (member; EnumMembers!T) {
         writer.formattedWrite("alias %s = " ~ T.stringof ~ ".%s;\n", member, member);
      }
   }
   return writer.data;
}

mixin(_enum!(GuiControlState, GuiTextAlignment, GuiControl, GuiControlProperty, GuiDefaultProperty, GuiToggleProperty, GuiSliderProperty, GuiCheckBoxProperty,
      GuiComboBoxProperty, GuiDropdownBoxProperty, GuiTextBoxProperty, GuiSpinnerProperty, GuiScrollBarProperty,
      GuiScrollBarSide, GuiListViewProperty, GuiColorPickerProperty, GuiPropertyElement));

// Required for: raygui icons
// Required for: FILE, fopen(), fclose(), fprintf(), feof(), fscanf(), vsprintf()
// Required for: strlen() on GuiTextBox()
// Required for: va_list, va_start(), vfprintf(), va_end()

// Gui control property style element
enum GuiPropertyElement {
   BORDER = 0,
   BASE = 1,
   TEXT = 2,
   OTHER = 3
}

// Global Variables Definition
__gshared GuiControlState guiState;
__gshared Font guiFont; // NOTE: Highly coupled to raylib
__gshared bool guiLocked;
__gshared float guiAlpha = 1.0f;

// Global gui style array (allocated on heap by default)
// NOTE: In raygui we manage a single int array with all the possible style properties.
// When a new style is loaded, it loads over the global style... but default gui style
// could always be recovered with GuiLoadStyleDefault()
__gshared uint[NUM_CONTROLS * (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED)] guiStyle;
__gshared bool guiStyleLoaded;

// Area of the currently active textbox
// Keeps state of the active textbox

//----------------------------------------------------------------------------------
// Standalone Mode Functions Declaration
//
// NOTE: raygui depend on some raylib input and drawing functions
// To use raygui as standalone library, below functions must be defined by the user
//----------------------------------------------------------------------------------

// White -- GuiColorBarAlpha()
// Black -- GuiColorBarAlpha()
// My own White (raylib logo)
// Gray -- GuiColorBarAlpha()

// raylib functions already implemented in raygui
//-------------------------------------------------------------------------------
// Returns a Color struct from hexadecimal value
// Returns hexadecimal value for a Color
// Color fade-in or fade-out, alpha goes from 0.0f to 1.0f
// Check if point is inside rectangle
// Formatting of text with variables to 'embed'
//-------------------------------------------------------------------------------

// Input required functions
//-------------------------------------------------------------------------------

// -- GuiTextBox()
//-------------------------------------------------------------------------------

// Drawing required functions
//-------------------------------------------------------------------------------
/* TODO */

/* TODO */

/* TODO */ // -- GuiColorPicker()
// -- GuiColorPicker()
// -- GuiColorPicker()
// -- GuiColorPicker()

/* TODO */ // -- GuiDropdownBox()
/* TODO */ // -- GuiScrollBar()

// -- GuiImageButtonEx()
//-------------------------------------------------------------------------------

// Text required functions
//-------------------------------------------------------------------------------
// --  GetTextWidth()

// -- GetTextWidth(), GuiTextBoxMulti()
// -- GuiDrawText()
//-------------------------------------------------------------------------------

// RAYGUI_STANDALONE

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------

Vector3 ConvertHSVtoRGB(Vector3 hsv); // Convert color data from HSV to RGB
Vector3 ConvertRGBtoHSV(Vector3 rgb); // Convert color data from RGB to HSV

// TODO: GetTextSize()

/// Gui get text width using default font
private int GetTextWidth(string text) {
   import std.string : empty, toStringz;

   Vector2 size = Vector2(0.0f, 0.0f);
   if (!text.empty) {
      size = MeasureTextEx(guiFont, text.toStringz, GuiGetStyle(GuiControl.DEFAULT, GuiDefaultProperty.TEXT_SIZE),
            GuiGetStyle(GuiControl.DEFAULT, GuiDefaultProperty.TEXT_SPACING));
   }
   // TODO: Consider text icon width here???
   return cast(int)size.x;
}

/// Get text bounds considering control bounds
private Rectangle GetTextBounds(int control, in Rectangle bounds) {
   immutable border = GuiGetStyle(control, GuiControlProperty.BORDER_WIDTH);
   immutable padding = GuiGetStyle(control, GuiControlProperty.INNER_PADDING);
   Rectangle textBounds = Rectangle(bounds.x + border + padding, bounds.y + border + padding,
         bounds.width - 2 * (border + padding), bounds.height - 2 * (border + padding));
   switch (control) {
      case GuiControl.COMBOBOX:
         textBounds.width -= (GuiGetStyle(control,
               GuiComboBoxProperty.SELECTOR_WIDTH) + GuiGetStyle(control, GuiComboBoxProperty.SELECTOR_PADDING));
         break;
      case GuiControl.CHECKBOX:
         textBounds.x += (bounds.width + GuiGetStyle(control, GuiCheckBoxProperty.CHECK_TEXT_PADDING));
         break;
      default:
         break;
   }
   // TODO: Special cases (no label): COMBOBOX, DROPDOWNBOX, SPINNER, LISTVIEW (scrollbar?)
   // More special cases (label side): CHECKBOX, SLIDER
   return textBounds;

}

/// Get text icon if provided and move text cursor
string GetTextIcon(string text, out int iconId) {
   version (RAYGUI_RICONS_SUPPORT) {
      //TODO: Work out what's going on here.
      if (text[0] == "#") {
         //.scan(/#(\d{3})#/).first.first.to_i
      }
   }
   return text;
}

/// Gui draw text using default font
void GuiDrawText(string text, Rectangle bounds, int alignment, Color tint) {
   import std.string : empty, toStringz;

   enum ICON_TEXT_PADDING = 4;
   if (!text.empty) {
      int iconId;
      text = GetTextIcon(text, iconId); // Check text for icon and move cursor

      // Get text position depending on alignment and iconId
      //---------------------------------------------------------------------------------

      Vector2 position = Vector2(bounds.x, bounds.y);

      // NOTE: We get text size after icon been processed
      int textWidth = GetTextWidth(text);
      int textHeight = GuiGetStyle(DEFAULT, TEXT_SIZE);

      version (RAYGUI_RICONS_SUPPORT) {
         if (iconId > 0) {
            textWidth += RICONS_SIZE;
            // WARNING: If only icon provided, text could be pointing to eof character!
            if (!text.empty) {
               textWidth += ICON_TEXT_PADDING;
            }
         }
      }
      // Check guiTextAlign global variables
      switch (alignment) {
         case GUI_TEXT_ALIGN_LEFT:
            position.x = bounds.x;
            position.y = bounds.y + bounds.height / 2 - textHeight / 2 + VALIGN_OFFSET(bounds.height);
            break;
         case GUI_TEXT_ALIGN_CENTER:
            position.x = bounds.x + bounds.width / 2 - textWidth / 2;
            position.y = bounds.y + bounds.height / 2 - textHeight / 2 + VALIGN_OFFSET(bounds.height);
            break;
         case GUI_TEXT_ALIGN_RIGHT:
            position.x = bounds.x + bounds.width - textWidth;
            position.y = bounds.y + bounds.height / 2 - textHeight / 2 + VALIGN_OFFSET(bounds.height);
            break;
         default:
            break;
      }
      //---------------------------------------------------------------------------------

      // Draw text (with icon if available)
      //---------------------------------------------------------------------------------
      version (RAYGUI_RICONS_SUPPORT) {
         if (iconId > 0) {
            // NOTE: We consider icon height, probably different than text size
            DrawIcon(iconId, Vector2(position.x, bounds.y + bounds.height / 2 - RICONS_SIZE / 2 + VALIGN_OFFSET(bounds.height)), 1, tint);
            position.x += (RICONS_SIZE + ICON_TEXT_PADDING);
         }
      } else {
         DrawTextEx(guiFont, text.toStringz, position, GuiGetStyle(DEFAULT, TEXT_SIZE), GuiGetStyle(DEFAULT, TEXT_SPACING), tint);
      }
      //---------------------------------------------------------------------------------
   }
}

/// Enable gui global state
void GuiEnable() {
   guiState = GuiControlState.GUI_STATE_NORMAL;
}

/// Disable gui global state
void GuiDisable() {
   guiState = GuiControlState.GUI_STATE_DISABLED;
}

/// Lock gui global state
void GuiLock() {
   guiLocked = true;
}

/// Unlock gui global state
void GuiUnlock() {
   guiLocked = false;
}

/// Set gui state (global state)
void GuiState(int state) {
   guiState = cast(GuiControlState)state;
}

/// Define custom gui font
void GuiFont(Font font) {
   if (font.texture.id > 0) {
      guiFont = font;
      GuiSetStyle(GuiControl.DEFAULT, GuiDefaultProperty.TEXT_SIZE, font.baseSize);
   }
}

/// Set gui controls alpha global state
void GuiFade(float alpha) {
   import std.algorithm : clamp;

   guiAlpha = alpha.clamp(0.0f, 1.0f);
}

/// Set control style property value
void GuiSetStyle(int control, int property, int value) {
   if (!guiStyleLoaded) {
      GuiLoadStyleDefault();
   }
   guiStyle[control * (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED) + property] = value;
}

/**
 * Get control style property value
 * Params:
 *  control = Control index
 *  property = Property index
 */
int GuiGetStyle(int control, int property) {
   if (!guiStyleLoaded) {
      GuiLoadStyleDefault();
   }
   return guiStyle[control * (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED) + property];
}

/// Window Box control
bool GuiWindowBox(Rectangle bounds, string text) {
   enum WINDOW_CLOSE_BUTTON_PADDING = 2;
   enum WINDOW_STATUSBAR_HEIGHT = 24;
   GuiControlState state = guiState;
   bool clicked;
   immutable borderWidth = GuiGetStyle(GuiControl.DEFAULT, GuiControlProperty.BORDER_WIDTH);
   immutable statusBar = Rectangle(bounds.x, bounds.y, bounds.width, WINDOW_STATUSBAR_HEIGHT);
   immutable buttonRec = Rectangle(statusBar.x + statusBar.width - borderWidth - WINDOW_CLOSE_BUTTON_PADDING - 20,
         statusBar.y + borderWidth + WINDOW_CLOSE_BUTTON_PADDING, 18, 18);
   if (bounds.height < WINDOW_STATUSBAR_HEIGHT * 2)
      bounds.height = WINDOW_STATUSBAR_HEIGHT * 2;
   // Update control
   //--------------------------------------------------------------------
   // NOTE: Logic is directly managed by button
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------

   // Draw window base
   DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(GuiControl.DEFAULT,
         GuiPropertyElement.BORDER + (state * 3))), guiAlpha));
   DrawRectangleRec(Rectangle(bounds.x + borderWidth, bounds.y + borderWidth, bounds.width - borderWidth * 2, bounds.height - borderWidth
         * 2), Fade(GetColor(GuiGetStyle(GuiControl.DEFAULT, GuiDefaultProperty.BACKGROUND_COLOR)), guiAlpha));

   // Draw window header as status bar
   immutable defaultPadding = GuiGetStyle(GuiControl.DEFAULT, GuiControlProperty.INNER_PADDING);
   immutable defaultTextAlign = GuiGetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_ALIGNMENT);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.INNER_PADDING, 8);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_ALIGNMENT, GuiTextAlignment.GUI_TEXT_ALIGN_LEFT);
   GuiStatusBar(statusBar, text);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.INNER_PADDING, defaultPadding);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_ALIGNMENT, defaultTextAlign);

   // Draw window close button
   immutable tempBorderWidth = GuiGetStyle(GuiControl.BUTTON, GuiControlProperty.BORDER_WIDTH);
   immutable tempTextAlignment = GuiGetStyle(GuiControl.BUTTON, GuiControlProperty.TEXT_ALIGNMENT);
   GuiSetStyle(GuiControl.BUTTON, GuiControlProperty.BORDER_WIDTH, 1);
   GuiSetStyle(GuiControl.BUTTON, GuiControlProperty.TEXT_ALIGNMENT, GuiTextAlignment.GUI_TEXT_ALIGN_CENTER);
   version (RAYGUI_RICONS_SUPPORT) {
      clicked = GuiButton(buttonRec, GuiIconText(RICON_CROSS_SMALL, NULL));
   } else {
      clicked = GuiButton(buttonRec, "x");
   }
   GuiSetStyle(GuiControl.BUTTON, GuiControlProperty.BORDER_WIDTH, tempBorderWidth);
   GuiSetStyle(GuiControl.BUTTON, GuiControlProperty.TEXT_ALIGNMENT, tempTextAlignment);
   //--------------------------------------------------------------------

   return clicked;

}

//// Group Box control with title name
void GuiGroupBox(Rectangle bounds, string text) {
   enum GROUPBOX_LINE_THICK = 1;
   immutable state = guiState;
   immutable color = (state == GUI_STATE_DISABLED) ? BORDER_COLOR_DISABLED : LINE_COLOR;
   auto fade = GuiGetStyle(GuiControl.DEFAULT, color).GetColor.Fade(guiAlpha);
   // Draw control
   //--------------------------------------------------------------------
   DrawRectangle(cast(int)bounds.x, cast(int)bounds.y, GROUPBOX_LINE_THICK, cast(int)bounds.height, fade);
   DrawRectangle(cast(int)bounds.x, cast(int)(bounds.y + bounds.height - 1), cast(int)bounds.width, GROUPBOX_LINE_THICK, fade);
   DrawRectangle(cast(int)(bounds.x + bounds.width - 1), cast(int)bounds.y, GROUPBOX_LINE_THICK, cast(int)bounds.height, fade);
   GuiLine(Rectangle(cast(int)bounds.x, cast(int)bounds.y, cast(int)bounds.width, 1), text);
}

/// Line control
void GuiLine(Rectangle bounds, string text) {
   import std.string : empty;

   enum LINE_TEXT_PADDING = 10;
   enum LINE_TEXT_SPACING = 2;

   GuiControlState state = guiState;

   immutable color = (state == GUI_STATE_DISABLED) ? BORDER_COLOR_DISABLED : LINE_COLOR;
   auto fade = GuiGetStyle(GuiControl.DEFAULT, color).GetColor.Fade(guiAlpha);

   // Draw control
   //--------------------------------------------------------------------
   if (text.empty) {
      DrawRectangle(cast(int)bounds.x, cast(int)(bounds.y + bounds.height / 2), cast(int)bounds.width, 1, fade);
   } else {
      Rectangle textBounds;
      textBounds.width = GetTextWidth(text) + 2 * LINE_TEXT_SPACING; // TODO: Consider text icon
      textBounds.height = GuiGetStyle(DEFAULT, TEXT_SIZE);
      textBounds.x = bounds.x + LINE_TEXT_PADDING + LINE_TEXT_SPACING;
      textBounds.y = bounds.y - GuiGetStyle(DEFAULT, TEXT_SIZE) / 2;

      // Draw line with embedded text label: "--- text --------------"
      DrawRectangle(cast(int)bounds.x, cast(int)bounds.y, LINE_TEXT_PADDING, 1, fade);
      GuiLabel(textBounds, text);
      DrawRectangle(cast(int)(bounds.x + textBounds.width + LINE_TEXT_PADDING + 2 * LINE_TEXT_SPACING),
            cast(int)bounds.y, cast(int)(bounds.width - (textBounds.width + LINE_TEXT_PADDING + 2 * LINE_TEXT_SPACING)), 1, fade);
   }
   //--------------------------------------------------------------------
}

/// Panel control
void GuiPanel(Rectangle bounds) {
   enum PANEL_BORDER_WIDTH = 1;
   auto state = guiState;
   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleRec(bounds, Fade(GetColor(GuiGetStyle(DEFAULT, (state == GUI_STATE_DISABLED) ? BASE_COLOR_DISABLED
         : BACKGROUND_COLOR)), guiAlpha));
   DrawRectangleLinesEx(bounds, PANEL_BORDER_WIDTH, Fade(GetColor(GuiGetStyle(DEFAULT, (state == GUI_STATE_DISABLED)
         ? BORDER_COLOR_DISABLED : LINE_COLOR)), guiAlpha));
   //--------------------------------------------------------------------
}

/// Scroll Panel control
Rectangle GuiScrollPanel(Rectangle bounds, Rectangle content, ref Vector2 scroll) {
   import std.algorithm : clamp;

   auto state = guiState;
   Vector2 scrollPos = scroll;

   bool hasHorizontalScrollBar = (content.width > bounds.width - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH)) ? true : false;
   bool hasVerticalScrollBar = (content.height > bounds.height - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH)) ? true : false;

   // Recheck to account for the other scrollbar being visible
   if (!hasHorizontalScrollBar)
      hasHorizontalScrollBar = (hasVerticalScrollBar && (content.width > (bounds.width - 2 * GuiGetStyle(DEFAULT,
            BORDER_WIDTH) - GuiGetStyle(LISTVIEW, SCROLLBAR_WIDTH)))) ? true : false;
   if (!hasVerticalScrollBar)
      hasVerticalScrollBar = (hasHorizontalScrollBar && (content.height > (bounds.height - 2 * GuiGetStyle(DEFAULT,
            BORDER_WIDTH) - GuiGetStyle(LISTVIEW, SCROLLBAR_WIDTH)))) ? true : false;

   const horizontalScrollBarWidth = hasHorizontalScrollBar ? GuiGetStyle(LISTVIEW, SCROLLBAR_WIDTH) : 0;
   const verticalScrollBarWidth = hasVerticalScrollBar ? GuiGetStyle(LISTVIEW, SCROLLBAR_WIDTH) : 0;
   const Rectangle horizontalScrollBar = {
      ((GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE) ? bounds.x + verticalScrollBarWidth : bounds.x) + GuiGetStyle(DEFAULT, BORDER_WIDTH),
         bounds.y + bounds.height - horizontalScrollBarWidth - GuiGetStyle(DEFAULT, BORDER_WIDTH),
         bounds.width - verticalScrollBarWidth - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH), horizontalScrollBarWidth
   };
   const Rectangle verticalScrollBar = {
      ((GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE) ? bounds.x + GuiGetStyle(DEFAULT, BORDER_WIDTH)
            : bounds.x + bounds.width - verticalScrollBarWidth - GuiGetStyle(DEFAULT, BORDER_WIDTH)), bounds.y + GuiGetStyle(DEFAULT,
            BORDER_WIDTH), verticalScrollBarWidth, bounds.height - horizontalScrollBarWidth - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH)
   };

   // Calculate view area (area without the scrollbars)
   Rectangle view = (GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE) ? Rectangle(bounds.x + verticalScrollBarWidth + GuiGetStyle(DEFAULT,
         BORDER_WIDTH), bounds.y + GuiGetStyle(DEFAULT, BORDER_WIDTH), bounds.width - 2 * GuiGetStyle(DEFAULT,
         BORDER_WIDTH) - verticalScrollBarWidth, bounds.height - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH) - horizontalScrollBarWidth)
      : Rectangle(bounds.x + GuiGetStyle(DEFAULT, BORDER_WIDTH), bounds.y + GuiGetStyle(DEFAULT, BORDER_WIDTH),
            bounds.width - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH) - verticalScrollBarWidth,
            bounds.height - 2 * GuiGetStyle(DEFAULT, BORDER_WIDTH) - horizontalScrollBarWidth);

   // Clip view area to the actual content size
   view.width = view.width.clamp(0, content.width);
   view.height = view.height.clamp(0, content.height);

   // TODO: Review!
   const horizontalMin = hasHorizontalScrollBar ? ((GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE)
         ? -verticalScrollBarWidth : 0) - GuiGetStyle(DEFAULT, BORDER_WIDTH) : ((GuiGetStyle(LISTVIEW,
         SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE) ? -verticalScrollBarWidth : 0) - GuiGetStyle(DEFAULT, BORDER_WIDTH);
   const horizontalMax = hasHorizontalScrollBar ? content.width - bounds.width + verticalScrollBarWidth + GuiGetStyle(DEFAULT,
         BORDER_WIDTH) - ((GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE) ? verticalScrollBarWidth : 0)
      : -GuiGetStyle(DEFAULT, BORDER_WIDTH);
   const verticalMin = hasVerticalScrollBar ? -GuiGetStyle(DEFAULT, BORDER_WIDTH) : -GuiGetStyle(DEFAULT, BORDER_WIDTH);
   const verticalMax = hasVerticalScrollBar ? content.height - bounds.height + horizontalScrollBarWidth + GuiGetStyle(DEFAULT,
         BORDER_WIDTH) : -GuiGetStyle(DEFAULT, BORDER_WIDTH);

   // Update control
   //--------------------------------------------------------------------
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();

      // Check button state
      if (CheckCollisionPointRec(mousePoint, bounds)) {
         if (IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON))
            state = GUI_STATE_PRESSED;
         else
            state = GUI_STATE_FOCUSED;

         if (hasHorizontalScrollBar) {
            if (IsKeyDown(KeyboardKey.KEY_RIGHT))
               scrollPos.x -= GuiGetStyle(SCROLLBAR, SCROLL_SPEED);
            if (IsKeyDown(KeyboardKey.KEY_LEFT))
               scrollPos.x += GuiGetStyle(SCROLLBAR, SCROLL_SPEED);
         }

         if (hasVerticalScrollBar) {
            if (IsKeyDown(KeyboardKey.KEY_DOWN))
               scrollPos.y -= GuiGetStyle(SCROLLBAR, SCROLL_SPEED);
            if (IsKeyDown(KeyboardKey.KEY_UP))
               scrollPos.y += GuiGetStyle(SCROLLBAR, SCROLL_SPEED);
         }

         scrollPos.y += GetMouseWheelMove() * 20;
      }
   }

   // Normalize scroll values
   if (scrollPos.x > -horizontalMin)
      scrollPos.x = -horizontalMin;
   if (scrollPos.x < -horizontalMax)
      scrollPos.x = -horizontalMax;
   if (scrollPos.y > -verticalMin)
      scrollPos.y = -verticalMin;
   if (scrollPos.y < -verticalMax)
      scrollPos.y = -verticalMax;
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleRec(bounds, GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR))); // Draw background

   // Save size of the scrollbar slider
   const int slider = GuiGetStyle(SCROLLBAR, SLIDER_SIZE);

   // Draw horizontal scrollbar if visible
   if (hasHorizontalScrollBar) {
      // Change scrollbar slider size to show the diff in size between the content width and the widget width
      GuiSetStyle(SCROLLBAR, SLIDER_SIZE, cast(int)(((bounds.width - 2 * GuiGetStyle(DEFAULT,
            BORDER_WIDTH) - verticalScrollBarWidth) / content.width) * (bounds.width - 2 * GuiGetStyle(DEFAULT,
            BORDER_WIDTH) - verticalScrollBarWidth)));
      scrollPos.x = -GuiScrollBar(horizontalScrollBar, cast(int)-scrollPos.x, cast(int)horizontalMin, cast(int)horizontalMax);
   }

   // Draw vertical scrollbar if visible
   if (hasVerticalScrollBar) {
      // Change scrollbar slider size to show the diff in size between the content height and the widget height
      GuiSetStyle(SCROLLBAR, SLIDER_SIZE, cast(int)(((bounds.height - 2 * GuiGetStyle(DEFAULT,
            BORDER_WIDTH) - horizontalScrollBarWidth) / content.height) * (bounds.height - 2 * GuiGetStyle(DEFAULT,
            BORDER_WIDTH) - horizontalScrollBarWidth)));
      scrollPos.y = -GuiScrollBar(verticalScrollBar, cast(int)-scrollPos.y, cast(int)verticalMin, cast(int)verticalMax);
   }

   // Draw detail corner rectangle if both scroll bars are visible
   if (hasHorizontalScrollBar && hasVerticalScrollBar) {
      // TODO: Consider scroll bars side
      DrawRectangleRec(Rectangle(horizontalScrollBar.x + horizontalScrollBar.width + 2,
            verticalScrollBar.y + verticalScrollBar.height + 2, horizontalScrollBarWidth - 4, verticalScrollBarWidth - 4),
            Fade(GetColor(GuiGetStyle(LISTVIEW, TEXT + (state * 3))), guiAlpha));
   }

   // Set scrollbar slider size back to the way it was before
   GuiSetStyle(SCROLLBAR, SLIDER_SIZE, slider);

   // Draw scrollbar lines depending on current state
   DrawRectangleLinesEx(bounds, GuiGetStyle(DEFAULT, BORDER_WIDTH), Fade(GetColor(GuiGetStyle(LISTVIEW, BORDER + (state * 3))), guiAlpha));
   //--------------------------------------------------------------------

   scroll = scrollPos;

   return view;
}

/// Label control
void GuiLabel(Rectangle bounds, string text) {
   auto state = guiState;
   immutable color = (state == GUI_STATE_DISABLED) ? TEXT_COLOR_DISABLED : TEXT_COLOR_NORMAL;
   auto fade = GuiGetStyle(GuiControl.LABEL, color).GetColor.Fade(guiAlpha);
   // Update control
   //--------------------------------------------------------------------
   // ...
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   GuiDrawText(text, GetTextBounds(LABEL, bounds), GuiGetStyle(LABEL, TEXT_ALIGNMENT), fade);
   //--------------------------------------------------------------------
}

///
/**
 * Button control
 *
 * Params:
 *  bounds = Button bounds
 *  text = Text inside button
 *
 *
 * Returns:  true when clicked
 *
 */
bool GuiButton(Rectangle bounds, string text) {
   GuiControlState state = guiState;
   immutable(int) borderWidth = GuiGetStyle(BUTTON, BORDER_WIDTH);
   immutable(int) pressed = bounds.LeftClicked(state);

   // Draw control
   /+
   DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(BUTTON, BORDER + (state * 3))), guiAlpha));
   DrawRectangleRec(Rectangle(bounds.x + borderWidth, bounds.y + borderWidth, bounds.width - 2 * borderWidth, bounds.height - 2
         * borderWidth), Fade(GetColor(GuiGetStyle(BUTTON, BASE + (state * 3))), guiAlpha));
   GuiDrawText(text, GetTextBounds(BUTTON, bounds), GuiGetStyle(BUTTON, TEXT_ALIGNMENT),
         Fade(GetColor(GuiGetStyle(BUTTON, TEXT + (state * 3))), guiAlpha));
+/
   DrawRectangleLinesEx(bounds, borderWidth, Fade(getBtnColor!BORDER(state), guiAlpha));
   DrawRectangleRec(Rectangle(bounds.x + borderWidth, bounds.y + borderWidth, bounds.width - 2 * borderWidth, bounds.height - 2
         * borderWidth), Fade(getBtnColor!BASE(state), guiAlpha));
   GuiDrawText(text, GetTextBounds(BUTTON, bounds), GuiGetStyle(BUTTON, TEXT_ALIGNMENT),
         Fade(getBtnColor!TEXT(state), guiAlpha));

   return pressed;
}
private Color getBtnColor(GuiPropertyElement E)(GuiControlState state) {
   return GetColor(GuiGetStyle(BUTTON, E + (state * 3)));
}

private Fade getBtnFade(GuiPropertyElement E)(GuiControlState state, float alpha) {
   return Fade(getBtnColor!E(state), alpha);
}


/// Determine whether something has been clicked.
private bool LeftClicked(in Rectangle bounds, ref GuiControlState state) {
   bool clicked;
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();
      // Check checkbox state
      if (CheckCollisionPointRec(mousePoint, bounds)) {
         if (IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
            state = GUI_STATE_PRESSED;
         } else if (IsMouseButtonReleased(MouseButton.MOUSE_LEFT_BUTTON)) {
            clicked = true;
         } else {
            state = GUI_STATE_FOCUSED;
         }
      }
   }
   return clicked;
}

/// Label button control
bool GuiLabelButton(Rectangle bounds, string text) {
   auto state = guiState;
   auto clicked = bounds.LeftClicked(state);
   auto fade = GuiGetStyle(LABEL, TEXT + (state * 3)).GetColor.Fade(guiAlpha);

   GuiDrawText(text, GetTextBounds(LABEL, bounds), GuiGetStyle(LABEL, TEXT_ALIGNMENT), fade);

   return clicked;
}

/// Image button control, returns true when clicked
bool GuiImageButton(Rectangle bounds, Texture2D texture) {
   return GuiImageButtonEx(bounds, texture, Rectangle(0, 0, texture.width, texture.height), "");
}

/// Image button control, returns true when clicked
bool GuiImageButtonEx(Rectangle bounds, Texture2D texture, Rectangle texSource, string text) {
   auto state = guiState;
   auto clicked = bounds.LeftClicked(state);

   DrawRectangleLinesEx(bounds, GuiGetStyle(BUTTON, BORDER_WIDTH), Fade(GetColor(GuiGetStyle(BUTTON, BORDER + (state * 3))), guiAlpha));
   DrawRectangle(cast(int)(bounds.x + GuiGetStyle(BUTTON, BORDER_WIDTH)), cast(int)(bounds.y + GuiGetStyle(BUTTON,
         BORDER_WIDTH)), cast(int)(bounds.width - 2 * GuiGetStyle(BUTTON, BORDER_WIDTH)),
         cast(int)(bounds.height - 2 * GuiGetStyle(BUTTON, BORDER_WIDTH)), Fade(GetColor(GuiGetStyle(BUTTON,
            BASE + (state * 3))), guiAlpha));

   if (text !is "") {
      GuiDrawText(text, GetTextBounds(BUTTON, bounds), GuiGetStyle(BUTTON, TEXT_ALIGNMENT),
            Fade(GetColor(GuiGetStyle(BUTTON, TEXT + (state * 3))), guiAlpha));
   }
   if (texture.id > 0) {
      DrawTextureRec(texture, texSource, Vector2(bounds.x + bounds.width / 2 - (texSource.width + GuiGetStyle(BUTTON,
            INNER_PADDING) / 2) / 2, bounds.y + bounds.height / 2 - texSource.height / 2),
            Fade(GetColor(GuiGetStyle(BUTTON, TEXT + (state * 3))), guiAlpha));
   }
   return clicked;
}

/// Toggle Button control, returns true when active
bool GuiToggle(Rectangle bounds, string text, bool active) {
   auto state = guiState;
   immutable borderWidth = GuiGetStyle(TOGGLE, BORDER_WIDTH);
   immutable textAlignment = GuiGetStyle(TOGGLE, TEXT_ALIGNMENT);
   // Update control.
   if (bounds.LeftClicked(state)) {
      active = !active;
   }

   immutable Rectangle toggleView = {
      bounds.x + borderWidth, bounds.y + borderWidth, bounds.width - 2 * borderWidth, bounds.height - 2 * borderWidth
   };
   if (state == GUI_STATE_NORMAL) {
      DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(TOGGLE, (active ? BORDER_COLOR_PRESSED
            : (BORDER + state * 3)))), guiAlpha));
      DrawRectangleRec(toggleView, Fade(GetColor(GuiGetStyle(TOGGLE, (active ? BASE_COLOR_PRESSED : (BASE + state * 3)))), guiAlpha));

      GuiDrawText(text, GetTextBounds(TOGGLE, bounds), textAlignment, Fade(GetColor(GuiGetStyle(TOGGLE, (active
            ? TEXT_COLOR_PRESSED : (TEXT + state * 3)))), guiAlpha));
   } else {
      DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(TOGGLE, BORDER + state * 3)), guiAlpha));
      DrawRectangleRec(toggleView, Fade(GetColor(GuiGetStyle(TOGGLE, BASE + state * 3)), guiAlpha));
      GuiDrawText(text, GetTextBounds(TOGGLE, bounds), textAlignment, Fade(GetColor(GuiGetStyle(TOGGLE, TEXT + state * 3)), guiAlpha));
   }
   return active;
}

/// Toggle Group control, returns toggled button index
int GuiToggleGroup(Rectangle bounds, string text, int active) {
   immutable initBoundsX = bounds.x;
   immutable padding = GuiGetStyle(TOGGLE, GROUP_PADDING);
   // Get substrings elements from text (elements pointers)
   string[] elements = text.GuiTextSplit();
   string prevRow = elements[0];
   foreach (i, element; elements) {
      if (prevRow != element) {
         bounds.x = initBoundsX;
         bounds.y += (bounds.height + padding);
         prevRow = element;
      }

      if (i == active) {
         GuiToggle(bounds, element, true);
      } else if (GuiToggle(bounds, element, false) == true) {
         // FIX: size_t active ??
         active = cast(int)i;
      }

      bounds.x += (bounds.width + padding);
   }
   return active;
}

/// Check Box control, returns true when active
bool GuiCheckBox(Rectangle bounds, string text, bool checked) {
   auto state = guiState;
   Rectangle textBounds;
   immutable textPadding = GuiGetStyle(CHECKBOX, CHECK_TEXT_PADDING);
   immutable controlPadding = GuiGetStyle(CHECKBOX, INNER_PADDING);
   immutable borderWidth = GuiGetStyle(CHECKBOX, BORDER_WIDTH);
   textBounds.x = bounds.x + bounds.width + textPadding;
   textBounds.y = bounds.y + bounds.height / 2 - GuiGetStyle(DEFAULT, TEXT_SIZE) / 2;
   textBounds.width = GetTextWidth(text); // TODO: Consider text icon
   textBounds.height = GuiGetStyle(DEFAULT, TEXT_SIZE);

   // Update control
   if (bounds.LeftClicked(state)) {
      checked = !checked;
   }
   // Draw control
   DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(CHECKBOX, BORDER + (state * 3))), guiAlpha));
   if (checked) {
      DrawRectangleRec(Rectangle(bounds.x + borderWidth + controlPadding, bounds.y + borderWidth + controlPadding,
            bounds.width - 2 * (borderWidth + controlPadding), bounds.height - 2 * (borderWidth + controlPadding)),
            Fade(GetColor(GuiGetStyle(CHECKBOX, TEXT + state * 3)), guiAlpha));
   }

   // NOTE: Forced left text alignment
   GuiDrawText(text, textBounds, GUI_TEXT_ALIGN_LEFT, Fade(GetColor(GuiGetStyle(LABEL, TEXT + (state * 3))), guiAlpha));
   return checked;
}

/// Combo Box control, returns selected item index
int GuiComboBox(Rectangle bounds, string text, int active) {
   import std.algorithm : clamp;
   import std.string : fromStringz;

   auto state = guiState;
   immutable comboWidth = GuiGetStyle(COMBOBOX, SELECTOR_WIDTH);
   immutable comboPadding = GuiGetStyle(COMBOBOX, SELECTOR_PADDING);
   immutable comboBorderWidth = GuiGetStyle(COMBOBOX, BORDER_WIDTH);
   bounds.width -= (comboWidth + comboPadding);

   Rectangle selector = Rectangle(bounds.x + bounds.width + comboPadding, bounds.y, comboWidth, bounds.height);

   // Get substrings elements from text (elements pointers, lengths and count)
   auto elements = text.GuiTextSplit();
   immutable elementCount = (elements.length - 1) > 0 ? elements.length - 1 : 0;
   active = active.clamp(0, elementCount);

   // Update control
   if (bounds.LeftClicked(state)) {
      active = ((active + 1) >= elements.length) ? 0 : active + 1;
   }

   // Draw combo box main
   DrawRectangleLinesEx(bounds, comboBorderWidth, Fade(GetColor(GuiGetStyle(COMBOBOX, BORDER + (state * 3))), guiAlpha));
   DrawRectangle(cast(int)(bounds.x + comboBorderWidth), cast(int)(bounds.y + comboBorderWidth),
         cast(int)(bounds.width - 2 * comboBorderWidth), cast(int)(bounds.height - 2 * comboBorderWidth),
         Fade(GetColor(GuiGetStyle(COMBOBOX, BASE + (state * 3))), guiAlpha));

   GuiDrawText(elements[active], GetTextBounds(COMBOBOX, bounds), GuiGetStyle(COMBOBOX, TEXT_ALIGNMENT),
         Fade(GetColor(GuiGetStyle(COMBOBOX, TEXT + (state * 3))), guiAlpha));

   // Draw selector using a custom button
   // NOTE: BORDER_WIDTH and TEXT_ALIGNMENT forced values
   immutable tempBorderWidth = GuiGetStyle(BUTTON, BORDER_WIDTH);
   immutable tempTextAlign = GuiGetStyle(BUTTON, TEXT_ALIGNMENT);
   GuiSetStyle(BUTTON, BORDER_WIDTH, 1);
   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);
   GuiButton(selector, cast(string)TextFormat("%i/%i", active + 1, elements.length).fromStringz);

   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, tempTextAlign);
   GuiSetStyle(BUTTON, BORDER_WIDTH, tempBorderWidth);
   return active;
}

/// Dropdown Box control, returns selected item
bool GuiDropdownBox(Rectangle bounds, string text, ref int active, bool editMode) {
   auto state = guiState;
   bool pressed;
   int auxActive = active;
   const elements = text.GuiTextSplit();
   Rectangle closeBounds = bounds;
   Rectangle openBounds = bounds;
   openBounds.height *= elements.length + 1;
   if (guiLocked && editMode) {
      guiLocked = false;
   }
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();
      if (editMode) {
         state = GUI_STATE_PRESSED;
      }
      if (!editMode) {
         if (CheckCollisionPointRec(mousePoint, closeBounds)) {
            if (IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
               state = GUI_STATE_PRESSED;
            }
            if (IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON)) {
               pressed = true;
            } else {
               state = GUI_STATE_FOCUSED;
            }
         }
      } else {
         if (CheckCollisionPointRec(mousePoint, closeBounds)) {
            if (IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON)) {
               pressed = true;
            }
         } else if (!CheckCollisionPointRec(mousePoint, openBounds)) {
            if (IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON) || IsMouseButtonReleased(MouseButton.MOUSE_LEFT_BUTTON)) {
               pressed = true;
            }
         }
      }
   }
   // Draw control
   //--------------------------------------------------------------------

   // TODO: Review this ugly hack... DROPDOWNBOX depends on GuiListElement() that uses DEFAULT_TEXT_ALIGNMENT
   immutable tempTextAlign = GuiGetStyle(DEFAULT, TEXT_ALIGNMENT);
   immutable dropDownPadding = GuiGetStyle(DROPDOWNBOX, INNER_PADDING);
   GuiSetStyle(DEFAULT, TEXT_ALIGNMENT, GuiGetStyle(DROPDOWNBOX, TEXT_ALIGNMENT));
   switch (state) {
      case GUI_STATE_NORMAL:
         DrawRectangleRec(bounds, Fade(GetColor(GuiGetStyle(DROPDOWNBOX, BASE_COLOR_NORMAL)), guiAlpha));
         DrawRectangleLinesEx(bounds, GuiGetStyle(DROPDOWNBOX, BORDER_WIDTH), Fade(GetColor(GuiGetStyle(DROPDOWNBOX,
               BORDER_COLOR_NORMAL)), guiAlpha));
         GuiListElement(bounds, elements[auxActive], false, false);
         break;
      case GUI_STATE_FOCUSED:
         GuiListElement(bounds, elements[auxActive], false, editMode);
         break;
      case GUI_STATE_PRESSED:
         if (!editMode) {
            GuiListElement(bounds, elements[auxActive], true, true);
         }
         if (editMode) {
            GuiPanel(openBounds);
            GuiListElement(bounds, elements[auxActive], true, true);
            foreach (i, element; elements) {
               Rectangle listRect = {
                  bounds.x, bounds.y + bounds.height * (i + 1) + dropDownPadding, bounds.width, bounds.height - dropDownPadding
               };
               if (i == auxActive && editMode) {
                  if (GuiListElement(listRect, element, true, true) == false) {
                     pressed = true;
                  }
               } else {
                  if (GuiListElement(listRect, element, false, true)) {
                     auxActive = cast(int)i;
                     pressed = true;
                  }
               }
            }
         }
         break;
      case GUI_STATE_DISABLED:
         DrawRectangleRec(bounds, Fade(GetColor(GuiGetStyle(DROPDOWNBOX, BASE_COLOR_DISABLED)), guiAlpha));
         DrawRectangleLinesEx(bounds, GuiGetStyle(DROPDOWNBOX, BORDER_WIDTH), Fade(GetColor(GuiGetStyle(DROPDOWNBOX,
               BORDER_COLOR_DISABLED)), guiAlpha));
         GuiListElement(bounds, elements[auxActive], false, false);
         break;
      default:
         break;
   }

   GuiSetStyle(DEFAULT, TEXT_ALIGNMENT, tempTextAlign);
   immutable arrowPadding = GuiGetStyle(DROPDOWNBOX, ARROW_RIGHT_PADDING);
   // TODO: Avoid this function, use icon instead or 'v'
   DrawTriangle(Vector2(bounds.x + bounds.width - arrowPadding, bounds.y + bounds.height / 2 - 2),
         Vector2(bounds.x + bounds.width - arrowPadding + 5, bounds.y + bounds.height / 2 - 2 + 5),
         Vector2(bounds.x + bounds.width - arrowPadding + 10, bounds.y + bounds.height / 2 - 2),
         Fade(GetColor(GuiGetStyle(DROPDOWNBOX, TEXT + (state * 3))), guiAlpha));
   //--------------------------------------------------------------------

   active = auxActive;
   return pressed;
}

/// Spinner control, returns selected value
bool GuiSpinner(Rectangle bounds, ref int value, int minValue, int maxValue, bool editMode) {
   import std.algorithm : clamp;

   bool pressed;
   int tempValue = value;
   immutable selectWidth = GuiGetStyle(SPINNER, SELECT_BUTTON_WIDTH);
   immutable selectPadding = GuiGetStyle(SPINNER, SELECT_BUTTON_PADDING);
   Rectangle spinner = {
      bounds.x + selectWidth + selectPadding, bounds.y, bounds.width - 2 * (selectWidth + selectPadding), bounds.height
   };
   Rectangle leftButtonBound = {bounds.x, bounds.y, selectWidth, bounds.height};
   Rectangle rightButtonBound = {bounds.x + bounds.width - selectWidth, bounds.y, selectWidth, bounds.height};

   // Update control
   //--------------------------------------------------------------------
   if (!editMode) {
      tempValue = tempValue.clamp(minValue, maxValue);
   }
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   // TODO: Set Spinner properties for ValueBox
   pressed = GuiValueBox(spinner, tempValue, minValue, maxValue, editMode);

   // Draw value selector custom buttons
   // NOTE: BORDER_WIDTH and TEXT_ALIGNMENT forced values
   immutable tempBorderWidth = GuiGetStyle(BUTTON, BORDER_WIDTH);
   GuiSetStyle(BUTTON, BORDER_WIDTH, GuiGetStyle(SPINNER, BORDER_WIDTH));

   immutable tempTextAlign = GuiGetStyle(BUTTON, TEXT_ALIGNMENT);
   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);

   version (RAYGUI_RICONS_SUPPORT) {
      if (GuiButton(leftButtonBound, GuiIconText(RICON_ARROW_LEFT_FILL, NULL))) {
         tempValue--;
      }
      if (GuiButton(rightButtonBound, GuiIconText(RICON_ARROW_RIGHT_FILL, NULL))) {
         tempValue++;
      }
   } else {
      if (GuiButton(leftButtonBound, "<")) {
         tempValue--;
      }
      if (GuiButton(rightButtonBound, ">")) {
         tempValue++;
      }
   }
   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, tempTextAlign);
   GuiSetStyle(BUTTON, BORDER_WIDTH, tempBorderWidth);
   //--------------------------------------------------------------------

   value = tempValue;
   return pressed;
}

/// Value Box control, updates input text with numbers
bool GuiValueBox(Rectangle bounds, ref int value, int minValue, int maxValue, bool editMode) {
   import std.conv : to, parse;
   import std.algorithm : clamp;

   enum VALUEBOX_MAX_CHARS = 32;
   auto text = value.to!string;
   bool pressed = GuiTextBox(bounds, text, VALUEBOX_MAX_CHARS, editMode);
   try {
      value = text.parse!int;
   } catch (Exception) {
      value = minValue;
   }
   value = value.clamp(minValue, maxValue);
   return pressed;
}

/// Text Box control, updates input text
bool GuiTextBox(Rectangle bounds, ref string text, int textSize, bool editMode) {
   static int framesCounter = 0; // Required for blinking cursor
   auto state = guiState;
   bool pressed;
   immutable borderWidth = GuiGetStyle(TEXTBOX, BORDER_WIDTH);

   // Update control
   //--------------------------------------------------------------------
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();
      if (editMode) {
         state = GUI_STATE_PRESSED;
         framesCounter++;

         immutable key = GetKeyPressed();
         int keyCount = cast(int)text.length;

         // Only allow keys in range [32..125]
         if (keyCount < (textSize - 1)) {
            immutable maxWidth = (bounds.width - (GuiGetStyle(DEFAULT, INNER_PADDING) * 2));
            if (text.GetTextWidth() < (maxWidth - GuiGetStyle(DEFAULT, TEXT_SIZE))) {
               if (((key >= 32) && (key <= 125)) || ((key >= 128) && (key < 255))) {
                  text ~= key;
                  keyCount++;
               }
            }
         }

         // Delete text
         if (keyCount > 0) {
            if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE)) {
               text.length--;
               framesCounter = 0;
            } else if (IsKeyDown(KeyboardKey.KEY_BACKSPACE)) {
               if ((framesCounter > TEXTEDIT_CURSOR_BLINK_FRAMES) && (framesCounter % 2) == 0) {
                  text.length--;
               }
            }
            import std.algorithm : clamp;

            text.length = text.length.clamp(0, textSize);
         }
      }

      if (!editMode) {
         if (CheckCollisionPointRec(mousePoint, bounds)) {
            state = GUI_STATE_FOCUSED;
            if (IsMouseButtonPressed(0)) {
               pressed = true;
            }
         }
      } else {
         if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (!CheckCollisionPointRec(mousePoint, bounds) && IsMouseButtonPressed(0))) {
            pressed = true;
         }
      }

      if (pressed) {
         framesCounter = 0;
      }
   }
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(TEXTBOX, BORDER + (state * 3))), guiAlpha));
   if (state == GUI_STATE_PRESSED) {
      DrawRectangleRec(Rectangle(bounds.x + borderWidth, bounds.y + borderWidth, bounds.width - 2 * borderWidth,
            bounds.height - 2 * borderWidth), Fade(GetColor(GuiGetStyle(TEXTBOX, BASE_COLOR_PRESSED)), guiAlpha));

      // Draw blinking cursor
      if (editMode && ((framesCounter / 20) % 2 == 0)) {
         DrawRectangleRec(Rectangle(bounds.x + GuiGetStyle(TEXTBOX,
               INNER_PADDING) + GetTextWidth(text) + 2 + bounds.width / 2 * GuiGetStyle(TEXTBOX, TEXT_ALIGNMENT),
               bounds.y + bounds.height / 2 - GuiGetStyle(DEFAULT, TEXT_SIZE), 1, GuiGetStyle(DEFAULT, TEXT_SIZE) * 2),
               Fade(GetColor(GuiGetStyle(TEXTBOX, BORDER_COLOR_PRESSED)), guiAlpha));
      }
   } else if (state == GUI_STATE_DISABLED) {
      DrawRectangleRec(Rectangle(bounds.x + borderWidth, bounds.y + borderWidth, bounds.width - 2 * borderWidth,
            bounds.height - 2 * borderWidth), Fade(GetColor(GuiGetStyle(TEXTBOX, BASE_COLOR_DISABLED)), guiAlpha));
   }

   GuiDrawText(text, GetTextBounds(TEXTBOX, bounds), GuiGetStyle(TEXTBOX, TEXT_ALIGNMENT),
         Fade(GetColor(GuiGetStyle(TEXTBOX, TEXT + (state * 3))), guiAlpha));
   //--------------------------------------------------------------------
   return pressed;
}

/// Text Box control with multiple lines
bool GuiTextBoxMulti(Rectangle bounds, ref string text, int textSize, bool editMode) {
   import std.string : lastIndexOf;
   import std.string : toStringz;
   import std.format : formattedWrite;
   import std.array : array, appender;
   import std.conv : to;

   static int framesCounter = 0; // Required for blinking cursor
   auto state = guiState;
   bool pressed = false;

   bool textHasChange = false;
   int currentLine = 0;
   immutable textBoxPadding = GuiGetStyle(TEXTBOX, INNER_PADDING);
   immutable textBoxSize = GuiGetStyle(DEFAULT, TEXT_SIZE);
   immutable textBoxBorderW = GuiGetStyle(TEXTBOX, BORDER_WIDTH);
   auto writer = appender!string;
   int newLineIndex = 0;
   auto end = textSize > text.length ? text.length : textSize;
   string newChar;
   writer.reserve(textSize + 2);
   // Update control
   //--------------------------------------------------------------------
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();

      if (editMode) {
         state = GUI_STATE_PRESSED;

         framesCounter++;

         int keyCount = cast(int)text.length;
         immutable maxWidth = (bounds.width - (textBoxPadding * 2));
         immutable maxHeight = (bounds.height - (textBoxPadding * 2));

         //numChars = TextFormat("%i/%i", keyCount, textSize - 1);

         // Only allow keys in range [32..125]
         if (keyCount < (textSize - 1)) {
            immutable key = GetKeyPressed();

            if (MeasureTextEx(guiFont, text.toStringz, textBoxSize, 1).y < (maxHeight - textBoxSize)) {
               if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
                  newChar = "\n";
                  keyCount++;
               } else if (((key >= 32) && (key <= 125)) || ((key >= 128) && (key < 255))) {
                  newChar = cast(string)[key];
                  keyCount++;
                  textHasChange = true;
               }
            } else if (GetTextWidth(text[text.lastIndexOf('\n') .. $]) < (maxWidth - textBoxSize)) {
               if (((key >= 32) && (key <= 125)) || ((key >= 128) && (key < 255))) {
                  newChar = cast(string)[key];
                  keyCount++;
                  textHasChange = true;
               }
            }
         }

         // Delete text
         if (keyCount > 0) {
            if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE)) {
               keyCount--;
               end = keyCount;
               framesCounter = 0;
               textHasChange = true;
            } else if (IsKeyDown(KeyboardKey.KEY_BACKSPACE)) {
               if ((framesCounter > TEXTEDIT_CURSOR_BLINK_FRAMES) && (framesCounter % 2) == 0) {
                  keyCount--;
               }
               end = keyCount;
               textHasChange = true;
            }
         }

         // Introduce automatic new line if necessary
         if (textHasChange) {
            textHasChange = false;
            if (text.GetTextWidth() >= maxWidth) {
               immutable lastSpace = text.lastIndexOf(" ");
               if (lastSpace != -1) {
                  newLineIndex = cast(int)(lastSpace + 1);
               } else {
                  newLineIndex = cast(int)(text.length - 1);
               }
            }
         }
         writer.formattedWrite("%s%s%s%s", text[0 .. newLineIndex], (newLineIndex > 0 ? "\n" : ""), text[newLineIndex .. end], newChar);
         text = writer.data;
         // Counting how many new lines
         foreach (c; text) {
            if (c == '\n') {
               currentLine++;
            }
         }
      }

      // Changing edit mode
      if (!editMode) {
         if (CheckCollisionPointRec(mousePoint, bounds)) {
            state = GUI_STATE_FOCUSED;
            if (IsMouseButtonPressed(0)) {
               pressed = true;
            }
         }
      } else {
         if (!CheckCollisionPointRec(mousePoint, bounds) && IsMouseButtonPressed(0)) {
            pressed = true;
         }
      }

      if (pressed) {
         framesCounter = 0;
      }
   }
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleLinesEx(bounds, textBoxBorderW, Fade(GetColor(GuiGetStyle(TEXTBOX, BORDER + (state * 3))), guiAlpha));

   if (state == GUI_STATE_PRESSED) {
      DrawRectangleRec(Rectangle(bounds.x + textBoxBorderW, bounds.y + textBoxBorderW, bounds.width - 2 * textBoxBorderW,
            bounds.height - 2 * textBoxBorderW), Fade(GetColor(GuiGetStyle(TEXTBOX, BASE_COLOR_PRESSED)), guiAlpha));

      if (editMode) {
         if ((framesCounter / 20) % 2 == 0) {
            string line;
            if (currentLine > 0) {
               line = text[text.lastIndexOf('\n') .. $];
            } else {
               line = text;
            }

            // Draw text cursor
            DrawRectangleRec(Rectangle(bounds.x + textBoxBorderW + textBoxPadding + GetTextWidth(line),
                  bounds.y + textBoxBorderW + textBoxPadding / 2 + ((GuiGetStyle(DEFAULT,
                  TEXT_SIZE) + textBoxPadding) * currentLine), 1, GuiGetStyle(DEFAULT, TEXT_SIZE) + textBoxPadding),
                  Fade(GetColor(GuiGetStyle(TEXTBOX, BORDER_COLOR_FOCUSED)), guiAlpha));
         }
      }
   } else if (state == GUI_STATE_DISABLED) {
      DrawRectangleRec(Rectangle(bounds.x + textBoxBorderW, bounds.y + textBoxBorderW, bounds.width - 2 * textBoxBorderW,
            bounds.height - 2 * textBoxBorderW), Fade(GetColor(GuiGetStyle(TEXTBOX, BASE_COLOR_DISABLED)), guiAlpha));
   }
   GuiDrawText(text, GetTextBounds(TEXTBOX, bounds), GuiGetStyle(TEXTBOX, GUI_TEXT_ALIGN_LEFT),
         Fade(GetColor(GuiGetStyle(TEXTBOX, TEXT + (state * 3))), guiAlpha));
   //--------------------------------------------------------------------

   return pressed;
}

/// Slider control with pro parameters
/// NOTE: Other GuiSlider*() controls use this one
float GuiSliderPro(Rectangle bounds, string text, float value, float minValue, float maxValue, int sliderWidth, bool showValue) {
   import std.string : fromStringz;
   import std.algorithm : clamp;

   auto state = guiState;
   immutable sliderBorderWidth = GuiGetStyle(SLIDER, BORDER_WIDTH);
   immutable sliderPadding = GuiGetStyle(SLIDER, INNER_PADDING);
   immutable sliderText = GuiGetStyle(DEFAULT, TEXT_SIZE);
   immutable sliderValue = cast(int)(((value - minValue) / (maxValue - minValue)) * (bounds.width - 2 * sliderBorderWidth));

   Rectangle slider = {
      bounds.x, bounds.y + sliderBorderWidth + sliderPadding, 0, bounds.height - 2 * sliderBorderWidth - 2 * sliderPadding
   };

   if (sliderWidth > 0) // Slider
   {
      slider.x += (sliderValue - sliderWidth / 2);
      slider.width = sliderWidth;
   } else if (sliderWidth == 0) // SliderBar
   {
      slider.x += sliderBorderWidth;
      slider.width = sliderValue;
   }

   Rectangle textBounds = {0};
   textBounds.width = GetTextWidth(text); // TODO: Consider text icon
   textBounds.height = GuiGetStyle(DEFAULT, TEXT_SIZE);
   textBounds.x = bounds.x - textBounds.width - GuiGetStyle(SLIDER, TEXT_PADDING);
   textBounds.y = bounds.y + bounds.height / 2 - GuiGetStyle(DEFAULT, TEXT_SIZE) / 2;

   // Update control
   //--------------------------------------------------------------------
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();

      if (CheckCollisionPointRec(mousePoint, bounds)) {
         if (IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
            state = GUI_STATE_PRESSED;

            // Get equivalent value and slider position from mousePoint.x
            value = ((maxValue - minValue) * (mousePoint.x - cast(float)(bounds.x + sliderWidth / 2))) / cast(float)(
                  bounds.width - sliderWidth) + minValue;

            if (sliderWidth > 0)
               slider.x = mousePoint.x - slider.width / 2; // Slider
            else if (sliderWidth == 0)
               slider.width = sliderValue; // SliderBar
         } else {
            state = GUI_STATE_FOCUSED;
         }
      }
      value = value.clamp(minValue, maxValue);
   }

   // Bar limits check
   if (sliderWidth > 0) // Slider
   {
      if (slider.x <= (bounds.x + sliderBorderWidth))
         slider.x = bounds.x + sliderBorderWidth;
      else if ((slider.x + slider.width) >= (bounds.x + bounds.width))
         slider.x = bounds.x + bounds.width - slider.width - sliderBorderWidth;
   } else if (sliderWidth == 0) // SliderBar
   {
      if (slider.width > bounds.width)
         slider.width = bounds.width - 2 * sliderBorderWidth;
   }
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleLinesEx(bounds, sliderBorderWidth, Fade(GetColor(GuiGetStyle(SLIDER, BORDER + (state * 3))), guiAlpha));
   DrawRectangleRec(Rectangle(bounds.x + sliderBorderWidth, bounds.y + sliderBorderWidth,
         bounds.width - 2 * sliderBorderWidth, bounds.height - 2 * sliderBorderWidth), Fade(GetColor(GuiGetStyle(SLIDER,
         (state != GUI_STATE_DISABLED) ? BASE_COLOR_NORMAL : BASE_COLOR_DISABLED)), guiAlpha));

   // Draw slider internal bar (depends on state)
   if ((state == GUI_STATE_NORMAL) || (state == GUI_STATE_PRESSED))
      DrawRectangleRec(slider, Fade(GetColor(GuiGetStyle(SLIDER, BASE_COLOR_PRESSED)), guiAlpha));
   else if (state == GUI_STATE_FOCUSED)
      DrawRectangleRec(slider, Fade(GetColor(GuiGetStyle(SLIDER, TEXT_COLOR_FOCUSED)), guiAlpha));

   GuiDrawText(text, textBounds, GuiGetStyle(SLIDER, TEXT_ALIGNMENT), Fade(GetColor(GuiGetStyle(SLIDER, TEXT + (state * 3))), guiAlpha));

   // TODO: Review showValue parameter, really ugly...
   if (showValue)
      GuiDrawText(cast(string)TextFormat("%.02f", value).fromStringz,
            Rectangle(bounds.x + bounds.width + GuiGetStyle(SLIDER, TEXT_PADDING),
               bounds.y + bounds.height / 2 - sliderText / 2 + sliderPadding, sliderText, sliderText),
            GUI_TEXT_ALIGN_LEFT, Fade(GetColor(GuiGetStyle(SLIDER, TEXT + (state * 3))), guiAlpha));
   //--------------------------------------------------------------------

   return value;
}

/// Slider control extended, returns selected value and has text
float GuiSlider(Rectangle bounds, string text, float value, float minValue, float maxValue, bool showValue) {
   return GuiSliderPro(bounds, text, value, minValue, maxValue, GuiGetStyle(SLIDER, SLIDER_WIDTH), showValue);
}

/// Slider Bar control extended, returns selected value
float GuiSliderBar(Rectangle bounds, string text, float value, float minValue, float maxValue, bool showValue) {
   return GuiSliderPro(bounds, text, value, minValue, maxValue, 0, showValue);
}

/// Progress Bar control extended, shows current progress value
float GuiProgressBar(Rectangle bounds, string text, float value, float minValue, float maxValue, bool showValue) {
   import std.string : fromStringz;

   auto state = guiState;
   immutable borderWidth = GuiGetStyle(PROGRESSBAR, BORDER_WIDTH);
   immutable progressPadding = GuiGetStyle(PROGRESSBAR, INNER_PADDING);
   Rectangle progress = {
      bounds.x + borderWidth, bounds.y + borderWidth + progressPadding, 0, bounds.height - 2 * borderWidth - 2 * progressPadding
   };

   // Update control
   //--------------------------------------------------------------------
   if (state != GUI_STATE_DISABLED)
      progress.width = cast(int)(value / (maxValue - minValue) * cast(float)(bounds.width - 2 * borderWidth));
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   if (showValue)
      GuiLabel(Rectangle(bounds.x + bounds.width + GuiGetStyle(SLIDER, TEXT_PADDING),
            bounds.y + bounds.height / 2 - GuiGetStyle(DEFAULT, TEXT_SIZE) / 2 + GuiGetStyle(SLIDER, INNER_PADDING),
            GuiGetStyle(DEFAULT, TEXT_SIZE), GuiGetStyle(DEFAULT, TEXT_SIZE)), cast(string)TextFormat("%.02f", value).fromStringz);

   DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(PROGRESSBAR, BORDER + (state * 3))), guiAlpha));

   // Draw slider internal progress bar (depends on state)
   if ((state == GUI_STATE_NORMAL) || (state == GUI_STATE_PRESSED))
      DrawRectangleRec(progress, Fade(GetColor(GuiGetStyle(PROGRESSBAR, BASE_COLOR_PRESSED)), guiAlpha));
   else if (state == GUI_STATE_FOCUSED)
      DrawRectangleRec(progress, Fade(GetColor(GuiGetStyle(PROGRESSBAR, TEXT_COLOR_FOCUSED)), guiAlpha));
   //--------------------------------------------------------------------

   return value;
}

// Status Bar control
void GuiStatusBar(Rectangle bounds, string text) {
   auto state = guiState;

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleLinesEx(bounds, GuiGetStyle(DEFAULT, BORDER_WIDTH), Fade(GetColor(GuiGetStyle(DEFAULT,
         (state != GUI_STATE_DISABLED) ? BORDER_COLOR_NORMAL : BORDER_COLOR_DISABLED)), guiAlpha));
   DrawRectangleRec(Rectangle(bounds.x + GuiGetStyle(DEFAULT, BORDER_WIDTH), bounds.y + GuiGetStyle(DEFAULT,
         BORDER_WIDTH), bounds.width - GuiGetStyle(DEFAULT, BORDER_WIDTH) * 2, bounds.height - GuiGetStyle(DEFAULT, BORDER_WIDTH) * 2),
         Fade(GetColor(GuiGetStyle(DEFAULT, (state != GUI_STATE_DISABLED) ? BASE_COLOR_NORMAL : BASE_COLOR_DISABLED)), guiAlpha));
   GuiDrawText(text, GetTextBounds(DEFAULT, bounds), GuiGetStyle(DEFAULT, TEXT_ALIGNMENT),
         Fade(GetColor(GuiGetStyle(DEFAULT, (state != GUI_STATE_DISABLED) ? TEXT_COLOR_NORMAL : TEXT_COLOR_DISABLED)), guiAlpha));
   //--------------------------------------------------------------------
}

/// Dummy rectangle control, intended for placeholding
void GuiDummyRec(Rectangle bounds, string text) {
   auto state = guiState;
   // Update control
   //--------------------------------------------------------------------
   bounds.LeftClicked(state);
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleRec(bounds, Fade(GetColor(GuiGetStyle(DEFAULT, (state != GUI_STATE_DISABLED) ? BASE_COLOR_NORMAL
         : BASE_COLOR_DISABLED)), guiAlpha));
   GuiDrawText(text, GetTextBounds(DEFAULT, bounds), GUI_TEXT_ALIGN_CENTER, Fade(GetColor(GuiGetStyle(BUTTON,
         (state != GUI_STATE_DISABLED) ? TEXT_COLOR_NORMAL : TEXT_COLOR_DISABLED)), guiAlpha));
}

/// Scroll Bar control
int GuiScrollBar(Rectangle bounds, int value, int minValue, int maxValue) {
   import std.algorithm : clamp;

   auto state = guiState;
   immutable scrollBarWidth = GuiGetStyle(SCROLLBAR, BORDER_WIDTH);
   immutable scrollBarPadding = GuiGetStyle(SCROLLBAR, INNER_PADDING);
   immutable sliderPadding = GuiGetStyle(SCROLLBAR, SLIDER_PADDING);
   float sliderSize = GuiGetStyle(SCROLLBAR, SLIDER_SIZE);

   // Is the scrollbar horizontal or vertical?
   immutable isVertical = (bounds.width > bounds.height) ? false : true;

   // The size (width or height depending on scrollbar type) of the spinner buttons
   immutable spinnerSize = GuiGetStyle(SCROLLBAR, SHOW_SPINNER_BUTTONS) ? (isVertical ? bounds.width - 2 * scrollBarWidth
         : bounds.height - 2 * scrollBarWidth) : 0;

   // Spinner buttons [<] [>] [∧] [∨]
   Rectangle spinnerUpLeft, spinnerDownRight;
   // Actual area of the scrollbar excluding the spinner buttons
   Rectangle scrollbar; //  ------------
   // Slider bar that moves     --[///]-----
   Rectangle slider;

   // Normalize value
   value = value.clamp(minValue, maxValue);

   immutable range = maxValue - minValue;
   // Calculate rectangles for all of the components
   spinnerUpLeft = Rectangle(bounds.x + scrollBarWidth, bounds.y + scrollBarWidth, spinnerSize, spinnerSize);

   if (isVertical) {
      spinnerDownRight = Rectangle(bounds.x + scrollBarWidth, bounds.y + bounds.height - spinnerSize - scrollBarWidth,
            spinnerSize, spinnerSize);
      scrollbar = Rectangle((bounds.x + scrollBarWidth + scrollBarPadding), spinnerUpLeft.y + spinnerUpLeft.height,
            bounds.width - 2 * (scrollBarWidth + scrollBarPadding),
            bounds.height - spinnerUpLeft.height - spinnerDownRight.height - 2 * scrollBarWidth);
      sliderSize = (sliderSize >= scrollbar.height) ? (scrollbar.height - 2) : sliderSize; // Make sure the slider won't get outside of the scrollbar
      slider = Rectangle(bounds.x + scrollBarWidth + sliderPadding,
            scrollbar.y + cast(int)((cast(float)(value - minValue) / range) * (scrollbar.height - sliderSize)),
            bounds.width - 2 * (scrollBarWidth + sliderPadding), sliderSize);
   } else {
      spinnerDownRight = Rectangle(bounds.x + bounds.width - spinnerSize - scrollBarWidth, bounds.y + scrollBarWidth,
            spinnerSize, spinnerSize);
      scrollbar = Rectangle(spinnerUpLeft.x + spinnerUpLeft.width, bounds.y + scrollBarWidth + scrollBarPadding,
            bounds.width - spinnerUpLeft.width - spinnerDownRight.width - 2 * scrollBarWidth,
            bounds.height - 2 * (scrollBarWidth + scrollBarPadding));
      sliderSize = (sliderSize >= scrollbar.width) ? (scrollbar.width - 2) : sliderSize; // Make sure the slider won't get outside of the scrollbar
      slider = Rectangle(scrollbar.x + cast(int)((cast(float)(value - minValue) / range) * (scrollbar.width - sliderSize)),
            bounds.y + scrollBarWidth + sliderPadding, sliderSize, bounds.height - 2 * (scrollBarWidth + sliderPadding));
   }

   // Update control
   //--------------------------------------------------------------------
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();

      if (CheckCollisionPointRec(mousePoint, bounds)) {
         state = GUI_STATE_FOCUSED;

         // Handle mouse wheel
         immutable wheel = GetMouseWheelMove();
         if (wheel != 0)
            value += wheel;

         if (IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON)) {
            if (CheckCollisionPointRec(mousePoint, spinnerUpLeft))
               value -= range / GuiGetStyle(SCROLLBAR, SCROLL_SPEED);
            else if (CheckCollisionPointRec(mousePoint, spinnerDownRight))
               value += range / GuiGetStyle(SCROLLBAR, SCROLL_SPEED);

            state = GUI_STATE_PRESSED;
         } else if (IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
            if (!isVertical) {
               Rectangle scrollArea = {
                  spinnerUpLeft.x + spinnerUpLeft.width, spinnerUpLeft.y, scrollbar.width, bounds.height - 2 * scrollBarWidth
               };
               if (CheckCollisionPointRec(mousePoint, scrollArea))
                  value = cast(int)((cast(float)(mousePoint.x - scrollArea.x - slider.width / 2) * range) / (scrollArea.width - slider
                        .width) + minValue);
            } else {
               Rectangle scrollArea = {
                  spinnerUpLeft.x, spinnerUpLeft.y + spinnerUpLeft.height, bounds.width - 2 * scrollBarWidth, scrollbar.height
               };
               if (CheckCollisionPointRec(mousePoint, scrollArea))
                  value = cast(int)((cast(float)(mousePoint.y - scrollArea.y - slider.height / 2) * range) / (
                        scrollArea.height - slider.height) + minValue);
            }
         }
      }

      // Normalize value
      value = value.clamp(minValue, maxValue);
   }
   //--------------------------------------------------------------------

   // Draw control
   //--------------------------------------------------------------------
   DrawRectangleRec(bounds, Fade(GetColor(GuiGetStyle(DEFAULT, BORDER_COLOR_DISABLED)), guiAlpha)); // Draw the background
   DrawRectangleRec(scrollbar, Fade(GetColor(GuiGetStyle(BUTTON, BASE_COLOR_NORMAL)), guiAlpha)); // Draw the scrollbar active area background

   DrawRectangleLinesEx(bounds, scrollBarWidth, Fade(GetColor(GuiGetStyle(LISTVIEW, BORDER + state * 3)), guiAlpha));

   DrawRectangleRec(slider, Fade(GetColor(GuiGetStyle(SLIDER, BORDER + state * 3)), guiAlpha)); // Draw the slider bar

   // Draw arrows using lines
   immutable padding = (spinnerSize - GuiGetStyle(SCROLLBAR, ARROWS_SIZE)) / 2;
   const Vector2[] lineCoords = [ //coordinates for <     0,1,2
   {spinnerUpLeft.x + padding, spinnerUpLeft.y + spinnerSize / 2}, {
      spinnerUpLeft.x + spinnerSize - padding, spinnerUpLeft.y + padding
   }, {
      spinnerUpLeft.x + spinnerSize - padding, spinnerUpLeft.y + spinnerSize - padding
   }, //coordinates for >     3,4,5
   {spinnerDownRight.x + padding, spinnerDownRight.y + padding}, {
      spinnerDownRight.x + spinnerSize - padding, spinnerDownRight.y + spinnerSize / 2
   }, {
      spinnerDownRight.x + padding, spinnerDownRight.y + spinnerSize - padding
   }, //coordinates for ∧     6,7,8
   {spinnerUpLeft.x + spinnerSize / 2, spinnerUpLeft.y + padding}, {
      spinnerUpLeft.x + padding, spinnerUpLeft.y + spinnerSize - padding
   }, {
      spinnerUpLeft.x + spinnerSize - padding, spinnerUpLeft.y + spinnerSize - padding
   }, //coordinates for ∨     9,10,11
   {spinnerDownRight.x + padding, spinnerDownRight.y + padding}, {
      spinnerDownRight.x + spinnerSize / 2, spinnerDownRight.y + spinnerSize - padding
   }, {
      spinnerDownRight.x + spinnerSize - padding, spinnerDownRight.y + padding
   }];

   Color lineColor = Fade(GetColor(GuiGetStyle(BUTTON, TEXT + state * 3)), guiAlpha);

   if (GuiGetStyle(SCROLLBAR, SHOW_SPINNER_BUTTONS)) {
      if (isVertical) {
         // Draw ∧
         DrawLineEx(lineCoords[6], lineCoords[7], 3.0f, lineColor);
         DrawLineEx(lineCoords[6], lineCoords[8], 3.0f, lineColor);

         // Draw ∨
         DrawLineEx(lineCoords[9], lineCoords[10], 3.0f, lineColor);
         DrawLineEx(lineCoords[11], lineCoords[10], 3.0f, lineColor);
      } else {
         // Draw <
         DrawLineEx(lineCoords[0], lineCoords[1], 3.0f, lineColor);
         DrawLineEx(lineCoords[0], lineCoords[2], 3.0f, lineColor);

         // Draw >
         DrawLineEx(lineCoords[3], lineCoords[4], 3.0f, lineColor);
         DrawLineEx(lineCoords[5], lineCoords[4], 3.0f, lineColor);
      }
   }
   //--------------------------------------------------------------------

   return value;
}

/// List Element control, returns element state
bool GuiListElement(Rectangle bounds, string text, bool active, bool editMode) {
   auto state = guiState;
   if (!guiLocked && editMode)
      state = GUI_STATE_NORMAL;

   // Update control
   //--------------------------------------------------------------------
   if (bounds.LeftClicked(state)) {
      active = !active;
   }
   //--------------------------------------------------------------------

   // Internal drawing function.
   void drawElement(in GuiControlProperty list, in GuiControlProperty border) {
      immutable viewColour = GuiGetStyle(LISTVIEW, list).GetColor.Fade(guiAlpha);
      immutable borderColour = GuiGetStyle(LISTVIEW, border).GetColor.Fade(guiAlpha);
      DrawRectangleRec(bounds, viewColour);
      DrawRectangleLinesEx(bounds, GuiGetStyle(DEFAULT, BORDER_WIDTH), borderColour);
   }

   // Draw control
   //--------------------------------------------------------------------
   // Draw element rectangle
   switch (state) {
      case GUI_STATE_NORMAL:
         if (active) {
            drawElement(GuiControlProperty.BASE_COLOR_PRESSED, GuiControlProperty.BORDER_COLOR_PRESSED);
         }
         break;
      case GUI_STATE_FOCUSED:
         drawElement(GuiControlProperty.BASE_COLOR_FOCUSED, GuiControlProperty.BORDER_COLOR_FOCUSED);
         break;
      case GUI_STATE_PRESSED:
         drawElement(GuiControlProperty.BASE_COLOR_PRESSED, GuiControlProperty.BORDER_COLOR_PRESSED);
         break;
      case GUI_STATE_DISABLED:
         if (active) {
            drawElement(GuiControlProperty.BASE_COLOR_DISABLED, GuiControlProperty.BORDER_COLOR_NORMAL);
         }
         break;
      default:
         break;
   }
   immutable textBounds = GetTextBounds(DEFAULT, bounds);
   immutable textAlignment = GuiGetStyle(DEFAULT, TEXT_ALIGNMENT);
   // Draw text depending on state
   if (state == GUI_STATE_NORMAL) {
      GuiDrawText(text, textBounds, textAlignment, Fade(GetColor(GuiGetStyle(LISTVIEW, active ? TEXT_COLOR_PRESSED
            : TEXT_COLOR_NORMAL)), guiAlpha));
   } else if (state == GUI_STATE_DISABLED) {
      GuiDrawText(text, textBounds, textAlignment, Fade(GetColor(GuiGetStyle(LISTVIEW, active ? TEXT_COLOR_NORMAL
            : TEXT_COLOR_DISABLED)), guiAlpha));
   } else {
      GuiDrawText(text, textBounds, textAlignment, Fade(GetColor(GuiGetStyle(LISTVIEW, TEXT + state * 3)), guiAlpha));
   }
   //--------------------------------------------------------------------

   return active;
}

/// List View control
bool GuiListView(Rectangle bounds, string text, ref int active, ref int scrollIndex, bool editMode) {
   auto list = text.GuiTextSplit();
   int enabled;
   int focus;
   return GuiListViewEx(bounds, list, cast(int)list.length, enabled, active, focus, scrollIndex, editMode);
}

/// List View control extended parameters
/// NOTE: Elements could be disabled individually and focused element could be obtained:
///  int *enabled defines an array with enabled elements inside the list
///  int *focus returns focused element (may be not pressed)
bool GuiListViewEx(Rectangle bounds, string[] text, int count, ref int enabled, ref int active, ref int focus,
      ref int scrollIndex, bool editMode) {
   //FIXME: Seems to rely on null being a valid value for enabled and focus.
   import std.algorithm : clamp;

   auto state = guiState;
   bool pressed;
   int focusElement = -1;
   int startIndex = scrollIndex;
   bool useScrollBar = true;
   bool pressedKey;
   immutable elementsPadding = GuiGetStyle(LISTVIEW, ELEMENTS_PADDING);
   immutable elementsHeight = GuiGetStyle(LISTVIEW, ELEMENTS_HEIGHT);
   immutable scrollBarWidth = GuiGetStyle(LISTVIEW, SCROLLBAR_WIDTH);
   immutable borderWidth = GuiGetStyle(DEFAULT, BORDER_WIDTH);
   auto visibleElements = cast(int)(bounds.height / (elementsHeight + elementsPadding));
   startIndex = startIndex.clamp(0, count - visibleElements);
   int endIndex = startIndex + visibleElements;

   int auxActive = active;

   float barHeight = bounds.height;
   immutable minBarHeight = 10.0f;

   // Update control
   //--------------------------------------------------------------------
   // All the elements fit inside ListView and dont need scrollbar.
   if (visibleElements >= count) {
      useScrollBar = false;
      startIndex = 0;
      endIndex = count;
   }

   // Calculate position X and width to draw each element.
   auto posX = bounds.x + elementsPadding;
   auto elementWidth = bounds.width - 2 * elementsPadding - borderWidth;

   if (useScrollBar) {
      posX = GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_LEFT_SIDE ? posX + scrollBarWidth : posX;
      elementWidth = bounds.width - scrollBarWidth - 2 * elementsPadding - borderWidth;
   }

   Rectangle scrollBarRect = {
      bounds.x + borderWidth, bounds.y + borderWidth, scrollBarWidth, bounds.height - 2 * borderWidth
   };

   if (GuiGetStyle(LISTVIEW, SCROLLBAR_SIDE) == SCROLLBAR_RIGHT_SIDE)
      scrollBarRect.x = posX + elementWidth + elementsPadding;

   // Area without the scrollbar
   Rectangle viewArea = {posX, bounds.y + borderWidth, elementWidth, bounds.height - 2 * borderWidth};

   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      auto mousePoint = GetMousePosition();

      if (editMode) {
         state = GUI_STATE_PRESSED;
         // Change active with keys
         if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            if (auxActive > 0) {
               auxActive--;
               if ((useScrollBar) && (auxActive < startIndex)) {
                  startIndex--;
               }
            }
            pressedKey = true;
         } else if (IsKeyPressed(KeyboardKey.KEY_DOWN)) {
            if (auxActive < count - 1) {
               auxActive++;
               if ((useScrollBar) && (auxActive >= endIndex)) {
                  startIndex++;
               }
            }

            pressedKey = true;
         }

         if (useScrollBar) {
            endIndex = startIndex + visibleElements;
            if (CheckCollisionPointRec(mousePoint, viewArea)) {
               immutable wheel = GetMouseWheelMove();
               if (wheel < 0 && endIndex < count) {
                  startIndex -= wheel;
               } else if (wheel > 0 && startIndex > 0) {
                  startIndex -= wheel;
               }
            }

            if (pressedKey) {
               pressedKey = false;
               if ((auxActive < startIndex) || (auxActive >= endIndex)) {
                  startIndex = auxActive;
               }
            }

            if (startIndex < 0) {
               startIndex = 0;
            } else if (startIndex > (count - (endIndex - startIndex))) {
               startIndex = count - (endIndex - startIndex);
            }

            endIndex = startIndex + visibleElements;

            if (endIndex > count) {
               endIndex = count;
            }
         }
      }

      if (!editMode) {
         if (CheckCollisionPointRec(mousePoint, viewArea)) {
            state = GUI_STATE_FOCUSED;
            if (IsMouseButtonPressed(0)) {
               pressed = true;
            }

            startIndex -= GetMouseWheelMove();

            if (startIndex < 0) {
               startIndex = 0;
            } else if (startIndex > (count - (endIndex - startIndex))) {
               startIndex = count - (endIndex - startIndex);
            }

            pressed = true;
         }
      } else {
         if (!CheckCollisionPointRec(mousePoint, viewArea)) {
            if (IsMouseButtonPressed(0) || (GetMouseWheelMove() != 0)) {
               pressed = true;
            }
         }
      }

      // Get focused element
      foreach (i; startIndex .. endIndex) {
         if (CheckCollisionPointRec(mousePoint, Rectangle(posX,
               bounds.y + elementsPadding + borderWidth + (i - startIndex) * (elementsHeight + elementsPadding),
               elementWidth, elementsHeight))) {
            focusElement = i;
         }
      }
   }

   immutable slider = GuiGetStyle(SCROLLBAR, SLIDER_SIZE); // Save default slider size

   // Calculate percentage of visible elements and apply same percentage to scrollbar
   if (useScrollBar) {
      immutable percentVisible = (endIndex - startIndex) * 100.0f / count;
      barHeight *= percentVisible / 100;
      barHeight = barHeight.clamp(minBarHeight, bounds.height);

      GuiSetStyle(SCROLLBAR, SLIDER_SIZE, cast(int)barHeight); // Change slider size
   }

   // Draw control
   DrawRectangleRec(bounds, GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR))); // Draw background

   // Draw scrollBar
   if (useScrollBar) {
      immutable scrollSpeed = GuiGetStyle(SCROLLBAR, SCROLL_SPEED); // Save default scroll speed
      GuiSetStyle(SCROLLBAR, SCROLL_SPEED, count - visibleElements); // Hack to make the spinner buttons work

      int index = scrollIndex != 0 ? scrollIndex : startIndex;
      index = GuiScrollBar(scrollBarRect, index, 0, count - visibleElements);

      GuiSetStyle(SCROLLBAR, SCROLL_SPEED, scrollSpeed); // Reset scroll speed to default
      GuiSetStyle(SCROLLBAR, SLIDER_SIZE, slider); // Reset slider size to default

      // FIXME: Quick hack to make this thing work, think of a better way
      if (CheckCollisionPointRec(GetMousePosition(), scrollBarRect) && IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
         startIndex = index;
         startIndex = startIndex.clamp(0, (count - (endIndex - startIndex)));
         endIndex = startIndex + visibleElements;
         if (endIndex > count) {
            endIndex = count;
         }
      }
   }

   Rectangle elementRect(int i) {
      //FIXME: elementWidth-1 is a temporary fix.  Must be a rounding error from truncation.
      return Rectangle(posX, bounds.y + elementsPadding + borderWidth + (i - startIndex) * (elementsHeight + elementsPadding),
            elementWidth - 1, elementsHeight);
   }

   DrawRectangleLinesEx(bounds, borderWidth, Fade(GetColor(GuiGetStyle(LISTVIEW, BORDER + state * 3)), guiAlpha));

   // Draw ListView states
   switch (state) {
      case GUI_STATE_NORMAL:
         foreach (i; startIndex .. endIndex) {
            if (enabled == 0) {
               GuiDisable();
               GuiListElement(elementRect(i), text[i], false, false);
               GuiEnable();
            } else if (i == auxActive) {
               GuiDisable();
               GuiListElement(elementRect(i), text[i], true, false);
               GuiEnable();
            } else
               GuiListElement(elementRect(i), text[i], false, false);
         }
         break;
      case GUI_STATE_FOCUSED:
         foreach (i; startIndex .. endIndex) {
            if (enabled == 0) {
               GuiDisable();
               GuiListElement(elementRect(i), text[i], false, false);
               GuiEnable();
            } else if (i == auxActive) {
               GuiListElement(elementRect(i), text[i], true, false);
            } else {
               GuiListElement(elementRect(i), text[i], false, false);
            }
         }
         break;
      case GUI_STATE_PRESSED:
         foreach (i; startIndex .. endIndex) {
            if (enabled == 0) {
               GuiDisable();
               GuiListElement(elementRect(i), text[i], false, false);
               GuiEnable();
            } else if ((i == auxActive) && editMode) {
               if (GuiListElement(elementRect(i), text[i], true, true) == false)
                  auxActive = -1;
            } else {
               if (GuiListElement(elementRect(i), text[i], false, true) == true)
                  auxActive = i;
            }
         }
         break;
      case GUI_STATE_DISABLED:
         foreach (i; startIndex .. endIndex) {
            if (i == auxActive)
               GuiListElement(elementRect(i), text[i], true, false);
            else
               GuiListElement(elementRect(i), text[i], false, false);
         }
         break;
      default:
         break;
   }
   //--------------------------------------------------------------------

   //FIXME: Null stuff?
   scrollIndex = startIndex;
   focus = focusElement;
   active = auxActive;

   return pressed;
}

// Color Panel control

// HSV: Saturation
// HSV: Value

// Update control
//--------------------------------------------------------------------

// Calculate color from picker

// Get normalized value on x
// Get normalized value on y

// NOTE: Vector3ToColor() only available on raylib 1.8.1

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw color picker: selector

//--------------------------------------------------------------------
Color GuiColorPanel(Rectangle bounds, Color color);

// Color Bar Alpha control
// NOTE: Returns alpha value normalized [0..1]

// Update control
//--------------------------------------------------------------------

//selector.x = bounds.x + (int)(((alpha - 0)/(100 - 0))*(bounds.width - 2*GuiGetStyle(SLIDER, BORDER_WIDTH))) - selector.width/2;

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------
// Draw alpha bar: checked background

//--------------------------------------------------------------------
float GuiColorBarAlpha(Rectangle bounds, float alpha) {
   // FIX:
   return 0;
}

enum COLORBARALPHA_CHECKED_SIZE = 10;

// Color Bar Hue control
// NOTE: Returns hue value normalized [0..1]

// Update control
//--------------------------------------------------------------------

/*if (IsKeyDown(KeyboardKey.KEY_UP))
  {
  hue -= 2.0f;
  if (hue <= 0.0f) hue = 0.0f;
  }
  else if (IsKeyDown(KeyboardKey.KEY_DOWN))
  {
  hue += 2.0f;
  if (hue >= 360.0f) hue = 360.0f;
  }*/

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw hue bar:color bars

// Draw hue bar: selector

//--------------------------------------------------------------------
float GuiColorBarHue(Rectangle bounds, float hue) {
   // FIX:
   return 0;
}

// TODO: Color GuiColorBarSat() [WHITE->color]
// TODO: Color GuiColorBarValue() [BLACK->color], HSV / HSL
// TODO: float GuiColorBarLuminance() [BLACK->WHITE]

// Color Picker control
// NOTE: It's divided in multiple controls:
//      Color GuiColorPanel() - Color select panel
//      float GuiColorBarAlpha(Rectangle bounds, float alpha)
//      float GuiColorBarHue(Rectangle bounds, float value)
// NOTE: bounds define GuiColorPanel() size

//Rectangle boundsAlpha = { bounds.x, bounds.y + bounds.height + GuiGetStyle(COLORPICKER, BARS_PADDING), bounds.width, GuiGetStyle(COLORPICKER, BARS_THICK) };

//color.a = (unsigned char)(GuiColorBarAlpha(boundsAlpha, (float)color.a/255.0f)*255.0f);
Color GuiColorPicker(Rectangle bounds, Color color) {
   // FIX:
   return WHITE;
}

/// Message Box control
int GuiMessageBox(Rectangle bounds, string windowTitle, string message, string buttons) {
   import std.string : toStringz;

   enum MESSAGEBOX_BUTTON_HEIGHT = 24;
   enum MESSAGEBOX_BUTTON_PADDING = 10;
   enum WINDOW_STATUSBAR_HEIGHT = 24;
   int clicked = -1; // Returns clicked button from buttons list, 0 refers to closed window button
   const buttonsText = buttons.GuiTextSplit();
   immutable(int) buttonsCount = cast(int)buttonsText.length;

   immutable textSize = MeasureTextEx(guiFont, message.toStringz, GuiGetStyle(DEFAULT, TEXT_SIZE), 1);

   Rectangle textBounds = {
      bounds.x + bounds.width / 2 - textSize.x / 2,
         bounds.y + WINDOW_STATUSBAR_HEIGHT + (bounds.height - WINDOW_STATUSBAR_HEIGHT) / 4 - textSize.y / 2, textSize.x, textSize.y
   };

   Rectangle buttonBounds = {
      bounds.x + MESSAGEBOX_BUTTON_PADDING, bounds.y + bounds.height / 2 + bounds.height / 4 - MESSAGEBOX_BUTTON_HEIGHT / 2,
         (bounds.width - MESSAGEBOX_BUTTON_PADDING * (buttonsCount + 1)) / buttonsCount, MESSAGEBOX_BUTTON_HEIGHT
   };

   // Draw control
   if (GuiWindowBox(bounds, windowTitle)) {
      clicked = 0;
   }

   int prevTextAlignment = GuiGetStyle(LABEL, TEXT_ALIGNMENT);
   GuiSetStyle(LABEL, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);
   GuiLabel(textBounds, message);
   GuiSetStyle(LABEL, TEXT_ALIGNMENT, prevTextAlignment);

   prevTextAlignment = GuiGetStyle(BUTTON, TEXT_ALIGNMENT);
   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);

   foreach (int i; 0 .. buttonsCount) {
      if (GuiButton(buttonBounds, buttonsText[i])) {
         clicked = i + 1;
      }
      buttonBounds.x += (buttonBounds.width + MESSAGEBOX_BUTTON_PADDING);
   }

   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, prevTextAlignment);
   //--------------------------------------------------------------------

   return clicked;
}

/// Text Input Box control, ask for text
int GuiTextInputBox(Rectangle bounds, string windowTitle, string message, string text, string buttons) {
   int btnIndex = -1;
   //TODO
   return btnIndex;
}

/// Grid control
/// NOTE: Returns grid mouse-hover selected cell
/// About drawing lines at subpixel spacing, simple put, not easy solution:
/// https://stackoverflow.com/questions/4435450/2d-opengl-drawing-lines-that-dont-exactly-fit-pixel-raster
Vector2 GuiGrid(Rectangle bounds, float spacing, int subdivs) {
   enum GRID_COLOR_ALPHA = 0.15f;
   auto state = guiState;
   auto mousePoint = GetMousePosition();
   Vector2 currentCell = {-1, -1};

   int linesV = (cast(int)(bounds.width / spacing) + 1) * subdivs;
   int linesH = (cast(int)(bounds.height / spacing) + 1) * subdivs;

   // Update control
   if ((state != GUI_STATE_DISABLED) && !guiLocked) {
      if (CheckCollisionPointRec(mousePoint, bounds)) {
         currentCell.x = cast(int)((mousePoint.x - bounds.x) / spacing);
         currentCell.y = cast(int)((mousePoint.y - bounds.y) / spacing);
      }
   }

   // Draw control
   switch (state) {
      case GUI_STATE_NORMAL:
         // Draw vertical grid lines
         foreach (i; 0 .. linesV) {
            DrawRectangleRec(Rectangle(bounds.x + spacing * i, bounds.y, 1, bounds.height), ((i % subdivs) == 0)
                  ? Fade(GetColor(GuiGetStyle(DEFAULT, LINE_COLOR)), GRID_COLOR_ALPHA * 4)
                  : Fade(GetColor(GuiGetStyle(DEFAULT, LINE_COLOR)), GRID_COLOR_ALPHA));
         }

         // Draw horizontal grid lines
         foreach (i; 0 .. linesH) {
            DrawRectangleRec(Rectangle(bounds.x, bounds.y + spacing * i, bounds.width, 1), ((i % subdivs) == 0)
                  ? Fade(GetColor(GuiGetStyle(DEFAULT, LINE_COLOR)), GRID_COLOR_ALPHA * 4)
                  : Fade(GetColor(GuiGetStyle(DEFAULT, LINE_COLOR)), GRID_COLOR_ALPHA));
         }

         break;
      default:
         break;
   }

   return currentCell;
}

//----------------------------------------------------------------------------------
// Styles loading functions
//----------------------------------------------------------------------------------

/// Load raygui style file (.rgs)
/// TEXT ONLY FOR NOW.
void GuiLoadStyle(string fileName) {
   import std.regex : matchFirst, ctRegex;
   import std.typecons : Tuple;
   import std.conv : to;
   import std.stdio : File;
   import std.string : toStringz;

   alias Style = Tuple!(string, "type", int, "control", int, "property", string, "value");
   auto controlRegex = ctRegex!(`^(?P<type>p) (?P<control>\d+) (?P<property>\d+) \b0x(?P<value>[0-9a-fA-F]{8})\b`);
   auto fontRegex = ctRegex!(`^(?P<type>f) (?P<control>\d+) (?P<property>\d+) (?P<value>.+(.ttf|.otf))`);
   File styles;
   try {
      styles = File(fileName, "rt");
      foreach (style; styles.byLine) {
         auto match = style.matchFirst(controlRegex);
         if (match.empty) {
            match = style.matchFirst(fontRegex);
         }
         if (!match.empty) {
            immutable s = Style(match["type"].to!string, match["control"].to!int, match["property"].to!int, match["value"].to!string);
            switch (s.type) {
               case "p":
                  int colour = s.value.to!uint(16);
                  if (s.control == 0) {
                     // If a DEFAULT property is loaded, it is propagated to all controls,
                     // NOTE: All DEFAULT properties should be defined first in the file
                     GuiSetStyle(0, s.property, colour);
                     if (s.property < NUM_PROPS_DEFAULT) {
                        foreach (i; 1 .. NUM_CONTROLS)
                           GuiSetStyle(i, s.property, colour);
                     }
                  } else {
                     GuiSetStyle(s.control, s.property, colour);
                  }
                  break;
               case "f":
                  auto fontFileName = s.value.toStringz;
                  Font font = "%s/%s".toStringz.TextFormat(fileName.toStringz.GetDirectoryPath(), fontFileName)
                     .LoadFontEx(s.control, null, s.property);
                  if ((font.texture.id > 0) && (font.charsCount > 0)) {
                     GuiFont(font);
                     GuiSetStyle(DEFAULT, TEXT_SIZE, s.control);
                     GuiSetStyle(DEFAULT, TEXT_SPACING, s.property);
                  }
                  break;
               default:
                  break;
            }
         }
      }
   }  //Catch any exception.  Could tighten this up.
   catch (Exception) {
   }
   scope (exit) {
      styles.close();
   }
}

/// Load style from a palette values array
void GuiLoadStyleProps(in int[] props, int count) {
   int completeSets = count / (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED);
   int uncompleteSetProps = count % (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED);

   // Load style palette values from array (complete property sets)
   foreach (i; 0 .. completeSets) {
      // TODO: This code needs review
      foreach (j; 0 .. (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED)) {
         GuiSetStyle(i, j, props[i]);
      }
   }

   // Load style palette values from array (uncomplete property set)
   foreach (k; 0 .. uncompleteSetProps) {
      GuiSetStyle(completeSets, k, props[completeSets * (NUM_PROPS_DEFAULT + NUM_PROPS_EXTENDED) + k]);
   }
}

/// Load style default over global style
void GuiLoadStyleDefault() {
   // We set this variable first to avoid cyclic function calls
   // when calling GuiSetStyle() and GuiGetStyle()
   guiStyleLoaded = true;
   // Initialize default LIGHT style property values
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BORDER_COLOR_NORMAL, 0x838383ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BASE_COLOR_NORMAL, 0xc9c9c9ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_COLOR_NORMAL, 0x686868ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BORDER_COLOR_FOCUSED, 0x5bb2d9ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BASE_COLOR_FOCUSED, 0xc9effeff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_COLOR_FOCUSED, 0x6c9bbcff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BORDER_COLOR_PRESSED, 0x0492c7ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BASE_COLOR_PRESSED, 0x97e8ffff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_COLOR_PRESSED, 0x368bafff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BORDER_COLOR_DISABLED, 0xb5c1c2ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BASE_COLOR_DISABLED, 0xe6e9e9ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_COLOR_DISABLED, 0xaeb7b8ff);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.BORDER_WIDTH, 1);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.INNER_PADDING, 1);
   GuiSetStyle(GuiControl.DEFAULT, GuiControlProperty.TEXT_ALIGNMENT, GuiTextAlignment.GUI_TEXT_ALIGN_CENTER);
   // Populate all controls with default style
   GuiUpdateStyleComplete();
   //Initialise default font.
   guiFont = GetFontDefault();
   // Initialize extended property values
   // NOTE: By default, extended property values are initialized to 0
   GuiSetStyle(GuiControl.DEFAULT, GuiDefaultProperty.TEXT_SIZE, 10);
   GuiSetStyle(GuiControl.DEFAULT, GuiDefaultProperty.TEXT_SPACING, 1);
   GuiSetStyle(GuiControl.DEFAULT, GuiDefaultProperty.LINE_COLOR, 0x90abb5ff); // GuiControl.DEFAULT specific property
   GuiSetStyle(GuiControl.DEFAULT, GuiDefaultProperty.BACKGROUND_COLOR, 0xf5f5f5ff); // GuiControl.DEFAULT specific property
   GuiSetStyle(GuiControl.LABEL, GuiControlProperty.TEXT_ALIGNMENT, GuiTextAlignment.GUI_TEXT_ALIGN_LEFT);
   GuiSetStyle(GuiControl.BUTTON, GuiControlProperty.BORDER_WIDTH, 2);
   GuiSetStyle(GuiControl.BUTTON, GuiControlProperty.INNER_PADDING, 4);
   GuiSetStyle(GuiControl.TOGGLE, GuiToggleProperty.GROUP_PADDING, 2);
   GuiSetStyle(GuiControl.SLIDER, GuiSliderProperty.SLIDER_WIDTH, 15);
   GuiSetStyle(GuiControl.SLIDER, GuiSliderProperty.TEXT_PADDING, 5);
   GuiSetStyle(GuiControl.CHECKBOX, GuiCheckBoxProperty.CHECK_TEXT_PADDING, 5);
   GuiSetStyle(GuiControl.COMBOBOX, GuiComboBoxProperty.SELECTOR_WIDTH, 30);
   GuiSetStyle(GuiControl.COMBOBOX, GuiComboBoxProperty.SELECTOR_PADDING, 2);
   GuiSetStyle(GuiControl.DROPDOWNBOX, GuiDropdownBoxProperty.ARROW_RIGHT_PADDING, 16);
   GuiSetStyle(GuiControl.TEXTBOX, GuiControlProperty.INNER_PADDING, 4);
   GuiSetStyle(GuiControl.TEXTBOX, GuiControlProperty.TEXT_ALIGNMENT, GuiTextAlignment.GUI_TEXT_ALIGN_LEFT);
   GuiSetStyle(GuiControl.TEXTBOX, GuiTextBoxProperty.MULTILINE_PADDING, 5);
   GuiSetStyle(GuiControl.TEXTBOX, GuiTextBoxProperty.COLOR_SELECTED_FG, 0xf0fffeff);
   GuiSetStyle(GuiControl.TEXTBOX, GuiTextBoxProperty.COLOR_SELECTED_BG, 0x839affe0);
   GuiSetStyle(GuiControl.VALUEBOX, GuiControlProperty.TEXT_ALIGNMENT, GuiTextAlignment.GUI_TEXT_ALIGN_CENTER);
   GuiSetStyle(GuiControl.SPINNER, GuiSpinnerProperty.SELECT_BUTTON_WIDTH, 20);
   GuiSetStyle(GuiControl.SPINNER, GuiSpinnerProperty.SELECT_BUTTON_PADDING, 2);
   GuiSetStyle(GuiControl.SPINNER, GuiSpinnerProperty.SELECT_BUTTON_BORDER_WIDTH, 1);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiControlProperty.BORDER_WIDTH, 0);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiScrollBarProperty.SHOW_SPINNER_BUTTONS, 0);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiControlProperty.INNER_PADDING, 0);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiScrollBarProperty.ARROWS_SIZE, 6);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiScrollBarProperty.SLIDER_PADDING, 0);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiScrollBarProperty.SLIDER_SIZE, 16);
   GuiSetStyle(GuiControl.SCROLLBAR, GuiScrollBarProperty.SCROLL_SPEED, 10);
   GuiSetStyle(GuiControl.LISTVIEW, GuiListViewProperty.ELEMENTS_HEIGHT, 0x1e);
   GuiSetStyle(GuiControl.LISTVIEW, GuiListViewProperty.ELEMENTS_PADDING, 2);
   GuiSetStyle(GuiControl.LISTVIEW, GuiListViewProperty.SCROLLBAR_WIDTH, 10);
   GuiSetStyle(GuiControl.LISTVIEW, GuiListViewProperty.SCROLLBAR_SIDE, GuiScrollBarSide.SCROLLBAR_RIGHT_SIDE);
   GuiSetStyle(GuiControl.COLORPICKER, GuiColorPickerProperty.COLOR_SELECTOR_SIZE, 6);
   GuiSetStyle(GuiControl.COLORPICKER, GuiColorPickerProperty.BAR_WIDTH, 0x14);
   GuiSetStyle(GuiControl.COLORPICKER, GuiColorPickerProperty.BAR_PADDING, 0xa);
   GuiSetStyle(GuiControl.COLORPICKER, GuiColorPickerProperty.BAR_SELECTOR_HEIGHT, 6);
   GuiSetStyle(GuiControl.COLORPICKER, GuiColorPickerProperty.BAR_SELECTOR_PADDING, 2);
}

/// Updates controls style with default values
void GuiUpdateStyleComplete() {
   // Populate all controls with default style
   // NOTE: Extended style properties are ignored
   foreach (i; 1 .. NUM_CONTROLS) {
      foreach (j; 0 .. NUM_PROPS_DEFAULT) {
         GuiSetStyle(i, j, GuiGetStyle(GuiControl.DEFAULT, j));
      }
   }
}

/// Get text with icon id prepended
/// NOTE: Useful to add icons by name id (enum) instead of
/// a number that can change between ricon versions
string GuiIconText(int iconId, string text) {
   import std.format : format;
   return "#%03d#%s".format(iconId, text);
}

//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------

/// Split controls text into multiple strings
/// Also check for multiple columns (required by GuiToggleGroup())
private string[] GuiTextSplit(string text) {
   //TODO: Multiple columns.
   import std.regex : splitter, regex;
   import std.typecons : No;
   import std.array : array;
   import std.algorithm : min;

   enum MAX_SUBSTRINGS_COUNT = 64;
   static pattern = regex(`([;\n])`);
   auto result = text.splitter!(No.keepSeparators)(pattern).array;
   return result[0 .. MAX_SUBSTRINGS_COUNT.min(result.length)];
}

// Convert color data from RGB to HSV
// NOTE: Color data should be passed normalized

// Value

// Undefined, maybe NAN?

// NOTE: If max is 0, this divide would cause a crash
// Saturation

// NOTE: If max is 0, then r = g = b = 0, s = 0, h is undefined

// Undefined, maybe NAN?

// NOTE: Comparing float values could not work properly
// Between yellow & magenta

// Between cyan & yellow
// Between magenta & cyan

// Convert to degrees
Vector3 ConvertRGBtoHSV(Vector3 rgb);

// Convert color data from HSV to RGB
// NOTE: Color data should be passed normalized

// NOTE: Comparing float values could not work properly
Vector3 ConvertHSVtoRGB(Vector3 hsv);

// Returns a Color struct from hexadecimal value

// Returns hexadecimal value for a Color

// Check if point is inside rectangle

// Color fade-in or fade-out, alpha goes from 0.0f to 1.0f

// Formatting of text with variables to 'embed'

// RAYGUI_STANDALONE

// RAYGUI_IMPLEMENTATION
