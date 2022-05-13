// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function CreateCellsArray(){
	var Array = array_create(room_width/32 - 1);
	
	for (var i = 0; i < array_length(Array); i++){
		Array[i] = array_create(room_height/32 - 1);
	}
	global.cellsArray = Array;
}

function FillTheMapArray(){
	for (var i = 0; i < array_length(global.cellsArray); i++){
		for (var j = 0; j < array_length(global.cellsArray[0]); j++){
			var b = position_meeting(i*32+16, j*32+16, obj_wallObj);
			if (b == 1){
				var q = i;
				var p = j;
				if (i != 0) q = i-1;
					global.cellsArray[q][j] = b;
				if (j != 0) p = j-1;
					global.cellsArray[i][p] = b;
				if (i != 0 && j != 0)
					global.cellsArray[q][p] = b;
			}
			global.cellsArray[i][j] = b;
		}
	}
}

function ShowArray(array = global.cellsArray){
	var line = "";
	for (var i = 0; i < array_length(array[0]); i++){
		for (var j = 0; j < array_length(array); j++){
			line += string(array[j][i]);
		}
		show_debug_message(line);
		line = "";
	}
}

function FindAdgesOnMapArray(array = global.cellsArray){
	for (var i = 1; i < array_length(array)-1; i++){
		for (var j = 1; j < array_length(array[0])-1; j++){
			if (array[i][j] == 1 && TouchingAdgesAmount(i,j) == 2){
				if (array[i-1][j] == 0 || array[i-1][j] == 2){
					array[i-1][j] = 2;
					var obj = instance_create_depth((i+1)*32,(j+1)*32, 1, obj_wallObj_invisible_right);
					obj.image_angle += 180;
					obj.y += 1;
					obj.visible = false;
				}
				if (array[i+1][j] == 0 || array[i+1][j] == 2){
					array[i+1][j] = 2;
					var obj = instance_create_depth((i+1)*32,(j+1)*32, 1, obj_wallObj_invisible_right);
					obj.visible = false;
				}
				if (array[i][j-1] == 0 || array[i][j-1] == 2){
					array[i][j-1] = 2;
					var obj = instance_create_depth((i+1)*32,(j+1)*32, 1, obj_wallObj_invisible_right);
					obj.image_angle += 90;
					obj.visible = false;
				}
				if (array[i][j+1] == 0 || array[i][j+1] == 2){
					array[i][j+1] = 2;
					var obj = instance_create_depth((i+1)*32,(j+1)*32, 1, obj_wallObj_invisible_right);
					obj.image_angle -= 90;
					obj.x += 1;
					obj.visible = false;
				}
			}
			
		}
	}
}

function TouchingAdgesAmount(i, j, array = global.cellsArray){
	var num = 0;
	if (array[i-1][j] == 1)
		num += 1;
	if (array[i+1][j] == 1)
		num += 1;
	if (array[i][j-1] == 1)
		num += 1;
	if (array[i][j+1] == 1)
		num += 1;
		
	return num;
}

function MakeVertixArray(array = global.cellsArray){
	var vArray = array_create(0);
	array_push(vArray, new Vector2(obj_start.x+32, obj_start.y+32));
	for (var i = 0; i < array_length(array); i++){
		for (var j = 0; j < array_length(array[0]); j++){
			if (array[i][j] == 2){
				array_push(vArray, new Vector2((i+1)*32,(j+1)*32));
			}
		}
	}
	array_push(vArray, new Vector2(obj_finish.x+32, obj_finish.y+32));
	
	return vArray;
}

function new_DijkstraAlgo(vArray, nArray){
	var vDist = array_create(array_length(vArray), infinity);
	var usedV = array_create(array_length(vArray), false);
	var pArray = array_create(array_length(vArray), 0);
	vDist[0] = 0;
	for (var i = 0; i < array_length(vDist); i++){
		var v = noone;
		for (var j = 0; j < array_length(vDist); j++){
			if (!usedV[j]) && (v == noone || vDist[j] < vDist[v]){
				v = j;
			}
		}
		usedV[v] = true;
		
		for (var k = 0; k < array_length(nArray[v].vArray); k++){
			var curObj = nArray[v].vArray[k];
			if (usedV[curObj.obj_id]) continue;
			
			var dist = point_distance(vArray[v].x, vArray[v].y, curObj.x, curObj.y);
			if ((dist + vDist[v]) < vDist[curObj.obj_id]){
				vDist[curObj.obj_id] = dist + vDist[v];
				pArray[curObj.obj_id] = v;
			}
		}
	}
	return pArray;
}


function GetAPath(pArray, vArray){
	var seq = array_create(0);
	var finishID = array_length(pArray) - 1;
	var num = pArray[finishID];
	array_push(seq, finishID);
	array_push(seq, num);
	var i = 0;
	while (num != 0){
		num = pArray[num];
		array_push(seq, num);
		i++;
		if (i > finishID + 2){
			show_debug_message("SOMETHING WENT WRONG");
			break;	
		}
	}
	var returnSeq = array_create(array_length(seq));
	for (var i = 0; i < array_length(returnSeq); i++){
		returnSeq[i] = vArray[seq[i]];
	}
	
	return returnSeq;
}

function Print1DMArray(array){
	for (var i = 0; i < array_length(array); i++){
		show_debug_message(array[i]);
	}
	show_debug_message("=========")
}


function DijkstraAlgoPrep(){
	FillTheMapArray();	
	FindAdgesOnMapArray();
}

function CreateNodeArray(vArray){
	var nArray = array_create(0);
	for (var i = 0; i < array_length(vArray); i++){
		array_push(nArray, new NodeMain(vArray[i].x, vArray[i].y, i));
		for (var j = 0; j < array_length(vArray); j++){
			if (i == j) continue;
			if (collision_line(vArray[i].x, vArray[i].y, vArray[j].x, vArray[j].y, obj_wallObj, false, true) ||
				collision_line(vArray[i].x, vArray[i].y, vArray[j].x, vArray[j].y, obj_wallObj_invisible_right, false, true)){
					continue;
				}
			nArray[i].Add(new Node(vArray[j].x, vArray[j].y, j));
		}
	}
	
	return nArray;
}

function PathFindingWithDijkstraAlgo(){
	
	var vArray = MakeVertixArray();
	var nArray = CreateNodeArray(vArray);
	
	var pArray = new_DijkstraAlgo(vArray, nArray);
	var path = GetAPath(pArray, vArray);
	
	return path;
}



