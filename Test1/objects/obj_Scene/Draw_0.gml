/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
var path = PathFindingWithDiikstraAlgo();
for (var i = 0; i < array_length(path) - 1; i++){
		draw_line_color(path[i].x, path[i].y, path[i+1].x, path[i+1].y, c_red, c_red);
	}

