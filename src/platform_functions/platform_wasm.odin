#+build js
package platform_functions

import "core:fmt"
import "base:runtime"
foreign import platform "platform_functions"

@(default_calling_convention="contextless")
foreign platform {
  // get_platform_name :: proc "contextless" () ---
}

get_platform_name :: proc "contextless" () {
  context = runtime.default_context()
  fmt.println("wasm")
}

