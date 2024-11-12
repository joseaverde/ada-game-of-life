with Ada.Calendar;
with Window;
with Grids, Grids.Rules, Grids.Display_ANSI, Grids.OpenGL_Display;

procedure GameOfLife is
   use type Ada.Calendar.Time, Grids.Row_Index, Grids.Col_Index;

   Sleep  : constant Duration := 0.100;
   Width  : constant := 800;
   Height : constant := 800;
   Next   : Ada.Calendar.Time;

   G_Width  : constant := 16;
   G_Height : constant := 16;
   Decay    : constant := 3;
   Grid     : Grids.Grid_Type (G_Height, G_Width, Decay);

begin
   Window.Open (Width, Height, "Game of Life -- Ada");
   Grids.Rules.Wave (Grid);
   -- Grid.Set (G_Height / 2,     G_Width / 2 + 1, Decay);
   -- Grid.Set (G_Height / 2 + 1, G_Width / 2 + 1, Decay);
   -- Grid.Set (G_Height / 2 + 2, G_Width / 2 + 1, Decay);
   -- Grid.Set (G_Height / 2 + 1, G_Width / 2,     Decay);
   -- Grid.Set (G_Height / 2 + 2, G_Width / 2 + 2, Decay);
   Grids.OpenGL_Display.Start (Grid);
   Grids.Display_ANSI (Grid);
   Next := Ada.Calendar.Clock + Sleep;
   while Window.Is_Open loop
      Window.Begin_Frame;
      Grids.Display_ANSI (Grid);
      Grids.OpenGL_Display.Frame (Grid);
      Window.End_Frame;
      delay until Next;
      Next := Ada.Calendar.Clock + Sleep;
      Grid.Tick;
   end loop;
   Grids.OpenGL_Display.Stop;
   Window.Finalise;
end GameOfLife;
