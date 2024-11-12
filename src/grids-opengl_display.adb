with Ada.Containers.Indefinite_Holders;
with GL.Attributes, GL.Buffers, GL.Pixels, GL.Types;
with GL.Objects.Buffers, GL.Objects.Programs, GL.Objects.Shaders,
   GL.Objects.Textures, GL.Objects.Textures.Targets, GL.Objects.Vertex_Arrays;
with Interfaces;

package body Grids.OpenGL_Display is

   subtype Byte is Interfaces.Unsigned_8;
   type Texture_Buffer is array (Row_Index range <>, Col_Index range <>)
      of aliased Byte with Pack;

   package Texture_Holders is
      new Ada.Containers.Indefinite_Holders (Texture_Buffer);
   subtype Texture_Holder is Texture_Holders.Holder;

   -->> Shaders <<--

   LF : constant Character := Character'Val (10);
   Vertex_Shader_Source : constant String :=
"#version 330 core                                                     " & LF &
"                                                                      " & LF &
"in vec2 position ;                                                    " & LF &
"out vec2 fragment_position ;                                          " & LF &
"                                                                      " & LF &
"void main ( void ) {                                                  " & LF &
"                                                                      " & LF &
"  gl_Position = vec4 ( position, 0.0, 1.0 ) ;                         " & LF &
"  vec2 pos = 0.5 * ( position + vec2 (1, 1) );                        " & LF &
"  fragment_position = vec2(pos.x, 1 - pos.y);                         " & LF &
"}                                                                     " & LF;

   Fragment_Shader_Source : constant String :=
"#version 330 core                                                     " & LF &
"                                                                      " & LF &
"in vec2 fragment_position ;                                           " & LF &
"out vec4 colour ;                                                     " & LF &
"uniform sampler2D gridTexture ;                                       " & LF &
"                                                                      " & LF &
"void main ( void ) {                                                  " & LF &
"                                                                      " & LF &
"  float p = texture ( gridTexture, fragment_position ).r ;            " & LF &
"  colour = vec4 ( .4 * p + .1, p, .8 * p + .2, 1.0 ) ;                " & LF &
"}                                                                     " & LF;

   -->> OpenGL Objects <<--

   Program  : GL.Objects.Programs.Program;
   Vertices : GL.Objects.Buffers.Buffer;
   Texture  : GL.Objects.Textures.Texture;
   Holder   : Texture_Holder;

   -->> OpenGL <<--

   procedure Load_Vectors is
      new GL.Objects.Buffers.Load_To_Buffer (
      GL.Types.Singles.Vector2_Pointers);

   procedure Load_Shader is
      Vertex_Shader : GL.Objects.Shaders.Shader (
         GL.Objects.Shaders.Vertex_Shader);
      Fragment_Shader : GL.Objects.Shaders.Shader (
         GL.Objects.Shaders.Fragment_Shader);
   begin
      -->> Vertex Shader <<--
      Vertex_Shader.Initialize_Id;
      Vertex_Shader.Set_Source (Vertex_Shader_Source);
      Vertex_Shader.Compile;
      if not Vertex_Shader.Compile_Status then
         raise Program_Error with "Couldn't compile vertex shader : " &
            Vertex_Shader.Info_Log;
      end if;
      -->> Fragment Shader <<--
      Fragment_Shader.Initialize_Id;
      Fragment_Shader.Set_Source (Fragment_Shader_Source);
      Fragment_Shader.Compile;
      if not Fragment_Shader.Compile_Status then
         raise Program_Error with "Couldn't compile fragment shader : " &
            Fragment_Shader.Info_Log;
      end if;
      -->> Program <<--
      Program.Initialize_Id;
      Program.Attach (Vertex_Shader);
      Program.Attach (Fragment_Shader);
      Program.Link;
      if not Program.Link_Status then
         raise Program_Error with "Couldn't link program! : " &
            Program.Info_Log;
      end if;
   end Load_Shader;

   procedure Update_Texture is
   begin
      GL.Objects.Textures.Targets.Texture_2D.Bind (Texture);
      GL.Objects.Textures.Targets.Texture_2D.Set_Minifying_Filter (
         GL.Objects.Textures.Nearest);
      GL.Objects.Textures.Targets.Texture_2D.Set_Magnifying_Filter (
         GL.Objects.Textures.Nearest);
      GL.Objects.Textures.Targets.Texture_2D.Set_Highest_Mipmap_Level (0);
      GL.Objects.Textures.Targets.Texture_2D.Load_From_Data (
         Level             => 0,
         Internal_Format   => GL.Pixels.Red,
         Width             => Holder.Constant_Reference.Element'Length (2),
         Height            => Holder.Constant_Reference.Element'Length (1),
         Source_Format     => GL.Pixels.Red,
         Source_Type       => GL.Pixels.Unsigned_Byte,
         Source            => GL.Objects.Textures.Image_Source (
            Holder.Reference.Element.all'Address));
   end Update_Texture;

   procedure Prepare is
      use type GL.Types.Single;
      Buffer : constant GL.Types.Singles.Vector2_Array := [
         [-1.0, -1.0], [+1.0, -1.0], [+1.0, +1.0],
         [+1.0, +1.0], [-1.0, +1.0], [-1.0, -1.0]];
   begin
      Load_Shader;
      Vertices.Initialize_Id;
      GL.Objects.Buffers.Array_Buffer.Bind (Vertices);
      Load_Vectors (
         Target => GL.Objects.Buffers.Array_Buffer,
         Data   => Buffer,
         Usage  => GL.Objects.Buffers.Static_Draw);
      Texture.Initialize_Id;
      Update_Texture;
   end Prepare;

   procedure Render is
   begin
      GL.Buffers.Set_Color_Clear_Value ([1.0, 1.0, 1.0, 1.0]);
      GL.Buffers.Clear (Bits => (Color => True, others => False));

      Program.Use_Program;
      GL.Objects.Textures.Set_Active_Unit (0);
      GL.Objects.Textures.Targets.Texture_2D.Bind (Texture);
      GL.Attributes.Enable_Vertex_Attrib_Array (0);
      GL.Objects.Buffers.Array_Buffer.Bind (Vertices);
      GL.Attributes.Set_Vertex_Attrib_Pointer (
         Index      => 0,
         Count      => 2,
         Kind       => GL.Types.Single_Type,
         Normalized => False,
         Stride     => 0,
         Offset     => 0);
      GL.Objects.Vertex_Arrays.Draw_Arrays (
         Mode  => GL.Types.Triangles,
         First => 0,
         Count => 6);
      GL.Attributes.Disable_Vertex_Attrib_Array (0);
   end Render;

   -->> Interface <<--

   procedure Start (Grid : in Grid_Type) is
      New_Texture : Texture_Buffer (1 .. Grid.Rows, 1 .. Grid.Cols);
   begin
      Holder.Replace_Element (New_Texture);
      Prepare;
   end Start;

   procedure Frame (Grid : in Grid_Type) is
      Tex renames Holder.Reference.Element;
      procedure Process (
         Row   : in Row_Index;
         Col   : in Col_Index;
         State : in Cell_State) is
      begin
         Tex (Row, Col) := Byte (Integer (State) * 255 / Integer (Grid.Decay));
      end Process;
   begin
      -- Copy texture
      Grid.Query (Process'Access);
      Update_Texture;
      Render;
   end Frame;

   procedure Stop is
   begin
      Holder.Clear;
   end Stop;

end Grids.OpenGL_Display;
