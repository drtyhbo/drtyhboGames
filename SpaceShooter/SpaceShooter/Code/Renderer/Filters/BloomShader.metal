//
//  MinShader.metal
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 getColorAtPoint(texture2d<float, access::read> texture, uint2 point);
float4 calculateBlur(texture2d<float, access::read> texture, uint2 point, float2 direction);

float4 getColorAtPoint(texture2d<float, access::read> texture, uint2 point) {
    float4 color = texture.read(point);
    float intensity = dot(color.rgb, float3(0.299, 0.587, 0.114));
    return intensity > 0.2 ? color : float4(0);
}

float4 calculateBlur(texture2d<float, access::read> texture, uint2 point, float2 direction) {
    float4 sum = float4(0);

    float hstep = direction[0];
    float vstep = direction[1];

    sum += getColorAtPoint(texture, uint2(point[0] - 4 * hstep, point[1] - 4 * vstep)) * 0.0162162162;
    sum += getColorAtPoint(texture, uint2(point[0] - 3 * hstep, point[1] - 3 * vstep)) * 0.0540540541;
    sum += getColorAtPoint(texture, uint2(point[0] - 2 * hstep, point[1] - 2 * vstep)) * 0.1216216216;
    sum += getColorAtPoint(texture, uint2(point[0] - 1 * hstep, point[1] - 1 * vstep)) * 0.1945945946;

    sum += getColorAtPoint(texture, point) * 0.2270270270;

    sum += getColorAtPoint(texture, uint2(point[0] + 1 * hstep, point[1] + 1 * vstep)) * 0.1945945946;
    sum += getColorAtPoint(texture, uint2(point[0] + 2 * hstep, point[1] + 2 * vstep)) * 0.1216216216;
    sum += getColorAtPoint(texture, uint2(point[0] + 3 * hstep, point[1] + 3 * vstep)) * 0.0540540541;
    sum += getColorAtPoint(texture, uint2(point[0] + 4 * hstep, point[1] + 4 * vstep)) * 0.0162162162;

    return sum;
}

kernel void bloom_shader(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]]) {
    float4 inputColor = inTexture.read(gid);

    float4 sum = float4(0);
    sum += calculateBlur(inTexture, gid, float2(1, 0));
    sum += calculateBlur(inTexture, gid, float2(0, 1));

    outTexture.write(float4(inputColor.r * (1 - sum.a) + sum.r * sum.a, inputColor.g * (1 - sum.a) + sum.g * sum.a, inputColor.b * (1 - sum.a) + sum.b * sum.a, 1), gid);
}