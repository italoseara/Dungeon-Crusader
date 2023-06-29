extern number radius;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    number distance = distance(screen_coords, vec2(love_ScreenSize.x / 2, love_ScreenSize.y / 2));
    number alpha = distance / radius;

    return vec4(0, 0, 0, alpha);
}