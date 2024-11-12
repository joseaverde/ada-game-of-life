package Window is

   type Width_Type is range 80 .. 16_384;
   type Height_Type is range 80 .. 16_384;

   procedure Open (
      Width  : in Width_Type;
      Height : in Height_Type;
      Title  : in String);

   function Is_Open return Boolean;

   procedure Begin_Frame;

   procedure End_Frame;

   procedure Finalise;

end Window;
