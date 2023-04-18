//
//  test.metal
//  metalstudy
//
//  Created by 蓬莱直哉 on 2023/04/18.
//

#include <metal_stdlib>
using namespace metal;

struct MyVertex {
    float4 position [[position]];
    float4 color;
};

vertex MyVertex myVertexShader(
                               const device float4 *position [[buffer(0)]],
                               const device float4 *color[[buffer(1)]],
                               const uint vid [[vertex_id]] ){
                                   MyVertex v;
                                   v.position = position[vid];
                                   v.color = color[vid];
                                   return v;
                                   
                               }

fragment float4 myFragmentShader(MyVertex vertexIn[[stage_in]]){
    return vertexIn.color;
}

