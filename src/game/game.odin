package game

import "core:fmt"
import platform "../platform_functions"


counter := 0

@export
step :: proc(dt: f64) -> bool {
  counter += 1

  if counter == 1 do platform.get_platform_name()

  if counter == 500 do return false
  return true
}

