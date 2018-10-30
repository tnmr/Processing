import java.util.Arrays;

makeBlock selectBlock;
makeBlock mb;

ArrayList blocks;
float rotX, rotY;
int flag, sizeFlag;
PVector mousePos;
float add_vertical, add_height, add_horaizontal, add_layer;
float block_number;

void setup() {
  size( 800, 800, P3D );

  flag = 0;
  blocks = new ArrayList();
  blocks.add( new makeBlock( 21, 1/(9.6 * 10), 21, 0, 0, 0, 0 ) );
}

void draw() {
  background( 255 );
  //camera( 1160-300, -1960+1000, 1730-500, 890-100, -1200+500, 1200-100, 0, 1, 0 );
  camera( width/2.0 + 600, height/2.0 - 1000, (height/2.0) / tan(PI*30.0 / 180.0) + 1400, width/2.0-300, height/2.0, 0-300, 0, 1, 0 );
  pointLight( 255, 255, 255, width/2 + 600, height/2 -500, (height/2.0) / tan(PI*30.0 / 180.0) + 1400 );

  //値の範囲指定
  if ( sizeFlag < 0 ) {
    sizeFlag = 3;
  } else if ( sizeFlag > 3 ) {
    sizeFlag = 0;
  }
  if ( add_horaizontal <= 0 ) {
    add_horaizontal = 1;
  }
  if ( add_height <= 0 ) {
    add_height = 1;
  }
  if ( add_vertical <= 0 ) {
    add_vertical = 1;
  }
  if ( block_number < 1 ) {
    block_number = blocks.size()-1;
  } else if ( block_number >= blocks.size() ) {
    block_number = 1;
  }

  // カーソル位置に対応する床面上の座標を計算
  PVector floorPos = new PVector( width/2, height/2, 0 ); // 床の座標
  PVector floorDir = new PVector( 0, -1, 0 );      // 床の法線ベクトル
  mousePos = getUnProjectedPointOnFloor( mouseX, mouseY, floorPos, floorDir );

  // 床
  perspective();
  pushMatrix();
  translate( floorPos.x, floorPos.y, floorPos.z );
  //rotateX( rotY - 0.5 );
  //rotateY( rotX - 0.5 );  
  //fill(255);
  //selectBlock.make( 30, 1, 30 );
  fill( 255 );
  mb = (makeBlock)blocks.get(0);
  mb.make();
  popMatrix();


  for ( int i = blocks.size ()-1; i >= 1; i-- ) {
    if ( block_number == i && flag == 2 ) {
      fill( 255, 0, 0 );
    } else {
      fill( 255 );
    }
    pushMatrix();
    mb = (makeBlock)blocks.get(i);
    mb.make();
    popMatrix();
  }

  // カーソル位置に立方体を描画  
  if ( flag == 1 ) {
    pushMatrix();
    //translate( mousePos.x, mousePos.y, mousePos.z );
    makeBlock selectBlock = new makeBlock( add_horaizontal, add_height, add_vertical, add_layer, mousePos.x, mousePos.y, mousePos.z );
    selectBlock.make();
    popMatrix();
  }

  /*
  ortho( 0, 100, 0, 50 );
  pushMatrix();
  ellipse( 0, 0, 150, 150 );
  popMatrix();
  */

  //println( mousePos );
  println( blocks.size() );
}

void keyPressed() {
  if ( flag == 1 ) {
    if ( keyCode == LEFT ) {
      sizeFlag--;
    } else if ( keyCode == RIGHT ) {
      sizeFlag++;
    }

    if ( sizeFlag == 0 ) {
      if ( keyCode == UP ) {
        add_horaizontal++;
      } else if ( keyCode == DOWN ) {
        add_horaizontal--;
      }
    }
    if ( sizeFlag == 1 ) {
      if ( keyCode == UP ) {
        add_height++;
      } else if ( keyCode == DOWN ) {
        add_height--;
      }
    }
    if ( sizeFlag == 2 ) {
      if ( keyCode == UP ) {
        add_vertical++;
      } else if ( keyCode == DOWN ) {
        add_vertical--;
      }
    }
    if ( sizeFlag == 3 ) {
      if ( keyCode == UP ) {
        add_layer++;
      } else if ( keyCode == DOWN ) {
        add_layer--;
      }
    }
  }

  if ( flag == 2 ) {
    if ( keyCode == UP ) {
      block_number++;
    } 
    if ( keyCode == DOWN ) {
      block_number--;
    }
  }    

  if ( key == 'a' || key == 'A' ) {
    flag = 1;
  } else if ( key == 'd' || key == 'D' ) {
    flag = 2;
  } else if ( key == 'e' || key == 'E' ) {
    flag = 0;
  }

  if ( keyCode == ENTER ) {
    if ( flag == 1 ) {
      flag = 0;
      pushMatrix();
      blocks.add( new makeBlock( add_horaizontal, add_height, add_vertical, add_layer, mousePos.x, mousePos.y, mousePos.z ) );
      popMatrix();
    } else if ( flag == 2 ) {
      flag = 0;
      for (int i = blocks.size ()-1; i >= 0; i--) { 
        mb = (makeBlock)blocks.get(i);
        if ( block_number == i ) {
          blocks.remove( i );
        }
      }
    }
  }
}

// 画面座標に対応する床面上の座標を計算する関数
PVector getUnProjectedPointOnFloor(float screen_x, float screen_y, PVector floorPosition, PVector floorDirection) {

  PVector f = floorPosition.get(); // 床の位置
  PVector n = floorDirection.get(); // 床の方向（法線ベクトル）
  PVector w = unProject(screen_x, screen_y, -1.0); // 画面上の点に対応する３次元座標
  PVector e = getEyePosition(); // 視点位置

  // 交点の計算  
  f.sub(e);
  w.sub(e);
  w.mult( n.dot(f)/n.dot(w) );
  w.add(e);

  return w;
}

// 現在の座標系における視点の位置を取得する関数
PVector getEyePosition() {
  PMatrix3D mat = (PMatrix3D)getMatrix(); // モデルビュー行列を取得
  mat.invert();
  return new PVector( mat.m03, mat.m13, mat.m23 );
}

// ウィンドウ座標系からローカル座標系への変換（逆投影）を行う関数
PVector unProject(float winX, float winY, float winZ) {
  PMatrix3D mat = getMatrixLocalToWindow();  
  mat.invert();

  float[] in = {
    winX, winY, winZ, 1.0f
  };
  float[] out = new float[4];
  mat.mult(in, out);  // Do not use PMatrix3D.mult(PVector, PVector)

  if (out[3] == 0 ) {
    return null;
  }

  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);  
  return result;
}

// ローカル座標系からウィンドウ座標系への変換行列を計算する関数
PMatrix3D getMatrixLocalToWindow() {
  PMatrix3D projection = ((PGraphics3D)g).projection; // プロジェクション行列
  PMatrix3D modelview = ((PGraphics3D)g).modelview;   // モデルビュー行列

  // ビューポート変換行列
  PMatrix3D viewport = new PMatrix3D();
  viewport.m00 = viewport.m03 = width/2;
  viewport.m11 = -height/2;
  viewport.m13 =  height/2;

  // ローカル座標系からウィンドウ座標系への変換行列を計算  
  viewport.apply(projection);
  viewport.apply(modelview);
  return viewport;
}

