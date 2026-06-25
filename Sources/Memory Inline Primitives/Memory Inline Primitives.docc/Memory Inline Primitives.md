# ``Memory_Inline_Primitives``

@Metadata {
    @DisplayName("Memory Inline Primitives")
    @TitleHeading("Swift Primitives")
}

An element-free, fixed-capacity raw byte region stored inline. `Memory.Inline<n>` lays exactly `n` bytes out directly in the value — no heap allocation — and exposes them as a `base` address plus a byte `capacity`, the substrate for inline pool and arena allocators.

## Topics

### The inline region

- ``Memory/Inline``
```
