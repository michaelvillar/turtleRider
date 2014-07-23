var Main = function() {
	this.canvas = document.getElementById("canvas");
	this.ctx = this.canvas.getContext("2d"); 
	this.curves = [];
	this.addCurve();
	this.addCurve();
	this.selectedCurveIndex = 1;
	this.bonuses = [];
	this.turtleImage = new Image(65, 38);
	this.turtleImage.src = 'img/turtle-hd.png';
	this.state = Main.states['NORMAL_STATE'];
	this.stateInfo = {};
	this.shiftPressed = false;
	this.altPressed = false;
	this.screenType = Main.screenTypes["LARGE_TYPE"];
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
	"EDIT_SCALE_GUIDE_STATE": 5,
	"EDIT_CAMERA_GUIDE_STATE": 6,
	"CAMERA_MODE_STATE": 7
};

Main.screenTypes = {
	"LARGE_TYPE": 0,
	"SMALL_TYPE": 1
}

Main.prototype.init = function() {
	document.getElementById("curves").addEventListener("change", this.didChangeCurve.bind(this));
	document.getElementById("add_curve").addEventListener("click", this.didClickCurveButton.bind(this));
	document.getElementById("add_bonus").addEventListener("click", this.didClickBonusButton.bind(this));
	document.getElementById("add_scale_guide").addEventListener("click", this.didClickScaleGuideButton.bind(this));
	document.getElementById("add_camera_guide").addEventListener("click", this.didClickCameraGuideButton.bind(this));
	document.getElementById("add_looping").addEventListener("click", this.didClickLoopingButton.bind(this));
	document.getElementById("camera_mode").addEventListener("click", this.didClickCameraModeButton.bind(this));
	document.getElementById("screen_type").addEventListener("click", this.didClickScreenTypeButton.bind(this));
	document.getElementById("export").addEventListener("click", this.didClickExportButton.bind(this));
	document.getElementById("load").addEventListener("change", this.didClickLoadButton.bind(this));
	document.getElementById("canvas").addEventListener("click", this.didClickCanvas.bind(this));
	document.getElementById("canvas").addEventListener("mousemove", this.didMoveMouseOnCanvas.bind(this));
	document.addEventListener("keyup", this.didReleaseKey.bind(this));
	document.addEventListener("keydown", this.didPressKey.bind(this));

	this.ctx.font = "20px Arial";

	this.editButtonsState();

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

	if (this.selectedCurveIndex == 0) {
		if (this.state == Main.states["CAMERA_MODE_STATE"])
			this.curves[0].draw(this.ctx, false, "rgb(150, 150, 150)");
		else
			this.curves[0].draw(this.ctx, true, "rgb(0, 0, 0)");
	}

	var color;

	if (this.selectedCurveIndex == 0 && this.state != Main.states["CAMERA_MODE_STATE"])
		color = "rgb(100, 100, 100)";
	else  
		color = "rgb(0, 0, 0)";

	for (var i = 1; i < this.curves.length; i++) {
		this.curves[i].draw(this.ctx, this.selectedCurveIndex != 0, color);
	}

	if (this.state == Main.states["CAMERA_MODE_STATE"]) {
		var point = this.stateInfo["cameraPosition"];
		var scale = this.stateInfo["cameraScale"];
		var characterPosition = this.stateInfo["characterPosition"];

		this.ctx.save();
		this.ctx.fillStyle = "rgb(0, 150, 0)";
		this.ctx.beginPath();
		this.ctx.arc(characterPosition.x , characterPosition.y, 10, 0, 2 * Math.PI);
		this.ctx.fill();

		this.ctx.strokeStyle = this.ctx.fillStyle;
		if (this.screenType == Main.screenTypes["LARGE_TYPE"])
			this.ctx.strokeRect(point.x, point.y, 568 / scale, 320 / scale);
		else
			this.ctx.strokeRect(point.x, point.y, 480 / scale, 320 / scale);
		this.ctx.restore();
	}


	this.ctx.drawImage(this.turtleImage, Main.origin.x, Main.origin.y - this.turtleImage.height, this.turtleImage.width, this.turtleImage.height);
};


Main.prototype.addPoint = function(point) {
	if (this.curves.length == 0)
		this.addCurve();

	var index = document.getElementById("curves").selectedIndex;
	index = index == -1 ? 0 : index;

	var curve = this.curves[index];

	if ((this.selectedCurveIndex == 0 || this.selectedCurveIndex == 1) && this.curves[index].isEmpty())
		curve.addPoint(point, Main.origin, this.shiftPressed, this.altPressed);
	else
		curve.addPoint(point, null, this.shiftPressed, this.altPressed);

};

Main.prototype.selectCurveSegment = function(point) {
	if (this.selectedCurveIndex == 0) {
		if (this.curves[0].selectSegment(point)) {
			this.stateInfo.curveIndex = 0;
			return true;
		}
		return false;
	}

	for (var i = 1; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.selectSegment(point)) {
			this.stateInfo.curveIndex = i;
			return true;
		}
	}
	return false;
}

Main.prototype.selectCurvePoint = function(point) {
	if (this.selectedCurveIndex == 0) {
		if (this.curves[0].selectPoint(point)) {
			this.stateInfo.curveIndex = 0;
			return true;
		}
		return false;
	}

	for (var i = 1; i < this.curves.length; i++) {
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

Main.prototype.selectScaleGuide = function(point) {
	for (var i = 0; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.selectScaleGuide(point)) {
			this.stateInfo.scaleGuideIndex = i;
			return true;
		}
	}
	return false;
};

Main.prototype.selectCameraGuide = function(point) {
	for (var i = 0; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.selectCameraGuide(point)) {
			this.stateInfo.cameraGuideIndex = i;
			return true;
		}
	}
	return false;
};


Main.prototype.editButtonsState = function() {
	var loopingButton = document.getElementById("add_looping");
	var scaleGuideButton = document.getElementById("add_scale_guide");
	var cameraGuideButton = document.getElementById("add_camera_guide");
	var cameraModeButton = document.getElementById("camera_mode");
	var screenTypeButton = document.getElementById("screen_type");
	var addCurveButton = document.getElementById("add_curve");
	var addBonusButton = document.getElementById("add_bonus");

	if (this.selectedCurveIndex == 0) {
		loopingButton.disabled = true;
		scaleGuideButton.disabled = false;
		cameraGuideButton.disabled = false;
		cameraModeButton.disabled = false;
		screenTypeButton.disabled = false;
		addBonusButton.disabled = true;
	} else {
		if (this.state == Main.states["EDIT_CURVE_STATE"])
			loopingButton.disabled = false;
		else
			loopingButton.disabled = true;
		scaleGuideButton.disabled = true;
		cameraGuideButton.disabled = true;
		cameraModeButton.disabled = true;
		screenTypeButton.disabled = true;
		addBonusButton.disabled = false;
	}

	addCurveButton.disabled = false;
};


Main.prototype.addCurve = function() {
	this.curves.push(new Curve());
	this.updateSelectCurves();
	this.selectedCurveIndex = this.curves.length - 1;
	document.getElementById("curves").value = "curve" + (this.curves.length - 1);
};

Main.prototype.removeCurve = function(index) {
	this.curves.splice(index, 1);
	this.updateSelectCurves();
	document.getElementById("curves").value = "curve" + (this.curves.length - 1);
};

Main.prototype.updateSelectCurves = function() {
	var str = '<option value="curve'+i+'">'+"Camera curve" +'</option>';
	for (var i = 1; i < this.curves.length; i++) {
		str += '<option value="curve'+i+'">'+"Curve " + i +'</option>';
	}
	document.getElementById("curves").innerHTML = str;
};

Main.prototype.archive = function() {
	var archive = {};
	archive["camera_curve"] = this.curves[0].archive();
	archive["curves"] = [];

	for (var i = 1; i < this.curves.length; i++)
		archive["curves"].push(this.curves[i].archive());

	archive["bonuses"] = [];

	for (var i = 0; i < this.bonuses.length; i++)
		archive["bonuses"].push(this.bonuses[i].archive());

	return archive;
};

Main.prototype.unarchive = function(archive) {
	this.curves = [Curve.unarchive(archive['camera_curve'])];
	for (var i = 0; i < archive['curves'].length; i++)
		this.curves.push(Curve.unarchive(archive['curves'][i]));

	this.bonuses = [];
	for (var i = 0; i < archive['bonuses'].length; i++)
		this.bonuses.push(Bonus.unarchive(archive['bonuses'][i]));

	this.state = Main.states['NORMAL_STATE'];
	this.stateInfo = {};
};

Main.prototype.updateCamera = function(point) {
	var curve = this.curves[0];
	point.x = point.x < Main.origin.x ? Main.origin.x : point.x;

	var scale = curve.scaleForX(point.x);
	var cameraPosition = curve.cameraPositionForX(point.x);
	cameraPosition = new Point(cameraPosition.x - 60 / scale, cameraPosition.y - 160 / scale);
	var characterPosition = curve.segments[curve.segments.length - 1].end;

	for (var i = 1; i < this.curves.length; i++) {
		var curve = this.curves[i];
		if (curve.segments.length > 0) {
			if (point.x >= curve.segments[0].start.x && point.x <= curve.segments[curve.segments.length - 1].end.x) {
				characterPosition = curve.pointForX(point.x);
				break;
			};
		}
	}

	this.stateInfo["cameraScale"] = scale;
	this.stateInfo["cameraPosition"] = cameraPosition;
	this.stateInfo["characterPosition"] = characterPosition;
}

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

Main.prototype.didChangeCurve = function(e) {
	this.selectedCurveIndex = document.getElementById("curves").selectedIndex;
	this.editButtonsState();
	this.draw();
}

Main.prototype.didClickCameraModeButton = function(e) {
	var button = e.target;
 	if (this.state == Main.states["CAMERA_MODE_STATE"])
 		this.state = Main.states["NORMAL_STATE"];
 	else
 		this.state = Main.states["CAMERA_MODE_STATE"];
 	this.stateInfo["cameraScale"] = 1.0;
 	this.stateInfo["cameraPosition"] = Main.origin;
 	this.stateInfo["characterPosition"] = Main.origin;
 	this.draw();
}

Main.prototype.didClickScreenTypeButton = function(e) {
	var button = e.target;
	if (this.screenType == Main.screenTypes["LARGE_TYPE"]) {
		button.value = "Small screen";
		this.screenType = Main.screenTypes["SMALL_TYPE"];
	}
	else {
		button.value = "Large screen";
		this.screenType = Main.screenTypes["LARGE_TYPE"];
	}
} 

Main.prototype.didClickCanvas = function(e) {
	var x = Math.round(e.pageX / Main.magnetGridSize) * Main.magnetGridSize;
	var y = Math.round(e.pageY / Main.magnetGridSize) * Main.magnetGridSize;
	var point = new Point(x, y);

	switch(this.state) {
		case Main.states['NORMAL_STATE']: 
			if (this.selectCurvePoint(point)) {
				this.state = Main.states['EDIT_CURVE_POINT_STATE'];
			} else if (this.selectBonus(point)) {
				this.state = Main.states['EDIT_BONUS_STATE']
			} else if (this.selectScaleGuide(point)) {
				this.state = Main.states['EDIT_SCALE_GUIDE_STATE'];
			} else if (this.selectCameraGuide(point)) {
				this.state = Main.states['EDIT_CAMERA_GUIDE_STATE'];
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

		case Main.states['EDIT_SCALE_GUIDE_STATE']:
			this.state = Main.states['NORMAL_STATE'];
			break;

		case Main.states['EDIT_CAMERA_GUIDE_STATE']:
			this.state = Main.states['NORMAL_STATE'];
			break;

		case Main.states['HOVERED_CURVE_STATE']:
			if (this.selectCurvePoint(point)) {
				this.curves[this.stateInfo.curveIndex].deselectSegment();
				this.state = Main.states['EDIT_CURVE_POINT_STATE'];
			} else {
				this.curves[this.stateInfo.curveIndex].isSegmentSelected = true;
				this.state = Main.states['EDIT_CURVE_STATE'];
				this.editButtonsState();
			}
			break;

		case Main.states['EDIT_CURVE_STATE']:
			this.editButtonsState();
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
				} else if (this.selectBonus(point) || this.selectScaleGuide(point) || this.selectCameraGuide(point))  {
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
				} else if (this.selectScaleGuide(point)) {
					this.curves[this.stateInfo.curveIndex].deselectSegment();
					this.state = Main.states['NORMAL_STATE'];
				} else if (this.selectCameraGuide(point)) {
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

		case Main.states['EDIT_SCALE_GUIDE_STATE']:
			var curve = this.curves[this.stateInfo.scaleGuideIndex];
			curve.moveSelectedScaleGuide(point);
			break;

		case Main.states['EDIT_CAMERA_GUIDE_STATE']:
			var curve = this.curves[this.stateInfo.cameraGuideIndex];
			curve.moveSelectedCameraGuide(point);
			break;

		case Main.states['CAMERA_MODE_STATE']:
			this.updateCamera(point);
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

Main.prototype.didClickScaleGuideButton = function() {
	var curve = this.curves[this.selectedCurveIndex];
	var x = document.body.scrollLeft + document.body.offsetWidth / 2 - Main.origin.x;
	var point = curve.pointForX(x);
	if (!point)
		return;

	curve.addScaleGuide(point);
	this.draw();
};

Main.prototype.didClickCameraGuideButton = function() {
	var curve = this.curves[this.selectedCurveIndex];
	var x = document.body.scrollLeft + document.body.offsetWidth / 2 - Main.origin.x;
	var point = curve.pointForX(x);
	if (!point)
		return;

	curve.addCameraGuide(point);
	this.draw();
};

Main.prototype.didClickLoopingButton = function() {
	if (this.state == Main.states['EDIT_CURVE_STATE']) {
		var curve = this.curves[this.stateInfo.curveIndex];
		curve.switchSelectedSegmentWithLooping();
		this.editButtonsState();
		this.curves[this.stateInfo.curveIndex].deselectSegment();
		this.state = Main.states['NORMAL_STATE'];
		this.draw();
	}
};

Main.prototype.didClickTunnelButton = function() {
	if (this.state == Main.states['EDIT_CURVE_STATE']) {
		var curve = this.curves[this.stateInfo.curveIndex];
		curve.switchSelectedSegmentWithTunnel();
		this.editButtonsState();
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
				if (curve.isEmpty() && this.stateInfo.curveIndex > 1)
					this.removeCurve(this.stateInfo.curveIndex);
				break;

			case Main.states['EDIT_BONUS_STATE']:
				this.bonuses.splice(this.stateInfo.bonusIndex, 1);
				this.state = Main.states['NORMAL_STATE'];
				break;

			case Main.states['EDIT_SCALE_GUIDE_STATE']:
				this.curves[this.stateInfo.scaleGuideIndex].deleteSelectedScaleGuide();
				this.state = Main.states['NORMAL_STATE'];
				break;

			case Main.states['EDIT_CAMERA_GUIDE_STATE']:
				this.curves[this.stateInfo.cameraGuideIndex].deleteSelectedCameraGuide();
				this.state = Main.states['NORMAL_STATE'];
				break;
		}
		this.editButtonsState();
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