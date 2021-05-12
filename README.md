
# LÖWR:
[LöVR](http://lovr.org) bindings for the [Wu programming language](https://github.com/wu-lang/wu).

## Example:
```go
import libs { lowr }

timer: float = 0
update: fun(delta: float) {
	timer += delta
}

draw: fun {
	lowr graphics cube("fill", 0, 1.7, -1, .5, timer, nil, nil, nil)
}

lowr setUpdate(update)
lowr setDraw(draw)
```

## Main differences:
As Wu forbids the patching of external libraries, you will need to use the "`set<Callback>(fun)`" functions provided by this binding.

## How to install:
Add `lowr = "darltrash/lowr"` to your `wu.toml` file anywhere behind `[dependencies]` and `wu build` will manage everything for you instantly.
```ini
# It should look like this

[dependencies]
lowr = "darltrash/lowr"
```

## Pro-Tips:
### At Build:
- Delete the `lovrapi.lua` and `generate.lua` files since they arent needed for normal usage
### At Runtime:
- Delete all generated lua files from the repo except `init.lua`, since `init.lua` can mirror LöVR alone at runtime.

## Regenerate bindings:
You will need:
- LuaJIT
- LöVR

Steps:
- Clone the LöVR docs
- Clone LÖWR
- Run the `api/` folder from the LöVR docs with LöVR
- Remove the `lovrapi.lua` file from LÖWR
- Copy the generated `init.file` inside `api/` onto LÖWR with the name `lovrapi.lua`
- Run `generate.lua` with LuaJIT

Done!

## Known issues:
- Structs/Objects like `vec3`s or `mat4`s cannot be initialized with data, Ex: `vec3(10, 30, 20)`.
	This is due to LöVR's docs not specifying the input and return values of `newVec3()` nor `vec3()`
- Needing to add `nil` for every non-used argument.
	This is due to a Wu bug. 
- Naming the LÖWR binding "lovr" will break things. 
	This is due to LöVR being `require()`able

## License
(C) 2021 Nelson "darltrash" Lopez

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
 This notice may not be removed or altered from any source distribution.
