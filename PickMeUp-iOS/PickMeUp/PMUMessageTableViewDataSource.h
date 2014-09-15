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

#ifndef ChatMessageTableViewDataSource_h
#define ChatMessageTableViewDataSource_h

@class PMUMessage;
@class PMUMessageTableView;

/** The PMUMessageTableViewDatasource protocol defines the methods for accessing
 * data in the PMUMessageTableView. */
@protocol PMUMessageTableViewDataSource <NSObject>

@optional

@required

/** Returns the number of rows in the chat table.
 * @param tableView The table to get the number of rows from.
 */
- (NSInteger)rowsForChatTable:(PMUMessageTableView *)tableView;
/** Returns the PMUMessage object for the given row in the chat table. 
 * @param tableView The table to get the data from.
 * @param row The row of the table to get the data from.
 */
- (PMUMessage *)chatMessageTableView:(PMUMessageTableView *)tableView
                         dataForRow:(NSInteger)row;

@end

#endif