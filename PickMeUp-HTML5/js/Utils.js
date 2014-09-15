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
//  Utils.js
//  --------
//  Utility functions, enums, etc.
//
/////////////////////////////////////
Utils = (function (global) {
	var base64ToArrayBuffer = function(b64) {
		// remove any carriage returns in the payload 
		b64 = b64.replace(new RegExp("\\n", "g"), "");

		var binary_string = window.atob(b64);
		var len = binary_string.length;
		var bytes = new Uint8Array(len);
		for (var i = 0; i < len; i++) {
			bytes[i] = binary_string.charCodeAt(i);
		}
		return bytes.buffer;
	}

	var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984
	var toProjection   = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection

	var makeLonLat = function(lon, lat) {
		return new OpenLayers.LonLat(lon, lat).transform(fromProjection, toProjection);
	};

	var getLonLatFromPoint = function(point) {
		return new OpenLayers.LonLat(point.x, point.y).transform(toProjection, fromProjection);
	};

	var getRandomGeo = function() {
		var minLon = -97.754, maxLon = -97.709;
		var minLat = 30.369, maxLat = 30.416;
		return {
			lon: (minLon + Math.random() * (minLon - maxLon)).toFixed(5),
			lat: (minLat + Math.random() * (minLat - maxLat)).toFixed(5)
		};
	}

	var CHAT_FORMAT = {
		TEXT: "text",
		AUDIO: "data:audio/wav;base64"
	}

	var TRACE = true;

	/*
	var getRandomString = function(length) {
		var str = "";
		var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		for (var i = 0; i < length; i++) {
			str += chars[Math.floor(Math.random() * chars.length)];
		}
		return str;
	}
	*/

	var getDefaultImage = function() {
		return "data:image/png;base64,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";
	}

	return {
		base64ToArrayBuffer: base64ToArrayBuffer,
		makeLonLat: makeLonLat,
		getLonLatFromPoint: getLonLatFromPoint,
		getRandomGeo: getRandomGeo,
		getDefaultImage: getDefaultImage,
		CHAT_FORMAT: CHAT_FORMAT,
		TRACE: TRACE,
	}

})(window);

