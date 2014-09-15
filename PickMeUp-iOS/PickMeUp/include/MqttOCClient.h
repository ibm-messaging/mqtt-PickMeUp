/*******************************************************************************
 * Copyright (c) 2013, 2014 IBM Corp.
 *
 * Contributors:
 *    Peter Niblett, Allan Stockdill-Mander, Seth Hoenig, Mike Robertson - initial API and implementation 
 *******************************************************************************/

typedef void* MQTTAsync;

/**
 * @mainpage Asynchronous MQTT client library for iOS
 * 
 * &copy; Copyright IBM Corp. 2013, 2014
 * 
 * @brief An Asynchronous MQTT client library for iOS.
 *
 * An MQTT client application connects to MQTT-capable servers. 
 * A typical client is responsible for collecting information from a telemetry 
 * device and publishing the information to the server. It can also subscribe 
 * to topics, receive messages, and use this information to control the 
 * telemetry device.
 * 
 * MQTT clients implement the published MQTT v3 protocol. You can write your own
 * API to the MQTT protocol using the programming language and platform of your 
 * choice. This can be time-consuming and error-prone.
 * 
 * To simplify writing MQTT client applications, this library encapsulates
 * the MQTT v3 protocol for you. Using this library enables a fully functional 
 * MQTT client application to be written in a few lines of code.
 * The information presented here documents the API provided
 * by the Asynchronous MQTT Client library for iOS.
 * 
 * <b>Using the client</b><br>
 * Applications that use the client library typically use a similar structure:
 * <ul>
 * <li>Create a client object</li>
 * <li>Set the options to connect to an MQTT server</li>
 * <li>Set up callback functions</li>
 * <li>Connect the client to an MQTT server</li>
 * <li>Subscribe to any topics the client needs to receive</li>
 * <li>Repeat until finished:</li>
 *     <ul>
 *     <li>Publish any messages the client needs to</li>
 *     <li>Handle any incoming messages</li>
 *     </ul>
 * <li>Disconnect the client</li>
 * </ul>
 */

/**
 * A structure representing the payload and attributes of an MQTT message.
 */
@interface MqttMessage : NSObject

/** Initialise an MqttMessage
 * @param destinationName The topic to deliver the message to
 * @param payload The payload of the message as a null terminated char array
 * @param len The length of the payload
 * @param msgId The message identifier
 * @param qos The Quality of Service value
 * @param retained Is this a retained message
 * @param duplicate Is this a potential duplicate message
 * @returns A pointer to an MqttMessage initialised with the 
 * parameter values
 */
- (MqttMessage*) initWithMqttMessage:(NSString*)destinationName
                             payload:(char*)payload
                              length:(int)len
                               msgId:(int)msgId
                                 qos:(int)qos
                            retained:(BOOL)retained
                           duplicate:(BOOL)duplicate;
/** Initialise an MqttMessage
 * @param destinationName The topic to deliver the message to
 * @param payload The payload of the message as a null terminated char array
 * @param len The length of the payload
 * @param qos The Quality of Service value
 * @param retained Is this a retained message
 * @param duplicate Is this a potential duplicate message
 * @returns A pointer to an MqttMessage initialised with the 
 * parameter values
 */
- (MqttMessage*) initWithMqttMessage:(NSString*)destinationName
                             payload:(char*)payload
                              length:(int)len
                                 qos:(int)qos
                            retained:(BOOL)retained
                           duplicate:(BOOL)duplicate;
/** Initialise an MqttMessage
 * @param jMsg An NSDictionary containing the initialisation values
 * @returns A pointer to an MqttMessage initialised with the 
 * dictionary values
 */
- (MqttMessage*) initWithDictionary:(NSDictionary*)jMsg;
/** Get the properies of an MqttMessage as a dictionary
 * @return An NSMutableDictionary of the MqttMessage properties
 */
- (NSMutableDictionary*) toDictionary;

/** The topic name with which the message is associated. */
@property (copy) NSString* destinationName;
/** The payload contained by the message as a null terminated char array */
@property char* payload;
/** The size of the payload in bytes. */
@property int payloadLength;
/** The message identifier is normally reserved for internal use by the MQTT client and server. */
@property int msgId;
/** The quality of service assigned to the message. There are three
 *  levels of QoS in MQTT:
 *     QoS 0: "Fire and Forget", the message might not be delivered.
 *     QoS 1: "At Least Once", the message is delivered at least once,
 *            and may be delivered more than once under some circumstances.
 *     QoS 2: "Exactly Once", the message is guaranteed to be delivered
 *            once and only once, under any circumstance.
 */
@property int qos;
/** The retained flag serves two purposes depending on whether the
 *  message it is associated with is being published or received.
 *  retained == YES: For messages being published, a true setting
 *     indicates that the MQTT server should retain a copy of the
 *     message. The message will then be transmitted to new subscribers
 *     registering a new subscription, the flag being true indicates
 *     that the received message is not a new one, but one that has
 *     been retained by the MQTT server.
 *  retained == NO: For publishers, this indicates that this message
 *     should not be retained by the MQTT server. For subscribers,
 *     a NO setting indicates this is a normal messages, received as
 *     a result of it being published to the server.
 */
@property (getter=isRetained) BOOL retained;
/** The duplicate flag indicates whether or not this message is a
 *  duplicate. It is only meaningful when receiving QoS 1 messages.
 *  When true, the client application should take appropriate action
 *  to deal with the duplicate message.
 */
@property (readonly, getter=isDuplicate) BOOL duplicate;

@end



/**
 * A structure representing the settings to establish an SSL/TLS connection using the
 * OpenSSL library. It covers the following scenarios:
 * - Server authentication: The client needs the digital certificate of the server. It is included
 *   in a store containing trusted material (also known as "trust store").
 * - Mutual authentication: Both client and server are authenticated during the SSL handshake. In
 *   addition to the digital certificate of the server in a trust store, the client will need its own
 *   digital certificate and the private key used to sign its digital certificate stored in a "key store".
 * - Anonymous connection: Both client and server do not get authenticated and no credentials are needed
 *   to establish an SSL connection. Note that this scenario is not fully secure since it is subject to
 *   man-in-the-middle attacks.
 */
@interface SSLOptions : NSObject

/** True/False option to enable verification of the server certificate. */
@property            BOOL     enableServerCertAuth;
/** The list of cipher suites that the client will present to the server during the SSL handshake. For
 *  a full explanation of the cipher list format, please see the OpenSSL on-line documentation:
 *  http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT
 *  If this setting is omitted, its default value will be "ALL", that is, all the 
 *  cipher suites -excluding those offering no encryption- will be considered.
 *  This setting can be used to set an SSL anonymous connection ("aNULL" string value, for instance).
 */
@property  (copy)    NSString *enabledCipherSuites;
/** The file in PEM format containing the public certificate chain of the client. It may also include
 *  the client's private key.
 */
@property  (copy)    NSString *keyStore;
/** The file in PEM format containing the public digital certificates trusted by the client. */
@property  (copy)    NSString *trustStore;
/** If not included in the sslKeyStore, this setting points to the file in PEM format containing
 *  the client's private key. */
@property  (copy)    NSString *privateKey;
/** The password to load the client's privateKey if encrypted. */
@property  (copy)    NSString *privateKeyPassword;
@property  (copy)    NSData   *pkey;
@property  (copy)    NSData   *x509;

@end




/**
 * A structure representing the settings to establish an MQTT connection to a server
 */
@interface ConnectOptions : NSObject

/** The amount of time in seconds which the client may spend
 *  attempting to connect to the MQTT broker.
 */
@property  int       timeout;
/** Controls the behavior of both the client and server
 *  at connection and disconnection time. The client and server
 *  both maintain session state information. This information is
 *  used to ensure QoS 1 ("at least once") and QoS 2 ("exactly once")
 *  delivery, and "exactly once" receipt of messages. Session state
 *  also includes subscriptions created by an MQTT client. You can
 *  choose to maintain or discard state information between sessions.
 *  When cleanSession is YES, the state information is discarded at
 *  connect and disconnect. Setting cleanSession to false keeps the
 *  state information. When you connect an MQTT client application,
 *  the client identifies the connection using the client identifier
 *  and the address of the server. The server checks whether session
 *  information for this client has been saved from a previous connection
 *  to the server. If a previous session still exists, and cleanSession==YES,
 *  then the previous session information at the client and server is
 *  cleared. If cleanSession==NO, the previous session is resumed. If
 *  no previous session exists, a new session is started.
 */
@property  BOOL      cleanSession;
/** The maximum time between packets being sent to the server by the client
 *  to indicate that the client is still running. If no messages have been
 *  sent, or responded to, by the client in this many seconds the client
 *  will send a ping to the server.
 */
@property  int       keepAliveInterval;
/** When a client connects to an MQTT server, it may configure a Will 
 *  message which will only be published by the server if the client 
 *  does not disconnect cleanly.
 */
@property  (assign)  MqttMessage *willMessage;
/** Options related only to the use of SSL. See ::SSLOptions for details. */
@property  (assign)  SSLOptions *sslProperties;
/** MQTT servers that support the MQTT v3.1 protocol provide authentication
 *  and authorization by username and password.
 */
@property  (copy)    NSString *userName;
/** MQTT servers that support the MQTT v3.1 protocol provide authentication
 *  and authorization by username and password. Note that unless
 *  some sort of transport layer security is used, this information is 
 *  transmitted in plain-text across the wire.
 */
@property  (copy)    NSString *password;

@end




/** Structure defining properties unique to disconnecting */
@interface DisconnectOptions : NSObject

/** The amount of time in seconds the client may spend attempting
 *  to disconnect from the MQTT server. If the timeout is exceeded,
 *  the client will forcefully close the connection.
 */
@property int timeout;

@end




/** Protocol defining the callbacks and their signature for InvocationComplete */
@protocol InvocationComplete <NSObject>
@optional

/** Is called when the function the protocol is assigned to completes successfully
 *  @param invocationContext A pointer to a variable or object that is to be made 
 *  available to the onSuccess function, for example the MqttClient object 
 */
- (void) onSuccess:(NSObject*) invocationContext;
/** Is called when the function the protocol is assigned to fails to complete
 *  successfully
 *  @param invocationContext A pointer to a variable or object that is to be made 
 *  available to the onSuccess function, for example the MqttClient object
 *  @param errorCode An error code indicating the reason for the failure (this may
 *  not always be available)
 *  @param errorMessage An error message indicating the reason for the failure (this
 *  may not always be available)
 */
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;

@end




/** Protocol of methods to be implemented for MqttCallbacks */
@protocol MqttCallbacks <NSObject>
@optional

/** If the connection is determined to be broken between
 *  the client and MQTT server, this method will be executed. It may be
 *  used to attempt to re-establish a connection.
 *  @param invocationContext A pointer to a variable or object that is to be made
 *  available to the onConnectionLost function, for example the MqttClient object
 *  @param errorMessage An error message indicating the reason for the loss
 *  of connectivity (this may not always be available)
 */
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage;
/** If the client is subscribed to an MQTT topic which has
 *  a message delivered to it, this method will be executed upon delivery of
 *  that message to this client.
 *  @param invocationContext A pointer to a variable or object that is to be made
 *  available to the onMessageArrived function, for example the MqttClient object
 *  @param msg An MqttMessage object of the delivered message
 */
- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg;
/** If the client publishes a message to an MQTT topic,
 *  this method is executed upon successful delivery of that message to 
 *  the MQTT server.
 *  @param invocationContext A pointer to a variable or object that is to be made
 *  available to the onMessageDelivered function, for example the MqttClient object
 *  @param msgId the message identifier of the delivered message (no value
 *  if the delivered message was QoS0)
 */
- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId;

@end



/*****************
 *** MqttTrace ***
 *****************/

@interface MqttTrace

typedef NS_ENUM(int, TraceLevel) {
    TraceLevelDebug,
    TraceLevelLog,
    TraceLevelInfo,
    TraceLevelWarning,
    TraceLevelError
};

@end




/** Protocol which must be implemented in
 * order to handle trace messages. A simple implementation
 * is to have each of the trace methods call NSLog().
 */
@protocol MqttTraceHandler <NSObject>

/** Emit a trace message at the TraceLevelDebug level.
 *  @param message A string value of the trace message
 */
- (void) traceDebug: (NSString*)message;
/** Emit a trace message at the TraceLevelLog level.
 *  @param message A string value of the trace message
 */
- (void) traceLog:   (NSString*)message;
/** Emit a trace message at the TraceLevelInfo level.
 *  @param message A string value of the trace message
 */
- (void) traceInfo:  (NSString*)message;
/** Emit a trace message at the TraceLevelWarn level.
 *  @param message A string value of the trace message
 */
- (void) traceWarn:  (NSString*)message;
/** Emit a trace message at the TraceLevelError level.
 *  @param message A string value of the trace message
 */
- (void) traceError: (NSString*)message;

@end




/** An interface defining the properties and functions of an MqttClient */
@interface MqttClient:NSObject {
  /** The underlying C library client object */
	MQTTAsync myClient;
  /** The general timeout value for functions */
	int       timeout;
  /** the connectivity state of the client */
	BOOL      disconnected; // in MQTT context, as opposed to losing network connectivity
}

/** Set the client to use a specific ::MqttTraceHandler
 *  @param trace an MqttTraceHandler
 */
+ (void) setTrace:(id<MqttTraceHandler>) trace;
/** Initialise a client with the given options
 *  @param host hostname of the server to connect to
 *  @param port port on which the server is running
 *  @param clientId The clientId to be used by this connection
 */
- (MqttClient*) initWithHost:(NSString*)host port:(int)port clientId:(NSString*)clientId;
/** Initialiase a client with the given options for HA configurations
 *  @param hosts an array of hostname that constitute an HA configuration
 *  @param ports a corresponding array of port numbers for the HA servers
 *  @param clientId the clientId to be used by this connection
 */
- (MqttClient*) initWithHosts:(NSArray*)hosts ports:(NSArray*)ports clientId:(NSString*)clientId;
/** Disconnect the client from a server using the given ::DisconnectOptions
 *  @param discOpts The options to be used when disconnecting
 *  @param context A pointer to a variable or object to be passed to the onCompletion
 *  callbacks
 *  @param callback An instance of InvocationComplete to be called on the
 *  success or failure of disconnecting
 */
- (void) disconnectWithOptions:(DisconnectOptions *)discOpts invocationContext:(NSObject*) context  onCompletion:(id <InvocationComplete>) callback;
/** Connect the client to a server using the given ::ConnectOptions
 *  @param connOpts The options to be used when connecting
 *  @param context A pointer to a variable or object to be passed to the onCompletion
 *  callbacks
 *  @param callback An instance of InvocationComplete to be called on the
 *  success or failure of connecting.
 */
- (void) connectWithOptions:(ConnectOptions *) connOpts invocationContext:(NSObject*) invocationContext onCompletion:(id <InvocationComplete>) callback;
/** Send an MqttMessage to the connected server
 *  @param msg The ::MqttMessage to send
 *  @param context A pointer to a variable or object to be passed to the onCompletion callback
 *  @param callback An instance of InvocationComplete to be called on the
 *  success or failure of sending the message
 */
- (void) send: (MqttMessage *)msg invocationContext:(NSObject*) context onCompletion:(id <InvocationComplete>) callback;
/** Subscribe to a topic on the MQTT server
 *  @param topicFilter The topic to be subscribed to
 *  @param qos The maximum QoS at which to receive messages on this subscription
 *  @param context A pointer to a variable or object to be passed to the onCompletion
 *  callbacks
 *  @param callback An instance of InvocationComplete to be called on the
 *  success or failure of subscribing
 */
- (void) subscribe: (NSString *) topicFilter qos:(int) qos invocationContext:(NSObject*) context  onCompletion:(id <InvocationComplete>) callback;
/** Unsubscribe from a topic on the MQTT server
 *  @param topicFilter The topic to be unsubscribed from
 *  @param context A pointer to a variable or object to be passed to the onCompletion
 *  callbacks
 *  @param callback An instance of InvocationComplete to be called on the
 *  success or failure of unsubscribing
 */
- (void) unsubscribe: (NSString *) topicFilter invocationContext:(NSObject*) context  onCompletion:(id <InvocationComplete>) callback;
/** Query the connectivity status of the MqttClient
 *  @returns true or false to indicate connected or not connected
 */
- (BOOL) isConnected;

/** The array of MQTT server hostnames in an HA configuration */
@property(readonly, copy) NSArray* hostNames;
/** The array of ports for MQTT servers in an HA configuration */
@property(readonly, copy) NSArray* ports;
/** The client id used to identify the client */
@property(readonly, assign) NSString* clientId;
/** When connecting should it be a clean session */
@property(readonly) BOOL cleanSession;
/** The callbacks for connection lost, message delivered and message
 *  arrived events
 */
@property(retain)   id<MqttCallbacks> callbacks;

@end


