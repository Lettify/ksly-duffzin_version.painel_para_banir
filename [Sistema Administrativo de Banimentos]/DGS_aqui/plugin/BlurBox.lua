BlurBoxGlobalScreenSource = false
local blurBoxShader 

function dgsCreateBlurBox()
	if not isElement(BlurBoxGlobalScreenSource) then
		BlurBoxGlobalScreenSource = dxCreateScreenSource(sW,sH)
	end
	local shader = dxCreateShader(blurBoxShader)
	dgsSetData(shader,"asPlugin","dgs-dxblurbox")
	dxSetShaderValue(shader,"screenSource",BlurBoxGlobalScreenSource)
	triggerEvent("onDgsPluginCreate",shader,sourceResource)
	return shader
end

function dgsBlurBoxRender(blurBox,x,y,w,h,postGUI)
	dxUpdateScreenSource(BlurBoxGlobalScreenSource,true)
	dxDrawImageSection(x,y,w,h,x,y,w,h,blurBox,0,0,0,0xFFFFFFFF,postGUI or false)
end

----------------Shader
blurBoxShader = [[
texture screenSource;
float brightness = 1;

sampler2D Sampler0 = sampler_state
{
    Texture         = screenSource;
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

float4 PixelShaderFunction(float2 tex : TEXCOORD0, float4 diffuse : COLOR0 ) : COLOR0
{
    float4 Color = 0;
    float4 Texel = tex2D(Sampler0,tex);
    for(int i = -3; i <= 3; i++)
		for(int j = -3; j <= 3; j++)
			Color += tex2D(Sampler0,tex+float2(i*ddx(tex.x),j*ddy(tex.y))) *(1.0/49.0)*brightness;
    return Color*diffuse;
}

technique fxBlur
{
    pass P0
    {
        PixelShader = compile ps_2_a PixelShaderFunction();
    }
}
]]