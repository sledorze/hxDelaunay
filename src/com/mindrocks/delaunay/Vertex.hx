package com.mindrocks.delaunay;

import flash.geom.Point;
import flash.Vector;

@:final class Vertex implements ICoord
{
	public static var VERTEX_AT_INFINITY:Vertex = new Vertex(Math.NaN, Math.NaN);
	
	private static var _pool:Vector<Vertex> = new Vector<Vertex>();
	private static function create(x:Float, y:Float):Vertex
	{
    var a = x+y;
		if (a == (a + 1)) // Math.isNaN(x) || Math.isNaN(y)
		{
			return VERTEX_AT_INFINITY;
		}
		if (_pool.length > 0)
		{
			return _pool.pop().init(x, y);
		}
		else
		{
			return new Vertex(x, y);
		}
	}


	private static var _nvertices:Int = 0;
	
	private var _coord:Point;
	public var coord(get_coord, null):Point;
	inline public function get_coord():Point {
		return _coord;
	}
	private var _vertexIndex:Int;
	public var vertexIndex(get_vertexIndex, null):Int;
	inline public function get_vertexIndex():Int
	{
		return _vertexIndex;
	}

	// Should be private
	public function new(x:Float, y:Float) {
		init(x, y);
	}
	
	inline private function init(x:Float, y:Float):Vertex {
		_coord = new Point(x, y);
		return this;
	}
	
	inline public function dispose():Void {
    if (this != VERTEX_AT_INFINITY) {
      _coord = null;
      _pool.push(this);
    }
	}
	
	inline public function setIndex():Void {
		_vertexIndex = _nvertices++;
	}
	
	public function toString():String
	{
		return "Vertex (" + _vertexIndex + ")";
	}

	/**
	 * This is the only way to make a Vertex
	 * 
	 * @param halfedge0
	 * @param halfedge1
	 * @return 
	 * 
	 */
	public static function intersect(halfedge0:Halfedge, halfedge1:Halfedge):Vertex {
		var halfedge:Halfedge;
		var determinant:Float;
		var intersectionX:Float;
		var intersectionY:Float;
		var rightOfSite:Bool;
	
		var edge0 = halfedge0.edge;
		var edge1 = halfedge1.edge;
		if (edge0 == null || edge1 == null) {
			return null;
		}
		if (edge0.rightSite == edge1.rightSite) {
			return null;
		}
	
		determinant = edge0.a * edge1.b - edge0.b * edge1.a;
		if (-1.0e-10 < determinant && determinant < 1.0e-10)
		{
			// the edges are parallel
			return null;
		}
	
		var oneOverDet = 1 / determinant;
		intersectionX = (edge0.c * edge1.b - edge1.c * edge0.b)*oneOverDet;
		intersectionY = (edge1.c * edge0.a - edge0.c * edge1.a)*oneOverDet;
	
		var edge:Edge;
		if (Voronoi.isInfSite(edge0.rightSite, edge1.rightSite)) {
			halfedge = halfedge0; edge = edge0;
		} else {
			halfedge = halfedge1; edge = edge1;
		}
		rightOfSite = intersectionX >= edge.rightSite.x;
		if ((rightOfSite && halfedge.leftRight == LR.LEFT)
		||  (!rightOfSite && halfedge.leftRight == LR.RIGHT))
		{
			return null;
		}
	
		return Vertex.create(intersectionX, intersectionY);
	}
	public var x(get_x, null):Float;
	public var y(get_y, null):Float;
	inline public function get_x():Float {
		return _coord.x;
	}
	inline public function get_y():Float {
		return _coord.y;
	}
	
}
