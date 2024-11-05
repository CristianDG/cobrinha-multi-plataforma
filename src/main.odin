package main

import "game"
import "core:fmt"
import "base:runtime"

HOT_RELOAD :: #config(HOT_RELOAD, false)

import "platform_functions"

main :: proc() {
  when ODIN_OS != .JS {
    main_native()
  }
}

main_native :: proc() {
  when HOT_RELOAD {
    main_hot_reload()
  } else {
    main_static()
  }
}

main_static :: proc() {
  for {
    if !game.step(.3) do break
  }
}
