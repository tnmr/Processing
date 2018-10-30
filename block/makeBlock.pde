class makeBlock {
  float box_vertical, box_horaizontal, box_height;   //ブロック縦、横、高さ
  float uneven_length, uneven_radius, uneven_interval;   //凹凸高さ、半径、間隔
  float vertical_number, height_number, horaizontal_number;
  float boxPosX, boxPosY, boxPosZ;
  float magnification;   //倍率
  float layer;   //何層目か

  makeBlock( float _horaizontal_number, float _height_number, float _vertical_number, float _layer, float _boxPosX, float _boxPosY, float _boxPosZ ) {
    vertical_number = _vertical_number;
    height_number = _height_number;
    horaizontal_number = _horaizontal_number;
    layer = _layer;
    boxPosX = _boxPosX;
    boxPosY = _boxPosY;
    boxPosZ = _boxPosZ;
    
    magnification = 10;
    box_vertical = (7.925 * magnification) * vertical_number;   //ブロック縦
    box_horaizontal = (7.925 * magnification) * horaizontal_number;   //ブロック横
    box_height = (9.6 * magnification) * height_number;   //ブロック高さ
    uneven_length = 1.7 * magnification;   //凹凸高さ
    uneven_radius = 2.5 * magnification;   //凹凸半径
    uneven_interval = 8.0 * magnification;   //凹凸間隔
  }

  void make() {
    translate( boxPosX, boxPosY, boxPosZ );
    translate( 0, -box_height/2 - (box_height * layer), 0 );
    noStroke();
    box( box_horaizontal, box_height, box_vertical );
    translate( -box_horaizontal/2, -(box_height/2+uneven_length/2), -box_vertical/2 );
    for ( int x=0; x<horaizontal_number; x++ ) {
      for ( int y=0; y<vertical_number; y++ ) {
        pushMatrix();
        translate( ( (box_horaizontal - (uneven_interval*(horaizontal_number-1)))/2 ) + uneven_interval*x, 0, ( (box_vertical - (uneven_interval*(vertical_number-1)))/2 ) + uneven_interval*y );
        pillar( uneven_length, uneven_radius, uneven_radius );
        popMatrix();
      }
    }
  }

  void pillar(float len, float radius1, float radius2) {
    float x, y, z;
    pushMatrix();
    //上面の作成
    beginShape(TRIANGLE_FAN);
    y = -len / 2;
    vertex(0, y, 0);
    for (int deg = 0; deg <= 360; deg = deg + 10) {
      x = cos(radians(deg)) * radius1;
      z = sin(radians(deg)) * radius1;
      vertex(x, y, z);
    }
    endShape();              //底面の作成
    beginShape(TRIANGLE_FAN);
    y = len / 2;
    vertex(0, y, 0);
    for (int deg = 0; deg <= 360; deg = deg + 10) {
      x = cos(radians(deg)) * radius2;
      z = sin(radians(deg)) * radius2;
      vertex(x, y, z);
    }
    endShape();
    //側面の作成
    beginShape(TRIANGLE_STRIP);
    for (int deg =0; deg <= 360; deg = deg + 5) {
      x = cos(radians(deg)) * radius1;
      y = -len / 2;
      z = sin(radians(deg)) * radius1;
      vertex(x, y, z);
      x = cos(radians(deg)) * radius2;
      y = len / 2;
      z = sin(radians(deg)) * radius2;
      vertex(x, y, z);
    }
    endShape();
    popMatrix();
  }
}

