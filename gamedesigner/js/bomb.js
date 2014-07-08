var Bomb = function(point) {
	this.position = point;
	this.radius = 7;
};

Bomb.unarchive = function(archive) {
	return new Bomb(Point.unarchive(archive['position']));
};

Bomb.prototype.pointInside = function(point) {
	return (point.x > this.position.x - this.radius && point.x < this.position.x + this.radius &&
			point.y > this.position.y - this.radius && point.y < this.position.y + this.radius);
};

Bomb.prototype.move = function(point) {
	this.position = point;
};

Bomb.prototype.archive = function() {
	return {"position": this.position.archive()};
};

Bomb.prototype.draw = function(ctx) {
	ctx.save();
	ctx.beginPath();
	ctx.arc(this.position.x, this.position.y, this.radius, 0, 2 * Math.PI, false);
  ctx.fillStyle = 'rgb(200, 36, 30)';
  ctx.fill();
  ctx.lineWidth = 2;
  ctx.strokeStyle = 'rbg(0, 0, 0)';
  ctx.stroke();
  ctx.restore();
};