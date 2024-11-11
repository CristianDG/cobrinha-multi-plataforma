#+build !js
package platform_functions

import "base:runtime"
import "core:fmt"
import sdl "vendor:sdl2"
import gl "vendor:OpenGL"

foreign import platform "bin:native/platform_functions.so"

@export get_platform_name :: proc "contextless" () {
  context = runtime.default_context()
  fmt.println("native")
}

SCREEN_WIDTH  :: 640
SCREEN_HEIGHT :: 480

global_window  : ^sdl.Window
global_surface : ^sdl.Surface
global_gl_context : sdl.GLContext

init :: proc() {

  global_window = sdl.CreateWindow(
    "Teste",
    sdl.WINDOWPOS_UNDEFINED,
    sdl.WINDOWPOS_UNDEFINED,
    SCREEN_WIDTH,
    SCREEN_HEIGHT,
    { .OPENGL },
  )
  if global_window == nil {
    fmt.println("could not create window: %s", sdl.GetError())
  }

  global_gl_context = sdl.GL_CreateContext(global_window)
  sdl.GL_MakeCurrent(global_window, global_gl_context)
  gl.load_up_to(3, 3, sdl.gl_set_proc_address)
  
}

deinit :: proc() {
  sdl.DestroyWindow(global_window)
  sdl.Quit()
}

create_shader :: proc(vertex_source, fragment_source: string) -> (u32, bool) {
  return gl.load_shaders_source(vertex_source, fragment_source)
}

clear_color :: proc(r, g, b, a: f32) {
  gl.Clear(gl.COLOR_BUFFER_BIT)
  gl.ClearColor(r, g, b, a)
}

get_ticks :: proc() -> u64 {
  return sdl.GetTicks64()
}

begin_drawing :: proc() {
}

end_drawing :: proc() {
  sdl.GL_SwapWindow(global_window)
}

draw :: proc(shader: u32) {
  @static vbo : u32
  @static created := false
  @static vao : u32

  @static vertices := []f32 {
    -.5, -.5, 0, // left
    +.5, -.5, 0, // right
    0.0, +.5, 0, // middle
  }

  gl.UseProgram(shader)

  if !created {
    created = false
    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices[0]) * len(vertices), &vertices[0], gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
  }

  gl.DrawArrays(gl.TRIANGLES, 0, 3)
}

