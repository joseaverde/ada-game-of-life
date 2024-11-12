package body Grids is

   procedure Set (
      Grid  : in out Grid_Type;
      Row   : in     Row_Index;
      Col   : in     Col_Index;
      State : in     Cell_State) is
   begin
      case Grid.Selector is
         when First  => Grid.First_Buffer (Row - 1, Col - 1) := State;
         when Second => Grid.Second_Buffer (Row - 1, Col - 1) := State;
      end case;
   end Set;

   procedure Tick (
      Source : in     Grid_Buffer;
      Max    : in     Maximum_Life;
      Target :    out Grid_Buffer) is
      function Is_Dead (State : in Cell_State) return Boolean is (
         State < Max);
      function Is_Alive (State : in Cell_State) return Boolean is (
         State = Max);
      Directions : constant array (1 .. 9) of Integer
                 := [-1, -1, 0, -1, 1, 0, 1, 1, -1];
      Neighbours : Natural;
      State      : Cell_State;
   begin
      for Row in Source'First (1) + 1 .. Source'Last (1) - 1 loop
         for Col in Source'First (2) + 1 .. Source'Last (2) - 1 loop
            -- Count neighbours
            Neighbours := 0;
            for I in Directions'First .. Directions'Last - 1
               when Is_Alive (Source (
                  Row + Extended_Row_Index (Directions (I)),
                  Col + Extended_Col_Index (Directions (I + 1))))
            loop
                  Neighbours := @ + 1;
            end loop;
            -- Update target
            State := Source (Row, Col);
            Target (Row, Col) := (
               if Is_Alive (State) and Neighbours < 2    then Max - 1
               elsif Is_Alive (State) and Neighbours > 3 then Max - 1
               elsif Is_Dead (State) and Neighbours = 3  then Max
               elsif Is_Dead (State) then (if State = 0 then 0 else State - 1)
               else State);
         end loop;
      end loop;
   end Tick;

   procedure Tick (Grid : in out Grid_Type) is
   begin
      case Grid.Selector is
         when First =>
            Tick (Grid.First_Buffer, Grid.Decay, Grid.Second_Buffer);
            Grid.Selector := Second;
         when Second =>
            Tick (Grid.Second_Buffer, Grid.Decay, Grid.First_Buffer);
            Grid.Selector := First;
      end case;
   end Tick;

   procedure Update (
      Grid    : in out Grid_Buffer;
      Process : not null access
                function (Row : in Row_Index; Col : in Col_Index)
                   return Cell_State) is
   begin
      for Row in Grid'First (1) + 1 .. Grid'Last (1) - 1 loop
         for Col in Grid'First (2) + 1 .. Grid'Last (2) - 1 loop
            Grid (Row, Col) := Process (Row + 1, Col + 1);
         end loop;
      end loop;
   end Update;

   procedure Update (
      Grid    : in out Grid_Type;
      Process : not null access
                function (Row : in Row_Index; Col : in Col_Index)
                   return Cell_State) is
   begin
      case Grid.Selector is
         when First  => Update (Grid.First_Buffer, Process);
         when Second => Update (Grid.Second_Buffer, Process);
      end case;
   end Update;

   procedure Query (
      Grid    : in Grid_Buffer;
      Process : not null access
                procedure (
                   Row   : in Row_Index;
                   Col   : in Col_Index;
                   State : in Cell_State)) is
   begin
      for Row in Grid'First (1) + 1 .. Grid'Last (1) - 1 loop
         for Col in Grid'First (2) + 1 .. Grid'Last (2) - 1 loop
            Process (Row + 1, Col + 1, Grid (Row, Col));
         end loop;
      end loop;
   end Query;

   procedure Query (
      Grid    : in Grid_Type;
      Process : not null access
                procedure (
                   Row   : in Row_Index;
                   Col   : in Col_Index;
                   State : in Cell_State)) is
   begin
      case Grid.Selector is
         when First  => Query (Grid.First_Buffer, Process);
         when Second => Query (Grid.Second_Buffer, Process);
      end case;
   end Query;

end Grids;
