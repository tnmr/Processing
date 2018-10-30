/*
2016/7/24
 Draw the tsumutsumu_demo.pde
 2620140503　３年３組３３番　谷森　一貴
 
 このプログラムはProcessingのライブラリの'fisica'を使用しています。
 */

import fisica.*;
FWorld world;
FCircle ball[];

final int radius = 50;
final int number = 8;
color flag = 0;
boolean released, disable;
ArrayList delete;
boolean trans_flag[];
boolean delete_flag[];
boolean up1[];
boolean up2[];
boolean down1[];
boolean down2[];
float trans_radius[];
float move_r[];
int now_time, release_time, count;

void setup() {
  size(400, 400);
  delete = new ArrayList();
  released = false;
  disable = false;
  count = 0;

  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  world.setGravity(0, 1500);
  world.setGrabbable(false);

  FLine leftEdge = new FLine(0, 350, width/2, height);
  leftEdge.setStatic(true);
  world.add(leftEdge);
  FLine rightEdge = new FLine(width/2, height, width, 350);
  rightEdge.setStatic(true);
  world.add(rightEdge);

  ball = new FCircle [number*3];
  for (int n=0; n<3; n++) {
    for (int i=0; i<number; i++) {
      ball[n*number+i] = new FCircle(radius);
      ball[n*number+i].setPosition(random(radius, width-radius*2), random(1, 70));
      ball[n*number+i].setRestitution(0.01);
      ball[n*number+i].setDensity(10000);
      if (n==0) {
        ball[n*number+i].setFill(255, 0, 0);
      } else if (n==1) {
        ball[n*number+i].setFill(0, 255, 0);
      } else {
        ball[n*number+i].setFill(0, 0, 255);
      }
      world.add(ball[n*number+i]);
    }
  }

  trans_flag = new boolean [ball.length];
  delete_flag = new boolean [ball.length];
  up1 = new boolean [ball.length];
  up2 = new boolean [ball.length];
  down1 = new boolean [ball.length];
  down2 = new boolean [ball.length];
  trans_radius = new float [ball.length];
  move_r = new float [ball.length];
  for (int i=0; i<ball.length; i++) {
    trans_flag[i] = false;
    delete_flag[i] = false;
    up1[i] = false;
    up2[i] = false;
    down1[i] = false;
    down2[i] = false;
    trans_radius[i] = 0;
    move_r[i] = 0;
  }
}

void draw() {
  background(255);
  world.step();
  world.draw();

  for (int i=0; i<ball.length; i++) {
    if (!mousePressed) {
      ball[i].setStroke(0);
      ball[i].setStrokeWeight(1);
    }
  }

  //タッチしたときのバウンスアクション
  if (!released) {
    for (int i=0; i<ball.length; i++) {
      if (trans_flag[i]) {
        bounceAction(i, ball[i].getX(), ball[i].getY(), ball[i].getFillColor());
      }
    }
  }

  stroke(0);
  strokeWeight(2);
  if (delete.size()==1) {
    point(ball[(int)delete.get(0)].getX(), ball[(int)delete.get(0)].getY());
  }
  for (int i=0; i<delete.size()-1; i++) {
    line(ball[(int)delete.get(i)].getX(), ball[(int)delete.get(i)].getY(), ball[(int)delete.get(i+1)].getX(), ball[(int)delete.get(i+1)].getY());
  }

  now_time = frameCount;

  //キャラを消す
  if (released) {
    if (!disable) {
      if (now_time-release_time >= count*10) {
        ball[(int)delete.get(count)].setNoStroke();
        ball[(int)delete.get(count)].setNoFill();
        count++;
      }

      if (count >= delete.size()) {
        disable = true;
      }
    } else {
      for (int i=0; i<delete.size(); i++) {
        world.remove(ball[(int)delete.get(i)]);
        delete_flag[(int)delete.get(i)] = true;
      }
      delete.clear();
      flag = 0;
      released = false;
      disable = false;
      count = 0;
    }
  }

  stroke(0);
  fill(255);
  rect(0, 0, width-1, 150);
}

void mousePressed() {
  //消すキャラを決めてdeleteに追加する
  for (int i=0; i<ball.length; i++) {
    if (dist(mouseX, mouseY, ball[i].getX(), ball[i].getY())<=radius/2) {
      ball[i].setStroke(0, 200, 255);
      ball[i].setStrokeWeight(3);
      delete.add(i);
      trans_flag[i] = true;
      if (ball[i].getFillColor() == #FF0000) {
        flag = #FF0000;
      } else if (ball[i].getFillColor() == #00FF00) {
        flag = #00FF00;
      } else {
        flag = #0000FF;
      }
    }
  }
}

void mouseDragged() {
  //消すキャラを決めてdeleteに追加する
  if (delete.size()==0) {
    for (int i=0; i<ball.length; i++) {
      if (dist(mouseX, mouseY, ball[i].getX(), ball[i].getY())<=radius/2) {
        ball[i].setStroke(0, 200, 255);
        ball[i].setStrokeWeight(3);
        delete.add(i);
        trans_flag[i] = true;
        if (ball[i].getFillColor() == #FF0000) {
          flag = #FF0000;
        } else if (ball[i].getFillColor() == #00FF00) {
          flag = #00FF00;
        } else {
          flag = #0000FF;
        }
      }
    }
  }

  //deleteに追加する
  for (int i=0; i<ball.length; i++) {
    if (dist(mouseX, mouseY, ball[i].getX(), ball[i].getY()) <= radius/2 && !delete.contains(i)) {
      if (delete.size()>0 && dist(ball[i].getX(), ball[i].getY(), ball[(int)delete.get(delete.size()-1)].getX(), ball[(int)delete.get(delete.size()-1)].getY()) <= radius*1.5) {
        if (flag == ball[i].getFillColor()) {   
          delete.add(i);
          trans_flag[i] = true;
          ball[i].setStroke(0, 200, 255);
          ball[i].setStrokeWeight(3);
        }
      }
    }
  }
}

void mouseReleased() {
  if (delete.size() >= 3) {
    released = true;
    release_time = frameCount;
    for (int i=0; i<delete.size(); i++) {
      if (flag == #FF0000) {
        ball[(int)delete.get(i)].setFill(255, 0, 0, 128);
      } else if (flag == #00FF00) {
        ball[(int)delete.get(i)].setFill(0, 255, 0, 128);
      } else {
        ball[(int)delete.get(i)].setFill(0, 0, 255, 128);
      }
    }
  } else {
    delete.clear();
    flag = 0;
  }
}

void bounceAction(int num, float x, float y, color fillColor) {
  int radius_limit1 = 20;
  int radius_limit2 = 5;
  up1[num] = true;

  stroke(0, 200, 255);
  strokeWeight(3);
  fill(fillColor);
  ellipse(x, y, radius + trans_radius[num], radius + trans_radius[num]);

  if (up1[num] && !down1[num]) {
    trans_radius[num] = 1.4*sq(move_r[num]);
    move_r[num]+=0.5;

    if (trans_radius[num]>=radius_limit1) {
      down1[num] = true;
    }
  }

  if (down1[num] && !up2[num]) {
    trans_radius[num] = trans_radius[num] - 0.2*sq(move_r[num]);
    move_r[num]+=0.4;

    if (trans_radius[num]<=0) {
      up2[num] = true;
      move_r[num] = 0;
    }
  }

  if (up2[num] && !down2[num]) {
    trans_radius[num] = 1.4*sq(move_r[num]);
    move_r[num]+=0.4;

    if (trans_radius[num]>=radius_limit2) {
      down2[num] = true;
    }
  }

  if (down2[num]) {
    trans_radius[num] = trans_radius[num] - 0.2*sq(move_r[num]);
    move_r[num]+=0.4;

    if (trans_radius[num]<=0) {
      up1[num] = false;
      up2[num] = false;
      down1[num] = false;
      down2[num] = false;
      move_r[num] = 0;
      trans_flag[num] = false;
    }
  }
}