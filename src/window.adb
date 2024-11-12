with GL, GL.Objects.Vertex_Arrays, GL.Types, GL.Window;
with Glfw.Input, Glfw.Windows, Glfw.Windows.Context, Glfw.Windows.Hints;

package body Window is

   type Window_Type is
      new Glfw.Windows.Window with
      null record;

   Screen : aliased Window_Type;
   VAO    : GL.Objects.Vertex_Arrays.Vertex_Array_Object;

   procedure Open (
      Width  : in Width_Type;
      Height : in Height_Type;
      Title  : in String) is
   begin
      GL.Init;
      Glfw.Init;
      Glfw.Windows.Hints.Set_Minimum_OpenGL_Version (3, 3);
      Glfw.Windows.Hints.Set_Profile (Glfw.Windows.Context.Core_Profile);
      Glfw.Windows.Hints.Set_Resizable (False);
      Screen.Init (
         Width  => Glfw.Size (Width),
         Height => Glfw.Size (Height),
         Title  => Title);
      GL.Window.Set_Viewport (
         X      => 0,
         Y      => 0,
         Width  => GL.Types.Size (Width),
         Height => GL.Types.Size (Height));
      VAO.Initialize_Id;
      VAO.Bind;
   end Open;

   function Is_Open return Boolean is (not Screen.Should_Close);

   procedure Begin_Frame is
   begin
      Glfw.Input.Poll_Events;
      VAO.Bind;
   end Begin_Frame;

   procedure End_Frame is
   begin
      Glfw.Windows.Context.Swap_Buffers (Screen'Access);
   end End_Frame;

   procedure Finalise is
   begin
      Glfw.Shutdown;
   end Finalise;

end Window;
