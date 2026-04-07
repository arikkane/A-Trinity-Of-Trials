shader_type canvas_item;

uniform int mode = 0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}
//changes shader values based on color blind setting
void fragment() {
	vec4 color = texture(SCREEN_TEXTURE,SCREEN_UV);
	//mode for Protanopia (Red Weak)
	if(mode == 1){
		float r = color.r * .56667 + color.g * .43333;
		float g = color.r * .55833 + color.g * .44167;
		float b = color.g * .24167 + color.b * .75833;
		COLOR = vec4(r,g,b,color.a);
	}
	// mode for Deuteranopia (Green Weak)
	else if(mode == 2){
		float r = color.r * .625 + color.g * .375;
		float g = color.r * .7 + color.g * .3;
		float b = color .g * .475 + color.b *.7;
		COLOR = vec4(r,g,b,color.a);
	}
	//mode for Tritanopia (Blue Weak)
	else if(mode == 3){
		float r = color.r * .95 + color.g * .05;
		float g = color.g * .43333 + color.b * .56667;
		float b = color.g * .475 + color.b * .525;
		COLOR = vec4(r,g,b,color.a);
	}
	else{
		COLOR = color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
