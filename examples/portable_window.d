/*******************************************************************************************
*
*   raygui - portable window
*
*   DEPENDENCIES:
*       raylib 2.1  - Windowing/input management and drawing.
*       raygui 2.0  - Immediate-mode GUI controls.
*
*   COMPILATION (Windows - MinGW):
*       gcc -o $(NAME_PART).exe $(FILE_NAME) -I../../src -lraylib -lopengl32 -lgdi32 -std=c99
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2019 raylib technologies (@raylibtech)
*
**********************************************************************************************/
import raylib;
import draygui.raygui;
import draygui.util : setWindowPosition, drawText;
import draygui.iconsdata;
import std.format : format;
import std.conv : to;

int main() {
   // Initialization
   //---------------------------------------------------------------------------------------
   int screenWidth = 800;
   int screenHeight = 600;

   SetConfigFlags(ConfigFlag.FLAG_WINDOW_UNDECORATED);
   InitWindow(screenWidth, screenHeight, "raygui - portable window");

   // General variables
   Vector2 mousePosition = Vector2(0, 0);
   Vector2 windowPosition = Vector2(500F, 200F);
   Vector2 panOffset = mousePosition;
   bool dragWindow = false;

   setWindowPosition(windowPosition);

   bool exitWindow = false;

   SetTargetFPS(60);
   while (!exitWindow && !WindowShouldClose()) // Detect window close button or ESC key
   {
      // Update
      mousePosition = GetMousePosition();

      if (IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON)) {
         if (CheckCollisionPointRec(mousePosition, Rectangle(0, 0, screenWidth, 20))) {
            dragWindow = true;
            panOffset = mousePosition;
         }
      }

      if (dragWindow) {
         windowPosition.x += (mousePosition.x - panOffset.x);
         windowPosition.y += (mousePosition.y - panOffset.y);

         if (IsMouseButtonReleased(MouseButton.MOUSE_LEFT_BUTTON)) {
            dragWindow = false;
         }

         setWindowPosition(windowPosition);
      }

      // Draw
      BeginDrawing();

      ClearBackground(RAYWHITE);

      exitWindow = GuiWindowBox(Rectangle(0, 0, screenWidth, screenHeight), "PORTABLE WINDOW");

      string title = "Mouse Position: [ %.0f, %.0f ]".format(mousePosition.x, mousePosition.y);
      drawText(title, 10, 40, 20, DARKGRAY);

      EndDrawing();
   }

   CloseWindow(); // Close window and OpenGL context
   return 0;
}
