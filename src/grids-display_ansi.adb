with Ada.Text_IO, Ada.Integer_Text_IO;

procedure Grids.Display_ANSI (Grid : in Grid_Type) is
   use Ada.Text_IO, Ada.Integer_Text_IO;
   procedure Escape (Rest : in String) is
   begin
      Put (ASCII.ESC); Put ("["); Put (Rest);
   end Escape;

   function Scale (State : in Cell_State; Part : in Integer)
      return Integer is (
      Integer (State) * 255 / Integer (Grid.Decay) * Part / 10);

   Last_Row : Row_Index := Row_Index'First;

   procedure Draw_Frame (
      Row   : in Row_Index;
      Col   : in Col_Index;
      State : in Cell_State) is
   begin
      if Row /= Last_Row then
         Escape ("0m");
         New_Line;
         Last_Row := Row;
      end if;
      Escape ("48;2;");
      Put (Scale (State, 4) + 25, 1); Put (';');
      Put (Scale (State, 10), 1);     Put (';');
      Put (Scale (State, 8) + 51, 1); Put ('m');
      Put ("  ");
   end Draw_Frame;

begin
   Escape ("?25l");
   Escape ("?2026h");
   Grid.Query (Draw_Frame'Access);
   Escape ("?2026l");
   Escape ("?25h");
   Escape ("0m");
   New_Line (2);
end Grids.Display_ANSI;
