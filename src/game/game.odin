package game

import "core:fmt"
import platform "../platform_functions"

counter := u32(0)
shader := u32(0)

exit := false

@export
init :: proc() {
  platform.init()
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

@export
step :: proc(dt: f64) -> bool {
  counter += 1

  if counter == 200 do exit = true

  platform.begin_drawing()
  {
    platform.clear_color(.2, .4, .6, 1)

    platform.draw(shader)
  }
  platform.end_drawing()

  return !exit
}

