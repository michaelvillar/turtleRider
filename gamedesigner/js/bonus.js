var Bonus = function(point) {
	this.position = point;
	this.radius = 10;
};

Bonus.unarchive = function(archive) {
	return new Bonus(Point.unarchive(archive['position']));
};

Bonus.prototype.pointInside = function(point) {
	return (point.x > this.position.x - this.radius && point.x < this.position.x + this.radius &&
			point.y > this.position.y - this.radius && point.y < this.position.y + this.radius);
};

Bonus.prototype.move = function(point) {
	this.position = point;
};

Bonus.prototype.archive = function() {
	return {"position": this.position.archive()};
};

Bonus.prototype.draw = function(ctx) {
	ctx.save();
	ctx.beginPath();
	ctx.arc(this.position.x, this.position.y, this.radius, 0, 2 * Math.PI, false);
  ctx.fillStyle = 'rgb(251, 217, 45)';
  ctx.fill();
  ctx.lineWidth = 2;
  ctx.strokeStyle = 'rbg(0, 0, 0)';
  ctx.stroke();
  ctx.restore();
};