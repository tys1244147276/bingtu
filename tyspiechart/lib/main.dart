import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimationDemo(),
    );
  }
}

class AnimationDemo2 extends AnimatedWidget{
  final double st ;
  final double ed ;
  final String title;
  final List data;
  Function onTapAnimation;
  // static final _runTween = new Tween<double>(begin:0.0,end:2.0);

  AnimationDemo2({Key key,Animation<double> animation,
  this.st,this.ed,this.title,this.data,this.onTapAnimation})
    :super(key:key,listenable:animation);


  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    final _runTween = new Tween<double>(begin: st,end: ed);
    return Column(
      children: <Widget>[
        Text(title),
        Padding(padding: EdgeInsets.all(50),) ,
        Transform(
          transform: Matrix4.identity()..rotateZ(_runTween.evaluate(animation)),
          alignment: Alignment.center,
          child: Container(
            width: 400,
            height: 400,
            child: DonutPieChart(data,
              onTap: (i){
                print(i);
                if (onTapAnimation != null){
                  onTapAnimation(i);
                }
            },
            ),
          ),
        ),
      ])
     ;
  }
  
}


class AnimationDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AnimationDemoState();
  }
}

class _AnimationDemoState extends State<AnimationDemo>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  double stP = 0.0;
  double edP = 2.0;
  int _count = 0;
  double cashStp;
  bool canRun = true;
  final data = [new DataRow("1", "A", 100), new DataRow("2", "B", 200), new DataRow("3", "C", 300), new DataRow("4", "D", 400)];
  @override
  void initState() {
    print("init---");
    super.initState();

    //初始化控制器
    controller = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    //创建动画
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    // 添加状态监听
    animation.addStatusListener(
      (status) {
        //根据不同动画状态执行
      if (status == AnimationStatus.completed) {
        print('completed');
        setState(() {
          canRun = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        print('dismissed');
        setState(() {
          canRun = false;
        });
      } else if (status == AnimationStatus.forward) {
        print('forward');
        setState(() {
          canRun = false;
        });
      }
    }
    );
    
  }

  length(n) {
    double sum = 0;
    for(var i=0;i<data.length;i++){
      sum = sum + data[i].value;
    }
    return (data[n].value / sum) * 2 * math.pi;
  }

  setStep(n) {
    if(n == 0){
      if(cashStp != null) {
        stP = cashStp;
      }else{
        stP = 0;
      }
      edP = math.pi - length(0) / 2;
      cashStp = edP;
    }else {
      if(cashStp != null) {
        stP = cashStp;
      }else{
        stP = sumOther(n-1);
      }
      edP = math.pi - length(n) / 2 - sumOther(n-1);
      cashStp = edP;
    }
    // stP = length(0);
    // // edP = math.pi -((data[0].value / sum) * 2 * math.pi)/2;
    // edP = math.pi -(length(1))/2 - length(0) ;
  }

  sumOther(n) {
    double sum = length(n);
    while(n > 0) {
      sum = sum + length(n-1);
      n--;
    }
    return sum;
  }

  _runC(int number){
    setStep(number);
    
    //即使用了动画Widget,外部的变量状态还是需要自己管理更新的
    this.setState((){});
    //重置动画
    controller.reset();
    //启动动画
    //controller有许多
    controller.forward();
  }
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AnimationDemo")),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.directions_run),
      //   onPressed: _runC,
      // ),
      body: Center(
        child: GestureDetector(
          // onPanDown: (_){if(canRun){_runC();}},
          child: AnimationDemo2(animation: animation,st:stP,ed:edP,title:_count.toString(),data:data,onTapAnimation: (value){
            if(canRun){
              _runC(value);
            }
          },),
        ),
      ),
    );
  }
}

class DonutPieChart extends StatelessWidget {
  final List seriesList;
  final bool animate;
  Function onTap;

  DonutPieChart(this.seriesList, {this.animate,this.onTap});

  /// Creates a [PieChart] with sample data and no transition.
  // factory DonutPieChart.withSampleData(data) {
  //   return new DonutPieChart(
  //     _createSampleDate2(data),
  //     // Disable animations for image tests.
  //     animate: false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(_createSampleDate2(seriesList),
        animate: false,
        selectionModels: [ // 设置点击选中事件
          charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: (charts.SelectionModel model) {
              // print(model.selectedDatum.first.index);
              if (onTap != null){
                onTap(model.selectedDatum.first.index);
              }
            }
          )
        ],
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        // defaultRenderer: new charts.ArcRendererConfig(arcWidth: 70));
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 70,
          arcRendererDecorators: [
            new charts.ArcLabelDecorator(
              insideLabelStyleSpec: new charts.TextStyleSpec(fontSize: 16, color: 
                charts.Color.fromHex(code: "#FFFFFF")))
          ]
        ));
  }

  static List<charts.Series<DataRow, String>> _createSampleDate2(data) {
    return [
      new charts.Series<DataRow, String>(
        id: "serId",
        keyFn: (DataRow dr, _) => dr.id,
        labelAccessorFn: (DataRow dr, _) => '${dr.label}: ${dr.value}',
        domainFn: (DataRow dr, _) => dr.label,
        measureFn: (DataRow dr, _) => dr.value,
        data: data)
    ];
  }
}

class DataRow {
  final String id;
  final String label;
  final double value;
  DataRow(this.id, this.label, this.value);
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
