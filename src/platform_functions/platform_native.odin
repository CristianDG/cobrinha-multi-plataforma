#+build !js
package platform_functions
// FIXME: definir platform_functions_native e platform_functions_wasm além de
//        encontrar uma forma de usar funções exportadas daqui no módulo wasm

import "core:fmt"
import "base:runtime"

foreign import platform "bin:native/platform_functions.so"

@export get_platform_name :: proc "contextless" (r, g, b: u8) {
  context = runtime.default_context()
  fmt.println("native")
}

