var Curve = function(origin) {
	this.segments = [];
	this.hoveredSegmentIndex = null;
	this.selectedPointSegmentIndex = null;
	this.isSegmentSelected = false;
	this.selectedBombSegmentIndex = null;
};

Curve.unarchive = function(archive) {
	var curve = new Curve();

	for (var i = 0; i < archive['segments'].length; i++) {
		var segment = archive['segments'][i];
		if (segment.type == 2)
			curve.segments.push(LoopingSegment.unarchive(segment));
		else
			curve.segments.push(CurveSegment.unarchive(segment));
	}

	return curve;
};

Curve.prototype.pointForX = function(x) {
	for (var i = 0; i < this.segments.length; i++) {
		var segment = this.segments[i];
		if (x >= segment.start.x && x <= segment.end.x) {
			return segment.pointForX(x);
		}
	}
	if (x < this.segments[0].start)
		return this.segments[0].start;
	return this.segments[this.segments.length - 1].end;
}

Curve.prototype.addBomb = function() {
	if (this.hoveredSegmentIndex == null)
		return;

	this.segments[this.hoveredSegmentIndex].addBomb();
};

Curve.prototype.moveSelectedBomb = function(point) {
	if (this.selectedBombSegmentIndex == null)
		return;

	this.segments[this.selectedBombSegmentIndex].moveSelectedBomb(point);
};

Curve.prototype.deleteSelectedBomb = function() {
	if (this.selectedBombSegmentIndex == null)
		return;

	this.segments[this.selectedBombSegmentIndex].deleteSelectedBomb();
};

Curve.prototype.addPoint = function(point, startPoint, shiftPressed, altPressed) {
	var lastSegment = this.segments[this.segments.length - 1];

	if (lastSegment) {
		var cx;
		var cy;
		if (shiftPressed) {
			point.y = lastSegment.end.y + (point.x - lastSegment.end.x) * lastSegment.endSlope();
			cx = lastSegment.end.x + (point.x - lastSegment.end.x) / 2;
			cy = lastSegment.end.y + (point.y - lastSegment.end.y) / 2;
		} else if (altPressed) {
			var slope = lastSegment.endSlope();
			if (slope != 0) {
				cx = (point.y - lastSegment.end.y) / lastSegment.endSlope() + lastSegment.end.x;
				if (cx > lastSegment.end.x && cx < point.x)
					cy = point.y;
				else {
					cx = lastSegment.end.x + (point.x - lastSegment.end.x) / 2;
					cy = lastSegment.end.y + (cx - lastSegment.end.x) * lastSegment.endSlope();
				}
			}
		} else {
			cx = lastSegment.end.x + (point.x - lastSegment.end.x) / 2;
			cy = lastSegment.end.y + (cx - lastSegment.end.x) * lastSegment.endSlope();
		}

		var control = new Point(cx, cy);
		this.segments.push(new CurveSegment(lastSegment.end, control, point));
	} else {
		if (startPoint) {
			if (shiftPressed) 
				point.y = startPoint.y;
			this.segments.push(new CurveSegment(startPoint, new Point(startPoint.x + (point.x - startPoint.x) / 2, startPoint.y), point));
		} else
			this.segments.push(new CurveSegment(point, new Point(point.x + 50, point.y), new Point(point.x + 100, point.y)));
	}
};

Curve.prototype.selectPoint = function(point) {
	for (var i = 0; i < this.segments.length; i++) {
		var segment = this.segments[i];
		if (segment.selectPoint(point, i == 0)) {
			this.selectedPointSegmentIndex = i;
			return true;
		}
	}
	return false;
};

Curve.prototype.selectBomb = function(point) {
	for (var i = 0; i < this.segments.length; i++) {
		var segment = this.segments[i];
		if (segment instanceof CurveSegment && segment.selectBomb(point)) {
			this.selectedBombSegmentIndex = i;
			return true;
		}
	}
	return false;
};

Curve.prototype.moveSelectedPoint = function(point, shiftPressed) {
	var segment = this.segments[this.selectedPointSegmentIndex];
	if (segment instanceof LoopingSegment)
		segment = segment.originalSegment;
	else
		segment.adjustBombs();

	switch(this.segments[this.selectedPointSegmentIndex].selectedPoint) {
		case "control":
			var slope = segment.startSlope();
			segment.control = new Point(point.x, segment.control.y + (point.x - segment.control.x) * slope);
			this.propagateChangeFromIndex(this.selectedPointSegmentIndex + 1);
			break;

		case "end":
			if (shiftPressed)
				point.y = segment.end.y + (point.x - segment.end.x) * segment.endSlope();
			segment.end = point;
			if (this.selectedPointSegmentIndex + 1 < this.segments.length) {
				if (this.segments[this.selectedPointSegmentIndex + 1] instanceof LoopingSegment)
					this.segments[this.selectedPointSegmentIndex + 1].originalSegment.start = segment.end;
				else
					this.segments[this.selectedPointSegmentIndex + 1].start = segment.end;
			}
			segment.control.x = segment.start.x + (segment.end.x - segment.start.x) / 2;
			this.propagateChangeFromIndex(this.selectedPointSegmentIndex);
			break;

		case "start":
			segment.start = point;
			break;
	}

	if (this.segments[this.selectedPointSegmentIndex] instanceof LoopingSegment) {
		this.segments[this.selectedPointSegmentIndex].init();
	}
};

Curve.prototype.selectSegment = function(point) {
	for (var i = 0; i < this.segments.length; i++) {
		var segment = this.segments[i];
		segment.deselect();
		var rect = segment.boundingRect();
		if (point.x > rect.origin.x && point.x < rect.origin.x + rect.size.width && point.y > rect.origin.y && point.y < rect.origin.y + rect.size.height) {
			this.hoveredSegmentIndex = i;
			return true;
		}
	}
	return false;
};

Curve.prototype.deleteSelected = function() {
	var index = this.selectedPointSegmentIndex || this.hoveredSegmentIndex;
	var segment = this.segments[index];
	if (index + 1 < this.segments.length) {
		var nextSegment = this.segments[index + 1];
		if (nextSegment instanceof LoopingSegment) {
			nextSegment.originalSegment.start = segment.start;
			nextSegment.init();
		} else
			nextSegment.start = segment.start;
	}

	this.segments.splice(index, 1);

	this.propagateChangeFromIndex(index);

	this.deselectSegment();
}

Curve.prototype.deselectPoint = function() {
	if (this.selectedPointSegmentIndex) {
		var segment = this.segments[this.selectedPointSegmentIndex];
		segment.deselect();
	}
	this.selectedPointSegmentIndex = null;
};

Curve.prototype.deselectSegment = function() {
	this.hoveredSegmentIndex = null;
	this.isSegmentSelected = false;
};

Curve.prototype.switchSelectedSegmentWithTunnel = function() {
	var segment = this.segments[this.hoveredSegmentIndex];
	segment.isTunnel = !segment.isTunnel;
};


Curve.prototype.switchSelectedSegmentWithLooping = function() {
	var segment = this.segments[this.hoveredSegmentIndex];
	if (segment instanceof CurveSegment) {
		var loopingSegment = new LoopingSegment(segment);
		this.segments[this.hoveredSegmentIndex] = loopingSegment;
	} else {
		this.segments[this.hoveredSegmentIndex] = segment.originalSegment;
	}
};

Curve.prototype.propagateChangeFromIndex = function(index) {
	index = index < 1 ? 1 : index;
	while (index < this.segments.length) {
		var currentSegment = this.segments[index];
		var lastSegment = this.segments[index - 1];
		
		//Change control point
		var toModifySegment = currentSegment;
		if (toModifySegment instanceof LoopingSegment)
			toModifySegment = toModifySegment.originalSegment;

		var cx = lastSegment.end.x + (toModifySegment.end.x - lastSegment.end.x) / 2;
		var cy = lastSegment.end.y + (cx - lastSegment.end.x) * lastSegment.endSlope();
		toModifySegment.control = new Point(cx, cy);

		if (currentSegment instanceof LoopingSegment)
			currentSegment.init();
		else
			currentSegment.adjustBombs();

		index++;
	}
}

Curve.prototype.isEmpty = function() {
	return this.segments.length == 0;
};

Curve.prototype.archive = function() {
	var archive = {};
	archive["segments"] = [];

	for (var i = 0; i < this.segments.length; i++)
		archive["segments"].push(this.segments[i].archive());

	return archive;
};

Curve.prototype.draw = function(ctx, normalMode, color) {
	for (var i = 0; i < this.segments.length; i++) {
		var segment = this.segments[i];
		if (normalMode) {
			var pointsToShow = {"end": true, "control": true}
			if (i == 0)
				pointsToShow["start"] = true;
			segment.draw(ctx, pointsToShow, color);

			if (i == this.hoveredSegmentIndex) {
				ctx.save();
				if (this.isSegmentSelected)
					ctx.strokeStyle = "rgb(250, 150, 150)";
				else
					ctx.strokeStyle = "rgb(150, 150, 150)";
				var rect = segment.boundingRect();
				ctx.strokeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
				ctx.restore();
			}
		} else {
			segment.draw(ctx, {}, color);
		}
	}
};



