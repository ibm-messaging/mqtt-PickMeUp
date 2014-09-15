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

////////////////////////////////////////
//
//  Messenger.js
//  ------------
//  Abstract all MQTT messaging for the driver session.  The
//  Messenger namespace contains the following objects:
//
//    - TopicManager: manages application topics
//    - MessageFactory: contains definitions and accessors for the 
//                      payloads the client will publish 
//    - SubscriptionFactory: contains definitions and accessors for the
//                           subscriptions the client will create
//    - MessageHandler: parses messages received by the MQTT client's
//                      onMessage callback, and invokes the appropriate
//                      function in App()
//
//  ...and wrappers around the mqttws31.js MQTT client functions. Example:
//
//    Messenger.connect();
//    Messenger.publish(Messenger.MessageFactory.getClearRequestMessage());
//    Messenger.subscribe(Messenger.SubscriptionFactory.getRequestSubscription());
//    Messenger.disconnect();
//
//  The Messenger object requires the driverId and passengerId to be set
//  using the appropriate setter method before invoking any publish or
//  subscribe functions that use this information in the topic or payload.
//
/////////////////////////////////////

Messenger = (function (global) {

	var _client = null;
	var _server = "messagesight.demos.ibm.com";
	var _port = 1883;
	var _clientId = null;
	
	var _driverId = null;
	var _passengerId = null;

	var TopicManager = (function() {

		var _driverId = null;
		var _passengerId = null;

		var _baseTopic = "pickmeup/";
		var _baseDriverTopic = "pickmeup/drivers/";
		var _basePassengerTopic = "pickmeup/passengers/";
		var _baseRequestTopic = "pickmeup/requests/";

		var setDriverId = function(driverId) {
			_driverId = driverId;
		}
		var setPassengerId = function(passengerId) {
			_passengerId = passengerId;
		}

		// replaces + and # characters with regex for matching in onMessage
		var getMatchString = function(topic) {
			var topic = topic.replace(/\+/g, "[^\\/]*")
			topic = topic.replace(/\#/g, ".*");
			return topic;
		}

		// request topics
		var getRequestTopic = function() {
			return _baseRequestTopic + "+";
		}
		var getClearRequestTopic = function() {
			return _baseRequestTopic + _passengerId;
		}

		// passenger topics
		var getPassengerPresenceTopic = function() {
			return _basePassengerTopic + _passengerId;
		}
		var getPassengerPictureTopic = function() {
			return _basePassengerTopic + _passengerId + "/picture";
		}
		var getPassengerLocationTopic = function() {
			return _basePassengerTopic + _passengerId + "/location";
		}
		var getPassengerChatTopic = function() {
			return _basePassengerTopic + _passengerId + "/chat";
		}
		var getPassengerInboxTopic = function() {
			return _basePassengerTopic + _passengerId + "/inbox";
		}

		// driver topics
		var getDriverPresenceTopic = function() {
			return _baseDriverTopic + _driverId;
		}
		var getDriverPictureTopic = function() {
			return _baseDriverTopic + _driverId + "/picture";
		}
		var getDriverLocationTopic = function() {
			return _baseDriverTopic + _driverId + "/location";
		}
		var getDriverChatTopic = function() {
			return _baseDriverTopic + _driverId + "/chat";
		}
		var getDriverInboxTopic = function() {
			return _baseDriverTopic + _driverId + "/inbox";
		}

		return {
			setDriverId: setDriverId,
			setPassengerId: setPassengerId,
			getMatchString: getMatchString,

			getRequestTopic: getRequestTopic,
			getClearRequestTopic: getClearRequestTopic,

			getPassengerPresenceTopic: getPassengerPresenceTopic,
			getPassengerPictureTopic: getPassengerPictureTopic,
			getPassengerLocationTopic: getPassengerLocationTopic,
			getPassengerChatTopic: getPassengerChatTopic,
			getPassengerInboxTopic: getPassengerInboxTopic,

			getDriverPresenceTopic: getDriverPresenceTopic,
			getDriverPictureTopic: getDriverPictureTopic,
			getDriverLocationTopic: getDriverLocationTopic,
			getDriverChatTopic: getDriverChatTopic,
			getDriverInboxTopic: getDriverInboxTopic
		};
	})();

	var MessageFactory = (function() {

		var _driverId = null;
		var _passengerId = null;

		var setDriverId = function(driverId) {
			_driverId = driverId;
		}
		var setPassengerId = function(passengerId) {
			_passengerId = passengerId;
		}

		var getClearRequestMessage = function() {
			return {
				topic: TopicManager.getClearRequestTopic(),
				payload: "",
				qos: 1,
				retained: true
			}
		}

		var getAcceptRequestMessage = function(driverGeo) {
			return {
				topic: TopicManager.getPassengerInboxTopic(),
				payload: JSON.stringify({
					type: "accept",
					driverId: _driverId,
					lon: driverGeo.lon,
					lat: driverGeo.lat
				}),
				qos: 1,
				retained: false
			}
		}

		var getTripStartMessage = function() {
			return {
				topic: TopicManager.getPassengerInboxTopic(),
				payload: JSON.stringify({
					type: "tripStart"
				}),
				qos: 1,
				retained: false
			}
		}

		var getDriverPresenceMessage = function(driverName) {
			if (!driverName) { driverName = _driverId; }
			return {
				topic: TopicManager.getDriverPresenceTopic(),
				payload: JSON.stringify({
					name: driverName,
					connectionTime: (new Date()).getTime()
				}),
				qos: 1,
				retained: true
			}
		}

		var getDriverPictureMessage = function(src) {
			return {
				topic: TopicManager.getDriverPictureTopic(),
				payload: JSON.stringify({
					url: src
				}),
				qos: 0,
				retained: true
			}
		}

		var getDriverLocationMessage = function(driverGeo) {
			return {
				topic: TopicManager.getDriverLocationTopic(),
				payload: JSON.stringify({
					lon: driverGeo.lon,
					lat: driverGeo.lat
				}),
				qos: 0,
				retained: true
			}
		}

		var getChatMessage = function(format, data) {
			return {
				topic: TopicManager.getPassengerChatTopic(),
				payload: JSON.stringify({
					format: format,
					data: data
				}),
				qos: 0,
				retained: false
			}
		}

		var getTripEndMessage = function(distance, time, cost) {
			return {
				topic: TopicManager.getPassengerInboxTopic(),
				payload: JSON.stringify({
					type: "tripEnd",
					distance: distance,
					time: time,
					cost: cost
				}),
				qos: 1,
				retained: false
			}
		}

		return {
			setDriverId: setDriverId,
			setPassengerId: setPassengerId,

			getClearRequestMessage: getClearRequestMessage,
			getAcceptRequestMessage: getAcceptRequestMessage,

			getTripStartMessage: getTripStartMessage,
			getTripEndMessage: getTripEndMessage,

			getDriverPresenceMessage: getDriverPresenceMessage,
			getDriverPictureMessage: getDriverPictureMessage,
			getDriverLocationMessage: getDriverLocationMessage,
			getChatMessage: getChatMessage,
		};
	})();

	var SubscriptionFactory = (function() {

		var getDriverInboxSubscription = function() {
			var topic = TopicManager.getDriverInboxTopic();
			return {
				topic: topic,
				qos: 1,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		var getRequestSubscription = function() {
			var topic = TopicManager.getRequestTopic();
			return {
				topic: topic,
				qos: 0,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		var getPassengerPresenceSubscription = function() {
			var topic = TopicManager.getPassengerPresenceTopic();
			return {
				topic: topic,
				qos: 0,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		var getPassengerLocationSubscription = function() {
			var topic = TopicManager.getPassengerLocationTopic();
			return {
				topic: topic,
				qos: 0,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		var getPassengerPictureSubscription = function() {
			var topic = TopicManager.getPassengerPictureTopic();
			return {
				topic: topic,
				qos: 0,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		var getPassengerChatSubscription = function() {
			var topic = TopicManager.getPassengerChatTopic();
			return {
				topic: topic,
				qos: 0,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		var getDriverChatSubscription = function() {
			var topic = TopicManager.getDriverChatTopic();
			return {
				topic: topic,
				qos: 0,
				onSuccess: function() { if (Utils.TRACE) { console.log("subscribed to " + topic); } }
			}
		}

		return {
			getDriverInboxSubscription: getDriverInboxSubscription,
			getRequestSubscription: getRequestSubscription,
			getPassengerPresenceSubscription: getPassengerPresenceSubscription,
			getPassengerLocationSubscription: getPassengerLocationSubscription,
			getPassengerPictureSubscription: getPassengerPictureSubscription,
			getPassengerChatSubscription: getPassengerChatSubscription,
			getDriverChatSubscription: getDriverChatSubscription
		};
	})();

	var MessageHandler = (function() {

		var processMessage = function(topic, payload) {
			try {
				if (topic.match(TopicManager.getMatchString(TopicManager.getRequestTopic()))) {
					_processRequestMessage(topic, payload);
				} else
				if (topic.match(TopicManager.getPassengerLocationTopic())) {
					_processPassengerLocationMessage(topic, payload);
				} else
				if (topic.match(TopicManager.getPassengerChatTopic())) {
					_processPassengerChatMessage(topic, payload);
				} else
				if (topic.match(TopicManager.getPassengerPictureTopic())) {
					_processPassengerPictureMessage(topic, payload);
				} else
				if (topic.match(TopicManager.getDriverChatTopic())) {
					_processDriverChatMessage(topic, payload);
				} else
				if (topic.match(TopicManager.getDriverInboxTopic())) {
					_processDriverInboxMessage(topic, payload);
				} 
			} catch (e) { console.error(e.stack); }
		}

		var _processRequestMessage = function(topic, payload) {
			var passengerId = topic.split("/")[2];
			if (payload == "") { 
				// an empty payload is a clear message
				window.app.removeRequest(passengerId);
			} else {
				var data = JSON.parse(payload);
				var passengerName = data.name;
				var lon = data.lon;
				var lat = data.lat;
				window.app.addRequest(passengerId, passengerName, lon, lat);
			}
		}

		var _processPassengerLocationMessage = function(topic, payload) {
			// don't process retained messages clearing the location data
			if (payload == "") { return; }
			var passengerId = topic.split("/")[2];
			var data = JSON.parse(payload);
			var lon = data.lon;
			var lat = data.lat;
			window.app.updatePassengerLocation(passengerId, lon, lat);
		}

		var _processPassengerChatMessage = function(topic, payload) {
			// message to driver from passenger
			var passengerId = topic.split("/")[2];
			var json = JSON.parse(payload);
			var format = json.format;
			var data = json.data;
			window.app.handleChatMessage(format, data, false);
		}

		var _processPassengerPictureMessage = function(topic, payload) {
			// don't process retained messages clearing the picture data
			if (payload == "") { return; }
			var passengerId = topic.split("/")[2];
			var data = JSON.parse(payload);
			var src = data.url;
			window.app.updatePassengerPicture(src);
		}

		var _processDriverChatMessage = function(topic, payload) {
			// message to driver from passenger
			var passengerId = topic.split("/")[2];
			var json = JSON.parse(payload);
			var format = json.format;
			var data = json.data;
			window.app.handleChatMessage(format, data, true);
		}

		var _processDriverInboxMessage = function(topic, payload) {
			// message to driver from passenger
			var json = JSON.parse(payload);
			var type = json.type;

			if (type == "tripProcessed") {
				var rating = parseFloat(json.rating);
				var tip = parseFloat(json.tip);
				window.app.handleTripProcessed(rating, tip);
			}
		}

		return {
			processMessage: processMessage
		};
	})();

	var connect = function() {
		_clientId = "PMU-D-" + _driverId;
		_client = new Messaging.Client(_server, _port, _clientId);

		_client.onMessageArrived = _onMessage;
		_client.onConnectionLost = _onConnectionLost;

		var willMessage = new Messaging.Message("");
		willMessage.destinationName = TopicManager.getDriverPresenceTopic();
		willMessage.retained = true;

		var connectOptions = new Object();
		connectOptions.useSSL = false;
		connectOptions.cleanSession = true;
		connectOptions.keepAliveInterval = 3600;
		connectOptions.timeout = 10;
		connectOptions.willMessage = willMessage;
		connectOptions.onSuccess = _onConnectionSuccess;
		connectOptions.onFailure = _onConnectionFailure;

		_client.connect(connectOptions);
	}

	var disconnect = function() {
		_client.disconnect();
	}

	var _onMessage = function(msg) {
		try {
			var topic = msg.destinationName;
			var payload = msg.payloadString;
			if (Utils.TRACE) { console.log("onMessage | topic=" + topic + " | payload=" + payload); }
			MessageHandler.processMessage(topic, payload);
		} catch (e) { console.error(e.stack); }
	}

	var _onConnectionLost = function() {
		try {
			window.app.handleConnectionLost();
		} catch (e) { console.error(e.stack); }
	}

	var _onConnectionSuccess = function() {
		try {
			window.app.handleConnectionSuccess();
		} catch (e) { console.error(e.stack); }
	}

	var _onConnectionFailure = function() {
		try {
			window.app.handleConnectionFailure();
		} catch (e) { console.error(e.stack); }
	}

	var publish = function(msgFactoryObj) {
		var topic = msgFactoryObj.topic;
		var payload = msgFactoryObj.payload;
		var qos = msgFactoryObj.qos;
		var retained = msgFactoryObj.retained;

		var msg = new Messaging.Message(payload);
		msg.destinationName = topic;
		msg.qos = qos;
		msg.retained = retained;
		if (Utils.TRACE) { console.log("publish | topic=" + topic + " | payload=" + payload + " | qos=" + qos + " | retained=" + retained); }
		_client.send(msg);
	}

	var subscribe = function(subFactoryObj) {
		var topic = subFactoryObj.topic;
		var qos = subFactoryObj.qos;
		var onSuccess = subFactoryObj.onSuccess;

		_client.subscribe(topic, {
			qos: qos,
			onSuccess: onSuccess
		});
	}

	var setDriverId = function(driverId) {
		_driverId = driverId;
		TopicManager.setDriverId(driverId);
		MessageFactory.setDriverId(driverId);
	}

	var setPassengerId = function(passengerId) {
		_passengerId = passengerId;
		TopicManager.setPassengerId(passengerId);
		MessageFactory.setPassengerId(passengerId);
	}

	return {
		connect: connect,
		disconnect: disconnect,
		publish: publish,
		subscribe: subscribe,

		setDriverId: setDriverId,
		setPassengerId: setPassengerId,

		MessageFactory: MessageFactory,
		SubscriptionFactory: SubscriptionFactory
	}
})(window);

