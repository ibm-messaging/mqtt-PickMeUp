/*******************************************************************************
 * Copyright (c) 2014 IBM Corp.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *   http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 ******************************************************************************/ 

/////////////////////////////////////
//
//  App.js
//  ------
//  Manage UI and data relevant to the PickMeUp session.  A single
//  instance is attached to the window object to manage the session.
//
/////////////////////////////////////

function App() {

	this.driver = {
		geo: { lon: null, lat: null },
		id: null,
		name: null,
		picture: Utils.getDefaultImage()
	};

	this.passenger = {
		geo: { lon: null, lat: null },
		id: null,
		name: null,
		picture: Utils.getDefaultImage()
	};

	this.requests = null;

	this.map = {
		osmMap: null,
		dragControl: null,
		images: {
			passengerVectors: null,
			requestVectors: null,
			driverVectors: null
		},
		bManualMovement: false
	};

	this.tripData = {
		distance: 0,
		cost: 0,
		startTime: 0,
		totalTime: 0,
		coords: [],
		interval: null
	};

	this.audio = {
		bHasWebAudio: true,
		context: null,
		source: null,
		buffer: null
	}

	this.page = "pageSignin";
}

App.prototype.playAudio = function() {
	this.audio.source = this.audio.context.createBufferSource();
	this.audio.source.buffer = this.audio.buffer;
	this.audio.source.connect(this.audio.context.destination);

	if ('AudioContext' in window) {
		this.audio.source.start(0);
	} else if ('webkitAudioContext' in window) {
		this.audio.source.noteOn(0);
	}
}

App.prototype.loadAudio = function(base64) {
	var arrayBuff = Utils.base64ToArrayBuffer(base64);
	this.audio.context.decodeAudioData(arrayBuff, function(audioData) {
		window.app.audio.buffer = audioData;
	});
}

App.prototype.acceptRequest = function(passengerId) {

	Messenger.setPassengerId(passengerId);
	Messenger.publish(Messenger.MessageFactory.getClearRequestMessage());
	Messenger.publish(Messenger.MessageFactory.getAcceptRequestMessage(this.driver.geo));

	this.passenger.id = passengerId;
	this.passenger.name = this.requests[passengerId].name;

	$("#pickupPassengerName").html(this.requests[passengerId].name);

	this.goToPage("pageApproaching");
}

App.prototype.showSummary = function() {
	this.tripData.cost = 5 + this.tripData.distance * 0.75 + this.tripData.totalTime / 60000 * 0.5;

	var min = Math.floor(this.tripData.totalTime / 60000);
	var sec = Math.floor(this.tripData.totalTime % 60000 / 1000);
	if (sec < 10) sec = "0" + sec;
	var timeStr = min + ":" + sec;
	$("#tripTimeValue").html(timeStr);
	$("#tripCostValue").html("$" + this.tripData.cost.toFixed(2));

	$("#tripSummaryDistanceValue").html(this.tripData.distance.toFixed(2) + " mi");
	$("#tripSummaryTimeValue").html(timeStr);
	$("#tripSummaryCostValue").html("$" + this.tripData.cost.toFixed(2));

	this.fade($(".mask"), "in", 1000, 0.5);
	this.fade($("#tripDetailsContainer"), "out", 200);
	this.fade($("#tripSummaryContainer"), "in", 500);
}

App.prototype.showPayment = function(rating, tip) {
	$("#paymentRatingValue").html(rating + " stars");
	$("#paymentTipValue").html("$" + tip.toFixed(2));

	this.fade($(".mask"), "in", 1000, 0.7);
	this.fade($("#tripSummaryContainer"), "out", 200);
	this.fade($("#paymentSummaryContainer"), "in", 500);
}

App.prototype.fade = function(obj, direction, duration, opacity) {
	if (!opacity) { opacity = 1; }
	if (direction == "out") {
		$(obj).animate({ opacity: 0 }, duration, function() {
			$(obj).css("visibility", "hidden");
		});
	} else if (direction == "in") {
		$(obj).css("visibility", "visible");
		$(obj).animate({ opacity: opacity }, duration);
	} else {
		console.error("'" + direction + "' is an invalid param:  use in/out");
	}
}

App.prototype.getCurrentPage = function() {
	return $(".page").filter(function() {
		return $(this).css("opacity") == 1;
	});
}

App.prototype.goToPage = function(id) {
	if (Utils.TRACE) { console.log("goToPage("+id+")"); }
	$("#" + id).css("visibility", "visible");
	this.getCurrentPage().animate({ opacity: 0 }, function() {
		$(this).css("visibility", "hidden");
		$("#" + id).animate({ opacity: 1 });
	});
	if ($("#map_"+id)) {
		this.map.osmMap.render("map_"+id)
	}

	this.page = id;

	switch (id) {
		case "pagePairing":
			this.initRequests();
			Messenger.subscribe(Messenger.SubscriptionFactory.getRequestSubscription());
			break;
		case "pageApproaching":
			this.requests = null;
			this.map.osmMap.removeLayer(this.map.images.requestVectors);
			this.map.images.requestVectors = null;

			Messenger.subscribe(Messenger.SubscriptionFactory.getPassengerPresenceSubscription());
			Messenger.subscribe(Messenger.SubscriptionFactory.getPassengerLocationSubscription());
			Messenger.subscribe(Messenger.SubscriptionFactory.getPassengerPictureSubscription());
			Messenger.subscribe(Messenger.SubscriptionFactory.getPassengerChatSubscription());
			Messenger.subscribe(Messenger.SubscriptionFactory.getDriverChatSubscription());

			// force a location change to update the distance and ETA for pickup
			this.driverLocationChanged(this.driver.geo.lon, this.driver.geo.lat);
			break;

		case "pageRiding":
			this.tripData.startTime = (new Date()).getTime();
			Messenger.publish(Messenger.MessageFactory.getTripStartMessage());
			this.map.osmMap.removeLayer(this.map.images.passengerVectors);
			this.map.images.passengerVectors = null;
			this.map.osmMap.setCenter(Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat), 15);
			this.tripData.interval = setInterval(function() {
				window.app.tripData.totalTime = (new Date()).getTime() - window.app.tripData.startTime;
				window.app.tripData.cost = 5 + window.app.tripData.distance * 0.75 + window.app.tripData.totalTime / 60000 * 0.5;

				var min = Math.floor(window.app.tripData.totalTime / 60000);
				var sec = Math.floor(window.app.tripData.totalTime % 60000 / 1000);
				if (sec < 10) sec = "0" + sec;
				var timeStr = min + ":" + sec;
				$("#tripTimeValue").html(timeStr);
				$("#tripCostValue").html("$" + window.app.tripData.cost.toFixed(2));
			}, 200);
			this.map.dragControl.activate();
			break;
	}

	resize();
}

App.prototype.clearMapVectors = function() {
	if (this.map.images.requestVectors) {
		this.map.osmMap.removeLayer(this.map.images.requestVectors);
	}
	if (this.map.images.driverVectors) {
		this.map.osmMap.removeLayer(this.map.images.driverVectors);
	}
	if (this.map.images.passengerVectors) {
		this.map.osmMap.removeLayer(this.map.images.passengerVectors);
	}
	if (this.map.dragControl) {
		this.map.osmMap.removeLayer(this.map.dragControl);
	}
}

App.prototype.initRequests = function() {
	if (Utils.TRACE) { console.log("initRequests"); }
	try {
		$("#requestList").html("");
		this.requests = {};
		this.clearMapVectors();
		this.map.images.requestVectors = new OpenLayers.Layer.Vector("requestVectors");
		this.map.images.driverVectors = new OpenLayers.Layer.Vector("driverVectors");

		setInterval(function() {
			navigator.geolocation.getCurrentPosition(function(position) {
				var lat = position.coords.latitude.toFixed(7);
				var lon = position.coords.longitude.toFixed(7);
				var lonlat = Utils.makeLonLat(lon, lat);
				if (!window.app.map.bManualMovement) {
					window.app.map.images.driverVectors.features[0].move(lonlat);
					window.app.driverLocationChanged(lon, lat);
				}
			});
		}, 1000);

		var lonlat = Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat);
		this.map.images.driverVectors.addFeatures([new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat), null, {
			externalGraphic: this.getMarkerIconFromImage(this.driver.picture),
			graphicWidth: 68,
			graphicHeight: 90,
			graphicYOffset: -90,
			label: this.driver.name,
			labelYOffset: 100,
			fontWeight: "bold",
			fillOpacity: 1
		})]);

		this.map.osmMap.addLayer(this.map.images.requestVectors);
		this.map.osmMap.addLayer(this.map.images.driverVectors);
		this.map.dragControl = new OpenLayers.Control.DragFeature(this.map.images.driverVectors, {
			onDrag: function(feature, pixel) {
				var lonlat = Utils.getLonLatFromPoint(feature.geometry);
				window.app.driverLocationChanged(lonlat.lon, lonlat.lat);
				window.app.map.bManualMovement = true;
			}
		});
		this.map.osmMap.addControl(this.map.dragControl);
		this.map.dragControl.activate();
	} catch (e) { console.error(e.stack); }
}

App.prototype.getMarkerIconFromImage = function(dataUrl) {
	var c = document.createElement("canvas");
	c.width = 68;
	c.height = 90;
	var ctx = c.getContext("2d");
	ctx.beginPath();
	ctx.fillStyle = "#fff";
	ctx.strokeStyle = "#000";
	ctx.lineWidth = 2;
	ctx.moveTo(34, 89);
	ctx.lineTo(26, 67);
	ctx.lineTo(1, 67);
	ctx.lineTo(1, 1);
	ctx.lineTo(67, 1);
	ctx.lineTo(67, 67);
	ctx.lineTo(42, 67);
	ctx.lineTo(34, 89);
	ctx.fill();
	ctx.stroke();
	var image = new Image();
	image.src = dataUrl;
	if (dataUrl == "") {
		image.src = "img/person.png";
	}
	ctx.drawImage(image, 2, 2, 64, 64);
	return c.toDataURL("image/png");
}

App.prototype.addRequest = function(passengerId, passengerName, lon, lat) {
	if (Utils.TRACE) { console.log("addRequest"); }
	this.requests[passengerId] = {
		name: passengerName,
		lon: lon,
		lat: lat
	};

	var html = '' +
	'<div id="requestItem_' + passengerId + '" class="requestItem">' +
	'	<div class="requestName">' + passengerName + '</div>' +
	'	<div id="requestDist_' + passengerId + '" class="requestDist">TODO</div>' +
	'	<div class="requestAccept">' +
	'		<button class="requestAcceptButton" onclick="window.app.acceptRequest(\''+passengerId+'\')">Accept</button>' +
	'	</div>' +
	'</div>';
	
	$("#requestList").append(html);

	var lonlat = Utils.makeLonLat(lon, lat);
	this.map.images.requestVectors.addFeatures([new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat), { passengerId: passengerId }, {
		externalGraphic: "img/marker.png",
		label: passengerName,
		graphicWidth: 21,
		graphicHeight: 25,
		graphicYOffset: -25,
		labelYOffset: 35,
		fontWeight: "bold",
		fillOpacity: 1
	})]);

	this.updateRequestDistances();
}

App.prototype.removeRequest = function(passengerId) {
	if (Utils.TRACE) { console.log("removeRequest"); }
	if (this.page != "pagePairing") { return; }
	this.requests[passengerId] = null;
	$("#requestItem_"+passengerId).remove();
	this.map.images.requestVectors.removeFeatures(this.getRequestFeatureForPassengerId(passengerId));
}

App.prototype.getRequestFeatureForPassengerId = function(passengerId) {
	var feature = null;
	for (var i in this.map.images.requestVectors.features) {
		var f = this.map.images.requestVectors.features[i];
		if (f.data.passengerId == passengerId) {
			feature = f;
			break;
		}
	}
	return feature;
}

App.prototype.updatePassengerLocation = function(passengerId, lon, lat) {
	console.log("updatePassengerLocation: ", passengerId, lon, lat);
	this.passengerLocationChanged(passengerId, lon, lat);
	var lonlat = Utils.makeLonLat(lon, lat);

	if (this.page == "pageApproaching" && !this.map.images.passengerVectors) {
		// force a location change to update the distance and ETA for pickup
		this.driverLocationChanged(this.driver.geo.lon, this.driver.geo.lat);

		this.map.images.passengerVectors = new OpenLayers.Layer.Vector("passengerVectors");
		this.map.images.passengerVectors.addFeatures([new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat), null, {
			externalGraphic: this.getMarkerIconFromImage(this.passenger.picture),
			graphicWidth: 68,
			graphicHeight: 90,
			graphicYOffset: -90,
			label: this.passenger.name,
			labelYOffset: 100,
			fontWeight: "bold",
			fillOpacity: 1
		})]);
		this.map.osmMap.addLayer(this.map.images.passengerVectors);
		this.zoomToFitPassenger();
	}
}

App.prototype.handleChatMessage = function(format, data, toDriver) {
	switch (format) {
		case "text":
			if (toDriver) {
				var html = "" +
					"<div class='chatRow'>" +
					"	<div class='passengerPicture shadowBorder chatAvatarOther'></div>" +
					"	<div class='chatMessageOther'>"+data+"</div>" +
					"	<div style='clear: both'></div>" +
					"</div>";
			} else {
				var html = "" +
					"<div class='chatRow'>" +
					"	<div class='driverPicture shadowBorder chatAvatarMine'></div>" +
					"	<div class='chatMessageMine'>"+data+"</div>" +
					"	<div style='clear: both'></div>" +
					"</div>";
			}
			$(".chatMessagesContainer").append(html);
			this.updatePassengerPictureElements();
			this.updateDriverPictureElements();

			var el = $(".chatMessagesContainer > div:last-child");
			el.css("opacity", 0);
			el.animate({ opacity: 1.0 }, 300);
			setTimeout(function() {
				$(".chatMessagesContainer").animate({scrollTop: $(".chatMessagesContainer").height() }, 400);
			}, 100);

			break;

		case "data:audio/wav;base64":

			if (this.audio.bHasWebAudio) {
				// use web audio API, produce large PLAY button overlay
				this.loadAudio(data);
				this.fade($(".mask"), "in", 500, 0.5);
				this.fade($("#newAudioMessageContainer"), "in", 200);
			} else {
				// ignore voice data if we don't support it
			}
			break;
	}
}

App.prototype.handleTripProcessed = function(rating, tip) {
	this.showPayment(rating, tip);
}

App.prototype.handleConnectionLost = function() {
	alert("connection lost!");
	window.location.reload();
}

App.prototype.handleConnectionSuccess = function() {
	if (Utils.TRACE) { console.log("connected!"); }
	this.goToPage("pagePairing");
	$("#connectionStatus").html("Welcome, <b>" + this.driver.name + "</b>");

	Messenger.publish(Messenger.MessageFactory.getDriverPresenceMessage());
	Messenger.publish(Messenger.MessageFactory.getDriverPictureMessage(this.driver.picture));
	Messenger.publish(Messenger.MessageFactory.getDriverLocationMessage(this.driver.geo));
	Messenger.subscribe(Messenger.SubscriptionFactory.getDriverInboxSubscription());

	this.map.osmMap.setCenter(Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat), 13);
}

App.prototype.handleConnectionFailure = function() {
	alert("failed to connect to broker");
}

App.prototype.updatePassengerPictureElements = function() {
	$(".passengerPicture").css("background-image", 'url(\"' + this.passenger.picture + '\")');
}

App.prototype.updateDriverPictureElements = function() {
	$(".driverPicture").css("background-image", 'url(\"' + this.driver.picture + '\")');
}

App.prototype.updatePassengerPicture = function(src) {
	this.passenger.picture = src;
	$("#pickupPassengerImage")[0].src = this.passenger.picture;
	this.updatePassengerPictureElements();

	if (this.map.images.passengerVectors) {
		var feature = this.map.images.passengerVectors.features[0];
		feature.style.externalGraphic = this.getMarkerIconFromImage(this.passenger.picture);
		this.map.images.passengerVectors.drawFeature(feature);
	}
}

App.prototype.driverLocationChanged = function(lon, lat) {
	if (Utils.TRACE) { console.log("driver location changed: ", lon, lat); }
	this.driver.geo.lon = lon;
	this.driver.geo.lat = lat;

	Messenger.publish(Messenger.MessageFactory.getDriverLocationMessage(this.driver.geo));

	if (this.page == "pagePairing") {
		this.updateRequestDistances();
	} else if (this.page == "pageApproaching") {
		var ll1 = Utils.makeLonLat(this.passenger.geo.lon, this.passenger.geo.lat);
		var ll2 = Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat);
		var p1 = new OpenLayers.Geometry.Point(ll1.lon, ll1.lat);
		var p2 = new OpenLayers.Geometry.Point(ll2.lon, ll2.lat);
		var distance = p1.distanceTo(p2);
		var miles = (distance * 0.000621371).toFixed(1);
		$("#pickupDistanceValue").html(miles + " mi");
		this.checkForPickupArrival(miles);

		var seconds = miles * 3 * 60;  // avg 20 mph
		var date = new Date((new Date()).getTime() + 1000*seconds);
		var hours = date.getHours();
		var minutes = date.getMinutes();
		var ampm = hours >= 12 ? 'pm' : 'am';
		hours = hours % 12;
		hours = hours ? hours : 12; // the hour '0' should be '12'
		minutes = minutes < 10 ? '0'+minutes : minutes;
		var strTime = hours + ':' + minutes + ' ' + ampm;

		$("#pickupETAValue").html(strTime);
	} else if (this.page == "pageRiding") {
		var lonlat = Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat);
		if (this.tripData.coords.length > 0) {
			var lastlonlat = this.tripData.coords[this.tripData.coords.length-1];
			var p1 = new OpenLayers.Geometry.Point(lastlonlat.lon, lastlonlat.lat);
			var p2 = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
			var distance = p1.distanceTo(p2);
			var miles = (distance * 0.000621371);
			this.tripData.distance += miles;
			$("#tripDistanceValue").html(this.tripData.distance.toFixed(2) + " mi");
		}
		this.tripData.coords.push(lonlat);
	}
}

App.prototype.zoomToFitPassenger = function() {
	var newBound = new OpenLayers.Bounds();
	newBound.extend(Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat));
	newBound.extend(Utils.makeLonLat(this.passenger.geo.lon, this.passenger.geo.lat));

	var width = newBound.right - newBound.left;
	var height = newBound.top - newBound.bottom;
	newBound.left -= 0.3*width;
	newBound.right += 0.3*width;
	newBound.bottom -= 0.3*height;
	newBound.top += 0.3*height;

	this.map.osmMap.zoomToExtent(newBound);
}

App.prototype.checkForPickupArrival = function(dist) {
	if (dist < 0.05) {
		this.map.dragControl.deactivate();
		this.goToPage("pageRiding");
	}
}

App.prototype.updateRequestDistances = function() {
	for (var id in this.requests) {
		var ll1 = Utils.makeLonLat(this.requests[id].lon, this.requests[id].lat);
		var ll2 = Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat);

		var p1 = new OpenLayers.Geometry.Point(ll1.lon, ll1.lat);
		var p2 = new OpenLayers.Geometry.Point(ll2.lon, ll2.lat);
		var distance = p1.distanceTo(p2);
		var miles = (distance * 0.000621371).toFixed(1);
		$("#requestDist_"+id).html(miles + " mi");
	}
}

App.prototype.passengerLocationChanged = function(passengerId, lon, lat) {
	var ll1 = Utils.makeLonLat(lon, lat);
	var ll2 = Utils.makeLonLat(this.driver.geo.lon, this.driver.geo.lat);

	var p1 = new OpenLayers.Geometry.Point(ll1.lon, ll1.lat);
	var p2 = new OpenLayers.Geometry.Point(ll2.lon, ll2.lat);
	var distance = p1.distanceTo(p2);
	var miles = (distance * 0.000621371).toFixed(1);

	if (this.requests) {
		for (var id in this.requests) {
			$("#requestDist_"+id).html(miles + " mi");
		}
	} else {
		if (this.passenger.id == passengerId) {
			this.passenger.geo.lon = lon;
			this.passenger.geo.lat = lat;
		}
	}
}
