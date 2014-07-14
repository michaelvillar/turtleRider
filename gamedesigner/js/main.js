var Main = function() {
	this.canvas = document.getElementById("canvas");
	this.ctx = this.canvas.getContext("2d"); 
	this.curves = [];
	this.bonuses = [];
	this.turtleImage = new Image(65, 38);
	this.turtleImage.src = 'img/turtle-hd.png';
	this.state = Main.states['NORMAL_STATE'];
	this.stateInfo = {};
	this.shiftPressed = false;
	this.altPressed = false;
};

Main.pointFrequence = 10; 
Main.gridYCount = Math.floor(document.getElementById("canvas").height / 320);
Main.gridBorder = 40;;
Main.barHeight = parseInt(window.getComputedStyle(document.getElementById("top-bar")).height.match(/(\d*).*$/)[1]);
Main.magnetGridSize = 5;
Main.origin = new Point(Main.gridBorder, Main.gridBorder + Main.barHeight + Main.gridYCount * 320 / 2);
Main.origin.y = Math.round(Main.origin.y / Main.magnetGridSize) * Main.magnetGridSize;

Main.states = {
	"NORMAL_STATE": 0,
	"EDIT_CURVE_POINT_STATE": 1,
	"HOVERED_CURVE_STATE": 2,
	"EDIT_CURVE_STATE": 3,
	"EDIT_BONUS_STATE": 4,
	"HOVERED_CURVE_OPTION": 5,
	"EDIT_BOMB_STATE": 6
};

Main.prototype.init = function() {
	document.getElementById("add_curve").addEventListener("click", this.didClickCurveButton.bind(this));
	document.getElementById("add_bonus").addEventListener("click", this.didClickBonusButton.bind(this));
	document.getElementById("add_bomb").addEventListener("click", this.didClickBombButton.bind(this));
	document.getElementById("add_looping").addEventListener("click", this.didClickLoopingButton.bind(this));
	document.getElementById("add_tunnel").addEventListener("click", this.didClickTunnelButton.bind(this));
	document.getElementById("export").addEventListener("click", this.didClickExportButton.bind(this));
	document.getElementById("load").addEventListener("change", this.didClickLoadButton.bind(this));
	document.getElementById("canvas").addEventListener("click", this.didClickCanvas.bind(this));
	document.getElementById("canvas").addEventListener("mousemove", this.didMoveMouseOnCanvas.bind(this));
	document.addEventListener("keyup", this.didReleaseKey.bind(this));
	document.addEventListener("keydown", this.didPressKey.bind(this));

	this.ctx.font = "20px Arial";

	this.draw();
	setTimeout(function() {
		window.scrollTo(0, document.body.offsetHeight / 2 - 320);
	}.bind(this), 100);
};

Main.prototype.draw = function() {
	this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

	//Draw grid

	this.ctx.save();
	this.ctx.strokeStyle = "rgb(170, 170, 170)";
	this.ctx.fillStyle = "rgb(170, 170, 170)";
	this.ctx.beginPath();

	var j = 0;
	for (var i = Main.gridBorder; i < this.canvas.width - Main.gridBorder; i += 568) {
		this.ctx.moveTo(i, Main.gridBorder + Main.barHeight);
		this.ctx.lineTo(i, this.canvas.height - Main.gridBorder);
		this.ctx.stroke();
		this.ctx.fillText(j, i + 568 / 2 - this.ctx.measureText(j).width / 2, Main.barHeight + 30);
		j++;
	}

	j = -Math.floor(Main.gridYCount / 2);
	for (var i = Main.gridBorder + Main.barHeight; i < this.canvas.height - Main.gridBorder; i += 320) {
		this.ctx.moveTo(Main.gridBorder, i);
		this.ctx.lineTo(this.canvas.width - Main.gridBorder, i);
		this.ctx.stroke();
		this.ctx.fillText(j, 10, i + 320 / 2);
		j++;
	}

	this.ctx.restore();

	for (var i = 0; i < this.bonuses.length; i++) {
		var bonus = this.bonuses[i];
		bonus.draw(this.ctx);
	}

	for (var i = 0; i < this.curves.length; i++) {
		this.curves[i].draw(this.ctx);
	}

	this.ctx.drawImage(this.turtleImage, Main.origin.x, Main.origin.y - this.turtleImage.height, this.turtleImage.width, this.turtleImage.height);
};


Main.prototype.addPoint = function(point) {
	if (this.curves.length == 0)
		this.addCurve();

	var index = document.getElementById("curves").selectedIndex;
	index = index == -1 ? 0 : index;

	var curve = this.curves[index];

	if (this.curves.length == 1 && this.curves[0].isEmpty())
		curve.addPoint(point, Main.origin, this.shiftPressed, this.altPressed);
	else
		curve.addPoint(point, null, this.shiftPressed, this.altPressed);

};

Main.prototype.selectCurveSegment = function(point) {
	for (var i = 0; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.selectSegment(point)) {
			this.stateInfo.curveIndex = i;
			return true;
		}
	}
	return false;
}

Main.prototype.selectCurvePoint = function(point) {
	for (var i = 0; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.selectPoint(point)) {
			this.stateInfo.curveIndex = i;
			return true;
		}
	}
	return false;
};

Main.prototype.selectBonus = function(point) {
	for (var i = 0; i < this.bonuses.length; i++) {
		var bonus = this.bonuses[i];
		if (bonus.pointInside(point)) {
			this.stateInfo.bonusIndex = i;
			return true;
		}
	}
	return false;
};

Main.prototype.selectBomb = function(point) {
	for (var i = 0; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.selectBomb(point)) {
			this.stateInfo.bombCurveIndex = i;
			return true;
		}
	}
	return false;
};


Main.prototype.enableButtons = function(segment) {
	var tunnelButton = document.getElementById("add_tunnel");
	tunnelButton.disabled = false;
	tunnelButton.value = "Switch to tunnel/curve";

	var loopingButton = document.getElementById("add_looping");
	loopingButton.disabled = false;
	loopingButton.value = "Switch to looping/curve";

	var bombButton = document.getElementById("add_bomb");
	bombButton.disabled = false;
};

Main.prototype.disableButtons = function() {
	var tunnelButton = document.getElementById("add_tunnel");
	tunnelButton.disabled = true;

	var loopingButton = document.getElementById("add_looping");
	loopingButton.disabled = true;

	var bombButton = document.getElementById("add_bomb");
	bombButton.disabled = true;
};

Main.prototype.addCurve = function() {
	this.curves.push(new Curve());
	this.updateSelectCurves();
	document.getElementById("curves").value = "curve" + (this.curves.length - 1);
};

Main.prototype.removeCurve = function(index) {
	this.curves.splice(index, 1);
	this.updateSelectCurves();
	document.getElementById("curves").value = "curve" + (this.curves.length - 1);
};

Main.prototype.updateSelectCurves = function() {
	var str = "";
	for (var i = 0; i < this.curves.length; i++) {
		str += '<option value="curve'+i+'">'+"Curve " + (i + 1) +'</option>';
	}
	document.getElementById("curves").innerHTML = str;
};

Main.prototype.archive = function() {
	var archive = {};
	archive["curves"] = [];

	for (var i = 0; i < this.curves.length; i++)
		archive["curves"].push(this.curves[i].archive());

	archive["bonuses"] = [];

	for (var i = 0; i < this.bonuses.length; i++)
		archive["bonuses"].push(this.bonuses[i].archive());

	return archive;
};

Main.prototype.unarchive = function(archive) {
	this.curves = [];
	for (var i = 0; i < archive['curves'].length; i++)
		this.curves.push(Curve.unarchive(archive['curves'][i]));

	this.bonuses = [];
	for (var i = 0; i < archive['bonuses'].length; i++)
		this.bonuses.push(Bonus.unarchive(archive['bonuses'][i]));

	this.state = Main.states['NORMAL_STATE'];
	this.stateInfo = {};
};

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

Main.prototype.didClickCanvas = function(e) {
	var x = Math.round(e.pageX / Main.magnetGridSize) * Main.magnetGridSize;
	var y = Math.round(e.pageY / Main.magnetGridSize) * Main.magnetGridSize;
	var point = new Point(x, y);
	console.log(Math.round(e.pageY / Main.magnetGridSize));

	switch(this.state) {
		case Main.states['NORMAL_STATE']: 
			if (this.selectCurvePoint(point)) {
				this.state = Main.states['EDIT_CURVE_POINT_STATE'];
			} else if (this.selectBonus(point)) {
				this.state = Main.states['EDIT_BONUS_STATE']
			} else if (this.selectBomb(point)) {
				this.state = Main.states['EDIT_BOMB_STATE'];
			} else {
				this.addPoint(point);
			}
			break;

		case Main.states['EDIT_CURVE_POINT_STATE']:
			this.curves[this.stateInfo.curveIndex].deselectPoint();
			this.state = Main.states['NORMAL_STATE'];
			break;

		case Main.states['EDIT_BONUS_STATE']:
			this.state = Main.states['NORMAL_STATE'];
			break;

		case Main.states['EDIT_BOMB_STATE']:
			this.state = Main.states['NORMAL_STATE'];
			break;

		case Main.states['HOVERED_CURVE_STATE']:
			if (this.selectCurvePoint(point)) {
				this.curves[this.stateInfo.curveIndex].deselectSegment();
				this.state = Main.states['EDIT_CURVE_POINT_STATE'];
			} else {
				this.curves[this.stateInfo.curveIndex].isSegmentSelected = true;
				this.enableButtons();
				this.state = Main.states['EDIT_CURVE_STATE'];
			}
			break;

		case Main.states['EDIT_CURVE_STATE']:
			this.disableButtons();
			this.curves[this.stateInfo.curveIndex].deselectSegment();
			this.state = Main.states['NORMAL_STATE'];
			break;
	}

	this.draw();
}

Main.prototype.didMoveMouseOnCanvas = function(e) {
	var x = Math.round(e.pageX / Main.magnetGridSize) * Main.magnetGridSize;
	var y = Math.round(e.pageY / Main.magnetGridSize) * Main.magnetGridSize;
	var point = new Point(x, y);

	switch(this.state) {
		case Main.states['NORMAL_STATE']:
			if (this.selectCurveSegment(point)) {
				if (this.selectCurvePoint(point)) {
					this.curves[this.stateInfo.curveIndex].deselectSegment();
					this.curves[this.stateInfo.curveIndex].deselectPoint();
				} else if (this.selectBonus(point) || this.selectBomb(point))  {
					this.curves[this.stateInfo.curveIndex].deselectSegment();
				} else
					this.state = Main.states['HOVERED_CURVE_STATE'];
			}
			break;

		case Main.states['HOVERED_CURVE_STATE']:
			if (this.selectCurveSegment(point)) {
				if (this.selectCurvePoint(point)) {
					this.curves[this.stateInfo.curveIndex].deselectSegment();
					this.curves[this.stateInfo.curveIndex].deselectPoint();
					this.state = Main.states['NORMAL_STATE'];
				} else if (this.selectBonus(point)) {
					this.curves[this.stateInfo.curveIndex].deselectSegment();
					this.state = Main.states['NORMAL_STATE'];
				} else if (this.selectBomb(point)) {
					this.curves[this.stateInfo.curveIndex].deselectSegment();
					this.state = Main.states['NORMAL_STATE'];
				} else {
					this.state = Main.states['HOVERED_CURVE_STATE'];
				}
			} else {
				this.curves[this.stateInfo.curveIndex].deselectSegment()
				this.state = Main.states['NORMAL_STATE'];
			}
			break;

		case Main.states['EDIT_CURVE_POINT_STATE']:
			var curve = this.curves[this.stateInfo.curveIndex];
			curve.moveSelectedPoint(point, this.shiftPressed);
			break;

		case Main.states['EDIT_BONUS_STATE']:
			var bonus = this.bonuses[this.stateInfo.bonusIndex];
			bonus.move(point);
			break;

		case Main.states['EDIT_BOMB_STATE']:
			var curve = this.curves[this.stateInfo.bombCurveIndex];
			curve.moveSelectedBomb(point);
			break;
	}

	this.draw();
};

Main.prototype.didClickCurveButton = function() {
	this.addCurve();
};

Main.prototype.didClickBonusButton = function() {
	var bonus = new Bonus(new Point(document.body.clientWidth / 2 + document.body.scrollLeft, 100 + document.body.scrollTop));
	this.bonuses.push(bonus);
	this.draw();
};

Main.prototype.didClickBombButton = function() {
	if (this.state != Main.states['EDIT_CURVE_STATE'])
		return;

	this.curves[this.stateInfo.curveIndex].addBomb();
	this.curves[this.stateInfo.curveIndex].deselectSegment();
	this.disableButtons();
	this.state = Main.states['NORMAL_STATE'];
	this.draw();
};

Main.prototype.didClickLoopingButton = function() {
	if (this.state == Main.states['EDIT_CURVE_STATE']) {
		var curve = this.curves[this.stateInfo.curveIndex];
		curve.switchSelectedSegmentWithLooping();
		this.disableButtons();
		this.curves[this.stateInfo.curveIndex].deselectSegment();
		this.state = Main.states['NORMAL_STATE'];
		this.draw();
	}
};

Main.prototype.didClickTunnelButton = function() {
	if (this.state == Main.states['EDIT_CURVE_STATE']) {
		var curve = this.curves[this.stateInfo.curveIndex];
		curve.switchSelectedSegmentWithTunnel();
		this.disableButtons();
		this.curves[this.stateInfo.curveIndex].deselectSegment();
		this.state = Main.states['NORMAL_STATE'];
		this.draw();
	}
};

Main.prototype.didPressKey = function(e) {
	if (e.keyCode == 16) {
		e.preventDefault();
		this.shiftPressed = true;
	} else if (e.keyCode == 18) {
		this.altPressed = true;
	} else if (e.keyCode == 8)
		e.preventDefault();
};

Main.prototype.didReleaseKey = function(e) {
	if (e.keyCode == 16) {
		e.preventDefault();
		this.shiftPressed = false;
	} else if (e.keyCode == 18) {
		e.preventDefault();
		this.altPressed = false;
	} else if (e.keyCode == 8) {
		e.preventDefault();
		switch(this.state) {
			case Main.states['EDIT_CURVE_POINT_STATE']:
			case Main.states['EDIT_CURVE_STATE']:
				var curve = this.curves[this.stateInfo.curveIndex];
				curve.deleteSelected();
				this.state = Main.states['NORMAL_STATE'];
				if (curve.isEmpty())
					this.removeCurve(this.stateInfo.curveIndex);
				break;

			case Main.states['EDIT_BONUS_STATE']:
				this.bonuses.splice(this.stateInfo.bonusIndex, 1);
				this.state = Main.states['NORMAL_STATE'];
				break;

			case Main.states['EDIT_BOMB_STATE']:
				this.curves[this.stateInfo.bombCurveIndex].deleteSelectedBomb();
				this.state = Main.states['NORMAL_STATE'];
				break;
		}
		this.disableButtons();
		this.draw();	
	}
};

Main.prototype.didClickExportButton = function(e) {
	var archive = this.archive();
	FileManager.saveToDisk(archive);
};

Main.prototype.didClickLoadButton = function(e) {
	var files = e.target.files;
	if (files.length <= 0 || files.length > 1)
		return null;

	FileManager.loadFile(files[0], function(archive) {
		this.unarchive(archive);
		this.draw();
	}.bind(this));
};

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

window.addEventListener("load", function() {
	new Main().init();
});