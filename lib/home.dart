import 'dart:ui';

import 'package:flutter/material.dart';

import 'mycolor.dart';
import 'tile.dart';
import 'grid.dart';
import 'game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<List<int>> grid = [];
  List<List<int>> gridNew = [];
  late SharedPreferences sharedPreferences;
  int score = 0;int _seconds = 60;


  bool isgameOver = false;
  bool isgameWon = false;

  List<Widget> getGrid(double width, double height) {
    List<Widget> grids = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int num = grid[i][j];
        String number;
        int color;
        if (num == 0) {
          color = MyColor.emptyGridBackground;
          number = "";
        } else if (num == 2 || num == 4) {
          color = MyColor.gridColorTwoFour;
          number = "${num}";
        } else if (num == 8 || num == 64 || num == 256) {
          color = MyColor.gridColorEightSixtyFourTwoFiftySix;
          number = "${num}";
        } else if (num == 16 || num == 32 || num == 1024) {
          color = MyColor.gridColorSixteenThirtyTwoOneZeroTwoFour;
          number = "${num}";
        } else if (num == 128 || num == 512) {
          color = MyColor.gridColorOneTwentyEightFiveOneTwo;
          number = "${num}";
        } else {
          color = MyColor.gridColorWin;
          number = "${num}";
        }
        double size;
        String n = "${number}";
        switch (n.length) {
          case 1:
          case 2:
            size = 40.0;
            break;
          case 3:
            size = 30.0;
            break;
          case 4:
            size = 20.0;
            break;
          default:
            size = 0.0; // Default size if length is not covered
        }
        grids.add(Tile(number, width, height, color, size));
      }
    }
    return grids;
  }

  void handleGesture(int direction) {
    bool flipped = false;
    bool played = true;
    bool rotated = false;
    if (direction == 0) {
      setState(() {
        grid = transposeGrid(grid);
        grid = flipGrid(grid);
        rotated = true;
        flipped = true;
      });
    } else if (direction == 1) {
      setState(() {
        grid = transposeGrid(grid);
        rotated = true;
      });
    } else if (direction == 2) {
    } else if (direction == 3) {
      setState(() {
        grid = flipGrid(grid);
        flipped = true;
      });
    } else {
      played = false;
    }

    if (played) {
      List<List<int>> past = copyGrid(grid);
      for (int i = 0; i < 4; i++) {
        setState(() {
          List result = operate(grid[i], score, sharedPreferences);
          score = result[0];
          grid[i] = result[1];
        });
      }
      setState(() {
        grid = addNumber(grid, gridNew);
      });
      bool changed = compare(past, grid);
      if (flipped) {
        setState(() {
          grid = flipGrid(grid);
        });
      }

      if (rotated) {
        setState(() {
          grid = transposeGrid(grid);
        });
      }

      if (changed) {
        setState(() {
          grid = addNumber(grid, gridNew);
        });
      }

      bool gameover = isGameOver(grid);
      if (gameover) {
        setState(() {
          isgameOver = true;
        });
      }

      bool gamewon = isGameWon(grid);
      if (gamewon) {
        setState(() {
          isgameWon = true;
        });
      }
    }
  }

  @override
  void initState() {
    grid = blankGrid();
    gridNew = blankGrid();
    addNumber(grid, gridNew);
    addNumber(grid, gridNew);
    super.initState();
  }

  Future<String> getHighScore() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int? score = sharedPreferences.getInt('high_score');
    if (score == null) {
      score = 0;
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double gridWidth = (width - 80) / 4;
    double gridHeight = gridWidth;
    double height = 30 + (gridHeight * 4) + 10;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '2048',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(MyColor.gridBackground),
        actions: [
          IconButton(
            icon: Icon(Icons.info), // Icon for tutorial
            onPressed: () {
              // Show popup tutorial page when icon is pressed
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Tutorial"),
                    content: Text("วิธีการเล่น:\n 2048 เป็นเกมที่มีแผ่นกระเบื้องกับตัวเลขที่ปรากฏบนกระดาน ใช้แป้นลูกศรเพื่อย้ายแผ่นกระเบื้องรอบกระดาน กดขึ้นจะย้ายแผ่นกระเบื้องทั้งหมดขึ้น กดขวาจะย้ายแผ่นกระเบื้องทั้งหมดไปทางด้านขวาของกระดาน เป็นต้น แต่ละครั้งที่คุณย้าย กระเบื้องใหม่จะปรากฏขึ้น\n\n เป้าหมายของเกมนี้คือการทำให้แผ่นกระเบื้องที่มีค่าเดียวกันชนกัน เมื่อทั้งสองแผ่นกระเบื้องที่มีค่าเดียวกันชนกัน พวกมันจะรวมเป็นแผ่นกระเบื้องเดียวที่มีค่าเป็นสองเท่า ดังนั้นถ้าสองแผ่นกระเบื้องที่มีค่าของ 2 ชนกัน พวกมันจะกลายเป็นแผ่นกระเบื้องเดียวที่มีค่าของ 4 ถ้าสองแผ่นกระเบื้องที่มีค่าของ 4 ชนกัน พวกมันจะรวมเป็นแผ่นกระเบื้องเดียวที่มีค่าของ 8 เป็นต้น คุณชนะเมื่อคุณจัดการเพื่อสร้างแผ่นกระเบื้องที่มีมูลค่า 2048 โชคดี!"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Color(MyColor.gridBackground),
                  ),
                  
                  height: 82.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                        
                        child: Text(
                          'Score',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          '${score}',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
              Container(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: GridView.count(
                          primary: false,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          crossAxisCount: 4,
                          children: getGrid(gridWidth, gridHeight),
                        ),
                        onVerticalDragEnd: (DragEndDetails details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < 0) {
                              handleGesture(0);
                            } else if (details.primaryVelocity! > 0) {
                              handleGesture(1);
                            }
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! > 0) {
                              handleGesture(2);
                            } else if (details.primaryVelocity! < 0) {
                              handleGesture(3);
                            }
                          }
                        },
                      ),
                    ),
                    isgameOver
                        ? Container(
                            height: height,
                            color: Color(MyColor.transparentWhite),
                            child: Center(
                              child: Text(
                                'Game over!',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(MyColor.gridBackground)),
                              ),
                            ),
                          )
                        : SizedBox(),
                    isgameWon
                        ? Container(
                            height: height,
                            color: Color(MyColor.transparentWhite),
                            child: Center(
                              child: Text(
                                'You Won!',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(MyColor.gridBackground)),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                color: Color(MyColor.gridBackground),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Color(MyColor.gridBackground),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: IconButton(
                          iconSize: 35.0,
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              grid = blankGrid();
                              gridNew = blankGrid();
                              grid = addNumber(grid, gridNew);
                              grid = addNumber(grid, gridNew);
                              score = 0;
                              isgameOver = false;
                              isgameWon = false;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Color(MyColor.gridBackground),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'High Score',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder<String>(
                              future: getHighScore(),
                              builder: (ctx, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Text(
                                    snapshot.data!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  return Text(
                                    '0',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}
