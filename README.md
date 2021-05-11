# LÖWR:
[LöVR](lovr.org) bindings for the [Wu programming language](https://github.com/wu-lang/wu).

## Example:
```go
import lowr

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
- Needing to add "nil" for every non-used argument.
	This is due to a Wu bug. 
