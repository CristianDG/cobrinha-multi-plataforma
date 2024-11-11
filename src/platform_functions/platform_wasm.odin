#+build js
package platform_functions

/*
TODO:
  - deinit proc
  - get window dimensions
  - set window dimensions
*/

import "base:runtime"
import "core:fmt"
import "core:sys/wasm/js"
import webgl "vendor:wasm/WebGL"

foreign import platform "platform_functions"

@(default_calling_convention="contextless")
foreign platform {
	get_platform_name :: proc() ---
  get_ticks :: proc() -> u64 ---
}

init :: proc "c" () {
  context = runtime.default_context()
  ok := webgl.CreateCurrentContextById("screen", {})
}

@export clear_color :: proc "c" (r, g, b, a: f32) {
  webgl.Clear(webgl.COLOR_BUFFER_BIT)
  webgl.ClearColor(r, g, b, a)
}

create_shader :: proc (vertex_source, fragment_source: string) -> (u32, bool) {
  program := webgl.CreateProgram()

  success  : i32
  info_log : [512]byte

  vertex_shader : webgl.Shader
  defer webgl.DeleteShader(vertex_shader)
  {
    vertex_shader = webgl.CreateShader(webgl.VERTEX_SHADER)
    webgl.ShaderSource(vertex_shader, { vertex_source })
    webgl.CompileShader(vertex_shader)

    success = webgl.GetShaderiv(vertex_shader, webgl.COMPILE_STATUS)
    if success == 0 {
      reason := webgl.GetShaderInfoLog(vertex_shader, info_log[:])
      fmt.println("[VERTEX ERROR]:",reason)
      return 0, false
    }
  }

  fragment_shader : webgl.Shader
  defer webgl.DeleteShader(fragment_shader)
  {
    fragment_shader = webgl.CreateShader(webgl.FRAGMENT_SHADER)
    webgl.ShaderSource(fragment_shader, { fragment_source })
    webgl.CompileShader(fragment_shader)

    success = webgl.GetShaderiv(fragment_shader, webgl.COMPILE_STATUS)
    if success == 0 {
      reason := webgl.GetShaderInfoLog(fragment_shader, info_log[:])
      fmt.println("[FRAGMENT ERROR]:",reason)
      return 0, false
    }
  }

  webgl.AttachShader(program, vertex_shader)
  webgl.AttachShader(program, fragment_shader)
  webgl.LinkProgram(program)

  reason := webgl.GetProgramInfoLog(program, info_log[:])
  if reason != "" {
    fmt.println("[SHADER_ERROR]", reason)
  }

  return u32(program), true
}

// TODO:
deinit :: proc() {
  // webgl.DeleteProgram(shader)
}

begin_drawing :: proc() {}
end_drawing   :: proc() {}

// TODO: remover
draw :: proc(shader: u32) {

  @static vbo : webgl.Buffer
  @static created := false
  @static vao : webgl.VertexArrayObject

  @static vertices := []f32 {
    -.5, -.5, 0, // left
    +.5, -.5, 0, // right
    0.0, +.5, 0, // middle
  }

  if !created {
    vao = webgl.CreateVertexArray()
    webgl.BindVertexArray(vao)

    vbo = webgl.CreateBuffer()
    webgl.BindBuffer(webgl.ARRAY_BUFFER, vbo)
    webgl.BufferData(webgl.ARRAY_BUFFER, size_of(vertices[0]) * len(vertices), &vertices[0], webgl.STATIC_DRAW)
    created = false

    webgl.VertexAttribPointer(0, 3, webgl.FLOAT, false, 3 * size_of(f32), 0)
    webgl.EnableVertexAttribArray(0)
  }

  webgl.UseProgram(webgl.Program(shader))
  webgl.DrawArrays(webgl.TRIANGLES, 0, 3)
}

