package com.mindrocks.delaunay;

import com.mindrocks.geom.Polygon;
import com.mindrocks.geom.Winding;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;

@:final class Site implements ICoord
{
	private static var _pool:Vector<Site> = new Vector<Site>();
	public static function create(p:Point, index:Int, weight:Float, color:Int):Site {
		if (_pool.length > 0)
		{
			return _pool.pop().init(p, index, weight, color);
		}
		else
		{
			return new Site(p, index, weight, color);
		}
	}
	
	public inline static function sortSites(sites:Vector<Site>):Void {
		sites.sort(Site.compare);
	}

	/**
	 * sort sites on y, then x, coord
	 * also change each site's _siteIndex to match its new position in the list
	 * so the _siteIndex can be used to identify the site for nearest-neighbor queries
	 * 
	 * haha "also" - means more than one responsibility...
	 * 
	 */
	
	inline private static function compare(s1:Site, s2:Site):Int {
		var returnValue:Int = Voronoi.compareByYThenX(s1, s2);
		
		// swap _siteIndex values if necessary to match new ordering:
		var tempIndex:Int;
		if (returnValue == -1)
		{
			if (s1._siteIndex > s2._siteIndex)
			{
				tempIndex = s1._siteIndex;
				s1._siteIndex = s2._siteIndex;
				s2._siteIndex = tempIndex;
			}
		}
		else if (returnValue == 1)
		{
			if (s2._siteIndex > s1._siteIndex)
			{
				tempIndex = s2._siteIndex;
				s2._siteIndex = s1._siteIndex;
				s1._siteIndex = tempIndex;
			}
			
		}
		
		return returnValue;
	}
	


	private static var EPSILON = .005;
	private static function closeEnough(p0:Point, p1:Point):Bool {
		return Point.distance(p0, p1) < EPSILON;
	}
	public var coord(get_coord, null) : Point;
	private var _coord:Point;
	inline public function get_coord():Point {
		return _coord;
	}
	
	public var color:Int;
	public var weight:Float;
	
	private var _siteIndex:Int;
	
	// the edges that define this Site's Voronoi region:
	private var _edges:Vector<Edge>;
	public var edges(get_edges, null):Vector<Edge>;
	inline function get_edges():Vector<Edge>
	{
		return _edges;
	}
	// which end of each edge hooks up with the previous edge in _edges:
	private var _edgeOrientations:Vector<LR>;
	// ordered list of points that define the region clipped to bounds:
	private var _region:Vector<Point>;

	// use create instead.
	private function new(p:Point, index:Int, weight:Float, color:Int) {
		init(p, index, weight, color);
	}
	
	private function init(p:Point, index:Int, weight:Float, color:Int):Site
	{
		_coord = p;
		_siteIndex = index;
		this.weight = weight;
		this.color = color;
		_edges = new Vector<Edge>();
		_region = null;
		return this;
	}
	
	public function toString():String
	{
		return "Site " + _siteIndex + ": " + coord;
	}
	
	private function move(p:Point):Void
	{
		clear();
		_coord = p;
	}
	
	public function dispose():Void
	{
		_coord = null;
		clear();
		_pool.push(this);
	}
	
	private function clear():Void
	{
		if (_edges != null)
		{
			#if flash
			_edges.length = 0;
			#end
			_edges = null;
		}
		if (_edgeOrientations != null)
		{
			#if flash
			_edgeOrientations.length = 0;
			#end
			_edgeOrientations = null;
		}
		if (_region != null)
		{
			#if flash
			_region.length = 0;
			#end
			_region = null;
		}
	}
	
	public inline function addEdge(edge:Edge):Void
	{
		_edges.push(edge);
	}
	// TODO: Can be optimized.
	public function nearestEdge():Edge
	{
		_edges.sort(Edge.compareSitesDistances);
		return _edges[0];
	}
	
	public function neighborSites():Vector<Site>
	{
		if (_edges == null || _edges.length == 0)
		{
			return new Vector<Site>();
		}
		if (_edgeOrientations == null)
		{ 
			reorderEdges();
		}
		var list = new Vector<Site>();
		for (edge in _edges)
		{
			list.push(neighborSite(edge));
		}
		return list;
	}
		
	private function neighborSite(edge:Edge):Site
	{
		if (this == edge.leftSite)
		{
			return edge.rightSite;
		}
		if (this == edge.rightSite)
		{
			return edge.leftSite;
		}
		return null;
	}
	
	public function region(clippingBounds:Rectangle):Vector<Point> {
		if (_edges == null || _edges.length == 0)
		{
			return new Vector<Point>();
		}
		if (_edgeOrientations == null)
		{
			reorderEdges();
			_region = clipToBounds(clippingBounds);
			if ((new Polygon(_region)).winding() == Winding.CLOCKWISE)
			{
				_region.reverse();
			}
		}
		return _region;
	}
	
	private function reorderEdges():Void
	{
		//trace("_edges:", _edges);
		var reorderer = new EdgeReorderer(_edges, EdgeReorderer.edgeToLeftVertex, EdgeReorderer.edgeToRightVertex);
		_edges = reorderer.edges;
		//trace("reordered:", _edges);
		_edgeOrientations = reorderer.edgeOrientations;
		reorderer.dispose();
	}
	
	private function clipToBounds(bounds:Rectangle):Vector<Point>
	{
		var points:Vector<Point> = new Vector<Point>();
		var n:Int = _edges.length;
		var i:Int = 0;
		var edge:Edge;
		while (i < n && (_edges[i].visible == false))
		{
			++i;
		}
		
		if (i == n)
		{
			// no edges visible
			return new Vector<Point>();
		}
		edge = _edges[i];
		var orientation:LR = _edgeOrientations[i];
		points.push(edge.clippedEnds(orientation));
		points.push(edge.clippedEnds(LR.other(orientation)));
		
		for (j in (i + 1)...n)
		{
			edge = _edges[j];
			if (edge.visible == false)
			{
				continue;
			}
			connect(points, j, bounds);
		}
		// close up the polygon by adding another corner point of the bounds if needed:
		connect(points, i, bounds, true);
		
		return points;
	}
	
	private function connect(points:Vector<Point>, j:Int, bounds:Rectangle, closingUp:Bool = false):Void
	{
		var rightPoint = points[points.length - 1];
		var newEdge = _edges[j];
		var newOrientation:LR = _edgeOrientations[j];
		// the point that  must be connected to rightPoint:
		var newPoint = newEdge.clippedEnds(newOrientation);
		if (!closeEnough(rightPoint, newPoint))
		{
			// The points do not coincide, so they must have been clipped at the bounds;
			// see if they are on the same border of the bounds:
			if (rightPoint.x != newPoint.x
			&&  rightPoint.y != newPoint.y)
			{
				// They are on different borders of the bounds;
				// insert one or two corners of bounds as needed to hook them up:
				// (NOTE this will not be correct if the region should take up more than
				// half of the bounds rect, for then we will have gone the wrong way
				// around the bounds and included the smaller part rather than the larger)
				var rightCheck:Int = BoundsCheck.check(rightPoint, bounds);
				var newCheck:Int = BoundsCheck.check(newPoint, bounds);
				var px;
				var py;
				if (rightCheck & BoundsCheck.RIGHT != 0)
				{
					px = bounds.right;
					if (newCheck & BoundsCheck.BOTTOM != 0)
					{
						py = bounds.bottom;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.TOP != 0)
					{
						py = bounds.top;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.LEFT != 0)
					{
						if (rightPoint.y - bounds.y + newPoint.y - bounds.y < bounds.height)
						{
							py = bounds.top;
						}
						else
						{
							py = bounds.bottom;
						}
						points.push(new Point(px, py));
						points.push(new Point(bounds.left, py));
					}
				}
				else if (rightCheck & BoundsCheck.LEFT != 0)
				{
					px = bounds.left;
					if (newCheck & BoundsCheck.BOTTOM != 0)
					{
						py = bounds.bottom;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.TOP != 0)
					{
						py = bounds.top;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.RIGHT != 0)
					{
						if (rightPoint.y - bounds.y + newPoint.y - bounds.y < bounds.height)
						{
							py = bounds.top;
						}
						else
						{
							py = bounds.bottom;
						}
						points.push(new Point(px, py));
						points.push(new Point(bounds.right, py));
					}
				}
				else if (rightCheck & BoundsCheck.TOP != 0)
				{
					py = bounds.top;
					if (newCheck & BoundsCheck.RIGHT != 0)
					{
						px = bounds.right;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.LEFT != 0)
					{
						px = bounds.left;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.BOTTOM != 0)
					{
						if (rightPoint.x - bounds.x + newPoint.x - bounds.x < bounds.width)
						{
							px = bounds.left;
						}
						else
						{
							px = bounds.right;
						}
						points.push(new Point(px, py));
						points.push(new Point(px, bounds.bottom));
					}
				}
				else if (rightCheck & BoundsCheck.BOTTOM != 0)
				{
					py = bounds.bottom;
					if (newCheck & BoundsCheck.RIGHT != 0)
					{
						px = bounds.right;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.LEFT != 0)
					{
						px = bounds.left;
						points.push(new Point(px, py));
					}
					else if (newCheck & BoundsCheck.TOP != 0)
					{
						if (rightPoint.x - bounds.x + newPoint.x - bounds.x < bounds.width)
						{
							px = bounds.left;
						}
						else
						{
							px = bounds.right;
						}
						points.push(new Point(px, py));
						points.push(new Point(px, bounds.top));
					}
				}
			}
			if (closingUp)
			{
				// newEdge's ends have already been added
				return;
			}
			points.push(newPoint);
		}
		var newRightPoint = newEdge.clippedEnds(LR.other(newOrientation));
		if (!closeEnough(points[0], newRightPoint))
		{
			points.push(newRightPoint);
		}
	}
	
	public var x(get_x, null):Float;
	
	inline public function get_x() {
		return _coord.x;
	}

	public var y(get_y, null):Float;
	inline function get_y() {
		return _coord.y;
	}
	
	inline public function dist(p:ICoord)
	{
    if (p.coord == null) {
      trace("yeargla");
    }
    if (this.coord == null) {
      trace("pas yeargla");
    }
		return Point.distance(p.coord, this._coord);
	}

}


class PrivateConstructorEnforcer {}

import flash.geom.Point;
import flash.geom.Rectangle;

@: final class BoundsCheck
{
	public static var TOP:Int = 1;
	public static var BOTTOM:Int = 2;
	public static var LEFT:Int = 4;
	public static var RIGHT:Int = 8;
	
	/**
	 * 
	 * @param point
	 * @param bounds
	 * @return an Int with the appropriate bits set if the Point lies on the corresponding bounds lines
	 * 
	 */
	public static function check(point:Point, bounds:Rectangle):Int
	{
		var value:Int = 0;
		if (point.x == bounds.left)
		{
			value |= LEFT;
		} else if (point.x == bounds.right) {
			value |= RIGHT;
		}
		if (point.y == bounds.top)
		{
			value |= TOP;
		} else if (point.y == bounds.bottom) {
			value |= BOTTOM;
		}
		return value;
	}
	
	private function new()
	{
		throw "BoundsCheck constructor unused";
	}
	
}