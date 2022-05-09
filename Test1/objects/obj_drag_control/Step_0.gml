/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if (mouse_check_button_pressed(mb_left)) {
    var lowest_depth = 999999;
    var lowest_id = noone;
    with (obj_drag_parent) {
        if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            if (depth < lowest_depth) {
                lowest_depth = depth;
                lowest_id = id;
            }
        }
    }
    if (lowest_id != noone) {
        lowest_id.draggable = true;
    }
}

if (mouse_check_button_released(mb_left)) {
    with (obj_drag_parent) {
        draggable = false;
    }
}
