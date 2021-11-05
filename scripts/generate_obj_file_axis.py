#!/bin/python

import sys

if (len(sys.argv)!=3):
  print("Usage: generate_obj_file_axis.py output_file axis")
  exit();

axis = int(sys.argv[2])

def get_index_cube(pos):
  return 1+pos[0]+pos[1]*17+pos[2]*17*17

def get_index_texture(pos):
  return 1+2
   
def generate_obj():  
  check_sides = [[0,1,0],[0,-1,0],[-1,0,0],[1,0,0],[0,0,1],[0,0,-1]];
  cube_variants = [
      [ 0, 0, 0],
      [ 1, 0, 0],
      [ 1, 0, 1],
      [ 0, 0, 1],
      [ 0, 1, 0],
      [ 1, 1, 0],
      [ 1, 1, 1],
      [ 0, 1, 1]
      # x-z 0,1,2,3
      # x-z 4,5,6,7
      # y-z 0,3,7,4
      # y-z 1,2,6,5
      # x-y 0,1,5,4
      # x-y 2,3,7,6
    ];
  
  v = "";
  vt = "";
  vn = "";
  f = "";
  
  s_i = 0;
    
  for y in range(5):
    for x in range(5):
      vt = vt + "vt {} {}\n".format(x/4, y/4);
  
  for side in check_sides:
    vn = vn + "vn {} {} {}\n".format(-side[0], side[1], side[2]);
  
  if (axis==1) or (axis==2):
    for y in range(17):
      v = v + "v {} {} {}\n".format(-0.5, 0.5-y/16, -0.5);
      v = v + "v {} {} {}\n".format(-0.5, 0.5-y/16,  0.5);
      v = v + "v {} {} {}\n".format( 0.5, 0.5-y/16,  0.5);
      v = v + "v {} {} {}\n".format( 0.5, 0.5-y/16, -0.5);
  if (axis==3) or (axis==4):
    for x in range(17):
      v = v + "v {} {} {}\n".format(-0.5+x/16, -0.5, -0.5);
      v = v + "v {} {} {}\n".format(-0.5+x/16, -0.5,  0.5);
      v = v + "v {} {} {}\n".format(-0.5+x/16,  0.5,  0.5);
      v = v + "v {} {} {}\n".format(-0.5+x/16,  0.5, -0.5);
  if (axis==5) or (axis==6):
    for z in range(17):
      v = v + "v {} {} {}\n".format(-0.5, -0.5, -0.5+z/16);
      v = v + "v {} {} {}\n".format(-0.5,  0.5, -0.5+z/16);
      v = v + "v {} {} {}\n".format( 0.5,  0.5, -0.5+z/16);
      v = v + "v {} {} {}\n".format( 0.5, -0.5, -0.5+z/16);
  
  for y in range(16):
    ti_xx = 22 + y%4 - y//4*5;
    ti_xy = 17 + y%4 - y//4*5;
    ti_yx = 21 + y%4 - y//4*5;
    ti_yy = 16 + y%4 - y//4*5;
    variants = []
    for variant in cube_variants:
      variants.append([variant[0]+x, variant[1], variant[2]]);
    
    if (axis==1):
      f = f + "usemtl yp\n";
      f = f + "s {}\n".format(s_i+0);
      f = f + "f {}/{}/{} {}/{}/{} {}/{}/{} {}/{}/{}\n".format(y*4+1, ti_yx, 1, y*4+2, ti_yy, 1, y*4+3, ti_xy, 1, y*4+4, ti_xx, 1);
      s_i = s_i + 1;
    if (axis==2):
      f = f + "usemtl yn\n";
      f = f + "s {}\n".format(s_i+0);
      f = f + "f {}/{}/{} {}/{}/{} {}/{}/{} {}/{}/{}\n".format(y*4+8, ti_xx, 2, y*4+7, ti_xy, 2, y*4+6, ti_yy, 2, y*4+5, ti_yx, 2);
      s_i = s_i + 1;
    
  for x in range(16):
    ti_xx = 21 + x%4 - x//4*5;
    ti_xy = 22 + x%4 - x//4*5;
    ti_yx = 16 + x%4 - x//4*5;
    ti_yy = 17 + x%4 - x//4*5;
    variants = []
    for variant in cube_variants:
      variants.append([variant[0]+x, variant[1], variant[2]]);
    
    if (axis==3):
      f = f + "usemtl xp\n";
      f = f + "s {}\n".format(s_i+0);
      f = f + "f {}/{}/{} {}/{}/{} {}/{}/{} {}/{}/{}\n".format(x*4+1, ti_xx, 3, x*4+2, ti_xy, 3, x*4+3, ti_yy, 3, x*4+4, ti_yx, 3);
      s_i = s_i + 1;
    if (axis==4):
      f = f + "usemtl xn\n";
      f = f + "s {}\n".format(s_i+0);
      f = f + "f {}/{}/{} {}/{}/{} {}/{}/{} {}/{}/{}\n".format(x*4+8, ti_yx, 4, x*4+7, ti_yy, 4, x*4+6, ti_xy, 4, x*4+5, ti_xx, 4);
      s_i = s_i + 1;
  
  for z in range(16):
    ti_xx = 22 + z%4 - z//4*5;
    ti_xy = 17 + z%4 - z//4*5;
    ti_yx = 21 + z%4 - z//4*5;
    ti_yy = 16 + z%4 - z//4*5;
    variants = []
    for variant in cube_variants:
      variants.append([variant[0]+x, variant[1], variant[2]]);
    
    if (axis==5):
      f = f + "usemtl zp\n";
      f = f + "s {}\n".format(s_i+0);
      f = f + "f {}/{}/{} {}/{}/{} {}/{}/{} {}/{}/{}\n".format(z*4+1, ti_xx, 5, z*4+2, ti_xy, 5, z*4+3, ti_yy, 5, z*4+4, ti_yx, 5);
      s_i = s_i + 1;
    if (axis==6):
      f = f + "usemtl zn\n";
      f = f + "s {}\n".format(s_i+0);
      f = f + "f {}/{}/{} {}/{}/{} {}/{}/{} {}/{}/{}\n".format(z*4+8, ti_yx, 6, z*4+7, ti_yy, 6, z*4+6, ti_xy, 6, z*4+5, ti_xx, 6);
      s_i = s_i + 1;
    
  
  
  node_obj = "# mesh generated\n";
  node_obj = node_obj + "o generated\n\n";
  
  node_obj = node_obj + v;
  node_obj = node_obj + "\n";
  node_obj = node_obj + vt;
  node_obj = node_obj + "\n";
  node_obj = node_obj + vn;
  node_obj = node_obj + "\n";
  node_obj = node_obj + "g generated\n";
  node_obj = node_obj + f;
  node_obj = node_obj + "\n\n";
  return node_obj;

node_obj = generate_obj();

output_file = open(sys.argv[1], "w");
output_file.write(node_obj);
output_file.close();

