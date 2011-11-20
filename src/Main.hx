package ;

import com.mindrocks.delaunay.Voronoi;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.Vector;
import haxe.Timer;

/**
 * ...
 * @author sledorze
 */

class Main extends Sprite {
	var voro : Voronoi;
  
	static function main() 
	{
		new Main();
	}
	function new() {
    super();

    Lib.current.addChild(this);
    
//    while (true) {
      
      var nbPoints = 10;
      var points : Vector<Point> = new Vector(0);
      for (i in 0...nbPoints) {
        points.push(new Point(Std.random(400), Std.random(400)));
      }
      
      var time = Timer.measure(function () {
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        /*
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
        */
      });
    
      this.graphics.lineStyle(1);
      this.graphics.beginFill(0xff0000);
      
      for (region in voro.regions()) {
        if (region.length > 2) {
          var last = region[region.length - 1];
          this.graphics.moveTo(last.x, last.y);
          for (pt in region) {
            this.graphics.lineTo(pt.x, pt.y);
          }        
        }
      }
      for (circle in voro.circles()) {      
        this.graphics.drawCircle(circle.center.x, circle.center.y, circle.radius);      
      }
      this.graphics.endFill();

//    }
	}
}