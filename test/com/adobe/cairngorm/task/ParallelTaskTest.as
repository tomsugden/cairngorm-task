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

    public class ParallelTaskTest extends TaskGroupTestFixture
    {
        private var taskgroup:ITaskGroup;

        public function ParallelTaskTest(methodName:String = null)
        {
            super(methodName);
        }

        override public function setUp():void
        {
            super.setUp();

            taskgroup = new ParallelTask();
            taskgroup.addChild(child1);
            taskgroup.addChild(child2);
        }

        public function testStartsAllChildren():void
        {
            taskgroup.start();

            assertEquals(TaskState.RUNNING, child1.currentState);
            assertEquals(TaskState.RUNNING, child2.currentState);
        }

        public function testFaultOccursWhenAChildFails():void
        {
            taskgroup.start();
            child1.faultNow();

            assertEquals(TaskState.FAULT, taskgroup.currentState);
        }

        public function testCompletesWhenAllChildrenHaveCompleted():void
        {
            taskgroup.start();
            child1.completeNow();

            assertEquals(TaskState.RUNNING, taskgroup.currentState);

            child2.completeNow();

            assertEquals(TaskState.COMPLETED, taskgroup.currentState);
        }

        public function testDispatchesProgressEventWhenFirstChildCompletes():void
        {
            listenForEvent(taskgroup, TaskEvent.TASK_PROGRESS);

            taskgroup.start();
            child1.completeNow();

            assertEvents();
            assertEquals(1, taskEvent.processed);
            assertEquals(2, taskEvent.size);
        }

        public function testDispatchesProgressEventWhenLastChildCompletes():void
        {
            taskgroup.start();
            child1.completeNow();

            listenForEvent(taskgroup, TaskEvent.TASK_PROGRESS);

            child2.completeNow();

            assertEvents();
            assertEquals(2, taskEvent.processed);
            assertEquals(2, taskEvent.size);
        }

        public function testDispatchesProgressEventWhenChildIsSkipped():void
        {
            child1.enabled = false;

            listenForEvent(taskgroup, TaskEvent.TASK_PROGRESS);

            taskgroup.start();

            assertEvents();
            assertEquals(1, taskEvent.processed);
            assertEquals(2, taskEvent.size);
            assertEquals(TaskState.UNSTARTED, child1.currentState);
        }
    }
}