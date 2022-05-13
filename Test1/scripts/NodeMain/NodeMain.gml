// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function NodeMain(_x, _y, _id) constructor{
	x = _x;
	y = _y;
	obj_id = _id;
	vArray = array_create(0);
	Add = function (vec2){
		array_push(vArray, vec2);
	}
}
