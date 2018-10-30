// 操作方法
// 対応点を左右交互、もしくは対応する順番にクリックする（左右の順番関係なし）
// Enterキーでリセット

import org.apache.commons.math3.linear.*;

PImage img1, img2, img_out;
ArrayList img1_x;
ArrayList img1_y;
ArrayList img2_x;
ArrayList img2_y;
boolean exe = false;
int move_x, move_y;

RealVector H;



void setup() {
  size(1280, 720);
  stroke(255, 0, 0);
  noFill();

  img1 = loadImage("image1.jpg");
  img2 = loadImage("image2.jpg");
  img_out = createImage(width, height, RGB);

  img1_x = new ArrayList();
  img1_y = new ArrayList();
  img2_x = new ArrayList();
  img2_y = new ArrayList();
  
  move_x = 0;
  move_y = 0;
}



void draw() {
  background(0);
  if (exe) {
    for (int y=0; y<img_out.height; y++) {
      for (int x=0; x<img_out.width; x++) {
        double u = (x*H.getEntry(0) + y*H.getEntry(1) + H.getEntry(2)) / (x*H.getEntry(6) + y*H.getEntry(7) + 1);
        double v = (x*H.getEntry(3) + y*H.getEntry(4) + H.getEntry(5)) / (x*H.getEntry(6) + y*H.getEntry(7) + 1);
        img_out.set(x + move_x, y + move_y, img2.get(round((float)u), round((float)v)));
      }
    }
    image(img_out, 0, 0);
    image(img1, move_x, 0);
  }

  if (!exe) {
    image(img1, 0, 0);
    image(img2, img1.width, 0);

    for (int i=0; i<img1_x.size(); i++) {
      ellipse((int)img1_x.get(i), (int)img1_y.get(i), 10, 10);
    }
    for (int i=0; i<img2_x.size(); i++) {
      ellipse((int)img2_x.get(i) + img1.width, (int)img2_y.get(i), 10, 10);
    }
  }
}



void mousePressed() {
  if (!exe) {
    if (mouseX < img1.width && img1_x.size() < 4) {
      img1_x.add(mouseX);
      img1_y.add(mouseY);
    } else if (mouseX >= img1.width && img2_x.size() < 4) {
      img2_x.add(mouseX - img1.width);
      img2_y.add(mouseY);
    }

    if (img1_x.size() == 4 && img2_x.size() == 4) {
      homography((int)img1_x.get(0), (int)img1_x.get(1), (int)img1_x.get(2), (int)img1_x.get(3), (int)img1_y.get(0), (int)img1_y.get(1), (int)img1_y.get(2), (int)img1_y.get(3), (int)img2_x.get(0), (int)img2_x.get(1), (int)img2_x.get(2), (int)img2_x.get(3), (int)img2_y.get(0), (int)img2_y.get(1), (int)img2_y.get(2), (int)img2_y.get(3));
      exe = true;
    }
  }
}



void keyPressed() {
  if (key == ENTER) {
    exe = false;

    int count = img1_x.size();
    for (int i=0; i<count; i++) {
      img1_x.remove(0);
      img1_y.remove(0);
    }
    count = img2_x.size();
    for (int i=0; i<count; i++) {
      img2_x.remove(0);
      img2_y.remove(0);
    }
  } else if (key == 's' || key == 'S') {
    save("result.png");
  }
  if (exe) {
    if (key == LEFT) {
      move_x--;
    } else if(key == RIGHT){
      move_x++;
    } else if(key == UP){
      move_y--;
    } else if(key == DOWN){
      move_y++;
    }
  }
}



void homography(int x1, int x2, int x3, int x4, int y1, int y2, int y3, int y4, int u1, int u2, int u3, int u4, int v1, int v2, int v3, int v4) {
  // 擬似逆行列の導出
  double[][] array_A = {
    {x1, y1, 1, 0, 0, 0, -(x1*u1), -(y1*u1)}, 
    {0, 0, 0, x1, y1, 1, -(x1*v1), -(y1*v1)}, 
    {x2, y2, 1, 0, 0, 0, -(x2*u2), -(y2*u2)}, 
    {0, 0, 0, x2, y2, 1, -(x2*v2), -(y2*v2)}, 
    {x3, y3, 1, 0, 0, 0, -(x3*u3), -(y3*u3)}, 
    {0, 0, 0, x3, y3, 1, -(x3*v3), -(y3*v3)}, 
    {x4, y4, 1, 0, 0, 0, -(x4*u4), -(y4*u4)}, 
    {0, 0, 0, x4, y4, 1, -(x4*v4), -(y4*v4)}
  };
  RealMatrix A = MatrixUtils.createRealMatrix( array_A );
  double[] array_b = {u1, v1, u2, v2, u3, v3, u4, v4};
  RealVector b = MatrixUtils.createRealVector( array_b );
  H = MatrixUtils.inverse( A.transpose().multiply(A) ).multiply( A.transpose() ).operate(b);
  //showVector(H);
}



void showMatrix( RealMatrix M ) {
  println( "---" );
  for (int i=0; i<M.getRowDimension(); i++) {
    for (int j=0; j<M.getColumnDimension(); j++) {
      print( M.getEntry(i, j) + "  " );
    }
    println();
  }
  println( "---" );
}



void showVector( RealVector v ) {
  println( "---" );
  for (int i=0; i<v.getDimension(); i++) {
    println( v.getEntry(i) );
  }
  println( "---" );
}