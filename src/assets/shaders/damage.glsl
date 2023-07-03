vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    if (pixel.a > 0.0) {
        pixel.r = 1.0;
        pixel.g = 0.0;
        pixel.b = 0.0;
    }
    return pixel * color;
}