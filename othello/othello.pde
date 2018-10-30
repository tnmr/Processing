final int SIZE = 50;
final int STONE_SIZE = (int)(SIZE*0.7);
final int NONE = 0;
final int BLACK = 1;
final int WHITE = 2;

int[][] field;
boolean[] direct;
boolean[][] highlight;
boolean[] pass_both;
boolean black_turn =true;
boolean windowResized = false;
boolean timeFlag = false;
boolean autoFlag = false;
boolean userColor;
int putTime, nowTime;
int max_x, max_y;

userInterface ui;
evaluation ev;

void setup() {
  size(100, 100);
  field = new int [8][8];
  direct = new boolean [9];
  highlight = new boolean [8][8];
  pass_both = new boolean [2];

  ui = new userInterface(SIZE, STONE_SIZE, NONE, BLACK, WHITE);
  ev = new evaluation(NONE, BLACK, WHITE);

  for (int i=0; i<8; ++i) {
    for (int j=0; j<8; ++j) {
      field[i][j] = NONE;
    }
  }

  for (int i=0; i<2; i++) {
    pass_both[i] = false;
  }

  initialization();
  //sample();

  if (check_pass()) {
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        ui.highlight(i, j, highlight[i][j], get_current_stone());
      }
    }
  }
  
  max_x = -1;
  max_y = -1;
  
  text("とりあえず書いておく", 100, 100);
}

void draw() {
  if (!windowResized) {
    // resize the main window to the size fo the image.
    surface.setSize(8*SIZE, 8*SIZE);
    windowResized = true;
    return;
  }

  background(0, 128, 0);

  // lines
  stroke(0);
  strokeWeight(1);
  for (int i=1; i<8; ++i) {
    line(i*SIZE, 0, i*SIZE, height);
    line(0, i*SIZE, width, i*SIZE);
  }

  //メニュー表示
  ui.drawMenu(field, get_current_stone());
  if (!timeFlag) {
    //置くマスのハイライト
    ui.putHighlight();
    //CPUの置いた石のハイライト
    if (ui.cpu()) {
      ui.putHighlight_CPU(max_x, max_y);
    }
  }

  // draw stones
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      noStroke();
      strokeWeight(1);
      if (field[i][j]==BLACK) {
        fill(0);  //color black
        ellipse((i*2+1)*SIZE/2, (j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      } else if (field[i][j]==WHITE) {
        fill(255); // color white
        ellipse((i*2+1)*SIZE/2, (j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      }

      //置ける場所のハイライト
      if (!timeFlag) {
        ui.highlight(i, j, highlight[i][j], get_current_stone());
      }
    }
  }

  //ターンの石をマウス下に表示
  if (!timeFlag) {
    ui.turnStone(get_current_stone());
  }

  //CPUのターン
  if (ui.cpu() && userColor!=black_turn) {
    interval();
    if (autoFlag) {
      auto_play();
      autoFlag = false;
    }
  }

  ui.drawDecideColor();

  if (!check_winlose()) {
    //パス処理
    if (check_pass()) {
      pass_both[get_current_stone()-1] = true;
      if (ui.cpu()) {
        //CPUモード時
        //ユーザーパス処理（CPU２回目ターン）
        if (userColor==black_turn) {
          println("user_pass");
          timeFlag = true;
          putTime = frameCount;
          //CPUパス処理（ユーザー２回目ターン）
        } else {
          println("cpu_pass");
        }
      }
      //パスになったらターンを進める
      black_turn = !black_turn;
    } else {
      for (int i=0; i<2; i++) {
        pass_both[i] = false;
      }
    }
  } else {
    ui.drawResult();
  }
}

void mousePressed() {
  int x = mouseX/SIZE;
  int y = mouseY/SIZE;

  if (!ui.decide_color) {
    if (mouseX <= 8*SIZE) {
      if (field[x][y]==NONE) {
        if (can_put_here(x, y)) {
          if (black_turn) {
            field[x][y] = BLACK;
          } else {
            field[x][y] = WHITE;
          }

          for (int i=-1; i<2; i++) {
            for (int j=-1; j<2; j++) {
              if (direct[(i+1)*3+(j+1)]==true) {
                reverse_direction(x, y, j, i);
              }
            }
          }

          black_turn = !black_turn;   //ターン交代

          if (ui.cpu()) {
            timeFlag = true;
            putTime = frameCount;
          }
        }
      }
    } else {
      if (ui.pressedButton()) {
        black_turn = true;
        for (int i=0; i<2; i++) {
          pass_both[i] = false;
        }
        ui.pressedEvent(field);
        max_x = -1;
        max_y = -1;
      }
    }
  } else {
    //ユーザーの色を決める
    userColor = ui.userColor(get_current_stone());
    if (ui.cpu()) {
      if (!userColor) {
        if (black_turn) {
          timeFlag = true;
          putTime = frameCount;
        }
      }
    }
  }
}

//キー処理
void keyPressed() {
  switch(key) {
  case 'm':
  case 'M':
    break;
  case 's':
  case 'S':
    save("output.png");
    break;
  case ESC:
    break;
  }
}

//初期配置
void initialization() {
  field[3][3] = BLACK;
  field[4][4] = BLACK;
  field[3][4] = WHITE;
  field[4][3] = WHITE;
}

//例題
void sample() {
  field[3][3] = BLACK;
  field[4][3] = BLACK;
  field[5][3] = BLACK;
  field[3][4] = BLACK;
  field[4][4] = WHITE;
  field[5][4] = BLACK;
  field[3][5] = BLACK;
  field[4][5] = BLACK;
  field[5][5] = BLACK;
}

//ターンの色を返す
int get_current_stone() {
  if (black_turn) {
    return BLACK;
  } else {
    return WHITE;
  }
}

//置けるか判定する
boolean can_put_here(int x, int y) {
  boolean put_table = false;
  if (field[x][y] != NONE) {
    return false;
  }

  for (int i=-1; i<=1; i++) {
    for (int j=-1; j<=1; j++) {
      direct[(i+1)*3+(j+1)] = false;   //初期化
      if (!(i==0 && j==0)) {
        if (inside(x + j, y + i)) {
          if (field[x + j][y + i] == get_current_stone()) {
            direct[(i+1)*3+(j+1)] = false;
          } else if (field[x + j][y + i] == NONE) {
            direct[(i+1)*3+(j+1)] = false;
          } else if (field[x + j][y + i] != get_current_stone()) {
            direct[(i+1)*3+(j+1)] = check_direction(x + j, y + i, j, i);
          }
        }
      }
    }
  }

  //８方向のうち１つでも置ける方向があれば
  if (direct[0] || direct[1] || direct[2] || direct[3] || direct[5] || direct[6] || direct[7] || direct[8]) {
    put_table = true;
  }

  return put_table;
}

//隣の石を見る
boolean check_direction(int x, int y, int vec_x, int vec_y) {
  if (!inside(x + vec_x, y + vec_y)) {   //端なら
    return false;
  } else if (field[x + vec_x][y + vec_y] == NONE) {   //空白なら
    return false;
  } else if (field[x + vec_x][y + vec_y] == get_current_stone()) {   //置いた色と同じなら
    return true;
  } else if (field[x + vec_x][y + vec_y] != get_current_stone()) {   //置いた色と違う色なら
    return check_direction(x + vec_x, y + vec_y, vec_x, vec_y);
  } else {
    return false;
  }
}

//ひっくり返す
void reverse_direction(int x, int y, int vec_x, int vec_y) {
  if (field[x + vec_x][y + vec_y] == get_current_stone()) {   //置いた色と同じ色なら
    return;
  } else {   //置いた色と違う色なら
    field[x + vec_x][y + vec_y] = get_current_stone();
    reverse_direction(x + vec_x, y + vec_y, vec_x, vec_y);
  }
}

//端にあるか内側にあるか調べる
boolean inside(int x, int y) {
  if (x>=0 && x<8 && y>=0 && y<8) {
    return true;
  } else {
    return false;
  }
}

//置けるところがあるか調べる
boolean check_pass() {
  boolean pass = true;
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      if (can_put_here(i, j)==true) {
        pass = false;
        highlight[i][j] = true;
      } else {
        highlight[i][j] = false;
      }
    }
  }
  return pass;
}

//勝ち負け判定
boolean check_winlose() {
  boolean end = true; 
  //黒も白もどちらもパスしたら
  if (pass_both[0] && pass_both[1]) {
    end = true;
  } else {
    end = false;
  }
  return end;
}

//CPU自動操作
void auto_play() {
  int max_value = -1000;
  max_x = -1;
  max_y = -1;

  //評価値計算
  ev.calculateValue(field, get_current_stone());

  for (int x=0; x<8; x++) {
    for (int y=0; y<8; y++) {
      if (can_put_here(x, y)) {
        if (max_value < ev.value[x][y]) {
          max_value = ev.value[x][y];
          max_x = x;
          max_y = y;
        }
      }
    }
  }

  if (!check_pass()) {
    if (can_put_here(max_x, max_y)) {
      if (black_turn) {
        field[max_x][max_y] = BLACK;
      } else {
        field[max_x][max_y] = WHITE;
      }

      for (int i=-1; i<2; i++) {
        for (int j=-1; j<2; j++) {
          if (direct[(i+1)*3+(j+1)]==true) {
            reverse_direction(max_x, max_y, j, i);
          }
        }
      }
    }
    black_turn = !black_turn;
  }
}

//待ち時間調整
void interval() {
  if (timeFlag) {
    nowTime = frameCount;
    if (nowTime - putTime >= 100) {
      timeFlag = false;
      autoFlag = true;
    }
  }
}