package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:math"
import platform "../platform"

counter := u32(0)
shader := u32(0)

exit := false

@export
init :: proc() {
  platform.init("screen", 640, 360)
  shader_ok: bool
  shader, shader_ok = platform.create_shader(
    platform.VERTEX_SHADER_SOURCE,
    platform.FRAGMENT_SHADER_SOURCE,
  )
  if !shader_ok {
    fmt.println("error when creating shader")
    exit = true
  }
}

@export
deinit :: proc() {
  platform.deinit()
}

draw_quad :: proc(x, y, size_x, size_y: f32, color: platform.Color) {
  color := platform.u8color_to_f32color(color)

  half_size := [3]f32{size_x, size_y, 0} / 2
  pos := [3]f32{x, y, 0} + half_size

  cima_esquerda := platform.Vertex{
    pos   = ({-1, +1, 0} * half_size + pos),
    color = color,
  }
  cima_direita := platform.Vertex{
    pos   = ({+1, +1, 0} * half_size + pos),
    color = color,
  }
  baixo_esquerda := platform.Vertex{
    pos   = ({-1, -1, 0} * half_size + pos),
    color = color,
  }
  baixo_direita := platform.Vertex{
    pos   = ({+1, -1, 0} * half_size + pos),
    color = color,
  }

  platform.add_vertex(cima_direita)
  platform.add_vertex(cima_esquerda)
  platform.add_vertex(baixo_esquerda)

  platform.add_vertex(baixo_esquerda)
  platform.add_vertex(baixo_direita)
  platform.add_vertex(cima_direita)
}

pos_y := f32(300)
pos_x := f32(300) 
sla := false

@export
step :: proc(dt: f64) -> bool {

  if platform.is_key_pressed(.Escape) do exit = true

  platform.begin_drawing()
  {
    platform.clear_color(.2, .4, .6, 1)

    if platform.is_key_pressed(.Space) do sla = !sla

    if platform.is_key_down(.W) do pos_x += 150 * f32(dt)
    if platform.is_key_down(.S) do pos_x -= 150 * f32(dt)
    if platform.is_key_down(.A) do pos_y -= 150 * f32(dt)
    if platform.is_key_down(.D) do pos_y += 150 * f32(dt)


    for i in f32(0)..<21 {
      size := f32(30)
      platform.draw_triangle(i*size, 0, size, {255, 128, 64, 255})
    }


    platform.draw_triangle(pos_y, pos_x, 10, {255, sla ? 0 : 255, 0, 255})
    draw_quad(0, 0, 10, 10, {255, 0, 0, 255})
  }
  platform.end_drawing(shader)

  return !exit
}

