package com.mindrocks.delaunay;

import flash.Vector;

@:final class EdgeReorderer {
	private var _edges:Vector<Edge>;
	private var _edgeOrientations:Vector<LR>;
	public var edges(get_edges, null):Vector<Edge>;
	inline public function get_edges():Vector<Edge> {
		return _edges;
	}
	public var edgeOrientations(get_edgeOrientations, null):Vector<LR>;
	
	inline public function get_edgeOrientations():Vector<LR> {
		return _edgeOrientations;
	}
	
	inline public static function edgeToLeftVertex(ed : Edge) : ICoord { return ed.leftVertex;}
	inline public static function edgeToLeftSite(ed : Edge) : ICoord { return ed.leftSite;}
	inline public static function edgeToRightVertex(ed : Edge) : ICoord { return ed.rightVertex;}
	inline public static function edgeToRightSite(ed : Edge) : ICoord { return ed.rightSite;}
	
	// TODO: use a adt to represent criterion.
	public function new(origEdges:Vector<Edge>, leftCoord: Edge -> ICoord, rightCoord: Edge -> ICoord) {
		_edges = new Vector<Edge>();
		_edgeOrientations = new Vector<LR>();
		if (origEdges.length > 0)
		{
			_edges = reorderEdges(origEdges, leftCoord, rightCoord);
		}
	}
	
	public function dispose():Void
	{
		_edges = null;
		_edgeOrientations = null;
	}

	private function reorderEdges(origEdges:Vector<Edge>, leftCoord: Edge -> ICoord, rightCoord: Edge -> ICoord):Vector<Edge> {
		var i:Int;
		var j:Int;
		var n:Int = origEdges.length;
		var edge:Edge;
		// we're going to reorder the edges in order of traversal
		var done:Vector<Bool> = new Vector<Bool>(n, true);
		var nDone:Int = 0;
		for (b in done) {
			b = false;
		}
		var newEdges:Vector<Edge> = new Vector<Edge>();
		
		i = 0;
		edge = origEdges[i];
		newEdges.push(edge);
		_edgeOrientations.push(LR.LEFT);
		var firstPoint:ICoord = leftCoord(edge);
		var lastPoint:ICoord = rightCoord(edge);
		
		if (firstPoint == Vertex.VERTEX_AT_INFINITY || lastPoint == Vertex.VERTEX_AT_INFINITY)
		{
			return new Vector<Edge>();
		}
		
		done[i] = true;
		++nDone;
		
		while (nDone < n)
		{
			for (i in 1...n)
			{
				if (done[i])
				{
					continue;
				}
				edge = origEdges[i];
				var leftPoint:ICoord = leftCoord(edge);
				var rightPoint:ICoord = rightCoord(edge);
				
				if (leftPoint == Vertex.VERTEX_AT_INFINITY || rightPoint == Vertex.VERTEX_AT_INFINITY)
				{
					return new Vector<Edge>();
				}
				if (leftPoint == lastPoint)
				{
					lastPoint = rightPoint;
					_edgeOrientations.push(LR.LEFT);
					newEdges.push(edge);
					done[i] = true;
				}
				else if (rightPoint == firstPoint)
				{
					firstPoint = leftPoint;
					_edgeOrientations.unshift(LR.LEFT);
					newEdges.unshift(edge);
					done[i] = true;
				}
				else if (leftPoint == firstPoint)
				{
					firstPoint = rightPoint;
					_edgeOrientations.unshift(LR.RIGHT);
					newEdges.unshift(edge);
					done[i] = true;
				}
				else if (rightPoint == lastPoint)
				{
					lastPoint = leftPoint;
					_edgeOrientations.push(LR.RIGHT);
					newEdges.push(edge);
					done[i] = true;
				}
				if (done[i])
				{
					++nDone;
				}
			}
		}
		
		return newEdges;
	}

}