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
//  main.js
//  -------
//  Contains global initialization functions for the web audio, 
//  map, events and geolocation.
//
/////////////////////////////////////

var setupAudio = function() {
	// set up Web Audio context
	if ('AudioContext' in window) {
		window.app.audio.context = new AudioContext();
	} else if ('webkitAudioContext' in window) {
		window.app.audio.context = new webkitAudioContext();
	} else {
		window.app.audio.bHasWebAudio = false;
		console.warning("no Web Audio API support -- voice chat unavailable");
	}
}

var setupMap = function() {
	// set up Map
	window.app.map.osmMap = new OpenLayers.Map({
		div: "map_pagePairing",
		allOverlays: true
	});
	window.app.map.osmMap.addLayer(new OpenLayers.Layer.OSM());
	window.app.map.osmMap.zoomToMaxExtent();
}

var setupEvents = function() {
	$("body").on("touchmove", function(e) {
		// only allow scroll on chatRow elements
		if (e.target.className != "chatRow") {
			e.preventDefault();
		}
	});

	$("#chatInputForm").submit(function(event) {
		var txt = $("#chatInputText").val();
		if (txt == "") { return; }

		var format = "text";
		var data = txt;
		Messenger.publish(Messenger.MessageFactory.getChatMessage(format, data));
		$("#chatInputText").val("");
		return false;
	});

	$("#driverLoginButton").on("click", function(event) {
		window.app.driver.name = $("#driverNameInput").val();
		window.app.driver.id = window.app.driver.name;

		if (window.localStorage) {
			window.localStorage.setItem("pickmeupDriverName", $("#driverNameInput").val());
		}

		Messenger.setDriverId(window.app.driver.id);
		Messenger.connect();
	});

	$("#tripStopButton").on("click", function(event) {
		var distance = window.app.tripData.distance.toFixed(2);
		var time = Math.round(window.app.tripData.totalTime / 1000);
		var cost = window.app.tripData.cost.toFixed(2);
		Messenger.publish(Messenger.MessageFactory.getTripEndMessage(distance, time, cost));
		clearInterval(window.app.tripData.interval);
		window.app.showSummary();
	});

	$("#pickupPassengerImage")[0].src = window.app.passenger.picture;

	$("#driverPictureInput").on("change", function() {
		var reader = new FileReader();
		reader.onload = function(e) {
			window.app.driver.picture = reader.result;
			$("#signinDriverImage")[0].src = window.app.driver.picture;
			window.app.updateDriverPictureElements();
		}
		reader.readAsDataURL(this.files[0]);
	});

	$(".newAudioMessageBtn").click(function() {
		window.app.playAudio();
		window.app.fade($(".mask"), "out", 500);
		window.app.fade($("#newAudioMessageContainer"), "out", 500);
	});

	$(".goHomeBtn").click(function() {
		window.location.reload();
		window.app.fade($(".mask"), "out", 500);
		window.app.fade($("#paymentSummaryContainer"), "out", 500);
	});

	document.addEventListener('focusout', function(e) {window.scrollTo(0, 0)});

	if (window.localStorage && window.localStorage.getItem("pickmeupDriverName")) {
		$("#driverNameInput").val(window.localStorage.getItem("pickmeupDriverName"));
	}
}

var setupGeolocation = function() {
	window.app.driver.geo = Utils.getRandomGeo();
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(function(position) {
			var lat = position.coords.latitude.toFixed(7);
			var lon = position.coords.longitude.toFixed(7);
			window.app.driver.geo = { lon: lon, lat: lat };
		});
	}
}

var init = function() {
	if (Utils.TRACE) { console.log("init"); }

	window.app = new App();

	// update container sizes to fit window
	resize();

	setupAudio();
	setupMap();
	setupEvents();
	setupGeolocation();

	window.app.fade($("#pageSignin_middleContainer"), "in");
}

var resize = function() {
	var windowHeight = $(window).height();
	if (windowHeight == 692) { windowHeight -= 15; } // account for horizontal iOS 7 orientation

	$("#pageSignin_middleContainer").css("margin-top", -1 * $("#pageSignin_middleContainer").height() / 2);
	$("#pageSignin_middleContainer").css("margin-left", -1 * $("#pageSignin_middleContainer").width() / 2);

	$("#pagePairing_leftContainer").css("height", windowHeight - $(".header").height());
	var rightContainer = {
		width: $(window).width() - $("#pagePairing_leftContainer").width(),
		height: windowHeight - $(".header").height()
	};
	$("#pagePairing_rightContainer").css("width", rightContainer.width);
	$("#pagePairing_rightContainer").css("height", rightContainer.height);

	$("#pageApproaching_leftContainer").css("height", windowHeight - $(".header").height());
	var rightContainer = {
		width: $(window).width() - $("#pageApproaching_leftContainer").width(),
		height: windowHeight - $(".header").height()
	};
	$("#pageApproaching_rightContainer").css("width", rightContainer.width);
	$("#pageApproaching_rightContainer").css("height", rightContainer.height);

	$("#pickupDetailsContainer").css("right", ($("#pageApproaching_rightContainer").width() - $("#pickupDetailsContainer").innerWidth()) / 2);
	$("#tripDetailsContainer").css("right", ($("#tripDetailsContainer").parent().width() - $("#tripDetailsContainer").width()) / 2);

	$(".mapContainer").each(function(index, value) {
		$(this).css("width", $(this).parent().width());
		$(this).css("height", windowHeight - $(".header").height());
	});

	$(".chatMessagesContainer").css("height", $(window).innerHeight() -
		$(".header").innerHeight() -
		$(".leftContainerTitle").innerHeight() -
		$(".pickupPassengerContainer").innerHeight() -
		$(".chatInputContainer").innerHeight() -
		20);

	$("#tripSummaryContainer").css("right", ($(window).width() - $("#tripSummaryContainer").innerWidth()) / 2);
	$("#tripSummaryContainer").css("top", ($(window).height() - $("#tripSummaryContainer").innerHeight()) / 2);

	$("#paymentSummaryContainer").css("right", ($(window).width() - $("#paymentSummaryContainer").innerWidth()) / 2);
	$("#paymentSummaryContainer").css("top", ($(window).height() - $("#paymentSummaryContainer").innerHeight()) / 2);

	$("#newAudioMessageContainer").css("right", ($(window).width() - $("#newAudioMessageContainer").innerWidth()) / 2);
	$("#newAudioMessageContainer").css("top", ($(window).height() - $("#newAudioMessageContainer").innerHeight()) / 2);
}

$(window).resize(this.resize);

