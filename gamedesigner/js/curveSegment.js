var CurveSegment = function(start, control, end) {
	this.start = start;
	this.control = control;
	this.end = end;
	this.isTunnel = false;
	this.selectedPoint = null;
	this.selectedBombIndex = null;
	this.bombs = [];
	this.bombsT = [];
};

CurveSegment.unarchive = function(archive) {
	var bezierPoints = archive['bezier_points'];
	var start = Point.unarchive(bezierPoints['start']);
	var control = Point.unarchive(bezierPoints['control']);
	var end = Point.unarchive(bezierPoints['end']);

	var curveSegment = new CurveSegment(start, control, end);
	curveSegment.isTunnel = archive.type == 1;

	for (var i = 0; i < archive['bombs'].length; i++) {
		curveSegment.bombs.push(Bomb.unarchive(archive['bombs'][i]));
		curveSegment.bombsT.push(archive['bombsT'][i]);
	}

	return curveSegment;
};

CurveSegment.prototype.archive = function() {
	var archive = {};
	archive["type"] = this.isTunnel ? 1 : 0;
	archive["bezier_points"] = {
		"start": this.start.archive(),
		"control": this.control.archive(),
		"end": this.end.archive()
	};

	archive["arc_length"] = this.length();
	archive["bombs"] = [];
	archive["bombsT"] = [];

	for (var i = 0; i < this.bombs.length; i++) {
		archive["bombs"].push(this.bombs[i].archive());
		archive["bombsT"].push(this.bombsT[i]);
	}

	archive["all_points"] = [];

	var pointsCount = Math.floor(this.length() / Main.pointFrequence);
	var tInc = 1 / pointsCount;
	for (var t = 0; t <= 1; t += tInc) {
		if (t + tInc > 1)
			t = 1;
	
		var x = (1 - t) * (1 - t) * this.start.x + 2 * (1 - t) * t * this.control.x + t * t * this.end.x;
		var y = (1 - t) * (1 - t) * this.start.y + 2 * (1 - t) * t * this.control.y + t * t * this.end.y;
		var point = new Point(x, y);
		archive["all_points"].push(point.archive());
	}

	return archive;
};

CurveSegment.prototype.pointForX = function(x) {
	var t = this.tForX(x);
	var y = (1 - t) * (1 - t) * this.start.y + 2 * (1 - t) * t * this.control.y + t * t * this.end.y;
	var x = (1 - t) * (1 - t) * this.start.x + 2 * (1 - t) * t * this.control.x + t * t * this.end.x;
	return new Point(x, y);
};

CurveSegment.prototype.tForX = function(x) {
	var x1 = this.start.x;
  var x2 = this.control.x;
  var x3 = this.end.x
    
  var a = x1 - 2 * x2 + x3;
  var b = - 2 * x1 + 2 * x2;
  var c = x1 - x;
    
  var t1;
  var t2;
    
  if (a == 0) {
      t1 = -c / b;
      t2 = 0;
  } else {
      var rho = b * b - 4 * a * c;
      t1 = (- b + Math.sqrt(rho)) / (2 * a);
      t2 = (- b - Math.sqrt(rho)) / (2 * a);
  }
    
    if (t1 >= 0 && t1 <= 1) {
        return t1;
    }
    else if (t2 >= 0 && t2 <= 1) {
        return t2;
    }
    return 0;
}

CurveSegment.prototype.length = function() {
	var ax = this.start.x - 2*this.control.x + this.end.x;
	var ay = this.start.y - 2*this.control.y + this.end.y;
	var bx = 2*this.control.x - 2*this.start.x;
	var by = 2*this.control.y - 2*this.start.y;
	
	var a = 4*(ax*ax + ay*ay);
	var b = 4*(ax*bx + ay*by);
	var c = bx*bx + by*by;
	
	var abc = 2*Math.sqrt(a+b+c);
	var a2  = Math.sqrt(a);
	var a32 = 2*a*a2;
	var c2  = 2*Math.sqrt(c);
	var ba  = b/a2;
	var length = (a32*abc + a2*b*(abc-c2) + (4*c*a-b*b)*Math.log((2*a2+ba+abc)/(ba+c2)))/(4*a32);
	if (Number.isNaN(length)) {
		return Math.sqrt(Math.pow(this.end.x - this.start.x, 2) + Math.pow(this.end.y - this.start.y, 2));
	}
	return length;
};

CurveSegment.prototype.addBomb = function() {
	var t = 0.5;
	var midX = (1 - t) * (1 - t) * this.start.x + 2 * (1 - t) * t * this.control.x + t * t * this.end.x;
	var midY = (1 - t) * (1 - t) * this.start.y + 2 * (1 - t) * t * this.control.y + t * t * this.end.y;
	var bomb = new Bomb(new Point(midX, midY));
	this.bombsT.push(t);
	this.bombs.push(bomb);
};

CurveSegment.prototype.moveSelectedBomb = function(point) {
	if (this.selectedBombIndex == null)
		return;

	var t = (point.x - this.start.x) / (this.end.x - this.start.x);
	if (t < 0)
		t = 0;
	if (t > 1)
		t = 1;

	var x = (1 - t) * (1 - t) * this.start.x + 2 * (1 - t) * t * this.control.x + t * t * this.end.x;
	var y = (1 - t) * (1 - t) * this.start.y + 2 * (1 - t) * t * this.control.y + t * t * this.end.y;
	this.bombs[this.selectedBombIndex].move(new Point(x, y));
	this.bombsT[this.selectedBombIndex] = t;
};

CurveSegment.prototype.deleteSelectedBomb = function() {
	if (this.selectedBombIndex == null)
		return;

	this.bombs.splice(this.selectedBombIndex, 1);
	this.bombsT.splice(this.selectedBombIndex, 1);
};

CurveSegment.prototype.adjustBombs = function() {
	for (var i = 0; i < this.bombs.length; i++) {
		var t = this.bombsT[i];
		var midX = (1 - t) * (1 - t) * this.start.x + 2 * (1 - t) * t * this.control.x + t * t * this.end.x;
		var midY = (1 - t) * (1 - t) * this.start.y + 2 * (1 - t) * t * this.control.y + t * t * this.end.y;
		this.bombs[i].move(new Point(midX, midY));
	}
};

CurveSegment.prototype.selectBomb = function(point) {
	for (var i = 0; i < this.bombs.length; i++) {
		var bomb = this.bombs[i];
		if (bomb.pointInside(point)) {
			this.selectedBombIndex = i;
			return true;
		}
	}
	return false;
};

CurveSegment.prototype.startSlope = function() {
	return (this.control.y - this.start.y) / (this.control.x - this.start.x);
};

CurveSegment.prototype.endSlope = function() {
	return (this.end.y - this.control.y) / (this.end.x - this.control.x);
};

CurveSegment.prototype.selectPoint = function(point, withStart) {
	var offset = 8;

	if (point.x > this.control.x - offset && point.x < this.control.x + offset && point.y > this.control.y - offset && point.y < this.control.y + offset) {
		this.selectedPoint = "control";
		return true;
	}

	if (point.x > this.end.x - offset && point.x < this.end.x + offset && point.y > this.end.y - offset && point.y < this.end.y + offset) {
		this.selectedPoint = "end";
		return true;
	}

	if (withStart && point.x > this.start.x - offset && point.x < this.start.x + offset && point.y > this.start.y - offset && point.y < this.start.y + offset) {
		this.selectedPoint = "start";
		return true;
	}
	return false;
};

CurveSegment.prototype.deselect = function() {
	this.selectedPoint = null;
};

CurveSegment.prototype.boundingRect = function() {
	var origin = new Point(Math.min(this.start.x, this.control.x, this.end.x), Math.min(this.start.y, this.control.y, this.end.y));
	var width = Math.max(Math.abs(this.end.x - this.start.x), Math.abs(this.end.x - this.control.x), Math.abs(this.control.x - this.start.x));
	var height = Math.max(Math.abs(this.end.y - this.start.y), Math.abs(this.end.y - this.control.y), Math.abs(this.start.y - this.control.y));
	if (height < 16) {
		origin.y -= (16 - height) / 2;
		height = 16;
	}
	return {"origin": origin, size: {"width": width, "height": height}};
};

CurveSegment.prototype.draw = function(ctx, pointsToShow, color) {
	ctx.save();
	ctx.strokeStyle = color;
	if (pointsToShow.control)  {
		ctx.save();
		ctx.strokeStyle = "rgb(255, 0, 0)";
		ctx.strokeRect(this.control.x - 4, this.control.y - 4, 8, 8);
		ctx.restore();
	}
	if (pointsToShow.end)
		ctx.fillRect(this.end.x - 4, this.end.y - 4, 8, 8);
	if (pointsToShow.start)
		ctx.fillRect(this.start.x - 4, this.start.y - 4, 8, 8);

	ctx.beginPath();
	ctx.moveTo(this.start.x, this.start.y);
	ctx.quadraticCurveTo(this.control.x, this.control.y, this.end.x, this.end.y);
	if (this.isTunnel)
		ctx.lineWidth = 5;
	else
		ctx.lineWidth = 1;
	ctx.stroke();

	if (!this.isTunnel) {
		for (var i = 0; i < this.bombs.length; i++) {
			var bomb = this.bombs[i];
			bomb.draw(ctx);
		}
	}
	ctx.restore();
};