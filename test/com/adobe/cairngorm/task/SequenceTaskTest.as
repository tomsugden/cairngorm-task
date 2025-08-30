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

    import mx.effects.easing.Exponential;

    public class SequenceTaskTest extends TaskGroupTestFixture
    {
        private var taskgroup:ITaskGroup;

        public function SequenceTaskTest(methodName:String = null)
        {
            super(methodName);
        }

        override public function setUp():void
        {
            super.setUp();

            taskgroup = new SequenceTask();
            taskgroup.addChild(child1);
            taskgroup.addChild(child2);
        }

        public function testStartsFirstChild():void
        {
            listenForEvent(child1, TaskEvent.TASK_START);

            taskgroup.start();

            assertEvents();
        }

        public function testDispatchesProgressEventWhenFirstChildCompletes():void
        {
            taskgroup.start();

            listenForEvent(taskgroup, TaskEvent.TASK_PROGRESS);

            child1.completeNow();

            assertEvents();
            assertEquals(1, taskgroup.processed);
            assertEquals(1, taskEvent.processed);
            assertEquals(2, taskEvent.size);
        }

        public function testDispatchesProgressEventWhenSecondChildCompletes():void
        {
            taskgroup.start();
            child1.completeNow();

            listenForEvent(taskgroup, TaskEvent.TASK_PROGRESS);

            child2.completeNow();

            assertEvents();
            assertEquals(2, taskgroup.processed);
            assertEquals(2, taskEvent.processed);
            assertEquals(2, taskEvent.size);
        }

        public function testDispatchesFaultEventWhenFirstChildFails():void
        {
            taskgroup.start();

            listenForEvent(child1, TaskEvent.TASK_FAULT);

            child1.faultNow();

            assertEvents();
        }

        public function testStartsSecondChildWhenFirstCompletes():void
        {
            taskgroup.start();

            listenForEvent(child2, TaskEvent.TASK_START);

            child1.completeNow();

            assertEvents();
        }

        public function testDoesNotStartSecondChildWhenFirstChildFails():void
        {
            listenForEvent(child2, TaskEvent.TASK_START, false);

            taskgroup.start();
            child1.faultNow();

            assertEvents();
        }

        public function testDispatchesCompleteEventWhenAllChildrenComplete():void
        {
            taskgroup.start();
            child1.completeNow();

            listenForEvent(taskgroup, TaskEvent.TASK_COMPLETE);

            child2.completeNow();

            assertEvents();
        }

        public function testSkipsDisabledTaskItem():void
        {
            child1.enabled = false;

            listenForEvent(child1, TaskEvent.TASK_START, false);

            taskgroup.start();

            assertEvents();
            assertEquals(1, taskgroup.processed);
        }

        public function testCompletesWhenAllChildrenDisabled():void
        {
            child1.enabled = false;
            child2.enabled = false;

            listenForEvent(taskgroup, TaskEvent.TASK_COMPLETE);
            listenForEvent(child1, TaskEvent.TASK_START, false);
            listenForEvent(child2, TaskEvent.TASK_START, false);

            taskgroup.start();

            assertEvents();
            assertEquals(2, taskgroup.processed);
        }
    }
}