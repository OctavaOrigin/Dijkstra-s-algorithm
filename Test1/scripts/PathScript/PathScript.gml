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
				if (array[i-1][j] == 0)
					array[i-1][j] = 2;
				if (array[i+1][j] == 0)
					array[i+1][j] = 2
				if (array[i][j-1] == 0)
					array[i][j-1] = 2;
				if (array[i][j+1] == 0)
					array[i][j+1] = 2;
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

/*
function DeikstraAlgorithm(array){
	var S = array_create(0);
	array_push(S, 0);
	var D = array_create(array_length(array), infinity);
	D[0] = 0;
	var currentID = 0;
	var minDist = infinity;
	var minDistID = 0;
	var noCheck = false;
	var pArray = array_create(array_length(array), 0);
	for (var i = 0; i < array_length(array)-1; i++){
		for (var j = 0; j < array_length(D); j++){
			noCheck = false;
			for (var l = 0; l < array_length(S); l++){
				if (S[l] == j){
					noCheck = true;
				}
			}
			if (!noCheck){
				if (!collision_line(array[currentID].x, array[currentID].y,array[j].x, array[j].y, obj_wallObj, false, true)){
					var dist = point_distance(array[currentID].x, array[currentID].y,array[j].x, array[j].y);
					dist += D[currentID];
					if (dist < D[j]){
						D[j] = dist;
						pArray[j] = currentID;
					}
				}
				if (D[j] < minDist){
					minDist = D[j];
					minDistID = j;
				}
			}
		}
		currentID = minDistID;
		array_push(S, currentID);
		minDist = infinity;
	}
	
	return pArray;
}
*/

function new_DijkstraAlgo(vArray){
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
		for (var l = 0; l < array_length(vDist); l++){
			if (usedV[l]) continue;
			if (collision_line(vArray[v].x, vArray[v].y,vArray[l].x, vArray[l].y, obj_wallObj, false, true))
				continue;
			var dist = point_distance(vArray[v].x, vArray[v].y,vArray[l].x, vArray[l].y);
			if ((dist + vDist[v]) < vDist[l]){
				vDist[l] = dist + vDist[v];
				pArray[l] = v;
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





function PathFindingWithDijkstraAlgo(){
	FillTheMapArray();	

	FindAdgesOnMapArray();
	var vArray = MakeVertixArray();
	
	//var pArray = DeikstraAlgorithm(vArray);
	var pArray = new_DijkstraAlgo(vArray);
	var path = GetAPath(pArray, vArray);
	
	return path;
}



