shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;
//uniform vec2 numberOfTiles = vec2(15, 8.4375);
uniform vec2 numberOfTiles = vec2(60, 33.75);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 positionInSquare = UV * numberOfTiles;
	vec2 frac =- fract(positionInSquare);
	vec2 direction = abs(frac + 0.5); //change + to - for a different effect
	
	if((direction.x + UV.x) + (direction.y + UV.y) >= progress * 3.0) {
		if (!reverse) {
			discard;
		}
	}
		
	else if (reverse) {
		discard;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
