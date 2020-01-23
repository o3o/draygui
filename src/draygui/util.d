module draygui.util;

import raylib;

void setWindowPosition(Vector2 v) {
   setWindowPosition(v.x, v.y);
}

void setWindowPosition(float x, float y) {
   import std.conv : to;
   SetWindowPosition(x.to!int, y.to!int);
}

void drawText(string text, int posX, int posY, int fontSize, Color color) {
   import std.string : toStringz;
   DrawText(toStringz(text) , posX, posY, fontSize, color);
}

Rectangle rect(float x, float y, float width, float height) {
   return Rectangle( x, y, width,  height);
}


