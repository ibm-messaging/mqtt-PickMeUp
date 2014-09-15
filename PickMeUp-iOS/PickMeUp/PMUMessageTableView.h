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
 *
 * Contributors:
 *    Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 *    Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#ifndef ChatMessageTableView_h
#define ChatMessageTableView_h

#import "PMUMessage.h"
#import "PMUMessageTableViewDataSource.h"

/** The PMUMessageTableView class implements the chat table of the application */
@interface PMUMessageTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

/** The data source for the chat table */
@property (nonatomic, assign) IBOutlet id<PMUMessageTableViewDataSource> chatMessageDataSource;
/** The array of messages for the chat table */
@property (nonatomic, retain) NSMutableArray *chatSection;

@end

#endif