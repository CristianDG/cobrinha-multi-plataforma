package main

import "game"
import "core:fmt"

HOT_RELOAD :: #config(HOT_RELOAD, false)

main :: proc() {
  when ODIN_OS == .JS {

  } else{
    when HOT_RELOAD {
      main_hot_reload()
    } else {
      main_static()
    }
  }
  fmt.println(ODIN_OS)
}

main_static :: proc() {
  for {
    should_close := game.step(.3)
    if should_close do break
  }
}
