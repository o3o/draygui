import raylib;
import draygui.raygui;
import draygui.iconsdata;
import std.format : format;
import std.stdio;

void main(string[] args) {
   int screenWidth = 690;
   int screenHeight = 560;
   InitWindow(screenWidth, screenHeight, "raygui - button");
   SetExitKey(0);
   bool exitWindow;
   size_t step = 0;

   while (!exitWindow) {
      exitWindow = WindowShouldClose();
      switch (step) {
         case 0:
            if (mainForm()) {
               step = 1;
            }
            break;
         case 1:
            if (subForm()) {
               step = 0;
            }
            break;
         default:
            assert(false);
      }

   }
}

bool mainForm() {
   bool done;
   // Detect window close button or ESC key
   BeginDrawing();
   ClearBackground(GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR)));
   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);
   if (GuiButton(Rectangle(25, 255, 125, 30), GuiIconText(GuiIconName.RICON_FILE_SAVE, "Open sub"))) {
      writeln("click");
      done =true;
   }
   EndDrawing();
   return done;

}

bool subForm() {
   bool done;
   // Detect window close button or ESC key
   BeginDrawing();
   ClearBackground(GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR)));
   GuiSetStyle(BUTTON, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);
   if (GuiButton(Rectangle(25, 255, 125, 50), "Exit")) {
      done = true;
      writeln("click sub");
   }
   EndDrawing();
   return done;
}
