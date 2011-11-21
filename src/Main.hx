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

import de.polygonal.motor.geom.tri.DelaunayTriangulation;
 
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
      
      var nbPoints = 80;
      var points : Vector<Point> = new Vector(0);
      for (i in 0...nbPoints) {
        points.push(new Point(Std.random(400), Std.random(400)));
      }
      points.sort(function (a, b) return Std.int(a.x - b.x));

      var pts = [];
      var destTris = [];
      for (pt in points) {
        pts.push(pt.x);
        pts.push(pt.y);
        pts.push(0);
        
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
        destTris.push(0);
      }
      
      this.graphics.lineStyle(1);
      this.graphics.beginFill(0xff0000);
      
      var nbTris;
        nbTris = DelaunayTriangulation.triangulate(pts, destTris);
      Timer.measure(function () {
        nbTris = DelaunayTriangulation.triangulate(pts, destTris);
      });
/*      
      for (i in 0...nbTris) {        
        var a = destTris[i * 3];
        var b = destTris[i * 3 + 1];
        var c = destTris[i * 3 + 2];
        
        this.graphics.moveTo(pts[c*3], pts[c*3+1]);
        this.graphics.lineTo(pts[a*3], pts[a*3+1]);
        this.graphics.lineTo(pts[b*3], pts[b*3+1]);
        this.graphics.lineTo(pts[c*3], pts[c*3+1]);
      }
  */
        voro = new Voronoi(points, null, new Rectangle(0, 0, 400, 400));      
      Timer.measure(function () {
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
    
      
      
   
      for (line in voro.voronoiDiagram()) {
        this.graphics.moveTo(line.p0.x, line.p0.y);
        this.graphics.lineTo(line.p1.x, line.p1.y);        
      }
/*
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
      */
      this.graphics.endFill();

//    }
	}
}