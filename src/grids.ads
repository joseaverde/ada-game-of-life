package Grids with Pure is

   Max_Rows : constant := 100;
   Max_Cols : constant := 100;

   type Row_Index is range 1 .. 100;
   type Col_Index is range 1 .. 100;
   type Cell_State is range 0 .. 255 with Size => 8;
   subtype Maximum_Life is Cell_State range 1 .. Cell_State'Last;

   type Grid_Type (
      Rows  : Row_Index;
      Cols  : Col_Index;
      Decay : Maximum_Life) is
      tagged limited private with
      Preelaborable_Initialization;

   procedure Set (
      Grid  : in out Grid_Type;
      Row   : in     Row_Index;
      Col   : in     Col_Index;
      State : in     Cell_State) with
      Pre  => (Row in 1 .. Grid.Rows and then Col in 1 .. Grid.Cols and then
               State <= Grid.Decay)
                 or else raise Constraint_Error,
      Post => Get (Grid, Row, Col) = State;

   function Get (
      Grid  : in Grid_Type;
      Row   : in Row_Index;
      Col   : in Col_Index)
      return Cell_State with
      Pre => (Row in 1 .. Grid.Rows and then Col in 1 .. Grid.Cols)
                or else raise Constraint_Error;

   procedure Tick (Grid : in out Grid_Type);

   procedure Query (
      Grid    : in Grid_Type;
      Process : not null access
                procedure (
                   Row   : in Row_Index;
                   Col   : in Col_Index;
                   State : in Cell_State));

   procedure Update (
      Grid    : in out Grid_Type;
      Process : not null access
                function (Row : in Row_Index; Col : in Col_Index)
                   return Cell_State);

private

   subtype Extended_Row_Index is Row_Index'Base range -1 .. Row_Index'Last;
   subtype Extended_Col_Index is Col_Index'Base range -1 .. Col_Index'Last;

   type Grid_Buffer is
      array (Extended_Row_Index range <>, Extended_Col_Index range <>)
      of Cell_State with Pack, Default_Component_Value => Cell_State'First;

   type Selector_Type is (First, Second);

   type Grid_Type (
      Rows  : Row_Index;
      Cols  : Col_Index;
      Decay : Maximum_Life) is
   tagged limited record
      Selector      : Selector_Type;
      First_Buffer  : aliased Grid_Buffer (-1 .. Rows, -1 .. Cols);
      Second_Buffer : aliased Grid_Buffer (-1 .. Rows, -1 .. Cols);
   end record with Pack;

   function Get (
      Grid  : in Grid_Type;
      Row   : in Row_Index;
      Col   : in Col_Index)
      return Cell_State is (
      (case Grid.Selector is
         when First  => Grid.First_Buffer (Row - 1, Col - 1),
         when Second => Grid.First_Buffer (Row - 1, Col - 1)));

end Grids;
