package body Grids.Rules is

   procedure Rule (
      Grid    : in out Grid_Type;
      Process : not null access
                function (Row : in Row_Index; Col : in Col_Index)
                   return Boolean) is
      function Wrapper (Row : in Row_Index; Col : in Col_Index)
         return Cell_State is (
         (if Process (Row, Col) then Grid.Decay else 0));
   begin
      Grid.Update (Wrapper'Access);
   end Rule;

   procedure Triangle (Grid : in out Grid_Type) is
      function Process (Row : in Row_Index; Col : in Col_Index)
         return Boolean is (Integer (Col) < Integer (Row));
   begin
      Rule (Grid, Process'Access);
   end Triangle;

   -- procedure Missile (Grid : in out Grid_Type);
   -- procedure Ships (Grid : in out Grid_Type);
   -- procedure Snowflake (Grid : in out Grid_Type);
   -- procedure Colonies (Grid : in out Grid_Type);
   -- procedure Wave (Grid : in out Grid_Type);

   procedure Wave (Grid : in out Grid_Type) is
      function Process (Row : in Row_Index; Col : in Col_Index)
         return Boolean is (
         (Col mod 2 = 0 and Row mod 2 = 0) or else
         (Integer (Row) < Integer (Col) and Col mod 2 = 0));
   begin
      Rule (Grid, Process'Access);
   end Wave;

end Grids.Rules;
