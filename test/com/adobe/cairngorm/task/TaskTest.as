/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.task
{
    import flexunit.framework.EventfulTestCase;

    import mx.events.StateChangeEvent;

    public class TaskTest extends EventfulTestCase
    {
        private var taskItem:MockTask = new MockTask();

        public function TaskTest(methodName:String = null)
        {
            super(methodName);
        }

        public function testInitialStateIsUnstarted():void
        {
            assertEquals(TaskState.UNSTARTED, taskItem.currentState);
        }

        //-------------------------------
        //  currentState change tests
        //-------------------------------

        public function testCurrentStateChangesWhenStarted():void
        {
            listenForEvent(taskItem, StateChangeEvent.CURRENT_STATE_CHANGE);

            taskItem.start();

            assertEvents();
            assertEquals(TaskState.RUNNING, taskItem.currentState);
        }

        public function testCurrentStateChangesWhenCompleted():void
        {
            listenForEvent(taskItem, StateChangeEvent.CURRENT_STATE_CHANGE);

            taskItem.start();
            taskItem.completeNow();

            assertEvents();
            assertEquals(TaskState.COMPLETED, taskItem.currentState);
        }

        public function testCurrentStateChangesWhenFaulted():void
        {
            listenForEvent(taskItem, StateChangeEvent.CURRENT_STATE_CHANGE);

            taskItem.start();
            taskItem.faultNow();

            assertEvents();
            assertEquals(TaskState.FAULT, taskItem.currentState);
        }

        //-------------------------------
        //  TaskEvent dispatching tests
        //-------------------------------

        public function testDispatchedStartEventWhenStarted():void
        {
            listenForEvent(taskItem, TaskEvent.TASK_START);

            taskItem.start();

            assertEvents();
        }

        public function testDispatchesCompleteEventWhenCompleted():void
        {
            listenForEvent(taskItem, TaskEvent.TASK_COMPLETE);

            taskItem.start();
            taskItem.completeNow();

            assertEvents();
        }

        public function testDispatchesFaultEventWhenFaultOccurs():void
        {
            listenForEvent(taskItem, TaskEvent.TASK_FAULT);

            taskItem.start();
            taskItem.faultNow("fault message");

            assertEvents();
            assertEquals("fault message", TaskEvent(dispatchedExpectedEvents[0]).message);
        }

        //-------------------------------
        //  corner cases
        //-------------------------------

        public function testIgnoresRepeatedFaults():void
        {
            taskItem.start();
            taskItem.faultNow();

            listenForEvent(taskItem, TaskEvent.TASK_FAULT, false);
            listenForEvent(taskItem, StateChangeEvent.CURRENT_STATE_CHANGE, false);

            taskItem.faultNow();

            assertEvents();
        }

        public function testCompletesOnlyOnce():void
        {
            taskItem.start();
            taskItem.completeNow();

            listenForEvent(taskItem, TaskEvent.TASK_COMPLETE, false);
            listenForEvent(taskItem, StateChangeEvent.CURRENT_STATE_CHANGE, false);

            taskItem.completeNow();

            assertEvents();
        }

    /*
       Example showing duplicate events are undetected
       public function testListenForMultipleEvents() : void
       {
       var dispatcher : IEventDispatcher = new EventDispatcher();

       listenForEvent( dispatcher, "myEvent" );

       dispatcher.dispatchEvent( new Event( "myEvent" ) );
       dispatcher.dispatchEvent( new Event( "myEvent" ) );

       assertEvents();
       }
     */
    }
}