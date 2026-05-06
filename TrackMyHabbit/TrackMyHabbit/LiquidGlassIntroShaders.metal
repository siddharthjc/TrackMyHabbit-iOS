//
//  LiquidGlassIntroShaders.metal
//  TrackMyHabbit
//
//  Refractive liquid-glass stitchable shader adapted from the Wabi-Intro sample
//  (https://github.com/sforsethi/Wabi-Intro). Renamed entry point for this app.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 tmhLiquidGlass(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 glassCenter,
    float glassRadius,
    float refraction,
    float shadowBlur,
    float time
) {
    float2 safePosition = clamp(position, float2(1.0), size - float2(1.0));
    half4 originalColor = layer.sample(safePosition);

    float2 toCenter = position - glassCenter;
    float dist = length(toCenter);
    float normalizedDist = dist / max(glassRadius, 1.0);
    float2 direction = toCenter / max(dist, 1.0);

    float shadowOffset = shadowBlur * 0.36;
    float2 shadowCenter = glassCenter + float2(shadowOffset, shadowOffset);
    float shadowDist = length(position - shadowCenter);
    float shadowRadius = glassRadius + shadowBlur;

    half4 result = originalColor;

    if (normalizedDist > 1.0) {
        if (shadowDist < shadowRadius) {
            float shadowFalloff = (shadowDist - glassRadius) / max(shadowBlur, 1.0);
            float shadowStrength = smoothstep(1.0, 0.0, shadowFalloff);
            result.rgb = mix(result.rgb, half3(0.0), half(shadowStrength * 0.055));
        }

        return result;
    }

    float falloff = 1.0 - normalizedDist * normalizedDist;
    float edgeFalloff = smoothstep(0.42, 1.0, normalizedDist);
    float2 refractedOffset = toCenter * falloff * refraction;

    float edgeDistanceToScreen = min(min(position.x, size.x - position.x), min(position.y, size.y - position.y));
    float screenEdgeFade = smoothstep(0.0, 36.0, edgeDistanceToScreen);
    float chromaticStrength = edgeFalloff * screenEdgeFade * 0.18;

    float2 refractedPosition = clamp(position - refractedOffset, float2(1.0), size - float2(1.0));
    float2 redPosition = clamp(position - refractedOffset * (1.0 + chromaticStrength), float2(1.0), size - float2(1.0));
    float2 bluePosition = clamp(position - refractedOffset * (1.0 - chromaticStrength), float2(1.0), size - float2(1.0));

    half4 refractedColor = layer.sample(refractedPosition);
    half4 redSample = layer.sample(redPosition);
    half4 blueSample = layer.sample(bluePosition);
    refractedColor.r = redSample.r;
    refractedColor.b = blueSample.b;

    result = refractedColor;
    float darkAmount = 1.0 - clamp(float(dot(result.rgb, half3(0.299, 0.587, 0.114))), 0.0, 1.0);

    float horizontalSide = dot(direction, normalize(float2(1.0, 0.0)));
    half3 manualChroma = mix(
        half3(0.05, 0.22, 1.0),
        half3(1.0, 0.08, 0.03),
        half(horizontalSide * 0.5 + 0.5)
    );

    float manualChromaMask = edgeFalloff * screenEdgeFade * darkAmount;
    result.rgb += manualChroma * half(manualChromaMask * 0.18);

    float edgeThickness = 0.045 * min(size.x, size.y);
    float edgeDistance = abs(dist - glassRadius);
    float edgeFade = smoothstep(edgeThickness, 0.0, edgeDistance);

    float2 lightDir = normalize(float2(-0.5, -0.8));
    float rimBias = clamp(dot(direction, lightDir), 0.0, 1.0);
    half3 highlightColor = half3(1.06, 1.08, 1.14);
    result.rgb += half(edgeFade * rimBias * 0.28) * highlightColor;

    float lowerOcclusion = smoothstep(0.10, 0.92, normalizedDist) * smoothstep(-0.25, 0.92, direction.y);
    result.rgb = mix(result.rgb, half3(0.0), half(lowerOcclusion * 0.035));

    float innerSheen = (1.0 - smoothstep(0.0, 0.64, normalizedDist)) * 0.12;
    float caustic = (sin(position.x * 0.028 + position.y * 0.018 + time * 1.6) * 0.5 + 0.5) * edgeFade;
    result.rgb = mix(result.rgb, half3(1.0), half(innerSheen + caustic * 0.035));

    float darkAmount2 = 1.0 - clamp(float(dot(result.rgb, half3(0.299, 0.587, 0.114))), 0.0, 1.0);

    float leftFringe = smoothstep(-0.85, -0.15, direction.x);
    float rightFringe = smoothstep(0.15, 0.85, direction.x);

    half3 blueFringe = half3(0.0, 0.35, 1.0) * half(leftFringe);
    half3 redFringe = half3(1.0, 0.12, 0.0) * half(rightFringe);

    float fringeMask = edgeFade * darkAmount2;

    result.rgb += (blueFringe + redFringe) * half(fringeMask * 4.0);
    return result;
}
