import processing.video.*;

Movie movie;

PImage img_bg;  // 背景画像
PImage img_result; // 結果画像
PImage img_sub;   // 差分画像
PImage img_bin;  // 2値画像
PImage img_tmp1;  // 膨張収縮処理中のデータを入れる変数
PImage img_tmp2;  // 膨張収縮処理中のデータを入れる変数

color WHITE = color(255);  // 白画素
color BLACK = color(0);    // 黒画素

int count;
int label [][] = new int [640][360];   //ラベルの値
ArrayList LUT;

void setup() {
  size(1280, 720 );
  movie = new Movie(this, "cup.mp4");
  movie.loop();

  img_bg = createImage( 640, 360, RGB );
  img_result = createImage( 640, 360, RGB );
  img_sub = createImage( 640, 360, RGB );
  img_bin = createImage( 640, 360, RGB );
  img_tmp1= createImage( 640, 360, RGB );
  img_tmp2 = createImage( 640, 360, RGB );

  LUT = new ArrayList();
  LUT.add(0);
}


void draw() {
  background(0);
  PImage img_live = movie.copy();

  subtraction( img_live, img_bg, img_sub ); // 背景差分
  binarization( img_sub, img_bin, 21 ); // ２値化処理

  // クロージング
  dilation( img_bin, img_tmp1 );  // 膨張処理
  erosion( img_tmp1, img_tmp2 );  // 収縮処理

  // オープニング
  erosion( img_tmp2, img_tmp1 );  // 収縮処理
  dilation( img_tmp1, img_tmp2 );  // 膨張処理

  labeling( img_tmp2, img_result );  // ラベリング処理

  // 結果表示
  image(img_live, 0, 0);
  image(img_tmp2, img_live.width, 0 );
  image(img_live, 0, img_live.height );
  image(img_result, img_live.width, img_live.height);

  bounding( 0, 1, 300 );  // バウンディング処理
}

void movieEvent(Movie m) {
  m.read();
}

void mousePressed() {
  if ( mouseButton == LEFT ) {
    movie.pause();
  }
  if ( mouseButton == RIGHT ) {
    movie.play();
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    save("result.png");
  } else {
    img_bg = movie.copy();
  }
}



// ２値化処理
// img_in : 入力画像
// img_out : 出力画像（2値画像）
// threshold : 閾値
void binarization(PImage img_in, PImage img_out, int threshold) {

  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      color c = img_in.get(x, y);

      // 輝度値の計算
      float I = 0.299 * red(c) + 0.587*green(c) + 0.114*blue(c);

      // 閾値を越えていたら
      if ( I > threshold ) {
        img_out.set(x, y, color(255) );  // 白にする
      } else {
        img_out.set(x, y, color(0) );  // 黒にする
      }
    }
  }
}



// 差分処理
// img_fr : 物体が写った画像
// img_bg : 背景画像
// img_out : 結果画像（差分画像）
void subtraction(PImage img_fr, PImage img_bg, PImage img_out) {

  for (int y=0; y<img_fr.height; y++) {
    for (int x=0; x<img_fr.width; x++) {

      color c1 = img_fr.get(x, y);
      color c2 = img_bg.get(x, y);

      float r = abs( red(c1) - red(c2) );
      float g = abs( green(c1) - green(c2) );
      float b = abs( blue(c1) - blue(c2) );

      color c = color(r, g, b);
      img_out.set(x, y, c);
    }
  }
}



// 膨張処理
// img_in : 入力画像
// img_out : 出力画像
void dilation(PImage img_in, PImage img_out) {

  // 入力画像と同じデータを出力画像にコピー
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      img_out.set( x, y, img_in.get(x, y) );
    }
  }

  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {

      // 注目画素: (x,y)

      // 注目画素の左上が白（物体領域）画素だったら
      if ( img_in.get(x-1, y-1) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x, y-1) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x+1, y-1) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x-1, y) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x+1, y) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x-1, y+1) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x, y+1) == WHITE ) {
        img_out.set( x, y, WHITE );
      } else if ( img_in.get(x+1, y+1) == WHITE ) {
        img_out.set( x, y, WHITE );
      }
    }
  }
}



// 収縮処理
// img_in : 入力画像
// img_out : 出力画像
void erosion(PImage img_in, PImage img_out) {

  // 入力画像と同じデータを出力画像にコピー
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      img_out.set( x, y, img_in.get(x, y) );
    }
  }

  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {

      // 注目画素（x,y）の左上が黒（背景）画素だったら
      if ( img_in.get(x-1, y-1) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x, y-1) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x+1, y-1) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x-1, y) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x+1, y) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x-1, y+1) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x, y+1) == BLACK ) {
        img_out.set( x, y, BLACK );
      } else if ( img_in.get(x+1, y+1) == BLACK ) {
        img_out.set( x, y, BLACK );
      }
    }
  }
}




// ラベリング処理
// img_in : 入力画像
// img_out : 出力画像
void labeling(PImage img_in, PImage img_out) {

  color c [] = new color [6];
  c[0] = color(255, 0, 0);
  c[1] = color(0, 255, 0);
  c[2] = color(0, 0, 255);
  c[3] = color(255, 255, 0);
  c[4] = color(0, 255, 255);
  c[5] = color(255, 0, 255);

  // 入力画像と同じデータ出力画像にコピー
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      img_out.set(x, y, img_in.get(x, y));
    }
  }

  // ラベル初期化
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      label[x][y] = 0;
    }
  }

  // テーブル初期化
  if (LUT.size() > 1) {
    int table_size = LUT.size();
    for (int j=1; j<table_size; j++) {
      LUT.remove(1);
    }
  }

  int i = 0;
  // ラベルをつけながら、ルックアップテーブルにもラベルを記録する
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      // 1-画素なら
      if (img_in.get(x, y) == WHITE) {        
        // 上も左も0-画素（または画像の外）のとき
        if ((img_in.get(x, y-1) == BLACK || y-1 == -1) && (img_in.get(x-1, y) == BLACK || x-1 == -1)) {
          i++;
          label[x][y] = i;
          LUT.add(i);

          // 上の画素が0-画素（または画像の外）で、左の画素が1-画素であるとき
        } else if ((img_in.get(x, y-1) == BLACK || y-1 == -1) && img_in.get(x-1, y) == WHITE) {
          label[x][y] = label[x-1][y];

          // 上の画素が1-画素であるとき
        } else if (img_in.get(x, y-1) == WHITE) {
          label[x][y] = label[x][y-1];

          // 左の画素がラベルを持ち、注目画素のラベルと異なるとき
          if (img_in.get(x-1, y) == WHITE) {

            // 小さい方のラベルをつける
            int min = min((int)LUT.get(label[x][y-1]), (int)LUT.get(label[x-1][y]));
            int max = max((int)LUT.get(label[x][y-1]), (int)LUT.get(label[x-1][y]));
            label[x][y] = min;
            for (int j=1; j<LUT.size(); j++) {
              // 大きい方のLUTの値変更
              if ((int)LUT.get(j) == max) {
                LUT.set(j, min);
              }
            }
          }
        }
      }
    }
  }

  // LUTを連番にする
  count = 1;
  for (int k=1; k<LUT.size(); k++) {
    boolean count_flag = false;
    for (int j=1; j<LUT.size(); j++) {
      if ((int)LUT.get(j) == k) {
        count_flag = true;
        LUT.set(j, count);
      }
    }
    if (count_flag) {
      count++;
    }
  }

  // LUTを元にラベルを更新
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      if (img_in.get(x, y) == WHITE) {
        label[x][y] = (int)LUT.get(label[x][y]);
      }
    }
  }

  // ラベルから画素値を更新
  for (int y=0; y<img_in.height; y++) {
    for (int x=0; x<img_in.width; x++) {
      if (img_in.get(x, y) == WHITE) {
        int color_num = (label[x][y] -1) % c.length;
        img_out.set(x, y, c[color_num] );
      }
    }
  }
}



// 枠線処理
// move_x : 枠線の横移動
// move_y : 枠線の縦移動
// threshold : 閾値
void bounding(int move_x, int move_y, int threshold) {

  int area [] = new int [count-1];
  int left [] = new int [count-1];
  int right [] = new int [count-1];
  int top [] = new int [count-1];
  int bottom [] = new int [count-1];
  for (int i=0; i<left.length; i++) {
    left[i] = img_result.width;
  }
  for (int i=0; i<right.length; i++) {
    right[i] = 0;
  }
  for (int i=0; i<top.length; i++) {
    top[i] = img_result.height;
  }
  for (int i=0; i<bottom.length; i++) {
    bottom[i] = 0;
  }

  // 面積・幅・高さを計算
  for (int y=0; y<img_result.height; y++) {
    for (int x=0; x<img_result.width; x++) {
      if (label[x][y] != 0) {
        area[label[x][y] -1]++;
        left[label[x][y] -1] = min(x, left[label[x][y] -1]);
        right[label[x][y] -1] = max(x, right[label[x][y] -1]);
        top[label[x][y] -1] = min(y, top[label[x][y] -1]);
        bottom[label[x][y] -1] = max(y, bottom[label[x][y] -1]);
      }
    }
  }

  // 枠線を描く
  stroke(255, 0, 0);
  strokeWeight(2);
  noFill();
  for (int i=0; i<area.length; i++) {
    if (area[i] >= threshold) {
      rect(left[i] + img_result.width*move_x, top[i] + img_result.height*move_y, right[i] - left[i], bottom[i] - top[i]);
    }
  }
}