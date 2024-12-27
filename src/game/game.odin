package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:math"
import "core:math/rand"
import platform "../platform"

// TODO: Game_State struct
Game_State :: struct {}

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

  snake[0] = {10, 10}
}

@export
deinit :: proc() {
  platform.deinit()
}

draw_quad_with_transform :: proc(transform: glm.mat4, color: platform.Color) {
  color := platform.u8color_to_f32color(color)
  transform := transform
  transform *= glm.mat4Scale({.5, .5, 1})
  transform *= glm.mat4Translate({1, 1, 0})

  top_left := platform.Vertex{
    pos   = (transform * [?]f32{-1, +1, 0, 1}).xyz,
    color = color,
  }
  top_right := platform.Vertex{
    pos   = (transform * [?]f32{+1, +1, 0, 1}).xyz,
    color = color,
  }
  bottom_left := platform.Vertex{
    pos   = (transform * [?]f32{-1, -1, 0, 1}).xyz,
    color = color,
  }
  bottom_right := platform.Vertex{
    pos   = (transform * [?]f32{+1, -1, 0, 1}).xyz,
    color = color,
  }

  platform.add_vertex(top_right)
  platform.add_vertex(top_left)
  platform.add_vertex(bottom_left)

  platform.add_vertex(bottom_left)
  platform.add_vertex(bottom_right)
  platform.add_vertex(top_right)
}

draw_quad :: proc(x, y, size_x, size_y: f32, color: platform.Color) {

  transform : glm.mat4 = 1

  transform *= glm.mat4Translate({x, y, 0})
  transform *= glm.mat4Scale({size_x, size_y, 1})

  draw_quad_with_transform(transform, color)

}

grid_cells_x :: 20
grid_cells_y :: 20

snake_color :: platform.Color{255, 128, 64, 255}
fruit_color :: platform.Color{255, 255, 0, 255}
grid_color  :: platform.Color{16, 32, 64, 255}


snake := [grid_cells_x * grid_cells_y][2]i8{}
snake_length := 1

pos_y := f32(300)
pos_x := f32(300) 
current_time := f64(0)

draw_game :: proc() {
  linhe_thickness := f32(3)
  window_width, window_height := platform.get_render_size()

  width, height : f32
  x_offset, y_offset : f32
  if window_width > window_height {
    height = f32(window_height) - linhe_thickness
    x_offset = f32(window_width - window_height)/2
    width  = height + linhe_thickness
  } else {
    width = f32(window_width) - linhe_thickness
    y_offset = f32(window_height - window_width)/2
    height = width + linhe_thickness
  }

  cell_size := height / grid_cells_y

  { // draw snake
    for i in 0..<snake_length {
      part := snake[i]
      draw_quad(x_offset + f32(part.x) * cell_size, y_offset + f32(part.y) * cell_size, cell_size, cell_size, snake_color)
    }
  }
  { // draw fruit
    draw_quad(
      x_offset + cell_size * f32(fruit.x),
      y_offset + cell_size * f32(fruit.y),
      cell_size, cell_size, fruit_color,
    )
  }
  { // draw grid
    for i in f32(0)..=grid_cells_x {
      draw_quad(x_offset + cell_size * i, y_offset, linhe_thickness, f32(height), grid_color)
    }
    for i in f32(0)..=grid_cells_y {
      draw_quad(x_offset, y_offset + cell_size * i, f32(width), linhe_thickness, grid_color)
    }
  }
}

Move :: enum u8 {
  LEFT,
  RIGHT,
  UP,
  DOWN,
}

last_move := Move.RIGHT
current_move := last_move

fruit := [2]i8{0, 0}
update_paused := false

// TODO: passar todo o estado do jogo
update_game :: proc(move: Move) {

  // NOTE: melhor fazer isso somente uma vez, no init, mas to com preguiça
  rand.reset(u64(rand.int63()))

  move := move
  head := snake[0]
  { // cannot go 180
    if snake_length > 1 {
      if move == .UP && last_move == .DOWN do move = last_move
      if move == .DOWN && last_move == .UP do move = last_move
      if move == .LEFT && last_move == .RIGHT do move = last_move
      if move == .RIGHT && last_move == .LEFT do move = last_move
    }
  }
  { // move the head
    switch move {
    case .UP:    head.y += 1
    case .DOWN:  head.y -= 1
    case .LEFT:  head.x -= 1
    case .RIGHT: head.x += 1
    }

    if head.x >= grid_cells_x do head.x = 0
    if head.y >= grid_cells_y do head.y = 0
    if head.x < 0 do head.x = grid_cells_x-1
    if head.y < 0 do head.y = grid_cells_y-1
  }
  { // fruit
    if head.x == fruit.x && head.y == fruit.y {

      snake[snake_length] = snake[snake_length-1]
      snake_length += 1

      fruit_collides := true
      for fruit_collides {
        fruit.x = i8(rand.float32_range(0, grid_cells_x))
        fruit.y = i8(rand.float32_range(0, grid_cells_y))

        fruit_collides = false
        for i in 0..<snake_length {
          fruit_collides ||= fruit.x == snake[i].x && fruit.y == snake[i].y
        }
      }
    }
  }
  { // shift spots
    for part_index := snake_length-1; part_index > 0; part_index -= 1 {
      snake[part_index] = snake[part_index-1]
    }
    snake[0] = head
  }
  { // see if the head collides
    for part in snake[1:snake_length] {
      if head.x == part.x && head.y == part.y {
        lost = true
      }
    }
  }

  last_move = move
}

lost := false
update_cooldown := f64(0)

@export
step :: proc(dt: f64) -> bool {
  current_time += dt
  if !update_paused {
    update_cooldown += dt
  }

  if platform.is_key_pressed(.Escape) do exit = true

  if platform.is_key_down(.W) do current_move = .UP
  if platform.is_key_down(.S) do current_move = .DOWN
  if platform.is_key_down(.A) do current_move = .LEFT
  if platform.is_key_down(.D) do current_move = .RIGHT
  if platform.is_key_down(.P) do update_paused = !update_paused

  if update_cooldown >= .2 {
    update_cooldown = 0
    update_game(current_move)
  }

  platform.begin_drawing()
  {
    platform.clear_color(platform.f32color_to_u8color(.2, .4, .6, 1))

    draw_game()

  }
  platform.end_drawing(shader)

  return !exit
}

